import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showLoginForm = false;

  // Animation controller for pulsing icon
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    final colorScheme = context.colors;

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
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.screenHeight -
                  context.topPadding -
                  context.bottomPadding -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Animated Logo with glow effect
                _buildAnimatedLogo(colorScheme),

                const SizedBox(height: AppSpacing.lg),

                // App Title
                Text(
                  context.l10n.appTitle,
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Motivational Tagline
                Text(
                  context.l10n.loginTagline,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Stats Preview
                _buildStatsPreview(colorScheme),

                const SizedBox(height: AppSpacing.xl),

                // Login Options
                if (_showLoginForm)
                  _buildEmailForm(authController, colorScheme)
                else
                  _buildSocialLoginOptions(authController, colorScheme),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.3),
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.primary.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 30 * _pulseAnimation.value,
                spreadRadius: 5 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                AppIcons.workout,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsPreview(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: AppIcons.workout,
            value: '∞',
            label: context.l10n.loginStatsWorkouts,
            color: colorScheme.primary,
          ),
          _StatDivider(color: colorScheme.outlineVariant),
          _StatItem(
            icon: AppIcons.repeat,
            value: '∞',
            label: context.l10n.loginStatsSets,
            color: colorScheme.secondary,
          ),
          _StatDivider(color: colorScheme.outlineVariant),
          _StatItem(
            icon: AppIcons.emojiEvents,
            value: '∞',
            label: context.l10n.loginStatsPRs,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginOptions(
    AsyncValue<void> authController,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: authController.isLoading ? null : _signInWithGoogle,
            icon: authController.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(),
                  )
                : const Icon(AppIcons.gMobiledata, size: 24),
            label: Text(
              context.l10n.signInWithGoogle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Apple Sign In (iOS only)
        if (Platform.isIOS) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: authController.isLoading ? null : _signInWithApple,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: authController.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: LoadingIndicator(),
                    )
                  : const Icon(AppIcons.apple),
              label: Text(
                context.l10n.signInWithApple,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                context.l10n.orDivider,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Email Sign In
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showLoginForm = true),
            icon: Icon(AppIcons.email, color: colorScheme.primary),
            label: Text(
              context.l10n.signInWithEmail,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Register
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => context.pushNamed('register'),
            icon: Icon(AppIcons.personAdd, color: colorScheme.secondary),
            label: Text(
              context.l10n.signUpButton,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Guest Mode Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                context.l10n.orDivider,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Try Without Account (Guest Mode)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton.icon(
            onPressed: () => _signInAnonymously(),
            icon: Icon(
              AppIcons.visibilityOff,
              color: colorScheme.onSurfaceVariant,
            ),
            label: Text(
              context.l10n.tryWithoutAccount,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Guest Mode Disclaimer
        Text(
          context.l10n.guestModeDisclaimer,
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _signInAnonymously() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();
  }

  Widget _buildEmailForm(
    AsyncValue<void> authController,
    ColorScheme colorScheme,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: context.l10n.emailLabel,
              hintText: context.l10n.emailHint,
              prefixIcon: const Icon(AppIcons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.pleaseEnterEmail;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return context.l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: context.l10n.passwordLabel,
              hintText: context.l10n.passwordHint,
              prefixIcon: const Icon(AppIcons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? AppIcons.visibility : AppIcons.visibilityOff,
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
          const SizedBox(height: AppSpacing.lg),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: authController.isLoading ? null : _handleEmailSignIn,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: authController.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: LoadingIndicator(),
                    )
                  : Text(
                      context.l10n.signInButton,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Forgot Password
          TextButton(
            onPressed: _handleForgotPassword,
            child: Text(context.l10n.forgotPassword),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Back to options
          TextButton.icon(
            onPressed: () => setState(() => _showLoginForm = false),
            icon: const Icon(AppIcons.arrowBack),
            label: Text(context.l10n.backToOptions),
          ),
        ],
      ),
    );
  }

  void _handleEmailSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
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

  void _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      SnackBarService.showWarning(context, context.l10n.pleaseEnterEmailFirst);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
            _emailController.text.trim(),
          );

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.passwordResetEmailSent);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, e.toString());
      }
    }
  }
}

/// Single stat item in the preview
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Vertical divider between stats
class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: color.withValues(alpha: 0.3),
    );
  }
}
