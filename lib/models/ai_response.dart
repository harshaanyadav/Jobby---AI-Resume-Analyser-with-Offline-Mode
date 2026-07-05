/// Generic wrapper for a raw OpenRouter completion result before
/// it is parsed into a specific model (ResumeAnalysis, ResumeMatch, etc).
class AIResponse {
  final bool success;
  final String rawContent;
  final String? errorMessage;

  const AIResponse({
    required this.success,
    this.rawContent = '',
    this.errorMessage,
  });

  factory AIResponse.ok(String content) =>
      AIResponse(success: true, rawContent: content);

  factory AIResponse.failure(String message) =>
      AIResponse(success: false, errorMessage: message);
}
