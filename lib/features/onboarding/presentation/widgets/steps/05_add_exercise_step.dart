import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AddExerciseStep extends StatefulWidget {

  const AddExerciseStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  State<AddExerciseStep> createState() => _AddExerciseStepState();
}

class _AddExerciseStepState extends State<AddExerciseStep> with TickerProviderStateMixin {
  bool _showDemo = false;
  bool _isSearching = false;
  bool _isCompleted = false;
  String _searchText = '';
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _mockExercises = [
    {
      'id': 'panca_piana',
      'nome': 'Panca Piana',
      'nameEn': 'Bench Press',
      'focus': 'PETTO, TRIC, DELT_ANT',
      'tipoEsercizio': 'Compound',
      'tipoEsercizioEn': 'Compound',
      'difficolta': 'Intermedio',
      'difficoltaEn': 'Intermediate',
      'attrezzatura': 'Bilanciere',
      'attrezzaturaEn': 'Barbell'
    },
    {
      'id': 'distensioni_manubri',
      'nome': 'Distensioni Manubri',
      'nameEn': 'Dumbbell Press',
      'focus': 'PETTO, TRIC, DELT_ANT',
      'tipoEsercizio': 'Compound',
      'tipoEsercizioEn': 'Compound',
      'difficolta': 'Intermedio',
      'difficoltaEn': 'Intermediate',
      'attrezzatura': 'Manubri',
      'attrezzaturaEn': 'Dumbbells'
    },
    {
      'id': 'croci_cavi',
      'nome': 'Croci ai Cavi',
      'nameEn': 'Cable Flyes',
      'focus': 'PETTO',
      'tipoEsercizio': 'Isolamento',
      'tipoEsercizioEn': 'Isolation',
      'difficolta': 'Intermedio',
      'difficoltaEn': 'Intermediate',
      'attrezzatura': 'Cavi',
      'attrezzaturaEn': 'Cables'
    },
    {
      'id': 'flessioni',
      'nome': 'Flessioni',
      'nameEn': 'Push Ups',
      'focus': 'PETTO, TRIC, DELT_ANT',
      'tipoEsercizio': 'Compound',
      'tipoEsercizioEn': 'Compound',
      'difficolta': 'Base',
      'difficoltaEn': 'Beginner',
      'attrezzatura': 'Corpo Libero',
      'attrezzaturaEn': 'Bodyweight'
    },
    {
      'id': 'french_press',
      'nome': 'French Press',
      'nameEn': 'French Press',
      'focus': 'TRIC',
      'tipoEsercizio': 'Isolamento',
      'tipoEsercizioEn': 'Isolation',
      'difficolta': 'Intermedio',
      'difficoltaEn': 'Intermediate',
      'attrezzatura': 'Bilanciere EZ',
      'attrezzaturaEn': 'EZ Bar'
    }
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startDemo() {
    setState(() {
      _showDemo = true;
    });
    _slideController.forward();
  }

  void _simulateSearch(String text) {
    if (text.isEmpty) return;

    setState(() {
      _searchText = text;
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        _fadeController.forward();
      }
    });
  }

  void _selectExercise() {
    setState(() {
      _isCompleted = true;
    });
  }

  List<Map<String, dynamic>> get _filteredExercises {
    if (_searchText.isEmpty) return _mockExercises;
    return _mockExercises.where((exercise) {
      final nome = exercise['nome'].toString().toLowerCase();
      final nameEn = exercise['nameEn'].toString().toLowerCase();
      final searchLower = _searchText.toLowerCase();
      return nome.contains(searchLower) || nameEn.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.workout,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.addExerciseStepTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addExerciseStepDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Interactive Demo Section
          if (!_showDemo) ...[
            FilledButton.icon(
              onPressed: _startDemo,
              icon: const Icon(AppIcons.play),
              label: Text(l10n.onboardingTryItOut),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ] else ...[
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Bar (only Database tab for simplicity)
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Database',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Custom',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Superset',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mock Search Bar
                    _MockSearchBar(
                      colorScheme: colorScheme,
                      theme: theme,
                      l10n: l10n,
                      onSearch: _simulateSearch,
                      isSearching: _isSearching,
                    ),
                    const SizedBox(height: 16),

                    // Search Results
                    if (_searchText.isNotEmpty && !_isSearching) ...[
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _MockSearchResults(
                          exercises: _filteredExercises,
                          colorScheme: colorScheme,
                          theme: theme,
                          l10n: l10n,
                          onSelect: _isCompleted ? null : _selectExercise,
                          isCompleted: _isCompleted,
                        ),
                      ),
                    ],

                    if (_isCompleted) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.complete,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.onboardingCompleted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MockSearchBar extends StatefulWidget {

  const _MockSearchBar({
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    required this.onSearch,
    required this.isSearching,
  });
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final Function(String) onSearch;
  final bool isSearching;

  @override
  State<_MockSearchBar> createState() => _MockSearchBarState();
}

class _MockSearchBarState extends State<_MockSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.colorScheme.surface,
        border: Border.all(
          color: widget.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.l10n.onboardingSearchExercises,
          prefixIcon: Icon(
            Icons.search,
            color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: widget.isSearching
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.colorScheme.primary,
                  ),
                ),
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: widget.theme.textTheme.bodyMedium?.copyWith(
            color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _MockSearchResults extends StatelessWidget {

  const _MockSearchResults({
    required this.exercises,
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    this.onSelect,
    required this.isCompleted,
  });
  final List<Map<String, dynamic>> exercises;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback? onSelect;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${exercises.length} risultati trovati / results found',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        ...exercises.take(2).map((exercise) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ExerciseResultCard(
            exercise: exercise,
            colorScheme: colorScheme,
            theme: theme,
            l10n: l10n,
            onTap: onSelect,
            isCompleted: isCompleted,
          ),
        )),
        if (!isCompleted && onSelect != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.onboardingTapToComplete,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _ExerciseResultCard extends StatelessWidget {

  const _ExerciseResultCard({
    required this.exercise,
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    this.onTap,
    required this.isCompleted,
  });
  final Map<String, dynamic> exercise;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isCompleted ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
            color: isCompleted ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                AppIcons.workout,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isItalian ? exercise['nome'] : exercise['nameEn'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${exercise['focus']} • ${isItalian ? exercise['difficolta'] : exercise['difficoltaEn']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${isItalian ? exercise['tipoEsercizio'] : exercise['tipoEsercizioEn']} • ${isItalian ? exercise['attrezzatura'] : exercise['attrezzaturaEn']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.5)
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Icon(
                AppIcons.complete,
                color: colorScheme.primary,
                size: 20,
              )
            else
              Icon(
                AppIcons.addCircleOutline,
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
