# 🎙️ Gemini TTS Voice Model - Quick Setup Guide

## ✅ **New Voice: Vindemiatrix (Gemini TTS)**

Your 3D mentor now uses **Gemini's Vindemiatrix voice** - a warm, natural female voice that sounds more human-like!

---

## 🚀 **Quick Setup (5 Minutes)**

### **Step 1: Get Gemini API Key**

1. Go to **[Google AI Studio](https://aistudio.google.com/app/apikey)**
2. Click **"Create API Key"**
3. Copy the generated key

### **Step 2: Add to Environment**

Open `backend/.env` and add:

```bash
GEMINI_API_KEY=your_actual_api_key_here
GEMINI_TTS_VOICE=Vindemiatrix
```

### **Step 3: Start Backend**

```bash
cd backend
npm start
```

### **Step 4: Test It!**

1. Run your Flutter app
2. Navigate to 3D Mentor
3. Speak or send a message
4. Listen to the new **Vindemiatrix voice**! 🎉

---

## 🎯 **What You Get**

### **Primary TTS: Gemini (Vindemiatrix)**
- ✅ **Natural voice** - Sounds more human
- ✅ **High quality** - 24kHz audio
- ✅ **Fast** - Quick response times
- ✅ **Free tier** - Generous quota
- ✅ **Retry logic** - Handles errors gracefully

### **Fallback TTS: Google Cloud**
- ✅ **Automatic** - If Gemini fails
- ✅ **Reliable** - Always works
- ✅ **Seamless** - User doesn't notice

---

## 🎨 **Available Voices**

You can change the voice by updating `.env`:

| Voice | Type | Description |
|-------|------|-------------|
| **Vindemiatrix** | Female | Warm, natural (default) ✅ |
| Aoede | Female | Bright, cheerful |
| Charon | Male | Deep, authoritative |
| Fenrir | Male | Energetic, dynamic |
| Kore | Female | Gentle, soft |
| Puck | Neutral | Playful, fun |

**Example:**
```bash
GEMINI_TTS_VOICE=Charon  # Deep male voice
```

---

## 📊 **How It Works**

```
User speaks → Speech-to-Text → Mistral AI → TTS
                                              ↓
                                    Try Gemini TTS (Vindemiatrix)
                                              ↓
                                    Success? → Play audio ✅
                                              ↓ No
                                    Retry once (if 500 error)
                                              ↓
                                    Success? → Play audio ✅
                                              ↓ No
                                    Fallback to Google Cloud TTS
                                              ↓
                                    Play audio ✅
```

---

## 🔍 **Verify It's Working**

### **Check Console Logs:**

**Success:**
```
[TTS] Attempt 1/2: Trying Gemini TTS with voice Vindemiatrix...
[Gemini TTS] ✓ Generated 48000 bytes of audio
[Socket] Complete response sent using gemini-2.5-flash-preview-tts
```

**Fallback:**
```
[TTS] Gemini TTS attempt 1 failed: ...
[TTS] Falling back to Google Cloud TTS...
[Socket] Complete response sent using google-cloud-tts
```

---

## 🐛 **Troubleshooting**

### **Issue: "Gemini API key not configured"**
**Solution:** Add `GEMINI_API_KEY` to `.env` file

### **Issue: "Error 403"**
**Solution:** API key is invalid. Generate a new one at [AI Studio](https://aistudio.google.com/app/apikey)

### **Issue: Voice sounds different**
**Check:** Make sure `GEMINI_TTS_VOICE=Vindemiatrix` in `.env`

### **Issue: Audio not playing**
**Solution:** Browser autoplay blocked. User must click a button first.

---

## 📝 **Configuration Reference**

### **Environment Variables:**

```bash
# Required
GEMINI_API_KEY=your_key_here

# Optional (defaults shown)
GEMINI_TTS_VOICE=Vindemiatrix
PORT=3000
NODE_ENV=development
```

### **Voice Quality Comparison:**

| Metric | Gemini TTS | Google Cloud TTS |
|--------|------------|------------------|
| Naturalness | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Speed | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Cost | Free tier | Paid |
| Sample Rate | 24kHz | 24kHz |
| Format | WAV | MP3 |

---

## ✨ **Benefits**

### **For Users:**
- 🎙️ More natural, human-like voice
- ⚡ Faster response times
- 🎯 Better pronunciation
- 💬 More engaging conversations

### **For Developers:**
- 🆓 Free tier available
- 🔄 Automatic retry logic
- 🛡️ Fallback protection
- 📊 Detailed logging

---

## 🎉 **You're All Set!**

Once you add the Gemini API key to `.env`, your 3D mentor will automatically use the new **Vindemiatrix voice**!

**Test it now:**
1. Add API key to `.env`
2. Restart backend: `npm start`
3. Talk to your 3D mentor
4. Enjoy the new voice! 🎊

---

## 📚 **More Information**

- **Full Documentation:** `GEMINI_TTS_INTEGRATION.md`
- **Voice Chat Config:** `docs-voicechat-config.md`
- **Get API Key:** [Google AI Studio](https://aistudio.google.com/app/apikey)

---

**Status:** ✅ READY TO USE
**Voice:** Vindemiatrix (Gemini TTS)
**Setup Time:** ~5 minutes
