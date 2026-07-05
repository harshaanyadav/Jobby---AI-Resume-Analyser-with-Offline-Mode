/// Represents a fully-built prompt ready to send to OpenRouter:
/// system instructions + user content, kept separate so prompt files
/// stay reusable and free of any HTTP concerns.
class PromptResponse {
  final String systemPrompt;
  final String userPrompt;

  const PromptResponse({required this.systemPrompt, required this.userPrompt});
}
