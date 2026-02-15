/// Workout Import Screen
///
/// Full-screen bottom sheet with two tabs: Text and Photo.
/// Allows users to paste workout text or take a photo for AI parsing.
///
/// **Layer**: Presentation - Screen
/// **Feature**: Workout Import
library;

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/providers/workout_import_provider.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/widgets/import_preview_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';

class WorkoutImportScreen extends ConsumerStatefulWidget {
  const WorkoutImportScreen({super.key});

  @override
  ConsumerState<WorkoutImportScreen> createState() =>
      _WorkoutImportScreenState();
}

class _WorkoutImportScreenState extends ConsumerState<WorkoutImportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(workoutImportProvider);
    final l10n = context.l10n;

    // Listen for error messages
    ref.listen<WorkoutImportState>(workoutImportProvider, (prev, next) {
      if (next.status == WorkoutImportStatus.error && mounted) {
        final msg = switch (next.errorMessage) {
          'empty' => l10n.workoutImportErrorEmpty,
          'rate_limit' => l10n.workoutImportErrorRateLimit,
          'parsing' => l10n.workoutImportErrorParsing,
          _ => l10n.workoutImportErrorApi,
        };
        SnackBarService.showError(context, msg);
      }
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(l10n.workoutImportTitle),
        leading: IconButton(
          icon: const Icon(AppIcons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(AppIcons.paste, size: AppIconSize.small),
              text: l10n.workoutImportFromText,
            ),
            Tab(
              icon: const Icon(AppIcons.camera, size: AppIconSize.small),
              text: l10n.workoutImportFromPhoto,
            ),
          ],
        ),
      ),
      body: importState.status == WorkoutImportStatus.success &&
              importState.parsedWorkout != null
          ? ImportPreviewSection(
              workout: importState.parsedWorkout!,
              onCreateTemplates: _createTemplates,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTextTab(importState),
                _buildPhotoTab(importState),
              ],
            ),
    );
  }

  Widget _buildTextTab(WorkoutImportState importState) {
    final l10n = context.l10n;
    final isLoading = importState.status == WorkoutImportStatus.loading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + context.tabBarInset,
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l10n.workoutImportPasteHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(workoutImportProvider.notifier)
                          .parseText(_textController.text);
                    },
              icon: isLoading
                  ? LoadingIndicator(
                      size: 20,
                      color: context.colors.onPrimary,
                    )
                  : const Icon(AppIcons.search),
              label: Text(
                isLoading
                    ? l10n.workoutImportAnalyzing
                    : l10n.workoutImportAnalyze,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTab(WorkoutImportState importState) {
    final l10n = context.l10n;
    final isLoading = importState.status == WorkoutImportStatus.loading;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + context.tabBarInset,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.camera,
            size: 64,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.workoutImportPhotoHint,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          if (isLoading)
            Column(
              children: [
                LoadingIndicator(size: 40, color: context.colors.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.workoutImportAnalyzing,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(workoutImportProvider.notifier)
                          .parseImage(ImageSource.camera);
                    },
                    icon: const Icon(AppIcons.camera),
                    label: Text(l10n.workoutImportTakePhoto),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(workoutImportProvider.notifier)
                          .parseImage(ImageSource.gallery);
                    },
                    icon: const Icon(AppIcons.image),
                    label: Text(l10n.workoutImportChooseGallery),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _createTemplates() async {
    final l10n = context.l10n;
    final templates = await ref
        .read(workoutImportProvider.notifier)
        .createTemplates();

    if (templates.isNotEmpty && mounted) {
      unawaited(HapticFeedback.mediumImpact());
      Navigator.of(context).pop();
      SnackBarService.showSuccess(
        context,
        templates.length > 1
            ? l10n.workoutImportSuccess
            : l10n.workoutImportSingleSuccess,
      );
    }
  }
}
