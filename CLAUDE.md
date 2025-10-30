# 🤖 CLAUDE.md - Istruzioni Progetto

> **IMPORTANTE**: Questo file contiene le regole obbligatorie per lavorare su questo progetto Flutter.

## 📱 Progetto: FitLog Pro
**Framework**: Flutter | **Architettura**: Clean Architecture + Riverpod | **Stato**: ⚠️ **TESTING PHASE** - Solo utente sviluppatore

> **🧪 NOTA TESTING**: L'app è attualmente in fase di sviluppo e testing con UN SOLO UTENTE (lo sviluppatore).
> **Non esiste base utenti** → Possiamo fare **breaking changes** e **migrazioni dati** senza preoccupazioni di compatibilità retroattiva.
> **Refactoring aggressivi sono permessi** per migliorare architettura e performance.

---

## 📚 STEP 0: LEGGI LA DOCUMENTAZIONE PRIMA DI IMPLEMENTARE

**⚠️ OBBLIGATORIO PRIMA DI QUALSIASI MODIFICA:**

### 🔍 Prima di implementare una feature:

1. **LEGGI** [`docs/NAVIGATION/INDEX.md`](docs/NAVIGATION/INDEX.md) - Mappa completa della documentazione
2. **TROVA** la documentazione della feature che devi implementare/modificare
3. **LEGGI** tutta la documentazione correlata (architettura, esempi, best practices)
4. **IMPLEMENTA** seguendo i pattern documentati
5. **AGGIORNA** la documentazione se necessario

### 📖 Documentazione Disponibile per Feature:

| Feature | Documentazione | Quando Leggerla |
|---------|----------------|-----------------|
| **📚 Comprehensive App Docs** | `docs/STRUTTURA_DATI.md`, `ARCHITETTURA_APP.md`, `SCHERMATE_PRINCIPALI.md`, `FLUSSI_UTENTE.md`, `FEATURES_IMPLEMENTATE.md`, `PROBLEMATICHE_LIMITAZIONI.md` | **ONBOARDING** - Per capire l'intera app (5,445 righe totali) |
| **🎨 Design System** | `docs/DESIGN_GUIDELINES.md` | **SEMPRE** - Prima di creare widget, colori, spacing, animazioni |
| **🎯 UI Flows & Components** | `docs/GymBro-UI-Flows.md` | **UI/UX DEVELOPMENT** - User flows dettagliati, componenti UI con codice Dart completo, interaction patterns |
| **🏋️ Design & Architecture Report** | `docs/GymBro-Design-Report.md` | **ARCHITECTURE REVIEW** - Executive summary, issues identificati, soluzioni proposte, KPIs, roadmap |
| **Timer & Rest Timer** | `docs/UX_FLOWS/notifications_background/TIMER_SYSTEM_DOCUMENTATION.md` | Prima di modificare timer, Live Activities, audio feedback |
| **Analytics & Progress** | `docs/UX_FLOWS/home_dashboard/ANALYTICS_SYSTEM_DOCUMENTATION.md` | Prima di modificare metriche, PR detection, chart data |
| **User Profile & Auth** | `docs/UX_FLOWS/user_account/USER_PROFILE_DOCUMENTATION.md` | Prima di modificare auth, account tiers, quota |
| **Premium & IAP** | `docs/UX_FLOWS/user_account/PREMIUM_IAP_DOCUMENTATION.md` | Prima di modificare subscriptions, IAP, sync premium |
| **Workout History** | `docs/UX_FLOWS/home_dashboard/WORKOUT_HISTORY_DOCUMENTATION.md` | Prima di modificare history, editing, export |
| **Workout Session** | `docs/UX_FLOWS/workout_session/WORKOUT_SYSTEM_OVERVIEW.md` | Prima di modificare workout flow principale |
| **Exercise Database** | `docs/UX_FLOWS/exercise_database/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` | Prima di modificare esercizi, feedback, sync |
| **Routine Center** | `docs/UX_FLOWS/routine_center/ROUTINE_CENTER_SYSTEM_REPORT.md` | Prima di modificare routine, swap flow, templates |

### 🎯 Workflow Completo:

```
1. Ricevi richiesta di implementare feature X
   ↓
2. LEGGI docs/NAVIGATION/INDEX.md
   ↓
3. TROVA sezione "Quick Navigation by Task"
   ↓
4. SEGUI link alla documentazione di feature X
   ↓
5. LEGGI documentazione completa (architettura + esempi)
   ↓
6. LEGGI documentazione correlata (se presente)
   ↓
7. IMPLEMENTA seguendo pattern documentati
   ↓
8. TESTA secondo guida di testing
   ↓
9. AGGIORNA documentazione se hai fatto modifiche significative
   ↓
10. COMMIT con messaggio descrittivo
```

**❌ MAI**: Implementare una feature senza aver letto la documentazione esistente
**✅ SEMPRE**: Consultare INDEX.md → Trovare docs → Leggere → Implementare → Aggiornare

---

## 🛡️ ENFORCEMENT REGOLE CRITICHE

**Tutte le modifiche DEVONO rispettare:**
1. Nessun testo hardcoded → `context.l10n.*`
2. Nessun colore hardcoded → `context.colors.*`
3. No componenti raw → usa `LoadingIndicator`, `SnackBarService`, `ModalService`
4. `flutter analyze` deve passare prima di commit

---

## 🌍 REGOLA #1: MULTILINGUA OBBLIGATORIO

✅ **SEMPRE**: `context.l10n.keyName` (BuildContext extensions)
- Importa: `build_context_extensions.dart`
- Aggiungi traduzioni in `assets/i18n/app_en.arb` e `app_it.arb`
- Rigenera: `flutter gen-l10n`

❌ **MAI**: Testi hardcoded o `AppLocalizations.of(context)!`

---

## 🎨 REGOLA #2: TEMA SCURO/CHIARO

✅ **SEMPRE**: `context.colors.primary/secondary/surface/onSurface` etc.
❌ **MAI**: `Colors.blue`, `Theme.of(context).colorScheme` diretto

---

## 🏗️ REGOLA #3: ARCHITETTURA RIVERPOD

Struttura: `features/[name]/{domain,data,presentation}` + `shared/`
Widget pattern: `ConsumerWidget` + `ref.watch()`/`ref.read()`

---

## 🔧 WIDGET PATTERN ESSENZIALI

- ✅ Usa `const` quando possibile
- ✅ Import assoluti: `package:...` (mai `../`)
- ✅ Usa `select()` per evitare rebuild inutili: `ref.watch(provider.select((x) => x.field))`
- ✅ Manage resources: cancella `Timer`, `StreamSubscription`, `Controller`
- ✅ Testa in entrambi i temi (chiaro/scuro)

---

## 🍎 REGOLA #4: iOS SPECIFICO

- Live Activities (iOS 16.1+), Dynamic Island, Background Tasks
- Controlla sempre `Platform.isIOS` prima di codice iOS-only
- Files nativi in `ios/Runner/LiveActivityTimer/` e `BackgroundTaskManager/` - NON modificare

---

## 🔄 REGOLA #11: GIT & VERSIONING

### 📝 Commit Message Format:
```
feat: add rest timer with live activity support
fix: resolve workout timer not pausing in background  
refactor: improve workout provider memory usage
docs: update localization guide with new patterns
```

### 🚫 NON Committare Mai:
- File con testi hardcoded
- API keys o secrets
- File di build (`build/`, `.dart_tool/`)
- File IDE specifici (`.vscode/settings.json` personali)

### ✅ Pre-commit Automatici:
- Lint check (`flutter analyze`)
- Hardcoded strings check
- Localizations regen se necessario
- Test execution

---

## ⚡ CHECKLIST RAPIDA

Prima di ogni modifica, verifica:

- [ ] 🌍 Nessun testo hardcoded (usa `context.l10n`)
- [ ] 🎨 Nessun colore hardcoded (usa `context.colors`)
- [ ] 📱 Import di `build_context_extensions.dart` aggiunto
- [ ] 🖨️ **Nessun print() - usa debugPrint() + kDebugMode**
- [ ] 🔤 Traduzioni aggiunte in EN e IT
- [ ] ⚙️ `flutter gen-l10n` eseguito se aggiunte traduzioni
- [ ] 🔍 `flutter analyze` passa senza errori
- [ ] 🧪 Widget testato in entrambi i temi (chiaro/scuro)
- [ ] 📱 Funzionalità testata su iOS E Android (se applicabile)
- [ ] 🔒 Autenticazione controllata se usa Firebase
- [ ] ⚡ Performance ottimizzata (const, select, dispose)
- [ ] 🧭 Named routes usate (non path hardcoded)

---

## 🍎 REGOLA #4: PIATTAFORMA iOS SPECIFICA

### 📱 Funzionalità iOS Esclusive:
- **Live Activities** (iOS 16.1+)
- **Dynamic Island** (iPhone 14 Pro+)
- **Background Tasks** (iOS specifici)
- **Apple Health Integration**
- **Sign in with Apple**

### ⚠️ Gestione Piattaforma:
```dart
// ✅ CORRETTO - Controlla piattaforma
if (Platform.isIOS) {
  // Codice specifico iOS
  await _startLiveActivity();
}

// ❌ SBAGLIATO - Assumere che sia sempre iOS
await _startLiveActivity(); // Crash su Android!
```

### 📂 File iOS Nativi:
- `ios/Runner/LiveActivityTimer/` - Live Activities
- `ios/Runner/BackgroundTaskManager/` - Background tasks
- **NON modificare** senza conoscenze Swift/iOS

---

## 🔥 REGOLA #5: FIREBASE & SICUREZZA

- Valida SEMPRE input utente e stato autenticazione
- Ogni documento Firestore deve avere `userId` per sicurezza
- Validazione lato client E server
- Error handling obbligatorio per operazioni async

---

## 🧪 REGOLA #6: TESTING & DEBUG

- ✅ Testa con localizzazione (IT/EN)
- ✅ Usa `debugPrint()` + `kDebugMode` (mai `print()`)
- ✅ Testa in Release mode prima di deploy
- ❌ MAI usare `print()` in production

---

## 🏋️‍♂️ REGOLA #7: DOMINIO FITNESS

Entità: Workout, Exercise, ExerciseCard, WorkoutTemplate, Analytics
Terminologia: Set/Serie, Rep, Rest, Superset, Drop Set, Rest-Pause
Timer: Rest Timer (tra serie), Workout Timer, Live Activity (iOS), Background

---

## 🚫 REGOLA #8: COSA NON TOCCARE

- `ios/Runner/LiveActivityTimer/` e `BackgroundTaskManager/` (Swift nativo)
- `lib/shared/presentation/l10n/generated/` (File generati)
- `.dart_tool/`, `build/`, `firebase_options.dart`, plist, keys

---

## 🔨 REGOLA #9: BUILD & COMPILATION

❌ **MAI** fare build automatici
- ✅ Solo se esplicitamente richiesto
- ✅ Solo per fix critici di compilazione
- ✅ Sempre lasciar fare build a Xcode/Android Studio per preferenza utente

---

## 🎯 REGOLA #10: BUILDCONTEXT EXTENSIONS (OBBLIGATORIO)

Importa: `build_context_extensions.dart`
- `context.l10n.*` - Localizzazioni
- `context.colors.*` - Colori tema
- `context.textTheme`, `context.screenHeight`, `context.isDarkMode` etc.

---

## 🧩 REGOLA #11: COMPONENTI UNIFICATI (OBBLIGATORIO)

**LoadingIndicator** per loading states (mai `CircularProgressIndicator` diretto)
**SnackBarService** per messaggi (mai `ScaffoldMessenger.showSnackBar` diretto)
**ModalService** per modals/dialogs (mai `showModalBottomSheet` diretto)

---

## 📝 REGOLA #12: DOCUMENTAZIONE AUTOMATICA POST-IMPLEMENTAZIONE (COMPORTAMENTO AUTOMATICO)

**⚠️ COMPORTAMENTO OBBLIGATORIO DI CLAUDE DOPO OGNI IMPLEMENTAZIONE:**

### 🤖 Workflow Automatico (Claude lo fa SEMPRE):

```
Appena finita un'implementazione di feature/modifica significativa
                    ↓
Claude AUTOMATICAMENTE rileva che hai implementato qualcosa
                    ↓
Claude CHIEDE: "🤖 Ho notato che hai implementato [nome-feature].
                Vuoi che generi automaticamente la documentazione
                completa e la colleghi a INDEX.md e CLAUDE.md?"
                    ↓
            [Sì]              [No/Dopo]
             ↓                     ↓
    Claude AUTOMATICAMENTE    Salta per ora
    esegue tutto:             (ma ricorda)
    1. Analizza git diff
    2. Genera docs completa
    3. Aggiorna INDEX.md
    4. Aggiorna CLAUDE.md
    5. Cross-references
    6. Commit documentazione
             ↓
    ✅ FATTO: Feature documentata e interconnessa
```

### 🎯 Cosa Fa Claude AUTOMATICAMENTE (senza comandi):

**Quando**: Dopo ogni implementazione significativa (nuova feature, modifica importante, nuovo screen/provider/repository)

**Claude automaticamente**:

1. **🔍 RILEVA**: Analizza i file modificati/creati
   ```
   - git diff --cached
   - git status
   - Nuovi file in lib/features/
   ```

2. **💬 CHIEDE**: "Vuoi che documenti questa implementazione?"
   - Se sì → procede automaticamente
   - Se no → ricorda per dopo

3. **📝 GENERA**: Crea documentazione completa
   ```markdown
   docs/UX_FLOWS/[category]/[FEATURE]_DOCUMENTATION.md
   - Overview
   - Architecture (domain/data/presentation)
   - Key features
   - Implementation details
   - UI components
   - Related documentation
   ```

4. **🔗 INTERCONNETTE**: Aggiorna tutto
   - **INDEX.md**: Aggiunge "Quick Navigation by Feature" entry
   - **CLAUDE.md**: Aggiunge feature mapping table entry
   - **Cross-refs**: Link bidirezionali con docs correlate

5. **💾 COMMIT**: Salva tutto
   ```bash
   git commit -m "docs: add [feature] documentation with interconnection"
   ```

### 📖 Esempio Conversazione Automatica:

```
User: "Implementa una pagina A/B testing dinamica"
       ↓
Claude: [implementa il codice]
       ↓
Claude: "✅ Implementazione completata!

        🤖 Ho notato che hai implementato una nuova feature:
           'Dynamic A/B Testing Page'

        Vuoi che generi automaticamente:
        - Documentazione completa (450+ righe)
        - Aggiornamento INDEX.md con link
        - Aggiornamento CLAUDE.md con mapping
        - Cross-references con docs correlate
        - Commit della documentazione

        Risposta: sì/no"
       ↓
User: "sì"
       ↓
Claude: [AUTOMATICAMENTE esegue tutto]
       ↓
Claude: "✅ Documentazione completata!

        📄 Creato: docs/UX_FLOWS/ab_testing/AB_TESTING_PAGE_DOCUMENTATION.md (450 righe)
        🔗 Aggiornato: INDEX.md (nuovo link in Quick Navigation)
        🔗 Aggiornato: CLAUDE.md (nuovo mapping feature)
        🔗 Cross-referenced: Analytics, User Profile, Firebase docs
        💾 Commit: docs: add A/B testing page documentation

        ✨ Ora la feature è completamente documentata e interconnessa!
           CLAUDE.md → INDEX.md → AB Testing docs"
```

### ⚙️ Regole di Rilevamento Automatico:

Claude rileva automaticamente quando hai implementato qualcosa se:

| Condizione | Claude chiede documentazione |
|-----------|------------------------------|
| ✅ Nuovi file in `lib/features/` | SÌ - Nuova feature |
| ✅ Nuovi screen `*_screen.dart` | SÌ - Nuova UI |
| ✅ Nuovi provider `*_provider.dart` | SÌ - Nuovo state management |
| ✅ Nuovi repository `*_repository.dart` | SÌ - Nuovo data layer |
| ✅ Modifiche significative (>100 righe) | SÌ - Major refactor |
| ❌ Piccoli fix (<50 righe) | NO - Non necessario |
| ❌ Solo commenti/formattazione | NO - Non necessario |

### 🎯 Nessun Comando Manuale Necessario:

**PRIMA (manuale)**:
```bash
# Implementa
# Ricordati di documentare
/finalize-feature "nome"  ← Devi ricordartelo!
```

**ORA (automatico)**:
```bash
# Implementa
# Claude automaticamente chiede e fa tutto
✨ Zero sforzo - tutto automatico
```

### ⚠️ Importante per Claude:

- **SEMPRE** chiedi dopo ogni implementazione significativa
- **MAI** committare senza aver offerto di documentare
- **SEMPRE** aspetta conferma dell'utente prima di procedere
- **MAI** documentare piccoli fix o refactor minori

---

## ⚡ CHECKLIST COMPLETA

### 📖 PRIMA di Implementare:
- [ ] ✅ Letto `docs/NAVIGATION/INDEX.md`
- [ ] ✅ Trovata e letta documentazione della feature
- [ ] ✅ Letta documentazione correlata

### 🔧 DURANTE l'Implementazione:
- [ ] ✅ Nessun testo hardcoded (`context.l10n.*`)
- [ ] ✅ Nessun colore hardcoded (`context.colors.*`)
- [ ] ✅ Import `build_context_extensions.dart` aggiunto
- [ ] ✅ Nessun `print()` → usa `debugPrint() + kDebugMode`
- [ ] ✅ Traduzioni aggiunte (EN + IT)
- [ ] ✅ `flutter gen-l10n` eseguito
- [ ] ✅ `flutter analyze` senza errori
- [ ] ✅ Testato in chiaro/scuro
- [ ] ✅ iOS E Android (se applicabile)
- [ ] ✅ Autenticazione controllata (se Firebase)
- [ ] ✅ Performance ottimizzata (`const`, `select`, `dispose`)
- [ ] ✅ Named routes usate

### 📝 DOPO l'Implementazione (AUTOMATICO):
- [ ] ✅ **Claude chiede automaticamente di documentare** ← Claude lo fa SEMPRE
- [ ] ✅ Rispondo "sì" → Claude genera tutto automaticamente
- [ ] ✅ Documentazione generata e verificata (automatico)
- [ ] ✅ INDEX.md aggiornato (automatico)
- [ ] ✅ CLAUDE.md aggiornato (automatico)
- [ ] ✅ Cross-references create (automatico)
- [ ] ✅ Commit documentazione (automatico)

---

## 🆘 RISORSE

- **Locale/Tema**: `build_context_extensions.dart`
- **Loading/Snackbar/Modal**: Usa i servizi unificati
- **Documentazione**: Vedi `docs/INDEX.md`
- **Script**: `scripts/find_hardcoded_strings.sh`, `flutter analyze`

---

> **⚠️ TESTING PHASE**: App in sviluppo con solo lo sviluppatore come utente. Breaking changes e migrazioni aggressive sono permesse. Seguire SEMPRE le regole di clean code sopra.