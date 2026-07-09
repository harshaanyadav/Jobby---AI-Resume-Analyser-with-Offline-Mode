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

/// Facade over the two ResumeAnalysisEngine implementations
/// (KeywordAnalysisEngine / GeminiAnalysisEngine). This is the ONLY
/// class the UI talks to — it never knows which engine actually ran.
///
/// For Premium users, it tries Gemini first. If Gemini throws (network
/// failure, rate limit, missing API key, bad JSON, etc.) it transparently
/// falls back to the free keyword engine AND sets [premiumFellBack] = true
/// so the UI can show an honest "AI temporarily unavailable" banner
/// instead of silently pretending the free-tier result is a Premium one.
class ResumeAnalysisService {
  ResumeAnalysisService._();
  static final ResumeAnalysisService instance = ResumeAnalysisService._();

  final ResumeAnalysisEngine _keywordEngine = KeywordAnalysisEngine();
  final ResumeAnalysisEngine _geminiEngine = GeminiAnalysisEngine();

  /// Set by the most recent Premium-tier call. True only when that call
  /// attempted Gemini and had to fall back — NOT true for Free-tier users,
  /// since for them there was nothing to "fall back" from.
  bool premiumFellBack = false;

  Future<ResumeAnalysis> parseResume(
    Uint8List resumeBytes, {
    required bool isPremium,
  }) async {
    if (!isPremium) {
      premiumFellBack = false;
      return _keywordEngine.parseResume(resumeBytes);
    }
    try {
      final result = await _geminiEngine.parseResume(resumeBytes);
      premiumFellBack = false;
      return result;
    } catch (_) {
      premiumFellBack = true;
      return _keywordEngine.parseResume(resumeBytes);
    }
  }

  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (!isPremium) {
      premiumFellBack = false;
      return _keywordEngine.matchResume(resume, jobDescription);
    }
    try {
      final result = await _geminiEngine.matchResume(resume, jobDescription);
      premiumFellBack = false;
      return result;
    } catch (_) {
      premiumFellBack = true;
      return _keywordEngine.matchResume(resume, jobDescription);
    }
  }

  Future<ResumeReview> reviewResume(
    ResumeAnalysis resume, {
    required bool isPremium,
  }) async {
    if (!isPremium) {
      premiumFellBack = false;
      return AnalysisService.buildHeuristicReview(resume);
    }
    try {
      final result = await _geminiEngine.reviewResume(resume);
      premiumFellBack = false;
      return result;
    } catch (_) {
      premiumFellBack = true;
      return AnalysisService.buildHeuristicReview(resume, premiumFailed: true);
    }
  }

  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription, {
    required bool isPremium,
  }) async {
    if (!isPremium) {
      premiumFellBack = false;
      return _keywordEngine.rankCandidates(candidates, jobDescription);
    }
    try {
      final result =
          await _geminiEngine.rankCandidates(candidates, jobDescription);
      premiumFellBack = false;
      return result;
    } catch (_) {
      premiumFellBack = true;
      return _keywordEngine.rankCandidates(candidates, jobDescription);
    }
  }
}
