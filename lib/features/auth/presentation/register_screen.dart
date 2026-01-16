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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showEmailForm = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            SnackBarService.showError(context, context.l10n.error);
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Animated Logo with glow effect
              _buildAnimatedLogo(colorScheme),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                context.l10n.createAccount,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Subtitle
              Text(
                context.l10n.startTrackingJourney,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Stats Preview
              _buildStatsPreview(colorScheme),

              const SizedBox(height: AppSpacing.xl),

              // Registration Options
              if (_showEmailForm)
                _buildEmailForm(authController, colorScheme)
              else
                _buildQuickRegisterOptions(authController, colorScheme),

              const SizedBox(height: AppSpacing.lg),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.alreadyHaveAccountPrompt,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      context.l10n.signIn,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
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
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.secondary.withValues(alpha: 0.3),
                colorScheme.secondary.withValues(alpha: 0.1),
                colorScheme.secondary.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withValues(alpha: 0.4),
                blurRadius: 25 * _pulseAnimation.value,
                spreadRadius: 4 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondaryContainer,
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                AppIcons.personAdd,
                size: 32,
                color: colorScheme.secondary,
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

  Widget _buildQuickRegisterOptions(
    AsyncValue<void> authController,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Google Sign Up
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: authController.isLoading ? null : _handleGoogleSignUp,
            icon: authController.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(),
                  )
                : const Icon(AppIcons.gMobiledata, size: 24),
            label: Text(
              context.l10n.continueWithGoogle,
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

        // Apple Sign Up (iOS only)
        if (Platform.isIOS) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: authController.isLoading ? null : _handleAppleSignUp,
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
                context.l10n.continueWithApple,
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

        // Email Registration
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showEmailForm = true),
            icon: Icon(AppIcons.email, color: colorScheme.primary),
            label: Text(
              context.l10n.signUpWithEmail,
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
      ],
    );
  }

  Widget _buildEmailForm(
    AsyncValue<void> authController,
    ColorScheme colorScheme,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.fullName,
              hintText: context.l10n.fullNameHint,
              prefixIcon: const Icon(AppIcons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.nameRequired;
              }
              if (value.trim().length < 2) {
                return context.l10n.nameMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

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
                return context.l10n.emailRequired;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return context.l10n.emailInvalid;
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
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.passwordRequired;
              }
              if (value.length < 6) {
                return context.l10n.passwordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: context.l10n.confirmPassword,
              hintText: context.l10n.confirmPasswordHint,
              prefixIcon: const Icon(AppIcons.lockOutline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? AppIcons.visibility
                      : AppIcons.visibilityOff,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.confirmPasswordRequired;
              }
              if (value != _passwordController.text) {
                return context.l10n.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Register Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: authController.isLoading ? null : _handleRegister,
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
                      context.l10n.createAccount,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Back to options
          TextButton.icon(
            onPressed: () => setState(() => _showEmailForm = false),
            icon: const Icon(AppIcons.arrowBack),
            label: Text(context.l10n.backToOptions),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authControllerProvider.notifier).registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );
    }
  }

  void _handleGoogleSignUp() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignUp() async {
    await ref.read(authControllerProvider.notifier).signInWithApple();
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
