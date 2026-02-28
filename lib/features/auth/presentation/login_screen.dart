import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/auth_visual_scaffold.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/branded_auth_buttons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final String _selectedHeroImage;
  bool _obscurePassword = true;
  bool _showLoginForm = false;

  @override
  void initState() {
    super.initState();
    _selectedHeroImage = AuthHeroAssets.randomLoginVariant();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            SnackBarService.showError(context, error.toString());
          }
        },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _selectedHeroImage,
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
                    Colors.black.withValues(alpha: 0.56),
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.65),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _showLoginForm
                        ? _buildEmailForm(authController)
                        : _buildBottomActions(authController),
                  ),
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
        ClipPath(
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
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.appTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                context.l10n.loginTagline,
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
      key: const ValueKey('bottom_actions'),
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
          BrandedGoogleAuthButton(
            label: context.l10n.signInWithGoogle,
            isLoading: authController.isLoading,
            onPressed: authController.isLoading ? null : _signInWithGoogle,
          ),
          const SizedBox(height: AppSpacing.sm),
          BrandedAppleAuthButton(
            label: context.l10n.signInWithApple,
            isLoading: authController.isLoading,
            onPressed: authController.isLoading || !Platform.isIOS
                ? null
                : _signInWithApple,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: authController.isLoading
                  ? null
                  : () => setState(() => _showLoginForm = true),
              icon: const Icon(AppIcons.email),
              label: Text(
                context.l10n.signInWithEmail,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Se non hai ancora un account ',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed('register'),
                child: Text(
                  'Registrati',
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

  Widget _buildEmailForm(AsyncValue<void> authController) {
    return Container(
      key: const ValueKey('email_form'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.signInWithEmail,
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                hintText: context.l10n.emailHint,
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(AppIcons.email, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.pleaseEnterEmail;
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return context.l10n.pleaseEnterValidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                hintText: context.l10n.passwordHint,
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(AppIcons.lock, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? AppIcons.visibility
                        : AppIcons.visibilityOff,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.pleaseEnterPassword;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: authController.isLoading ? null : _handleEmailSignIn,
                child: authController.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingIndicator(),
                      )
                    : Text(context.l10n.signInButton),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => setState(() => _showLoginForm = false),
              child: Text(
                context.l10n.backToOptions,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmailSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  void _signInWithApple() async {
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
