class ApiConstants {
  // Untuk Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Untuk browser/Windows desktop Flutter:
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Untuk HP fisik, gunakan IP laptop:
  // static const String baseUrl = 'http://192.168.1.10:8000/api';

  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';

  static const String periods = '/periods';
  static const String candidates = '/candidates';
  static const String candidateRegister = '/candidates/register';
  static const String criteria = '/criteria';
  static const String juryCriteria = '/jury-criteria';
  static const String interviews = '/interviews';
  static const String generateInterviews = '/interviews/generate';
  static const String resetInterviews = '/interviews/reset';
  static const String scores = '/scores';
  static const String myScores = '/my-scores';
  static const String arasResults = '/aras-results';
  static const String calculateAras = '/aras-results/calculate';
  static const String juries = '/juries';
  static const String juriesOptions = '/juries/options';
  static const String juryDashboardSummary = '/jury/dashboard-summary';
  static const String juryScoringCandidates = '/jury/scoring-candidates';
  static const String juryScoringHistory = '/jury/scoring-history';
  static const String publicResults = '/public/results';
  static const String announcementCheckReadiness = '/announcements/check-readiness';
  static const String announcementPublish = '/announcements/publish';
  static const String announcementUnpublish = '/announcements/unpublish';
  static const String monitoringScores = '/monitoring/scores';
}