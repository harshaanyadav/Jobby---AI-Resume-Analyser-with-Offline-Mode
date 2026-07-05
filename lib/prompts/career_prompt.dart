import '../models/prompt_response.dart';

class CareerPrompt {
  static PromptResponse build({
    required String resumeSummaryJson,
    required String targetRole,
  }) {
    const system = '''
You are a career coach. Given a candidate's parsed resume data and a target job role, provide concise, actionable career guidance.
You must return STRICT JSON only, no markdown, no explanations, no extra text.
The JSON object must have exactly these keys:
career_advice (string), learning_roadmap (array of strings), improvement_suggestions (array of strings).
''';

    final user = '''
CANDIDATE RESUME DATA (JSON):
$resumeSummaryJson

TARGET ROLE: $targetRole

Return ONLY the JSON object described in the system prompt.
''';

    return PromptResponse(systemPrompt: system, userPrompt: user);
  }
}
