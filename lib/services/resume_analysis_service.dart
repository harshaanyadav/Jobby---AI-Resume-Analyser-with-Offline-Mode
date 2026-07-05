import 'dart:typed_data';
import '../models/resume_analysis.dart';
import '../models/resume_match.dart';
import '../models/resume_review.dart';
import '../models/candidate_ranking.dart';
import '../models/job_description.dart';
import 'resume_analysis_engine.dart';
import 'keyword_analysis_engine.dart';
import 'gemini_analysis_engine.dart';

/// The ONLY class the UI is allowed to talk to for resume intelligence.
/// Premium now runs on GeminiAnalysisEngine (free tier). If you ever
/// want to switch to OpenRouter again, just swap this one line — the
/// UI and every screen stay untouched either way.
class ResumeAnalysisService {
  ResumeAnalysisService._();
  static final ResumeAnalysisService instance = ResumeAnalysisService._();

  final ResumeAnalysisEngine _freeEngine = KeywordAnalysisEngine();
  final ResumeAnalysisEngine _premiumEngine = GeminiAnalysisEngine();

  Future<ResumeAnalysis> parseResume(
    Uint8List resumeBytes, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        return await _premiumEngine.parseResume(resumeBytes);
      } catch (e) {
        print('GEMINI REVIEW FAILED: $e'); // TEMP DEBUG LINsE
        return await _freeEngine.parseResume(resumeBytes);
      }
    }
    return await _freeEngine.parseResume(resumeBytes);
  }

  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        return await _premiumEngine.matchResume(resume, jobDescription);
      } catch (_) {
        return await _freeEngine.matchResume(resume, jobDescription);
      }
    }
    return await _freeEngine.matchResume(resume, jobDescription);
  }

  Future<ResumeReview> reviewResume(
    ResumeAnalysis resume, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        return await _premiumEngine.reviewResume(resume);
      } catch (_) {
        return await _freeEngine.reviewResume(resume);
      }
    }
    return await _freeEngine.reviewResume(resume);
  }

  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        return await _premiumEngine.rankCandidates(candidates, jobDescription);
      } catch (_) {
        return await _freeEngine.rankCandidates(candidates, jobDescription);
      }
    }
    return await _freeEngine.rankCandidates(candidates, jobDescription);
  }
}
