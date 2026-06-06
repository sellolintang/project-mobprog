class CriterionModel {
  final int id;
  final int periodId;
  final String code;
  final String name;
  final double weight;
  final String type;
  final double minScore;
  final double maxScore;
  final bool isActive;

  CriterionModel({
    required this.id,
    required this.periodId,
    required this.code,
    required this.name,
    required this.weight,
    required this.type,
    required this.minScore,
    required this.maxScore,
    required this.isActive,
  });

  factory CriterionModel.fromJson(Map<String, dynamic> json) {
    return CriterionModel(
      id: json['id'] ?? 0,
      periodId: json['period_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      weight: double.tryParse(json['weight'].toString()) ?? 0.0,
      type: json['type'] ?? 'benefit',
      minScore: double.tryParse(json['min_score'].toString()) ?? 0.0,
      maxScore: double.tryParse(json['max_score'].toString()) ?? 100.0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}