import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendAIService {
  // Backend server URL - Update this based on your setup
  static const String baseUrl = 'http://localhost:3000';
  
  // For Android emulator, use: http://10.0.2.2:3000
  // For physical device, use your computer's IP: http://192.168.x.x:3000

  /// Get AI response from backend (uses Mistral AI with conversation history)
  static Future<String?> getAIResponse(
    String userInput,
    String language, {
    String? studentContext,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userInput,
          'languageCode': language,
          'studentContext': studentContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('Backend AI Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling backend AI: $e');
      return null;
    }
  }

  /// Convert text to speech using backend (ElevenLabs)
  static Future<List<int>?> convertTextToSpeech(String text) async {
    try {
      final url = Uri.parse('$baseUrl/api/tts');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Backend TTS Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling backend TTS: $e');
      return null;
    }
  }

  /// Check if backend is available
  static Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available: $e');
      return false;
    }
  }
}
