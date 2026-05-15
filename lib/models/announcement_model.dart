class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final String? authorName;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.authorName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      // We join the profiles table to grab the author's real name!
      authorName: json['profiles'] != null ? json['profiles']['full_name'] as String? : 'Admin',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
