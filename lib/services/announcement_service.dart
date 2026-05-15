import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> get announcements => _announcements;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _canPost = false;
  bool get canPost => _canPost;

  Future<void> initAnnouncements() async {
    await _checkUserRole();
    await fetchAnnouncements();
  }

  // Checks if the user is an Exco (Role ID > 1)
  Future<void> _checkUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await _supabase
          .from('profiles')
          .select('role_id')
          .eq('id', user.id)
          .single();
      
      _canPost = (response['role_id'] as int) > 1;
      notifyListeners();
    } catch (e) {
      debugPrint('Role check error: $e');
    }
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('announcements')
          .select('id, title, content, type, created_at, profiles(full_name)')
          .order('created_at', ascending: false);
          
      _announcements = (response as List).map((data) => AnnouncementModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postAnnouncement(String title, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.from('announcements').insert({
        'author_id': user.id,
        'title': title,
        'content': content,
        'type': 'Announcement',
      });
      await fetchAnnouncements();
    } catch (e) {
      debugPrint('Error posting: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
