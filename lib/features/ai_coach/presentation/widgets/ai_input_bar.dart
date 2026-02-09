/// AI Input Bar Widget
///
/// Text input field and send button for AI Coach chat.
/// Simple, focused on core functionality.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Input bar widget
class AIInputBar extends StatefulWidget {
  const AIInputBar({
    super.key,
    required this.onSend,
    this.onTextChanged,
    this.isLoading = false,
  });

  final void Function(String text) onSend;

  /// Called when input text changes (for smart suggestions)
  final void Function(String text)? onTextChanged;

  final bool isLoading;

  @override
  State<AIInputBar> createState() => _AIInputBarState();
}

class _AIInputBarState extends State<AIInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    // Notify parent for smart suggestions
    widget.onTextChanged?.call(_controller.text);
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isLoading,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.l10n.aiCoachInputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: _hasText && !widget.isLoading ? _handleSend : null,
              icon: Icon(
                AppIcons.send,
                color: _hasText && !widget.isLoading
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
