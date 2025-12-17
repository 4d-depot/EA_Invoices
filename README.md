# EA_Invoices

A ready-to-use Invoice application. You can adapt it to suit your needs.

## Installing and Using a 4D Project

### Pre-requisites

* Download the latest Release version of 4D from: https://us.4d.com/product-download or the latest Beta version from: https://discuss.4d.com
* Follow the activation steps for 4D from: https://developer.4d.com/docs/GettingStarted/installation

### Steps to Run the Project

* Clone or download the GitHub repository containing the 4D project to your local machine. Need help, check out [this blog](https://blog.4d.com/github-4d-depot/).
* Open the 4D project in your 4D software by navigating to "File > Open Project".  You can find more details [in 4d documentation](https://developer.4d.com/docs/GettingStarted/creating#opening-a-project).
* Play with this HDI.
* Navigate to the "Mode/Return to design mode" menu to view the code.

By following these steps, you will be able to successfully install and run a 4D project.

## AI Chat Setup

This branch features an AI Chat. To set it up, you need to create an `AIProvider.json` file in the `Resources` folder with your API configuration:

```json
{
  "reasoning": {
    "key": "YOUR_API_KEY",
    "model": "gpt-4o",
    "url": "OPTIONAL_CUSTOM_URL"
  }
}
```

Leave API key empty if you use a local model.
This project was mainly tested with OpenAI gpt-4.1 model.

## Voice Features (AIVoice Branch)

The AIVoice branch adds voice conversation capabilities to the AI Chat:

### Speech-to-Text (STT)
- **Voice input**: Click the microphone button to record your voice
- **Whisper API integration**: Audio is transcribed using OpenAI's Whisper API
- **Voice Activity Detection (VAD)**: Automatic silence detection stops recording after 1.5 seconds of silence
- **Continuous conversation mode**: Toggle for hands-free voice conversations

### Text-to-Speech (TTS)
- **Streaming audio**: Real-time audio playback using OpenAI's TTS API with PCM streaming
- **Pipelined TTS**: Multiple sentences are queued and played sequentially for natural conversation flow
- **Web Audio API**: Low-latency audio playback directly in the web area

### Technical Highlights
- `VoiceServices` class handles both STT (Whisper) and TTS (OpenAI) API calls
- `TTSRequestHandler` class manages async HTTP callbacks for streaming audio
- Externalized JavaScript (`chat-template.js`) for better maintainability
- DOMPurify integration for secure HTML sanitization

