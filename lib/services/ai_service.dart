import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Integreted Keys (As provided)
  static const String mistralApiKey = 'J8puXD4IdLfYqAeVCJbFaqlM8OszNg65';
  static const String elevenLabsApiKey = 'sk_26a1bad01958c835b788dd88ac1c4c12438d856fefeae2ed';
  
  // Voice ID for "Adam" (Male - Standard)
  static const String elevenLabsVoiceId = 'pNInz6obpgDQGcFmaJgB'; 

  /// Sends the user input to Mistral AI and returns the generated text.
  static Future<String?> getAIResponse(String userInput, String language, {String? studentContext}) async {
    try {
      final url = Uri.parse('https://api.mistral.ai/v1/chat/completions');
      
      // Prompt engineering for mentorship context
      String systemPrompt = "You are a helpful and knowledgeable teacher named Deepak. You are mentoring a student.";
      
      if (studentContext != null) {
        systemPrompt += "\n\nHERE IS THE STUDENT'S DATA. USE THIS TO ANSWER QUESTIONS ABOUT THEM:\n$studentContext\n\nIf asked 'what is my name', use the Name field from above. Keep answers concise (under 2 sentences) and encouraging.";
      } else {
        systemPrompt += " Keep answers concise (under 2 sentences) and encouraging.";
      }

      if (language == 'hi-IN') systemPrompt += " Reply in Hindi.";
      else if (language == 'mr-IN') systemPrompt += " Reply in Marathi.";

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $mistralApiKey',
        },
        body: jsonEncode({
          "model": "mistral-tiny",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userInput}
          ],
          "max_tokens": 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Mistral API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling Mistral API: $e');
      return null;
    }
  }

  /// Converts text to speech using ElevenLabs and returns the audio URL/Bytes.
  /// Note: ElevenLabs returns MPEG audio bytes.
  static Future<List<int>?> convertTextToSpeech(String text) async {
    try {
      final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$elevenLabsVoiceId');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': elevenLabsApiKey,
        },
        body: jsonEncode({
          "text": text,
          "model_id": "eleven_multilingual_v2",
          "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.5
          }
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('ElevenLabs API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling ElevenLabs API: $e');
      return null;
    }
  }
}
