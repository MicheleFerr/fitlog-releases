/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations required
/// 🎨 Theme: ✅ Theme.of(context) required
/// 📱 Platform: Universal
/// 
/// Screen for exporting workout templates to JSON with premium features
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/export_format.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/account_tier.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_export_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/export_options_widget.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_selection_widget.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/premium_export_features_widget.dart';

/// Screen for exporting workout templates
class TemplateExportScreen extends ConsumerStatefulWidget {
  
  const TemplateExportScreen({
    super.key,
    this.preselectedTemplates,
  });
  final List<WorkoutTemplate>? preselectedTemplates;

  @override
  ConsumerState<TemplateExportScreen> createState() => _TemplateExportScreenState;
}

class _TemplateExportScreenState extends ConsumerState<TemplateExportScreen> {
  List<WorkoutTemplate> _selectedTemplates = [];
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _includeAnalytics = false;
  bool _isExporting = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.preselectedTemplates != null) {
      _selectedTemplates = List.from(widget.preselectedTemplates!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(unifiedUserProvider);
    final exportState = ref.watch(templateExportProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportTemplates),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (user.accountTier != AccountTier.free)
            IconButton(
              onPressed: () => _showExportLimits(context, l10n),
              icon: const Icon(Icons.info_outline),
            ),
        ],
      ),
      body: _isExporting
          ? _buildExportingView(l10n, theme)
          : _buildExportContent(context, l10n, theme, user),
      bottomNavigationBar: _selectedTemplates.isNotEmpty && !_isExporting
          ? _buildExportButton(l10n, theme, user)
          : null,
    );
  }
  
  Widget _buildExportContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    UserProfile user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserTierInfo(l10n, theme, user),
          const SizedBox(height: 24),
          
          // Template selection
          TemplateSelectionWidget(
            selectedTemplates: _selectedTemplates,
            onSelectionChanged: (templates) {
              setState(() {
                _selectedTemplates = templates;
              });
            },
            maxSelection: _getMaxTemplatesForUser(user),
          ),
          
          if (_selectedTemplates.isNotEmpty) ...[
            const SizedBox(height: 24),
            
            // Export options
            ExportOptionsWidget(
              selectedFormat: _selectedFormat,
              includeAnalytics: _includeAnalytics,
              canIncludeAnalytics: _canIncludeAnalytics(user),
              onFormatChanged: (format) {
                setState(() {
                  _selectedFormat = format;
                });
              },
              onIncludeAnalyticsChanged: (include) {
                setState(() {
                  _includeAnalytics = include;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Premium features info
            if (user.accountTier == AccountTier.free)
              PremiumExportFeaturesWidget(
                onUpgradePressed: () => _showUpgradeDialog(context),
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildUserTierInfo(
    AppLocalizations l10n,
    ThemeData theme,
    UserProfile user,
  ) {
    final isFreeTier = user.accountTier == AccountTier.free;
    
    return Card(
      color: isFreeTier 
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isFreeTier ? Icons.lock : Icons.workspace_premium,
              color: isFreeTier 
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFreeTier ? l10n.freeAccount : l10n.premiumAccount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isFreeTier 
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isFreeTier ? l10n.freeExportLimitations : l10n.premiumExportFeatures,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isFreeTier 
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            if (isFreeTier)
              TextButton(
                onPressed: () => _showUpgradeDialog(context),
                child: Text(
                  l10n.upgrade,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExportingView(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.exportingTemplates,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedTemplates.length} ${l10n.templatesSelected}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExportButton(
    AppLocalizations l10n,
    ThemeData theme,
    UserProfile user,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _exportTemplates(ExportAction.download),
              icon: const Icon(Icons.download),
              label: Text(l10n.downloadJson),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _exportTemplates(ExportAction.share),
            icon: const Icon(Icons.share),
            label: Text(l10n.share),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _exportTemplates(ExportAction.copy),
            icon: const Icon(Icons.copy),
            label: Text(l10n.copy),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportTemplates(ExportAction action) async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      final user = ref.read(unifiedUserProvider);
      
      // Check if user can export this many templates
      if (!_canExportTemplates(user, _selectedTemplates.length)) {
        _showLimitReachedDialog();
        return;
      }
      
      // Perform export
      final exportedJson = await ref.read(templateExportProvider.notifier).exportTemplates(
        _selectedTemplates,
        format: _selectedFormat,
        includeAnalytics: _includeAnalytics,
      );
      
      // Handle export result based on action
      switch (action) {
        case ExportAction.download:
          await _downloadFile(exportedJson);
          break;
        case ExportAction.share:
          await _shareFile(exportedJson);
          break;
        case ExportAction.copy:
          await _copyToClipboard(exportedJson);
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).exportSuccessful),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).exportFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
  
  Future<void> _downloadFile(String jsonContent) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'gymbro_templates_$timestamp.json';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(jsonContent);
    
    // On mobile, share the file since direct downloads aren't straightforward
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/json')],
      text: AppLocalizations.of(context).gymbroTemplatesExport,
    );
  }
  
  Future<void> _shareFile(String jsonContent) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'gymbro_templates_$timestamp.json';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(jsonContent);
    
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/json')],
      text: AppLocalizations.of(context).gymbroTemplatesExport,
    );
  }
  
  Future<void> _copyToClipboard(String jsonContent) async {
    await Clipboard.setData(ClipboardData(text: jsonContent));
  }
  
  int _getMaxTemplatesForUser(UserProfile user) {
    switch (user.accountTier) {
      case AccountTier.free:
        return 1;
      case AccountTier.premium:
        return 10;
      case AccountTier.pro:
        return -1; // Unlimited
    }
  }
  
  bool _canIncludeAnalytics(UserProfile user) {
    return user.accountTier == AccountTier.premium || 
           user.accountTier == AccountTier.pro;
  }
  
  bool _canExportTemplates(UserProfile user, int count) {
    final max = _getMaxTemplatesForUser(user);
    return max == -1 || count <= max;
  }
  
  void _showExportLimits(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportLimits),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourCurrentLimits),
            const SizedBox(height: 12),
            // Add specific limits based on user tier
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
  
  void _showUpgradeDialog(BuildContext context) {
    // Navigate to premium upgrade screen
    // Implementation depends on existing premium flow
  }
  
  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).limitReached),
        content: Text(AppLocalizations.of(context).upgradeToExportMore),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showUpgradeDialog(context);
            },
            child: Text(AppLocalizations.of(context).upgrade),
          ),
        ],
      ),
    );
  }
}

enum ExportAction {
  download,
  share,
  copy,
}