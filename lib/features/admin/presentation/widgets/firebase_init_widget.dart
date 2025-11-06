/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Widget per gestire l'inizializzazione Firebase degli esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/firebase_init_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class FirebaseInitWidget extends ConsumerWidget {
  const FirebaseInitWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final initState = ref.watch(firebaseInitStateProvider);
    final isInitialized = ref.watch(isFirebaseInitializedProvider);
    final currentVersion = ref.watch(currentFirebaseVersionProvider);
    final collectionStats = ref.watch(collectionStatsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.cloudUpload,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  l10n.firebaseInitialization,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stato corrente
            _buildCurrentStatus(context, l10n, isInitialized, currentVersion, collectionStats),

            const SizedBox(height: 16),

            // Controlli inizializzazione
            _buildInitializationControls(context, l10n, ref, initState),

            const SizedBox(height: 16),

            // Risultati operazione
            _buildOperationResult(context, l10n, initState),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<bool> isInitialized,
    AsyncValue<String?> currentVersion,
    AsyncValue<Map<String, dynamic>> collectionStats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.currentStatus,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Status Firebase
        isInitialized.when(
          data: (initialized) => _StatusTile(
            icon: initialized ? AppIcons.complete : AppIcons.error,
            title: l10n.firebaseStatus,
            subtitle: initialized ? l10n.initialized : l10n.notInitialized,
            isSuccess: initialized,
          ),
          loading: () => _StatusTile(
            icon: AppIcons.hourglassEmpty,
            title: l10n.firebaseStatus,
            subtitle: l10n.checking,
            isSuccess: null,
          ),
          error: (_, __) => _StatusTile(
            icon: AppIcons.error,
            title: l10n.firebaseStatus,
            subtitle: l10n.checkFailed,
            isSuccess: false,
          ),
        ),

        const SizedBox(height: 8),

        // Versione corrente
        currentVersion.when(
          data: (version) => _StatusTile(
            icon: AppIcons.infoIcon,
            title: l10n.currentVersion,
            subtitle: version ?? l10n.notAvailable,
            isSuccess: version != null,
          ),
          loading: () => _StatusTile(
            icon: AppIcons.hourglassEmpty,
            title: l10n.currentVersion,
            subtitle: l10n.loading,
            isSuccess: null,
          ),
          error: (error, __) => _StatusTile(
            icon: AppIcons.error,
            title: l10n.currentVersion,
            subtitle: l10n.loadingError(error.toString()),
            isSuccess: false,
          ),
        ),

        const SizedBox(height: 8),

        // Statistiche collection
        collectionStats.when(
          data: (stats) => _buildStatsDisplay(context, l10n, stats),
          loading: () => _StatusTile(
            icon: AppIcons.hourglassEmpty,
            title: l10n.collectionStats,
            subtitle: l10n.loading,
            isSuccess: null,
          ),
          error: (error, __) => _StatusTile(
            icon: AppIcons.error,
            title: l10n.collectionStats,
            subtitle: l10n.loadingError(error.toString()),
            isSuccess: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsDisplay(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> stats,
  ) {
    if (stats.containsKey('error')) {
      return _StatusTile(
        icon: AppIcons.error,
        title: l10n.collectionStats,
        subtitle: stats['error'].toString(),
        isSuccess: false,
      );
    }

    final exerciseCount = stats['exerciseCount'] ?? 0;
    final hasVersionMetadata = stats['hasVersionMetadata'] ?? false;
    final hasSearchIndex = stats['hasSearchIndex'] ?? false;

    return Column(
      children: [
        _StatusTile(
          icon: AppIcons.workout,
          title: l10n.exerciseCountLabel,
          subtitle: exerciseCount.toString(),
          isSuccess: exerciseCount > 0,
        ),
        const SizedBox(height: 4),
        _StatusTile(
          icon: AppIcons.infoIcon,
          title: l10n.versionMetadata,
          subtitle: hasVersionMetadata ? l10n.present : l10n.missing,
          isSuccess: hasVersionMetadata,
        ),
        const SizedBox(height: 4),
        _StatusTile(
          icon: AppIcons.search,
          title: l10n.searchIndex,
          subtitle: hasSearchIndex ? l10n.present : l10n.missing,
          isSuccess: hasSearchIndex,
        ),
      ],
    );
  }

  Widget _buildInitializationControls(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    FirebaseInitState initState,
  ) {
    final isLoading = initState is FirebaseInitLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.actions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Inizializzazione completa
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _showInitializeDialog(context, l10n, ref),
              icon: const Icon(AppIcons.cloudUpload),
              label: Text(l10n.initializeExercises),
            ),

            // Verifica integrità
            OutlinedButton.icon(
              onPressed: isLoading ? null : () => ref.read(firebaseInitStateProvider.notifier).verifyDataIntegrity(),
              icon: Icon(AppIcons.verified),
              label: Text(l10n.verifyIntegrity),
            ),

            // Fix dati mancanti
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => ref.read(firebaseInitStateProvider.notifier).fixMissingData(),
              icon: Icon(AppIcons.buildCircle),
              label: Text(l10n.fixMissingData),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),

            // Reset stato
            if (initState is! FirebaseInitIdle)
              TextButton.icon(
                onPressed: () => ref.read(firebaseInitStateProvider.notifier).resetState(),
                icon: const Icon(AppIcons.refresh),
                label: Text(l10n.resetStatus),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationResult(
    BuildContext context,
    AppLocalizations l10n,
    FirebaseInitState initState,
  ) {
    return switch (initState) {
      FirebaseInitIdle() => const SizedBox.shrink(),
      FirebaseInitLoading() => Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(l10n.operationInProgress),
              ],
            ),
          ),
        ),
      FirebaseInitSuccess(result: final result) => Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.complete,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      l10n.operationSuccess,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  result.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (result.details != null && result.details!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  ExpansionTile(
                    title: Text(l10n.details),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.formattedStats,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      FirebaseInitError(message: final message) => Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(width: 8),
                    Text(
                      l10n.operationError,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
    };
  }

  void _showInitializeDialog(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => _InitializeDialog(l10n: l10n, ref: ref),
    );
  }
}

class _StatusTile extends StatelessWidget {

  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSuccess,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool? isSuccess;

  @override
  Widget build(BuildContext context) {
    Color? iconColor;
    if (isSuccess == true) {
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (isSuccess == false) {
      iconColor = Theme.of(context).colorScheme.error;
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitializeDialog extends StatefulWidget {

  const _InitializeDialog({
    required this.l10n,
    required this.ref,
  });
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  State<_InitializeDialog> createState() => _InitializeDialogState();
}

class _InitializeDialogState extends State<_InitializeDialog> {
  bool overwriteExisting = false;
  final versionController = TextEditingController();

  @override
  void dispose() {
    versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.initializeExercises),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.l10n.initializeDescription),
          const SizedBox(height: 16),

          CheckboxListTile(
            title: Text(widget.l10n.overwriteExisting),
            subtitle: Text(widget.l10n.overwriteExistingDescription),
            value: overwriteExisting,
            onChanged: (value) => setState(() => overwriteExisting = value ?? false),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: versionController,
            decoration: InputDecoration(
              labelText: widget.l10n.versionOptional,
              hintText: '1.0.0',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.ref.read(firebaseInitStateProvider.notifier).initializeExercises(
              overwriteExisting: overwriteExisting,
              specificVersion: versionController.text.isEmpty ? null : versionController.text,
            );
          },
          child: Text(widget.l10n.initialize),
        ),
      ],
    );
  }
}
