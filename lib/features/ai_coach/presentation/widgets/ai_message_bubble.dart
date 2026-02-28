/// AI Message Bubble Widget
///
/// Displays a single message in the chat interface.
/// Uses DecoratedBox for performance, supports Markdown rendering.
/// Shows interactive suggestion chips when exercise not found.
/// Supports copy and clickable exercise links.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Message bubble widget with enhanced UX features
class AIMessageBubble extends StatefulWidget {
  const AIMessageBubble({
    super.key,
    required this.message,
    required this.isFromUser,
    this.onSuggestionTap,
    this.animate = false,
    this.showTimestamp = true,
  });

  final AIMessage message;
  final bool isFromUser;
  final void Function(String)? onSuggestionTap;

  /// Whether to animate the bubble entrance (for newly added messages)
  final bool animate;

  /// Whether to show the timestamp below the bubble
  final bool showTimestamp;

  @override
  State<AIMessageBubble> createState() => _AIMessageBubbleState();
}

class _AIMessageBubbleState extends State<AIMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  static final RegExp _inlineHeatmapPattern = RegExp(
    r'\[\[MUSCLE_HEATMAP:(\{[\s\S]*?\})\]\]',
  );
  static final RegExp _inlineTemplateActionPattern = RegExp(
    r'\[\[TEMPLATE_ACTION_CARD:([\s\S]*?)\]\]',
  );

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    if (widget.animate) {
      _entryController.forward();
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    final plainContent = _stripInlineMarkers(widget.message.content);
    Clipboard.setData(ClipboardData(text: plainContent));
    HapticFeedback.lightImpact();
    SnackBarService.showSuccess(context, context.l10n.textCopied);
  }

  void _handleLinkTap(String text, String? href, String title) {
    // Handle exercise links - format: exercise://exerciseName
    if (href != null && href.startsWith('exercise://')) {
      final exerciseName = href.replaceFirst('exercise://', '');
      _navigateToExerciseAnalytics(exerciseName);
      return;
    }

    // Handle regular links
    if (href != null) {
      // Could open in browser, for now just copy
      Clipboard.setData(ClipboardData(text: href));
      SnackBarService.showInfo(context, 'Link copiato');
    }
  }

  void _navigateToExerciseAnalytics(String exerciseName) {
    context.pushNamed(
      AppRoutes.analyticsExerciseDetailName,
      pathParameters: {'exerciseName': Uri.encodeComponent(exerciseName)},
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'ora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m fa';
    } else if (diff.inDays < 1) {
      return DateFormat.Hm().format(timestamp);
    } else {
      return DateFormat.MMMd().format(timestamp);
    }
  }

  /// Process content to make exercise names clickable
  /// Looks for patterns like **Esercizio** or `esercizio` and makes them links
  String _processContentForExerciseLinks(String content) {
    // Common exercise patterns in AI responses
    // Matches: **Exercise Name** or `Exercise Name`
    final exercisePattern = RegExp(
      r'\*\*([A-Za-zÀ-ÿ\s]+(?:\s+[A-Za-zÀ-ÿ]+)*)\*\*|`([A-Za-zÀ-ÿ\s]+)`',
    );

    // Known exercise keywords to filter
    const exerciseKeywords = [
      'panca',
      'squat',
      'stacco',
      'curl',
      'press',
      'rematore',
      'alzate',
      'affondi',
      'leg',
      'dip',
      'pull',
      'push',
      'fly',
      'crunch',
      'plank',
      'deadlift',
      'bench',
      'row',
      'extension',
      'military',
      'shoulder',
      'tricep',
      'bicep',
      'lat',
      'chest',
      'back',
    ];

    return content.replaceAllMapped(exercisePattern, (match) {
      final exerciseName = match.group(1) ?? match.group(2) ?? '';
      final lowerName = exerciseName.toLowerCase();

      // Check if it looks like an exercise
      final isExercise = exerciseKeywords.any((kw) => lowerName.contains(kw));

      if (isExercise && exerciseName.length > 3) {
        // Convert to clickable link
        return '[**$exerciseName**](exercise://$exerciseName)';
      }

      // Return original if not an exercise
      return match.group(0) ?? '';
    });
  }

  /// Remove any leaked JSON tool calls from message content
  String _filterToolCallArtifacts(String content) {
    var filtered = content;

    // Remove "erta raa" artifacts
    filtered = filtered.replaceAll(RegExp(r'erta\s+raa[^}]*'), '').trim();

    // Remove JSON blocks (both code fences and plain JSON)
    filtered = filtered
        .replaceAll(RegExp(r'```json[\s\S]*?```', caseSensitive: false), '')
        .trim();
    filtered = filtered
        .replaceAll(
          RegExp(
            r'\{\s*"(?:name|type|function|parameters)"[\s\S]*?\}',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Collapse excessive whitespace
    filtered = filtered.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return filtered;
  }

  _InlineHeatmapData? _extractInlineHeatmap(String content) {
    final match = _inlineHeatmapPattern.firstMatch(content);
    if (match == null) return null;

    final marker = match.group(0);
    final jsonPayload = match.group(1);
    if (marker == null || jsonPayload == null) return null;

    try {
      final decoded = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final rawValues = decoded['values'];
      if (rawValues is! Map) return null;

      final values = <String, double>{};
      for (final entry in rawValues.entries) {
        final parsed = double.tryParse(entry.value.toString());
        if (parsed != null && parsed > 0) {
          values[entry.key.toString()] = parsed.clamp(0.0, 100.0);
        }
      }

      if (values.isEmpty) return null;

      final cleaned = content.replaceFirst(marker, '').trim();
      return _InlineHeatmapData(
        cleanedContent: cleaned,
        values: values,
        underTrainedLabel: decoded['underTrained'] as String?,
        overTrainedLabel: decoded['overTrained'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  _InlineTemplateActionData? _extractInlineTemplateAction(String content) {
    final match = _inlineTemplateActionPattern.firstMatch(content);
    if (match == null) return null;

    final marker = match.group(0);
    final jsonPayload = match.group(1);
    if (marker == null || jsonPayload == null) return null;

    try {
      final decoded = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final title = (decoded['title'] as String?)?.trim();
      final subtitle = (decoded['subtitle'] as String?)?.trim();
      final imageUrl = (decoded['imageUrl'] as String?)?.trim();
      final selectionHint = (decoded['selectionHint'] as String?)?.trim();

      final actionsRaw = decoded['actions'];
      final actions = <_InlineTemplateActionButton>[];
      if (actionsRaw is List) {
        for (final item in actionsRaw) {
          if (item is! Map) continue;
          final actionMap = item.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          final label = (actionMap['label'] as String?)?.trim();
          final command = (actionMap['command'] as String?)?.trim();
          final actionType = (actionMap['actionType'] as String?)?.trim();
          final style = (actionMap['style'] as String?)?.trim();
          if (label == null ||
              label.isEmpty ||
              command == null ||
              command.isEmpty) {
            continue;
          }
          actions.add(
            _InlineTemplateActionButton(
              label: label,
              command: command,
              actionType: actionType,
              style: style,
            ),
          );
        }
      }
      final alternativesRaw = decoded['alternatives'];
      final alternatives = <_InlineTemplateAlternative>[];
      if (alternativesRaw is List) {
        for (final item in alternativesRaw) {
          if (item is! Map) continue;
          final altMap = item.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          final name = (altMap['name'] as String?)?.trim();
          final commandRaw = (altMap['command'] as String?)?.trim();
          final image = (altMap['imageUrl'] as String?)?.trim();
          final musclesRaw = altMap['muscles'];
          final muscles = musclesRaw is List
              ? musclesRaw.map((e) => e.toString()).toList()
              : const <String>[];
          if (name == null || name.isEmpty) {
            continue;
          }
          final command = (commandRaw == null || commandRaw.isEmpty)
              ? name
              : commandRaw;
          alternatives.add(
            _InlineTemplateAlternative(
              name: name,
              command: command,
              imageUrl: image != null && image.isNotEmpty ? image : null,
              muscles: muscles.take(3).toList(),
            ),
          );
        }
      }

      final cleaned = content.replaceFirst(marker, '').trim();
      return _InlineTemplateActionData(
        cleanedContent: cleaned,
        title: title ?? 'Azione template',
        subtitle: subtitle,
        imageUrl: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
        selectionHint:
            alternatives.isNotEmpty &&
                selectionHint != null &&
                selectionHint.isNotEmpty
            ? selectionHint
            : null,
        alternatives: alternatives,
        actions: actions,
      );
    } catch (_) {
      return null;
    }
  }

  String _stripInlineMarkers(String content) {
    return content
        .replaceAll(RegExp(r'\[\[MUSCLE_HEATMAP:(\{[\s\S]*?\})\]\]'), '')
        .replaceAll(RegExp(r'\[\[TEMPLATE_ACTION_CARD:[\s\S]*?\]\]'), '')
        .trim();
  }

  Widget _buildInlineHeatmapCard(
    BuildContext context,
    _InlineHeatmapData inlineHeatmap,
  ) {
    final subtitle = switch ((
      inlineHeatmap.overTrainedLabel,
      inlineHeatmap.underTrainedLabel,
    )) {
      (final over?, final under?) =>
        'Più stimolato: $over • Meno stimolato: $under',
      (final over?, null) => 'Più stimolato: $over',
      (null, final under?) => 'Meno stimolato: $under',
      _ => 'Distribuzione volume per gruppi muscolari',
    };

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bilanciamento muscolare',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 280,
            child: ProfessionalBodyHeatmap(
              heatValues: MuscleHeatValues(inlineHeatmap.values),
            ),
          ),
        ],
      ),
    );
  }

  IconData _actionIconFor(String? actionType) {
    switch (actionType?.toLowerCase()) {
      case 'add':
        return AppIcons.add;
      case 'confirm_add':
        return AppIcons.addCircleOutline;
      case 'replace':
        return AppIcons.refresh;
      case 'confirm_replace':
        return AppIcons.check;
      case 'remove':
        return AppIcons.remove;
      case 'confirm_remove':
        return AppIcons.check;
      case 'link':
        return AppIcons.settings;
      default:
        return AppIcons.edit;
    }
  }

  String _actionReadableLabel(String label, String? actionType) {
    final normalized = label.trim().toLowerCase();
    if (normalized == 'add') return 'Conferma aggiunta';
    if (normalized == 'replace') return 'Sostituisci esercizio';
    if (normalized == 'remove') return 'Rimuovi esercizio';
    if (actionType == 'add' && normalized == 'applica') {
      return 'Conferma aggiunta';
    }
    return label;
  }

  Widget _buildInlineTemplateActionCard(
    BuildContext context,
    _InlineTemplateActionData card,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (card.subtitle != null && card.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              card.subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          if (card.selectionHint != null && card.selectionHint!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              card.selectionHint!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (card.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                card.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
                errorBuilder: (context, _, _) => _buildImageFallback(context),
              ),
            )
          else if (card.alternatives.isEmpty)
            _buildImageFallback(context)
          else
            _buildImageFallback(context, compact: true),
          if (card.alternatives.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Alternative disponibili',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildAlternativeExercisesCarousel(context, card.alternatives),
          ],
          if (card.actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.actions.map((action) {
                final isPrimary = action.style == 'primary';
                final isDanger = action.style == 'danger';

                final chipLabel = _actionReadableLabel(
                  action.label,
                  action.actionType,
                );
                if (isPrimary) {
                  return ActionChip(
                    avatar: Icon(_actionIconFor(action.actionType), size: 16),
                    label: Text(chipLabel),
                    backgroundColor: context.colors.secondaryContainer,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onSuggestionTap?.call(action.command);
                    },
                  );
                }

                if (isDanger) {
                  return ActionChip(
                    avatar: Icon(
                      _actionIconFor(action.actionType),
                      size: 16,
                      color: context.colors.error,
                    ),
                    label: Text(chipLabel),
                    side: BorderSide(color: context.colors.error),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onSuggestionTap?.call(action.command);
                    },
                  );
                }

                return ActionChip(
                  avatar: Icon(_actionIconFor(action.actionType), size: 16),
                  label: Text(chipLabel),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSuggestionTap?.call(action.command);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativeExercisesCarousel(
    BuildContext context,
    List<_InlineTemplateAlternative> alternatives,
  ) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: alternatives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final alternative = alternatives[index];
          return ActionChip(
            avatar: alternative.imageUrl != null
                ? CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(alternative.imageUrl!),
                    onBackgroundImageError: (_, __) {},
                  )
                : Icon(
                    AppIcons.image,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
            label: Text(
              alternative.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSuggestionTap?.call(alternative.command);
            },
          );
        },
      ),
    );
  }

  Widget _buildImageFallback(BuildContext context, {bool compact = false}) {
    return Container(
      width: double.infinity,
      height: compact ? 52 : 120,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: compact
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.image, color: context.colors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Immagine non disponibile',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.template,
                    color: context.colors.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Anteprima esercizio',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var processedContent = widget.isFromUser
        ? widget.message.content
        : _processContentForExerciseLinks(widget.message.content);

    // Extra safety: filter tool call artifacts from AI messages
    if (!widget.isFromUser) {
      processedContent = _filterToolCallArtifacts(processedContent);
    }
    _InlineTemplateActionData? inlineTemplateAction;
    if (!widget.isFromUser) {
      final extractedAction = _extractInlineTemplateAction(processedContent);
      if (extractedAction != null) {
        inlineTemplateAction = extractedAction;
        processedContent = extractedAction.cleanedContent;
      }
    }

    _InlineHeatmapData? inlineHeatmap;
    if (!widget.isFromUser) {
      final extracted = _extractInlineHeatmap(processedContent);
      if (extracted != null) {
        inlineHeatmap = extracted;
        processedContent = extracted.cleanedContent;
      }
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: widget.isFromUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Avatar (only for AI messages)
            if (!widget.isFromUser) ...[
              _buildAvatar(context),
              const SizedBox(width: AppSpacing.xs),
            ],

            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: widget.isFromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Message bubble
                    DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.isFromUser
                          ? context.colors.primary
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(widget.isFromUser ? 16 : 4),
                        bottomRight: Radius.circular(
                          widget.isFromUser ? 4 : 16,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: MarkdownBody(
                        data: processedContent,
                        onTapLink: _handleLinkTap,
                        styleSheet: _buildMarkdownStyleSheet(context),
                      ),
                    ),
                  ),
                  if (!widget.isFromUser && inlineHeatmap != null)
                    _buildInlineHeatmapCard(context, inlineHeatmap),
                  if (!widget.isFromUser && inlineTemplateAction != null)
                    _buildInlineTemplateActionCard(
                      context,
                      inlineTemplateAction,
                    ),

                  // Timestamp (shown only when there's a >5min gap)
                  if (widget.showTimestamp)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.xxs,
                        left: AppSpacing.xs,
                        right: AppSpacing.xs,
                      ),
                      child: Text(
                        _formatTimestamp(widget.message.timestamp),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ),

                  // Quick actions row (always visible for AI)
                  if (!widget.isFromUser) _buildQuickActions(context),

                  // Suggestion chips - with different style for disambiguation
                  if (!widget.isFromUser &&
                      widget.message.suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.message.suggestions.map((suggestion) {
                          if (widget.message.isDisambiguation) {
                            return FilledButton.tonal(
                              onPressed: () =>
                                  widget.onSuggestionTap?.call(suggestion),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(suggestion),
                            );
                          }
                          return ActionChip(
                            label: Text(suggestion),
                            onPressed: () =>
                                widget.onSuggestionTap?.call(suggestion),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final textColor = widget.isFromUser
        ? context.colors.onPrimary
        : context.colors.onSurface;
    final linkColor = widget.isFromUser
        ? context.colors.onPrimary
        : context.colors.primary;
    final codeBackground = widget.isFromUser
        ? context.colors.onPrimary.withValues(alpha: 0.15)
        : context.colors.surfaceContainerHighest;

    return MarkdownStyleSheet(
      p: context.textTheme.bodyMedium?.copyWith(color: textColor),
      a: context.textTheme.bodyMedium?.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
        decorationColor: linkColor,
      ),
      strong: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: context.textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      h1: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      h2: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      h3: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h4: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h5: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h6: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      code: context.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        color: textColor,
        backgroundColor: codeBackground,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      codeblockPadding: const EdgeInsets.all(AppSpacing.sm),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: linkColor,
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: AppSpacing.sm),
      listBullet: context.textTheme.bodyMedium?.copyWith(color: textColor),
      tableHead: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      tableBody: context.textTheme.bodyMedium?.copyWith(color: textColor),
      tableBorder: TableBorder.all(
        color: textColor.withValues(alpha: 0.3),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SemanticIcon(
          icon: AppIcons.smartToy,
          semanticLabel: 'AI Coach',
          size: AppIconSize.small,
          color: context.colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy button
          _ActionButton(
            icon: AppIcons.copy,
            tooltip: context.l10n.copy,
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }

}

class _InlineHeatmapData {
  const _InlineHeatmapData({
    required this.cleanedContent,
    required this.values,
    this.underTrainedLabel,
    this.overTrainedLabel,
  });

  final String cleanedContent;
  final Map<String, double> values;
  final String? underTrainedLabel;
  final String? overTrainedLabel;
}

class _InlineTemplateActionData {
  const _InlineTemplateActionData({
    required this.cleanedContent,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.selectionHint,
    this.alternatives = const [],
    required this.actions,
  });

  final String cleanedContent;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? selectionHint;
  final List<_InlineTemplateAlternative> alternatives;
  final List<_InlineTemplateActionButton> actions;
}

class _InlineTemplateActionButton {
  const _InlineTemplateActionButton({
    required this.label,
    required this.command,
    this.actionType,
    this.style,
  });

  final String label;
  final String command;
  final String? actionType;
  final String? style;
}

class _InlineTemplateAlternative {
  const _InlineTemplateAlternative({
    required this.name,
    required this.command,
    this.imageUrl,
    this.muscles = const [],
  });

  final String name;
  final String command;
  final String? imageUrl;
  final List<String> muscles;
}

/// Small action button for message actions
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
