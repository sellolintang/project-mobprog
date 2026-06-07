class PeriodModel {
  final int id;
  final int electionYear;
  final String status;
  final String? registrationStart;
  final String? registrationEnd;
  final String? interviewStart;
  final String? interviewEnd;

  final bool isResultPublished;
  final String? resultPublishedAt;
  final int? resultPublishedBy;
  final String? announcementNote;

  PeriodModel({
    required this.id,
    required this.electionYear,
    required this.status,
    this.registrationStart,
    this.registrationEnd,
    this.interviewStart,
    this.interviewEnd,
    this.isResultPublished = false,
    this.resultPublishedAt,
    this.resultPublishedBy,
    this.announcementNote,
  });

  static bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;
    if (value == 1) return true;
    if (value == 0) return false;

    final text = value?.toString().toLowerCase();

    return text == '1' || text == 'true' || text == 'yes';
  }

  factory PeriodModel.fromJson(Map json) {
    return PeriodModel(
      id: json['id'] ?? 0,
      electionYear: int.tryParse(json['election_year'].toString()) ?? 0,
      status: json['status'] ?? 'draft',
      registrationStart: json['registration_start'],
      registrationEnd: json['registration_end'],
      interviewStart: json['interview_start'],
      interviewEnd: json['interview_end'],
      isResultPublished: _parseBool(json['is_result_published']),
      resultPublishedAt: json['result_published_at'],
      resultPublishedBy: int.tryParse(
        json['result_published_by']?.toString() ?? '',
      ),
      announcementNote: json['announcement_note'],
    );
  }
}