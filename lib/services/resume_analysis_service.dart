import 'dart:typed_data';
import '../models/resume_analysis.dart';
import '../models/resume_match.dart';
import '../models/resume_review.dart';
import '../models/candidate_ranking.dart';
import '../models/job_description.dart';
import 'resume_analysis_engine.dart';
import 'keyword_analysis_engine.dart';
import 'gemini_analysis_engine.dart';
import 'analysis_service.dart';

/// The ONLY class the UI is allowed to talk to for resume intelligence.
/// Premium now runs on GeminiAnalysisEngine (free tier). If you ever
/// want to switch to OpenRouter again, just swap this one line — the
/// UI and every screen stay untouched either way.
class ResumeAnalysisService {
  ResumeAnalysisService._();
  static final ResumeAnalysisService instance = ResumeAnalysisService._();

  final ResumeAnalysisEngine _freeEngine = KeywordAnalysisEngine();
  final ResumeAnalysisEngine _premiumEngine = GeminiAnalysisEngine();

  /// True whenever the LAST premium call attempted (parse/match/review/rank)
  /// failed and silently fell back to the free engine. UI screens should
  /// read this right after their sequence of calls finishes, and show an
  /// "AI temporarily unavailable" notice instead of an "upgrade" notice
  /// when this is true for a Premium user.
  bool premiumFellBack = false;

  Future<ResumeAnalysis> parseResume(
    Uint8List resumeBytes, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        final result = await _premiumEngine.parseResume(resumeBytes);
        premiumFellBack = false;
        return result;
      } catch (e) {
        print('GEMINI PARSE FAILED: $e'); // TEMP DEBUG LINE
        premiumFellBack = true;
        return await _freeEngine.parseResume(resumeBytes);
      }
    }
    premiumFellBack = false;
    return await _freeEngine.parseResume(resumeBytes);
  }

  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        final result = await _premiumEngine.matchResume(resume, jobDescription);
        premiumFellBack = false;
        return result;
      } catch (e) {
        print('GEMINI MATCH FAILED: $e'); // TEMP DEBUG LINE
        premiumFellBack = true;
        return await _freeEngine.matchResume(resume, jobDescription);
      }
    }
    premiumFellBack = false;
    return await _freeEngine.matchResume(resume, jobDescription);
  }

  Future<ResumeReview> reviewResume(
    ResumeAnalysis resume, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        final result = await _premiumEngine.reviewResume(resume);
        premiumFellBack = false;
        return result;
      } catch (e) {
        print('GEMINI REVIEW FAILED: $e'); // TEMP DEBUG LINE
        premiumFellBack = true;
        return AnalysisService.buildHeuristicReview(resume,
            premiumFailed: true);
      }
    }
    premiumFellBack = false;
    return AnalysisService.buildHeuristicReview(resume, premiumFailed: false);
  }

  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      try {
        final result =
            await _premiumEngine.rankCandidates(candidates, jobDescription);
        premiumFellBack = false;
        return result;
      } catch (e) {
        print('GEMINI RANKING FAILED: $e'); // TEMP DEBUG LINE
        premiumFellBack = true;
        return await _freeEngine.rankCandidates(candidates, jobDescription);
      }
    }
    premiumFellBack = false;
    return await _freeEngine.rankCandidates(candidates, jobDescription);
  }
}
