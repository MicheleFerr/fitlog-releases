import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// 🔄 Widget che mostra lo stato di sincronizzazione dei template in background
///
/// Visualizza un banner informativo quando ci sono template in attesa di sincronizzazione
/// con il cloud. Mostra il numero di template, i tentativi e il tempo al prossimo retry.
class PendingTemplateSyncIndicator extends ConsumerWidget {
  const PendingTemplateSyncIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingSyncAsync = ref.watch(pendingTemplateSyncProvider);

    return pendingSyncAsync.when(
      data: (pendingTemplates) {
        if (pendingTemplates.isEmpty) {
          return const SizedBox.shrink();
        }

        // Mostra un banner per ogni template in sync
        // Se ci sono troppi, mostra solo un riepilogo
        if (pendingTemplates.length == 1) {
          return _buildSyncBanner(context, pendingTemplates.first);
        }

        // Se ci sono più di uno, mostra un riepilogo
        return _buildMultipleSyncBanner(context, pendingTemplates);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) {
        // Silenziosamente ignora gli errori di sync tracking
        return const SizedBox.shrink();
      },
    );
  }

  /// Crea un banner per un singolo template in sync
  Widget _buildSyncBanner(
    BuildContext context,
    PendingTemplateSyncInfo syncInfo,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icona e titolo
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.cloudSync,
                semanticLabel: 'Sync',
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template in sincronizzazione',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      syncInfo.templateName,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: syncInfo.retryProgress / 100,
              minHeight: 4,
              backgroundColor: context.colors.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                syncInfo.attemptCount >= syncInfo.maxAttempts
                    ? context.colors.error
                    : context.colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status text
          Text(
            syncInfo.statusMessage,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: syncInfo.attemptCount >= syncInfo.maxAttempts
                  ? context.colors.error
                  : context.colors.onSurfaceVariant,
            ),
          ),

          // Error message if failed
          if (syncInfo.lastError != null) ...[
            const SizedBox(height: 8),
            Text(
              'Errore: ${syncInfo.lastError}',
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: context.colors.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Crea un banner per più template in sync
  Widget _buildMultipleSyncBanner(
    BuildContext context,
    List<PendingTemplateSyncInfo> syncInfos,
  ) {
    final failedCount =
        syncInfos.where((s) => s.attemptCount >= s.maxAttempts).length;
    final syncingCount = syncInfos.length - failedCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: failedCount > 0
            ? context.colors.errorContainer.withValues(alpha: 0.7)
            : context.colors.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (failedCount > 0
                  ? context.colors.error
                  : context.colors.primary)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.cloudSync,
                semanticLabel: 'Sync',
                size: AppIconSize.medium,
                color: failedCount > 0
                    ? context.colors.error
                    : context.colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${syncInfos.length} template in sincronizzazione',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: failedCount > 0
                            ? context.colors.error
                            : context.colors.primary,
                      ),
                    ),
                    if (syncingCount > 0 && failedCount > 0)
                      Text(
                        '$syncingCount sincronizzazione, $failedCount non riusciti',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🔄 Widget per mostrare lo stato di sync in una lista di template
///
/// Da usare accanto a ogni template nella lista per indicare se è in attesa
/// di sincronizzazione con il cloud.
class TemplateSyncStatusBadge extends ConsumerWidget {
  const TemplateSyncStatusBadge({
    required this.templateId,
    Key? key,
  }) : super(key: key);

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingSyncAsync = ref.watch(pendingTemplateSyncProvider);

    return pendingSyncAsync.when(
      data: (pendingTemplates) {
        // Cerca se questo template è in sync
        final syncInfo = pendingTemplates
            .firstWhere((s) => s.templateId == templateId, orElse: () => null as dynamic) as PendingTemplateSyncInfo?;

        if (syncInfo == null) {
          return const SizedBox.shrink();
        }

        // Mostra un badge con lo stato
        final isError = syncInfo.attemptCount >= syncInfo.maxAttempts;

        return Tooltip(
          message: syncInfo.statusMessage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isError
                  ? context.colors.errorContainer.withValues(alpha: 0.5)
                  : context.colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    value: syncInfo.retryProgress / 100,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isError
                          ? context.colors.error
                          : context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${syncInfo.attemptCount}/${syncInfo.maxAttempts}',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isError
                        ? context.colors.error
                        : context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
