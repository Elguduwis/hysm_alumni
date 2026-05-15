import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting_model.dart';

class MeetingService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<MeetingModel> _meetings = [];
  List<MeetingModel> get meetings => _meetings;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _canSchedule = false;
  bool get canSchedule => _canSchedule;

  Future<void> initMeetings() async {
    await _checkUserRole();
    await fetchMeetings();
  }

  Future<void> _checkUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await _supabase
          .from('profiles')
          .select('role_id')
          .eq('id', user.id)
          .single();
      
      _canSchedule = (response['role_id'] as int) > 1;
      notifyListeners();
    } catch (e) {
      debugPrint('Role check error: $e');
    }
  }

  Future<void> fetchMeetings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('announcements')
          .select('id, title, content, date_scheduled, meeting_link, profiles(full_name)')
          .eq('type', 'Meeting')
          .order('date_scheduled', ascending: true); // Show upcoming first
          
      _meetings = (response as List).map((data) => MeetingModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching meetings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scheduleMeeting(String title, String description, DateTime date, String link) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.from('announcements').insert({
        'author_id': user.id,
        'title': title,
        'content': description,
        'type': 'Meeting',
        'date_scheduled': date.toIso8601String(),
        'meeting_link': link.isEmpty ? null : link,
      });
      await fetchMeetings();
    } catch (e) {
      debugPrint('Error scheduling: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
