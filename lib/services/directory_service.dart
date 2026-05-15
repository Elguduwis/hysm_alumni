import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alumni_model.dart';

class DirectoryService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<AlumniModel> _alumni = [];
  List<AlumniModel> get alumni => _alumni;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAlumni() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch profiles and join with roles table to get Exco titles
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, graduation_year, profession, location, phone, roles(role_name)')
          .order('graduation_year', ascending: false);
          
      _alumni = (response as List).map((data) => AlumniModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching directory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
