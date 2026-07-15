import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/chat_message_model.dart';
import '../models/improvement_score_model.dart';

class CoachRepository {
  const CoachRepository();

  // ── Get chat history ───────────────────────────────────────────────────────
  Future<List<ChatMessage>> getChatHistory() async {
    final res = await ApiClient.get(ApiEndpoints.coachHistory);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Clear chat history ─────────────────────────────────────────────────────
  Future<void> clearHistory() async {
    await ApiClient.delete(ApiEndpoints.coachHistory);
  }

  // ── Get improvement score ──────────────────────────────────────────────────
  Future<ImprovementScoreModel> getImprovementScore() async {
    final res = await ApiClient.get(ApiEndpoints.improvementScore);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return ImprovementScoreModel.fromJson(
          res.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load improvement score');
  }

  // ── Get daily AI advice ────────────────────────────────────────────────────
  Future<String> getDailyAdvice() async {
    final res = await ApiClient.get(ApiEndpoints.dailyAdvice);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return res.data['data'] as String;
    }
    throw Exception('Failed to load daily advice');
  }

  // ── SSE streaming chat ─────────────────────────────────────────────────────
  // Uses the `http` package directly because Dio cannot handle
  // chunked streaming responses properly.
  Stream<String> streamChat(String message, {String? context}) async* {
    final token   = await SecureStorage.getToken();
    final baseUrl = AppConstants.baseUrl;
    final uri     = Uri.parse('$baseUrl${ApiEndpoints.coachChat}');

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
        'Accept':        'text/event-stream',
      })
      ..body = jsonEncode({
        'message': message,
        if (context != null) 'context': context,
      });

    final response =
        await http.Client().send(request).timeout(
          const Duration(seconds: 60),
        );

    if (response.statusCode != 200) {
      throw Exception('Chat request failed: ${response.statusCode}');
    }

    // Process SSE stream
    String buffer = '';
    await for (final chunk in response.stream
        .transform(utf8.decoder)) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data.isEmpty) continue;

        try {
          final json  = jsonDecode(data) as Map<String, dynamic>;
          if (json['done']  == true) return;
          if (json['error'] != null) {
            throw Exception(json['error'] as String);
          }
          final delta = json['delta'] as String? ?? '';
          if (delta.isNotEmpty) yield delta;
        } catch (_) {
          // Skip malformed chunk
        }
      }
    }
  }
}