class ResumeData {
  final String mobileNumber;
  final String email;
  final List<String> skills;
  final String certifications;
  final String degree;
  final String experience;
  final String? linkedIn;

  ResumeData({
    this.mobileNumber = 'Not found',
    this.email = 'Not found',
    this.skills = const [],
    this.certifications = 'No certifications found',
    this.degree = 'Not found',
    this.experience = 'No experience details found',
    this.linkedIn,
  });
}

class CandidateResult {
  final String name;
  final String filePath;
  final double matchPercentage;
  final List<String> skills;
  final double readinessScore;

  CandidateResult({
    required this.name,
    required this.filePath,
    required this.matchPercentage,
    required this.skills,
    required this.readinessScore,
  });
}
