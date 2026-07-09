import '../models/resume_analysis.dart';
import '../models/resume_review.dart';
import '../models/ats_result.dart';
import 'job_role_service.dart';

/// Static keyword-matching + scoring helpers, used by both engines and
/// by the results screens. Role data comes ONLY from JobRoleService,
/// which loads assets/job_roles.json — single source of truth.
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
      for (final entry in JobRoleService.instance.roleSkillMap.entries)
        entry.key: calculateMatch(skills, entry.value)
    };
  }

  static List<String> getMissingSkills(
      List<String> candidateSkills, String jobRole) {
    final required = JobRoleService.instance.skillsFor(jobRole);
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

  /// Builds a lightweight, deterministic "review" so the results screen
  /// can show the same sections regardless of tier/outcome, without
  /// calling the network. `premiumFailed` lets the UI distinguish
  /// "you're on Free tier" from "Premium AI call failed, here's a
  /// fallback" without adding a second model class.
  static ResumeReview buildHeuristicReview(
    ResumeAnalysis analysis, {
    bool premiumFailed = false,
  }) {
    final readiness = calculateReadiness(
      analysis.experienceSummary.isEmpty
          ? 'No experience details found'
          : analysis.experienceSummary,
      analysis.certifications.isEmpty ? 'No certifications found' : 'has',
      analysis.allSkills,
    );

    final summaryNote = premiumFailed
        ? 'AI is temporarily unavailable — showing a fallback summary.'
        : 'Resume summary unavailable in free tier. Upgrade to Premium for an AI-written summary.';
    final grammarNote = premiumFailed
        ? 'AI is temporarily unavailable — grammar review could not be generated.'
        : 'Grammar review is a Premium feature. Upgrade to unlock AI-powered writing feedback.';
    final careerNote = premiumFailed
        ? 'AI is temporarily unavailable — career advice could not be generated.'
        : 'Personalized career advice is a Premium feature. Upgrade to unlock AI-powered guidance.';
    final projectNote = premiumFailed
        ? 'AI is temporarily unavailable — project evaluation could not be generated.'
        : 'Detailed project evaluation is a Premium feature.';

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
      resumeSummary:
          analysis.summary.isNotEmpty ? analysis.summary : summaryNote,
      grammarReview: grammarNote,
      careerAdvice: careerNote,
      interviewReadiness: '${readiness.toStringAsFixed(0)}%',
      projectEvaluation: projectNote,
      strengths: analysis.strengths,
      weaknesses: analysis.weaknesses,
      improvementSuggestions: const [],
      learningRoadmap: const [],
      hiringRecommendation: '',
    );
  }
}
