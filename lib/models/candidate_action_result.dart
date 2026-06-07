import 'candidate_model.dart';

class CandidateActionResult {
  final bool success;
  final bool emailSent;
  final String message;
  final CandidateModel? candidate;

  const CandidateActionResult({
    required this.success,
    required this.emailSent,
    required this.message,
    this.candidate,
  });

  factory CandidateActionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    CandidateModel? candidate;
    bool emailSent = false;

    if (data is Map) {
      emailSent = data['email_sent'] == true;

      final candidateData = data['candidate'];
      if (candidateData is Map) {
        candidate = CandidateModel.fromJson(
          Map<String, dynamic>.from(candidateData),
        );
      }
    }

    return CandidateActionResult(
      success: true,
      emailSent: emailSent,
      message: json['message']?.toString() ?? 'Aksi berhasil diproses.',
      candidate: candidate,
    );
  }

  factory CandidateActionResult.failed(String message) {
    return CandidateActionResult(
      success: false,
      emailSent: false,
      message: message,
    );
  }
}