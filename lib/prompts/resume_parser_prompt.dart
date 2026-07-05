import '../models/prompt_response.dart';

class ResumeParserPrompt {
  static PromptResponse build(String resumeText) {
    const system = '''
You are an expert resume parser. You extract structured candidate data from raw resume text.
You must return STRICT JSON only. Never include markdown formatting, code fences, explanations, or any text outside the JSON object.
The JSON object must have exactly these keys:
name, email, phone, linkedin, degree, experience_years, experience_summary, projects, certifications, technical_skills, soft_skills, frameworks, tools, cloud, languages, strengths, weaknesses, career_level, industry, summary.
Array fields must be arrays of strings. If a field cannot be determined, use an empty string or empty array. Never fabricate data that is not implied by the resume text.
''';

    final user = '''
Extract structured data from the following resume text and return ONLY the JSON object described in the system prompt.

RESUME TEXT:
"""
$resumeText
"""
''';

    return PromptResponse(systemPrompt: system, userPrompt: user);
  }
}
