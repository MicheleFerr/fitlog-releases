/// Branding Editor Section Widget
///
/// Form for editing coach PDF branding settings.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_branding.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Section for editing coach branding
class BrandingEditorSection extends StatefulWidget {
  const BrandingEditorSection({
    super.key,
    required this.branding,
    required this.onSave,
  });

  final CoachBranding? branding;
  final Future<void> Function(CoachBranding) onSave;

  @override
  State<BrandingEditorSection> createState() => _BrandingEditorSectionState();
}

class _BrandingEditorSectionState extends State<BrandingEditorSection> {
  late TextEditingController _businessNameController;
  late TextEditingController _taglineController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;
  late TextEditingController _footerTextController;

  late Color _primaryColor;
  late Color _accentColor;

  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final b = widget.branding;
    _businessNameController = TextEditingController(
      text: b?.businessName ?? '',
    );
    _taglineController = TextEditingController(text: b?.tagline ?? '');
    _emailController = TextEditingController(text: b?.email ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _websiteController = TextEditingController(text: b?.website ?? '');
    _instagramController = TextEditingController(text: b?.instagram ?? '');
    _footerTextController = TextEditingController(text: b?.footerText ?? '');

    _primaryColor = _hexToColor(b?.primaryColor ?? kDefaultPrimaryColor);
    _accentColor = _hexToColor(b?.accentColor ?? kDefaultAccentColor);

    // Listen for changes
    for (final controller in [
      _businessNameController,
      _taglineController,
      _emailController,
      _phoneController,
      _websiteController,
      _instagramController,
      _footerTextController,
    ]) {
      controller.addListener(_markChanged);
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2196F3); // Fallback to blue
    }
  }

  String _colorToHex(Color color) {
    // Convert to ARGB int and format as hex (without alpha)
    final argb =
        ((color.a * 255).round() << 24) |
        ((color.r * 255).round() << 16) |
        ((color.g * 255).round() << 8) |
        (color.b * 255).round();
    return argb.toRadixString(16).substring(2).toUpperCase();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _taglineController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updatedBranding = CoachBranding(
        id: widget.branding?.id ?? 'new',
        coachId: widget.branding?.coachId ?? '',
        businessName: _businessNameController.text.trim(),
        tagline: _taglineController.text.trim().isEmpty
            ? null
            : _taglineController.text.trim(),
        primaryColor: _colorToHex(_primaryColor),
        accentColor: _colorToHex(_accentColor),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        instagram: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        footerText: _footerTextController.text.trim().isEmpty
            ? null
            : _footerTextController.text.trim(),
        createdAt: widget.branding?.createdAt ?? DateTime.now(),
      );

      await widget.onSave(updatedBranding);
      setState(() => _hasChanges = false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showColorPicker(bool isPrimary) {
    final currentColor = isPrimary ? _primaryColor : _accentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPrimary ? context.l10n.primaryColor : context.l10n.accentColor,
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                if (isPrimary) {
                  _primaryColor = color;
                } else {
                  _accentColor = color;
                }
                _hasChanges = true;
              });
            },
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Business Name
            _buildTextField(
              controller: _businessNameController,
              label: context.l10n.businessName,
              icon: AppIcons.business,
              required: true,
            ),
            const SizedBox(height: AppSpacing.md),

            // Tagline
            _buildTextField(
              controller: _taglineController,
              label: context.l10n.tagline,
              icon: AppIcons.formatQuote,
              hint: 'Your Personal Fitness Coach',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Colors
            Text(
              context.l10n.brandColors,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ColorPickerButton(
                    label: context.l10n.primaryColor,
                    color: _primaryColor,
                    onTap: () => _showColorPicker(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ColorPickerButton(
                    label: context.l10n.accentColor,
                    color: _accentColor,
                    onTap: () => _showColorPicker(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Contact Info
            Text(
              context.l10n.contactInfo,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(
              controller: _emailController,
              label: context.l10n.contactEmail,
              icon: AppIcons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _phoneController,
              label: context.l10n.contactPhone,
              icon: AppIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Social Links
            Text(
              context.l10n.socialLinks,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(
              controller: _websiteController,
              label: context.l10n.websiteUrl,
              icon: AppIcons.language,
              keyboardType: TextInputType.url,
              hint: 'www.mycoaching.com',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _instagramController,
              label: context.l10n.instagramHandle,
              icon: AppIcons.alternateEmail,
              hint: 'mycoaching',
              prefix: '@',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Footer Text
            _buildTextField(
              controller: _footerTextController,
              label: context.l10n.footerText,
              icon: AppIcons.shortText,
              hint: 'Powered by Coach Mike',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save Button
            FilledButton.icon(
              onPressed: _hasChanges && !_isSaving ? _save : null,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(AppIcons.save),
              label: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? prefix,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: prefix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Color picker button with preview
class _ColorPickerButton extends StatelessWidget {
  const _ColorPickerButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.outline),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: 16,
              color: context.colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
