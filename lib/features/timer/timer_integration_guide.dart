/// Guida per integrare il nuovo timer minimizzabile in GymBro
/// 
/// Questo file contiene le istruzioni per sostituire gradualmente 
/// il RestTimerOverlay esistente con il nuovo MinimizableTimerOverlay

/*

INTEGRAZIONE STEP-BY-STEP:

1. AGGIUNGERE DIPENDENZA SHARED_PREFERENCES
   Nel pubspec.yaml, assicurati di avere:
   ```yaml
   dependencies:
     shared_preferences: ^2.2.2
   ```

2. IMPORTARE I NUOVI MODULI
   Dove usi attualmente RestTimerOverlay, aggiungi:
   ```dart
   import 'package:gymbro_flutter_new/features/timer/presentation/widgets/minimizable_timer_overlay.dart';
   import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_position_provider.dart';
   import 'package:gymbro_flutter_new/features/timer/domain/entities/timer_display_mode.dart';
   ```

3. SOSTITUIRE IL WIDGET
   Sostituisci:
   ```dart
   const RestTimerOverlay()
   ```
   
   Con:
   ```dart
   const MinimizableTimerOverlay()
   ```

4. TESTING GESTURE (opzionale)
   Per testare le gesture:
   - Pinch in/out per cambiare dimensione
   - Drag per spostare il timer
   - Tap per ciclare tra modalità
   - Double tap per tornare a modalità normale

5. PERSONALIZZAZIONE (opzionale)
   Per personalizzare colori o dimensioni, modifica:
   - TimerLayoutManager in timer_display_mode.dart
   - _getGradientColors in minimizable_timer_overlay.dart

GESTURE SUPPORTATE:
✅ Drag & Drop - Sposta il timer ovunque sullo schermo
✅ Pinch to Scale - Pinch in → Compact, Pinch out → Expanded  
✅ Tap to Cycle - Tap per ciclare tra Compact → Normal → Expanded
✅ Double Tap Reset - Double tap per tornare sempre a Normal
✅ Auto Snap to Edge - Snap automatico ai bordi in modalità Compact
✅ Haptic Feedback - Vibrazione per ogni interazione
✅ Persistent State - Posizione e modalità salvate tra sessioni

MODALITÀ DISPONIBILI:
📱 Compact (80x40px) - Solo tempo rimanente
📱 Normal (280x120px) - Timer + controlli base (modalità esistente)
📱 Expanded (full width x 200px) - Timer + controlli avanzati + stats

*/

// Export dei componenti principali per facilità d'uso
export 'presentation/widgets/minimizable_timer_overlay.dart';
export 'presentation/providers/timer_position_provider.dart';
export 'domain/entities/timer_display_mode.dart';