import 'dart:typed_data';
import '../models/resume_analysis.dart';
import '../models/resume_match.dart';
import '../models/resume_review.dart';
import '../models/candidate_ranking.dart';
import '../models/job_description.dart';
import 'resume_analysis_engine.dart';
import 'resume_parser.dart';
import 'analysis_service.dart';

/// Free-tier engine. Fully offline, no network calls, wraps the
/// project's original keyword matching logic and exposes it through
/// the same ResumeAnalysisEngine contract the AI engine uses.
class KeywordAnalysisEngine implements ResumeAnalysisEngine {
  final ResumeParser _parser = ResumeParser();

  @override
  String get engineName => 'keyword';

  @override
  Future<ResumeAnalysis> parseResume(Uint8List resumeBytes) async {
    final data = await _parser.parse(resumeBytes);
    return ResumeAnalysis(
      email: data.email,
      phone: data.mobileNumber,
      linkedin: data.linkedIn ?? '',
      degree: data.degree,
      experienceSummary: data.experience,
      certifications:
          data.certifications == 'No certifications found'
              ? const []
              : [data.certifications],
      technicalSkills: data.skills,
      summary: '',
    );
  }

  @override
  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription,
  ) async {
    final pct = AnalysisService.calculateMatch(
      resume.allSkills,
      jobDescription.requiredSkills,
    );
    final missing = jobDescription.requiredSkills
        .where((s) => !resume.allSkills
            .map((e) => e.toLowerCase())
            .contains(s.toLowerCase()))
        .toList();

    return ResumeMatch(
      matchPercentage: pct,
      missingSkills: missing,
      strengths: resume.allSkills,
      summary:
          'Matched using keyword intersection against ${jobDescription.title}.',
    );
  }

  @override
  Future<ResumeReview> reviewResume(ResumeAnalysis resume) async {
    return AnalysisService.buildHeuristicReview(resume);
  }

  @override
  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription,
  ) async {
    final scored = <CandidateRanking>[];
    for (final c in candidates) {
      final pct = AnalysisService.calculateMatch(
        c.allSkills,
        jobDescription.requiredSkills,
      );
      scored.add(CandidateRanking(
        name: c.name.isNotEmpty ? c.name : 'Candidate',
        score: pct,
        reason: 'Skill overlap with ${jobDescription.title} requirements.',
      ));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}
