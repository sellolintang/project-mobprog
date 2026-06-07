class MissingScoreSampleModel {
  final int candidateId;
  final String candidateName;
  final int criterionId;
  final String criterionCode;
  final String criterionName;

  const MissingScoreSampleModel({
    required this.candidateId,
    required this.candidateName,
    required this.criterionId,
    required this.criterionCode,
    required this.criterionName,
  });

  factory MissingScoreSampleModel.fromJson(Map<String, dynamic> json) {
    return MissingScoreSampleModel(
      candidateId: int.tryParse(json['candidate_id'].toString()) ?? 0,
      candidateName: json['candidate_name']?.toString() ?? '-',
      criterionId: int.tryParse(json['criterion_id'].toString()) ?? 0,
      criterionCode: json['criterion_code']?.toString() ?? '-',
      criterionName: json['criterion_name']?.toString() ?? '-',
    );
  }
}

class AnnouncementReadinessModel {
  final bool ready;
  final int? periodId;
  final int? electionYear;
  final int criteriaCount;
  final int eligibleCandidateCount;
  final int arasResultCount;
  final int missingScoreCount;
  final List<MissingScoreSampleModel> missingScoreSamples;
  final List<String> warnings;

  const AnnouncementReadinessModel({
    required this.ready,
    required this.periodId,
    required this.electionYear,
    required this.criteriaCount,
    required this.eligibleCandidateCount,
    required this.arasResultCount,
    required this.missingScoreCount,
    required this.missingScoreSamples,
    required this.warnings,
  });

  factory AnnouncementReadinessModel.fromJson(Map<String, dynamic> json) {
    final rawSamples = json['missing_score_samples'];
    final rawWarnings = json['warnings'];

    return AnnouncementReadinessModel(
      ready: json['ready'] == true,
      periodId: int.tryParse(json['period_id']?.toString() ?? ''),
      electionYear: int.tryParse(json['election_year']?.toString() ?? ''),
      criteriaCount: int.tryParse(json['criteria_count'].toString()) ?? 0,
      eligibleCandidateCount:
      int.tryParse(json['eligible_candidate_count'].toString()) ?? 0,
      arasResultCount: int.tryParse(json['aras_result_count'].toString()) ?? 0,
      missingScoreCount:
      int.tryParse(json['missing_score_count'].toString()) ?? 0,
      missingScoreSamples: rawSamples is List
          ? rawSamples
          .whereType<Map>()
          .map(
            (item) => MissingScoreSampleModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <MissingScoreSampleModel>[],
      warnings: rawWarnings is List
          ? rawWarnings.map((item) => item.toString()).toList()
          : <String>[],
    );
  }
}