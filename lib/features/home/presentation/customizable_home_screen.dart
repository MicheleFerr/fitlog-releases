import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/home/providers/home_customization_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/home_widget_factory.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/widget_customization_menu.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/rewarded_ad_service.dart';

class CustomizableHomeScreen extends ConsumerStatefulWidget {
  const CustomizableHomeScreen({super.key});

  @override
  ConsumerState<CustomizableHomeScreen> createState() => _CustomizableHomeScreenState();
}

class _CustomizableHomeScreenState extends ConsumerState<CustomizableHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final _rewardedAdService = RewardedAdService();
  bool _isPremiumUnlocked = false;
  Duration? _premiumRemainingTime;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    // Pre-load rewarded ad
    _rewardedAdService.preloadRewardedAd();

    // Check premium status
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final isUnlocked = await _rewardedAdService.isPremiumUnlocked();
    final remainingTime = await _rewardedAdService.getPremiumRemainingTime();

    if (mounted) {
      setState(() {
        _isPremiumUnlocked = isUnlocked;
        _premiumRemainingTime = remainingTime;
      });
    }
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    _rewardedAdService.dispose();
    super.dispose();
  }

  Future<void> _watchAdForPremium() async {
    final adShown = await _rewardedAdService.showRewardedAd(
      onUserEarnedReward: (amount, type) async {
        // User earned reward - unlock premium for 24h
        await _rewardedAdService.unlockPremiumTemporarily();

        // Update UI
        await _checkPremiumStatus();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).premiumUnlockedFor24Hours,
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      onAdClosed: () {
        // Pre-load next ad
        _rewardedAdService.preloadRewardedAd();
      },
    );

    if (!adShown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).adNotReady),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours${AppLocalizations.of(context).hours} $minutes${AppLocalizations.of(context).minutes}';
    } else {
      return '$minutes${AppLocalizations.of(context).minutes}';
    }
  }
  
  void _startEditMode() {
    ref.read(isHomeEditingProvider.notifier).state = true;
    HapticFeedback.mediumImpact();
    _shakeController.forward().then((_) {
      _shakeController.repeat(reverse: true);
    });
  }
  
  void _endEditMode() {
    ref.read(isHomeEditingProvider.notifier).state = false;
    _shakeController.stop();
    _shakeController.reset();
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(isHomeEditingProvider);
    final widgets = ref.watch(homeCustomizationProvider);
    final visibleWidgets = ref.read(homeCustomizationProvider.notifier).visibleWidgets;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: isEditing ? 140 : 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Personalizza Home' : _getGreeting(),
                      style: TextStyle(
                        fontSize: isEditing ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isEditing)
                      Text(
                        'Trascina per riordinare, tocca per configurare',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            actions: [
              if (!isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _startEditMode,
                  tooltip: 'Personalizza',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Open notifications
                  },
                ),
              ] else ...[
                TextButton(
                  onPressed: () {
                    ref.read(homeCustomizationProvider.notifier).resetToDefaults();
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(AppLocalizations.of(context).reset),
                ),
                TextButton(
                  onPressed: _endEditMode,
                  child: Text(
                    AppLocalizations.of(context).fatto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          
          // Main content
          if (isEditing) ...[
            // Edit mode with reorderable list
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverReorderableList(
                itemBuilder: (context, index) {
                  final widget = visibleWidgets[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(widget.id),
                    index: index,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: isEditing
                              ? _shakeAnimation.value * 0.01 * (index.isEven ? 1 : -1)
                              : 0,
                          child: _buildEditableWidgetWithSize(widget),
                        );
                      },
                    ),
                  );
                },
                itemCount: visibleWidgets.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(homeCustomizationProvider.notifier)
                      .reorderWidgets(oldIndex, newIndex);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            
            // Add widget button
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildAddWidgetButton(context),
              ),
            ),
          ] else ...[
            // Normal mode with visible widgets using smart grid layout
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: _buildUniformGrid(visibleWidgets),
              ),
            ),
          ],

          // 🎁 Premium Unlock Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildPremiumUnlockCard(),
            ),
          ),

          // 📱 Banner Ad
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: AdaptiveBannerAd(
                adUnitId: AdMobConfig.bannerAnalytics,
              ),
            ),
          ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      
      // Floating action button (only in normal mode) - COMMENTED OUT
      // floatingActionButton: !isEditing
      //     ? FloatingActionButton.extended(
      //         onPressed: () => context.push('/workout'),
      //         icon: const Icon(Icons.fitness_center),
      //         label: Text(AppLocalizations.of(context)!.iniziaAllenamento),
      //       )
      //     : null,
    );
  }
  
  Widget _buildEditableWidgetWithSize(HomeWidgetConfig widget) {
    final sizeLabel = _getSizeLabel(widget.size);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSizeIcon(widget.size),
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  sizeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildEditableWidget(widget),
        ],
      ),
    );
  }
  
  String _getSizeLabel(WidgetSize size) {
    switch (size) {
      case WidgetSize.small:
        return 'Compatto';
      case WidgetSize.medium:
        return 'Standard';
      case WidgetSize.large:
        return 'Espanso';
    }
  }
  
  Widget _buildEditableWidget(HomeWidgetConfig widget) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Widget preview
          Opacity(
            opacity: 0.4,
            child: HomeWidgetFactory.buildWidget(
              context: context,
              ref: ref,
              config: widget,
              isPreview: true,
            ),
          ),
          
          // Edit overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.drag_indicator,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  
                  // Widget info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(widget.icon, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Actions
                  if (!widget.isRequired) ...[
                    // Size selector - only show if resize is allowed
                    if (widget.allowResize)
                      PopupMenuButton<WidgetSize>(
                        icon: Icon(
                          _getSizeIcon(widget.size),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onSelected: (size) {
                          ref.read(homeCustomizationProvider.notifier)
                              .changeWidgetSize(widget.id, size);
                          HapticFeedback.lightImpact();
                        },
                        itemBuilder: (context) => [
                        PopupMenuItem(
                          value: WidgetSize.small,
                          child: Row(
                            children: [
                              Icon(_getSizeIcon(WidgetSize.small)),
                              const SizedBox(width: 8),
                              const Text('Piccolo'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: WidgetSize.medium,
                          child: Row(
                            children: [
                              Icon(_getSizeIcon(WidgetSize.medium)),
                              const SizedBox(width: 8),
                              const Text('Medio'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: WidgetSize.large,
                          child: Row(
                            children: [
                              Icon(_getSizeIcon(WidgetSize.large)),
                              const SizedBox(width: 8),
                              const Text('Grande'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Hide button
                    IconButton(
                      icon: const Icon(Icons.visibility_off),
                      onPressed: () {
                        ref.read(homeCustomizationProvider.notifier)
                            .toggleWidgetVisibility(widget.id);
                        HapticFeedback.lightImpact();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.title} nascosto'),
                            action: SnackBarAction(
                              label: 'Annulla',
                              onPressed: () {
                                ref.read(homeCustomizationProvider.notifier)
                                    .toggleWidgetVisibility(widget.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddWidgetButton(BuildContext context) {
    final hiddenWidgets = ref.read(homeCustomizationProvider.notifier).hiddenWidgets;
    
    if (hiddenWidgets.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: InkWell(
        onTap: () => _showWidgetCatalog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Aggiungi Widget',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showWidgetCatalog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WidgetCustomizationMenu(),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buongiorno! 🌅';
    } else if (hour < 18) {
      return 'Buon pomeriggio! ☀️';
    } else {
      return 'Buonasera! 🌙';
    }
  }
  
  IconData _getSizeIcon(WidgetSize size) {
    switch (size) {
      case WidgetSize.small:
        return Icons.crop_square;
      case WidgetSize.medium:
        return Icons.crop_16_9;
      case WidgetSize.large:
        return Icons.crop_portrait;
    }
  }
  
  Widget _buildUniformGrid(List<HomeWidgetConfig> widgets) {
    final List<Widget> rows = [];
    
    for (final widget in widgets) {
      // Tutti i widget occupano l'intera larghezza
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildConstrainedWidget(widget),
        ),
      );
    }
    
    return Column(children: rows);
  }
  
  Widget _buildSmartGrid(List<HomeWidgetConfig> widgets) {
    // Vecchia implementazione per riferimento futuro
    final List<Widget> rows = [];
    int i = 0;
    
    while (i < widgets.length) {
      final widget = widgets[i];
      
      if (widget.size == WidgetSize.small) {
        // Try to pair small widgets
        if (i + 1 < widgets.length && widgets[i + 1].size == WidgetSize.small) {
          // Two small widgets in a row
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildConstrainedWidget(widget),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildConstrainedWidget(widgets[i + 1]),
                    ),
                  ),
                ],
              ),
            ),
          );
          i += 2;
        } else {
          // Single small widget centered
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildConstrainedWidget(widget),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()), // Empty space
                ],
              ),
            ),
          );
          i++;
        }
      } else {
        // Medium or large widget takes full width
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildConstrainedWidget(widget),
          ),
        );
        i++;
      }
    }
    
    return Column(children: rows);
  }
  
  Widget _buildConstrainedWidget(HomeWidgetConfig widget) {
    final Widget child = HomeWidgetFactory.buildWidget(
      context: context,
      ref: ref,
      config: widget,
    );
    
    // Apply size constraints based on widget size
    switch (widget.size) {
      case WidgetSize.small:
        return SizedBox(
          height: 180,
          child: child,
        );
      case WidgetSize.medium:
        return SizedBox(
          height: 260,
          child: child,
        );
      case WidgetSize.large:
        return child; // No constraint
    }
  }

  Widget _buildPremiumUnlockCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isPremiumUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade700,
                    Colors.amber.shade900,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
        ),
        padding: const EdgeInsets.all(20),
        child: _isPremiumUnlocked
            ? _buildPremiumActiveContent()
            : _buildWatchAdContent(),
      ),
    );
  }

  Widget _buildPremiumActiveContent() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👑 ${AppLocalizations.of(context).premium}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_premiumRemainingTime != null)
                    Text(
                      AppLocalizations.of(context).premiumActiveRemaining(
                        _formatRemainingTime(_premiumRemainingTime!),
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatchAdContent() {
    return InkWell(
      onTap: _watchAdForPremium,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).unlockPremium,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).watchAdForPremium,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}