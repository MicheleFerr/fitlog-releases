import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/buddy_matching_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class BuddyOnboardingScreen extends ConsumerStatefulWidget {
  const BuddyOnboardingScreen({super.key});

  @override
  ConsumerState<BuddyOnboardingScreen> createState() => _BuddyOnboardingScreenState();
}

class _BuddyOnboardingScreenState extends ConsumerState<BuddyOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Form data
  final _preferences = BuddyPreferences(
    workoutSchedule: [],
    fitnessLevel: FitnessLevel.intermediate,
    goals: [],
    preferredActivities: [],
    maxDistance: 10,
    ageRange: const AgeRange(min: 18, max: 99),
    genderPreference: GenderPreference.any,
    personalityType: PersonalityType.supportive,
  );
  
  String? _instagramHandle;
  String? _location;
  String? _bio;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _savePreferences();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    // Salva preferences con Instagram handle
    await ref.read(buddyMatchingProvider.notifier).savePreferences(
      _preferences,
      instagramHandle: _instagramHandle,
      location: _location,
      bio: _bio,
    );
    
    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate completion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 7,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                context.colors.primary,
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(),
                  _SchedulePage(
                    schedule: _preferences.workoutSchedule,
                    onChanged: (schedule) => setState(() {
                      _preferences.workoutSchedule.clear();
                      _preferences.workoutSchedule.addAll(schedule);
                    }),
                  ),
                  _LevelAndGoalsPage(
                    level: _preferences.fitnessLevel,
                    goals: _preferences.goals,
                    onLevelChanged: (level) => setState(() {
                      _preferences.fitnessLevel = level;
                    }),
                    onGoalsChanged: (goals) => setState(() {
                      _preferences.goals.clear();
                      _preferences.goals.addAll(goals);
                    }),
                  ),
                  _LocationPage(
                    location: _location,
                    maxDistance: _preferences.maxDistance,
                    onLocationChanged: (location) => setState(() {
                      _location = location;
                    }),
                    onDistanceChanged: (distance) => setState(() {
                      _preferences.maxDistance = distance;
                    }),
                  ),
                  _PersonalityPage(
                    personality: _preferences.personalityType,
                    onChanged: (personality) => setState(() {
                      _preferences.personalityType = personality;
                    }),
                  ),
                  _SocialPage(
                    instagramHandle: _instagramHandle,
                    bio: _bio,
                    onInstagramChanged: (handle) => setState(() {
                      _instagramHandle = handle;
                    }),
                    onBioChanged: (bio) => setState(() {
                      _bio = bio;
                    }),
                  ),
                  _ReviewPage(
                    preferences: _preferences,
                    instagramHandle: _instagramHandle,
                    location: _location,
                    bio: _bio,
                  ),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    child: const Text('Indietro'),
                  ),
                  FilledButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage < 6 ? 'Avanti' : 'Completa'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 1: Welcome
class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🤝',
            style: TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24),
          Text(
            'Trova il tuo Workout Buddy',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Rispondi a queste domande per trovare il partner di allenamento perfetto per te',
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildFeature(context, AppIcons.location, 'Match basato sulla zona'),
                const SizedBox(height: 12),
                _buildFeature(context, AppIcons.schedule, 'Orari compatibili'),
                const SizedBox(height: 12),
                _buildFeature(context, AppIcons.workout, 'Stesso livello fitness'),
                SizedBox(height: 12),
                _buildFeature(context, AppIcons.camera, 'Connetti Instagram (opzionale)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.primary),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}

// Page 2: Schedule
class _SchedulePage extends StatelessWidget {

  const _SchedulePage({
    required this.schedule,
    required this.onChanged,
  });
  final List<WorkoutTime> schedule;
  final Function(List<WorkoutTime>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Quando ti alleni di solito? ⏰',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seleziona tutti gli orari in cui sei disponibile',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildTimeOption(
                  context,
                  WorkoutTime.earlyMorning,
                  '🌅 Mattina Presto',
                  '5:00 - 7:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.morning,
                  '☀️ Mattina',
                  '7:00 - 11:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.lunch,
                  '🍽️ Pausa Pranzo',
                  '12:00 - 14:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.afternoon,
                  '🌤️ Pomeriggio',
                  '14:00 - 18:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.evening,
                  '🌆 Sera',
                  '18:00 - 21:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.lateEvening,
                  '🌙 Sera Tardi',
                  '21:00 - 23:00',
                ),
                _buildTimeOption(
                  context,
                  WorkoutTime.weekend,
                  '📅 Weekend',
                  'Sabato e Domenica',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(
    BuildContext context,
    WorkoutTime time,
    String title,
    String subtitle,
  ) {
    final isSelected = schedule.contains(time);
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected 
              ? context.colors.primary
              : context.colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? AppIcons.check : AppIcons.clock,
            color: isSelected ? Colors.white : null,
            size: 20,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          final newSchedule = List<WorkoutTime>.from(schedule);
          if (isSelected) {
            newSchedule.remove(time);
          } else {
            newSchedule.add(time);
          }
          onChanged(newSchedule);
        },
      ),
    );
  }
}

// Page 3: Level and Goals
class _LevelAndGoalsPage extends StatelessWidget {

  const _LevelAndGoalsPage({
    required this.level,
    required this.goals,
    required this.onLevelChanged,
    required this.onGoalsChanged,
  });
  final FitnessLevel level;
  final List<FitnessGoal> goals;
  final Function(FitnessLevel) onLevelChanged;
  final Function(List<FitnessGoal>) onGoalsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Il tuo livello fitness 💪',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          _buildLevelSelector(context),
          SizedBox(height: 40),
          Text(
            'I tuoi obiettivi 🎯',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seleziona fino a 3 obiettivi principali',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildGoalsGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector(BuildContext context) {
    return RadioGroup<FitnessLevel>(
      groupValue: level,
      onChanged: (value) {
        if (value != null) {
          onLevelChanged(value);
        }
      },
      child: Column(
        children: [
          _buildLevelOption(
            context,
            FitnessLevel.beginner,
            '🌱 Principiante',
            '0-6 mesi di esperienza',
          ),
          _buildLevelOption(
            context,
            FitnessLevel.intermediate,
            '💪 Intermedio',
            '6 mesi - 2 anni',
          ),
          _buildLevelOption(
            context,
            FitnessLevel.advanced,
            '🔥 Avanzato',
            '2+ anni di esperienza',
          ),
        ],
      ),
    );
  }

  Widget _buildLevelOption(
    BuildContext context,
    FitnessLevel optionLevel,
    String title,
    String subtitle,
  ) {
    final isSelected = level == optionLevel;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected 
        ? context.colors.primaryContainer.withValues(alpha: 0.3)
        : null,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Radio<FitnessLevel>(
          value: optionLevel,
        ),
        onTap: () => onLevelChanged(optionLevel),
      ),
    );
  }

  Widget _buildGoalsGrid(BuildContext context) {
    final allGoals = [
      (FitnessGoal.muscleGain, '💪 Massa Muscolare'),
      (FitnessGoal.weightLoss, '⚖️ Perdita Peso'),
      (FitnessGoal.strength, '🏋️ Forza'),
      (FitnessGoal.endurance, '🏃 Resistenza'),
      (FitnessGoal.flexibility, '🧘 Flessibilità'),
      (FitnessGoal.generalFitness, '✨ Fitness Generale'),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allGoals.length,
      itemBuilder: (context, index) {
        final goal = allGoals[index];
        final isSelected = goals.contains(goal.$1);
        final canSelect = goals.length < 3 || isSelected;

        return InkWell(
          onTap: canSelect ? () {
            final newGoals = List<FitnessGoal>.from(goals);
            if (isSelected) {
              newGoals.remove(goal.$1);
            } else {
              newGoals.add(goal.$1);
            }
            onGoalsChanged(newGoals);
          } : null,
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected 
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                  ? context.colors.primary
                  : context.colors.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                goal.$2,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Page 4: Location
class _LocationPage extends StatelessWidget {

  const _LocationPage({
    required this.location,
    required this.maxDistance,
    required this.onLocationChanged,
    required this.onDistanceChanged,
  });
  final String? location;
  final double maxDistance;
  final Function(String) onLocationChanged;
  final Function(double) onDistanceChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Dove ti alleni? 📍',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Inserisci la tua zona o quartiere',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              labelText: 'Zona/Quartiere',
              hintText: 'es. Milano Centro, Porta Romana',
              prefixIcon: Icon(AppIcons.location),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onLocationChanged,
          ),
          SizedBox(height: 40),
          Text(
            'Distanza massima: ${maxDistance.toInt()} km',
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Slider(
            value: maxDistance,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${maxDistance.toInt()} km',
            onChanged: onDistanceChanged,
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.info,
                  color: context.colors.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Useremo questa informazione per trovare buddy nella tua zona',
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Page 5: Personality
class _PersonalityPage extends StatelessWidget {

  const _PersonalityPage({
    required this.personality,
    required this.onChanged,
  });
  final PersonalityType personality;
  final Function(PersonalityType) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Che tipo di partner cerchi? 🤔',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _buildPersonalityOption(
            context,
            PersonalityType.competitive,
            '🔥 Competitivo',
            'Mi piace la sfida e superare i limiti',
            'Cerco qualcuno che mi spinga al massimo',
          ),
          const SizedBox(height: 16),
          _buildPersonalityOption(
            context,
            PersonalityType.supportive,
            '🤗 Supportivo',
            'Preferisco incoraggiamento reciproco',
            'Cerco un ambiente positivo e motivante',
          ),
          const SizedBox(height: 16),
          _buildPersonalityOption(
            context,
            PersonalityType.mixed,
            '⚖️ Bilanciato',
            'Un mix di competizione e supporto',
            'Il meglio di entrambi i mondi',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityOption(
    BuildContext context,
    PersonalityType type,
    String title,
    String subtitle,
    String description,
  ) {
    final isSelected = personality == type;
    
    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? context.colors.primaryContainer.withValues(alpha: 0.3)
            : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
              ? context.colors.primary
              : context.colors.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(AppIcons.complete, color: Colors.green),
              ],
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 6: Social
class _SocialPage extends StatelessWidget {

  const _SocialPage({
    required this.instagramHandle,
    required this.bio,
    required this.onInstagramChanged,
    required this.onBioChanged,
  });
  final String? instagramHandle;
  final String? bio;
  final Function(String) onInstagramChanged;
  final Function(String) onBioChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Connetti i tuoi social 📱',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Opzionale - aiuta i buddy a conoscerti meglio',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          
          // Instagram
          TextField(
            decoration: InputDecoration(
              labelText: 'Instagram Username',
              hintText: '@tuousername',
              prefixIcon: const Icon(AppIcons.camera),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'I match potranno vedere il tuo profilo Instagram',
            ),
            onChanged: onInstagramChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Bio
          TextField(
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Presentati brevemente',
              hintText: 'Racconta qualcosa di te, i tuoi obiettivi, cosa cerchi in un workout buddy...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            onChanged: onBioChanged,
          ),
          
          SizedBox(height: 24),
          
          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.lockOutline,
                  color: context.colors.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy garantita',
                        style: context.textTheme.titleSmall,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Il tuo Instagram sarà visibile solo ai match confermati. Non salviamo mai le tue foto.',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Page 7: Review
class _ReviewPage extends StatelessWidget {

  const _ReviewPage({
    required this.preferences,
    required this.instagramHandle,
    required this.location,
    required this.bio,
  });
  final BuddyPreferences preferences;
  final String? instagramHandle;
  final String? location;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Riepilogo ✅',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Controlla le tue preferenze',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildReviewSection(
                  context,
                  'Orari',
                  preferences.workoutSchedule.map((t) => 
                    _getTimeLabel(t)).join(', '),
                ),
                _buildReviewSection(
                  context,
                  'Livello',
                  _getLevelLabel(preferences.fitnessLevel),
                ),
                _buildReviewSection(
                  context,
                  'Obiettivi',
                  preferences.goals.map((g) => 
                    _getGoalLabel(g)).join(', '),
                ),
                if (location != null && location!.isNotEmpty)
                  _buildReviewSection(
                    context,
                    'Zona',
                    '$location (max ${preferences.maxDistance.toInt()} km)',
                  ),
                _buildReviewSection(
                  context,
                  'Tipo di partner',
                  _getPersonalityLabel(preferences.personalityType),
                ),
                if (instagramHandle != null && instagramHandle!.isNotEmpty)
                  _buildReviewSection(
                    context,
                    'Instagram',
                    '@$instagramHandle',
                  ),
                if (bio != null && bio!.isNotEmpty)
                  _buildReviewSection(
                    context,
                    'Bio',
                    bio!,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🎉 Tutto pronto! Clicca "Completa" per iniziare a trovare il tuo workout buddy perfetto.',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeLabel(WorkoutTime time) {
    switch (time) {
      case WorkoutTime.earlyMorning:
        return 'Mattina presto';
      case WorkoutTime.morning:
        return 'Mattina';
      case WorkoutTime.lunch:
        return 'Pranzo';
      case WorkoutTime.afternoon:
        return 'Pomeriggio';
      case WorkoutTime.evening:
        return 'Sera';
      case WorkoutTime.lateEvening:
        return 'Sera tardi';
      case WorkoutTime.weekend:
        return 'Weekend';
    }
  }

  String _getLevelLabel(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return 'Principiante';
      case FitnessLevel.intermediate:
        return 'Intermedio';
      case FitnessLevel.advanced:
        return 'Avanzato';
    }
  }

  String _getGoalLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.muscleGain:
        return 'Massa muscolare';
      case FitnessGoal.weightLoss:
        return 'Perdita peso';
      case FitnessGoal.strength:
        return 'Forza';
      case FitnessGoal.endurance:
        return 'Resistenza';
      case FitnessGoal.flexibility:
        return 'Flessibilità';
      case FitnessGoal.generalFitness:
        return 'Fitness generale';
    }
  }

  String _getPersonalityLabel(PersonalityType type) {
    switch (type) {
      case PersonalityType.competitive:
        return 'Competitivo';
      case PersonalityType.supportive:
        return 'Supportivo';
      case PersonalityType.mixed:
        return 'Bilanciato';
    }
  }
}
