import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/auth_visual_scaffold.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/branded_auth_buttons.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/legal_document_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _tosAccepted = false;

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          if (mounted) {
            context.goNamed('home');
          }
        },
        loading: () {},
        error: (error, _) {
          if (mounted) {
            SnackBarService.showError(context, context.l10n.error);
          }
        },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AuthHeroAssets.register,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Image.asset(AuthHeroAssets.fallback, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.58),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.0, 0.34, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopHeader(context),
                  const Spacer(),
                  _buildBottomActions(authController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: ClipPath(
            clipper: const _CutCornerClipper(cut: 14),
            child: Container(
              width: 74,
              height: 74,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Image.asset(
                AuthHeroAssets.brandLogo,
                fit: BoxFit.contain,
                width: 72,
                height: 72,
                errorBuilder: (_, _, _) => Image.asset(
                  AuthHeroAssets.fallback,
                  fit: BoxFit.contain,
                  width: 72,
                  height: 72,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.createAccount,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                context.l10n.startTrackingJourney,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(AsyncValue<void> authController) {
    return Container(
      key: const ValueKey('register_bottom_actions'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTosCheckbox(),
          const SizedBox(height: AppSpacing.sm),
          BrandedGoogleAuthButton(
            label: context.l10n.continueWithGoogle,
            isLoading: authController.isLoading,
            onPressed: authController.isLoading || !_tosAccepted
                ? null
                : _handleGoogleSignUp,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (Platform.isIOS)
            BrandedAppleAuthButton(
              label: context.l10n.continueWithApple,
              isLoading: authController.isLoading,
              onPressed: authController.isLoading || !_tosAccepted
                  ? null
                  : _handleAppleSignUp,
            ),
          if (Platform.isIOS) const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.alreadyHaveAccountPrompt,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  context.l10n.signIn,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTosCheckbox() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: () => setState(() => _tosAccepted = !_tosAccepted),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _tosAccepted,
                onChanged: (value) =>
                    setState(() => _tosAccepted = value ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: Wrap(
                  children: [
                    Text(
                      context.l10n.iAcceptThe,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          LegalDocumentScreen.showTermsOfService(context),
                      child: Text(
                        context.l10n.termsOfService,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade300,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.andThe,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          LegalDocumentScreen.showPrivacyPolicy(context),
                      child: Text(
                        context.l10n.privacyPolicy,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade300,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoogleSignUp() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignUp() async {
    await ref.read(authControllerProvider.notifier).signInWithApple();
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper({required this.cut});

  final double cut;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..lineTo(0, cut)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CutCornerClipper oldClipper) {
    return oldClipper.cut != cut;
  }
}
