import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_paystack_fork/flutter_paystack_fork.dart';
import '../services/dues_service.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen> {
  final plugin = PaystackPlugin();
  
  // Your verified Paystack Test Key
  final String paystackPublicKey = 'pk_test_c06652bbd642f969303bfe3063a2804f2a3af830';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DuesService>().initDues();
    });
  }

  Future<void> _handlePayment(BuildContext context, String dueId, double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    // BULLETPROOF FIX: Await initialization exactly before the checkout is triggered
    await plugin.initialize(publicKey: paystackPublicKey);

    Charge charge = Charge()
      ..amount = (amount * 100).toInt() // Convert to Kobo
      ..reference = 'HYSM_${DateTime.now().millisecondsSinceEpoch}'
      ..email = user.email!;

    try {
      CheckoutResponse response = await plugin.checkout(
        context,
        method: CheckoutMethod.card, // Directs to card payment UI
        charge: charge,
        logo: const Icon(Icons.school, size: 50, color: Color(0xFF4A148C)), // Deep Purple
      );

      if (response.status == true && context.mounted) {
        await context.read<DuesService>().confirmPaymentSuccess(dueId, response.reference ?? "N/A");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Cancelled or Failed'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dues & Finance'),
        backgroundColor: const Color(0xFF4A148C), // Deep Purple
        foregroundColor: Colors.white,
      ),
      body: Consumer<DuesService>(
        builder: (context, duesService, child) {
          if (duesService.isLoading && duesService.duesList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const Text('Total Outstanding Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency.format(duesService.totalOutstanding),
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: duesService.duesList.length,
                  itemBuilder: (context, index) {
                    final due = duesService.duesList[index];
                    final isPaid = due.status == 'Paid';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isPaid ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle),
                          child: Icon(isPaid ? Icons.check_circle : Icons.warning_rounded, color: isPaid ? Colors.green : Colors.red),
                        ),
                        title: Text('${_getMonthName(due.dueMonth)} ${due.dueYear} Due', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(formatCurrency.format(due.amountExpected)),
                        trailing: isPaid
                            ? const Text('PAID', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white),
                                onPressed: () => _handlePayment(context, due.id, due.amountExpected),
                                child: const Text('Pay'),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
