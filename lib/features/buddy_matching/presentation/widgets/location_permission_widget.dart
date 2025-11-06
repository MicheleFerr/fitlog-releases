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
/// - Location service
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/services/location_service.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/providers/buddy_matching_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class LocationPermissionWidget extends ConsumerStatefulWidget {

  const LocationPermissionWidget({
    super.key,
    required this.child,
    this.showLocationButton = true,
  });
  final Widget child;
  final bool showLocationButton;

  @override
  ConsumerState<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends ConsumerState<LocationPermissionWidget> {
  LocationPermissionStatus? _permissionStatus;
  bool _isUpdatingLocation = false;
  Map<String, dynamic> _locationStats = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadLocationStats();
  }

  Future<void> _checkLocationPermission() async {
    final locationService = ref.read(locationServiceProvider);
    final status = await locationService.checkLocationPermission();
    
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  Future<void> _loadLocationStats() async {
    final locationService = ref.read(locationServiceProvider);
    final stats = await locationService.getLocationStats();
    
    if (mounted) {
      setState(() {
        _locationStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        widget.child,
        
        // Location permission banner
        if (_permissionStatus != LocationPermissionStatus.granted && widget.showLocationButton)
          _buildLocationBanner(context, theme, l10n),
        
        // Location update button
        if (_permissionStatus == LocationPermissionStatus.granted && widget.showLocationButton)
          _buildLocationButton(context, theme, l10n),
      ],
    );
  }

  Widget _buildLocationBanner(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.location,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.enableLocationForBetterMatches,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.locationHelpsFindNearbyBuddies,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _dismissBanner(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      side: BorderSide(color: theme.colorScheme.onPrimaryContainer),
                    ),
                    child: Text(l10n.notNow),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _requestLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(l10n.enableLocation),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location info
            if (_locationStats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _locationStats['cityName'] ?? l10n.unknownLocation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_locationStats['isAccurate'] == true)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.gpsFixed,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            l10n.accurate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
            
            // Update button
            IconButton(
              onPressed: _isUpdatingLocation ? null : _updateLocation,
              icon: _isUpdatingLocation
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      AppIcons.myLocation,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
              tooltip: l10n.updateLocation,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final locationService = ref.read(locationServiceProvider);
    final status = await locationService.requestLocationPermission();
    
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
      
      if (status == LocationPermissionStatus.granted) {
        _updateLocation();
        _showSuccessMessage(AppLocalizations.of(context).locationPermissionGranted);
      } else if (status == LocationPermissionStatus.permanentlyDenied) {
        _showPermissionDialog();
      } else {
        _showErrorMessage(AppLocalizations.of(context).locationPermissionDenied);
      }
    }
  }

  Future<void> _updateLocation() async {
    if (_isUpdatingLocation) return;
    
    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      
      if (location != null) {
        await locationService.updateUserLocation(location);
        await _loadLocationStats();
        
        // Refresh matches dopo l'aggiornamento della location
        ref.read(matchingProvider.notifier).refreshMatches();
        
        _showSuccessMessage('✅ ${AppLocalizations.of(context).locationUpdated}: ${location.cityName}');
      } else {
        _showErrorMessage(AppLocalizations.of(context).unableToGetLocation);
      }
    } catch (e) {
      _showErrorMessage('${AppLocalizations.of(context).locationUpdateError}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  void _dismissBanner() {
    setState(() {
      _permissionStatus = LocationPermissionStatus.denied;
    });
  }

  void _showPermissionDialog() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.locationPermissionRequired),
        content: Text(l10n.locationPermissionExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(locationServiceProvider).openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
