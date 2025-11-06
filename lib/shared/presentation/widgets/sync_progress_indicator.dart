/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Widget per mostrare il progresso della sincronizzazione batch in real-time.
/// Ascolta lo stato di FirestoreBatchWriter e mostra:
/// - Progress bar lineare
/// - Percentuale completamento
/// - Numero operazioni (es. 5/10)
/// - Tempo trascorso
///
/// **UTILIZZO**:
/// ```dart
/// // In una schermata che usa batch sync
/// class HomeScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('Home'),
///         bottom: SyncProgressIndicator(), // Auto-visible solo durante sync
///       ),
///       // ...
///     );
///   }
/// }
/// ```
///
/// **COMPORTAMENTO**:
/// - Visibile solo quando sync è in progress
/// - Nascosto automaticamente quando sync completa
/// - Animazione smooth del progresso
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';

/// Indicatore di progresso per sincronizzazione batch
///
/// Mostra barra di progresso quando FirestoreBatchWriter sta eseguendo flush.
/// Si nasconde automaticamente quando sync completa.
class SyncProgressIndicator extends ConsumerWidget implements PreferredSizeWidget {

  const SyncProgressIndicator({
    super.key,
    this.height = 56.0,
    this.showDetails = true,
  });
  /// Altezza del widget (usata da AppBar.bottom)
  final double height;

  /// Mostra dettagli extra (ops count, elapsed time)
  final bool showDetails;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(firestoreBatchWriterProvider);

    // Nasconde widget se non c'è sync in progress
    if (!syncState.isInProgress) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: syncState.progress,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          if (showDetails) ...[
            SizedBox(height: 8),

            // Dettagli: Percentuale, Operazioni, Tempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Percentuale + Operazioni
                Text(
                  '${(syncState.progress * 100).toStringAsFixed(0)}% • '
                  '${syncState.completedOperations}/${syncState.totalOperations} ops',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Chunk + Tempo
                Text(
                  'Chunk ${syncState.currentChunk}/${syncState.totalChunks}'
                  '${_formatElapsed(syncState.elapsed)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Formatta tempo trascorso (es. " • 2.5s")
  String _formatElapsed(Duration? elapsed) {
    if (elapsed == null) return '';
    final seconds = elapsed.inMilliseconds / 1000;
    return ' • ${seconds.toStringAsFixed(1)}s';
  }
}

/// Variante compatta per uso in ListTile o Card
///
/// Mostra solo progress bar senza dettagli.
class CompactSyncProgressIndicator extends ConsumerWidget {
  const CompactSyncProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(firestoreBatchWriterProvider);

    if (!syncState.isInProgress) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LinearProgressIndicator(
        value: syncState.progress,
        backgroundColor: context.colors.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          context.colors.primary,
        ),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Overlay fullscreen per operazioni critiche
///
/// Mostra progress dialog modale durante sync importante.
/// Blocca interazione utente fino a completamento.
class SyncProgressDialog extends ConsumerWidget {

  const SyncProgressDialog({
    super.key,
    this.title,
    this.message,
  });
  final String? title;
  final String? message;

  /// Mostra dialog con progress
  ///
  /// ```dart
  /// await SyncProgressDialog.show(
  ///   context,
  ///   title: 'Syncing workouts...',
  ///   message: 'Please wait',
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SyncProgressDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(firestoreBatchWriterProvider);

    // Auto-close dialog quando sync completa
    if (!syncState.isInProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null) ...[
            Text(message!),
            SizedBox(height: 24),
          ],

          // Circular progress
          CircularProgressIndicator(
            value: syncState.progress,
            strokeWidth: 6,
          ),

          SizedBox(height: 16),

          // Percentuale
          Text(
            '${(syncState.progress * 100).toStringAsFixed(0)}%',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          // Dettagli
          Text(
            '${syncState.completedOperations}/${syncState.totalOperations} operations',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
