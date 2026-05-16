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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // DYNAMIC KEY FETCH: Grab the Secret Key directly from Supabase!
      final response = await Supabase.instance.client
          .from('system_settings')
          .select('value')
          .eq('key', 'paystack_secret_key')
          .single();
          
      final dynamicSecretKey = response['value'] as String;

      if (context.mounted) Navigator.pop(context); // Close loading dialog

      await PayWithPayStack().now(
        context: context,
        secretKey: dynamicSecretKey,
        customerEmail: user.email!,
        reference: 'HYSM_${DateTime.now().millisecondsSinceEpoch}',
        currency: "NGN",
        // FIX 1: Leave it as a double (amount is a double, so * 100 stays a double)
        amount: amount * 100, 
        // FIX 2: Accept the paymentData parameter
        transactionCompleted: (paymentData) async {
          await context.read<DuesService>().confirmPaymentSuccess(dueId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
            );
          }
        },
        // FIX 3: Accept the error string parameter
        transactionNotCompleted: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Cancelled or Failed'), backgroundColor: Colors.orange),
            );
          }
        },
        callbackUrl: "https://wpkqiguvhnymqopzjfej.supabase.co", 
      );

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
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
        backgroundColor: const Color(0xFF4A148C),
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
