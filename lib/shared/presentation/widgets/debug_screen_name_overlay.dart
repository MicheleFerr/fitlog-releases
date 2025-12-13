/// 🔧 Debug Screen Name Overlay
///
/// Widget che mostra il nome della schermata corrente in modalità Beta/Debug
/// Utile per sviluppatori per identificare quale file corrisponde a quale schermata
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Overlay widget che mostra il nome della schermata in alto a sinistra
/// Solo visibile quando Beta Mode è abilitato nelle impostazioni
class DebugScreenNameOverlay extends ConsumerWidget {
  const DebugScreenNameOverlay({
    super.key,
    required this.screenName,
    required this.child,
  });

  final String screenName;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mostra solo se beta mode è abilitato
    final isBetaMode = ref.watch(betaModeEnabledProvider);

    if (!isBetaMode) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: _DebugLabel(screenName: screenName),
        ),
      ],
    );
  }
}

class _DebugLabel extends StatelessWidget {
  const _DebugLabel({required this.screenName});

  final String screenName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
  icon: AppIcons.code,
  semanticLabel: 'Code',
  size: AppIconSize.tiny,
  color: context.colors.warning,
),
          const SizedBox(width: 6),
          Text(
            screenName,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
