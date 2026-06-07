class ScoreMonitoringSummaryModel {
  final int totalCandidates;
  final int completeCandidates;
  final int incompleteCandidates;
  final int criteriaCount;
  final int juriesCount;
  final int scoreRecordsCount;
  final double completionPercentage;

  const ScoreMonitoringSummaryModel({
    required this.totalCandidates,
    required this.completeCandidates,
    required this.incompleteCandidates,
    required this.criteriaCount,
    required this.juriesCount,
    required this.scoreRecordsCount,
    required this.completionPercentage,
  });

  factory ScoreMonitoringSummaryModel.fromJson(Map<String, dynamic> json) {
    return ScoreMonitoringSummaryModel(
      totalCandidates: int.tryParse(json['total_candidates'].toString()) ?? 0,
      completeCandidates:
      int.tryParse(json['complete_candidates'].toString()) ?? 0,
      incompleteCandidates:
      int.tryParse(json['incomplete_candidates'].toString()) ?? 0,
      criteriaCount: int.tryParse(json['criteria_count'].toString()) ?? 0,
      juriesCount: int.tryParse(json['juries_count'].toString()) ?? 0,
      scoreRecordsCount:
      int.tryParse(json['score_records_count'].toString()) ?? 0,
      completionPercentage: double.tryParse(
        json['completion_percentage'].toString(),
      ) ??
          0,
    );
  }
}

class MissingCriterionModel {
  final int criterionId;
  final String criterionCode;
  final String criterionName;

  const MissingCriterionModel({
    required this.criterionId,
    required this.criterionCode,
    required this.criterionName,
  });

  factory MissingCriterionModel.fromJson(Map<String, dynamic> json) {
    return MissingCriterionModel(
      criterionId: int.tryParse(json['criterion_id'].toString()) ?? 0,
      criterionCode: json['criterion_code']?.toString() ?? '-',
      criterionName: json['criterion_name']?.toString() ?? '-',
    );
  }
}

class CandidateScoreMonitoringModel {
  final int id;
  final String registrationNumber;
  final String fullName;
  final String studentNumber;
  final String? studyProgram;
  final String status;
  final int scoredCriteriaCount;
  final int criteriaCount;
  final double completionPercentage;
  final bool isComplete;
  final double? averageScore;
  final List<MissingCriterionModel> missingCriteria;

  const CandidateScoreMonitoringModel({
    required this.id,
    required this.registrationNumber,
    required this.fullName,
    required this.studentNumber,
    required this.studyProgram,
    required this.status,
    required this.scoredCriteriaCount,
    required this.criteriaCount,
    required this.completionPercentage,
    required this.isComplete,
    required this.averageScore,
    required this.missingCriteria,
  });

  factory CandidateScoreMonitoringModel.fromJson(Map<String, dynamic> json) {
    final rawMissingCriteria = json['missing_criteria'];

    return CandidateScoreMonitoringModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      registrationNumber: json['registration_number']?.toString() ?? '-',
      fullName: json['full_name']?.toString() ?? '-',
      studentNumber: json['student_number']?.toString() ?? '-',
      studyProgram: json['study_program']?.toString(),
      status: json['status']?.toString() ?? '-',
      scoredCriteriaCount:
      int.tryParse(json['scored_criteria_count'].toString()) ?? 0,
      criteriaCount: int.tryParse(json['criteria_count'].toString()) ?? 0,
      completionPercentage: double.tryParse(
        json['completion_percentage'].toString(),
      ) ??
          0,
      isComplete: json['is_complete'] == true,
      averageScore: json['average_score'] == null
          ? null
          : double.tryParse(json['average_score'].toString()),
      missingCriteria: rawMissingCriteria is List
          ? rawMissingCriteria
          .whereType<Map>()
          .map(
            (item) => MissingCriterionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <MissingCriterionModel>[],
    );
  }
}

class CriterionScoreMonitoringModel {
  final int id;
  final String code;
  final String name;
  final String type;
  final double weight;
  final int scoredCandidateCount;
  final int candidateCount;
  final int missingCandidateCount;
  final double completionPercentage;

  const CriterionScoreMonitoringModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.weight,
    required this.scoredCandidateCount,
    required this.candidateCount,
    required this.missingCandidateCount,
    required this.completionPercentage,
  });

  factory CriterionScoreMonitoringModel.fromJson(Map<String, dynamic> json) {
    return CriterionScoreMonitoringModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      code: json['code']?.toString() ?? '-',
      name: json['name']?.toString() ?? '-',
      type: json['type']?.toString() ?? '-',
      weight: double.tryParse(json['weight'].toString()) ?? 0,
      scoredCandidateCount:
      int.tryParse(json['scored_candidate_count'].toString()) ?? 0,
      candidateCount: int.tryParse(json['candidate_count'].toString()) ?? 0,
      missingCandidateCount:
      int.tryParse(json['missing_candidate_count'].toString()) ?? 0,
      completionPercentage: double.tryParse(
        json['completion_percentage'].toString(),
      ) ??
          0,
    );
  }
}

class JuryScoreMonitoringModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final int assignedCriteriaCount;
  final int scoreCount;

  const JuryScoreMonitoringModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.assignedCriteriaCount,
    required this.scoreCount,
  });

  factory JuryScoreMonitoringModel.fromJson(Map<String, dynamic> json) {
    return JuryScoreMonitoringModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      phone: json['phone']?.toString(),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString() == '1',
      assignedCriteriaCount:
      int.tryParse(json['assigned_criteria_count'].toString()) ?? 0,
      scoreCount: int.tryParse(json['score_count'].toString()) ?? 0,
    );
  }
}

class ScoreMonitoringModel {
  final int periodId;
  final ScoreMonitoringSummaryModel summary;
  final List<CandidateScoreMonitoringModel> candidates;
  final List<CriterionScoreMonitoringModel> criteria;
  final List<JuryScoreMonitoringModel> juries;

  const ScoreMonitoringModel({
    required this.periodId,
    required this.summary,
    required this.candidates,
    required this.criteria,
    required this.juries,
  });

  factory ScoreMonitoringModel.fromJson(Map<String, dynamic> json) {
    final rawSummary = json['summary'];
    final rawCandidates = json['candidates'];
    final rawCriteria = json['criteria'];
    final rawJuries = json['juries'];

    return ScoreMonitoringModel(
      periodId: int.tryParse(json['period_id'].toString()) ?? 0,
      summary: rawSummary is Map
          ? ScoreMonitoringSummaryModel.fromJson(
        Map<String, dynamic>.from(rawSummary),
      )
          : const ScoreMonitoringSummaryModel(
        totalCandidates: 0,
        completeCandidates: 0,
        incompleteCandidates: 0,
        criteriaCount: 0,
        juriesCount: 0,
        scoreRecordsCount: 0,
        completionPercentage: 0,
      ),
      candidates: rawCandidates is List
          ? rawCandidates
          .whereType<Map>()
          .map(
            (item) => CandidateScoreMonitoringModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <CandidateScoreMonitoringModel>[],
      criteria: rawCriteria is List
          ? rawCriteria
          .whereType<Map>()
          .map(
            (item) => CriterionScoreMonitoringModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <CriterionScoreMonitoringModel>[],
      juries: rawJuries is List
          ? rawJuries
          .whereType<Map>()
          .map(
            (item) => JuryScoreMonitoringModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <JuryScoreMonitoringModel>[],
    );
  }
}