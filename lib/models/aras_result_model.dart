class ArasResultModel {
  final int id;
  final int periodId;
  final int candidateId;
  final double totalScore;
  final double utilityScore;
  final int finalRank;
  final String? calculatedAt;

  final String? candidateName;
  final String? registrationNumber;
  final String? studentNumber;
  final String? faculty;
  final String? studyProgram;
  final int? electionYear;
  final String? calculatorName;

  ArasResultModel({
    required this.id,
    required this.periodId,
    required this.candidateId,
    required this.totalScore,
    required this.utilityScore,
    required this.finalRank,
    this.calculatedAt,
    this.candidateName,
    this.registrationNumber,
    this.studentNumber,
    this.faculty,
    this.studyProgram,
    this.electionYear,
    this.calculatorName,
  });

  factory ArasResultModel.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'];
    final period = json['period'];
    final calculator = json['calculator'];

    return ArasResultModel(
      id: json['id'] ?? 0,
      periodId: json['period_id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      totalScore: double.tryParse(json['total_score'].toString()) ?? 0.0,
      utilityScore: double.tryParse(json['utility_score'].toString()) ?? 0.0,
      finalRank: int.tryParse(json['final_rank'].toString()) ?? 0,
      calculatedAt: json['calculated_at'],

      candidateName: candidate is Map
          ? candidate['full_name']
          : json['candidate_name'],
      registrationNumber: candidate is Map
          ? candidate['registration_number']
          : json['registration_number'],
      studentNumber: candidate is Map
          ? candidate['student_number']
          : json['student_number'],
      faculty: candidate is Map ? candidate['faculty'] : json['faculty'],
      studyProgram: candidate is Map
          ? candidate['study_program']
          : json['study_program'],

      electionYear: period is Map
          ? int.tryParse(period['election_year'].toString())
          : int.tryParse(json['election_year'].toString()),

      calculatorName: calculator is Map
          ? calculator['name']
          : json['calculator_name'],
    );
  }
}