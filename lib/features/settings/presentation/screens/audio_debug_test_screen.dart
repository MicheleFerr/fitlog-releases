import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/settings/domain/services/audio_debug_test_service.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/audio_debug_test_provider.dart';

/// 🔬 Audio Debug Test Screen
/// Automated testing UI for timer audio bugs
/// Accessible from Settings → Admin
class AudioDebugTestScreen extends ConsumerStatefulWidget {
  const AudioDebugTestScreen({super.key});

  @override
  ConsumerState<AudioDebugTestScreen> createState() =>
      _AudioDebugTestScreenState();
}

class _AudioDebugTestScreenState extends ConsumerState<AudioDebugTestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(AppIcons.bugReport, size: 20),
            const SizedBox(width: 8),
            Text(context.l10n.audioDebugTests),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.quickTests),
            Tab(text: context.l10n.fullTests),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_QuickTestsTab(), _FullTestsTab()],
      ),
    );
  }
}

// Quick Tests Tab (3 tests, 30 minutes)
class _QuickTestsTab extends ConsumerWidget {
  const _QuickTestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioDebugTestProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          _InfoCard(
            title: context.l10n.quickTestsTitle,
            description: context.l10n.quickTestsDescription,
            duration: '~30 ${context.l10n.minutes}',
            testCount: '3',
            icon: AppIcons.timer,
            color: context.colors.primary,
          ),

          const SizedBox(height: 24),

          // Test list
          _TestCaseCard(
            testId: 'A',
            title: 'Test A: Foreground Timer (30s)',
            description: context.l10n.testADescription,
            icon: AppIcons.phone,
            expectedResult: context.l10n.alwaysWorks,
            result: state.quickResults?.tests.firstWhere(
              (t) => t.testId == 'A',
              orElse: () => _emptyResult('A'),
            ),
          ),

          const SizedBox(height: 12),

          _TestCaseCard(
            testId: 'B',
            title: 'Test B: Background NO LA (90s)',
            description: context.l10n.testBDescription,
            icon: AppIcons.darkMode,
            expectedResult: context.l10n.sixtyPercentSuccess,
            result: state.quickResults?.tests.firstWhere(
              (t) => t.testId == 'B',
              orElse: () => _emptyResult('B'),
            ),
          ),

          const SizedBox(height: 12),

          _TestCaseCard(
            testId: 'C',
            title: 'Test C: Background WITH LA (90s)',
            description: context.l10n.testCDescription,
            icon: AppIcons.notifications,
            expectedResult: context.l10n.consistentlyFails,
            isHighlighted: true,
            result: state.quickResults?.tests.firstWhere(
              (t) => t.testId == 'C',
              orElse: () => _emptyResult('C'),
            ),
          ),

          const SizedBox(height: 24),

          // Progress indicator
          if (state.isRunning && state.currentProgress != null)
            _ProgressCard(progress: state.currentProgress!),

          if (state.isRunning && state.currentProgress != null)
            const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                // Accessibility: Quick tests button with semantic label
                child: Semantics(
                  label: state.isRunning
                      ? context.l10n.testing
                      : context.l10n.startQuickTests,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: state.isRunning
                        ? null
                        : () => ref
                              .read(audioDebugTestProvider.notifier)
                              .runQuickTests(),
                    icon: Icon(
                      state.isRunning ? AppIcons.hourglassEmpty : AppIcons.play,
                    ),
                    label: Text(
                      state.isRunning
                          ? context.l10n.testing
                          : context.l10n.startQuickTests,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
              if (state.quickResults != null) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () => _showResults(context, ref, isQuick: true),
                  icon: const Icon(AppIcons.list),
                  tooltip: context.l10n.viewResults,
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _exportResults(context, ref, isQuick: true),
                  icon: const Icon(AppIcons.share),
                  tooltip: context.l10n.exportResults,
                ),
              ],
            ],
          ),

          if (state.quickResults != null) ...[
            const SizedBox(height: 24),
            _ResultsSummaryCard(results: state.quickResults!),
          ],
        ],
      ),
    );
  }

  TestResult _emptyResult(String id) => TestResult(
    testId: id,
    testName: '',
    duration: Duration.zero,
    expectedSounds: 1,
    actualSounds: 0,
    traceId: '',
    status: TestStatus.pending,
    appState: AppState.foreground,
    liveActivityEnabled: false,
    startTime: DateTime.now(),
  );

  void _showResults(
    BuildContext context,
    WidgetRef ref, {
    required bool isQuick,
  }) {
    final results = isQuick
        ? ref.read(audioDebugTestProvider).quickResults
        : ref.read(audioDebugTestProvider).fullResults;

    if (results == null) return;

    showDialog(
      context: context,
      builder: (context) => _ResultsDialog(results: results),
    );
  }

  void _exportResults(
    BuildContext context,
    WidgetRef ref, {
    required bool isQuick,
  }) {
    final results = isQuick
        ? ref.read(audioDebugTestProvider).quickResults
        : ref.read(audioDebugTestProvider).fullResults;

    if (results == null) return;

    Share.share(results.summary, subject: 'FitLog Audio Debug Test Results');
  }
}

// Full Tests Tab (40 tests, 2-3 hours)
class _FullTestsTab extends ConsumerWidget {
  const _FullTestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioDebugTestProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          _InfoCard(
            title: context.l10n.fullTestMatrix,
            description: context.l10n.fullTestsDescription,
            duration: '2-3 ${context.l10n.hours}',
            testCount: '40',
            icon: AppIcons.checklist,
            color: context.colors.error,
          ),

          const SizedBox(height: 24),

          // Warning card
          Card(
            color: context.colors.warning.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppIcons.warning, color: context.colors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.fullTestsWarning,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Test matrix preview
          Text(
            context.l10n.testMatrix,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _TestMatrixPreview(),

          const SizedBox(height: 24),

          // Progress indicator
          if (state.isRunning && state.currentProgress != null)
            _ProgressCard(progress: state.currentProgress!),

          if (state.isRunning && state.currentProgress != null)
            const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                // Accessibility: Full tests button with semantic label
                child: Semantics(
                  label: state.isRunning
                      ? context.l10n.testing
                      : context.l10n.startFullTests,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: state.isRunning
                        ? null
                        : () => ref
                              .read(audioDebugTestProvider.notifier)
                              .runFullTests(),
                    icon: Icon(
                      state.isRunning ? AppIcons.hourglassEmpty : AppIcons.play,
                    ),
                    label: Text(
                      state.isRunning
                          ? context.l10n.testing
                          : context.l10n.startFullTests,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: context.colors.error,
                      foregroundColor: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
              if (state.fullResults != null) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () => const _QuickTestsTab()._showResults(
                    context,
                    ref,
                    isQuick: false,
                  ),
                  icon: const Icon(AppIcons.list),
                  tooltip: context.l10n.viewResults,
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => const _QuickTestsTab()._exportResults(
                    context,
                    ref,
                    isQuick: false,
                  ),
                  icon: const Icon(AppIcons.share),
                  tooltip: context.l10n.exportResults,
                ),
              ],
            ],
          ),

          if (state.fullResults != null) ...[
            const SizedBox(height: 24),
            _ResultsSummaryCard(results: state.fullResults!),
          ],
        ],
      ),
    );
  }
}

// Widgets

class _InfoCard extends StatelessWidget {

  const _InfoCard({
    required this.title,
    required this.description,
    required this.duration,
    required this.testCount,
    required this.icon,
    required this.color,
  });
  final String title;
  final String description;
  final String duration;
  final String testCount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: context.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(icon: AppIcons.timer, label: duration, color: color),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: AppIcons.checklist,
                  label: '$testCount tests',
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestCaseCard extends StatelessWidget {

  const _TestCaseCard({
    required this.testId,
    required this.title,
    required this.description,
    required this.icon,
    required this.expectedResult,
    this.isHighlighted = false,
    this.result,
  });
  final String testId;
  final String title;
  final String description;
  final IconData icon;
  final String expectedResult;
  final bool isHighlighted;
  final TestResult? result;

  @override
  Widget build(BuildContext context) {
    final hasResult = result != null && result!.status == TestStatus.completed;

    return Card(
      elevation: isHighlighted ? 4 : 1,
      color: isHighlighted ? context.colors.error.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasResult) _ResultBadge(result: result!),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  AppIcons.gpsFixed,
                  size: 14,
                  color: context.colors.onSurface87,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expected: $expectedResult',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            if (hasResult) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Actual: ${result!.actualSounds}x sound',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  if (result!.traceId.isNotEmpty)
                    Text(
                      'Trace: ${result!.traceId.substring(0, 8)}...',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: context.colors.onSurface87,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {

  const _ResultBadge({required this.result});
  final TestResult result;

  @override
  Widget build(BuildContext context) {
    final isPassed = result.isPassed;
    final icon = isPassed ? AppIcons.checkCircle : AppIcons.error;
    final color = isPassed ? context.colors.success : context.colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            isPassed ? 'PASS' : 'FAIL',
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {

  const _ProgressCard({required this.progress});
  final TestProgress progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LoadingIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Test ${progress.currentTest}/${progress.totalTests}',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(progress.percentage * 100).toStringAsFixed(0)}%',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.percentage,
              backgroundColor: Theme.of(context).colorScheme.outline,
              valueColor: AlwaysStoppedAnimation(context.colors.primary),
            ),
            const SizedBox(height: 12),
            Text(progress.testName, style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ResultsSummaryCard extends StatelessWidget {

  const _ResultsSummaryCard({required this.results});
  final QuickTestResults results;

  @override
  Widget build(BuildContext context) {
    final successRate = results.successRate * 100;
    final color = successRate >= 90
        ? context.colors.success
        : successRate >= 50
        ? context.colors.warning
        : context.colors.error;

    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.analytics, color: color),
                const SizedBox(width: 8),
                Text(
                  context.l10n.testResults,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                  label: context.l10n.passed,
                  value: '${results.passedTests}',
                  color: context.colors.success,
                ),
                _StatChip(
                  label: context.l10n.failed,
                  value: '${results.totalTests - results.passedTests}',
                  color: context.colors.error,
                ),
                _StatChip(
                  label: context.l10n.successRate,
                  value: '${successRate.toStringAsFixed(0)}%',
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              context.l10n.recommendation,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(results.recommendation, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface87,
          ),
        ),
      ],
    );
  }
}

class _TestMatrixPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TestMatrixRow('TC-1', 'Foreground 30s'),
            const _TestMatrixRow('TC-2', 'Background 90s NO LA'),
            const _TestMatrixRow('TC-3', 'Background 90s WITH LA'),
            const _TestMatrixRow('TC-4', 'Foreground + Spotify'),
            const _TestMatrixRow('TC-5', 'Background + Spotify'),
            const _TestMatrixRow('TC-6', 'Foreground 10s rapid'),
            const _TestMatrixRow('TC-7', 'Rapid succession'),
            const _TestMatrixRow('TC-8', 'Background 120s'),
            const SizedBox(height: 8),
            Text(
              '× 5 runs each = 40 tests total',
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: context.colors.onSurface87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestMatrixRow extends StatelessWidget {

  const _TestMatrixRow(this.id, this.name);
  final String id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              id,
              style: context.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(name, style: context.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _ResultsDialog extends StatelessWidget {

  const _ResultsDialog({required this.results});
  final QuickTestResults results;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.detailedResults),
      content: SingleChildScrollView(child: Text(results.summary)),
      actions: [
        // Accessibility: Close dialog button with semantic label
        Semantics(
          label: context.l10n.close,
          button: true,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
        ),
        // Accessibility: Share button with semantic label
        Semantics(
          label: context.l10n.share,
          button: true,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Share.share(results.summary);
            },
            icon: const Icon(AppIcons.share),
            label: Text(context.l10n.share),
          ),
        ),
      ],
    );
  }
}
