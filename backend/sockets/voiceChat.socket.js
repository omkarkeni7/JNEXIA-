const speechToTextService = require('../services/speechToText.service');
const mistralBotService = require('../services/mistralBot.service');
const elevenLabsService = require('../services/elevenLabs.service');

/**
 * Initialize Voice Chat Socket.IO handlers
 * @param {SocketIO.Server} io - Socket.IO server instance
 */
function initializeVoiceChatSocket(io) {
    // Store audio chunks per socket
    const audioChunks = new Map();

    io.on('connection', (socket) => {
        console.log(`[Socket] Client connected: ${socket.id}`);

        // Initialize audio buffer for this socket
        audioChunks.set(socket.id, []);

        // Send connection confirmation
        socket.emit('connected', {
            sessionId: socket.id,
            message: 'Connected to voice chat server',
        });

        /**
         * Handle incoming audio stream chunks
         */
        socket.on('audioStream', (audioData) => {
            try {
                const chunks = audioChunks.get(socket.id);
                chunks.push(Buffer.from(audioData));
                console.log(`[Socket] Received audio chunk from ${socket.id} (${chunks.length} chunks)`);
            } catch (error) {
                console.error('[Socket] Error handling audio stream:', error.message);
                socket.emit('error', { message: 'Failed to process audio chunk' });
            }
        });

        /**
         * Handle stop audio and process the complete recording
         */
        socket.on('stopAudio', async (config) => {
            try {
                const chunks = audioChunks.get(socket.id);

                if (!chunks || chunks.length === 0) {
                    socket.emit('error', { message: 'No audio data received' });
                    return;
                }

                console.log(`[Socket] Processing ${chunks.length} audio chunks for ${socket.id}`);

                // Combine all chunks into a single buffer
                const audioBuffer = Buffer.concat(chunks);

                // Clear chunks for next recording
                audioChunks.set(socket.id, []);

                // Extract configuration
                const {
                    encoding = 'WEBM_OPUS',
                    sampleRateHertz = 48000,
                    languageCode = 'en-US',
                    systemPrompt,
                    studentContext,
                } = config;

                // Step 1: Convert speech to text
                const transcription = await speechToTextService.transcribeAudio(audioBuffer, {
                    encoding,
                    sampleRateHertz,
                    languageCode,
                });

                if (!transcription || transcription.trim() === '') {
                    socket.emit('error', { message: 'No speech detected in audio' });
                    return;
                }

                // Send transcription to client
                socket.emit('transcription', { text: transcription });

                // Step 2: Generate AI response
                const languageName = getLanguageName(languageCode);
                const aiResponse = await mistralBotService.generateResponse(
                    transcription,
                    socket.id,
                    {
                        systemPrompt,
                        language: languageName,
                        studentContext,
                        maxTokens: 200,
                    }
                );

                // Step 3: Convert AI response to speech
                const audioBytes = await elevenLabsService.textToSpeech(aiResponse);

                // Send complete response to client
                socket.emit('aiResponse', {
                    transcription: transcription,
                    response: aiResponse,
                    audio: audioBytes.toString('base64'), // Send as base64
                });

                console.log(`[Socket] Complete response sent to ${socket.id}`);
            } catch (error) {
                console.error('[Socket] Error processing audio:', error.message);
                socket.emit('error', { message: `Processing failed: ${error.message}` });
            }
        });

        /**
         * Handle text message (for testing without voice)
         */
        socket.on('textMessage', async (data) => {
            try {
                const { message, systemPrompt, studentContext, languageCode = 'en-US' } = data;

                if (!message || message.trim() === '') {
                    socket.emit('error', { message: 'Empty message' });
                    return;
                }

                console.log(`[Socket] Text message from ${socket.id}: ${message}`);

                // Generate AI response
                const languageName = getLanguageName(languageCode);
                const aiResponse = await mistralBotService.generateResponse(
                    message,
                    socket.id,
                    {
                        systemPrompt,
                        language: languageName,
                        studentContext,
                        maxTokens: 200,
                    }
                );

                // Convert to speech
                const audioBytes = await elevenLabsService.textToSpeech(aiResponse);

                // Send response
                socket.emit('aiResponse', {
                    transcription: message,
                    response: aiResponse,
                    audio: audioBytes.toString('base64'),
                });

                console.log(`[Socket] Text response sent to ${socket.id}`);
            } catch (error) {
                console.error('[Socket] Error processing text message:', error.message);
                socket.emit('error', { message: `Processing failed: ${error.message}` });
            }
        });

        /**
         * Handle clear chat history
         */
        socket.on('clearHistory', () => {
            try {
                mistralBotService.clearSession(socket.id);
                socket.emit('historyCleared', { message: 'Chat history cleared' });
                console.log(`[Socket] History cleared for ${socket.id}`);
            } catch (error) {
                console.error('[Socket] Error clearing history:', error.message);
                socket.emit('error', { message: 'Failed to clear history' });
            }
        });

        /**
         * Handle disconnect
         */
        socket.on('disconnect', () => {
            console.log(`[Socket] Client disconnected: ${socket.id}`);
            audioChunks.delete(socket.id);
            // Optionally clear session history on disconnect
            // mistralBotService.clearSession(socket.id);
        });
    });

    console.log('[Socket] Voice chat handlers initialized');
}

/**
 * Get language name from language code
 * @param {string} languageCode - Language code (e.g., 'en-US')
 * @returns {string} - Language name
 */
function getLanguageName(languageCode) {
    const languageMap = {
        'en-US': 'English',
        'en-GB': 'English',
        'hi-IN': 'Hindi',
        'mr-IN': 'Marathi',
        'es-ES': 'Spanish',
        'fr-FR': 'French',
        'de-DE': 'German',
        'ja-JP': 'Japanese',
        'zh-CN': 'Chinese',
    };

    return languageMap[languageCode] || 'English';
}

module.exports = initializeVoiceChatSocket;
