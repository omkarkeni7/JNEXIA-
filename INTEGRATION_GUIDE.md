# JNEXIA Backend Integration Guide

## Overview

This guide will help you integrate the 3D mentor with the backend voice chat system using Socket.IO, Google Cloud Speech-to-Text, and Mistral AI.

## Architecture

### Frontend (Flutter)
- **3D Model**: `three_d_mentor_page_backend.dart`
- **Voice Chat Service**: `voice_chat_service.dart`
- **Audio Recording**: Uses `record` package for streaming audio
- **Audio Playback**: Uses `audioplayers` for TTS audio

### Backend (Node.js)
- **Server**: Express + Socket.IO
- **Speech-to-Text**: Google Cloud Speech-to-Text API
- **AI Responses**: Mistral AI
- **Text-to-Speech**: ElevenLabs API

## Setup Instructions

### 1. Backend Setup

#### Install Dependencies
```bash
cd backend
npm install
```

#### Configure Google Cloud

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable Speech-to-Text API**
   - Navigate to "APIs & Services" > "Library"
   - Search for "Cloud Speech-to-Text API"
   - Click "Enable"

3. **Create Service Account**
   - Go to "IAM & Admin" > "Service Accounts"
   - Click "Create Service Account"
   - Name it (e.g., "jnexia-speech-to-text")
   - Grant role: "Cloud Speech-to-Text API User"
   - Click "Done"

4. **Download Credentials**
   - Click on the service account you created
   - Go to "Keys" tab
   - Click "Add Key" > "Create new key"
   - Choose "JSON" format
   - Save the file as `google-credentials.json` in the `backend` directory

#### Environment Variables

The `.env` file is already configured with your API keys:
```env
MISTRAL_API_KEY=J8puXD4IdLfYqAeVCJbFaqlM8OszNg65
ELEVENLABS_API_KEY=sk_637c593411cce03d58c732b2d58c59b45d152e9a7d934c70
ELEVENLABS_VOICE_ID=pNInz6obpgDQGcFmaJgB
PORT=3000
NODE_ENV=development
GOOGLE_APPLICATION_CREDENTIALS=./google-credentials.json
```

#### Start the Server

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will start on `http://localhost:3000`

### 2. Flutter Setup

#### Install Dependencies
```bash
flutter pub get
```

#### Update Server URL

Edit `lib/services/voice_chat_service.dart` and update the server URL:

```dart
// For local development
static const String serverUrl = 'http://localhost:3000';

// For Android emulator
static const String serverUrl = 'http://10.0.2.2:3000';

// For physical device (use your computer's IP)
static const String serverUrl = 'http://192.168.x.x:3000';
```

To find your computer's IP:
- **Windows**: Run `ipconfig` in Command Prompt
- **Mac/Linux**: Run `ifconfig` in Terminal

#### Update Navigation

Update your navigation to use the new backend-enabled page:

```dart
// Replace this:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ThreeDMentorPage()),
);

// With this:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ThreeDMentorPageBackend()),
);
```

### 3. Testing

#### Test Backend Health
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "Voice chat server is running",
  "timestamp": "2026-02-17T06:00:00.000Z"
}
```

#### Test Chat API
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

#### Test Text-to-Speech
```bash
curl -X POST http://localhost:3000/api/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, this is a test"}' \
  --output test.mp3
```

### 4. Running the Complete System

1. **Start Backend Server**
   ```bash
   cd backend
   npm run dev
   ```

2. **Run Flutter App**
   ```bash
   flutter run
   ```

3. **Test Voice Chat**
   - Navigate to the 3D Mentor page
   - Wait for "Connected!" message
   - Tap the microphone button
   - Speak your question
   - The AI will respond with voice

## Features

### Current Implementation

✅ **Real-time Voice Chat**
- Audio streaming via Socket.IO
- Google Cloud Speech-to-Text for transcription
- Mistral AI for intelligent responses
- ElevenLabs for natural voice synthesis

✅ **Multi-Language Support**
- English (en-US)
- Hindi (hi-IN)
- Marathi (mr-IN)

✅ **Student Context Awareness**
- Fetches student data from backend
- Provides personalized responses based on student performance

✅ **3D Model Animation**
- Lip-sync animation when AI is speaking
- Idle animation when waiting

### Comparison: Old vs New

| Feature | Old (Direct API) | New (Backend) |
|---------|-----------------|---------------|
| Speech-to-Text | Flutter plugin (limited) | Google Cloud (accurate) |
| Language Support | Limited | 8+ languages |
| Audio Quality | Device-dependent | High-quality |
| Session Management | None | Full history |
| Scalability | Limited | Highly scalable |
| Error Handling | Basic | Comprehensive |

## Troubleshooting

### Backend Issues

**Error: Google Cloud credentials not found**
```
Solution: Ensure google-credentials.json exists in backend directory
```

**Error: EADDRINUSE (Port already in use)**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

**Error: Mistral API rate limit**
```
Solution: Wait a few minutes or upgrade your Mistral AI plan
```

### Flutter Issues

**Error: Socket connection failed**
```
Solution: 
1. Ensure backend is running
2. Check server URL in voice_chat_service.dart
3. For Android emulator, use http://10.0.2.2:3000
4. For physical device, use your computer's IP address
```

**Error: Microphone permission denied**
```
Solution: Grant microphone permission in device settings
```

**Error: Audio playback failed**
```
Solution: Ensure audioplayers package is properly installed
Run: flutter pub get
```

## File Structure

```
JNEXIA--main/
├── backend/
│   ├── services/
│   │   ├── speechToText.service.js
│   │   ├── mistralBot.service.js
│   │   └── elevenLabs.service.js
│   ├── sockets/
│   │   └── voiceChat.socket.js
│   ├── data/
│   │   └── mistral_history.json
│   ├── .env
│   ├── .env.example
│   ├── .gitignore
│   ├── package.json
│   ├── server.js
│   └── README.md
│
└── JNEXIA--main/
    └── lib/
        ├── pages/
        │   ├── three_d_mentor_page.dart (old)
        │   └── three_d_mentor_page_backend.dart (new)
        └── services/
            ├── voice_chat_service.dart
            ├── ai_service.dart (old)
            └── student_service.dart
```

## Next Steps

1. ✅ Backend server created
2. ✅ Flutter service created
3. ✅ New 3D mentor page created
4. ⏳ Install backend dependencies
5. ⏳ Configure Google Cloud credentials
6. ⏳ Update Flutter navigation
7. ⏳ Test the integration

## Support

For issues or questions:
- Check the troubleshooting section
- Review backend logs: `npm run dev`
- Check Flutter console for errors
- Verify all API keys are correct

## License

Part of JNEXIA Project
