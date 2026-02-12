import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Uniform info card for advanced exercise types (Superset, DropSet, RestPause).
/// Replaces 3 inconsistent card styles with a single collapsible design.
class AdvancedInfoCard extends StatefulWidget {
  const AdvancedInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  @override
  State<AdvancedInfoCard> createState() => _AdvancedInfoCardState();
}

class _AdvancedInfoCardState extends State<AdvancedInfoCard> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isExpanded) {
        setState(() => _isExpanded = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(_isExpanded ? 14 : 10),
        decoration: BoxDecoration(
          color: widget.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: widget.accentColor,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.accentColor,
              size: _isExpanded ? 22 : 18,
            ),
            SizedBox(width: _isExpanded ? 12 : 8),
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                secondChild: Text(
                  widget.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.accentColor,
                  ),
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isExpanded ? 0.5 : 0,
              child: Icon(
                AppIcons.keyboardArrowDown,
                color: widget.accentColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
