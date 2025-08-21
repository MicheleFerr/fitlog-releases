import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum per i tab dei template
enum TemplateTab {
  predefined,
  myTemplates,
}

/// Provider per il tab template selezionato
final selectedTemplateTabProvider = StateProvider<TemplateTab>((ref) {
  return TemplateTab.myTemplates;
});

/// Provider per i template personalizzati dell'utente
/// In futuro sarà collegato a Firestore o storage locale
final myTemplatesProvider = StateProvider<List<MyTemplate>>((ref) {
  // Per ora lista vuota per testare empty state
  // Cambiare a mock data se necessario per test
  return [
    // const MyTemplate(
    //   id: '1',
    //   name: 'Upper Body',
    //   description: 'Il mio custom',
    //   emoji: '🏋️',
    //   exerciseCount: 6,
    // ),
    // const MyTemplate(
    //   id: '2', 
    //   name: 'Quick Pump',
    //   description: '15 min workout',
    //   emoji: '🚀',
    //   exerciseCount: 4,
    // ),
    // const MyTemplate(
    //   id: '3',
    //   name: 'Home Workout',
    //   description: 'Senza attrezzi',
    //   emoji: '🎯',
    //   exerciseCount: 8,
    // ),
  ];
});

/// Entità per i template personalizzati
class MyTemplate {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int exerciseCount;
  final DateTime? createdAt;
  final DateTime? lastUsed;

  const MyTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.exerciseCount,
    this.createdAt,
    this.lastUsed,
  });

  MyTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    int? exerciseCount,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return MyTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}