/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Chat Input - Message input field with send button
///
/// **Features**:
/// - Multi-line text input
/// - Send button (enabled only when text is not empty)
/// - Haptic feedback on send
/// - Disabled state during streaming
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Chat input widget
class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
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

  @override
  Widget build(BuildContext context) {
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
