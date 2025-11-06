/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/demo_profiles.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/verification_badges.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/city_picker_widget.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/ice_breaker_widget.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/report_user_dialog.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/super_like_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class DevelopmentScreen extends ConsumerStatefulWidget {
  const DevelopmentScreen({super.key});

  @override
  ConsumerState<DevelopmentScreen> createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends ConsumerState<DevelopmentScreen> {
  List<BuddyProfile> _demoProfiles = [];
  bool _isLoading = false;
  int _superLikesDemo = 3;
  bool _showSuperLikeAnimation = false;

  @override
  void initState() {
    super.initState();
    _loadDemoProfiles();
  }

  void _loadDemoProfiles() {
    setState(() {
      _isLoading = true;
      _demoProfiles = DemoProfiles.allProfiles;
      _isLoading = false;
    });
  }

  void _clearDemoData() {
    setState(() {
      _demoProfiles.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).clearDemoData),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _testSuperLike() {
    if (_superLikesDemo > 0) {
      setState(() {
        _superLikesDemo--;
        _showSuperLikeAnimation = true;
      });
      
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _showSuperLikeAnimation = false;
          });
        }
      });
    }
  }

  void _resetSuperLikes() {
    setState(() {
      _superLikesDemo = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(AppIcons.developerMode, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.developmentMode),
          ],
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demo Profiles Section
                _buildSectionCard(
                  context,
                  title: l10n.demoProfiles,
                  icon: AppIcons.people,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadDemoProfiles,
                            icon: const Icon(AppIcons.refresh),
                            label: Text(l10n.seedDemoData),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearDemoData,
                            icon: const Icon(AppIcons.clear),
                            label: Text(l10n.clearDemoData),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_demoProfiles.isNotEmpty)
                      _buildDemoProfilesList(),
                  ],
                ),
                const SizedBox(height: 24),

                // Super Like Testing Section
                _buildSectionCard(
                  context,
                  title: 'Super Like Testing',
                  icon: AppIcons.star,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SuperLikeButton(
                          superLikesRemaining: _superLikesDemo,
                          onSuperLike: _testSuperLike,
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _testSuperLike,
                              child: const Text('Test Super Like'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resetSuperLikes,
                              child: const Text('Reset (3/3)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // City Picker Testing Section
                _buildSectionCard(
                  context,
                  title: 'City Picker Testing',
                  icon: AppIcons.locationCity,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        CityPickerWidget.show(
                          context: context,
                          onCitySelected: (city, zone) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selezionato: ${city.name}${zone != null ? ' - $zone' : ''}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(AppIcons.location),
                      label: Text(AppLocalizations.of(context).openCityPicker),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ice Breaker Testing Section
                _buildSectionCard(
                  context,
                  title: 'Ice Breaker Testing',
                  icon: AppIcons.message,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        IceBreakerWidget.show(
                          context: context,
                          userId: 'demo_user',
                          targetUserId: 'demo_target',
                          onSendMessage: (message) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ice Breaker: $message'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(AppIcons.acUnit),
                      label: Text(AppLocalizations.of(context).openIceBreakers),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Feature Status Section
                _buildSectionCard(
                  context,
                  title: 'Feature Status',
                  icon: AppIcons.checklist,
                  children: [
                    _buildFeatureStatus('Multi-purpose Matching', true),
                    _buildFeatureStatus('Italian Cities System', true),
                    _buildFeatureStatus('Super Likes', true),
                    _buildFeatureStatus('Profile Boost', true),
                    _buildFeatureStatus('Verification Badges', true),
                    _buildFeatureStatus('Ice Breakers', true),
                    _buildFeatureStatus('Report/Block System', true),
                    _buildFeatureStatus('Workout Together Tracking', true),
                    _buildFeatureStatus('Trust Score System', true),
                    _buildFeatureStatus('Demo Profile System', true),
                  ],
                ),
                
                const SizedBox(height: 100), // Space for overlay
              ],
            ),
          ),
          
          // Super Like Overlay
          if (_showSuperLikeAnimation)
            const Positioned.fill(
              child: SuperLikeOverlay(isVisible: true),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDemoProfilesList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _demoProfiles.length,
        itemBuilder: (context, index) {
          final profile = _demoProfiles[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: _buildDemoProfileCard(profile),
          );
        },
      ),
    );
  }

  Widget _buildDemoProfileCard(BuddyProfile profile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showProfileDetails(profile),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image and badges
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profile.photoURL != null
                        ? NetworkImage(profile.photoURL!)
                        : null,
                    child: profile.photoURL == null
                        ? Icon(AppIcons.person, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: VerificationBadges(profile: profile, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Name and city
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                profile.preferences.cityName ?? 'Unknown',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Connection type badges
              ConnectionTypeBadges(profile: profile, compact: true),
              
              const Spacer(),
              
              // Trust score
              TrustScoreIndicator(
                trustScore: profile.trustScore,
                showText: false,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDetails(BuddyProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerificationBadges(profile: profile, showText: true),
            const SizedBox(height: 8),
            TrustScoreIndicator(trustScore: profile.trustScore),
            const SizedBox(height: 8),
            ConnectionTypeBadges(profile: profile),
            const SizedBox(height: 16),
            if (profile.preferences.bio != null) ...[
              Text(
                'Bio:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(profile.preferences.bio!),
              const SizedBox(height: 8),
            ],
            Text('Partnerships: ${profile.partnershipsCount}'),
            Text('Success Rate: ${profile.successRate.toStringAsFixed(1)}%'),
            Text('Workouts: ${profile.totalWorkouts}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
          if (!profile.isVerified)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ReportUserDialog.show(
                  context: context,
                  targetProfile: profile,
                  onReport: (reason, description) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demo: Reported ${profile.displayName} for $reason'),
                      ),
                    );
                  },
                );
              },
              child: const Text('Test Report'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(String feature, bool isImplemented) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isImplemented ? Icons.check_circle : AppIcons.radioButtonUnchecked,
            size: 16,
            color: isImplemented ? const Color(0xFF4CAF50) : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
