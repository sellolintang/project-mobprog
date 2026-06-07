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

  static bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;
    if (value == 1) return true;
    if (value == 0) return false;

    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }

  factory ScoreCandidateModel.fromJson(Map json) {
    return ScoreCandidateModel(
      id: int.tryParse((json['id'] ?? json['candidate_id'] ?? 0).toString()) ??
          0,
      registrationNumber: json['registration_number']?.toString() ?? '-',
      fullName: json['full_name']?.toString() ?? '',
      studentNumber: json['student_number']?.toString() ?? '',
      studyProgram: json['study_program']?.toString(),
      candidateStatus: (json['candidate_status'] ?? json['status'])?.toString(),
      scheduledAt: json['scheduled_at']?.toString(),
      location: json['location']?.toString(),
      interviewStatus: json['interview_status']?.toString(),
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      scoredCriteriaCount:
      int.tryParse(json['scored_criteria_count'].toString()) ?? 0,
      completionPercentage:
      double.tryParse(json['completion_percentage'].toString()) ?? 0.0,
      averageScore: json['average_score'] == null
          ? null
          : double.tryParse(json['average_score'].toString()),
      isComplete: _parseBool(json['is_complete']),
      lastUpdatedAt: json['last_updated_at']?.toString(),
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

  factory ScoreCriterionModel.fromJson(Map json) {
    return ScoreCriterionModel(
      id: int.tryParse((json['id'] ?? json['criterion_id'] ?? 0).toString()) ??
          0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      weight: double.tryParse(json['weight'].toString()) ?? 0.0,
      type: json['type']?.toString() ?? 'benefit',
      minScore: double.tryParse(json['min_score'].toString()) ?? 0.0,
      maxScore: double.tryParse(json['max_score'].toString()) ?? 100.0,
      score: json['score'] == null
          ? null
          : double.tryParse(json['score'].toString()),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ScoringFormCandidateModel {
  final int id;
  final String registrationNumber;
  final String fullName;
  final String studentNumber;
  final String? email;
  final String? phone;
  final String? faculty;
  final String? studyProgram;
  final int? semester;
  final String? vision;
  final String? mission;
  final String? status;
  final String? scheduledAt;
  final String? location;
  final String? interviewStatus;

  const ScoringFormCandidateModel({
    required this.id,
    required this.registrationNumber,
    required this.fullName,
    required this.studentNumber,
    this.email,
    this.phone,
    this.faculty,
    this.studyProgram,
    this.semester,
    this.vision,
    this.mission,
    this.status,
    this.scheduledAt,
    this.location,
    this.interviewStatus,
  });

  factory ScoringFormCandidateModel.fromJson(Map json) {
    return ScoringFormCandidateModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      registrationNumber: json['registration_number']?.toString() ?? '-',
      fullName: json['full_name']?.toString() ?? '-',
      studentNumber: json['student_number']?.toString() ?? '-',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      faculty: json['faculty']?.toString(),
      studyProgram: json['study_program']?.toString(),
      semester: int.tryParse(json['semester']?.toString() ?? ''),
      vision: json['vision']?.toString(),
      mission: json['mission']?.toString(),
      status: json['status']?.toString(),
      scheduledAt: json['scheduled_at']?.toString(),
      location: json['location']?.toString(),
      interviewStatus: json['interview_status']?.toString(),
    );
  }
}

class ScoringFormSummaryModel {
  final int assignedCriteriaCount;
  final int scoredCriteriaCount;
  final double completionPercentage;
  final double? averageScore;
  final bool isComplete;

  const ScoringFormSummaryModel({
    required this.assignedCriteriaCount,
    required this.scoredCriteriaCount,
    required this.completionPercentage,
    this.averageScore,
    required this.isComplete,
  });

  factory ScoringFormSummaryModel.fromJson(Map json) {
    return ScoringFormSummaryModel(
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      scoredCriteriaCount:
      int.tryParse(json['scored_criteria_count'].toString()) ?? 0,
      completionPercentage:
      double.tryParse(json['completion_percentage'].toString()) ?? 0,
      averageScore: json['average_score'] == null
          ? null
          : double.tryParse(json['average_score'].toString()),
      isComplete: json['is_complete'] == true ||
          json['is_complete'] == 1 ||
          json['is_complete']?.toString() == '1',
    );
  }

  factory ScoringFormSummaryModel.empty() {
    return const ScoringFormSummaryModel(
      assignedCriteriaCount: 0,
      scoredCriteriaCount: 0,
      completionPercentage: 0,
      averageScore: null,
      isComplete: false,
    );
  }
}

class ScoringFormDataModel {
  final int periodId;
  final ScoringFormCandidateModel? candidate;
  final List<ScoreCriterionModel> criteria;
  final ScoringFormSummaryModel summary;

  const ScoringFormDataModel({
    required this.periodId,
    required this.candidate,
    required this.criteria,
    required this.summary,
  });

  factory ScoringFormDataModel.fromJson(Map<String, dynamic> json) {
    final rawCandidate = json['candidate'];
    final rawCriteria = json['criteria'];
    final rawSummary = json['summary'];

    return ScoringFormDataModel(
      periodId: int.tryParse(json['period_id'].toString()) ?? 0,
      candidate: rawCandidate is Map
          ? ScoringFormCandidateModel.fromJson(rawCandidate)
          : null,
      criteria: rawCriteria is List
          ? rawCriteria
          .whereType<Map>()
          .map((item) => ScoreCriterionModel.fromJson(item))
          .toList()
          : <ScoreCriterionModel>[],
      summary: rawSummary is Map
          ? ScoringFormSummaryModel.fromJson(rawSummary)
          : ScoringFormSummaryModel.empty(),
    );
  }
}

class ScoringHistoryDetailModel {
  final int periodId;
  final ScoringFormCandidateModel? candidate;
  final List<ScoreCriterionModel> scores;
  final ScoringFormSummaryModel summary;

  const ScoringHistoryDetailModel({
    required this.periodId,
    required this.candidate,
    required this.scores,
    required this.summary,
  });

  factory ScoringHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    final rawCandidate = json['candidate'];
    final rawScores = json['scores'] ?? json['criteria'];
    final rawSummary = json['summary'];

    return ScoringHistoryDetailModel(
      periodId: int.tryParse(json['period_id']?.toString() ?? '0') ?? 0,
      candidate: rawCandidate is Map
          ? ScoringFormCandidateModel.fromJson(rawCandidate)
          : null,
      scores: rawScores is List
          ? rawScores
          .whereType<Map>()
          .map((item) {
        final criterion = item['criterion'];

        if (criterion is Map) {
          final merged = <String, dynamic>{
            ...Map<String, dynamic>.from(criterion),
            'score': item['score'],
            'updated_at': item['updated_at'],
          };

          return ScoreCriterionModel.fromJson(merged);
        }

        return ScoreCriterionModel.fromJson(item);
      })
          .toList()
          : <ScoreCriterionModel>[],
      summary: rawSummary is Map
          ? ScoringFormSummaryModel.fromJson(rawSummary)
          : ScoringFormSummaryModel.empty(),
    );
  }
}