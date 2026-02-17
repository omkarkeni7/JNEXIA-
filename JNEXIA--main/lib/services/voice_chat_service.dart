import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VoiceChatService {
  static IO.Socket? _socket;
  static String? _sessionId;
  static bool _isConnected = false;

  // Backend server URL - Update this with your server URL
  static const String serverUrl = 'http://localhost:3000';

  // Callbacks
  static Function(String)? onTranscription;
  static Function(String, String, Uint8List)? onAIResponse; // (transcription, response, audio)
  static Function(String)? onError;
  static Function()? onConnected;
  static Function()? onDisconnected;

  /// Initialize Socket.IO connection
  static Future<void> connect() async {
    if (_isConnected) {
      print('[VoiceChat] Already connected');
      return;
    }

    try {
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      // Connection event
      _socket!.on('connect', (_) {
        print('[VoiceChat] Connected to server');
        _isConnected = true;
      });

      // Connected event with session ID
      _socket!.on('connected', (data) {
        _sessionId = data['sessionId'];
        print('[VoiceChat] Session ID: $_sessionId');
        onConnected?.call();
      });

      // Transcription event
      _socket!.on('transcription', (data) {
        final text = data['text'] as String;
        print('[VoiceChat] Transcription: $text');
        onTranscription?.call(text);
      });

      // AI Response event
      _socket!.on('aiResponse', (data) {
        final transcription = data['transcription'] as String;
        final response = data['response'] as String;
        final audioBase64 = data['audio'] as String;
        
        // Decode base64 audio
        final audioBytes = base64Decode(audioBase64);
        
        print('[VoiceChat] AI Response received');
        onAIResponse?.call(transcription, response, audioBytes);
      });

      // Error event
      _socket!.on('error', (data) {
        final message = data['message'] as String;
        print('[VoiceChat] Error: $message');
        onError?.call(message);
      });

      // History cleared event
      _socket!.on('historyCleared', (data) {
        print('[VoiceChat] History cleared');
      });

      // Disconnect event
      _socket!.on('disconnect', (_) {
        print('[VoiceChat] Disconnected from server');
        _isConnected = false;
        _sessionId = null;
        onDisconnected?.call();
      });

      // Connect to server
      _socket!.connect();
      
      // Wait for connection
      await Future.delayed(const Duration(seconds: 2));
      
      if (!_isConnected) {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      print('[VoiceChat] Connection error: $e');
      throw Exception('Failed to connect to voice chat server: $e');
    }
  }

  /// Disconnect from server
  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _sessionId = null;
      print('[VoiceChat] Disconnected');
    }
  }

  /// Send audio chunk to server
  static void sendAudioChunk(List<int> audioData) {
    if (!_isConnected || _socket == null) {
      print('[VoiceChat] Not connected, cannot send audio');
      return;
    }

    _socket!.emit('audioStream', audioData);
  }

  /// Stop audio recording and process
  static void stopAudio({
    String encoding = 'WEBM_OPUS',
    int sampleRateHertz = 48000,
    String languageCode = 'en-US',
    String? systemPrompt,
    String? studentContext,
  }) {
    if (!_isConnected || _socket == null) {
      print('[VoiceChat] Not connected, cannot stop audio');
      return;
    }

    _socket!.emit('stopAudio', {
      'encoding': encoding,
      'sampleRateHertz': sampleRateHertz,
      'languageCode': languageCode,
      'systemPrompt': systemPrompt ?? 'You are a helpful and knowledgeable teacher named Deepak.',
      'studentContext': studentContext,
    });

    print('[VoiceChat] Audio processing requested');
  }

  /// Send text message (for testing)
  static void sendTextMessage({
    required String message,
    String languageCode = 'en-US',
    String? systemPrompt,
    String? studentContext,
  }) {
    if (!_isConnected || _socket == null) {
      print('[VoiceChat] Not connected, cannot send message');
      return;
    }

    _socket!.emit('textMessage', {
      'message': message,
      'languageCode': languageCode,
      'systemPrompt': systemPrompt ?? 'You are a helpful and knowledgeable teacher named Deepak.',
      'studentContext': studentContext,
    });

    print('[VoiceChat] Text message sent: $message');
  }

  /// Clear chat history
  static void clearHistory() {
    if (!_isConnected || _socket == null) {
      print('[VoiceChat] Not connected, cannot clear history');
      return;
    }

    _socket!.emit('clearHistory');
    print('[VoiceChat] Clear history requested');
  }

  /// Check if connected
  static bool get isConnected => _isConnected;

  /// Get session ID
  static String? get sessionId => _sessionId;

  /// Get language code from language name
  static String getLanguageCode(String language) {
    const languageMap = {
      'en-US': 'en-US',
      'hi-IN': 'hi-IN',
      'mr-IN': 'mr-IN',
      'es-ES': 'es-ES',
      'fr-FR': 'fr-FR',
      'de-DE': 'de-DE',
      'ja-JP': 'ja-JP',
      'zh-CN': 'zh-CN',
    };

    return languageMap[language] ?? 'en-US';
  }
}
