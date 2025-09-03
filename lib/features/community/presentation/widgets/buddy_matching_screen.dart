import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/buddy_matching_provider.dart';
import 'package:gymbro_flutter_new/features/community/data/services/demo_profiles_loader.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class BuddyMatchingScreen extends ConsumerStatefulWidget {
  const BuddyMatchingScreen({super.key});

  @override
  ConsumerState<BuddyMatchingScreen> createState() => _BuddyMatchingScreenState();
}

class _BuddyMatchingScreenState extends ConsumerState<BuddyMatchingScreen> 
    with TickerProviderStateMixin {
  
  final List<Alignment> _cardAlignments = [];
  final List<double> _cardRotations = [];
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final potentialMatches = ref.watch(potentialMatchesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trova il tuo Buddy'),
        centerTitle: true,
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _loadDemoProfiles(context),
      //   backgroundColor: theme.colorScheme.tertiary,
      //   icon: const Icon(Icons.science),
      //   label: const Text('Demo Profiles'),
      //   tooltip: 'Carica 10 Profili Demo per Testing',
      // ),
      body: potentialMatches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Errore: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(potentialMatchesProvider),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
        data: (profiles) {
          if (profiles.isEmpty) {
            return _buildNoMoreProfiles(context, theme);
          }
          
          // Initialize alignments and rotations for each card
          while (_cardAlignments.length < profiles.length) {
            _cardAlignments.add(Alignment.center);
            _cardRotations.add(0);
          }
          
          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
              
              // Cards stack
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: profiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final profile = entry.value;
                        
                        if (index > 2) return const SizedBox.shrink(); // Show only top 3 cards
                        
                        return Positioned.fill(
                          child: GestureDetector(
                            onPanUpdate: index == 0 ? (details) {
                              setState(() {
                                _cardAlignments[index] = Alignment(
                                  _cardAlignments[index].x + details.delta.dx * 2 / constraints.maxWidth,
                                  _cardAlignments[index].y + details.delta.dy * 2 / constraints.maxHeight,
                                );
                                _cardRotations[index] = _cardAlignments[index].x * 0.3;
                              });
                            } : null,
                            onPanEnd: index == 0 ? (details) {
                              final x = _cardAlignments[index].x;
                              
                              if (x.abs() > 0.4) {
                                // Swipe threshold reached
                                _handleSwipe(profile, x > 0);
                                setState(() {
                                  _cardAlignments[index] = Alignment(x > 0 ? 2 : -2, 0);
                                });
                                
                                // Remove card after animation
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  if (mounted) {
                                    setState(() {
                                      profiles.removeAt(0);
                                      _cardAlignments.removeAt(0);
                                      _cardRotations.removeAt(0);
                                    });
                                  }
                                });
                              } else {
                                // Return to center
                                setState(() {
                                  _cardAlignments[index] = Alignment.center;
                                  _cardRotations[index] = 0;
                                });
                              }
                            } : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              alignment: _cardAlignments[index],
                              transform: Matrix4.identity()
                                ..translate(0.0, index * 5.0)
                                ..scale(1 - index * 0.05)
                                ..rotateZ(_cardRotations[index]),
                              child: _buildProfileCard(context, theme, profile, index == 0),
                            ),
                          ),
                        );
                      }).toList().reversed.toList(),
                    );
                  },
                ),
              ),
              
              // Action buttons
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Skip button - COMMENTED OUT
                    // FloatingActionButton(
                    //   heroTag: 'skip',
                    //   backgroundColor: Colors.grey.shade200,
                    //   onPressed: profiles.isNotEmpty ? () => _handleSwipe(profiles.first, false) : null,
                    //   child: const Icon(Icons.close, color: Colors.red, size: 32),
                    // ),
                    
                    // Super like button (future feature) - COMMENTED OUT
                    // FloatingActionButton(
                    //   heroTag: 'super',
                    //   backgroundColor: Colors.blue.shade100,
                    //   onPressed: null, // Disabled for now
                    //   child: const Icon(Icons.star, color: Colors.blue, size: 32),
                    // ),
                    
                    // Like button - COMMENTED OUT
                    // FloatingActionButton(
                    //   heroTag: 'like',
                    //   backgroundColor: Colors.green.shade100,
                    //   onPressed: profiles.isNotEmpty ? () => _handleSwipe(profiles.first, true) : null,
                    //   child: const Icon(Icons.favorite, color: Colors.green, size: 32),
                    // ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context, ThemeData theme, BuddyProfile profile, bool isTop) {
    return Card(
      elevation: isTop ? 8 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      profile.userId.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Name/Username
                  Text(
                    'User ${profile.userId.substring(0, 6)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Location
                  if (profile.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          profile.location!,
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ],
                  
                  // Instagram handle with click to open
                  if (profile.instagramHandle != null) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _openInstagram(profile.instagramHandle!),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE1306C), Color(0xFFF77737), Color(0xFFFCAF45)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '@${profile.instagramHandle}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Profile details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      Text(
                        profile.bio!,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Fitness level
                    _buildInfoChip(
                      context,
                      Icons.fitness_center,
                      _getLevelLabel(profile.preferences.fitnessLevel),
                      theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    
                    // Goals
                    if (profile.preferences.goals.isNotEmpty) ...[
                      Text(
                        'Obiettivi',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.preferences.goals.map((goal) => 
                          Chip(
                            label: Text(_getGoalLabel(goal)),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Schedule
                    if (profile.preferences.workoutSchedule.isNotEmpty) ...[
                      Text(
                        'Orari preferiti',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.preferences.workoutSchedule.map((time) => 
                          Chip(
                            label: Text(_getTimeLabel(time)),
                            backgroundColor: theme.colorScheme.tertiaryContainer,
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Personality
                    _buildInfoChip(
                      context,
                      Icons.psychology,
                      _getPersonalityLabel(profile.preferences.personalityType),
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoMoreProfiles(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nessun nuovo profilo',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Torna più tardi per nuovi match!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => ref.refresh(potentialMatchesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Ricarica'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleSwipe(BuddyProfile profile, bool isLike) async {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Save swipe to database
    await ref.read(buddyMatchingProvider.notifier).swipeProfile(profile.userId, isLike);
    
    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLike ? '❤️ Like inviato!' : '⏭️ Profilo saltato'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  Future<void> _openInstagram(String handle) async {
    final cleanHandle = handle.replaceAll('@', '');
    final url = Uri.parse('https://instagram.com/$cleanHandle');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non riesco ad aprire Instagram'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  // Helper methods for labels
  String _getLevelLabel(dynamic level) {
    return level.toString().split('.').last;
  }
  
  String _getGoalLabel(dynamic goal) {
    return goal.toString().split('.').last;
  }
  
  String _getTimeLabel(dynamic time) {
    return time.toString().split('.').last;
  }
  
  String _getPersonalityLabel(dynamic type) {
    return type.toString().split('.').last;
  }
  
  Future<void> _loadDemoProfiles(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Caricamento profili demo...'),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
      
      final service = DemoProfilesLoader();
      await service.loadDemoProfiles();
      
      // Refresh the provider to show new profiles
      ref.refresh(potentialMatchesProvider);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('✅ 10 profili demo caricati!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}