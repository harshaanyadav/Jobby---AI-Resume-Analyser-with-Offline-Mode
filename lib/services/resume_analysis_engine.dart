import 'dart:typed_data';
import '../models/resume_analysis.dart';
import '../models/resume_match.dart';
import '../models/resume_review.dart';
import '../models/candidate_ranking.dart';
import '../models/job_description.dart';

/// Strategy interface. The UI and ResumeAnalysisService never depend on
/// a concrete engine — only on this contract. Adding a new provider
/// (OpenAI, Gemini, Claude, Azure OpenAI, DeepSeek, Mistral...) later
/// means writing one new class that implements this interface.
abstract class ResumeAnalysisEngine {
  String get engineName;

  Future<ResumeAnalysis> parseResume(Uint8List resumeBytes);

  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription,
  );

  Future<ResumeReview> reviewResume(ResumeAnalysis resume);

  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription,
  );
}
