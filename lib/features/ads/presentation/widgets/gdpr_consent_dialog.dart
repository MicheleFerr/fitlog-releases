/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/widgets
 * 🎯 Feature: ads
 * 🔧 Type: widget (GDPR consent dialog)
 * 🌍 Localization: ✅ Full localization support
 * 🎨 Theme: ✅ Material 3 theming
 * 📱 Platform: Universal
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// GDPR consent status
enum ConsentStatus {
  unknown,
  accepted,
  rejected,
  expired,
}

/// GDPR consent manager
class GdprConsentManager {
  static const String _consentKey = 'gdpr_ads_consent';
  static const String _consentDateKey = 'gdpr_consent_date';
  static const String _userLocationKey = 'user_location';
  
  // Consent expires after 13 months per GDPR guidelines
  static const Duration _consentValidityPeriod = Duration(days: 395);

  /// Check if user is in EU/EEA (simplified check)
  static bool isEuUser() {
    // In production, this would check user's actual location
    // using IP geolocation or device settings
    // For now, we'll be conservative and assume EU user
    return true;
  }

  /// Get current consent status
  static Future<ConsentStatus> getConsentStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has given consent
      final hasConsent = prefs.getBool(_consentKey);
      if (hasConsent == null) return ConsentStatus.unknown;
      
      // Check consent date and validity
      final consentDateMs = prefs.getInt(_consentDateKey);
      if (consentDateMs == null) return ConsentStatus.unknown;
      
      final consentDate = DateTime.fromMillisecondsSinceEpoch(consentDateMs);
      final now = DateTime.now();
      
      if (now.difference(consentDate) > _consentValidityPeriod) {
        return ConsentStatus.expired;
      }
      
      return hasConsent ? ConsentStatus.accepted : ConsentStatus.rejected;
    } catch (e) {
      print('Error checking consent status: $e');
      return ConsentStatus.unknown;
    }
  }

  /// Save consent choice
  static Future<void> saveConsent(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, accepted);
      await prefs.setInt(_consentDateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving consent: $e');
    }
  }

  /// Clear consent (for testing or user request)
  static Future<void> clearConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentKey);
      await prefs.remove(_consentDateKey);
    } catch (e) {
      print('Error clearing consent: $e');
    }
  }
}

/// GDPR consent provider
final gdprConsentProvider = FutureProvider<ConsentStatus>((ref) async {
  return await GdprConsentManager.getConsentStatus();
});

/// GDPR consent dialog widget
class GdprConsentDialog extends ConsumerStatefulWidget {
  final VoidCallback? onConsentGiven;
  final VoidCallback? onConsentRejected;

  const GdprConsentDialog({
    super.key,
    this.onConsentGiven,
    this.onConsentRejected,
  });

  @override
  ConsumerState<GdprConsentDialog> createState() => _GdprConsentDialogState();
}

class _GdprConsentDialogState extends ConsumerState<GdprConsentDialog> {
  bool _isProcessing = false;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.privacyAndAds,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adsConsentDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Key points about ads
            _buildConsentPoint(
              context,
              icon: Icons.ad_units,
              title: l10n.personalizedAds,
              description: l10n.personalizedAdsDescription,
            ),
            
            _buildConsentPoint(
              context,
              icon: Icons.analytics_outlined,
              title: l10n.adAnalytics,
              description: l10n.adAnalyticsDescription,
            ),
            
            _buildConsentPoint(
              context,
              icon: Icons.security,
              title: l10n.dataProtection,
              description: l10n.dataProtectionDescription,
            ),
            
            const SizedBox(height: 16),
            
            // Show/hide details button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
              label: Text(_showDetails ? l10n.hideDetails : l10n.showDetails),
            ),
            
            // Detailed privacy information
            if (_showDetails) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.detailedPrivacyInfo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.gdprCompliantDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.yourRights,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.gdprRightsDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Premium alternative
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.adFreeAlternative,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.upgradeToRemoveAds,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Reject button
        TextButton(
          onPressed: _isProcessing ? null : () => _handleConsentChoice(false),
          child: Text(
            l10n.rejectAds,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        
        // Accept button
        FilledButton(
          onPressed: _isProcessing ? null : () => _handleConsentChoice(true),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.acceptAds),
        ),
      ],
    );
  }

  Widget _buildConsentPoint(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConsentChoice(bool accepted) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      await GdprConsentManager.saveConsent(accepted);
      
      // Refresh consent provider
      ref.invalidate(gdprConsentProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        if (accepted) {
          widget.onConsentGiven?.call();
        } else {
          widget.onConsentRejected?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingConsent),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Show GDPR consent dialog if needed
  static Future<void> showConsentDialogIfNeeded(
    BuildContext context,
    WidgetRef ref, {
    VoidCallback? onConsentGiven,
    VoidCallback? onConsentRejected,
  }) async {
    // Only show for EU users
    if (!GdprConsentManager.isEuUser()) return;
    
    final consentStatus = await GdprConsentManager.getConsentStatus();
    
    if (consentStatus == ConsentStatus.unknown || 
        consentStatus == ConsentStatus.expired) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => GdprConsentDialog(
            onConsentGiven: onConsentGiven,
            onConsentRejected: onConsentRejected,
          ),
        );
      }
    }
  }
}