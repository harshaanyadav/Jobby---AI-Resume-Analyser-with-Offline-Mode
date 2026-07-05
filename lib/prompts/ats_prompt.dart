import '../models/prompt_response.dart';

class ATSPrompt {
  static PromptResponse build(String resumeText) {
    const system = '''
You are an Applicant Tracking System (ATS) evaluator and professional resume reviewer.
You must return STRICT JSON only, no markdown, no explanations, no extra text.
The JSON object must have exactly these keys:
ats (an object with ats_score [0-100 number], resume_quality [string], formatting_issues [array of strings], keyword_suggestions [array of strings]),
resume_summary (string), grammar_review (string), career_advice (string), interview_readiness (string),
project_evaluation (string), strengths (array of strings), weaknesses (array of strings),
improvement_suggestions (array of strings), learning_roadmap (array of strings), hiring_recommendation (string).
''';

    final user = '''
Evaluate the following resume as an ATS system and career coach. Return ONLY the JSON object described in the system prompt.

RESUME TEXT:
"""
$resumeText
"""
''';

    return PromptResponse(systemPrompt: system, userPrompt: user);
  }
}
