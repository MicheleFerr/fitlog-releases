# 🎨 Golden Tests - Visual Regression Testing

## Cosa Sono

I golden tests (o snapshot tests) catturano lo stato visuale dei widget e lo salvano come immagine di riferimento. Ogni volta che esegui i test, Flutter confronta il rendering attuale con l'immagine salvata e fallisce se ci sono differenze.

## Perché Usarli

✅ **Previeni regressioni visuali accidentali**
- Modifichi il theme → Golden test fallisce → Fix prima di commit
- Zero regressioni visuali in production

✅ **Documentazione visiva auto-aggiornata**
- Le golden images sono documentazione vivente
- Vedi come appare ogni component in entrambi i temi

✅ **Review visuale in PR**
- GitHub Actions mostra diff visuali
- Reviewer vede esattamente cosa cambia

## Come Usarli

### 1. Eseguire i Test

```bash
# Run tutti i golden tests
flutter test test/golden/

# Run un test specifico
flutter test test/golden/design_system_test.dart
```

### 2. Aggiornare le Golden Images

**ATTENZIONE**: Fai questo SOLO se le modifiche visuali sono intenzionali!

```bash
# Aggiorna tutte le golden images
flutter test --update-goldens test/golden/

# Aggiorna un test specifico
flutter test --update-goldens test/golden/design_system_test.dart
```

### 3. Verificare le Differenze

Quando un test fallisce:

1. Guarda l'output del test per vedere quali immagini sono diverse
2. Le failure images sono salvate in `test/failures/`
3. Confronta failure con golden:
   ```bash
   # Confronta visivamente
   open test/golden/goldens/standard_card.png
   open test/failures/standard_card.png
   ```

4. Se le modifiche sono corrette:
   ```bash
   flutter test --update-goldens
   ```

5. Se le modifiche sono bugs:
   - Fix il codice
   - Re-run i test

### 4. Commit delle Golden Images

```bash
# Aggiungi le nuove/modificate golden images
git add test/golden/goldens/*.png

# Commit con messaggio descrittivo
git commit -m "test: update goldens after theme changes"
```

## Struttura

```
test/golden/
├── README.md                    # Questa guida
├── design_system_test.dart      # Test component design system
├── cards_test.dart              # Test card components
├── buttons_test.dart            # Test button components
├── dialogs_test.dart            # Test dialog components
└── goldens/                     # Golden images di riferimento
    ├── standard_card.png
    ├── standard_card_dark.png
    ├── elevated_button.png
    └── ...
```

## Best Practices

### ✅ DO

- **Test in entrambi i temi** (light + dark)
- **Test diversi stati** (enabled/disabled, selected/unselected)
- **Usa device size consistente** (es: iPhone 11)
- **Update goldens dopo modifiche intenzionali**
- **Review goldens in PR** prima di merge

### ❌ DON'T

- **Update goldens senza verificare** le modifiche
- **Commit goldens troppo grandi** (comprimi se necessario)
- **Skippare golden tests** in CI
- **Testare animazioni** (usa static state)

## Troubleshooting

### Test fallisce con "Golden file does not exist"

```bash
# Crea la golden per la prima volta
flutter test --update-goldens test/golden/my_test.dart
```

### Test fallisce con "Pixel difference exceeds threshold"

1. Verifica che le modifiche siano intenzionali
2. Se sì: `flutter test --update-goldens`
3. Se no: Fix il codice

### Golden images troppo grandi

```bash
# Comprimi immagini PNG (macOS/Linux)
for img in test/golden/goldens/*.png; do
  pngquant --force --ext .png "$img"
done
```

### Test fallisce solo in CI

- Device rendering potrebbe differire
- Usa `flutter test --platform chrome` per consistency
- Oppure configura CI per usare stesso device simulator

## Esempio Test

```dart
testWidgets('Standard Card golden test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StandardCard(
          title: 'Test Card',
          subtitle: 'This is a test',
        ),
      ),
    ),
  );

  await expectLater(
    find.byType(StandardCard),
    matchesGoldenFile('goldens/standard_card.png'),
  );
});
```

## CI Integration

```yaml
# .github/workflows/test.yml
- name: Run golden tests
  run: flutter test test/golden/

- name: Upload failure images
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: golden-failures
    path: test/failures/*.png
```

## Risorse

- [Flutter Golden Tests Docs](https://docs.flutter.dev/cookbook/testing/integration/golden-tests)
- [flutter_test matchesGoldenFile API](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
- [Alchemist Package](https://pub.dev/packages/alchemist) - Advanced golden testing

---

**Domande?** Vedi [docs/DESIGN_GUIDELINES.md](../../docs/DESIGN_GUIDELINES.md) per pattern di design completi.
