import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dues_model.dart';

class DuesService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<DuesModel> _duesList = [];
  List<DuesModel> get duesList => _duesList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalOutstanding => _duesList.where((d) => d.status != 'Paid').fold(0.0, (sum, item) => sum + item.amountExpected);

  Future<void> initDues() async {
    _isLoading = true;
    notifyListeners();
    await _generateCurrentMonthDueIfMissing();
    await fetchDues();
  }

  Future<void> _generateCurrentMonthDueIfMissing() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    try {
      final existing = await _supabase.from('monthly_dues').select().eq('user_id', user.id).eq('due_month', now.month).eq('due_year', now.year);
      
      if (existing.isEmpty) {
        // DYNAMIC FEE FETCH: Ask the database for the current official fee amount!
        double defaultAmount = 2000.00;
        try {
          final settings = await _supabase.from('system_settings').select('value').eq('key', 'monthly_dues_amount').single();
          defaultAmount = double.tryParse(settings['value'].toString()) ?? 2000.00;
        } catch (_) {} // Fallback to 2000 if setting is missing

        await _supabase.from('monthly_dues').insert({
          'user_id': user.id, 
          'amount_expected': defaultAmount, 
          'due_month': now.month, 
          'due_year': now.year, 
          'status': 'Unpaid',
        });
      }
    } catch (e) { debugPrint('Error generating dues: $e'); }
  }

  Future<void> fetchDues() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await _supabase.from('monthly_dues').select().eq('user_id', user.id).order('due_year', ascending: false).order('due_month', ascending: false);
      _duesList = (response as List).map((data) => DuesModel.fromJson(data)).toList();
    } catch (e) { debugPrint('Error fetching dues: $e'); } 
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> confirmPaymentSuccess(String dueId) async {
    try {
      await _supabase.from('monthly_dues').update({'status': 'Paid'}).eq('id', dueId);
      await fetchDues();
    } catch (e) {
      debugPrint('Error confirming payment: $e');
    }
  }
}
