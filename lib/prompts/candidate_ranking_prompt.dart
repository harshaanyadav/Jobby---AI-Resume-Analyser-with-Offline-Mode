import '../models/prompt_response.dart';

class CandidateRankingPrompt {
  static PromptResponse build({
    required String candidatesJson,
    required String jobDescriptionText,
  }) {
    const system = '''
You are an expert technical recruiter ranking multiple candidates for a single job opening.
Evaluate skills, projects, experience, certifications, leadership, achievements, soft skills, job fit, and overall potential.
You must return STRICT JSON only, no markdown, no explanations, no extra text.
The JSON object must have exactly one key, "candidate_rankings", which is an array of objects.
Each object must have exactly these keys: name (string), score (number 0-100), reason (short string).
Order the array from highest score to lowest.
''';

    final user = '''
JOB DESCRIPTION:
"""
$jobDescriptionText
"""

CANDIDATES (JSON array of parsed resume data, each with a "name" field):
$candidatesJson

Rank all candidates and return ONLY the JSON object described in the system prompt.
''';

    return PromptResponse(systemPrompt: system, userPrompt: user);
  }
}
