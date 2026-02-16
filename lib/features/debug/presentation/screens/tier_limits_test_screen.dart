/// 🧪 Admin Debug Screen: Tier Limits Testing
///
/// **Purpose**: Admin-only screen for testing tier limits system without
/// going through full user flows (gaining XP, buying subscriptions, etc.)
///
/// **Features**:
/// - Quick tier switching (Starter/Bronze/Silver/Gold/Platinum)
/// - Quick account switching (Free/Premium/Pro)
/// - XP manipulation (add/remove)
/// - Reset custom exercises/templates
/// - View current limits in real-time
/// - Create temporary exercises for testing
///
/// **Access**: Only visible to users with admin custom claim
///
/// **How to Use**:
/// 1. Settings → Debug → Tier Limits Test
/// 2. Use buttons to change tier/account
/// 3. Verify limits update correctly in UI
/// 4. Test edge cases (Premium + 0 XP, etc.)
///
/// @see lib/core/auth/admin_status_provider.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class TierLimitsTestScreen extends ConsumerStatefulWidget {
  const TierLimitsTestScreen({super.key});

  @override
  ConsumerState<TierLimitsTestScreen> createState() =>
      _TierLimitsTestScreenState();
}

class _TierLimitsTestScreenState extends ConsumerState<TierLimitsTestScreen> {
  UserTier _selectedTier = UserTier.starter;
  AccountTier _selectedAccount = AccountTier.free;
  int _customXP = 0;

  Future<void> _applyTierChange() async {
    try {
      // Apply tier/account overrides to Firestore
      await ref
          .read(userProfileNotifierProvider.notifier)
          .setDebugOverrides(
            debugTier: _selectedTier,
            debugAccount: _selectedAccount,
          );

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        '✅ Test applicato: ${_selectedTier.name.toUpperCase()} + ${_selectedAccount.name.toUpperCase()}',
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(context, '❌ Errore: $e');
    }
  }

  Future<void> _addXP(int amount) async {
    setState(() {
      _customXP += amount;
    });

    // Map XP to tier
    final newTier = UserTier.fromXP(_customXP);
    setState(() {
      _selectedTier = newTier;
    });

    try {
      // Apply override immediately to Firestore
      await ref
          .read(userProfileNotifierProvider.notifier)
          .setDebugOverrides(
            debugTier: newTier,
            debugAccount: _selectedAccount,
          );

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        '✅ XP: $_customXP → Tier: ${newTier.name.toUpperCase()}',
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(context, '❌ Errore: $e');
    }
  }

  Future<void> _resetToZero() async {
    // Reset local state
    setState(() {
      _selectedTier = UserTier.starter;
      _selectedAccount = AccountTier.free;
      _customXP = 0;
    });

    try {
      // Clear all debug overrides from Firestore
      await ref
          .read(userProfileNotifierProvider.notifier)
          .setDebugOverrides(clearAll: true);

      if (!mounted) return;

      SnackBarService.showInfo(context, '🔄 Reset a Starter (0 XP) + Free');
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(context, '❌ Errore reset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlements = ref.watch(tierEntitlementsProvider);
    final currentTier = ref.watch(userTierProvider);
    final currentProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Tier Limits Test'),
        actions: [
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: 'Reset',
            ),
            onPressed: _resetToZero,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current State
            _buildCurrentStateCard(currentTier, currentProfile, entitlements),

            const SizedBox(height: 24),

            // Tier Selection
            _buildSection(
              title: '📊 User Tier (XP-based)',
              child: Column(
                children: [
                  _buildTierButtons(),
                  const SizedBox(height: 12),
                  _buildXPButtons(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Selection
            _buildSection(
              title: '💳 Account Tier (Subscription)',
              child: _buildAccountButtons(),
            ),

            const SizedBox(height: 24),

            // Apply Button
            ElevatedButton(
              onPressed: _applyTierChange,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: context.colors.primary,
              ),
              child: const Text('Apply Changes'),
            ),

            const SizedBox(height: 24),

            // Quick Test Scenarios
            _buildSection(
              title: '⚡ Quick Test Scenarios',
              child: _buildQuickTestButtons(),
            ),

            const SizedBox(height: 24),

            // Expected vs Actual Limits
            _buildSection(
              title: '📋 Expected vs Actual Limits',
              child: _buildLimitsComparison(entitlements),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStateCard(
    UserTier currentTier,
    UserProfile? currentProfile,
    TierEntitlements entitlements,
  ) {
    return Card(
      color: context.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📌 Current State',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('User Tier', currentTier.name.toUpperCase()),
            _buildInfoRow(
              'Account',
              currentProfile?.accountTier.name.toUpperCase() ?? 'N/A',
            ),
            _buildInfoRow(
              'XP',
              currentProfile?.stats['totalXP']?.toString() ?? '0',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Custom Exercises',
              '${entitlements.maxCustomSingleExercises}',
            ),
            _buildInfoRow(
              'Templates (Private)',
              '${entitlements.maxTemplates}',
            ),
            _buildInfoRow(
              'Templates (Public)',
              '${entitlements.maxPublicTemplates}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTierButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: UserTier.values.map((tier) {
        final isSelected = _selectedTier == tier;
        return ChoiceChip(
          label: Text(tier.name.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) async {
            setState(() {
              _selectedTier = tier;
              _customXP = tier.minXP;
            });

            try {
              // Apply override immediately to Firestore for instant feedback
              await ref
                  .read(userProfileNotifierProvider.notifier)
                  .setDebugOverrides(
                    debugTier: tier,
                    debugAccount: _selectedAccount,
                  );
            } catch (e) {
              if (!mounted) return;
              SnackBarService.showError(context, '❌ Errore: $e');
            }
          },
          selectedColor: context.colors.primary,
          backgroundColor: context.colors.surface,
        );
      }).toList(),
    );
  }

  Widget _buildXPButtons() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'XP: $_customXP',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _addXP(100),
          icon: const Icon(AppIcons.add, size: 16),
          label: const Text('+100'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _addXP(500),
          icon: const Icon(AppIcons.add, size: 16),
          label: const Text('+500'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AccountTier.values.map((account) {
        final isSelected = _selectedAccount == account;
        return ChoiceChip(
          label: Text(account.name.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) async {
            setState(() {
              _selectedAccount = account;
            });

            try {
              // Apply override immediately to Firestore for instant feedback
              await ref
                  .read(userProfileNotifierProvider.notifier)
                  .setDebugOverrides(
                    debugTier: _selectedTier,
                    debugAccount: account,
                  );
            } catch (e) {
              if (!mounted) return;
              SnackBarService.showError(context, '❌ Errore: $e');
            }
          },
          selectedColor: account == AccountTier.premium
              ? context.colors.warning
              : context.colors.primary,
          backgroundColor: context.colors.surface,
        );
      }).toList(),
    );
  }

  Widget _buildQuickTestButtons() {
    return Column(
      children: [
        // CRITICAL Test: Premium + 0 XP
        _buildTestButton(
          icon: '🔥',
          label: 'CRITICAL: Premium + 0 XP',
          description: 'Test the main bug fix (Premium should get 999)',
          color: context.colors.error,
          onTap: () {
            setState(() {
              _selectedTier = UserTier.starter;
              _selectedAccount = AccountTier.premium;
              _customXP = 0;
            });
            _applyTierChange();
          },
        ),

        const SizedBox(height: 8),

        // Tier Progression
        _buildTestButton(
          icon: '📈',
          label: 'Simulate Tier Progression',
          description: 'Starter → Bronze → Silver → Gold → Platinum',
          color: context.colors.primary,
          onTap: () {
            // TODO: Animate progression
            SnackBarService.showInfo(context, 'Progressing through tiers...');
          },
        ),

        const SizedBox(height: 8),

        // Reset Everything
        _buildTestButton(
          icon: '🗑️',
          label: 'Reset Custom Exercises',
          description: 'Delete all custom exercises (admin only)',
          color: context.colors.warning,
          onTap: () {
            // TODO: Implement reset
            SnackBarService.showWarning(
              context,
              'Would delete all custom exercises (not implemented yet)',
            );
          },
        ),
      ],
    );
  }

  Widget _buildTestButton({
    required String icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitsComparison(TierEntitlements entitlements) {
    // Calculate expected limits based on selected tier/account
    final expectedSingles = _selectedAccount != AccountTier.free
        ? 999
        : _selectedTier.maxCustomSingleExercises;

    final expectedTemplatesPrivate = _selectedAccount != AccountTier.free
        ? 999
        : _selectedTier.maxTemplates;

    final expectedTemplatesPublic = _selectedAccount != AccountTier.free
        ? 999
        : _selectedTier.maxPublicTemplates;

    return Column(
      children: [
        _buildComparisonRow(
          'Custom Singles',
          expectedSingles,
          entitlements.maxCustomSingleExercises,
        ),
        _buildComparisonRow(
          'Custom Supersets',
          expectedSingles,
          entitlements.maxCustomSupersets,
        ),
        _buildComparisonRow(
          'Custom Dropsets',
          expectedSingles,
          entitlements.maxCustomDropsets,
        ),
        _buildComparisonRow(
          'Custom Rest-Pause',
          expectedSingles,
          entitlements.maxCustomRestPause,
        ),
        _buildComparisonRow(
          'Templates (Private)',
          expectedTemplatesPrivate,
          entitlements.maxTemplates,
        ),
        _buildComparisonRow(
          'Templates (Public)',
          expectedTemplatesPublic,
          entitlements.maxPublicTemplates,
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, int expected, int actual) {
    final matches = expected == actual;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              '$expected',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$actual',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: matches ? context.colors.success : context.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Icon(
            matches ? AppIcons.checkCircle : AppIcons.error,
            size: 16,
            color: matches ? context.colors.success : context.colors.error,
          ),
        ],
      ),
    );
  }
}
