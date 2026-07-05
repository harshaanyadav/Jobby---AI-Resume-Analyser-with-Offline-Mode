import '../models/job_roles.dart';
import '../models/resume_analysis.dart';
import '../models/resume_review.dart';
import '../models/ats_result.dart';

/// Existing keyword-matching logic. Unchanged behavior for free tier.
/// Added two small heuristic builders (buildHeuristicReview /
/// buildResumeAnalysisFromResumeData) so KeywordAnalysisEngine can return
/// the same unified models the AI engine returns, without touching any
/// of the original matching math.
class AnalysisService {
  static double calculateMatch(
      List<String> candidateSkills, List<String> requiredSkills) {
    if (requiredSkills.isEmpty) return 0;
    final matched = candidateSkills
        .map((s) => s.toLowerCase())
        .toSet()
        .intersection(requiredSkills.map((s) => s.toLowerCase()).toSet());
    return (matched.length / requiredSkills.length) * 100;
  }

  static double calculateReadiness(
      String experience, String certifications, List<String> skills) {
    double score = 0;
    if (experience != 'No experience details found') score += 25;
    if (certifications != 'No certifications found') score += 20;
    score += (skills.length * 5).clamp(0, 50).toDouble();
    const softSkills = [
      "communication",
      "leadership",
      "teamwork",
      "problem solving",
      "critical thinking"
    ];
    for (final skill in skills) {
      if (softSkills.contains(skill.toLowerCase())) {
        score += 5;
        break;
      }
    }
    return score.clamp(0, 100);
  }

  static Map<String, double> getAllRoleMatches(List<String> skills) {
    return {
      for (final entry in JobRoles.roles.entries)
        entry.key: calculateMatch(skills, entry.value)
    };
  }

  static List<String> getMissingSkills(
      List<String> candidateSkills, String jobRole) {
    final required = JobRoles.roles[jobRole] ?? [];
    final candidate = candidateSkills.map((s) => s.toLowerCase()).toSet();
    return required.where((s) => !candidate.contains(s.toLowerCase())).toList();
  }

  static String getBenchmarkText(List<String> skills, String jobRole) {
    final missing = getMissingSkills(skills, jobRole);
    if (missing.isEmpty) {
      return 'Your skills meet or exceed industry benchmarks for $jobRole.';
    }
    return 'For $jobRole, consider gaining: ${missing.take(5).join(', ')}${missing.length > 5 ? '...' : ''}';
  }

  static String getSoftSkillsEvaluation(String resumeText) {
    const keywords = [
      "communication",
      "teamwork",
      "problem-solving",
      "adaptability",
      "leadership",
      "creativity"
    ];
    final lower = resumeText.toLowerCase();
    final matched = keywords.where((k) => lower.contains(k)).toList();
    if (matched.isEmpty) {
      return 'Soft skills could not be evaluated from resume text.';
    }
    return 'Shows strong skills in ${matched.join(', ')}.';
  }

  /// Builds a lightweight, deterministic "review" for free-tier users so
  /// the results screen can show the same sections both tiers, without
  /// ever calling the network.
  static ResumeReview buildHeuristicReview(ResumeAnalysis analysis) {
    final readiness = calculateReadiness(
      analysis.experienceSummary.isEmpty
          ? 'No experience details found'
          : analysis.experienceSummary,
      analysis.certifications.isEmpty ? 'No certifications found' : 'has',
      analysis.allSkills,
    );

    return ResumeReview(
      ats: ATSResult(
        atsScore: readiness,
        resumeQuality: readiness >= 70
            ? 'Good'
            : readiness >= 40
                ? 'Average'
                : 'Needs Improvement',
        formattingIssues: const [],
        keywordSuggestions: const [],
      ),
      resumeSummary: analysis.summary.isNotEmpty
          ? analysis.summary
          : 'Resume summary unavailable in free tier. Upgrade to Premium for an AI-written summary.',
      grammarReview:
          'Grammar review is a Premium feature. Upgrade to unlock AI-powered writing feedback.',
      careerAdvice:
          'Personalized career advice is a Premium feature. Upgrade to unlock AI-powered guidance.',
      interviewReadiness: '${readiness.toStringAsFixed(0)}%',
      projectEvaluation: 'Detailed project evaluation is a Premium feature.',
      strengths: analysis.strengths,
      weaknesses: analysis.weaknesses,
      improvementSuggestions: const [],
      learningRoadmap: const [],
      hiringRecommendation: '',
    );
  }
}
