# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Backend Dependencies (2 min)

```bash
cd backend
npm install
```

### Step 2: Setup Google Cloud (REQUIRED)

**You MUST complete this step for the backend to work!**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or use existing)
3. Enable "Cloud Speech-to-Text API"
4. Create a service account with "Cloud Speech-to-Text API User" role
5. Download the JSON key file
6. Save it as `google-credentials.json` in the `backend` folder

### Step 3: Start Backend Server (30 sec)

```bash
cd backend
npm start
```

You should see:
```
🚀 Voice Chat Server Started
📡 Server running on: http://localhost:3000
🔌 Socket.IO ready for connections
🎤 Google Speech-to-Text: ✓
🤖 Mistral AI: ✓
🔊 ElevenLabs TTS: ✓
```

### Step 4: Update Flutter App (1 min)

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Update server URL in `lib/services/voice_chat_service.dart`:**
   
   For **Android Emulator**:
   ```dart
   static const String serverUrl = 'http://10.0.2.2:3000';
   ```
   
   For **Physical Device** (find your IP with `ipconfig` on Windows):
   ```dart
   static const String serverUrl = 'http://YOUR_IP_ADDRESS:3000';
   ```

3. **Update navigation to use the new page:**
   
   Find where you navigate to the 3D Mentor and replace:
   ```dart
   // OLD
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => ThreeDMentorPage()
   ));
   
   // NEW
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => ThreeDMentorPageBackend()
   ));
   ```

### Step 5: Run & Test (1 min)

```bash
flutter run
```

1. Navigate to 3D Mentor
2. Wait for "Connected!" message
3. Tap microphone
4. Ask a question
5. Listen to AI response!

## ✅ Verification Checklist

- [ ] Backend server is running (check terminal)
- [ ] You see ✓ marks for all services in backend logs
- [ ] Flutter app shows "Connected!" message
- [ ] Microphone permission granted
- [ ] Audio plays after speaking

## 🔧 Common Issues

### Backend won't start
```
Error: Google Cloud credentials not found
```
**Solution:** Make sure `google-credentials.json` exists in `backend/` folder

### Flutter can't connect
```
Error: Socket connection failed
```
**Solution:** 
- Check backend is running
- Update server URL in `voice_chat_service.dart`
- Use `http://10.0.2.2:3000` for Android emulator

### No audio playback
**Solution:** Run `flutter pub get` to ensure all packages are installed

## 📚 Full Documentation

For detailed setup and troubleshooting, see:
- `INTEGRATION_GUIDE.md` - Complete integration guide
- `backend/README.md` - Backend API documentation

## 🎯 What's Different?

| Feature | Old | New (Backend) |
|---------|-----|---------------|
| Speech Recognition | Flutter plugin | Google Cloud API |
| Accuracy | ~70% | ~95% |
| Languages | 3 | 8+ |
| Audio Quality | Basic | Professional |
| Session History | None | Full tracking |

## 🆘 Need Help?

1. Check backend terminal for errors
2. Check Flutter console for errors
3. Verify all API keys in `.env`
4. Review `INTEGRATION_GUIDE.md`

---

**Ready to go? Start with Step 1!** 🚀
