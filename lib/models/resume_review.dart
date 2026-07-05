import 'ats_result.dart';

/// Full premium "Resume Review" result used by AI-powered analysis.
/// Free tier populates this with lightweight heuristic values so the UI
/// can display the same sections without special-casing.
class ResumeReview {
  final ATSResult ats;
  final String resumeSummary;
  final String grammarReview;
  final String careerAdvice;
  final String interviewReadiness;
  final String projectEvaluation;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvementSuggestions;
  final List<String> learningRoadmap;
  final String hiringRecommendation;

  const ResumeReview({
    this.ats = const ATSResult(),
    this.resumeSummary = '',
    this.grammarReview = '',
    this.careerAdvice = '',
    this.interviewReadiness = '',
    this.projectEvaluation = '',
    this.strengths = const [],
    this.weaknesses = const [],
    this.improvementSuggestions = const [],
    this.learningRoadmap = const [],
    this.hiringRecommendation = '',
  });

  factory ResumeReview.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const [];

    return ResumeReview(
      ats: json['ats'] is Map<String, dynamic>
          ? ATSResult.fromJson(json['ats'])
          : const ATSResult(),
      resumeSummary: json['resume_summary']?.toString() ?? '',
      grammarReview: json['grammar_review']?.toString() ?? '',
      careerAdvice: json['career_advice']?.toString() ?? '',
      interviewReadiness: json['interview_readiness']?.toString() ?? '',
      projectEvaluation: json['project_evaluation']?.toString() ?? '',
      strengths: _list(json['strengths']),
      weaknesses: _list(json['weaknesses']),
      improvementSuggestions: _list(json['improvement_suggestions']),
      learningRoadmap: _list(json['learning_roadmap']),
      hiringRecommendation: json['hiring_recommendation']?.toString() ?? '',
    );
  }
}
