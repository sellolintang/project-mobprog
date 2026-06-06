class CandidateModel {
  final int id;
  final int periodId;
  final String registrationNumber;
  final String fullName;
  final String studentNumber;
  final String email;
  final String? phone;
  final String? faculty;
  final String? studyProgram;
  final int? semester;
  final String? vision;
  final String? mission;
  final String? photoFile;
  final String? cvFile;
  final String status;
  final String? rejectionReason;

  CandidateModel({
    required this.id,
    required this.periodId,
    required this.registrationNumber,
    required this.fullName,
    required this.studentNumber,
    required this.email,
    this.phone,
    this.faculty,
    this.studyProgram,
    this.semester,
    this.vision,
    this.mission,
    this.photoFile,
    this.cvFile,
    required this.status,
    this.rejectionReason,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] ?? 0,
      periodId: json['period_id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '-',
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      faculty: json['faculty'],
      studyProgram: json['study_program'],
      semester: json['semester'] == null
          ? null
          : int.tryParse(json['semester'].toString()),
      vision: json['vision'],
      mission: json['mission'],
      photoFile: json['photo_file'],
      cvFile: json['cv_file'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
    );
  }
}