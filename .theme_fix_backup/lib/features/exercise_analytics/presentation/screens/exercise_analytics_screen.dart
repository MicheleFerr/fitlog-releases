/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: exercise_analytics
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Exercise Analytics screen - Analisi e statistiche per singoli esercizi
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Schermata per analizzare le statistiche di singoli esercizi
class ExerciseAnalyticsScreen extends ConsumerStatefulWidget {
  const ExerciseAnalyticsScreen({super.key});

  @override
  ConsumerState<ExerciseAnalyticsScreen> createState() => _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends ConsumerState<ExerciseAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data per dimostrare la funzionalità
  final List<_ExerciseData> _mockExercises = [
    _ExerciseData(
      name: 'Panca Piana',
      category: 'Petto',
      lastWeight: 80.0,
      maxWeight: 90.0,
      totalVolume: 12000.0,
      sessionsCount: 15,
      avgRpe: 7.5,
      trend: _Trend.increasing,
    ),
    _ExerciseData(
      name: 'Squat',
      category: 'Gambe',
      lastWeight: 100.0,
      maxWeight: 120.0,
      totalVolume: 18000.0,
      sessionsCount: 20,
      avgRpe: 8.0,
      trend: _Trend.stable,
    ),
    _ExerciseData(
      name: 'Stacchi',
      category: 'Schiena',
      lastWeight: 110.0,
      maxWeight: 130.0,
      totalVolume: 15000.0,
      sessionsCount: 12,
      avgRpe: 8.5,
      trend: _Trend.increasing,
    ),
    _ExerciseData(
      name: 'Military Press',
      category: 'Spalle',
      lastWeight: 50.0,
      maxWeight: 60.0,
      totalVolume: 6000.0,
      sessionsCount: 10,
      avgRpe: 7.0,
      trend: _Trend.decreasing,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<_ExerciseData> get _filteredExercises {
    if (_searchQuery.isEmpty) return _mockExercises;
    return _mockExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(_searchQuery) ||
             exercise.category.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Analytics Esercizi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchBar(context, l10n, colorScheme),
            ),

            // Statistics Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsOverview(colorScheme),
            ),

            const SizedBox(height: 16),

            // Exercises List
            Expanded(
              child: _buildExercisesList(context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cerca esercizi o categorie...',
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.2,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.8),
            colorScheme.secondaryContainer.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Esercizi Tracciati',
              _mockExercises.length.toString(),
              Icons.fitness_center,
              colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Volume Totale',
              '${_mockExercises.fold<double>(0, (sum, ex) => sum + ex.totalVolume).toInt()}kg',
              Icons.trending_up,
              colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Sessioni',
              _mockExercises.fold<int>(0, (sum, ex) => sum + ex.sessionsCount).toString(),
              Icons.history,
              colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context, ColorScheme colorScheme) {
    final exercises = _filteredExercises;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun esercizio trovato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(context, exercise, colorScheme, index);
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    _ExerciseData exercise,
    ColorScheme colorScheme,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
                    colorScheme.surfaceContainer.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showExerciseDetails(context, exercise),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Exercise Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise.category,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trend Indicator
                            _buildTrendIndicator(exercise.trend, colorScheme),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: [
                            _buildMiniStat(
                              'Max',
                              '${exercise.maxWeight}kg',
                              colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            _buildMiniStat(
                              'Volume',
                              '${exercise.totalVolume.toInt()}kg',
                              colorScheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            _buildMiniStat(
                              'RPE Avg',
                              exercise.avgRpe.toString(),
                              colorScheme.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendIndicator(_Trend trend, ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (trend) {
      case _Trend.increasing:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case _Trend.decreasing:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case _Trend.stable:
        icon = Icons.trending_flat;
        color = colorScheme.onSurface.withValues(alpha: 0.6);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showExerciseDetails(BuildContext context, _ExerciseData exercise) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Categoria: ${exercise.category}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Detailed Stats
                        Text(
                          'Statistiche Dettagliate',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow('Peso Massimo', '${exercise.maxWeight} kg'),
                        _buildDetailRow('Ultimo Peso', '${exercise.lastWeight} kg'),
                        _buildDetailRow('Volume Totale', '${exercise.totalVolume.toInt()} kg'),
                        _buildDetailRow('Sessioni', exercise.sessionsCount.toString()),
                        _buildDetailRow('RPE Medio', exercise.avgRpe.toString()),

                        const SizedBox(height: 24),
                        Text(
                          'Funzionalità in arrivo:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Grafici dei progressi\n• Storico completo\n• Analisi forme\n• Confronti temporali',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtri'),
        content: const Text('Funzionalità di filtro in arrivo:\n• Per categoria muscolare\n• Per periodo temporale\n• Per livello di difficoltà'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Mock data classes
class _ExerciseData {

  _ExerciseData({
    required this.name,
    required this.category,
    required this.lastWeight,
    required this.maxWeight,
    required this.totalVolume,
    required this.sessionsCount,
    required this.avgRpe,
    required this.trend,
  });
  final String name;
  final String category;
  final double lastWeight;
  final double maxWeight;
  final double totalVolume;
  final int sessionsCount;
  final double avgRpe;
  final _Trend trend;
}

enum _Trend { increasing, decreasing, stable }