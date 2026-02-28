import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

const Color _brandForeground = Color(0xFF1F1F1F);
const Color _brandBorder = Color(0xFFDADCE0);
const Color _brandDisabledBackground = Color(0xFFE8EAED);
const Color _brandDisabledForeground = Color(0xFF5F6368);

/// Branded Google auth button with official logo and high-contrast colors.
class BrandedGoogleAuthButton extends StatelessWidget {
  const BrandedGoogleAuthButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = 16,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: LoadingIndicator(size: 20, color: _brandForeground),
              )
            : SvgPicture.asset(
                'assets/images/google_logo.svg',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDisabled ? _brandDisabledForeground : _brandForeground,
          ),
        ),
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          foregroundColor: _brandForeground,
          disabledBackgroundColor: _brandDisabledBackground,
          disabledForegroundColor: _brandDisabledForeground,
          side: const BorderSide(color: _brandBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Branded Apple auth button with official logo and matching social style.
class BrandedAppleAuthButton extends StatelessWidget {
  const BrandedAppleAuthButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = 16,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: LoadingIndicator(size: 20, color: _brandForeground),
              )
            : SvgPicture.asset(
                'assets/images/apple_logo.svg',
                width: 18,
                height: 22,
                fit: BoxFit.contain,
              ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDisabled ? _brandDisabledForeground : _brandForeground,
          ),
        ),
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          foregroundColor: _brandForeground,
          disabledBackgroundColor: _brandDisabledBackground,
          disabledForegroundColor: _brandDisabledForeground,
          side: const BorderSide(color: _brandBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
