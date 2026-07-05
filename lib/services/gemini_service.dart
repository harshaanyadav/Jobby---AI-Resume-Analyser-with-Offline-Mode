import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ai_response.dart';
import '../models/prompt_response.dart';

class GeminiRateLimitException implements Exception {
  final String message;
  GeminiRateLimitException(this.message);
}

/// Reusable Gemini (Google AI Studio) client. Mirrors OpenRouterService
/// so it can be swapped in with the same reliability behavior:
/// retries on transient errors with exponential backoff, clean failure
/// signaling, never throws raw exceptions the UI would need to handle.
class GeminiService {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 45);
  static const Duration _initialBackoff = Duration(milliseconds: 800);

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  String get _model => dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';
  String get _baseUrl =>
      dotenv.env['GEMINI_BASE_URL'] ??
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<AIResponse> complete(PromptResponse prompt) async {
    if (_apiKey.isEmpty) {
      return AIResponse.failure('Missing GEMINI_API_KEY in .env');
    }

    final uri = Uri.parse('$_baseUrl/$_model:generateContent');

    int attempt = 0;
    Duration backoff = _initialBackoff;

    while (true) {
      attempt++;
      try {
        final response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': _apiKey,
              },
              body: jsonEncode({
                'system_instruction': {
                  'parts': [
                    {'text': prompt.systemPrompt}
                  ]
                },
                'contents': [
                  {
                    'role': 'user',
                    'parts': [
                      {'text': prompt.userPrompt}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.3,
                  'responseMimeType': 'application/json',
                },
              }),
            )
            .timeout(_timeout);

        if (response.statusCode == 429) {
          throw GeminiRateLimitException(
              'Gemini free-tier rate limit exceeded.');
        }

        // 503 (model overloaded) and other 5xx errors are transient —
        // retry with exponential backoff instead of failing immediately.
        if (response.statusCode >= 500 && attempt <= _maxRetries) {
          await Future.delayed(backoff);
          backoff *= 2; // 0.8s -> 1.6s -> 3.2s
          continue;
        }

        if (response.statusCode != 200) {
          return AIResponse.failure(
              'Gemini API error: HTTP ${response.statusCode} — ${response.body}');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          return AIResponse.failure('Gemini returned no candidates.');
        }

        final parts = candidates.first['content']?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          return AIResponse.failure('Gemini returned no content parts.');
        }

        final text = parts.first['text']?.toString() ?? '';
        if (text.isEmpty) {
          return AIResponse.failure('Gemini returned empty text.');
        }

        return AIResponse.ok(text);
      } on GeminiRateLimitException catch (e) {
        return AIResponse.failure(e.message);
      } catch (e) {
        if (attempt <= _maxRetries) {
          await Future.delayed(backoff);
          backoff *= 2;
          continue;
        }
        return AIResponse.failure('Gemini request failed: $e');
      }
    }
  }

  /// Parses AI content into a JSON map. responseMimeType=application/json
  /// above means Gemini shouldn't add markdown fences, but we strip them
  /// defensively anyway since behavior can vary by model version.
  static Map<String, dynamic> parseJson(String content) {
    String cleaned = content.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'^```json'), '');
      cleaned = cleaned.replaceAll(RegExp(r'^```'), '');
      cleaned = cleaned.replaceAll(RegExp(r'```$'), '');
      cleaned = cleaned.trim();
    }
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}
