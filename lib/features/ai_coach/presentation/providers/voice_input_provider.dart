/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Voice Input Provider - Speech-to-text state management (Phase 3.1)
///
/// **Features**:
/// - Speech recognition with speech_to_text package
/// - Permission handling (microphone)
/// - Recording states (idle, listening, processing)
/// - Error handling (permission denied, not available)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Voice input state
enum VoiceInputState {
  idle,
  listening,
  processing,
  error,
}

/// Voice input notifier state
class VoiceInputNotifierState {

  const VoiceInputNotifierState({
    this.state = VoiceInputState.idle,
    this.recognizedText = '',
    this.errorMessage,
  });
  final VoiceInputState state;
  final String recognizedText;
  final String? errorMessage;

  VoiceInputNotifierState copyWith({
    VoiceInputState? state,
    String? recognizedText,
    String? errorMessage,
  }) {
    return VoiceInputNotifierState(
      state: state ?? this.state,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Voice input notifier
class VoiceInputNotifier extends Notifier<VoiceInputNotifierState> {

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  @override
  VoiceInputNotifierState build() {
    return const VoiceInputNotifierState();
  }

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Check and request microphone permission
    final permissionStatus = await Permission.microphone.status;

    if (!permissionStatus.isGranted) {
      final requestResult = await Permission.microphone.request();
      if (!requestResult.isGranted) {
        state = state.copyWith(
          state: VoiceInputState.error,
          errorMessage: 'Microphone permission denied',
        );
        return false;
      }
    }

    // Initialize speech-to-text
    final available = await _speechToText.initialize(
      onError: (error) {
        state = state.copyWith(
          state: VoiceInputState.error,
          errorMessage: error.errorMsg,
        );
      },
      onStatus: (status) {
        if (status == 'done' && state.state == VoiceInputState.listening) {
          state = state.copyWith(state: VoiceInputState.idle);
        }
      },
    );

    if (!available) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Speech recognition not available',
      );
      return false;
    }

    _isInitialized = true;
    return true;
  }

  /// Start listening
  Future<void> startListening() async {
    // Initialize if needed
    final initialized = await initialize();
    if (!initialized) return;

    // Reset previous text
    state = state.copyWith(
      recognizedText: '',
      state: VoiceInputState.listening,
      errorMessage: null,
    );

    // Start listening
    await _speechToText.listen(
      onResult: (result) {
        state = state.copyWith(
          recognizedText: result.recognizedWords,
          state: result.finalResult
              ? VoiceInputState.processing
              : VoiceInputState.listening,
        );
      },
      listenFor: const Duration(seconds: 30), // Max 30 seconds
      pauseFor: const Duration(seconds: 3), // Auto-stop after 3s silence
      partialResults: true,
      cancelOnError: true,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      state = state.copyWith(state: VoiceInputState.idle);
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
      state = state.copyWith(
        state: VoiceInputState.idle,
        recognizedText: '',
      );
    }
  }

}

/// Voice input provider
final voiceInputProvider =
    NotifierProvider<VoiceInputNotifier, VoiceInputNotifierState>(
  VoiceInputNotifier.new,
);
