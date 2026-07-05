import '../models/prompt_response.dart';
import '../prompts/resume_parser_prompt.dart';
import '../prompts/resume_matching_prompt.dart';
import '../prompts/candidate_ranking_prompt.dart';
import '../prompts/ats_prompt.dart';
import '../prompts/career_prompt.dart';

/// Thin facade over the prompts/ folder, in case you want a single
/// entry point for building prompts elsewhere in the app later.
class PromptService {
  PromptResponse resumeParser(String resumeText) =>
      ResumeParserPrompt.build(resumeText);

  PromptResponse resumeMatching({
    required String resumeSummaryJson,
    required String jobDescriptionText,
  }) =>
      ResumeMatchingPrompt.build(
        resumeSummaryJson: resumeSummaryJson,
        jobDescriptionText: jobDescriptionText,
      );

  PromptResponse candidateRanking({
    required String candidatesJson,
    required String jobDescriptionText,
  }) =>
      CandidateRankingPrompt.build(
        candidatesJson: candidatesJson,
        jobDescriptionText: jobDescriptionText,
      );

  PromptResponse ats(String resumeText) => ATSPrompt.build(resumeText);

  PromptResponse career({
    required String resumeSummaryJson,
    required String targetRole,
  }) =>
      CareerPrompt.build(
        resumeSummaryJson: resumeSummaryJson,
        targetRole: targetRole,
      );
}
