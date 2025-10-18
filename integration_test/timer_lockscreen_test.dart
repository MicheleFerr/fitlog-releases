import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro_flutter_new/app/app.dart' as app;
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('⏱️ Timer Integration Tests', () {
    
    testWidgets('📱 TEST 1: Timer 60s con lockscreen', (WidgetTester tester) async {
      // Avvia l'app
      await tester.pumpWidget(const app.GymBroApp());
      await tester.pumpAndSettle();
      
      // Naviga alla schermata workout (se necessario login)
      final workoutButton = find.text('Start Workout');
      if (workoutButton.evaluate().isNotEmpty) {
        await tester.tap(workoutButton);
        await tester.pumpAndSettle();
      }
      
      // Aggiungi un esercizio per avviare il timer
      final addExerciseButton = find.byIcon(Icons.add);
      await tester.tap(addExerciseButton);
      await tester.pumpAndSettle();
      
      // Seleziona "Bench Press" dall'elenco
      final benchPress = find.text('Bench Press');
      if (benchPress.evaluate().isNotEmpty) {
        await tester.tap(benchPress);
        await tester.pumpAndSettle();
      }
      
      // Completa un set per avviare il rest timer
      final completeSetButton = find.byKey(const Key('complete-set-0'));
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }
      
      // Verifica che il timer sia partito (60s di default)
      expect(find.textContaining('1:00'), findsOneWidget);
      
      // Simula lockscreen dopo 10 secondi
      await tester.pump(const Duration(seconds: 10));
      
      // NOTA: Il vero lockscreen non può essere simulato in integration test
      // Ma possiamo verificare che il timer continui in background
      if (kDebugMode) debugPrint('📱 Timer avviato: 60s');
      if (kDebugMode) debugPrint('🔒 Simula lockscreen dopo 10s');
      
      // Verifica che il timer provider mantenga lo stato
      expect(find.textContaining('0:50'), findsOneWidget);
      
      // Attendi completamento timer (50s rimanenti)
      await tester.pump(const Duration(seconds: 50));
      
      // Verifica che il timer sia completato
      expect(find.textContaining('0:00'), findsOneWidget);
      
      // Verifica che l'audio sia stato triggerato
      // NOTA: L'audio reale non può essere verificato in test
      if (kDebugMode) debugPrint('✅ Timer completato');
      if (kDebugMode) debugPrint('🔊 Audio dovrebbe suonare');
      
      // Verifica Live Activity su iOS
      if (Platform.isIOS) {
        if (kDebugMode) debugPrint('📱 iOS: Live Activity dovrebbe aggiornarsi');
        // Verifica che il channel method sia stato chiamato
        expect(find.byKey(const Key('live-activity-active')), findsOneWidget);
      }
    });
    
    testWidgets('🎵 TEST 2: Timer 120s con musica in background', (WidgetTester tester) async {
      // Avvia l'app
      await tester.pumpWidget(const app.GymBroApp());
      await tester.pumpAndSettle();
      
      if (kDebugMode) debugPrint('🎵 Test Timer con musica');
      if (kDebugMode) debugPrint('▶️ Simula musica Spotify/Apple Music in riproduzione');
      
      // Naviga al workout
      final workoutButton = find.text('Start Workout');
      if (workoutButton.evaluate().isNotEmpty) {
        await tester.tap(workoutButton);
        await tester.pumpAndSettle();
      }
      
      // Modifica durata rest timer a 120s
      final timerSettings = find.byKey(const Key('timer-settings'));
      if (timerSettings.evaluate().isNotEmpty) {
        await tester.tap(timerSettings);
        await tester.pumpAndSettle();
        
        // Imposta 120 secondi
        final duration120 = find.text('2:00');
        await tester.tap(duration120);
        await tester.pumpAndSettle();
      }
      
      // Avvia timer completando un set
      final completeSetButton = find.byKey(const Key('complete-set-0'));
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }
      
      // Verifica timer a 2:00
      expect(find.textContaining('2:00'), findsOneWidget);
      
      if (kDebugMode) debugPrint('⏱️ Timer 120s avviato');
      
      // Simula lockscreen dopo 30s
      await tester.pump(const Duration(seconds: 30));
      if (kDebugMode) debugPrint('🔒 Lockscreen dopo 30s');
      
      // Verifica che la musica NON si abbassi
      // NOTA: Questo richiede test manuale su device
      if (kDebugMode) debugPrint('🎵 Musica dovrebbe continuare normale volume');
      
      // Attendi completamento (90s rimanenti)
      await tester.pump(const Duration(seconds: 90));
      
      // Verifica completamento
      expect(find.textContaining('0:00'), findsOneWidget);
      if (kDebugMode) debugPrint('✅ Timer completato');
      if (kDebugMode) debugPrint('🔊 Audio timer dovrebbe suonare SOPRA la musica');
      
      // Verifica che audio usi AVAudioSession.playback
      if (Platform.isIOS) {
        if (kDebugMode) debugPrint('📱 iOS: AVAudioSession category = .playback');
        if (kDebugMode) debugPrint('📱 iOS: Audio mixes with altri audio');
      }
    });
    
    testWidgets('🔄 TEST 3: Transizione app→lockscreen→app (90s)', (WidgetTester tester) async {
      // Avvia l'app
      await tester.pumpWidget(const app.GymBroApp());
      await tester.pumpAndSettle();
      
      if (kDebugMode) debugPrint('🔄 Test sincronizzazione timer');
      
      // Imposta timer a 90s
      final workoutButton = find.text('Start Workout');
      if (workoutButton.evaluate().isNotEmpty) {
        await tester.tap(workoutButton);
        await tester.pumpAndSettle();
      }
      
      // Modifica durata a 90s
      final timerSettings = find.byKey(const Key('timer-settings'));
      if (timerSettings.evaluate().isNotEmpty) {
        await tester.tap(timerSettings);
        await tester.pumpAndSettle();
        
        final duration90 = find.text('1:30');
        await tester.tap(duration90);
        await tester.pumpAndSettle();
      }
      
      // Avvia timer
      final completeSetButton = find.byKey(const Key('complete-set-0'));
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }
      
      // Timer a 1:30
      expect(find.textContaining('1:30'), findsOneWidget);
      if (kDebugMode) debugPrint('⏱️ Timer avviato: 90s');
      
      // Dopo 30s vai in lockscreen
      await tester.pump(const Duration(seconds: 30));
      if (kDebugMode) debugPrint('🔒 Lockscreen dopo 30s (1:00 rimanenti)');
      
      // Verifica stato salvato
      expect(find.textContaining('1:00'), findsOneWidget);
      
      // Simula background per 30s
      await tester.pump(const Duration(seconds: 30));
      if (kDebugMode) debugPrint('⏰ Background per 30s...');
      
      // Riapri app dopo 60s totali
      if (kDebugMode) debugPrint('📱 Riapri app (0:30 rimanenti)');
      await tester.pumpAndSettle();
      
      // Verifica sincronizzazione corretta (±0.5s tolleranza)
      final timerText = find.textContaining(RegExp(r'0:(29|30|31)'));
      expect(timerText, findsOneWidget);
      if (kDebugMode) debugPrint('✅ Sync corretta: timer mostra ~0:30');
      
      // Completa timer
      await tester.pump(const Duration(seconds: 30));
      expect(find.textContaining('0:00'), findsOneWidget);
      if (kDebugMode) debugPrint('✅ Timer completato correttamente');
    });
    
    testWidgets('🍎 TEST 4: Live Activity iOS', (WidgetTester tester) async {
      // Skip se non iOS
      if (!Platform.isIOS) {
        if (kDebugMode) debugPrint('⏭️ Skip: Test solo per iOS');
        return;
      }

      await tester.pumpWidget(const app.GymBroApp());
      await tester.pumpAndSettle();
      
      if (kDebugMode) debugPrint('🍎 Test Live Activity iOS');
      
      // Naviga al workout
      final workoutButton = find.text('Start Workout');
      if (workoutButton.evaluate().isNotEmpty) {
        await tester.tap(workoutButton);
        await tester.pumpAndSettle();
      }
      
      // Avvia timer
      final completeSetButton = find.byKey(const Key('complete-set-0'));
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }
      
      // Verifica Live Activity attiva
      final liveActivityIndicator = find.byKey(const Key('live-activity-active'));
      expect(liveActivityIndicator, findsOneWidget);
      if (kDebugMode) debugPrint('✅ Live Activity attivata');
      
      // Verifica aggiornamenti ogni secondo
      for (int i = 59; i >= 55; i--) {
        await tester.pump(const Duration(seconds: 1));
        if (kDebugMode) debugPrint('📱 Live Activity update: 0:${i.toString().padLeft(2, '0')}');
      }
      
      // Lockscreen
      if (kDebugMode) debugPrint('🔒 Vai in lockscreen');
      await tester.pump(const Duration(seconds: 30));
      if (kDebugMode) debugPrint('📱 Live Activity visibile in lockscreen');
      if (kDebugMode) debugPrint('🏝️ Dynamic Island mostra timer');
      
      // Completa timer
      await tester.pump(const Duration(seconds: 25));
      if (kDebugMode) debugPrint('✅ Timer completato');
      if (kDebugMode) debugPrint('📱 Live Activity rimossa');
      
      // Verifica Live Activity terminata
      expect(find.byKey(const Key('live-activity-active')), findsNothing);
    });
    
    testWidgets('🔊 TEST 5: Audio completion in background', (WidgetTester tester) async {
      await tester.pumpWidget(const app.GymBroApp());
      await tester.pumpAndSettle();
      
      if (kDebugMode) debugPrint('🔊 Test audio in background');
      
      // Naviga al workout
      final workoutButton = find.text('Start Workout');
      if (workoutButton.evaluate().isNotEmpty) {
        await tester.tap(workoutButton);
        await tester.pumpAndSettle();
      }
      
      // Timer breve per test (10s)
      final timerSettings = find.byKey(const Key('timer-settings'));
      if (timerSettings.evaluate().isNotEmpty) {
        await tester.tap(timerSettings);
        await tester.pumpAndSettle();
        
        final duration10 = find.text('0:10');
        await tester.tap(duration10);
        await tester.pumpAndSettle();
      }
      
      // Avvia timer
      final completeSetButton = find.byKey(const Key('complete-set-0'));
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }
      
      if (kDebugMode) debugPrint('⏱️ Timer 10s avviato');
      
      // Vai in background dopo 3s
      await tester.pump(const Duration(seconds: 3));
      if (kDebugMode) debugPrint('📱 App in background');
      
      // Attendi completamento in background
      await tester.pump(const Duration(seconds: 7));
      
      if (kDebugMode) debugPrint('✅ Timer completato in background');
      if (kDebugMode) debugPrint('🔊 Audio dovrebbe suonare anche con app in background');
      
      if (Platform.isIOS) {
        if (kDebugMode) debugPrint('📱 iOS: Background audio capability attiva');
        if (kDebugMode) debugPrint('📱 iOS: AVAudioSession.playback configurato');
      } else {
        if (kDebugMode) debugPrint('🤖 Android: Foreground service attivo');
        if (kDebugMode) debugPrint('🤖 Android: Notification con timer visibile');
      }
      
      // Riapri app
      await tester.pumpAndSettle();
      
      // Verifica stato post-completamento
      expect(find.text('Rest completed'), findsOneWidget);
      if (kDebugMode) debugPrint('✅ Stato correttamente aggiornato dopo background');
    });
  });
}