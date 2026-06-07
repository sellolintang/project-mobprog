class JuryDashboardSummaryModel {
  final int assignedCriteriaCount;
  final int eligibleCandidateCount;
  final int completedCandidateCount;
  final int incompleteCandidateCount;
  final int scoreRecordsCount;
  final double completionPercentage;

  const JuryDashboardSummaryModel({
    required this.assignedCriteriaCount,
    required this.eligibleCandidateCount,
    required this.completedCandidateCount,
    required this.incompleteCandidateCount,
    required this.scoreRecordsCount,
    required this.completionPercentage,
  });

  factory JuryDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return JuryDashboardSummaryModel(
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      eligibleCandidateCount:
      int.tryParse(json['eligible_candidate_count'].toString()) ?? 0,
      completedCandidateCount:
      int.tryParse(json['completed_candidate_count'].toString()) ?? 0,
      incompleteCandidateCount:
      int.tryParse(json['incomplete_candidate_count'].toString()) ?? 0,
      scoreRecordsCount:
      int.tryParse(json['score_records_count'].toString()) ?? 0,
      completionPercentage: double.tryParse(
        json['completion_percentage'].toString(),
      ) ??
          0,
    );
  }
}

class JuryAssignedCriterionModel {
  final int id;
  final String code;
  final String name;
  final double weight;
  final String type;
  final double minScore;
  final double maxScore;

  const JuryAssignedCriterionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.weight,
    required this.type,
    required this.minScore,
    required this.maxScore,
  });

  factory JuryAssignedCriterionModel.fromJson(Map<String, dynamic> json) {
    return JuryAssignedCriterionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      code: json['code']?.toString() ?? '-',
      name: json['name']?.toString() ?? '-',
      weight: double.tryParse(json['weight'].toString()) ?? 0,
      type: json['type']?.toString() ?? '-',
      minScore: double.tryParse(json['min_score'].toString()) ?? 0,
      maxScore: double.tryParse(json['max_score'].toString()) ?? 100,
    );
  }
}

class JuryDashboardCandidateModel {
  final int id;
  final String registrationNumber;
  final String fullName;
  final String studentNumber;
  final String? studyProgram;
  final String status;
  final int scoredCriteriaCount;
  final int assignedCriteriaCount;
  final double completionPercentage;
  final bool isComplete;
  final double? averageScore;

  const JuryDashboardCandidateModel({
    required this.id,
    required this.registrationNumber,
    required this.fullName,
    required this.studentNumber,
    required this.studyProgram,
    required this.status,
    required this.scoredCriteriaCount,
    required this.assignedCriteriaCount,
    required this.completionPercentage,
    required this.isComplete,
    required this.averageScore,
  });

  factory JuryDashboardCandidateModel.fromJson(Map<String, dynamic> json) {
    return JuryDashboardCandidateModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      registrationNumber: json['registration_number']?.toString() ?? '-',
      fullName: json['full_name']?.toString() ?? '-',
      studentNumber: json['student_number']?.toString() ?? '-',
      studyProgram: json['study_program']?.toString(),
      status: json['status']?.toString() ?? '-',
      scoredCriteriaCount:
      int.tryParse(json['scored_criteria_count'].toString()) ?? 0,
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      completionPercentage: double.tryParse(
        json['completion_percentage'].toString(),
      ) ??
          0,
      isComplete: json['is_complete'] == true ||
          json['is_complete'] == 1 ||
          json['is_complete']?.toString() == '1',
      averageScore: json['average_score'] == null
          ? null
          : double.tryParse(json['average_score'].toString()),
    );
  }
}

class JuryRecentScoreModel {
  final int id;
  final double score;
  final String? updatedAt;
  final String candidateName;
  final String criterionCode;
  final String criterionName;

  const JuryRecentScoreModel({
    required this.id,
    required this.score,
    required this.updatedAt,
    required this.candidateName,
    required this.criterionCode,
    required this.criterionName,
  });

  factory JuryRecentScoreModel.fromJson(Map<String, dynamic> json) {
    return JuryRecentScoreModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      score: double.tryParse(json['score'].toString()) ?? 0,
      updatedAt: json['updated_at']?.toString(),
      candidateName: json['candidate_name']?.toString() ?? '-',
      criterionCode: json['criterion_code']?.toString() ?? '-',
      criterionName: json['criterion_name']?.toString() ?? '-',
    );
  }
}

class JuryDashboardModel {
  final int periodId;
  final JuryDashboardSummaryModel summary;
  final List<JuryAssignedCriterionModel> assignedCriteria;
  final List<JuryDashboardCandidateModel> candidates;
  final List<JuryRecentScoreModel> recentScores;

  const JuryDashboardModel({
    required this.periodId,
    required this.summary,
    required this.assignedCriteria,
    required this.candidates,
    required this.recentScores,
  });

  factory JuryDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawSummary = json['summary'];
    final rawAssignedCriteria = json['assigned_criteria'];
    final rawCandidates = json['candidates'];
    final rawRecentScores = json['recent_scores'];

    return JuryDashboardModel(
      periodId: int.tryParse(json['period_id'].toString()) ?? 0,
      summary: rawSummary is Map
          ? JuryDashboardSummaryModel.fromJson(
        Map<String, dynamic>.from(rawSummary),
      )
          : const JuryDashboardSummaryModel(
        assignedCriteriaCount: 0,
        eligibleCandidateCount: 0,
        completedCandidateCount: 0,
        incompleteCandidateCount: 0,
        scoreRecordsCount: 0,
        completionPercentage: 0,
      ),
      assignedCriteria: rawAssignedCriteria is List
          ? rawAssignedCriteria
          .whereType<Map>()
          .map(
            (item) => JuryAssignedCriterionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <JuryAssignedCriterionModel>[],
      candidates: rawCandidates is List
          ? rawCandidates
          .whereType<Map>()
          .map(
            (item) => JuryDashboardCandidateModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <JuryDashboardCandidateModel>[],
      recentScores: rawRecentScores is List
          ? rawRecentScores
          .whereType<Map>()
          .map(
            (item) => JuryRecentScoreModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <JuryRecentScoreModel>[],
    );
  }
}