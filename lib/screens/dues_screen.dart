import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Dues')),
      body: Consumer<DuesService>(
        builder: (context, duesService, child) {
          if (duesService.isLoading && duesService.duesList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Total Arrears Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Total Outstanding Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency.format(duesService.totalOutstanding),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Dues List
              Expanded(
                child: ListView.builder(
                  itemCount: duesService.duesList.length,
                  itemBuilder: (context, index) {
                    final due = duesService.duesList[index];
                    final isPaid = due.status == 'Paid';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isPaid ? Icons.check : Icons.warning_amber_rounded,
                            color: isPaid ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text('${_getMonthName(due.dueMonth)} ${due.dueYear} Due', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(formatCurrency.format(due.amountExpected)),
                        trailing: isPaid
                            ? const Chip(label: Text('Paid', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                                onPressed: () => duesService.mockPayDue(due.id),
                                child: const Text('Pay Now'),
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
