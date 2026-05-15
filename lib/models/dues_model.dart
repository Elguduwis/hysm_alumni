class DuesModel {
  final String id;
  final double amountExpected;
  final int dueMonth;
  final int dueYear;
  final String status;
  final DateTime createdAt;

  DuesModel({
    required this.id,
    required this.amountExpected,
    required this.dueMonth,
    required this.dueYear,
    required this.status,
    required this.createdAt,
  });

  factory DuesModel.fromJson(Map<String, dynamic> json) {
    return DuesModel(
      id: json['id'] as String,
      amountExpected: (json['amount_expected'] as num).toDouble(),
      dueMonth: json['due_month'] as int,
      dueYear: json['due_year'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
