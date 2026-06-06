class PeriodModel {
  final int id;
  final int electionYear;
  final String status;
  final String? registrationStart;
  final String? registrationEnd;
  final String? interviewStart;
  final String? interviewEnd;

  PeriodModel({
    required this.id,
    required this.electionYear,
    required this.status,
    this.registrationStart,
    this.registrationEnd,
    this.interviewStart,
    this.interviewEnd,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      id: json['id'] ?? 0,
      electionYear: int.tryParse(json['election_year'].toString()) ?? 0,
      status: json['status'] ?? 'draft',
      registrationStart: json['registration_start'],
      registrationEnd: json['registration_end'],
      interviewStart: json['interview_start'],
      interviewEnd: json['interview_end'],
    );
  }
}