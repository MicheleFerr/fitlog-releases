import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RestTimePickerModal extends StatefulWidget {

  const RestTimePickerModal({
    super.key,
    this.initialRestTime,
    required this.onRestTimeSelected,
  });
  final int? initialRestTime; // in seconds
  final Function(int?) onRestTimeSelected;

  @override
  State<RestTimePickerModal> createState() => _RestTimePickerModalState();
}

class _RestTimePickerModalState extends State<RestTimePickerModal> {
  late int _selectedMinutes;
  late int _selectedSeconds;
  bool _hasRestTime = true;

  // Preset comuni per diversi tipi di allenamento
  final List<RestTimePreset> _presets = [
    RestTimePreset('Nessun timer', null, Icons.timer_off),
    RestTimePreset('30 secondi', 30, Icons.flash_on),
    RestTimePreset('1 minuto', 60, Icons.speed),
    RestTimePreset('1:30 min', 90, Icons.fitness_center),
    RestTimePreset('2 minuti', 120, Icons.schedule),
    RestTimePreset('3 minuti', 180, Icons.access_time),
    RestTimePreset('5 minuti', 300, Icons.hourglass_empty),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialRestTime != null) {
      _selectedMinutes = widget.initialRestTime! ~/ 60;
      _selectedSeconds = widget.initialRestTime! % 60;
      _hasRestTime = true;
    } else {
      _selectedMinutes = 1;
      _selectedSeconds = 30;
      _hasRestTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Titolo
          Row(
            children: [
              const Icon(Icons.timer, size: 24),
              const SizedBox(width: 8),
              Text(
                'Tempo di Recupero',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Imposta il timer per il recupero tra le serie',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Switch per abilitare/disabilitare timer
          SwitchListTile(
            value: _hasRestTime,
            onChanged: (value) {
              setState(() => _hasRestTime = value);
            },
            title: const Text('Usa timer personalizzato'),
            subtitle: Text(_hasRestTime 
                ? 'Timer attivo per questo esercizio' 
                : 'Nessun timer specifico'),
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 16),

          if (_hasRestTime) ...[
            // Preset rapidi
            Text(
              'Preset Rapidi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.where((p) => p.seconds != null).map((preset) {
                final isSelected = _hasRestTime && 
                    preset.seconds == (_selectedMinutes * 60 + _selectedSeconds);
                
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(preset.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(preset.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && preset.seconds != null) {
                      setState(() {
                        _selectedMinutes = preset.seconds! ~/ 60;
                        _selectedSeconds = preset.seconds! % 60;
                      });
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),

            // Picker personalizzato
            Text(
              'Timer Personalizzato',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Minuti
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Minuti',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 28,
                            scrollController: FixedExtentScrollController(
                              initialItem: _selectedMinutes,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() => _selectedMinutes = index);
                            },
                            children: List.generate(11, (index) {
                              return Center(
                                child: Text(
                                  '$index',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  
                  // Secondi
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Secondi',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 28,
                            scrollController: FixedExtentScrollController(
                              initialItem: _selectedSeconds ~/ 15,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() => _selectedSeconds = index * 15);
                            },
                            children: List.generate(4, (index) {
                              final seconds = index * 15;
                              return Center(
                                child: Text(
                                  seconds.toString().padLeft(2, '0'),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Anteprima tempo selezionato (più compatta)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Timer impostato: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    _formatTime(_selectedMinutes * 60 + _selectedSeconds),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Pulsanti azione
          SafeArea(
            child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final restTime = _hasRestTime 
                        ? (_selectedMinutes * 60 + _selectedSeconds)
                        : null;
                    widget.onRestTimeSelected(restTime);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Conferma'),
                ),
              ),
              ],
            ),
          ),
            ],
          ),
        ),
      );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '0:00';
    
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (minutes == 0) {
      return '${seconds}s';
    } else if (seconds == 0) {
      return '${minutes}min';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class RestTimePreset {

  RestTimePreset(this.label, this.seconds, this.icon);
  final String label;
  final int? seconds;
  final IconData icon;
}