/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
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
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/ice_breaker.dart';

class IceBreakerWidget extends ConsumerStatefulWidget {

  const IceBreakerWidget({
    super.key,
    required this.userId,
    required this.targetUserId,
    required this.onSendMessage,
  });
  final String userId;
  final String targetUserId;
  final Function(String) onSendMessage;

  @override
  ConsumerState<IceBreakerWidget> createState() => _IceBreakerWidgetState();
}

class _IceBreakerWidgetState extends ConsumerState<IceBreakerWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<IceBreaker> _selectedCategoryIceBreakers = [];
  IceBreakerCategory _selectedCategory = IceBreakerCategory.workout;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: IceBreakerCategory.values.length,
      vsync: this,
    );
    _loadIceBreakers();
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = IceBreakerCategory.values[_tabController.index];
          _loadIceBreakers();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadIceBreakers() {
    setState(() {
      _selectedCategoryIceBreakers = IceBreakers.getByCategory(_selectedCategory);
    });
  }

  void _sendIceBreaker(IceBreaker iceBreaker) {
    // Process template variables if any
    String message = iceBreaker.messageTemplate;
    
    // For demo purposes, replace some common template variables
    message = message.replaceAll('{workout_type}', 'allenamenti funzionali');
    message = message.replaceAll('{time_period}', '2 anni');
    message = message.replaceAll('{time_preference}', 'mattina');
    
    widget.onSendMessage(message);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              l10n.iceBreakers,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              tabs: IceBreakerCategory.values.map((category) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.emoji),
                      const SizedBox(width: 4),
                      Text(_getCategoryText(l10n, category)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Ice breakers list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selectedCategoryIceBreakers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final iceBreaker = _selectedCategoryIceBreakers[index];
                return _buildIceBreakerCard(context, iceBreaker);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIceBreakerCard(BuildContext context, IceBreaker iceBreaker) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Process message for preview
    String previewMessage = iceBreaker.messageTemplate;
    previewMessage = previewMessage.replaceAll('{workout_type}', 'allenamenti funzionali');
    previewMessage = previewMessage.replaceAll('{time_period}', '2 anni');
    previewMessage = previewMessage.replaceAll('{time_preference}', 'mattina');

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _sendIceBreaker(iceBreaker),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      iceBreaker.category.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      previewMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (iceBreaker.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: iceBreaker.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryText(AppLocalizations l10n, IceBreakerCategory category) {
    switch (category) {
      case IceBreakerCategory.workout:
        return l10n.iceBreakerCategoryWorkout;
      case IceBreakerCategory.motivation:
        return l10n.iceBreakerCategoryMotivation;
      case IceBreakerCategory.fitness:
        return l10n.iceBreakerCategoryFitness;
      case IceBreakerCategory.goals:
        return l10n.iceBreakerCategoryGoals;
      case IceBreakerCategory.experience:
        return l10n.iceBreakerCategoryExperience;
      case IceBreakerCategory.casual:
        return l10n.iceBreakerCategoryCasual;
    }
  }

  static void show({
    required BuildContext context,
    required String userId,
    required String targetUserId,
    required Function(String) onSendMessage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => IceBreakerWidget(
          userId: userId,
          targetUserId: targetUserId,
          onSendMessage: onSendMessage,
        ),
      ),
    );
  }
}

/// Quick ice breaker suggestions for instant use
class QuickIceBreakers extends ConsumerWidget {

  const QuickIceBreakers({
    super.key,
    required this.onSendMessage,
    this.limit = 3,
  });
  final Function(String) onSendMessage;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Get most popular ice breakers
    final popularIceBreakers = IceBreakers.getMostPopular(limit: limit);
    
    if (popularIceBreakers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Messaggi Rapidi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        ...popularIceBreakers.map((iceBreaker) {
          String message = iceBreaker.messageTemplate;
          message = message.replaceAll('{workout_type}', 'allenamenti funzionali');
          message = message.replaceAll('{time_period}', '2 anni');
          message = message.replaceAll('{time_preference}', 'mattina');

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => onSendMessage(message),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Text(iceBreaker.category.emoji),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}