/// Chat Input Bar Widget
///
/// Input field with send button and attachment options.
/// Supports text, image attachments, and workout links.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';

/// Input bar for composing and sending messages
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onAttachWorkout,
    this.isLoading = false,
  });

  final void Function(String text) onSendText;
  final void Function(File imageFile, String? caption) onSendImage;
  final VoidCallback onAttachWorkout;
  final bool isLoading;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              _buildAttachmentButton(context),

              const SizedBox(width: AppSpacing.xs),

              // Text field
              Expanded(child: _buildTextField(context)),

              const SizedBox(width: AppSpacing.xs),

              // Send button
              _buildSendButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(AppIcons.attachFile, color: context.colors.onSurfaceVariant),
      tooltip: context.l10n.attachFile,
      enabled: !widget.isLoading,
      onSelected: (value) {
        switch (value) {
          case 'camera':
            _pickImage(ImageSource.camera);
          case 'gallery':
            _pickImage(ImageSource.gallery);
          case 'workout':
            widget.onAttachWorkout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(AppIcons.camera, color: context.colors.onSurface),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.takePhoto),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(AppIcons.image, color: context.colors.onSurface),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.chooseFromGallery),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'workout',
          child: Row(
            children: [
              Icon(AppIcons.fitnessCenter, color: context.colors.onSurface),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.shareWorkout),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: !widget.isLoading,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: context.l10n.typeMessage,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const SizedBox(width: 24, height: 24, child: LoadingIndicator()),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _hasText ? context.colors.primary : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          AppIcons.send,
          color: _hasText
              ? context.colors.onPrimary
              : context.colors.onSurfaceVariant,
          size: 20,
        ),
        onPressed: _hasText ? _sendMessage : null,
        tooltip: context.l10n.sendMessage,
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.onSendText(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      // Show caption dialog
      if (mounted) {
        final caption = await _showCaptionDialog();
        widget.onSendImage(file, caption);
      }
    } catch (e) {
      // Handle permission errors, etc.
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> _showCaptionDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addCaption),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: context.l10n.captionOptional),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.skip),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.send),
          ),
        ],
      ),
    );
  }
}
