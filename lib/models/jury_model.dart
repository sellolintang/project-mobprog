import 'criterion_model.dart';

class JuryModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final int criteriaCount;
  final List<String> criteriaCodes;
  final List<CriterionModel> criteria;

  JuryModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.criteriaCount,
    required this.criteriaCodes,
    required this.criteria,
  });

  factory JuryModel.fromJson(Map<String, dynamic> json) {
    final criteriaData = json['criteria'];

    return JuryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'juri',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      criteriaCount: int.tryParse(json['criteria_count'].toString()) ?? 0,
      criteriaCodes: json['criteria_codes'] is List
          ? List<String>.from(
        json['criteria_codes'].map((item) => item.toString()),
      )
          : [],
      criteria: criteriaData is List
          ? criteriaData
          .map(
            (item) => CriterionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }
}