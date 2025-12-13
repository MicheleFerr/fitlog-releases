/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Chat Input - Message input field with voice and send button
///
/// **Features**:
/// - Multi-line text input
/// - Voice input button with speech recognition (Phase 3.1)
/// - Send button (enabled only when text is not empty)
/// - Haptic feedback on send
/// - Disabled state during streaming
/// - Voice states: idle, listening, processing, error
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/voice_input_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Chat input widget
class ChatInput extends ConsumerStatefulWidget {

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (!_hasText || !widget.enabled) return;

    final message = widget.controller.text.trim();
    if (message.isEmpty) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Send message
    widget.onSend(message);
  }

  void _handleVoiceButtonTap() {
    if (!widget.enabled) return;

    final voiceState = ref.read(voiceInputProvider);
    final voiceNotifier = ref.read(voiceInputProvider.notifier);

    // Haptic feedback
    HapticFeedback.lightImpact();

    if (voiceState.state == VoiceInputState.idle) {
      // Start listening
      voiceNotifier.startListening();
    } else if (voiceState.state == VoiceInputState.listening) {
      // Stop listening
      voiceNotifier.stopListening();
    }
  }

  Widget _buildListeningAnimation(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: SemanticIcon(
            icon: AppIcons.mic,
            semanticLabel: context.l10n.voiceInputListening,
            size: AppIconSize.medium,
            color: context.colors.onPrimary,
          ),
        );
      },
      onEnd: () {
        // Restart animation if still listening
        if (mounted &&
            ref.read(voiceInputProvider).state == VoiceInputState.listening) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch voice input state
    final voiceState = ref.watch(voiceInputProvider);

    // Auto-fill text field when voice recognition completes
    ref.listen<VoiceInputNotifierState>(
      voiceInputProvider,
      (previous, next) {
        // When processing completes with text, auto-fill the text field
        if (previous?.state == VoiceInputState.processing &&
            next.state == VoiceInputState.idle &&
            next.recognizedText.isNotEmpty) {
          widget.controller.text = next.recognizedText;
        }

        // Show error snackbar if error occurred
        if (next.state == VoiceInputState.error && next.errorMessage != null) {
          SnackBarService.showError(context, next.errorMessage!);
        }
      },
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input field
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: widget.enabled,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.enabled
                      ? context.l10n.typeMessage
                      : context.l10n.aiCoachRespondingHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.colors.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.colors.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.colors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),

            const SizedBox(width: 8),

            // Voice input button
            Material(
              color: voiceState.state == VoiceInputState.listening
                  ? context.colors.primary
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: widget.enabled ? _handleVoiceButtonTap : null,
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: voiceState.state == VoiceInputState.listening
                      ? _buildListeningAnimation(context)
                      : voiceState.state == VoiceInputState.processing
                          ? SizedBox(
                              width: AppIconSize.medium,
                              height: AppIconSize.medium,
                              child: LoadingIndicator(),
                            )
                          : SemanticIcon(
                              icon: AppIcons.mic,
                              semanticLabel: voiceState.state == VoiceInputState.idle
                                  ? context.l10n.voiceInputTap
                                  : voiceState.state == VoiceInputState.error
                                      ? context.l10n.voiceInputError
                                      : context.l10n.voiceInputProcessing,
                              size: AppIconSize.medium,
                              color: widget.enabled
                                  ? context.colors.onSurfaceVariant
                                  : context.colors.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                            ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Material(
              color: _hasText && widget.enabled
                  ? context.colors.primary
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _hasText && widget.enabled ? _handleSend : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: SemanticIcon(
                    icon: AppIcons.send,
                    semanticLabel: 'Send message',
                    size: AppIconSize.medium,
                    color: _hasText && widget.enabled
                        ? context.colors.onPrimary
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
