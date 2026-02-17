# Backend Integration - System Flow

## 1. Voice Chat Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERACTION                            │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ 1. Taps Microphone
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Frontend)                            │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  ThreeDMentorPageBackend                                       │ │
│  │  - Starts audio recording (record package)                     │ │
│  │  - Shows "Listening..." status                                 │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 2. Audio chunks                  │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  VoiceChatService                                              │ │
│  │  - Sends audio chunks via Socket.IO                            │ │
│  │  - Emits 'audioStream' events                                  │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
└──────────────────────────────────┼──────────────────────────────────┘
                                   │ 3. WebSocket (Socket.IO)
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│                    BACKEND SERVER (Node.js)                          │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  voiceChat.socket.js                                           │ │
│  │  - Receives audio chunks                                       │ │
│  │  - Buffers audio data                                          │ │
│  │  - On 'stopAudio': processes complete recording                │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 4. Audio buffer                  │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  speechToText.service.js                                       │ │
│  │  - Sends to Google Cloud Speech-to-Text API                    │ │
│  │  - Returns transcribed text                                    │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 5. Transcribed text              │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  mistralBot.service.js                                         │ │
│  │  - Sends text + context to Mistral AI                          │ │
│  │  - Includes student context                                    │ │
│  │  - Maintains conversation history                              │ │
│  │  - Returns AI response                                         │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 6. AI response text              │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  elevenLabs.service.js                                         │ │
│  │  - Converts text to speech                                     │ │
│  │  - Returns audio bytes                                         │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 7. Audio bytes                   │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  voiceChat.socket.js                                           │ │
│  │  - Emits 'aiResponse' event                                    │ │
│  │  - Sends: transcription + response + audio                     │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
└──────────────────────────────────┼──────────────────────────────────┘
                                   │ 8. WebSocket (Socket.IO)
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│                    FLUTTER APP (Frontend)                            │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  VoiceChatService                                              │ │
│  │  - Receives 'aiResponse' event                                 │ │
│  │  - Decodes base64 audio                                        │ │
│  │  - Triggers callbacks                                          │ │
│  └───────────────────────────────┬───────────────────────────────┘ │
│                                   │ 9. Response data                 │
│  ┌───────────────────────────────▼───────────────────────────────┐ │
│  │  ThreeDMentorPageBackend                                       │ │
│  │  - Updates UI with response text                               │ │
│  │  - Plays audio (audioplayers)                                  │ │
│  │  - Animates 3D model (Talk animation)                          │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ 10. User hears response
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          USER EXPERIENCE                             │
│  - Sees transcription of what they said                             │
│  - Sees AI response text                                            │
│  - Hears natural voice response                                     │
│  - Watches 3D model speak with lip-sync                             │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. Technology Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                           FRONTEND                                   │
├─────────────────────────────────────────────────────────────────────┤
│  Flutter Framework                                                   │
│  ├─ UI: Material Design                                             │
│  ├─ 3D Model: model_viewer_plus                                     │
│  ├─ Audio Recording: record (v5.0.4)                                │
│  ├─ Audio Playback: audioplayers (v6.0.0)                           │
│  └─ WebSocket: socket_io_client (v2.0.3+1)                          │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Socket.IO WebSocket
                                   │
┌─────────────────────────────────────────────────────────────────────┐
│                           BACKEND                                    │
├─────────────────────────────────────────────────────────────────────┤
│  Node.js + Express                                                   │
│  ├─ WebSocket: socket.io (v4.6.1)                                   │
│  ├─ HTTP Server: express (v4.18.2)                                  │
│  └─ CORS: cors (v2.8.5)                                             │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
┌──────────────────────┐ ┌──────────────┐ ┌─────────────────┐
│  Google Cloud        │ │  Mistral AI  │ │  ElevenLabs     │
│  Speech-to-Text      │ │              │ │  Text-to-Speech │
│                      │ │  AI Model:   │ │                 │
│  - 95%+ accuracy     │ │  mistral-    │ │  Voice: Adam    │
│  - 8+ languages      │ │  small-      │ │  Model: v2      │
│  - Real-time         │ │  latest      │ │  Multi-lingual  │
└──────────────────────┘ └──────────────┘ └─────────────────┘
```

## 3. Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AUDIO RECORDING                               │
│  User speaks → Microphone → record package → Audio chunks           │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        AUDIO STREAMING                               │
│  Audio chunks → Socket.IO emit('audioStream') → Backend buffer      │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SPEECH-TO-TEXT                                  │
│  Audio buffer → Google Cloud API → Transcribed text                 │
│  Example: "What is my attendance?" (English)                         │
│           "मेरी उपस्थिति क्या है?" (Hindi)                          │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        AI PROCESSING                                 │
│  Transcription + Student Context → Mistral AI → Response            │
│  Context includes:                                                   │
│  - Student name, course                                             │
│  - Attendance, marks                                                │
│  - Risk level, strengths, concerns                                  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      TEXT-TO-SPEECH                                  │
│  AI response text → ElevenLabs API → Audio bytes (MP3)              │
│  Natural, human-like voice synthesis                                 │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        RESPONSE DELIVERY                             │
│  Audio bytes → Socket.IO emit('aiResponse') → Flutter               │
│  Includes: transcription + response text + audio                    │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        USER EXPERIENCE                               │
│  Audio playback + 3D model animation + Text display                 │
└─────────────────────────────────────────────────────────────────────┘
```

## 4. Socket.IO Events

```
CLIENT → SERVER:
├─ 'audioStream' (audio chunk)
│  └─ Sent continuously during recording
├─ 'stopAudio' (config)
│  └─ Sent when user stops recording
│  └─ Triggers processing pipeline
├─ 'textMessage' (message, config)
│  └─ For testing without voice
└─ 'clearHistory'
   └─ Clears conversation history

SERVER → CLIENT:
├─ 'connected' (sessionId, message)
│  └─ Sent on connection
├─ 'transcription' (text)
│  └─ Sent after speech-to-text
├─ 'aiResponse' (transcription, response, audio)
│  └─ Sent after complete processing
├─ 'error' (message)
│  └─ Sent on any error
└─ 'historyCleared' (message)
   └─ Sent after clearing history
```

## 5. File Organization

```
JNEXIA--main/
│
├── backend/                          # Node.js Backend
│   ├── services/                     # Business Logic
│   │   ├── speechToText.service.js   # Google Cloud
│   │   ├── mistralBot.service.js     # Mistral AI
│   │   └── elevenLabs.service.js     # ElevenLabs
│   ├── sockets/                      # WebSocket Handlers
│   │   └── voiceChat.socket.js       # Socket.IO events
│   ├── data/                         # Data Storage
│   │   └── mistral_history.json      # Conversation history
│   ├── server.js                     # Main server
│   ├── package.json                  # Dependencies
│   └── .env                          # Environment variables
│
└── JNEXIA--main/                     # Flutter App
    └── lib/
        ├── pages/
        │   └── three_d_mentor_page_backend.dart  # UI
        └── services/
            └── voice_chat_service.dart           # Socket.IO client
```

## 6. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      DEVELOPMENT SETUP                               │
├─────────────────────────────────────────────────────────────────────┤
│  Flutter App (localhost)                                             │
│  └─ Connects to: http://localhost:3000                              │
│                                                                       │
│  Backend Server (localhost:3000)                                     │
│  └─ Connects to: Google Cloud, Mistral AI, ElevenLabs               │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      PRODUCTION SETUP                                │
├─────────────────────────────────────────────────────────────────────┤
│  Mobile App                                                          │
│  └─ Connects to: https://your-domain.com                            │
│                                                                       │
│  Backend Server (Cloud - Heroku/AWS/GCP)                             │
│  └─ Connects to: Google Cloud, Mistral AI, ElevenLabs               │
└─────────────────────────────────────────────────────────────────────┘
```

---

**This diagram shows the complete flow from user interaction to response delivery!**
