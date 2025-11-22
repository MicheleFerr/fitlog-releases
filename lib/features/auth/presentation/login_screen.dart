import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showLoginForm = false;

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
          // Login successful, navigate to home
          if (mounted) {
            context.goNamed('home');
          }
        },
        loading: () {},
        error: (error, _) {
          // Show error message
          if (mounted) {
            SnackBarService.showError(context, context.l10n.error);
          }
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.screenHeight -
                context.topPadding -
                context.bottomPadding - 48, // Account for padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: context.colors.primary,
),
              ),
              SizedBox(height: 16),

              // App Title
              Text(
                context.l10n.appTitle,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),

              SizedBox(height: 8),
              Text(
                context.l10n.appSubtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              
              SizedBox(height: 32),
              
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SemanticIcon(
  icon: AppIcons.wavingHand,
  semanticLabel: 'Waving hand',
  size: AppIconSize.xlarge,
  color: context.colors.primary,
),
                      SizedBox(height: 16),
                      Text(
                        context.l10n.welcomeToGymBro,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        context.l10n.welcomeDescription,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Email/Password Login Form (conditionally shown)
              if (_showLoginForm) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: context.l10n.emailLabel,
                          hintText: context.l10n.emailHint,
                          prefixIcon: SemanticIcon(
  icon: AppIcons.email,
  semanticLabel: 'Email',
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
                      SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: context.l10n.passwordLabel,
                          hintText: context.l10n.passwordHint,
                          prefixIcon: SemanticIcon(
  icon: AppIcons.lock,
  semanticLabel: 'Lock',
),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? AppIcons.visibility : AppIcons.visibilityOff),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                      SizedBox(height: 24),
                      
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: authController.isLoading ? null : _handleEmailSignIn,
                          child: authController.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(context.l10n.signInButton),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Forgot Password
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(context.l10n.forgotPassword),
                      ),
                      SizedBox(height: 16),

                      // Back to options
                      TextButton.icon(
                        onPressed: () => setState(() => _showLoginForm = false),
                        icon: SemanticIcon(
  icon: AppIcons.back,
  semanticLabel: 'Back',
),
                        label: Text(context.l10n.backToOptions),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: authController.isLoading ? null : _signInWithGoogle,
                    icon: authController.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : SemanticIcon(
  icon: AppIcons.gMobiledata,
  semanticLabel: 'G mobiledata',
  size: AppIconSize.medium,
),
                    label: Text(context.l10n.signInWithGoogle),
                  ),
                ),

                const SizedBox(height: 16),

                // Apple Sign In Button (iOS only)
                if (Platform.isIOS) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: authController.isLoading ? null : _signInWithApple,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.onSurface,
                        foregroundColor: context.colors.surface,
                      ),
                      icon: authController.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SemanticIcon(
  icon: AppIcons.apple,
  semanticLabel: 'Apple',
),
                      label: Text(context.l10n.signInWithApple),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Email Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showLoginForm = true),
                    icon: SemanticIcon(
  icon: AppIcons.email,
  semanticLabel: 'Email',
),
                    label: Text(context.l10n.signInWithEmail),
                  ),
                ),

                SizedBox(height: 16),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pushNamed('register'),
                    icon: SemanticIcon(
  icon: AppIcons.personAdd,
  semanticLabel: 'Person add',
),
                    label: Text(context.l10n.signUpButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 16),
              
              // Features Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FeatureIcon(
                    icon: AppIcons.timer,
                    label: context.l10n.featureSmartTimer,
                    color: context.colors.primary,
                  ),
                  _FeatureIcon(
                    icon: AppIcons.phoneIphone,
                    label: context.l10n.featureLiveActivities,
                    color: context.colors.secondary,
                  ),
                  _FeatureIcon(
                    icon: AppIcons.favorite,
                    label: context.l10n.featureAppleHealth,
                    color: context.colors.tertiary,
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
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
        SnackBarService.showError(context, context.l10n.error);
      }
    }
  }

}

class _FeatureIcon extends StatelessWidget {

  const _FeatureIcon({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
