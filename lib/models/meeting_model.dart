class MeetingModel {
  final String id;
  final String title;
  final String description;
  final DateTime? dateScheduled;
  final String? meetingLink;
  final String? authorName;

  MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    this.dateScheduled,
    this.meetingLink,
    this.authorName,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['content'] as String, // Stored in the content column
      dateScheduled: json['date_scheduled'] != null ? DateTime.parse(json['date_scheduled']) : null,
      meetingLink: json['meeting_link'] as String?,
      authorName: json['profiles'] != null ? json['profiles']['full_name'] as String? : 'Admin',
    );
  }
}
