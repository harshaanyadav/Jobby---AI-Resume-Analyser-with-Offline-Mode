import 'dart:convert';
import 'dart:typed_data';
import '../models/resume_analysis.dart';
import '../models/resume_match.dart';
import '../models/resume_review.dart';
import '../models/candidate_ranking.dart';
import '../models/job_description.dart';
import '../prompts/resume_parser_prompt.dart';
import '../prompts/resume_matching_prompt.dart';
import '../prompts/candidate_ranking_prompt.dart';
import '../prompts/ats_prompt.dart';
import 'resume_analysis_engine.dart';
import 'gemini_service.dart';
import 'pdf_service.dart';

/// Premium engine backed by Google's free-tier Gemini API instead of
/// OpenRouter. Implements the same ResumeAnalysisEngine contract, so it
/// is a drop-in alternative — ResumeAnalysisService decides which one
/// to use, and the UI never knows the difference.
class GeminiAnalysisEngine implements ResumeAnalysisEngine {
  final GeminiService _client = GeminiService();

  @override
  String get engineName => 'gemini';

  @override
  Future<ResumeAnalysis> parseResume(Uint8List resumeBytes) async {
    final text = await PdfService.extractText(resumeBytes);
    final prompt = ResumeParserPrompt.build(text);
    final response = await _client.complete(prompt);

    if (!response.success) {
      throw Exception(response.errorMessage ?? 'Gemini resume parsing failed.');
    }

    final json = GeminiService.parseJson(response.rawContent);
    return ResumeAnalysis.fromJson(json);
  }

  @override
  Future<ResumeMatch> matchResume(
    ResumeAnalysis resume,
    JobDescription jobDescription,
  ) async {
    final prompt = ResumeMatchingPrompt.build(
      resumeSummaryJson: jsonEncode(resume.toJson()),
      jobDescriptionText: jobDescription.rawText.isNotEmpty
          ? jobDescription.rawText
          : jobDescription.requiredSkills.join(', '),
    );
    final response = await _client.complete(prompt);

    if (!response.success) {
      throw Exception(response.errorMessage ?? 'Gemini resume matching failed.');
    }

    final json = GeminiService.parseJson(response.rawContent);
    return ResumeMatch.fromJson(json);
  }

  @override
  Future<ResumeReview> reviewResume(ResumeAnalysis resume) async {
    final text =
        '${resume.summary}\n${resume.experienceSummary}\n${jsonEncode(resume.toJson())}';
    final prompt = ATSPrompt.build(text);
    final response = await _client.complete(prompt);

    if (!response.success) {
      throw Exception(response.errorMessage ?? 'Gemini resume review failed.');
    }

    final json = GeminiService.parseJson(response.rawContent);
    return ResumeReview.fromJson(json);
  }

  @override
  Future<List<CandidateRanking>> rankCandidates(
    List<ResumeAnalysis> candidates,
    JobDescription jobDescription,
  ) async {
    final candidatesJson = jsonEncode(
      candidates.map((c) => c.toJson()).toList(),
    );
    final prompt = CandidateRankingPrompt.build(
      candidatesJson: candidatesJson,
      jobDescriptionText: jobDescription.rawText.isNotEmpty
          ? jobDescription.rawText
          : jobDescription.requiredSkills.join(', '),
    );
    final response = await _client.complete(prompt);

    if (!response.success) {
      throw Exception(response.errorMessage ?? 'Gemini candidate ranking failed.');
    }

    final json = GeminiService.parseJson(response.rawContent);
    final list = json['candidate_rankings'] as List<dynamic>? ?? [];
    return list
        .map((e) => CandidateRanking.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
