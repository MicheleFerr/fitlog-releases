import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

class AuthHeroAssets {
  AuthHeroAssets._();

  // Place your custom screenshots here to match the provided reference design.
  static const String login = 'assets/images/auth_login_hero.png';
  static const List<String> loginVariants = [
    'assets/images/auth_login_hero_1.png',
    'assets/images/auth_login_hero_2.png',
  ];
  static const String brandLogo = 'assets/images/splash_no_bkg.png';
  static const String register = 'assets/images/auth_register_hero.png';
  static const String fallback = 'assets/images/splash_logo.png';

  static String randomLoginVariant([Random? random]) {
    final rng = random ?? Random();
    return loginVariants[rng.nextInt(loginVariants.length)];
  }
}

class AuthVisualScaffold extends StatelessWidget {
  const AuthVisualScaffold({
    required this.title,
    required this.subtitle,
    required this.heroAssetPath,
    required this.content,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final String subtitle;
  final String heroAssetPath;
  final Widget content;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5F6D), Color(0xFFFF7D3D), Color(0xFFFF2E93)],
          ),
        ),
        child: Stack(
          children: [
            const _BackdropBlobs(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onBackPressed != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _BackButtonPill(onPressed: onBackPressed!),
                          ),
                        _AuthHero(
                          title: title,
                          subtitle: subtitle,
                          heroAssetPath: heroAssetPath,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: context.colors.surface.withValues(
                              alpha: 0.94,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 34,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: content,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({
    required this.title,
    required this.subtitle,
    required this.heroAssetPath,
  });

  final String title;
  final String subtitle;
  final String heroAssetPath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;
        final textContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Text(
                'GymBro',
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: context.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

        final imageCard = Container(
          width: compact ? double.infinity : 170,
          height: compact ? 190 : 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            color: Colors.white.withValues(alpha: 0.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            heroAssetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset(AuthHeroAssets.fallback, fit: BoxFit.cover),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textContent,
              const SizedBox(height: AppSpacing.md),
              imageCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: textContent),
            const SizedBox(width: AppSpacing.md),
            imageCard,
          ],
        );
      },
    );
  }
}

class _BackButtonPill extends StatelessWidget {
  const _BackButtonPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _BackdropBlobs extends StatelessWidget {
  const _BackdropBlobs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -60,
            child: _Blob(
              size: 260,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            right: -80,
            top: 120,
            child: _Blob(size: 210, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: -120,
            left: 80,
            child: _Blob(
              size: 280,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
