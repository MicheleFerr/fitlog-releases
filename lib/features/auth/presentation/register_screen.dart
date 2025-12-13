import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          // Registration successful, navigate to home
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
      appBar: AppBar(
        title: Text(context.l10n.createAccount),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const SemanticIcon(
  icon: AppIcons.home,
  semanticLabel: 'Home',
),
            onPressed: () => context.goNamed('login'),
            tooltip: context.l10n.backToLogin,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: Theme.of(context,
).primaryColor,
                  ),
                ),

                // Welcome Text
                Text(
                  context.l10n.joinGymBro,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.startTrackingJourney,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Registration Options
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          context.l10n.registerQuickly,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.autoAccountCreation,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Google Sign Up
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: authController.isLoading ? null : _handleGoogleSignUp,
                            icon: authController.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: LoadingIndicator(),
                                  )
                                : const SemanticIcon(
  icon: AppIcons.gMobiledata,
  semanticLabel: 'G mobiledata',
  size: AppIconSize.medium,
),
                            label: Text(context.l10n.continueWithGoogle),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Apple Sign Up (iOS only)
                        if (Platform.isIOS) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: authController.isLoading ? null : _handleAppleSignUp,
                              style: FilledButton.styleFrom(
                                backgroundColor: context.colors.onSurface,
                                foregroundColor: context.colors.surface,
                              ),
                              icon: authController.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: LoadingIndicator(),
                                    )
                                  : const SemanticIcon(
  icon: AppIcons.apple,
  semanticLabel: 'Apple',
),
                              label: Text(context.l10n.continueWithApple),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Or divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        context.l10n.orDivider,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.fullName,
                    hintText: context.l10n.fullNameHint,
                    prefixIcon: const SemanticIcon(
  icon: AppIcons.person,
  semanticLabel: 'Profile',
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
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    hintText: context.l10n.emailHint,
                    prefixIcon: const SemanticIcon(
  icon: AppIcons.email,
  semanticLabel: 'Email',
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
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: context.l10n.passwordLabel,
                    hintText: context.l10n.passwordHint,
                    prefixIcon: const SemanticIcon(
  icon: AppIcons.lock,
  semanticLabel: 'Lock',
),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? AppIcons.visibility : AppIcons.visibilityOff),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: context.l10n.confirmPassword,
                    hintText: context.l10n.confirmPasswordHint,
                    prefixIcon: const SemanticIcon(
  icon: AppIcons.lockOutline,
  semanticLabel: 'Lock outline',
),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? AppIcons.visibility : AppIcons.visibilityOff),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                const SizedBox(height: 32),

                // Register Button
                FilledButton(
                  onPressed: authController.isLoading ? null : _handleRegister,
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: LoadingIndicator(),
                        )
                      : Text(context.l10n.createAccount),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.l10n.orDivider,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Google Sign Up Button
                OutlinedButton.icon(
                  onPressed: authController.isLoading ? null : _handleGoogleSignUp,
                  icon: const SemanticIcon(
  icon: AppIcons.gMobiledata,
  semanticLabel: 'G mobiledata',
  size: AppIconSize.medium,
),
                  label: Text(context.l10n.signUpWithGoogle),
                ),
                const SizedBox(height: 16),

                // Apple Sign Up Button (iOS only)
                if (Platform.isIOS)
                  OutlinedButton.icon(
                    onPressed: authController.isLoading ? null : _handleAppleSignUp,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.onSurface),
                    ),
                    icon: Icon(AppIcons.apple, color: context.colors.onSurface),
                    label: Text(context.l10n.signUpWithApple, style: context.textTheme.labelLarge?.copyWith(color: context.colors.onSurface)),
                  ),
                const SizedBox(height: 32),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.alreadyHaveAccountPrompt,
                      style: context.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(context.l10n.signIn),
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
