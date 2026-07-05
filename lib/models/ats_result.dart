class ATSResult {
  final double atsScore;
  final String resumeQuality;
  final List<String> formattingIssues;
  final List<String> keywordSuggestions;

  const ATSResult({
    this.atsScore = 0,
    this.resumeQuality = '',
    this.formattingIssues = const [],
    this.keywordSuggestions = const [],
  });

  factory ATSResult.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const [];
    double _num(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return ATSResult(
      atsScore: _num(json['ats_score']),
      resumeQuality: json['resume_quality']?.toString() ?? '',
      formattingIssues: _list(json['formatting_issues']),
      keywordSuggestions: _list(json['keyword_suggestions']),
    );
  }
}
