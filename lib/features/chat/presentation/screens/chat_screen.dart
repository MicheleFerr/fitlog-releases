/// Chat Screen
///
/// Real-time messaging interface between coach and athlete.
/// Supports text messages, images, and workout links.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/widgets/message_bubble.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// Main chat interface for messaging
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening the chat
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await ref.read(chatActionsProvider).markAllAsRead(widget.conversationId);
    } catch (_) {
      // Ignore errors when marking as read
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final conversationAsync = ref.watch(
      conversationProvider(widget.conversationId),
    );
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: _buildAppBar(context, conversationAsync, currentUserId),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) =>
                  _buildMessagesList(context, messages, currentUserId),
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    context.l10n.errorLoadingMessages,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),

          // Input bar
          ChatInputBar(
            isLoading: _isLoading,
            onSendText: _sendTextMessage,
            onSendImage: _sendImageMessage,
            onAttachWorkout: _showWorkoutPicker,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<ChatConversation?> conversationAsync,
    String currentUserId,
  ) {
    return AppBar(
      title: conversationAsync.when(
        data: (conversation) {
          if (conversation == null) return const SizedBox.shrink();
          final otherName = conversation.otherParticipantName(currentUserId);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherName,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                conversation.isCoach(currentUserId)
                    ? context.l10n.athlete
                    : context.l10n.coach,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    List<ChatMessage> messages,
    String currentUserId,
  ) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.chatBubbleOutline,
                size: 64,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.startConversation,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Most recent at bottom
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Messages are in reverse order (newest first)
        final message = messages[messages.length - 1 - index];
        final isMe = message.senderId == currentUserId;

        // Check if we need to show date separator
        final showDateSeparator = _shouldShowDateSeparator(
          messages,
          messages.length - 1 - index,
        );

        return Column(
          children: [
            if (showDateSeparator)
              _buildDateSeparator(context, message.createdAt),
            MessageBubble(
              message: message,
              isMe: isMe,
              onDelete: isMe ? () => _deleteMessage(message.id) : null,
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final currentDate = messages[index].createdAt;
    final previousDate = messages[index - 1].createdAt;

    return !_isSameDay(currentDate, previousDate);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String text;
    if (messageDate == today) {
      text = context.l10n.today;
    } else if (messageDate == yesterday) {
      text = context.l10n.yesterday;
    } else {
      text = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              text,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(chatActionsProvider)
          .sendTextMessage(
            conversationId: widget.conversationId,
            text: text.trim(),
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.errorSendingMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendImageMessage(File imageFile, String? caption) async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(chatActionsProvider)
          .sendImageMessage(
            conversationId: widget.conversationId,
            imageFile: imageFile,
            caption: caption,
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.errorSendingImage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendWorkoutLink(
    WorkoutHistoryDetail workout,
    String? comment,
  ) async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(chatActionsProvider)
          .sendWorkoutLink(
            conversationId: widget.conversationId,
            workout: workout,
            comment: comment,
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.errorSendingWorkout);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await ref
          .read(chatActionsProvider)
          .deleteMessage(
            conversationId: widget.conversationId,
            messageId: messageId,
          );
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.errorDeletingMessage);
      }
    }
  }

  void _showWorkoutPicker() {
    // TODO: Implement workout picker sheet
    // For now, show a placeholder
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _WorkoutPickerSheet(
        onSelect: (workout, comment) {
          Navigator.pop(context);
          _sendWorkoutLink(workout, comment);
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Since we use reverse: true, 0 is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

/// Bottom sheet for selecting a workout to share
class _WorkoutPickerSheet extends ConsumerWidget {
  const _WorkoutPickerSheet({required this.onSelect});

  final void Function(WorkoutHistoryDetail workout, String? comment) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                context.l10n.shareWorkout,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Workouts list
            Expanded(
              child: workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Show last 20 workouts
                  final recentWorkouts = workouts.take(20).toList();

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: recentWorkouts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final workout = recentWorkouts[index];
                      return _WorkoutTile(
                        workout: workout,
                        onTap: () => onSelect(workout, null),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (_, __) => _buildEmptyState(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.fitnessCenter,
            size: 64,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.noWorkoutsYet,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile for displaying a workout in the picker
class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.workout, required this.onTap});

  final WorkoutHistoryDetail workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.MMMd(context.l10n.localeName);
    final timeFormatter = DateFormat.Hm(context.l10n.localeName);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          AppIcons.fitnessCenter,
          color: context.colors.onPrimaryContainer,
        ),
      ),
      title: Text(
        workout.name,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${dateFormatter.format(workout.completedAt)} • '
        '${timeFormatter.format(workout.completedAt)} • '
        '${workout.duration.inMinutes} min',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(AppIcons.send, color: context.colors.primary, size: 20),
    );
  }
}
