import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarbellType {

  const BarbellType({
    required this.name,
    required this.category,
    required this.weight,
    required this.icon,
    required this.color,
    required this.description,
  });
  final String name;
  final String category;
  final double weight;
  final IconData icon;
  final Color color;
  final String description;
}

class BarbellSelectorWidget extends StatefulWidget {
  
  const BarbellSelectorWidget({
    super.key,
    this.selectedBarbellWeight,
    required this.onBarbellSelected,
  });
  final double? selectedBarbellWeight;
  final Function(double?) onBarbellSelected;

  @override
  State<BarbellSelectorWidget> createState() => _BarbellSelectorWidgetState();
}

class _BarbellSelectorWidgetState extends State<BarbellSelectorWidget> {
  // Comprehensive list of barbell types
  static const List<BarbellType> barbellTypes = [
    // No Barbell option
    BarbellType(
      name: 'No Barbell',
      category: 'None',
      weight: 0,
      icon: Icons.block,
      color: Colors.grey,
      description: 'Dumbbell or machine exercise',
    ),
    
    // Olympic Barbells
    BarbellType(
      name: 'Olympic Men\'s',
      category: 'Olympic',
      weight: 20,
      icon: Icons.fitness_center,
      color: Colors.blue,
      description: 'Standard Olympic bar (220cm)',
    ),
    BarbellType(
      name: 'Olympic Women\'s',
      category: 'Olympic',
      weight: 15,
      icon: Icons.fitness_center,
      color: Colors.pink,
      description: 'Women\'s Olympic bar (201cm)',
    ),
    
    // Standard Barbells
    BarbellType(
      name: 'Standard Bar',
      category: 'Standard',
      weight: 17.5,
      icon: Icons.horizontal_rule,
      color: Colors.orange,
      description: 'Common gym standard bar',
    ),
    BarbellType(
      name: 'Light Standard',
      category: 'Standard',
      weight: 12.5,
      icon: Icons.horizontal_rule,
      color: Colors.amber,
      description: 'Lighter standard bar',
    ),
    BarbellType(
      name: 'Training Bar',
      category: 'Standard',
      weight: 10,
      icon: Icons.horizontal_rule,
      color: Colors.lightGreen,
      description: 'Beginner/technique bar',
    ),
    
    // EZ Curl Bars
    BarbellType(
      name: 'Olympic EZ Bar',
      category: 'EZ Curl',
      weight: 10,
      icon: Icons.waves,
      color: Colors.purple,
      description: 'Olympic EZ curl bar (2" sleeves)',
    ),
    BarbellType(
      name: 'Standard EZ Bar',
      category: 'EZ Curl',
      weight: 7.5,
      icon: Icons.waves,
      color: Colors.deepPurple,
      description: 'Standard EZ curl bar (1" sleeves)',
    ),
    BarbellType(
      name: 'Super EZ Bar',
      category: 'EZ Curl',
      weight: 11,
      icon: Icons.waves,
      color: Colors.indigo,
      description: 'Super EZ with more curve',
    ),
    BarbellType(
      name: 'Mini EZ Bar',
      category: 'EZ Curl',
      weight: 5,
      icon: Icons.waves,
      color: Colors.lightBlue,
      description: 'Small EZ curl bar',
    ),
    
    // Specialty Bars
    BarbellType(
      name: 'Trap/Hex Bar',
      category: 'Specialty',
      weight: 25,
      icon: Icons.hexagon_outlined,
      color: Colors.red,
      description: 'Hexagonal trap bar',
    ),
    BarbellType(
      name: 'Safety Squat Bar',
      category: 'Specialty',
      weight: 30,
      icon: Icons.security,
      color: Colors.deepOrange,
      description: 'SSB with shoulder pads',
    ),
    BarbellType(
      name: 'Swiss/Football Bar',
      category: 'Specialty',
      weight: 18,
      icon: Icons.sports_football,
      color: Colors.teal,
      description: 'Multi-grip neutral bar',
    ),
    BarbellType(
      name: 'Cambered Bar',
      category: 'Specialty',
      weight: 25,
      icon: Icons.architecture,
      color: Colors.brown,
      description: 'Cambered squat/bench bar',
    ),
    BarbellType(
      name: 'Buffalo Bar',
      category: 'Specialty',
      weight: 20,
      icon: Icons.trending_down,
      color: Colors.cyan,
      description: 'Slightly curved bar',
    ),
    
    // Fixed Weight Bars
    BarbellType(
      name: 'Fixed 10kg',
      category: 'Fixed',
      weight: 10,
      icon: Icons.lock,
      color: Colors.blueGrey,
      description: 'Pre-loaded fixed bar',
    ),
    BarbellType(
      name: 'Fixed 15kg',
      category: 'Fixed',
      weight: 15,
      icon: Icons.lock,
      color: Colors.blueGrey,
      description: 'Pre-loaded fixed bar',
    ),
    BarbellType(
      name: 'Fixed 20kg',
      category: 'Fixed',
      weight: 20,
      icon: Icons.lock,
      color: Colors.blueGrey,
      description: 'Pre-loaded fixed bar',
    ),
    
    // Custom option
    BarbellType(
      name: 'Custom Weight',
      category: 'Custom',
      weight: -1, // Special value for custom
      icon: Icons.edit,
      color: Colors.grey,
      description: 'Enter custom barbell weight',
    ),
  ];
  
  double? _selectedWeight;
  double _customWeight = 0;
  String _selectedCategory = 'All';
  final TextEditingController _customWeightController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedWeight = widget.selectedBarbellWeight;
    if (_selectedWeight != null && !_isStandardWeight(_selectedWeight!)) {
      _customWeight = _selectedWeight!;
      _customWeightController.text = _customWeight.toString();
    }
  }
  
  bool _isStandardWeight(double weight) {
    return barbellTypes.any((b) => b.weight == weight);
  }
  
  @override
  void dispose() {
    _customWeightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['All', ...barbellTypes.map((b) => b.category).toSet()];
    
    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick common selections
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Common Selections',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickButton('None', 0, Icons.block, Colors.grey),
                  _buildQuickButton('Olympic', 20, Icons.fitness_center, Colors.blue),
                  _buildQuickButton('Women\'s', 15, Icons.fitness_center, Colors.pink),
                  _buildQuickButton('EZ Bar', 7.5, Icons.waves, Colors.purple),
                  _buildQuickButton('Trap Bar', 25, Icons.hexagon_outlined, Colors.red),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Barbell list
        Expanded(
          child: ListView.builder(
            itemCount: _getFilteredBarbells().length,
            itemBuilder: (context, index) {
              final barbell = _getFilteredBarbells()[index];
              final isSelected = barbell.weight == _selectedWeight ||
                  (barbell.weight == -1 && _customWeight > 0 && !_isStandardWeight(_customWeight));
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected 
                    ? theme.colorScheme.primaryContainer 
                    : null,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: barbell.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      barbell.icon,
                      color: barbell.color,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        barbell.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (barbell.weight > 0) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${barbell.weight}kg',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: barbell.weight == -1 
                      ? _buildCustomWeightInput()
                      : Text(
                          barbell.description,
                          style: theme.textTheme.bodySmall,
                        ),
                  onTap: () {
                    if (barbell.weight == -1) {
                      // Custom weight - don't close, just update
                      _handleCustomWeight();
                    } else {
                      setState(() {
                        _selectedWeight = barbell.weight == 0 ? null : barbell.weight;
                        _customWeight = 0;
                      });
                      widget.onBarbellSelected(_selectedWeight);
                      HapticFeedback.lightImpact();
                    }
                  },
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primaryContainer,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickButton(String label, double weight, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedWeight == weight || (weight == 0 && _selectedWeight == null);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWeight = weight == 0 ? null : weight;
          _customWeight = 0;
        });
        widget.onBarbellSelected(_selectedWeight);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.3) 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : theme.colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomWeightInput() {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter weight in kg',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              _customWeight = weight;
            },
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _handleCustomWeight,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Set'),
        ),
      ],
    );
  }
  
  void _handleCustomWeight() {
    if (_customWeight > 0) {
      setState(() {
        _selectedWeight = _customWeight;
      });
      widget.onBarbellSelected(_selectedWeight);
      HapticFeedback.lightImpact();
    }
  }
  
  List<BarbellType> _getFilteredBarbells() {
    if (_selectedCategory == 'All') {
      return barbellTypes;
    }
    return barbellTypes.where((b) => b.category == _selectedCategory).toList();
  }
}