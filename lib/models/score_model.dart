class ScoreCandidateModel {
  final int id;
  final String registrationNumber;
  final String fullName;
  final String studentNumber;
  final String? studyProgram;
  final String? candidateStatus;
  final String? scheduledAt;
  final String? location;
  final String? interviewStatus;
  final int assignedCriteriaCount;
  final int scoredCriteriaCount;
  final double completionPercentage;
  final double? averageScore;
  final bool isComplete;
  final String? lastUpdatedAt;

  ScoreCandidateModel({
    required this.id,
    required this.registrationNumber,
    required this.fullName,
    required this.studentNumber,
    this.studyProgram,
    this.candidateStatus,
    this.scheduledAt,
    this.location,
    this.interviewStatus,
    required this.assignedCriteriaCount,
    required this.scoredCriteriaCount,
    required this.completionPercentage,
    this.averageScore,
    required this.isComplete,
    this.lastUpdatedAt,
  });

  factory ScoreCandidateModel.fromJson(Map<String, dynamic> json) {
    return ScoreCandidateModel(
      id: json['id'] ?? json['candidate_id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '-',
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      studyProgram: json['study_program'],
      candidateStatus: json['candidate_status'] ?? json['status'],
      scheduledAt: json['scheduled_at'],
      location: json['location'],
      interviewStatus: json['interview_status'],
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      scoredCriteriaCount:
      int.tryParse(json['scored_criteria_count'].toString()) ?? 0,
      completionPercentage:
      double.tryParse(json['completion_percentage'].toString()) ?? 0.0,
      averageScore: json['average_score'] == null
          ? null
          : double.tryParse(json['average_score'].toString()),
      isComplete: json['is_complete'] == true || json['is_complete'] == 1,
      lastUpdatedAt: json['last_updated_at'],
    );
  }
}

class ScoreCriterionModel {
  final int id;
  final String code;
  final String name;
  final double weight;
  final String type;
  final double minScore;
  final double maxScore;
  final double? score;
  final String? updatedAt;

  ScoreCriterionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.weight,
    required this.type,
    required this.minScore,
    required this.maxScore,
    this.score,
    this.updatedAt,
  });

  factory ScoreCriterionModel.fromJson(Map<String, dynamic> json) {
    return ScoreCriterionModel(
      id: json['id'] ?? json['criterion_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      weight: double.tryParse(json['weight'].toString()) ?? 0.0,
      type: json['type'] ?? 'benefit',
      minScore: double.tryParse(json['min_score'].toString()) ?? 0.0,
      maxScore: double.tryParse(json['max_score'].toString()) ?? 100.0,
      score: json['score'] == null
          ? null
          : double.tryParse(json['score'].toString()),
      updatedAt: json['updated_at'],
    );
  }
}