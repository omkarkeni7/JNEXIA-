import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import '../services/voice_chat_service.dart';
import '../services/student_service.dart';

class ThreeDMentorPageBackend extends StatefulWidget {
  const ThreeDMentorPageBackend({super.key});

  @override
  State<ThreeDMentorPageBackend> createState() => _ThreeDMentorPageBackendState();
}

class _ThreeDMentorPageBackendState extends State<ThreeDMentorPageBackend> {
  // Services
  final AudioRecorder _audioRecorder = AudioRecorder();

  // State variables
  String? _studentContext;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isConnected = false;
  String _text = "Press the mic to start!";
  String _selectedLanguage = 'en-US';

  // Audio recording
  List<int> _audioChunks = [];

  // Language Map
  final Map<String, String> _languages = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Marathi': 'mr-IN',
  };

  @override
  void initState() {
    super.initState();
    _initVoiceChat();
    _fetchStudentContext();
  }

  Future<void> _initVoiceChat() async {
    try {
      // Set up callbacks
      VoiceChatService.onConnected = () {
        if (mounted) {
          setState(() {
            _isConnected = true;
            _text = "Connected! Press the mic and ask me anything!";
          });
        }
      };

      VoiceChatService.onTranscription = (text) {
        if (mounted) {
          setState(() {
            _text = text;
            _isProcessing = true;
          });
        }
      };

      VoiceChatService.onAIResponse = (transcription, response, audioBytes) {
        if (mounted) {
          setState(() {
            _text = response;
            _isProcessing = false;
          });
          _playAudioBytes(audioBytes);
        }
      };

      VoiceChatService.onError = (error) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      };

      VoiceChatService.onDisconnected = () {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _text = "Disconnected from server";
          });
        }
      };

      // Connect to server
      await VoiceChatService.connect();
    } catch (e) {
      print("Error initializing voice chat: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to server: $e')),
        );
      }
    }
  }

  Future<void> _fetchStudentContext() async {
    try {
      final data = await StudentService.fetchFullStudentData();
      final profile = data['profile'] ?? {};
      final perf = data['performance'] ?? {};
      final currentPerf = perf['currentPerformance'] ?? {};

      String context = """
      Name: ${profile['name']}
      Course: ${profile['Course']}
      Attendance: ${currentPerf['attendance']}%
      Marks: ${currentPerf['currentPerformance']?['internalMarks'] ?? 'N/A'}
      Risk Level: ${currentPerf['riskLevel']}
      Strengths: ${currentPerf['strengths']?.join(', ') ?? 'N/A'}
      Concerns: ${currentPerf['concerns']?.join(', ') ?? 'N/A'}
      """;

      setState(() => _studentContext = context);
      print("Student Context Loaded: $_studentContext");
    } catch (e) {
      print("Error fetching student context: $e");
    }
  }

  Future<void> _listen() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to server')),
      );
      return;
    }

    if (!_isListening) {
      // Start recording
      try {
        if (await _audioRecorder.hasPermission()) {
          setState(() {
            _isListening = true;
            _text = "Listening...";
            _audioChunks = [];
          });

          // Start recording with stream
          final stream = await _audioRecorder.startStream(
            const RecordConfig(
              encoder: AudioEncoder.opus,
              sampleRate: 48000,
              numChannels: 1,
            ),
          );

          // Listen to audio stream and send chunks to server
          stream.listen(
            (data) {
              _audioChunks.addAll(data);
              // Send chunk to server
              VoiceChatService.sendAudioChunk(data);
            },
            onError: (error) {
              print('Recording error: $error');
              if (mounted) {
                setState(() => _isListening = false);
              }
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      } catch (e) {
        print('Error starting recording: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    } else {
      // Stop recording
      await _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      
      setState(() {
        _isListening = false;
        _isProcessing = true;
        _text = "Processing...";
      });

      // Send stop signal to server with configuration
      VoiceChatService.stopAudio(
        encoding: 'WEBM_OPUS',
        sampleRateHertz: 48000,
        languageCode: _selectedLanguage,
        systemPrompt: 'You are a helpful and knowledgeable teacher named Deepak. You are mentoring a student.',
        studentContext: _studentContext,
      );
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _playAudioBytes(Uint8List bytes) async {
    try {
      setState(() => _isSpeaking = true);
      
      // Use audioplayers to play the audio
      // Note: You'll need to save the bytes to a temporary file or use BytesSource
      final player = AudioPlayer();
      await player.play(BytesSource(bytes));
      
      player.onPlayerComplete.listen((event) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      print("Audio playback error: $e");
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    VoiceChatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      body: Stack(
        children: [
          // 1. Full Screen 3D Model
          Positioned.fill(
            child: ModelViewer(
              src: 'assets/models/speaking_man.glb',
              alt: '3D Mentor',
              ar: true,
              autoRotate: false,
              cameraControls: true,
              backgroundColor: Colors.transparent,
              disableZoom: false,
              minCameraOrbit: 'auto 0deg auto',
              maxCameraOrbit: 'auto 90deg auto',
              animationName: _isSpeaking ? 'Talk' : 'Idle',
              autoPlay: true,
            ),
          ),

          // 2. Back Button (Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                VoiceChatService.disconnect();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // 3. Connection Status Indicator
          if (!_isConnected)
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cloud_off, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Offline',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language & Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            items: _languages.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.value,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedLanguage = val);
                              }
                            },
                          ),
                        ),
                      ),

                      // Status Text
                      if (_isProcessing)
                        const Text(
                          "Processing...",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Text Display
                  if (_text.isNotEmpty && !_isProcessing)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _text,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Mic Button
                  GestureDetector(
                    onTap: _listen,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : const Color(0xFF40FFA7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : const Color(0xFF40FFA7)).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        size: 32,
                        color: _isListening ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isListening ? "Listening..." : "Tap to Speak",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
