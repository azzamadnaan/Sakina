import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah/config.dart';

class GeminiService {
  final _client = http.Client();

  /// Sends a chat request to Gemini and returns the assistant's response.
  /// [messages] should contain the last 10 chat entries, each as a map:
  /// { "role": "user" | "model", "content": "text" }
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final uri = Uri.parse(
        '${Config.geminiBaseUrl}/${Config.geminiModel}:generateContent?key=${Config.geminiApiKey}');
    final body = _buildRequestBody(messages);

    try {
      final response = await _client
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Gemini error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Empty response from Gemini.');
      }

      final finishReason = candidates.first['finishReason'];
      if (finishReason == 'SAFETY' ||
          finishReason == 'PROHIBITED_CONTENT' ||
          finishReason == 'BLOCKLIST') {
        // Return a refusal message.
        return _refusalMessage();
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No content parts.');
      }

      final text = parts.first['text'] as String?;
      return text?.trim() ?? _refusalMessage();
    } on TimeoutException {
      return 'عذرًا، استغرق الرد وقتًا طويلاً. حاول مرة أخرى لاحقًا.';
    } catch (_) {
      return 'عذرًا، حدث خطأ في الاتصال. يرجى المحاولة لاحقًا.';
    }
  }

  Map<String, dynamic> _buildRequestBody(List<Map<String, String>> msgs) {
    // Convert messages to Gemini "contents" format.
    final List<Map<String, dynamic>> contents = [
      {
        'role': 'user',
        'parts': [
          {'text': Config.systemPrompt}
        ]
      },
    ];

    for (final m in msgs) {
      contents.add({
        'role': m['role'],
        'parts': [
          {'text': m['content']}
        ]
      });
    }

    return {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.6,
        'maxOutputTokens': 1500,
        'topP': 0.95,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_LOW_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_LOW_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_LOW_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_LOW_AND_ABOVE',
        },
      ],
    };
  }

  String _refusalMessage() => '''
عذرًا، لا أستطيع الإجابة على هذا السؤال. أنا سكينة، مساعدتك 
تقتصر على ما هو حلال وطيب. ﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا﴾
''';
}
