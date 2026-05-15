class AlumniModel {
  final String id;
  final String fullName;
  final int graduationYear;
  final String? profession;
  final String? location;
  final String? phone;
  final String? roleName;

  AlumniModel({
    required this.id,
    required this.fullName,
    required this.graduationYear,
    this.profession,
    this.location,
    this.phone,
    this.roleName,
  });

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      graduationYear: json['graduation_year'] as int,
      profession: json['profession'] as String?,
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      roleName: json['roles'] != null ? json['roles']['role_name'] as String? : null,
    );
  }
}
