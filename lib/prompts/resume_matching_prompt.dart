import '../models/prompt_response.dart';

class ResumeMatchingPrompt {
  static PromptResponse build({
    required String resumeSummaryJson,
    required String jobDescriptionText,
  }) {
    const system = '''
You are an expert technical recruiter. You compare a candidate resume against a job description and produce a fair, evidence-based match assessment.
You must return STRICT JSON only, no markdown, no explanations, no extra text.
The JSON object must have exactly these keys:
match_percentage (a number 0-100), strengths (array of strings), missing_skills (array of strings), recommendations (array of strings), summary (a short string).
''';

    final user = '''
CANDIDATE RESUME DATA (JSON):
$resumeSummaryJson

JOB DESCRIPTION:
"""
$jobDescriptionText
"""

Compare the candidate to the job description and return ONLY the JSON object described in the system prompt.
''';

    return PromptResponse(systemPrompt: system, userPrompt: user);
  }
}
