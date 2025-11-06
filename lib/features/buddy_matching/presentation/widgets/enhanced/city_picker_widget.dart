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
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class CityPickerWidget extends ConsumerStatefulWidget {

  const CityPickerWidget({
    super.key,
    this.selectedCity,
    this.selectedZone,
    required this.onCitySelected,
  });
  final ItalianCity? selectedCity;
  final String? selectedZone;
  final Function(ItalianCity, String?) onCitySelected;

  @override
  ConsumerState<CityPickerWidget> createState() => _CityPickerWidgetState();
}

class _CityPickerWidgetState extends ConsumerState<CityPickerWidget> {
  late TextEditingController _searchController;
  List<ItalianCity> _filteredCities = [];
  bool _showZones = false;
  ItalianCity? _tempSelectedCity;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCities = ItalianCities.majorCities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = ItalianCities.majorCities;
      } else {
        _filteredCities = ItalianCities.search(query);
      }
    });
  }

  void _selectCity(ItalianCity city) {
    setState(() {
      _tempSelectedCity = city;
      _showZones = ItalianCityZones.getZones(city.code).isNotEmpty;
    });
    
    if (!_showZones) {
      // No zones available, select city directly
      widget.onCitySelected(city, null);
      Navigator.of(context).pop();
    }
  }

  void _selectZone(String? zone) {
    if (_tempSelectedCity != null) {
      widget.onCitySelected(_tempSelectedCity!, zone);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _showZones ? l10n.zonePicker : l10n.cityPicker,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          if (!_showZones) ...[
            // Search bar for cities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCities,
                decoration: InputDecoration(
                  hintText: l10n.searchCity,
                  prefixIcon: Icon(
                    AppIcons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cities list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  final isSelected = widget.selectedCity?.code == city.code;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        city.code,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      city.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      city.region,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: isSelected
                        ? Icon(AppIcons.complete, color: colorScheme.primary)
                        : null,
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
          ] else ...[
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showZones = false;
                        _tempSelectedCity = null;
                      });
                    },
                    icon: Icon(AppIcons.back, color: colorScheme.onSurface),
                  ),
                  Expanded(
                    child: Text(
                      _tempSelectedCity?.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Zones list
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // No specific zone option
                  ListTile(
                    leading: Icon(
                      AppIcons.locationCity,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      'Tutta la città',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: widget.selectedZone == null 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: widget.selectedZone == null
                        ? Icon(AppIcons.complete, color: colorScheme.primary)
                        : null,
                    onTap: () => _selectZone(null),
                  ),
                  const Divider(),
                  
                  // Zone options
                  ...ItalianCityZones.getZones(_tempSelectedCity!.code)
                      .map((zone) {
                    final isSelected = widget.selectedZone == zone;
                    
                    return ListTile(
                      leading: Icon(
                        AppIcons.location,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        zone,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(AppIcons.complete, color: colorScheme.primary)
                          : null,
                      onTap: () => _selectZone(zone),
                    );
                  }),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    ItalianCity? selectedCity,
    String? selectedZone,
    required Function(ItalianCity, String?) onCitySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => CityPickerWidget(
          selectedCity: selectedCity,
          selectedZone: selectedZone,
          onCitySelected: onCitySelected,
        ),
      ),
    );
  }
}
