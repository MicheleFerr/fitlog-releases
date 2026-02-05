/// Scientific Paper Card Widget
///
/// Displays scientific paper information with proper attribution for CC-BY compliance.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
/// **Compliance**: GDPR, CC-BY license attribution
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget to display scientific paper with proper citation and license attribution
///
/// Shows:
/// - Title
/// - Authors and year (formatted citation)
/// - License badge
/// - DOI link
/// - Categories/keywords
/// - Expandable abstract
class ScientificPaperCard extends StatefulWidget {
  final ScientificPaper paper;
  final bool initiallyExpanded;

  const ScientificPaperCard({
    super.key,
    required this.paper,
    this.initiallyExpanded = false,
  });

  @override
  State<ScientificPaperCard> createState() => _ScientificPaperCardState();
}

class _ScientificPaperCardState extends State<ScientificPaperCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.paper.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Citation (Authors + Year) - REQUIRED FOR CC-BY
              Row(
                children: [
                  Icon(
                    AppIcons.person,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      widget.paper.formatCitation(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // License Badge - REQUIRED FOR CC-BY
              _buildLicenseBadge(context),
              const SizedBox(height: AppSpacing.sm),

              // Categories/Keywords
              if (widget.paper.categories.isNotEmpty) ...[
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: widget.paper.categories.map((category) {
                    return Chip(
                      label: Text(
                        category,
                        style: context.textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // DOI Link - REQUIRED FOR PROPER ATTRIBUTION
              TextButton.icon(
                onPressed: () => _launchUrl(widget.paper.url),
                icon: const Icon(AppIcons.openInNew, size: 16),
                label: const Text('View Original Paper'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
              ),

              // Expandable Abstract
              if (_isExpanded) ...[
                const Divider(height: AppSpacing.lg),
                Text(
                  'Abstract',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.paper.abstract,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],

              // Expand/Collapse indicator
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Icon(
                  _isExpanded
                      ? AppIcons.keyboardArrowUp
                      : AppIcons.keyboardArrowDown,
                  size: 20,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseBadge(BuildContext context) {
    // Determine badge color based on license type
    Color badgeColor;
    IconData icon;

    if (widget.paper.license.contains('CC-BY-NC-ND')) {
      badgeColor = context.colors.warning;
      icon = AppIcons.warning;
    } else if (widget.paper.license.contains('CC-BY')) {
      badgeColor = context.colors.success;
      icon = AppIcons.check;
    } else {
      badgeColor = context.colors.primary;
      icon = AppIcons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.paper.license,
            style: context.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
