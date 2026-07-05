/// Result of comparing a resume against a job description / job role,
/// regardless of whether it came from keyword intersection or AI.
class ResumeMatch {
  final double matchPercentage;
  final List<String> strengths;
  final List<String> missingSkills;
  final List<String> recommendations;
  final String summary;

  const ResumeMatch({
    required this.matchPercentage,
    this.strengths = const [],
    this.missingSkills = const [],
    this.recommendations = const [],
    this.summary = '',
  });

  factory ResumeMatch.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic v) {
      if (v == null) return const [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    double _pct(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return ResumeMatch(
      matchPercentage: _pct(json['match_percentage']),
      strengths: _list(json['strengths']),
      missingSkills: _list(json['missing_skills']),
      recommendations: _list(json['recommendations']),
      summary: json['summary']?.toString() ?? '',
    );
  }
}
