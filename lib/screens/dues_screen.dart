import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import '../services/dues_service.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen> {
  // REPLACE THIS WITH YOUR PAYSTACK PUBLIC KEY
  final String paystackPublicKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _handlePayment(BuildContext context, String dueId, double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    await PayWithPaystack().now(
      context: context,
      secretKey: "YOUR_PAYSTACK_SECRET_KEY_IF_USING_BACKEND_ELSE_IGNORE", 
      customerEmail: user.email!,
      reference: 'HYSM_${DateTime.now().millisecondsSinceEpoch}',
      currency: "NGN",
      amount: (amount * 100).toInt(),
      transactionCompleted: () async {
        await context.read<DuesService>().confirmPaymentSuccess(dueId, "COMPLETED");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
          );
        }
      },
      transactionNotCompleted: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Not Completed'), backgroundColor: Colors.orange),
          );
        }
      },
      callbackUrl: "https://wpkqiguvhnymqopzjfej.supabase.co", // Using your project URL
      publicKey: paystackPublicKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Dues & Finance')),
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
                  gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1), 
                                  foregroundColor: Colors.white,
                                ),
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
