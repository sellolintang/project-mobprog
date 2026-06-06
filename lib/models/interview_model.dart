class InterviewModel {
  final int id;
  final int periodId;
  final int candidateId;
  final String scheduledAt;
  final String? location;
  final String status;
  final String? registrationNumber;
  final String? candidateName;
  final String? studentNumber;
  final String? email;
  final String? phone;
  final String? faculty;
  final String? studyProgram;
  final int? semester;
  final String? candidateStatus;
  final int? electionYear;
  final String? createdByName;

  InterviewModel({
    required this.id,
    required this.periodId,
    required this.candidateId,
    required this.scheduledAt,
    this.location,
    required this.status,
    this.registrationNumber,
    this.candidateName,
    this.studentNumber,
    this.email,
    this.phone,
    this.faculty,
    this.studyProgram,
    this.semester,
    this.candidateStatus,
    this.electionYear,
    this.createdByName,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id'] ?? 0,
      periodId: json['period_id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      scheduledAt: json['scheduled_at'] ?? '',
      location: json['location'],
      status: json['status'] ?? 'scheduled',
      registrationNumber: json['registration_number'],
      candidateName: json['full_name'] ?? json['candidate_name'],
      studentNumber: json['student_number'],
      email: json['email'],
      phone: json['phone'],
      faculty: json['faculty'],
      studyProgram: json['study_program'],
      semester: json['semester'] == null
          ? null
          : int.tryParse(json['semester'].toString()),
      candidateStatus: json['candidate_status'],
      electionYear: json['election_year'] == null
          ? null
          : int.tryParse(json['election_year'].toString()),
      createdByName: json['created_by_name'],
    );
  }
}