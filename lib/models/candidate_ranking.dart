class CandidateRanking {
  final String name;
  final double score;
  final String reason;

  const CandidateRanking({
    required this.name,
    required this.score,
    this.reason = '',
  });

  factory CandidateRanking.fromJson(Map<String, dynamic> json) {
    double _num(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return CandidateRanking(
      name: json['name']?.toString() ?? '',
      score: _num(json['score']),
      reason: json['reason']?.toString() ?? '',
    );
  }
}
