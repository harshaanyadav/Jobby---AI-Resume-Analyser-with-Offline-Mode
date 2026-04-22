import '../models/job_roles.dart';

class AnalysisService {
  static double calculateMatch(
    List<String> candidateSkills,
    List<String> requiredSkills,
  ) {
    if (requiredSkills.isEmpty) return 0;
    final matched = candidateSkills
        .map((s) => s.toLowerCase())
        .toSet()
        .intersection(requiredSkills.map((s) => s.toLowerCase()).toSet());
    return (matched.length / requiredSkills.length) * 100;
  }

  static double calculateReadiness(
    String experience,
    String certifications,
    List<String> skills,
  ) {
    double score = 0;
    if (experience != 'No experience details found') score += 25;
    if (certifications != 'No certifications found') score += 20;
    score += (skills.length * 5).clamp(0, 50).toDouble();
    const softSkills = [
      "communication",
      "leadership",
      "teamwork",
      "problem solving",
      "critical thinking",
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
        entry.key: calculateMatch(skills, entry.value),
    };
  }

  static List<String> getMissingSkills(
    List<String> candidateSkills,
    String jobRole,
  ) {
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
      "creativity",
    ];
    final lower = resumeText.toLowerCase();
    final matched = keywords.where((k) => lower.contains(k)).toList();
    if (matched.isEmpty) {
      return 'Soft skills could not be evaluated from resume text.';
    }
    return 'Shows strong skills in ${matched.join(', ')}.';
  }
}
