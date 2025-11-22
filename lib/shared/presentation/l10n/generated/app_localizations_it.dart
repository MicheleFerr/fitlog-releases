// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FitLog Pro';

  @override
  String get welcome => 'Pronto per allenarti?';

  @override
  String get welcomeDescription =>
      'Traccia allenamenti, cronometra i riposi e sincronizza con Apple Health.';

  @override
  String onboardingWelcomeTitle(String name) {
    return 'Benvenuto, $name!';
  }

  @override
  String get onboardingWelcomeDescription =>
      'Traccia i tuoi progressi, raggiungi i tuoi obiettivi con il tracker di allenamenti più completo';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia!';

  @override
  String get onboardingTitle => 'Configurazione AI Coach';

  @override
  String get onboardingExperienceTitle =>
      'Qual è la tua esperienza di allenamento?';

  @override
  String get onboardingExperienceSubtitle =>
      'Aiutaci a personalizzare i tuoi insights';

  @override
  String get beginnerLevel => 'Principiante';

  @override
  String get beginnerLevelDescription => '0-6 mesi di allenamento';

  @override
  String get intermediateLevel => 'Intermedio';

  @override
  String get intermediateLevelDescription => '6-24 mesi di allenamento';

  @override
  String get advancedLevel => 'Avanzato';

  @override
  String get advancedLevelDescription => '2+ anni di allenamento';

  @override
  String get onboardingExitTitle => 'Uscire dall\'Onboarding?';

  @override
  String get onboardingExitMessage =>
      'Puoi sempre configurare l\'AI Coach successivamente nelle Impostazioni';

  @override
  String get onboardingGoalTitle => 'Qual è il tuo obiettivo principale?';

  @override
  String get onboardingGoalSubtitle =>
      'Personalizzeremo gli insights in base al tuo focus';

  @override
  String get hypertrophyGoal => 'Crescita Muscolare';

  @override
  String get hypertrophyGoalDescription => '8-12 rip, 60-90s recupero';

  @override
  String get strengthGoal => 'Forza Massima';

  @override
  String get strengthGoalDescription => '1-5 rip, 3-5min recupero';

  @override
  String get enduranceGoal => 'Resistenza';

  @override
  String get enduranceGoalDescription => '15+ rip, <30s recupero';

  @override
  String get onboardingQuickWinTitle => 'Il Tuo Quick Win';

  @override
  String get onboardingQuickWinSubtitle =>
      'Abbiamo analizzato i tuoi allenamenti. Ecco il tuo primo insight!';

  @override
  String get analyzingWorkouts => 'Analisi degli allenamenti in corso...';

  @override
  String get noWorkoutsYet => 'Nessun allenamento ancora';

  @override
  String get noWorkoutsYetDescription =>
      'Inizia ad allenarti e l\'AI Coach ti fornirà insights personalizzati!';

  @override
  String get beginnerQuickWinTitle => 'Ottimo Inizio!';

  @override
  String get beginnerQuickWinDescription =>
      'Stai costruendo solide fondamenta di allenamento. La costanza è la chiave!';

  @override
  String get beginnerQuickWinRecommendation =>
      'Concentrati sulla tecnica corretta prima di aumentare i carichi';

  @override
  String get intermediateQuickWinTitle => 'Bilancia il Volume';

  @override
  String get intermediateQuickWinDescription =>
      'Abbiamo rilevato potenziali squilibri tra gruppi muscolari nel tuo training';

  @override
  String get intermediateQuickWinRecommendation =>
      'Aggiungi 2-3 serie in più per i gruppi muscolari indietro ogni settimana';

  @override
  String get advancedQuickWinTitle => 'Rompi lo Stallo';

  @override
  String get advancedQuickWinDescription =>
      'I tuoi progressi sono fermi. È ora di implementare la periodizzazione!';

  @override
  String get advancedQuickWinRecommendation =>
      'Prova settimane di deload (40-50% volume) ogni 4-6 settimane per recuperare';

  @override
  String get onboardingNotificationsTitle => 'Resta in Carreggiata';

  @override
  String get onboardingNotificationsSubtitle =>
      'Ricevi insights tempestivi per ottimizzare il tuo allenamento';

  @override
  String get notificationBenefit1Title => 'Insights Intelligenti';

  @override
  String get notificationBenefit1Description =>
      'Ricevi consigli AI quando ne hai più bisogno';

  @override
  String get notificationBenefit2Title => 'Aggiornamenti Progressi';

  @override
  String get notificationBenefit2Description =>
      'Vieni notificato quando batti record personali o raggiungi traguardi';

  @override
  String get notificationBenefit3Title => 'Promemoria Recupero';

  @override
  String get notificationBenefit3Description =>
      'Evita il sovrallenamento con raccomandazioni intelligenti di riposo';

  @override
  String get enableNotifications => 'Abilita Notifiche';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get onboardingWhatToExpect => 'Cosa puoi aspettarti:';

  @override
  String get onboardingModeTitle => 'Scegli la Tua Esperienza';

  @override
  String get onboardingBaseMode => 'Modalità Base';

  @override
  String get onboardingBaseModeDescription =>
      'Funzionalità essenziali per allenamenti efficaci. Perfetta per principianti e allenamenti concentrati.';

  @override
  String get onboardingProMode => 'Modalità Pro';

  @override
  String get onboardingProModeDescription =>
      'Tracciamento avanzato con RPE, TUT, analisi e tutte le funzionalità sbloccate.';

  @override
  String get onboardingModeInfluenceDescription =>
      'La modalità influenza quali funzionalità sono visibili e disponibili';

  @override
  String get onboardingTimerRestTitle => 'Timer e Riposo';

  @override
  String get onboardingTimerRestDescription =>
      'Scopri come funziona:\\n\\n• Timer automatico di riposo\\n• Live Activities su iOS\\n• Personalizzazione durate\\n• Suoni e notifiche\\n• Timer personalizzati per esercizio\\n• Funzionamento in background';

  @override
  String get onboardingAdvancedFeaturesTitle => 'Funzionalità Avanzate';

  @override
  String get onboardingAdvancedFeaturesDescription =>
      'Esplora le features Pro:\\n\\n• Superset e Dropset\\n• Rest-Pause e tecniche avanzate\\n• Analytics e insights\\n• Suggerimenti community\\n• Warmup automatici\\n• Calcolo 1-Rep Max\\n• Export e condivisione';

  @override
  String get onboardingCongratulations => 'Congratulazioni!';

  @override
  String get onboardingCompletedMessage =>
      'Hai completato il tutorial completo di FitLog Pro. Ora sei pronto per iniziare i tuoi allenamenti!';

  @override
  String get selected => 'selezionati';

  @override
  String get onboardingFeaturesTitle => 'Funzionalità Potenti';

  @override
  String get onboardingFeature1 => 'Traccia serie, ripetizioni e peso';

  @override
  String get onboardingFeature2 => 'Timer riposo con Live Activities';

  @override
  String get onboardingFeature3 => 'Crea e salva template';

  @override
  String get onboardingFeature4 => 'Superset e dropset';

  @override
  String get onboardingCustomizeTitle => 'Personalizza';

  @override
  String get onboardingCustomizeDescription =>
      'Personalizza timer, suoni, temi e opzioni di visualizzazione per adattarli al tuo stile di allenamento.';

  @override
  String get onboardingGetStartedTitle => 'Pronto per Allenarti';

  @override
  String get onboardingGetStartedDescription =>
      'Inizia con un template o crea il tuo allenamento personalizzato. Iniziamo il tuo percorso fitness!';

  @override
  String get onboardingDone => 'Inizia';

  @override
  String onboardingProgress(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get globalOnboardingTitle => 'Guida Completa FitLog Pro';

  @override
  String get globalOnboardingDescription =>
      'Impara tutto sull\'app con questo tutorial interattivo passo dopo passo';

  @override
  String get togglePanoramaTitle => 'Panoramica Toggle e Personalizzazioni';

  @override
  String get togglePanoramaDescription =>
      'Esplora tutte le funzionalità disponibili e scopri come personalizzare la tua esperienza';

  @override
  String currentMode(String mode) {
    return 'Modalità attuale: $mode';
  }

  @override
  String get toggleSettingsHint =>
      'Puoi cambiare qualsiasi toggle in qualsiasi momento dalle impostazioni ⚙️';

  @override
  String get createWorkoutStepTitle => 'Creare un Workout';

  @override
  String get createWorkoutStepDescription =>
      'Impara come:\\n\\n• Creare un nuovo workout\\n• Usare template esistenti\\n• Personalizzare il nome\\n• Impostare obiettivi';

  @override
  String get addExerciseStepTitle => 'Aggiungere un Esercizio';

  @override
  String get addExerciseStepDescription =>
      'Tutorial step-by-step per:\\n\\n• Cercare esercizi nel database\\n• Aggiungere esercizio manuale\\n• Impostare serie e ripetizioni\\n• Configurare peso e RPE\\n• Aggiungere note personalizzate';

  @override
  String get executeSetStepTitle => 'Eseguire una Serie';

  @override
  String get executeSetStepDescription =>
      'Impara a:\\n\\n• Marcare serie completate\\n• Usare Quick Edit per modifiche rapide\\n• Valutare RPE (modalità Pro)\\n• Tracciare peso e ripetizioni\\n• Gestire serie fallite o parziali';

  @override
  String get timerRestStepTitle => 'Timer e Riposo';

  @override
  String get advancedFeaturesStepTitle => 'Funzionalità Avanzate';

  @override
  String get congratulations => 'Congratulazioni!';

  @override
  String get onboardingComplete =>
      'Hai completato il tutorial completo di FitLog Pro. Ora sei pronto per iniziare i tuoi allenamenti!';

  @override
  String get onboardingTryItOut => 'Provalo!';

  @override
  String get onboardingTapToComplete => 'Tocca per completare';

  @override
  String get onboardingExampleWorkout => 'Scheda di Esempio';

  @override
  String get onboardingSearchExercises => 'Cerca esercizi...';

  @override
  String get onboardingMockExercise => 'Flessioni';

  @override
  String get onboardingMockDescription =>
      'Esercizio classico a corpo libero per petto, spalle e tricipiti';

  @override
  String get onboardingCompleted => 'Completato!';

  @override
  String get onboardingWelcomeMissionTitle => 'La Nostra Mission';

  @override
  String get onboardingWelcomeMission =>
      'Il tuo compagno di allenamento che non sostituisce mai il tuo trainer, ma fornisce dati scientifici per aiutarti a raggiungere i tuoi obiettivi.';

  @override
  String get onboardingWelcomeFeature1Title => 'Tutorial Interattivo';

  @override
  String get onboardingWelcomeFeature1Description =>
      'Impara usando l\'app in tempo reale';

  @override
  String get onboardingWelcomeFeature2Title => 'Personalizzazione Completa';

  @override
  String get onboardingWelcomeFeature2Description =>
      'Scopri tutti i toggle e le opzioni';

  @override
  String get onboardingWelcomeFeature3Title => 'Workflow Completo';

  @override
  String get onboardingWelcomeFeature3Description =>
      'Dall\'impostazione all\'esecuzione';

  @override
  String get onboardingWelcomeFeature4Title => 'Modalità Base e Pro';

  @override
  String get onboardingWelcomeFeature4Description =>
      'Scegli il tuo livello di funzionalità';

  @override
  String get onboardingWelcomeCallToAction =>
      'Questo tutorial ti guiderà passo dopo passo attraverso tutte le funzionalità dell\'app. Puoi saltare o ripetere qualsiasi sezione.';

  @override
  String get onboardingVideoPlaceholder => 'Video Mancante';

  @override
  String get onboardingVideoComingSoon => 'Video tutorial in arrivo!';

  @override
  String get onboardingTogglePanoramaTitle =>
      'Panoramica Toggle e Personalizzazioni';

  @override
  String get onboardingTogglePanoramaDescription =>
      'Esplora tutte le funzionalità disponibili e scopri come personalizzare la tua esperienza';

  @override
  String get onboardingToggleAdvancedTrackingTitle => 'Tracciamento Avanzato';

  @override
  String get onboardingToggleAdvancedTrackingDescription =>
      'Funzionalità per il monitoraggio dettagliato';

  @override
  String get onboardingToggleTimerAutomationTitle => 'Timer e Automazioni';

  @override
  String get onboardingToggleTimerAutomationDescription =>
      'Gestione automatica dei tempi di riposo';

  @override
  String get onboardingToggleInterfaceTitle => 'Interfaccia e Suggerimenti';

  @override
  String get onboardingToggleInterfaceDescription =>
      'Personalizzazione dell\'esperienza utente';

  @override
  String get onboardingToggleSupportTitle => 'Supporto e Assistenza';

  @override
  String get onboardingToggleSupportDescription =>
      'Suggerimenti e aiuti durante l\'allenamento';

  @override
  String get onboardingToggleSettingsChangePart1 =>
      'Puoi cambiare qualsiasi toggle in qualsiasi momento dai';

  @override
  String get onboardingToggleSettingsChangePart2 => 'Personalizza Workout';

  @override
  String get quickStart => 'Avvio Rapido';

  @override
  String get quickWorkout => 'Allenamento Veloce';

  @override
  String get quickWorkoutSubtitle => 'Inizia con allenamento vuoto';

  @override
  String get sessioneLibera => 'Sessione Libera';

  @override
  String get suggested => 'Suggerito';

  @override
  String get notWhatYouWanted => '💡 Non è quello che volevi?';

  @override
  String get browseTemplates => 'Sfoglia Template';

  @override
  String get upperBody => 'Parte Superiore';

  @override
  String get upperBodySubtitle => 'Petto, Schiena, Spalle, Braccia';

  @override
  String get lowerBody => 'Parte Inferiore';

  @override
  String get lowerBodySubtitle => 'Gambe, Glutei, Polpacci';

  @override
  String get exerciseSync => 'Sincronizzazione Esercizi';

  @override
  String get syncIdle => 'Pronto';

  @override
  String get syncLoading => 'Caricamento...';

  @override
  String get syncSyncing => 'Sincronizzazione...';

  @override
  String get syncSuccess => 'Sincronizzazione riuscita';

  @override
  String syncError(String error) {
    return 'Sincronizzazione fallita: $error';
  }

  @override
  String get checkingStatus => 'Controllo stato...';

  @override
  String get statusError => 'Errore di stato';

  @override
  String get versionInfo => 'Informazioni Versione';

  @override
  String get localVersion => 'Versione Locale';

  @override
  String get remoteVersion => 'Versione Remota';

  @override
  String get updateAvailable => 'Aggiornamento Disponibile';

  @override
  String get checkingVersion => 'Controllo versione...';

  @override
  String get versionCheckError => 'Errore controllo versione';

  @override
  String get forceSync => 'Forza Sincronizzazione';

  @override
  String get syncSettings => 'Impostazioni Sincronizzazione';

  @override
  String get autoSync => 'Sincronizzazione Automatica';

  @override
  String get autoSyncDescription =>
      'Sincronizza automaticamente gli esercizi in background';

  @override
  String get syncFrequency => 'Frequenza Sincronizzazione';

  @override
  String get everyHour => 'Ogni Ora';

  @override
  String get every6Hours => 'Ogni 6 Ore';

  @override
  String get every12Hours => 'Ogni 12 Ore';

  @override
  String get daily => 'Giornaliera';

  @override
  String get every => 'Ogni';

  @override
  String get hours => 'ore';

  @override
  String get selectSyncFrequency => 'Seleziona Frequenza Sincronizzazione';

  @override
  String get cacheStatistics => 'Statistiche Cache';

  @override
  String get cachedExercises => 'Esercizi in Cache';

  @override
  String get cacheSize => 'Dimensione Cache';

  @override
  String get lastUpdate => 'Ultimo aggiornamento';

  @override
  String get loading => 'Caricamento...';

  @override
  String get ago => 'fa';

  @override
  String get clearCache => 'Pulisci Cache';

  @override
  String get clearCacheConfirmation =>
      'Sei sicuro di voler pulire la cache degli esercizi? Questo rimuoverà tutti gli esercizi in cache e verranno scaricati nuovamente alla prossima sincronizzazione.';

  @override
  String get clearExerciseCacheDesc =>
      'Pulisci il database esercizi in cache e forza il ricaricamento dai file JSON';

  @override
  String get exerciseCacheCleared =>
      'Cache esercizi pulita con successo! Gli esercizi verranno ricaricati dai file JSON al prossimo utilizzo.';

  @override
  String get cancel => 'Annulla';

  @override
  String get clear => 'Pulisci';

  @override
  String get done => 'Fatto';

  @override
  String get hiitTraining => 'Allenamento HIIT';

  @override
  String get hiitTrainingSubtitle => 'Intervalli ad alta intensità';

  @override
  String get startWorkout => 'Avvia Allenamento';

  @override
  String get addExercise => 'Aggiungi Esercizio';

  @override
  String get completeWorkout => 'Completa Allenamento';

  @override
  String get newWorkout => 'Nuovo Allenamento';

  @override
  String get workoutName => 'Nome Allenamento';

  @override
  String get workoutNameHint => 'es. Sessione Mattutina';

  @override
  String get exerciseName => 'Esercizio';

  @override
  String get exerciseNameHint => 'es. Panca Piana';

  @override
  String get importWorkoutTemplate => 'Importa Scheda Allenamento';

  @override
  String get exportTemplates => 'Esporta Schede';

  @override
  String get importFormat => 'Formato Importazione';

  @override
  String get naturalLanguageText => 'Linguaggio Naturale';

  @override
  String get jsonFile => 'File JSON';

  @override
  String get workoutDescription => 'Descrizione Allenamento';

  @override
  String get pasteWorkoutHere =>
      'Incolla qui la descrizione dell\'allenamento...\n\nEsempio:\nLUNEDÌ - PUSH\nPanca Piana - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg';

  @override
  String get aiParsingInstructions => 'Istruzioni AI per l\'Analisi';

  @override
  String get aiInstructionsHint =>
      'Opzionale: Fornisci contesto aggiuntivo per una migliore analisi (es. lingua, unità, nomi esercizi personalizzati)';

  @override
  String get aiInstructionsExample =>
      'Esempio: \"Il testo è in italiano, i pesi sono in kg, \'Panca\' significa Bench Press\"';

  @override
  String get selectJsonFile => 'Seleziona File JSON';

  @override
  String get tapToSelectFile => 'Tocca per selezionare file';

  @override
  String get supportedFormats => 'Supporta file .json e .txt';

  @override
  String get startImport => 'Inizia Importazione';

  @override
  String get exerciseDisambiguation => 'Disambiguazione Esercizi';

  @override
  String get percentageConversion => 'Conversione Percentuali Peso';

  @override
  String get continueImport => 'Continua Importazione';

  @override
  String get finalizeImport => 'Finalizza Importazione';

  @override
  String get importSuccessful => 'Importazione completata con successo!';

  @override
  String get importing => 'Importazione...';

  @override
  String get importCompleted => 'Importazione Completata';

  @override
  String templatesImportedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schede importate con successo!',
      one: '1 scheda importata con successo!',
    );
    return '$_temp0';
  }

  @override
  String get exportingTemplates => 'Esportazione Schede';

  @override
  String get templatesSelected => 'schede selezionate';

  @override
  String get freeAccount => 'Account Gratuito';

  @override
  String get premiumAccount => 'Account Premium';

  @override
  String get freeExportLimitations =>
      'Limitato a 1 esportazione, nessun dato analitico';

  @override
  String get premiumExportFeatures =>
      'Esportazione multipla, dati analitici, formati multipli';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get downloadJson => 'Scarica JSON';

  @override
  String get share => 'Condividi';

  @override
  String get copy => 'Copia';

  @override
  String get exportSuccessful => 'Esportazione completata con successo!';

  @override
  String get exportFailed => 'Esportazione fallita. Riprova.';

  @override
  String get gymbroTemplatesExport =>
      'Esportazione Schede Allenamento FitLog Pro';

  @override
  String get exportLimits => 'Limiti Esportazione';

  @override
  String get yourCurrentLimits => 'I tuoi attuali limiti di esportazione:';

  @override
  String get close => 'Chiudi';

  @override
  String get fullscreen => 'Schermo Intero';

  @override
  String get limitReached => 'Limite Raggiunto';

  @override
  String get upgradeToExportMore =>
      'Aggiorna a premium per esportare più schede con dati analitici.';

  @override
  String get pleaseSignIn => 'Accedi per usare le funzionalità di esportazione';

  @override
  String get aiPromptHelper => 'Assistente Prompt AI';

  @override
  String get createNew => 'Crea Nuovo';

  @override
  String get convertExisting => 'Converti Esistente';

  @override
  String get howToUse => 'Come Usare';

  @override
  String get createNewWorkout => 'Crea Nuovo Allenamento con AI';

  @override
  String get createNewWorkoutDesc =>
      'Genera un prompt personalizzato per creare schede con servizi AI esterni';

  @override
  String get selectWorkoutType => 'Seleziona Tipo Allenamento';

  @override
  String get selectDifficulty => 'Seleziona Livello Difficoltà';

  @override
  String get beginner => 'Principiante';

  @override
  String get intermediate => 'Intermedio';

  @override
  String get advanced => 'Avanzate';

  @override
  String get testNotification => 'Notifica di Test';

  @override
  String get testNotificationDescription =>
      'Invia una notifica di test per verificare che il sistema funzioni correttamente';

  @override
  String get testNotificationSent => 'Notifica di Test Inviata!';

  @override
  String get testNotificationSentDescription =>
      'Controlla il centro notifiche per verificare che funzioni';

  @override
  String get prNotifications => 'Nuovi Record Personali';

  @override
  String get prNotificationsDescription =>
      'Ricevi notifiche quando stabilisci un nuovo record personale';

  @override
  String get streakAchievements => 'Serie di Allenamenti';

  @override
  String get streakAchievementsDescription =>
      'Celebra i traguardi di costanza (7/30/100 giorni)';

  @override
  String get goalCompletions => 'Obiettivi Raggiunti';

  @override
  String get goalCompletionsDescription =>
      'Raggiungi i tuoi obiettivi mensili di volume e frequenza';

  @override
  String get milestones => 'Traguardi';

  @override
  String get milestonesDescription =>
      'Traccia i traguardi principali (50/100/500 allenamenti)';

  @override
  String get customRequest => 'Richiesta Personalizzata (Opzionale)';

  @override
  String get customRequestHint =>
      'es. Focus movimenti composti, allenamento 45 min, attrezzatura minima';

  @override
  String get generatedPrompt => 'Prompt AI Generato';

  @override
  String get convertExistingWorkout => 'Converti Allenamento Esistente';

  @override
  String get convertExistingDesc =>
      'Converti il tuo testo allenamento nel formato JSON di FitLog Pro';

  @override
  String get pasteWorkoutText => 'Incolla il Testo del Tuo Allenamento';

  @override
  String get workoutTextHint =>
      'LUNEDÌ - PUSH\nPanca Piana - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg\n...';

  @override
  String get generateConversionPrompt => 'Genera Prompt di Conversione';

  @override
  String get conversionPrompt => 'Prompt di Conversione';

  @override
  String get stepByStepGuide => 'Guida Passo-Passo';

  @override
  String get followTheseSteps =>
      'Segui questi semplici passi per creare schede con l\'AI';

  @override
  String get troubleshooting => 'Risoluzione Problemi';

  @override
  String get promptToCopy => 'Prompt da Copiare';

  @override
  String get copyPrompt => 'Copia Prompt';

  @override
  String get quickAIAccess => 'Accesso Rapido AI';

  @override
  String get copyPromptAndOpenAI => 'Copia Prompt e Apri Servizio AI';

  @override
  String get instructions => 'Istruzioni';

  @override
  String get conversionInstructions =>
      '1. Copia il prompt sopra 2. Apri un servizio AI 3. Incolla e invia 4. Copia il JSON risultante 5. Importa in FitLog Pro';

  @override
  String get creationInstructions =>
      '1. Copia il prompt sopra 2. Apri un servizio AI 3. Incolla e invia 4. Copia il JSON risultante 5. Importa in FitLog Pro';

  @override
  String get promptCopied => 'Prompt Copiato!';

  @override
  String get promptCopiedDesc => 'Il prompt AI è stato copiato negli appunti.';

  @override
  String get nextSteps => 'Prossimi passi:';

  @override
  String get step1OpenAI =>
      'Apri il tuo servizio AI preferito (ChatGPT, Claude, ecc.)';

  @override
  String get step2PastePrompt => 'Incolla il prompt copiato e invia';

  @override
  String get step3CopyJSON => 'Copia la risposta JSON dall\'AI';

  @override
  String get step4ReturnToApp => 'Torna in FitLog Pro e usa \'Importa Scheda\'';

  @override
  String get gotIt => 'Capito!';

  @override
  String get openChatGPT => 'Apri ChatGPT';

  @override
  String get cannotOpenUrl => 'Impossibile aprire questo URL';

  @override
  String get errorOpeningUrl => 'Errore nell\'apertura URL';

  @override
  String get pleaseEnterWorkoutText =>
      'Inserisci il testo dell\'allenamento da convertire';

  @override
  String get exerciseCategory => 'Categoria Esercizio';

  @override
  String get sets => 'serie';

  @override
  String get addSet => 'Aggiungi Serie';

  @override
  String get weight => 'Peso';

  @override
  String get oneRmEstimated => '1RM (Stim.)';

  @override
  String get weightTimesReps => 'Peso × Rip';

  @override
  String get reps => 'rip';

  @override
  String get notes => 'Note';

  @override
  String get notesHint => 'Aggiungi note sulla forma, progressione, ecc.';

  @override
  String get exerciseTypeSingle => 'Singolo';

  @override
  String get exerciseTypeSuperset => 'Superset';

  @override
  String get exerciseTypeDropset => 'Drop Set';

  @override
  String get exerciseTypeRestPause => 'Rest-Pause';

  @override
  String get exerciseCategoryChest => 'Petto';

  @override
  String get exerciseCategoryBack => 'Schiena';

  @override
  String get exerciseCategoryShoulders => 'Spalle';

  @override
  String get exerciseCategoryArms => 'Braccia';

  @override
  String get exerciseCategoryLegs => 'Gambe';

  @override
  String get exerciseCategoryAbs => 'Addominali';

  @override
  String get exerciseCategoryCardio => 'Cardio';

  @override
  String get exerciseCategoryOther => 'Altro';

  @override
  String get workoutStatusPlanned => 'Programmato';

  @override
  String get workoutStatusInProgress => 'In Corso';

  @override
  String get workoutStatusCompleted => 'Completato';

  @override
  String get workoutStatusPaused => 'In Pausa';

  @override
  String get exercises => 'esercizi';

  @override
  String get progress => 'Progressi';

  @override
  String get workoutProgress => 'Progresso Allenamento';

  @override
  String get tutTitle => 'Tempo Sotto Tensione (T.U.T.)';

  @override
  String get tutEccentricPhase => 'Eccentrica';

  @override
  String get tutEccentricDescription =>
      'Fase di abbassamento/allungamento (secondi)';

  @override
  String get tutBottomPausePhase => 'Pausa in Basso';

  @override
  String get tutBottomPauseDescription =>
      'Pausa nella posizione più bassa (secondi)';

  @override
  String get tutConcentricPhase => 'Concentrica';

  @override
  String get tutConcentricDescription =>
      'Fase di sollevamento/contrazione (secondi)';

  @override
  String get tutTopPausePhase => 'Pausa in Alto';

  @override
  String get tutTopPauseDescription =>
      'Pausa nella posizione più alta (secondi)';

  @override
  String get tutPresets => 'Preset';

  @override
  String get tutPresetStandard => 'Standard';

  @override
  String get tutPresetSlow => 'Lento';

  @override
  String get tutPresetExplosive => 'Esplosivo';

  @override
  String get tutPresetIsometric => 'Isometrico';

  @override
  String get tutCurrentTempo => 'Tempo Attuale';

  @override
  String get tutPhaseBreakdown => 'Dettaglio Fasi';

  @override
  String get tutEccentricFullDescription =>
      'Abbassa lentamente il peso, controllando il movimento con la tensione muscolare';

  @override
  String get tutBottomPauseFullDescription =>
      'Mantieni brevemente la posizione allungata per massimizzare l\'attivazione muscolare';

  @override
  String get tutConcentricFullDescription =>
      'Solleva il peso con forza controllata, concentrandoti sulla contrazione muscolare';

  @override
  String get tutTopPauseFullDescription =>
      'Breve pausa al picco di contrazione per aumentare il coinvolgimento muscolare';

  @override
  String get tutExample => 'Esempio: 3-1-2-0';

  @override
  String tutExampleStandard(
    String eccentric,
    String bottomPause,
    String concentric,
    String topPause,
  ) {
    return 'Impiega $eccentric secondi per abbassare, pausa $bottomPause secondi in basso, $concentric secondi per sollevare, poi pausa $topPause secondi in alto.';
  }

  @override
  String get tutExampleExplosive =>
      'Muoviti esplosivamente durante le fasi contrassegnate (X) mantenendo il controllo durante le fasi temporizzate.';

  @override
  String get tutExampleIsometric =>
      'Mantieni la posizione senza movimento per la durata specificata, concentrandoti sulla tensione muscolare.';

  @override
  String get tutSubtitle => 'Controlla il tuo tempo per risultati migliori';

  @override
  String get tutExplanationTitle => 'Comprensione del Formato T.U.T.';

  @override
  String get tutFormat =>
      'Formato: Eccentrica - Pausa 1 - Concentrica - Pausa 2';

  @override
  String get tutPhaseEccentric => 'Fase Eccentrica';

  @override
  String get tutPhaseEccentricDesc =>
      'Abbassamento/allungamento del muscolo (es. abbassare il bilanciere nella panca)';

  @override
  String get tutPhasePause1 => 'Pausa in Basso';

  @override
  String get tutPhasePause1Desc => 'Mantieni la posizione in basso/allungata';

  @override
  String get tutPhaseConcentric => 'Fase Concentrica';

  @override
  String get tutPhaseConcentricDesc =>
      'Sollevamento/accorciamento del muscolo (es. spingere il bilanciere verso l\'alto)';

  @override
  String get tutPhasePause2 => 'Pausa in Alto';

  @override
  String get tutPhasePause2Desc => 'Mantieni la posizione in alto/contratta';

  @override
  String get tutExampleDesc =>
      '3 secondi giù, 1 secondo pausa, 2 secondi su, nessuna pausa in alto';

  @override
  String get tutBenefits => 'Vantaggi del Tempo Controllato';

  @override
  String get tutBenefit1 => 'Maggiore tensione e crescita muscolare';

  @override
  String get tutBenefit2 => 'Migliore connessione mente-muscolo';

  @override
  String get tutBenefit3 => 'Forma e controllo migliorati';

  @override
  String get tutBenefit4 => 'Ridotto rischio di infortuni';

  @override
  String get noExercisesYet => 'Nessun esercizio ancora';

  @override
  String get tapToAddExercise =>
      'Tocca il pulsante + per aggiungere il primo esercizio';

  @override
  String get confirm => 'Conferma';

  @override
  String get start => 'Inizia';

  @override
  String get add => 'Aggiungi';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get duplicate => 'Duplica';

  @override
  String get searchExercises => 'Cerca esercizi...';

  @override
  String get searchExercisesHint => 'Cerca per nome esercizio...';

  @override
  String get supersetInfo =>
      'Il Superset combina 2+ esercizi eseguiti consecutivamente con riposo minimo.';

  @override
  String get dropsetInfo =>
      'Drop Set: Esegui l\'esercizio fino al cedimento, poi riduci immediatamente il peso e continua.';

  @override
  String get restPauseInfo =>
      'Rest-Pause: Esegui fino al cedimento, riposa 10-15 secondi, ripeti fino alle ripetizioni target.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get signOut => 'Esci';

  @override
  String get pauseWorkout => 'Pausa Allenamento';

  @override
  String get endWorkout => 'Termina Allenamento';

  @override
  String get settingsTitle => '⚙️ Impostazioni';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLightDesc => 'Usa sempre il tema chiaro';

  @override
  String get themeDarkDesc => 'Usa sempre il tema scuro';

  @override
  String get themeSystemDesc => 'Segui l\'impostazione di sistema';

  @override
  String get fontSize => 'Dimensione Carattere';

  @override
  String get fontSizeSmall => 'Piccolo';

  @override
  String get fontSizeNormal => 'Normale';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get accentColor => 'Colore Principale';

  @override
  String get workout => 'Allenamento';

  @override
  String get autoStartTimer => 'Timer Automatico';

  @override
  String get autoStartTimerDesc =>
      'Avvia automaticamente il timer dopo ogni serie';

  @override
  String get defaultRestTime => 'Riposo Predefinito';

  @override
  String get advancedTechniques => 'Tecniche Avanzate';

  @override
  String get advancedTechniquesDesc => 'Mostra drop set, superset, ecc.';

  @override
  String get unitsLanguage => 'Unità e Lingua';

  @override
  String get language => 'Lingua';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglishDesc => 'Inglese (US)';

  @override
  String get languageItalianDesc => 'Italiano (IT)';

  @override
  String get weightUnits => 'Unità di Peso';

  @override
  String get weightUnitsKg => 'Chilogrammi (kg)';

  @override
  String get weightUnitsLbs => 'Libbre (lbs)';

  @override
  String get weightUnitsKgDesc => 'Sistema metrico';

  @override
  String get weightUnitsLbsDesc => 'Sistema imperiale';

  @override
  String get iosFeatures => 'Funzionalità iOS';

  @override
  String get liveActivities => 'Attività Live';

  @override
  String get liveActivitiesDesc =>
      'Mostra il timer sulla schermata di blocco e Dynamic Island';

  @override
  String get healthAppSync => 'Sincronizzazione Salute';

  @override
  String get healthAppSyncDesc =>
      'Sincronizza gli allenamenti con Apple Salute';

  @override
  String get audioFeedback => 'Audio e Feedback';

  @override
  String get soundEffects => 'Effetti Sonori';

  @override
  String get soundEffectsDesc => 'Riproduci suoni per timer e completamento';

  @override
  String get vibrations => 'Vibrazioni';

  @override
  String get vibrationsDesc => 'Feedback tattile per le interazioni';

  @override
  String get exportSettings => 'Esporta Impostazioni';

  @override
  String get exportSettingsDesc => 'Salva le impostazioni come file JSON';

  @override
  String get importSettings => 'Importa Impostazioni';

  @override
  String get importSettingsDesc => 'Carica le impostazioni da file JSON';

  @override
  String get resetToDefaults => 'Ripristina Predefiniti';

  @override
  String get resetToDefaultsDesc =>
      'Ripristina tutte le impostazioni predefinite';

  @override
  String get accountActions => 'Azioni Account';

  @override
  String get signOutDesc => 'Disconnetti dal tuo account';

  @override
  String get chooseTheme => 'Scegli Tema';

  @override
  String get chooseLanguage => 'Scegli Lingua';

  @override
  String get resetSettings => 'Ripristina Impostazioni';

  @override
  String get resetSettingsConfirm =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get signOutConfirm => 'Sei sicuro di volerti disconnettere?';

  @override
  String get save => 'Salva';

  @override
  String get accept => 'Accetta';

  @override
  String get dismiss => 'Ignora';

  @override
  String get restTimeSuggestion => 'Suggerimento Recupero';

  @override
  String get reset => 'Resetta';

  @override
  String get settingsResetSuccess =>
      'Impostazioni ripristinate ai valori predefiniti';

  @override
  String get exportFunctioningComingSoon =>
      'Funzionalità di esportazione in arrivo';

  @override
  String get importFunctioningComingSoon =>
      'Funzionalità di importazione in arrivo';

  @override
  String get editExercise => 'Modifica Esercizio';

  @override
  String get exerciseRestTime => 'Tempo di Riposo';

  @override
  String get exerciseRestTimeDesc => 'Tempo di riposo per questo esercizio';

  @override
  String get restTimeSeconds => 'secondi';

  @override
  String get setRestTime => 'Imposta Timer';

  @override
  String get customRestTime => 'Timer Personalizzato';

  @override
  String get useDefaultRestTime => 'Usa Timer Predefinito';

  @override
  String get yourTemplates => 'I Tuoi Template';

  @override
  String get popularTemplates => 'Schede Popolari';

  @override
  String get seeAll => 'Vedi tutti';

  @override
  String get welcomeToGymBro => 'Benvenuto nel tuo nuovo compagno fitness!';

  @override
  String get homeWelcomeDescription =>
      'Traccia i tuoi allenamenti con precisione. Inizia una nuova sessione o continua da dove avevi lasciato.';

  @override
  String get quickActions => 'Azioni Rapide';

  @override
  String get startFresh => 'Inizia da capo';

  @override
  String get history => 'Storico';

  @override
  String get viewPastWorkouts => 'Visualizza allenamenti passati';

  @override
  String get analytics => 'Analisi';

  @override
  String get trackProgress => 'Traccia progressi';

  @override
  String get templates => 'Template';

  @override
  String get workoutRoutines => 'Routine di allenamento';

  @override
  String get customizeApp => 'Personalizza app';

  @override
  String get importExercises => 'Importa Esercizi';

  @override
  String get loadFromJson => 'Carica da JSON';

  @override
  String get activeWorkout => 'Allenamento Attivo';

  @override
  String get pausedWorkout => 'Allenamento in Pausa';

  @override
  String get continueButton => 'Continua';

  @override
  String get resume => 'Riprendi';

  @override
  String get end => 'TERMINA';

  @override
  String get endWorkoutConfirm =>
      'Sei sicuro di voler terminare l\'allenamento corrente?';

  @override
  String get workoutCompleted => '🎉 Allenamento completato!';

  @override
  String get appSettings => 'Impostazioni App';

  @override
  String get historyFeatureComingSoon => 'Funzionalità cronologia in arrivo!';

  @override
  String get customizeTemplate => 'Personalizza questo template';

  @override
  String get deleteTemplatePermanently =>
      'Elimina definitivamente questo template';

  @override
  String get removeExercise => 'Rimuovi Esercizio';

  @override
  String confirmRemoveExercise(String exerciseName) {
    return 'Rimuovere \"$exerciseName\" dal template?';
  }

  @override
  String get timerSound => 'Suono Timer';

  @override
  String get timerSoundDescription =>
      'Scegli il suono che viene riprodotto quando il timer di riposo termina';

  @override
  String get currentSound => 'Attuale';

  @override
  String get playPreview => 'Anteprima';

  @override
  String get playingPreview => 'Riproduzione anteprima';

  @override
  String get statisticsDashboard => 'Dashboard Statistiche';

  @override
  String get workoutAnalytics => 'Analisi Allenamenti';

  @override
  String get progressTracking => 'Monitoraggio Progressi';

  @override
  String get detailedAnalytics => 'Analisi Dettagliate';

  @override
  String get thisWeek => 'Questa Settimana';

  @override
  String get totalVolume => 'Volume Totale';

  @override
  String get consistency => 'Costanza';

  @override
  String get totalWorkouts => 'Allenamenti Totali';

  @override
  String get completedSessions => 'Sessioni Completate';

  @override
  String get weightLifted => 'Peso Sollevato';

  @override
  String get averageWorkoutTime => 'Durata Media Allenamento';

  @override
  String get perSession => 'Per Sessione';

  @override
  String get personalRecords => 'Record Personali';

  @override
  String get newPRs => 'Nuovi PR';

  @override
  String get weeklyVolumeChart => 'Grafico Volume Settimanale';

  @override
  String get workoutFrequency => 'Frequenza Allenamenti';

  @override
  String get bodyPartDistribution => 'Distribuzione Gruppi Muscolari';

  @override
  String get topExercises => 'Esercizi Principali';

  @override
  String get workoutStreak => 'Serie di Allenamenti';

  @override
  String get dayStreak => 'Serie Giorni';

  @override
  String get nextMilestone => 'Prossimo Traguardo';

  @override
  String get longestStreak => 'Streak massimo';

  @override
  String get totalDays => 'Giorni Totali';

  @override
  String get days => 'giorni';

  @override
  String get errorLoadingData => 'Errore nel caricamento dei dati';

  @override
  String get exportData => 'Esporta Dati';

  @override
  String get viewDetails => 'Visualizza Dettagli';

  @override
  String get noVolumeData => 'Nessun dato sul volume disponibile';

  @override
  String get noFrequencyData => 'Nessun dato sulla frequenza disponibile';

  @override
  String get noBodyPartData => 'Nessun dato sui gruppi muscolari disponibile';

  @override
  String get noExerciseData => 'Nessun dato sugli esercizi disponibile';

  @override
  String get noWorkoutData => 'Nessun dato allenamento ancora';

  @override
  String get completeWorkoutsToSeeAnalytics =>
      'Completa alcuni allenamenti per vedere le\ntue analisi e progressi!';

  @override
  String get startFirstWorkout => 'Inizia il Tuo Primo Allenamento';

  @override
  String volumeIncreased(String amount) {
    return 'Volume aumentato di ${amount}kg dalla settimana scorsa';
  }

  @override
  String volumeDecreased(String amount) {
    return 'Volume diminuito di ${amount}kg dalla settimana scorsa';
  }

  @override
  String get workouts => 'allenamenti';

  @override
  String bestWorkoutDay(String day) {
    return 'Miglior giorno di allenamento: $day';
  }

  @override
  String averageWorkoutsPerDay(String average) {
    return 'Media: $average allenamenti al giorno';
  }

  @override
  String get monday => 'Lunedì';

  @override
  String get tuesday => 'Martedì';

  @override
  String get wednesday => 'Mercoledì';

  @override
  String get thursday => 'Giovedì';

  @override
  String get friday => 'Venerdì';

  @override
  String get saturday => 'Sabato';

  @override
  String get sunday => 'Domenica';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mer';

  @override
  String get thursdayShort => 'Gio';

  @override
  String get fridayShort => 'Ven';

  @override
  String get saturdayShort => 'Sab';

  @override
  String get sundayShort => 'Dom';

  @override
  String get filterStatistics => 'Filtra Statistiche';

  @override
  String get timePeriod => 'Periodo Temporale';

  @override
  String get muscleGroups => 'Gruppi Muscolari';

  @override
  String get musclePectorals => 'Pettorali';

  @override
  String get muscleLats => 'Dorsali';

  @override
  String get muscleDeltoids => 'Spalle';

  @override
  String get muscleBiceps => 'Bicipiti';

  @override
  String get muscleTriceps => 'Tricipiti';

  @override
  String get muscleTrapezius => 'Trapezi';

  @override
  String get muscleRhomboids => 'Romboidi';

  @override
  String get muscleQuads => 'Quadricipiti';

  @override
  String get muscleGlutes => 'Glutei';

  @override
  String get muscleHamstrings => 'Femorali';

  @override
  String get muscleCalves => 'Polpacci';

  @override
  String get muscleAbs => 'Addominali';

  @override
  String get muscleObliques => 'Obliqui';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleForearms => 'Avambracci';

  @override
  String get muscleAdductors => 'Adduttori';

  @override
  String get muscleLowerBack => 'Lombari';

  @override
  String get lastWeek => 'Ultima Settimana';

  @override
  String get lastMonth => 'Ultimo Mese';

  @override
  String get lastThreeMonths => 'Ultimi 3 Mesi';

  @override
  String get applyFilters => 'Applica Filtri';

  @override
  String get improvingProgressSummary =>
      'I tuoi progressi stanno migliorando! Continua così!';

  @override
  String get needsImprovementSummary =>
      'I tuoi progressi hanno bisogno di miglioramenti. Rimani costante!';

  @override
  String get steadyProgressSummary =>
      'I tuoi progressi sono costanti. Ottima coerenza!';

  @override
  String get weeklyProgress => 'Progressi Settimanali';

  @override
  String get workoutGoal => 'Obiettivo Allenamenti';

  @override
  String get volumeGoal => 'Obiettivo Volume';

  @override
  String get rpe => 'RPE';

  @override
  String get rpeDescription => 'Percezione dello Sforzo (6-10)';

  @override
  String get rir => 'RIR';

  @override
  String get rirDescription => 'Ripetizioni di Riserva';

  @override
  String get actualReps => 'Reps Effettive';

  @override
  String targetReps(int reps) {
    return 'Target $reps reps';
  }

  @override
  String get repsCompleted => 'Ripetizioni Completate';

  @override
  String get actualRepsCompleted => 'Ripetizioni Effettivamente Completate';

  @override
  String get recordSetCompletion => 'Registra Completamento Serie';

  @override
  String get howHardWasTheSet => 'Quanto è stata difficile questa serie?';

  @override
  String get veryEasy => 'Molto Facile';

  @override
  String get easy => 'Facile';

  @override
  String get moderate => 'Moderata';

  @override
  String get hard => 'Difficile';

  @override
  String get maximal => 'Massimale';

  @override
  String get ofWord => 'di';

  @override
  String get skipRpe => 'Salta RPE';

  @override
  String get confirmSet => 'Conferma Serie';

  @override
  String get repsInReserve => 'reps in riserva';

  @override
  String get preferredTemplateSet => 'Template preferito impostato!';

  @override
  String get preferredTemplateRemoved => 'Template preferito rimosso';

  @override
  String get choosePreferredTemplate => 'Scegli Template Preferito';

  @override
  String get removePreferredTemplate => 'Rimuovi Template Preferito';

  @override
  String get startWithEmptyWorkout => 'Inizia con un allenamento vuoto';

  @override
  String get tapToStart => 'Tocca per iniziare';

  @override
  String get errorLoadingTemplates => 'Errore caricamento template';

  @override
  String get syncingWorkouts => 'Sincronizzazione allenamenti...';

  @override
  String get loadingWorkouts => 'Caricamento allenamenti...';

  @override
  String get errorLoadingWorkouts => 'Errore nel caricamento degli allenamenti';

  @override
  String get notifications => 'Notifiche';

  @override
  String get markAllAsRead => 'Segna Tutto Come Letto';

  @override
  String get noNotifications => 'Nessuna notifica ancora';

  @override
  String get notificationsDescription =>
      'Ti terremo aggiornato sui tuoi progressi!';

  @override
  String get workoutReminderTitle => 'Promemoria Allenamento';

  @override
  String workoutReminderBody(String workoutName) {
    return 'È ora del tuo allenamento $workoutName! 💪';
  }

  @override
  String get recoveryAlertTitle => 'Recupero Necessario';

  @override
  String recoveryAlertBodySingle(int days) {
    return 'Hai $days giorno saltato da recuperare! 🔄';
  }

  @override
  String recoveryAlertBodyMultiple(int days) {
    return 'Hai $days giorni saltati da recuperare! 🔄';
  }

  @override
  String get streakMotivationTitle => 'Mantieni la Serie!';

  @override
  String streakMotivationBody(int streak) {
    return '$streak giorni di serie! Non romperla ora! 🔥';
  }

  @override
  String get restDayTitle => 'Giorno di Riposo';

  @override
  String get restDayBody =>
      'Oggi è il tuo giorno di riposo. Il recupero è altrettanto importante! 😴';

  @override
  String get enableWorkoutReminders => 'Abilita Promemoria Allenamento';

  @override
  String get enableRecoveryAlerts => 'Abilita Avvisi Recupero';

  @override
  String get enableStreakMotivation => 'Abilita Motivazione Serie';

  @override
  String get enableRestDayReminders => 'Abilita Promemoria Riposo';

  @override
  String get preferredNotificationTime => 'Orario Preferito';

  @override
  String get doNotDisturb => 'Non Disturbare';

  @override
  String get morningTime => 'Mattina (8:00)';

  @override
  String get middayTime => 'Mezzogiorno (12:30)';

  @override
  String get afternoonTime => 'Pomeriggio (16:00)';

  @override
  String get eveningTime => 'Sera (19:00)';

  @override
  String get customTime => 'Ora personalizzata';

  @override
  String get newWeightPR => 'Nuovo Record di Peso!';

  @override
  String get newRepsPR => 'Nuovo Record di Ripetizioni!';

  @override
  String get newOneRMPR => 'Nuovo Record 1RM!';

  @override
  String get newVolumePR => 'Nuovo Record di Volume!';

  @override
  String get buildingMomentum => 'Stai Prendendo Slancio!';

  @override
  String get oneWeekStrong => 'Una Settimana Forte!';

  @override
  String get twoWeeksStreak => 'Due Settimane di Serie!';

  @override
  String get oneMonthStreak => 'UN MESE DI SERIE!';

  @override
  String get legendaryStreak => 'SERIE LEGGENDARIA!';

  @override
  String get volumeMilestone => 'Traguardo Volume!';

  @override
  String get massiveVolume => 'VOLUME MASSICCIO!';

  @override
  String get legendaryVolume => 'VOLUME LEGGENDARIO!';

  @override
  String get quickStats => 'I tuoi progressi';

  @override
  String get streak => 'Serie';

  @override
  String get achievements => 'Obiettivi';

  @override
  String get exerciseInfo => 'Info';

  @override
  String get warmup => 'Riscaldamento';

  @override
  String get safetyTips => 'Prevenzione';

  @override
  String get warmupAndMobility => 'Riscaldamento e Mobilità';

  @override
  String get exerciseInformation => 'Informazioni Esercizio';

  @override
  String get safetyAndPrevention => 'Sicurezza e Prevenzione';

  @override
  String get preWorkoutMobility => 'Mobilità Pre-Allenamento';

  @override
  String get muscleActivation => 'Attivazione Muscolare';

  @override
  String get warmupSets => 'Serie di Riscaldamento';

  @override
  String get recommendedWarmup => 'Riscaldamento Consigliato';

  @override
  String get warmupSmart => 'SMART';

  @override
  String get warmupTap => 'Tocca';

  @override
  String get warmupIntelligentProgression => 'Progressione Intelligente';

  @override
  String warmupProgressionDescription(
    String startWeight,
    String endWeight,
    String steps,
  ) {
    return 'Da ${startWeight}kg a ${endWeight}kg in $steps step';
  }

  @override
  String get workingWeight => 'Peso di Lavoro';

  @override
  String get emptyBarbell => 'Bilanciere Vuoto';

  @override
  String get customize => 'Personalizza';

  @override
  String get addAll => 'Aggiungi tutti';

  @override
  String editSet(String percentage) {
    return 'Modifica Set $percentage%';
  }

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String warmupSetsAdded(String count) {
    return 'Aggiunti $count set di riscaldamento';
  }

  @override
  String get warmupDuration => 'Durata Riscaldamento';

  @override
  String get primaryMuscles => 'Muscoli Primari';

  @override
  String get secondaryMuscles => 'Muscoli Secondari';

  @override
  String get difficultyLevel => 'Livello di Difficoltà';

  @override
  String get exerciseType => 'Tipo Esercizio';

  @override
  String get equipment => 'Attrezzatura';

  @override
  String get movementPattern => 'Pattern Movimento';

  @override
  String get repRange => 'Range Ripetizioni';

  @override
  String get injuryPrevention => 'Prevenzione Infortuni';

  @override
  String get recommendedCooldown => 'Defaticamento Consigliato';

  @override
  String get technicalDrills => 'Esercizi Tecnici';

  @override
  String get technicalNotes => 'Suggerimenti Tecnici';

  @override
  String get targetMuscles => 'Muscoli target';

  @override
  String get exerciseDetails => 'Dettagli Esercizio';

  @override
  String get preparation => 'Preparazione';

  @override
  String get specificWarmup => 'Riscaldamento Specifico';

  @override
  String get safetyAndTechnique => 'Sicurezza e Tecnica';

  @override
  String get recovery => 'Recupero';

  @override
  String goodMorning(String name) {
    return 'Buongiorno, $name!';
  }

  @override
  String goodAfternoon(String name) {
    return 'Buon pomeriggio, $name!';
  }

  @override
  String goodEvening(String name) {
    return 'Buonasera, $name!';
  }

  @override
  String get readyToDominate => 'Pronto per dominare?';

  @override
  String get workoutActive => 'ALLENAMENTO ATTIVO';

  @override
  String get workoutPaused => 'IN PAUSA';

  @override
  String get duration => 'Durata';

  @override
  String get reorderExercises => 'Riordina esercizi';

  @override
  String get confirmReorder => 'Conferma ordine';

  @override
  String get orderSaved => 'Ordine salvato';

  @override
  String get startNow => 'Inizia Subito';

  @override
  String get startImmediately =>
      'Inizia immediatamente e aggiungi esercizi al volo';

  @override
  String get workoutStartedQuickly =>
      'Allenamento iniziato! Aggiungi esercizi man mano';

  @override
  String get calories => 'Calorie';

  @override
  String get aiCoach => 'AI Coach';

  @override
  String get showPR => 'Mostra PR';

  @override
  String get analyzeVolume => 'Analizza volume';

  @override
  String get howIsTraining => 'Come va l\'allenamento?';

  @override
  String get needRest => 'Serve riposo?';

  @override
  String criticalInsights(int count) {
    return '$count Critici';
  }

  @override
  String get noInsights => 'Ottimo Lavoro!';

  @override
  String get noInsightsDescription =>
      'Ti stai allenando in modo ottimale. Continua così!';

  @override
  String get errorLoadingInsights => 'Errore nel caricamento degli insights';

  @override
  String get volume => 'Volume';

  @override
  String get startWorkoutQuick => 'INIZIA ALLENAMENTO';

  @override
  String get suggestedForToday => 'Suggerito per oggi';

  @override
  String get yourProgress => 'I Tuoi Progressi';

  @override
  String get pushDay => 'Push Day';

  @override
  String get pullDay => 'Pull Day';

  @override
  String get legDay => 'Leg Day';

  @override
  String get chestShouldersTriceps => 'Petto, Spalle, Tricipiti';

  @override
  String get backBiceps => 'Schiena, Bicipiti';

  @override
  String get legsGlutes => 'Gambe, Glutei';

  @override
  String get intensiveCardio => 'Cardio Intenso';

  @override
  String get quickTemplates => 'Template Veloci';

  @override
  String get predefined => 'Predefiniti';

  @override
  String get myTemplates => 'Le Mie Schede';

  @override
  String get noPersonalTemplates => 'Nessun template personale';

  @override
  String get createFirstTemplate => 'Crea il tuo primo template!';

  @override
  String get createTemplate => 'Crea Template';

  @override
  String get otherTools => 'Altri strumenti';

  @override
  String get workoutHistory => 'Cronologia';

  @override
  String get pastWorkouts => 'Workout passati';

  @override
  String workoutStarted(String name) {
    return 'Allenamento \"$name\" iniziato!';
  }

  @override
  String get templateNotFound => 'Template non trovato';

  @override
  String get loadingTemplate => 'Caricamento template...';

  @override
  String templateLoadError(String error) {
    return 'Errore nel caricamento template: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'Errore imprevisto: $error';
  }

  @override
  String workoutInProgress(String name) {
    return 'Allenamento in Corso';
  }

  @override
  String get workoutDiscarded => 'Allenamento scartato';

  @override
  String get workoutSavedSuccessfully => 'Allenamento salvato con successo!';

  @override
  String get howToEndWorkout => 'Come vuoi terminare l\'allenamento?';

  @override
  String get discard => 'Scarta';

  @override
  String get saveAndEnd => 'Salva e Termina';

  @override
  String get aiCoachFirstWorkout =>
      'Inizia il tuo primo allenamento per sbloccare consigli personalizzati!';

  @override
  String aiCoachStreakMessage(int days) {
    return 'Ottimo lavoro! $days giorni consecutivi di allenamento. Mantieni questo ritmo eccezionale!';
  }

  @override
  String aiCoachVolumeIncrease(String increase) {
    return 'Il tuo volume è aumentato del $increase! Continua così per massimizzare i risultati';
  }

  @override
  String aiCoachNewPR(String weight, String exercise) {
    return 'Hai stabilito un nuovo PR di $weight su $exercise! Punta a superarlo';
  }

  @override
  String get aiCoachConsistency =>
      'Concentrati sulla consistenza: prova ad allenarti almeno 3-4 volte questa settimana';

  @override
  String get aiCoachPersonalized => 'Personalizzato per te';

  @override
  String get aiCoachTapHint => 'Tocca per insights dettagliati';

  @override
  String get aiCoachDetailed => 'Approfondimenti AI Coach';

  @override
  String get aiCoachModalPlaceholder =>
      'Insights intelligenti in arrivo! Il tuo AI Coach analizzerà i tuoi pattern di allenamento e fornirà raccomandazioni personalizzate.';

  @override
  String get aiCoachDisclaimer =>
      'Questi sono consigli generali basati sui tuoi dati di allenamento. Consulta sempre un professionista del fitness qualificato prima di apportare modifiche significative al tuo programma di allenamento.';

  @override
  String get aiBadge => 'AI';

  @override
  String get badgeCritical => 'CRITICO';

  @override
  String get badgeWarning => 'ATTENZIONE';

  @override
  String get badgeInfo => 'INFO';

  @override
  String get badgeSuccess => 'OTTIMO';

  @override
  String get aiInsightStartJourney => 'Inizia il Tuo Percorso';

  @override
  String get aiInsightStartJourneyDesc =>
      'Inizia a tracciare gli allenamenti per sbloccare insights personalizzati';

  @override
  String get aiInsightStartJourneyRec =>
      'Completa il tuo primo allenamento per iniziare';

  @override
  String get aiCoachSeriesPerWeek => 'serie/sett';

  @override
  String get aiCoachTons => 'tonnellate';

  @override
  String get aiCoachCurrentVolume => 'Volume attuale';

  @override
  String get aiCoachProgressiveLoad => 'Carico progressivo';

  @override
  String get aiCoachTimesPerWeek => 'volte/sett';

  @override
  String get aiCoachCurrentFrequency => 'Frequenza attuale';

  @override
  String aiCoachMEVRange(String min, String max) {
    return 'MEV: $min-$max serie';
  }

  @override
  String get aiCoachScientificReferences => 'Riferimenti Scientifici';

  @override
  String get aiInsightNewUser => 'Ottimo Inizio!';

  @override
  String get aiInsightNewUserDesc =>
      'Stai costruendo solide basi! Mantieni la costanza per insights migliori';

  @override
  String get aiInsightNewUserRec =>
      'Completa 5+ allenamenti per sbloccare l\'analisi AI avanzata';

  @override
  String get aiInsightMuscleImbalance => 'Squilibrio Gruppi Muscolari';

  @override
  String aiInsightMuscleImbalanceDesc(String muscleGroup) {
    return '$muscleGroup è sotto-allenato questa settimana';
  }

  @override
  String aiInsightMuscleImbalanceRec(String muscleGroup) {
    return 'Aggiungi 2-3 esercizi per $muscleGroup al prossimo allenamento';
  }

  @override
  String get aiInsightPlateauAlert => 'Allarme Plateau';

  @override
  String aiInsightPlateauDesc(String exercise) {
    return 'Il peso di $exercise non è aumentato in 3+ sessioni';
  }

  @override
  String get aiInsightPlateauRec =>
      'Prova ad aumentare il peso di 2,5-5kg o aggiungi più ripetizioni';

  @override
  String get aiInsightInsufficientRecovery => 'Recupero Insufficiente';

  @override
  String get aiInsightInsufficientRecoveryDesc =>
      'Ti alleni troppo frequentemente senza riposo';

  @override
  String get aiInsightInsufficientRecoveryRec =>
      'Considera di aggiungere 1-2 giorni di riposo tra le sessioni';

  @override
  String get aiInsightLongRecovery => 'Periodi di Recupero Lunghi';

  @override
  String get aiInsightLongRecoveryDesc => 'Troppo tempo tra gli allenamenti';

  @override
  String get aiInsightLongRecoveryRec =>
      'Cerca di mantenere 2-3 giorni tra le sessioni per progresso ottimale';

  @override
  String get aiInsightLowVolume => 'Volume di Allenamento Basso';

  @override
  String aiInsightLowVolumeDesc(int sets) {
    return 'Media attuale: $sets serie per allenamento';
  }

  @override
  String get aiInsightLowVolumeRec =>
      'Considera di aggiungere 3-5 serie in più per massimizzare la crescita';

  @override
  String get aiInsightHighVolume => 'Volume di Allenamento Alto';

  @override
  String aiInsightHighVolumeDesc(int sets) {
    return 'Media attuale: $sets serie per allenamento';
  }

  @override
  String get aiInsightHighVolumeRec =>
      'Considera di ridurre il volume per evitare il sovrallenamento';

  @override
  String get aiInsightLowFrequency => 'Frequenza di Allenamento Bassa';

  @override
  String aiInsightLowFrequencyDesc(String frequency) {
    return 'Attualmente ti alleni $frequency volte a settimana';
  }

  @override
  String get aiInsightLowFrequencyRec =>
      'Punta a 3-4 sessioni a settimana per risultati ottimali';

  @override
  String get aiInsightHighFrequency => 'Frequenza Molto Alta';

  @override
  String aiInsightHighFrequencyDesc(String frequency) {
    return 'Ti alleni $frequency volte a settimana';
  }

  @override
  String get aiInsightHighFrequencyRec =>
      'Considera di aggiungere più giorni di riposo per prevenire il burnout';

  @override
  String get aiInsightVolumePlateau => 'Plateau di Volume Rilevato';

  @override
  String get aiInsightVolumePlateauDesc =>
      'Il volume di allenamento non è aumentato significativamente';

  @override
  String get aiInsightVolumePlateauRec =>
      'Prova nuovi esercizi, tecniche o aumenta l\'intensità';

  @override
  String get aiInsightOptimalVolume => 'Volume Perfetto!';

  @override
  String aiInsightOptimalVolumeDesc(String muscleGroup, int sets) {
    return 'Il volume di $muscleGroup è nel range ottimale ($sets serie/settimana)';
  }

  @override
  String get aiInsightOptimalVolumeRec =>
      'Continua così! Sei nel punto ideale per la crescita muscolare';

  @override
  String get aiInsightLargeWeightJump => 'Grande Salto di Peso';

  @override
  String aiInsightLargeWeightJumpDesc(String exercise, int increase) {
    return 'Il peso di $exercise è aumentato del $increase%';
  }

  @override
  String get aiInsightLargeWeightJumpRec =>
      'Assicurati di mantenere la forma corretta con questo aumento di peso';

  @override
  String get muscleGroupLegs => 'Gambe';

  @override
  String get muscleGroupChest => 'Petto';

  @override
  String get muscleGroupBack => 'Schiena';

  @override
  String get muscleGroupShoulders => 'Spalle';

  @override
  String get muscleGroupArms => 'Braccia';

  @override
  String get muscleGroupOther => 'Altro';

  @override
  String get perWeek => 'a settimana';

  @override
  String get target => 'Target';

  @override
  String get frequency => 'Frequenza';

  @override
  String get noRecord => 'Nessun record';

  @override
  String get startToday => 'Inizia oggi!';

  @override
  String get great => 'Grande!';

  @override
  String get keepGoing => 'Continua così!';

  @override
  String get day => 'Giorno';

  @override
  String get pullToRefresh => 'Trascina per aggiornare';

  @override
  String get weeklyFrequency => 'Frequenza Settimanale';

  @override
  String get excellentProgress => 'Progressi Eccellenti!';

  @override
  String get goodProgress => 'Buoni Progressi!';

  @override
  String get getStarted => 'Iniziamo!';

  @override
  String get streakMotivation => 'Motivazione Streak';

  @override
  String get consistencyMotivation =>
      'Grande costanza! Continua a costruire il tuo slancio.';

  @override
  String get buildStreakMotivation =>
      'Costruisci la tua serie rimanendo costante!';

  @override
  String get streakInfo =>
      'La serie conta i giorni consecutivi con almeno un allenamento completato.';

  @override
  String get totalWorkoutsInfo =>
      'Numero totale di sessioni di allenamento che hai completato.';

  @override
  String get weeklyFrequencyInfo =>
      'Numero medio di giorni di allenamento per settimana nelle ultime 4 settimane.';

  @override
  String get retry => 'Riprova';

  @override
  String get community => 'Community';

  @override
  String get communityComingSoonTitle => 'Funzionalità Community in Arrivo';

  @override
  String get communityComingSoonDescription =>
      'Stiamo lavorando per creare una fantastica funzionalità community dove potrai connetterti con altri atleti, condividere i tuoi progressi e imparare gli uni dagli altri. Resta sintonizzato!';

  @override
  String get generalInformation => 'Informazioni Generali';

  @override
  String get technicalNotesAndTut => 'Note Tecniche & TuT';

  @override
  String get warmupAndPreparation => 'Riscaldamento & Preparazione';

  @override
  String get technicalDrill => 'Drill Tecnico';

  @override
  String get termsExplanation => 'Spiegazione Termini';

  @override
  String get addToSelection => 'Aggiungi alla Selezione';

  @override
  String get exercisesFound => 'esercizi trovati';

  @override
  String get addedToSelection => 'aggiunto alla selezione';

  @override
  String get primaryFocus => 'Focus Principale';

  @override
  String get preMobilityWork => 'Mobilità Pre-Workout';

  @override
  String get preActivation => 'Attivazione Pre-Workout';

  @override
  String get filters => 'Filtri';

  @override
  String get addToWorkout => 'Aggiungi alla Scheda';

  @override
  String get exercisesSelected => 'esercizi selezionati';

  @override
  String get noExercisesFound => 'Nessun esercizio trovato';

  @override
  String get tryModifyingFilters => 'Prova a modificare i filtri di ricerca';

  @override
  String get clearAllFilters => 'Rimuovi tutti i filtri';

  @override
  String get minutes => 'min';

  @override
  String get noTemplatesYet => 'Nessuna scheda ancora';

  @override
  String get difficulty => 'Difficoltà';

  @override
  String get errorOccurred =>
      'Si è verificato un errore durante il caricamento dell\'allenamento';

  @override
  String get ok => 'OK';

  @override
  String get networkError => 'Errore di rete';

  @override
  String get databaseError => 'Errore Database';

  @override
  String get validationError => 'Errore di Validazione';

  @override
  String get permissionDenied => 'Permesso Negato';

  @override
  String get storageError => 'Errore di Archiviazione';

  @override
  String get unknownError => 'Errore Sconosciuto';

  @override
  String get userNotFound => 'Utente non trovato';

  @override
  String get wrongPassword => 'Password Errata';

  @override
  String get emailAlreadyInUse => 'Email Già in Uso';

  @override
  String get invalidEmail => 'Email Non Valida';

  @override
  String get weakPassword => 'Password Troppo Debole';

  @override
  String get authenticationError => 'Errore di Autenticazione';

  @override
  String get criticalError => 'Errore Critico';

  @override
  String get goBack => 'Indietro';

  @override
  String get startNewCycle => 'Inizia nuovo ciclo';

  @override
  String get continueRoutine => 'Continua la tua routine';

  @override
  String resumeAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return 'Riprendi dopo $days $_temp0';
  }

  @override
  String restartCycleAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return 'Ricomincia il ciclo dopo $days $_temp0';
  }

  @override
  String get nextInRotation => 'Prossimo nella rotazione';

  @override
  String get yourMostFrequentWorkout => 'Il tuo allenamento più frequente';

  @override
  String get selectExercise => 'Seleziona Esercizio';

  @override
  String get originalExercise => 'Esercizio originale';

  @override
  String get suggestedMatches => 'Corrispondenze suggerite';

  @override
  String get match => 'corrispondenza';

  @override
  String get linkedTo => 'Collegato a';

  @override
  String get skipExercise => 'Salta Esercizio';

  @override
  String get createNewExercise => 'Crea Nuovo';

  @override
  String get useSelectedExercise => 'Usa Selezionato';

  @override
  String get workoutTemplates => 'Schede Allenamento';

  @override
  String get discover => 'Scopri';

  @override
  String get searchContributions => 'Cerca contributi...';

  @override
  String get sort => 'Ordina';

  @override
  String get noContributionsFound => 'Nessun contributo trovato';

  @override
  String get tryDifferentSearch => 'Prova a modificare la ricerca o i filtri';

  @override
  String get errorLoadingContributions => 'Errore caricamento contributi';

  @override
  String get trending => 'Tendenze';

  @override
  String get avgRating => 'Valut. Media';

  @override
  String get newTemplate => 'Nuova Scheda';

  @override
  String get searchTemplates => 'Cerca schede...';

  @override
  String get noPublicTemplatesFound => 'Nessuna scheda pubblica trovata';

  @override
  String get trendingComingSoon => 'Schede di tendenza in arrivo!';

  @override
  String get maxTemplatesReached => 'Hai raggiunto il numero massimo di schede';

  @override
  String get createManually => 'Crea Manualmente';

  @override
  String get buildFromScratch => 'Costruisci la tua scheda da zero';

  @override
  String get importFromJSON => 'Importa da JSON';

  @override
  String get importJSONDescription => 'Importa una scheda dal formato JSON';

  @override
  String get importFromFile => 'Importa da File';

  @override
  String get importFileDescription =>
      'Seleziona un file JSON dal tuo dispositivo';

  @override
  String get jsonFormatGuide => 'Guida Formato JSON';

  @override
  String get jsonFormatDescription =>
      '📝 Come convertire la tua scheda:\n1. Copia la tua scheda (testo o foto)\n2. Vai su ChatGPT (gratis su chat.openai.com)\n3. Chiedi: \"Converti questa scheda in formato JSON come questo esempio\"\n4. Copia e incolla il risultato qui sotto\n\n⚙️ Campi richiesti: name, description, exercises array. Ogni esercizio deve avere: exerciseName, sets con targetReps/targetWeight. I superset devono avere type:\"superset\" e exercises array.';

  @override
  String get copyExample => 'Copia esempio';

  @override
  String get exampleCopied => 'Esempio copiato negli appunti';

  @override
  String get exampleCopiedAndPasted => 'Esempio copiato e incollato nel campo';

  @override
  String get tapToCopyAndPaste =>
      'Tocca per copiare e incollare nel campo sottostante';

  @override
  String get tapToCopyToClipboard => 'Tocca per copiare negli appunti';

  @override
  String get tapToExpandExample => 'Tocca per espandere esempio e guida';

  @override
  String get hideKeyboard => 'Nascondi Tastiera';

  @override
  String exerciseNotFoundInDatabase(String exerciseName) {
    return 'Esercizio \"$exerciseName\" non trovato nel database - uso nome originale';
  }

  @override
  String get exerciseNotFound => 'Non trovi l\'esercizio?';

  @override
  String exerciseNotFoundDescription(String exerciseName) {
    return 'L\'esercizio \"$exerciseName\" non è stato trovato nel nostro database. Cosa vorresti fare?';
  }

  @override
  String get exerciseNotFoundHelpText =>
      'Aggiungilo temporaneamente e lo inseriremo presto nel database!';

  @override
  String get whatWouldYouLikeToDo => 'Cosa vorresti fare?';

  @override
  String get chooseFromDatabase => 'Scegli dal Database';

  @override
  String get createCustom => 'Crea Personalizzato';

  @override
  String get useOriginalName => 'Usa Nome Originale';

  @override
  String get skip => 'Salta';

  @override
  String get selectExerciseFromDatabase => 'Seleziona Esercizio dal Database';

  @override
  String get noExercisesInDatabase => 'Nessun esercizio trovato nel database';

  @override
  String get createCustomExercise => 'Crea Esercizio Personalizzato';

  @override
  String get category => 'Categoria';

  @override
  String get customExerciseNote =>
      'Questo esercizio verrà salvato nella tua lista personale';

  @override
  String get create => 'Crea';

  @override
  String get premiumFeature => 'Funzionalità Premium';

  @override
  String get customExerciseLimit =>
      'Gli utenti gratuiti possono creare fino a 3 esercizi personalizzati per import. Passa a Premium per esercizi personalizzati illimitati!';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get deleteTemplate => 'Elimina Template';

  @override
  String confirmDeleteTemplate(String templateName) {
    return 'Sei sicuro di voler eliminare \"$templateName\"?';
  }

  @override
  String templateDeleted(String name) {
    return 'Template \"$name\" eliminato';
  }

  @override
  String get shareLinkCopied => 'Link di condivisione copiato negli appunti!';

  @override
  String templateDownloaded(String templateName) {
    return 'Scheda \"$templateName\" scaricata!';
  }

  @override
  String get failedToDownload => 'Impossibile scaricare la scheda';

  @override
  String get pasteWorkoutJSON =>
      'Incolla il JSON della scheda allenamento qui sotto:';

  @override
  String get viewJSONFormat => 'Visualizza Formato JSON';

  @override
  String get pasteJSONHere => 'Incolla JSON qui...';

  @override
  String get import => 'Importa';

  @override
  String get pleaseProvideJSON => 'Inserisci il contenuto JSON';

  @override
  String templateImportedSuccessfully(String templateName) {
    return 'Scheda \"$templateName\" importata con successo!';
  }

  @override
  String get importedProgram => 'Programma Importato';

  @override
  String get noDaysFoundInProgram => 'Nessun giorno trovato nel programma';

  @override
  String get selectDayToImport => 'Seleziona Giorno da Importare';

  @override
  String programFoundWithDays(String programName, int dayCount) {
    return 'Trovato programma \"$programName\" con $dayCount giorni:';
  }

  @override
  String get select => 'Seleziona';

  @override
  String exercisesCount(int count) {
    return '$count esercizi';
  }

  @override
  String importedFromProgram(String programName) {
    return 'Importato dal programma: $programName';
  }

  @override
  String errorImportingJSON(String error) {
    return 'Errore nell\'importazione JSON: $error';
  }

  @override
  String get filtersComingSoon => 'Filtri in arrivo';

  @override
  String byAuthor(String authorName) {
    return 'di $authorName';
  }

  @override
  String get anonymous => 'Anonimo';

  @override
  String get week => 'Settimana';

  @override
  String get month => 'Mese';

  @override
  String get improvement => 'Miglioramento';

  @override
  String get decline => 'Declino';

  @override
  String get stall => 'Stallo';

  @override
  String get totalExercises => 'Totale';

  @override
  String get totalSets => 'Serie Totali';

  @override
  String get avgVolumePerWorkout => 'Volume Medio Per Allenamento';

  @override
  String get average => 'Media';

  @override
  String get record => 'Record';

  @override
  String get trend => 'Trend';

  @override
  String get chest => 'Petto';

  @override
  String get back => 'Schiena';

  @override
  String get shoulders => 'Spalle';

  @override
  String get arms => 'Braccia';

  @override
  String get legs => 'Gambe';

  @override
  String get abs => 'Addominali';

  @override
  String get cardio => 'Cardio';

  @override
  String get other => 'Altro';

  @override
  String get personal => 'Personale';

  @override
  String get usages => 'utilizzi';

  @override
  String get muscleDistribution => 'Distribuzione Muscolare';

  @override
  String get core => 'CORE (Addominali/Lombare)';

  @override
  String get chestFull => 'Muscoli del Petto';

  @override
  String get backFull => 'Muscoli della Schiena';

  @override
  String get shouldersFull => 'Muscoli delle Spalle';

  @override
  String get armsFull => 'Muscoli delle Braccia';

  @override
  String get legsFull => 'Muscoli delle Gambe';

  @override
  String get coreFull => 'Muscoli del Core';

  @override
  String get overview => 'Panoramica';

  @override
  String get strength => 'Forza';

  @override
  String get insights => 'Insight';

  @override
  String get muscleBalance => 'Equilibrio Muscolare';

  @override
  String get allExercises => 'Tutti gli Esercizi';

  @override
  String get trainingInsights => 'Insight di Allenamento';

  @override
  String get recommendations => 'Raccomandazioni';

  @override
  String get exerciseTrends => 'Tendenze Esercizi';

  @override
  String get currentStreak => 'Streak attuale';

  @override
  String get totalPRs => 'PR Totali';

  @override
  String get volumeChange => 'Cambio Volume';

  @override
  String get maxWeight => 'Peso Massimo';

  @override
  String get maxReps => 'Ripetizioni Massime';

  @override
  String get estimated1RM => '1RM Stimato';

  @override
  String get volumeProgression => 'Progressione Volume';

  @override
  String get weekly => 'Settimanale';

  @override
  String get weeklyGoalTitle => 'Obiettivo Settimanale';

  @override
  String get weeklyGoalQuestion => 'Quanti allenamenti a settimana vuoi fare?';

  @override
  String get monthly => 'Mensile';

  @override
  String get volumeStatistics => 'Statistiche Volume';

  @override
  String get pleaseLogin => 'Effettua l\'accesso';

  @override
  String get startWorkoutToSeeAnalytics =>
      'Inizia un allenamento per vedere le tue analisi';

  @override
  String get recentWorkouts => 'Allenamenti Recenti';

  @override
  String get highPriority => 'Alta Priorità';

  @override
  String get insight => 'Suggerimento';

  @override
  String get recommendation => 'Raccomandazione';

  @override
  String get expand => 'Espandi';

  @override
  String get collapse => 'Comprimi';

  @override
  String get scientificStrategies => 'Strategie Scientifiche';

  @override
  String get dataPoints => 'Dati Chiave';

  @override
  String get aboutStrengthProgression =>
      'Informazioni sulla Progressione Forza';

  @override
  String get strengthProgressionInfo =>
      'Traccia i tuoi guadagni di forza nel tempo con calcoli 1RM stimati e indicatori di sovraccarico progressivo.';

  @override
  String get backToHome => 'Torna alla Home';

  @override
  String get backToHomeKeepWorkout => 'Torna alla Home (Mantieni Allenamento)';

  @override
  String get backToHomeKeepWorkoutActive =>
      'Torna alla Home (Mantieni Allenamento Attivo)';

  @override
  String get unlockPremiumFeatures => 'Sblocca Funzionalità Premium';

  @override
  String get premiumVolumeFeatures => 'Funzionalità Volume Premium';

  @override
  String get advancedInsights => 'Insight Avanzati';

  @override
  String get recoveryRecommendation => 'Raccomandazione Recupero';

  @override
  String get trainingIntensity => 'Intensità Allenamento';

  @override
  String get noDataForSelectedPeriod =>
      'Nessun dato disponibile per il periodo selezionato';

  @override
  String get previous => 'Precedente';

  @override
  String get tapForDetails => 'Tocca per dettagli';

  @override
  String get compareWithHistory => 'Confronta con storico';

  @override
  String get bestVolume => 'Volume Migliore';

  @override
  String get muscleGroupBalance => 'Equilibrio Gruppi Muscolari';

  @override
  String get overallBalance => 'Equilibrio Generale';

  @override
  String get excellentBalance => 'Eccellente';

  @override
  String get goodBalance => 'Buono';

  @override
  String get moderateBalance => 'Moderato';

  @override
  String get poorBalance => 'Scarso';

  @override
  String get comparePrevious => 'Confronta Precedente';

  @override
  String get currentStrength => 'Forza Attuale';

  @override
  String get strengthCalculationHint =>
      'La forza è calcolata basandosi sulla progressione del volume rispetto al tuo precedente migliore';

  @override
  String get howIsThisCalculated => 'Come viene calcolato?';

  @override
  String get refreshAnimation => 'Aggiorna Animazione';

  @override
  String get editTargets => 'Modifica Obiettivi';

  @override
  String get tapToEditTarget => 'Tocca per modificare obiettivo';

  @override
  String get targetStrength => 'Forza Obiettivo';

  @override
  String get comparedToLastMonth => 'Rispetto al mese scorso';

  @override
  String get recommendedExercises => 'Esercizi Consigliati';

  @override
  String get volumeBreakdown => 'Ripartizione Volume';

  @override
  String strengthExplanation(String volume) {
    return 'Basato su ${volume}kg volume totale';
  }

  @override
  String get howStrengthIsCalculated => 'Come viene calcolata la Forza';

  @override
  String get strengthCalculationExplanation =>
      'La percentuale di forza è calcolata basandosi sul tuo volume di allenamento confrontato con il volume massimo storico per ogni gruppo muscolare.';

  @override
  String get volumeFormula => 'Formula Volume';

  @override
  String get strengthPercentage => 'Percentuale Forza';

  @override
  String get targetExplanation =>
      'Gli obiettivi sono traguardi personalizzabili che ti aiutano a mantenere un allenamento equilibrato su tutti i gruppi muscolari.';

  @override
  String get previousWeightsLoaded => 'Pesi precedenti caricati';

  @override
  String get insightStrengthGainsTitle => 'Guadagni di Forza';

  @override
  String get insightStrengthGainsMessage =>
      'Hai fatto miglioramenti significativi nella forza';

  @override
  String get insightStrengthGainsRecommendation =>
      'Continua con il sovraccarico progressivo per mantenere lo slancio';

  @override
  String get insightPlateauTitle => 'Plateau delle Prestazioni';

  @override
  String get insightPlateauMessage =>
      'Le tue prestazioni hanno raggiunto un plateau di recente';

  @override
  String get insightPlateauRecommendation =>
      'Considera di cambiare la tua routine o fare una settimana di scarico';

  @override
  String get insightVolumeSurgeTitle => 'Aumento del Volume';

  @override
  String get insightVolumeSurgeMessage =>
      'Il tuo volume di allenamento è aumentato significativamente';

  @override
  String get insightVolumeSurgeRecommendation =>
      'Monitora il recupero e aggiusta se necessario';

  @override
  String get insightVolumeDropTitle => 'Calo del Volume';

  @override
  String get insightVolumeDropMessage =>
      'Il tuo volume di allenamento è diminuito';

  @override
  String get insightVolumeDropRecommendation =>
      'Aumenta gradualmente il volume per mantenere i progressi';

  @override
  String get insightVolumePlateauTitle => 'Plateau del Volume';

  @override
  String get insightVolumePlateauMessage => 'Il tuo volume è rimasto stabile';

  @override
  String get insightVolumePlateauRecommendation =>
      'Considera tecniche di sovraccarico progressivo';

  @override
  String get insightLowFrequencyTitle => 'Bassa Frequenza di Allenamento';

  @override
  String get insightLowFrequencyMessage =>
      'Ti sei allenato meno frequentemente';

  @override
  String get insightLowFrequencyRecommendation =>
      'Prova a mantenere un programma di allenamento costante';

  @override
  String get insightHighLoadTitle => 'Carico di Allenamento Alto';

  @override
  String get insightHighLoadMessage => 'Ti sei allenato con alta intensità';

  @override
  String get insightHighLoadRecommendation =>
      'Assicurati di avere riposo e recupero adeguati';

  @override
  String get insightGreatConsistencyTitle => 'Grande Costanza';

  @override
  String get insightGreatConsistencyMessage =>
      'Hai mantenuto un\'eccellente costanza nell\'allenamento';

  @override
  String get insightGreatConsistencyRecommendation => 'Continua così!';

  @override
  String get insightExtendedBreakTitle => 'Pausa Prolungata';

  @override
  String get insightExtendedBreakMessage =>
      'Hai fatto una pausa prolungata dall\'allenamento';

  @override
  String get insightExtendedBreakRecommendation =>
      'Inizia con carichi più leggeri e progredisci gradualmente';

  @override
  String get insightChasePRsTitle => 'Caccia ai PR';

  @override
  String get insightChasePRsMessage =>
      'Sei vicino a stabilire nuovi record personali';

  @override
  String get insightChasePRsRecommendation =>
      'Concentrati sui tuoi esercizi più forti per i tentativi di PR';

  @override
  String get insightPRWeekTitle => 'Settimana dei PR';

  @override
  String get insightPRWeekMessage => 'Hai stabilito più PR questa settimana';

  @override
  String get insightPRWeekRecommendation =>
      'Ottimo lavoro! Considera uno scarico per consolidare i guadagni';

  @override
  String get insightPRDroughtTitle => 'Siccità di PR';

  @override
  String get insightPRDroughtMessage => 'È passato un po\' dal tuo ultimo PR';

  @override
  String get insightPRDroughtRecommendation =>
      'Prova diversi range di ripetizioni o variazioni degli esercizi';

  @override
  String get insightMuscleImbalanceTitle => 'Squilibrio Muscolare';

  @override
  String get insightMuscleImbalanceMessage =>
      'Alcuni gruppi muscolari sono in ritardo';

  @override
  String get insightMuscleImbalanceRecommendation =>
      'Concentrati di più sui gruppi muscolari più deboli';

  @override
  String get insightFocusAdjustmentTitle => 'Aggiustamento del Focus';

  @override
  String get insightFocusAdjustmentMessage =>
      'Il focus del tuo allenamento potrebbe essere meglio bilanciato';

  @override
  String get insightFocusAdjustmentRecommendation =>
      'Aggiusta il tuo programma per un miglior equilibrio';

  @override
  String get insightWellBalancedTitle => 'Ben Bilanciato';

  @override
  String get insightWellBalancedMessage =>
      'Il tuo allenamento è ben bilanciato tra i gruppi muscolari';

  @override
  String get insightWellBalancedRecommendation =>
      'Continua a mantenere questo approccio equilibrato';

  @override
  String get insightOvertrainingTitle => 'Rischio Sovrallenamento';

  @override
  String get insightOvertrainingMessage =>
      'Potresti essere a rischio di sovrallenamento';

  @override
  String get insightOvertrainingRecommendation =>
      'Considera di prendere un giorno di riposo o una settimana di scarico';

  @override
  String get insightRecoveryNoteTitle => 'Nota sul Recupero';

  @override
  String get insightRecoveryNoteMessage =>
      'Le tue metriche di recupero necessitano attenzione';

  @override
  String get insightRecoveryNoteRecommendation =>
      'Concentrati su sonno, nutrizione e gestione dello stress';

  @override
  String get insightStreakTitle => 'Serie di Allenamenti';

  @override
  String get insightStreakMessage =>
      'Sei su una serie impressionante di allenamenti';

  @override
  String get insightStreakRecommendation =>
      'Continua così ascoltando il tuo corpo';

  @override
  String get insightVolumeMilestoneTitle => 'Traguardo del Volume';

  @override
  String get insightVolumeMilestoneMessage =>
      'Hai raggiunto un nuovo traguardo di volume';

  @override
  String get insightVolumeMilestoneRecommendation =>
      'Celebra questo risultato!';

  @override
  String get insightPRMachineTitle => 'Macchina dei PR';

  @override
  String get insightPRMachineMessage => 'Stai stabilendo PR costantemente';

  @override
  String get insightPRMachineRecommendation =>
      'Progressi fantastici! Continua a spingere i tuoi limiti';

  @override
  String get insightConsistencyBonusTitle => 'Bonus Costanza';

  @override
  String get insightConsistencyBonusMessage =>
      'La tua costanza sta dando i suoi frutti';

  @override
  String get insightConsistencyBonusRecommendation =>
      'La costanza è la chiave del successo a lungo termine';

  @override
  String get signInRequired => 'Accesso richiesto';

  @override
  String get signIn => 'Accedi';

  @override
  String get strengthProgression => 'Progressione Forza';

  @override
  String get actualWeight => 'Peso Effettivo';

  @override
  String get trendLine => 'Linea di Tendenza';

  @override
  String get current1RM => '1RM Attuale';

  @override
  String get bestEver => 'Migliore di Sempre';

  @override
  String get noDataForExercise =>
      'Nessun dato disponibile per questo esercizio';

  @override
  String get noDataForChart =>
      'Nessun dato disponibile per le metriche selezionate';

  @override
  String get chartTapToSeeRealValues =>
      'Tocca il grafico per vedere i valori reali';

  @override
  String get multiMetricComparison => 'Confronto Multi-Metrica';

  @override
  String get volumeHeatmap => 'Mappa di Calore del Volume';

  @override
  String get workoutDays => 'Giorni di Allenamento';

  @override
  String get weeksToShow => 'Settimane da Mostrare';

  @override
  String get less => 'Meno';

  @override
  String get more => 'Più';

  @override
  String get exercisesPerformed => 'Esercizi Eseguiti';

  @override
  String get mostSets => 'Più Serie';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get resetZoom => 'Ripristina Zoom';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String workoutWithExercises(Object workoutName, Object exerciseCount) {
    return '$workoutName con $exerciseCount esercizi';
  }

  @override
  String get totalDuration => 'Durata Totale';

  @override
  String get restDay => 'Giorno di Riposo';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi',
      one: '1 esercizio',
      zero: 'Nessun esercizio',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(Object minutes) {
    return '$minutes minuti';
  }

  @override
  String setsCount(int count) {
    return '$count serie';
  }

  @override
  String setLabel(Object number) {
    return 'Serie $number';
  }

  @override
  String get weightLabel => 'Peso (kg)';

  @override
  String get repsLabel => 'rip';

  @override
  String get effortLabel => 'Sforzo';

  @override
  String get importedTemplate => 'Template Importato';

  @override
  String get noExercisesFoundInJSON => 'Nessun esercizio trovato nel JSON';

  @override
  String get exercise => 'esercizio';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get editRoundData => 'Modifica dati round';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get setUpdated => 'Serie aggiornata con successo';

  @override
  String get quickEditWeight => 'Peso';

  @override
  String get quickEditPlates => 'Dischi';

  @override
  String get quickEditPercentage => '%';

  @override
  String get quickEditReps => 'Rip:';

  @override
  String get quickEditRpe => 'RPE:';

  @override
  String get quickEditCancel => 'Annulla';

  @override
  String get quickEditSave => 'Salva';

  @override
  String get quickEditCalculate => 'Calcola';

  @override
  String quickEditCopiedFromSet(int setNumber) {
    return 'Copiato da Serie $setNumber';
  }

  @override
  String get plateCalculatorTitle => 'Calcolatore Dischi';

  @override
  String get plateCalculatorDischi => 'Dischi';

  @override
  String get plateCalculatorAll => 'Tutti';

  @override
  String get plateCalculatorStandard => 'Standard';

  @override
  String get recentWeights => 'Pesi Recenti';

  @override
  String get quickAdjustment => 'Regolazione Veloce';

  @override
  String barbellIncluded(double weight) {
    return 'Bilanciere ${weight}kg incluso';
  }

  @override
  String get noBarbell => 'Nessun bilanciere';

  @override
  String get perSide => 'Per lato:';

  @override
  String get onlyBarbell => 'Solo bilanciere';

  @override
  String get noPlates => 'Nessun disco';

  @override
  String get configureAvailablePlates => 'Configura dischi disponibili';

  @override
  String get selectAvailablePlates =>
      'Seleziona i dischi disponibili nella tua palestra:';

  @override
  String get selectBarbell => 'Seleziona Bilanciere';

  @override
  String get selectBarbellButton => 'Seleziona';

  @override
  String get replace => 'Sostituisci';

  @override
  String get replaceExercise => 'Sostituisci Esercizio';

  @override
  String get deleteExercise => 'Elimina Esercizio';

  @override
  String get deleteExerciseDescription =>
      'Questo rimuoverà permanentemente questo esercizio dal tuo allenamento.';

  @override
  String get deleteSuperset => 'Elimina Superset';

  @override
  String get deleteSupersetDescription =>
      'Questo rimuoverà permanentemente questo superset e tutti i suoi esercizi dal tuo allenamento.';

  @override
  String deleteSetTitle(int setNumber) {
    return 'Eliminare la serie $setNumber?';
  }

  @override
  String get deleteWarmupSetTitle => 'Eliminare la serie di riscaldamento?';

  @override
  String get deleteSetMessage => 'Questa azione non può essere annullata.';

  @override
  String get collapseExercise => 'Comprimi';

  @override
  String get confirmAction => 'Conferma Azione';

  @override
  String get swipeToDeleteExercise => 'Scorri a sinistra per eliminare';

  @override
  String get swipeToEditExercise => 'Scorri a sinistra per modificare';

  @override
  String get swipeToReplaceExercise => 'Scorri a sinistra per sostituire';

  @override
  String get supersetTraining => 'Allenamento Superset';

  @override
  String get supersetDescription =>
      'Superset: Esegui due esercizi consecutivamente senza riposo tra loro.';

  @override
  String get selectedExercises => 'Esercizi Selezionati';

  @override
  String get addAtLeastTwoExercises =>
      'Aggiungi almeno 2 esercizi per creare un superset';

  @override
  String get addRound => 'Aggiungi Round';

  @override
  String get roundsConfiguration => 'Configurazione Round';

  @override
  String get createSuperset => 'Crea Superset';

  @override
  String get round => 'Round';

  @override
  String allExercisesWillBePerformed(int count) {
    return 'Tutti i $count esercizi verranno eseguiti in questo round';
  }

  @override
  String get optional => 'Opzionale';

  @override
  String get restSettings => 'Impostazioni Riposo';

  @override
  String get betweenExercises => 'Tra Esercizi';

  @override
  String get restTimeBetweenExercises =>
      'Tempo di riposo tra ogni esercizio in un round';

  @override
  String get afterRound => 'Dopo Round';

  @override
  String get restTimeAfterRound =>
      'Tempo di riposo dopo aver completato tutti gli esercizi';

  @override
  String get setCompleted => 'Serie completata';

  @override
  String get next => 'Avanti';

  @override
  String get single => 'Singolo';

  @override
  String get superset => 'Superset';

  @override
  String get dropset => 'Drop Set';

  @override
  String get restPause => 'Rest-Pause';

  @override
  String get tapToSelectFromDatabase => 'Tocca per selezionare dal database';

  @override
  String get restBetweenExercises => 'Riposo tra esercizi';

  @override
  String get seconds => 'secondi';

  @override
  String get selectExercisesForSuperset => 'Seleziona esercizi per superset';

  @override
  String get selectExerciseForDropset => 'Seleziona esercizio per dropset';

  @override
  String get selectExerciseForRestPause => 'Seleziona esercizio per rest-pause';

  @override
  String get clearAll => 'Deseleziona Tutto';

  @override
  String get stages => 'Stadi';

  @override
  String get addStage => 'Aggiungi Stadio';

  @override
  String get miniSets => 'mini-set';

  @override
  String get restTime => 'Tempo di Riposo';

  @override
  String supersetProgress(int current, int total) {
    return 'Esercizio $current di $total';
  }

  @override
  String get swipeToNavigate =>
      'Scorri a destra o sinistra per navigare tra gli esercizi';

  @override
  String get currentExercise => 'Esercizio Corrente';

  @override
  String get nextExercise => 'Prossimo Esercizio';

  @override
  String get previousExercise => 'Esercizio Precedente';

  @override
  String get completeAndNext => 'Completa e Prossimo';

  @override
  String get completeAndFinish => 'Completa e Termina';

  @override
  String get rateYourEffort => 'Valuta il tuo sforzo';

  @override
  String get completeSet => 'Completa Serie';

  @override
  String get verifyWeightReps => 'Verifica Peso e Ripetizioni';

  @override
  String get verifyTime => 'Verifica Minuti e Secondi';

  @override
  String get verifyReps => 'Verifica Ripetizioni';

  @override
  String get exerciseHistory => 'Storico Esercizio';

  @override
  String get errorLoadingHistory => 'Errore nel caricamento della cronologia';

  @override
  String get statistics => 'Statistiche';

  @override
  String get avgWeight => 'Peso Medio';

  @override
  String get firstWorkout => 'Primo Allenamento';

  @override
  String get noHistoryFound => 'Nessuno Storico Trovato';

  @override
  String get completeWorkoutsToSeeHistory =>
      'Completa degli allenamenti per vedere lo storico';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get workoutDatabase => 'Database Allenamenti';

  @override
  String get editableWorkoutHistory => 'Storico Allenamenti Modificabile';

  @override
  String get editWorkout => 'Modifica Allenamento';

  @override
  String get deleteWorkout => 'Elimina Allenamento';

  @override
  String workoutDate(int day, int month, int year) {
    return 'Allenamento $day/$month/$year';
  }

  @override
  String get workoutTime => 'Ora Allenamento';

  @override
  String get removeSet => 'Rimuovi Serie';

  @override
  String get saveChanges => 'Salva Modifiche';

  @override
  String get discardChanges => 'Scarta Modifiche';

  @override
  String get confirmDelete => 'Conferma Eliminazione';

  @override
  String get deleteWorkoutConfirmation =>
      'Sei sicuro di voler eliminare questo allenamento? Questa azione non può essere annullata.';

  @override
  String get workoutDeletedSuccessfully => 'Allenamento eliminato con successo';

  @override
  String get workoutUpdatedSuccessfully =>
      'Allenamento aggiornato con successo';

  @override
  String get noWorkoutsInHistory => 'Nessun allenamento nello storico';

  @override
  String get startTrackingWorkouts =>
      'Inizia a tracciare i tuoi allenamenti per vederli qui';

  @override
  String get searchWorkouts => 'Cerca allenamenti...';

  @override
  String get filterByExercise => 'Filtra per esercizio';

  @override
  String get sortByDate => 'Ordina per data';

  @override
  String get sortByDuration => 'Ordina per durata';

  @override
  String get sortByVolume => 'Ordina per volume';

  @override
  String get dataMigration => 'Migrazione Dati';

  @override
  String get dataMigrationDescription =>
      'Migra la cronologia degli allenamenti dal vecchio formato al nuovo sistema per migliori prestazioni e funzionalità.';

  @override
  String get noDataToMigrate => 'Nessun dato da migrare';

  @override
  String get migrationOptions => 'Opzioni Migrazione';

  @override
  String get timeWindowHours => 'Finestra Temporale (ore)';

  @override
  String get createBackup => 'Crea Backup';

  @override
  String get createBackupDescription =>
      'Crea un backup dei tuoi dati prima della migrazione';

  @override
  String get minExercisesPerWorkout => 'Min esercizi per allenamento';

  @override
  String get migrationPreview => 'Anteprima Migrazione';

  @override
  String get migrationResults => 'Risultati Migrazione';

  @override
  String get workoutsFound => 'Allenamenti trovati';

  @override
  String get migratedWorkouts => 'Allenamenti migrati';

  @override
  String get skippedExercises => 'Esercizi saltati';

  @override
  String get errors => 'Errori';

  @override
  String get workoutGroupsPreview => 'Anteprima Gruppi Allenamento';

  @override
  String get analyzing => 'Analisi in corso';

  @override
  String get migrating => 'Migrazione in corso';

  @override
  String get analyzeData => 'Analizza Dati';

  @override
  String get startMigration => 'Avvia Migrazione';

  @override
  String get confirmMigration => 'Conferma Migrazione';

  @override
  String get confirmMigrationDescription =>
      'Sei sicuro di voler avviare la migrazione? Questo processo non può essere annullato.';

  @override
  String get firebaseInitialization => 'Inizializzazione Firebase';

  @override
  String get currentStatus => 'Stato Attuale';

  @override
  String get firebaseStatus => 'Stato Firebase';

  @override
  String get initialized => 'Inizializzato';

  @override
  String get notInitialized => 'Non Inizializzato';

  @override
  String get checking => 'Verifica in corso...';

  @override
  String get checkFailed => 'Verifica Fallita';

  @override
  String get currentVersion => 'Versione Attuale';

  @override
  String get notAvailable => 'Non Disponibile';

  @override
  String loadingError(String error) {
    return 'Errore di caricamento: $error';
  }

  @override
  String get collectionStats => 'Statistiche Collection';

  @override
  String get versionMetadata => 'Metadati Versione';

  @override
  String get present => 'Presente';

  @override
  String get missing => 'Mancante';

  @override
  String get searchIndex => 'Indice Ricerca';

  @override
  String get actions => 'Azioni';

  @override
  String get initializeExercises => 'Inizializza Esercizi';

  @override
  String get verifyIntegrity => 'Verifica Integrità';

  @override
  String get resetStatus => 'Reimposta Stato';

  @override
  String get operationInProgress => 'Operazione in corso...';

  @override
  String get operationSuccess => 'Operazione Riuscita';

  @override
  String get operationError => 'Errore Operazione';

  @override
  String get details => 'Dettagli';

  @override
  String get initializeDescription =>
      'Questo caricherà tutti gli esercizi dal file JSON locale in Firebase. L\'operazione può richiedere diversi minuti.';

  @override
  String get overwriteExisting => 'Sovrascrivi Dati Esistenti';

  @override
  String get overwriteExistingDescription =>
      'Attenzione: Questo eliminerà tutti i dati degli esercizi esistenti in Firebase';

  @override
  String get versionOptional => 'Versione (Opzionale)';

  @override
  String get initialize => 'Inizializza';

  @override
  String get adminDashboard => 'Dashboard Admin';

  @override
  String get analyticsAdmin => 'Dashboard Analytics';

  @override
  String get manageExercises => 'Gestisci Esercizi';

  @override
  String get manageExercisesDescription =>
      'Aggiungi, modifica, rimuovi esercizi';

  @override
  String get reviewCorrections => 'Rivedi Correzioni';

  @override
  String get reviewCorrectionsDescription =>
      'Approva o rifiuta suggerimenti della community';

  @override
  String get userAnalytics => 'Analisi Utenti';

  @override
  String get userAnalyticsDescription =>
      'Visualizza statistiche di utilizzo e tendenze';

  @override
  String get databaseBackup => 'Backup Database';

  @override
  String get databaseBackupDescription =>
      'Esporta e fa il backup dei dati degli esercizi';

  @override
  String get pushNotifications => 'Notifiche Push';

  @override
  String get pushNotificationsDescription =>
      'Invia aggiornamenti a tutti gli utenti';

  @override
  String get featureComingSoon => 'Questa funzionalità sarà presto disponibile';

  @override
  String get loadingActivity => 'Caricamento attività recenti...';

  @override
  String get errorLoadingActivity => 'Errore nel caricamento attività';

  @override
  String get noRecentActivity => 'Nessuna Attività Recente';

  @override
  String get noRecentActivityDescription =>
      'Le correzioni della community e le attività admin appariranno qui.';

  @override
  String get allRecentActivity => 'Tutte le Attività Recenti';

  @override
  String get suggestedCorrection => 'Correzione suggerita';

  @override
  String get approvedCorrection => 'Correzione approvata';

  @override
  String get rejectedCorrection => 'Correzione rifiutata';

  @override
  String get activityFor => 'Attività per';

  @override
  String hoursAgo(int hours) {
    return '${hours}h fa';
  }

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m fa';
  }

  @override
  String get justNow => 'ora';

  @override
  String get viewAll => 'Visualizza Tutto';

  @override
  String get adminInfo => 'Informazioni Admin';

  @override
  String get welcomeAdmin => 'Benvenuto, Admin!';

  @override
  String get adminDashboardDescription =>
      'Gestisci il sistema FitLog Pro e controlla i contributi della community';

  @override
  String get systemStatistics => 'Statistiche Sistema';

  @override
  String get firebaseDatabase => 'Database Firebase';

  @override
  String get communityActivity => 'Attività Community';

  @override
  String get recentActivity => 'Attività Recenti';

  @override
  String get versionControl => 'Controllo Versioni';

  @override
  String get versionControlDescription => 'Gestisci versioni app';

  @override
  String get exerciseCountLabel => 'Numero Esercizi';

  @override
  String get pendingCorrections => 'Correzioni in Sospeso';

  @override
  String get approvedCorrections => 'Correzioni Approvate';

  @override
  String get rejectedCorrections => 'Correzioni Rifiutate';

  @override
  String get totalUsers => 'Utenti Totali';

  @override
  String get loadingStats => 'Caricamento statistiche...';

  @override
  String get errorLoadingStats => 'Errore nel caricamento statistiche';

  @override
  String get version => 'Versione';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get secureAdminAccess => 'Accesso Admin Sicuro';

  @override
  String get systemOverview => 'Panoramica Sistema';

  @override
  String get firebaseManagement => 'Gestione Firebase';

  @override
  String get adminInfoDescription =>
      'Pannello admin per gestione sistema e controllo community';

  @override
  String get exerciseManagement => 'Gestione Esercizi';

  @override
  String get exerciseManagementDescription =>
      'Aggiungi, modifica e organizza database esercizi';

  @override
  String get communityCorrections => 'Correzioni Community';

  @override
  String get communityCorrectionsDescription =>
      'Rivedi e approva correzioni inviate dalla community';

  @override
  String get fixMissingData => 'Correggi Dati Mancanti';

  @override
  String get fixMissingDataDescription =>
      'Identifica e aggiungi esercizi mancanti al database';

  @override
  String get errorLoadingCorrections =>
      'Errore nel caricamento delle correzioni';

  @override
  String get noCorrections => 'Nessuna Correzione';

  @override
  String get noCorrectionsDescription =>
      'Non ci sono correzioni da revisionare al momento';

  @override
  String get reviewedCorrections => 'Correzioni Revisionate';

  @override
  String get approveCorrection => 'Approva Correzione';

  @override
  String get rejectCorrection => 'Rifiuta Correzione';

  @override
  String get confirmApproval =>
      'Sei sicuro di voler approvare questa correzione?';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectionReason => 'Motivo del Rifiuto';

  @override
  String get rejectionReasonHint =>
      'Spiega perché questa correzione viene rifiutata';

  @override
  String get suggestedBy => 'Suggerito da';

  @override
  String get correctionType => 'Tipo di Correzione';

  @override
  String get currentValue => 'Valore attuale';

  @override
  String get proposedValue => 'Valore Proposto';

  @override
  String get submittedAt => 'Inviata';

  @override
  String get reviewedBy => 'Revisionata da';

  @override
  String get exerciseImage => 'Immagine Esercizio';

  @override
  String get muscleFocus => 'Focus Muscolare';

  @override
  String get correction => 'Correzione';

  @override
  String get tip => 'Suggerimento';

  @override
  String get warning => 'Attenzione';

  @override
  String get variant => 'Variante';

  @override
  String get translation => 'Traduzione';

  @override
  String get technique => 'Tecnica';

  @override
  String get pending => 'In Attesa';

  @override
  String get approved => 'Approvato';

  @override
  String get rejected => 'Rifiutato';

  @override
  String get fix => 'Correggi';

  @override
  String get description => 'Descrizione';

  @override
  String get status => 'Stato';

  @override
  String get databaseManager => 'Gestione Database';

  @override
  String get publishNewVersion => 'Pubblica Nuova Versione';

  @override
  String get lastPublished => 'Ultima Pubblicazione';

  @override
  String get totalExercisesInDb => 'Esercizi Totali nel Database';

  @override
  String get versionHistory => 'Cronologia Versioni';

  @override
  String get publishVersion => 'Pubblica Versione';

  @override
  String get versionNumber => 'Numero Versione';

  @override
  String get changelog => 'Changelog';

  @override
  String get changelogHint =>
      'Descrivi cosa è cambiato in questa versione (es. \'Aggiunti 15 nuovi esercizi per spalle\')';

  @override
  String get publishing => 'Pubblicazione in corso...';

  @override
  String versionPublished(String version) {
    return 'Versione $version pubblicata con successo! Tutti gli utenti riceveranno l\'aggiornamento entro 6 ore.';
  }

  @override
  String publishFailed(String error) {
    return 'Errore nella pubblicazione della versione: $error';
  }

  @override
  String get forceUpdate => 'Aggiornamento Obbligatorio';

  @override
  String get forceUpdateDesc =>
      'Se abilitato, gli utenti devono aggiornare per continuare a usare l\'app';

  @override
  String get multiSelectMode => 'Modalità Multi-Selezione';

  @override
  String get exportAllJson => 'Esporta Tutto in JSON';

  @override
  String get exportSelectedJson => 'Esporta Selezionati in JSON';

  @override
  String get importJson => 'Importa da JSON';

  @override
  String get bodyweight => 'Corpo Libero';

  @override
  String get uniqueMuscles => 'Muscoli';

  @override
  String get clearFilters => 'Cancella Filtri';

  @override
  String get bulkEdit => 'Modifica Multipla';

  @override
  String get exercisesExport => 'Esportazione Esercizi';

  @override
  String get exportSuccess => 'Esportazione completata con successo';

  @override
  String get importJsonDescription => 'Importa esercizi da file JSON';

  @override
  String get importWarning => 'Questo sovrascriverà gli esercizi esistenti!';

  @override
  String get selectFile => 'Seleziona File';

  @override
  String get selectField => 'Seleziona Campo';

  @override
  String get newValue => 'Nuovo valore';

  @override
  String get apply => 'Applica';

  @override
  String confirmDeleteMultiple(int count) {
    return 'Eliminare $count esercizi?';
  }

  @override
  String get exerciseNameRequired => 'Il nome dell\'esercizio è obbligatorio';

  @override
  String get updateExercise => 'Aggiorna Esercizio';

  @override
  String get createExercise => 'Crea Esercizio';

  @override
  String get exerciseUpdateAvailable => 'Aggiornamento Esercizi Disponibile';

  @override
  String get exerciseUpdateDescription =>
      'È disponibile una nuova versione del database degli esercizi con esercizi migliorati e nuove funzionalità.';

  @override
  String get downloadNow => 'Scarica Ora';

  @override
  String get downloading => 'Scaricando...';

  @override
  String get exerciseUpdateNote =>
      'Questo scaricherà i dati degli esercizi più recenti e migliorerà la tua esperienza di allenamento.';

  @override
  String get tempoEsecuzione => 'Tempo Sotto Tensione';

  @override
  String get tempoNote => 'Nota Tempo di Esecuzione';

  @override
  String get imagePreview => 'Anteprima Immagine';

  @override
  String get changeImage => 'Cambia Immagine';

  @override
  String get expandDetails => 'Espandi Dettagli';

  @override
  String get clearFilter => 'Cancella';

  @override
  String get timeUnderTensionExplanation =>
      'Il Tempo Sotto Tensione (TUT) è la quantità totale di tempo in cui un muscolo è sotto sforzo durante una serie. È un fattore chiave per la crescita muscolare e la forza.';

  @override
  String get tutBasicExplanation =>
      'Il TUT è la durata in cui i tuoi muscoli lavorano durante una serie di esercizi. Un TUT più lungo può portare a una maggiore crescita muscolare.';

  @override
  String get tutFormatTitle => 'Formato TUT: X-Y-Z-W';

  @override
  String get tutFormatExplanation =>
      'Il formato TUT X-Y-Z-W rappresenta la durata in secondi per ogni fase di un esercizio: X (eccentrica/abbassamento), Y (pausa in basso), Z (concentrica/sollevamento), W (pausa in alto).';

  @override
  String get warmupTipLight =>
      'Riscaldamento leggero: Concentrati su stretching dinamico e cardio leggero per far fluire il sangue.';

  @override
  String get warmupTipModerate =>
      'Riscaldamento moderato: Includi alcune serie leggere del tuo esercizio principale per preparare i muscoli.';

  @override
  String get warmupTipHeavy =>
      'Riscaldamento pesante: Aumenta gradualmente il peso con diverse serie, assicurando forma corretta e attivazione muscolare.';

  @override
  String get warmupTipMax =>
      'Riscaldamento massimo sforzo: Esegui alcune serie molto leggere, poi passa direttamente alle tue serie di lavoro con riposo minimo.';

  @override
  String get shareAdviceWithCommunity => 'Condividi un consiglio';

  @override
  String get communityAdvice => 'Consigli dalla Community';

  @override
  String get communityContributions => 'Contributi Community';

  @override
  String get reviewContributionsDescription =>
      'Gestisci i contributi della community';

  @override
  String peopleFoundHelpful(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'persone',
      one: 'persona',
      zero: 'persone',
    );
    return '$count $_temp0 hanno trovato utile questo consiglio';
  }

  @override
  String get noAdviceAvailable =>
      'Nessun consiglio disponibile per questo esercizio';

  @override
  String get beFirstToShare => 'Sii il primo a condividere i tuoi consigli!';

  @override
  String get contributionSubmittedSuccess =>
      '✅ Contributo inviato! In attesa di approvazione';

  @override
  String get thankYouForContributing => 'Grazie per aver aiutato la community!';

  @override
  String get startWorkoutWithTemplate =>
      'Inizia allenamento con questo template';

  @override
  String get editTemplate => 'Modifica Template';

  @override
  String get editTemplateSubtitle => 'Modifica esercizi e serie';

  @override
  String get sharePdf => 'Condividi PDF';

  @override
  String get sharePdfSubtitle => 'Esporta come PDF e condividi';

  @override
  String get print => 'Stampa';

  @override
  String get printTemplate => 'Stampa template allenamento';

  @override
  String get pdfExportOptions => 'Opzioni Esportazione PDF';

  @override
  String get pdfDetailLevelCompact => 'Formato Compatto';

  @override
  String get pdfDetailLevelCompactDesc => 'Raggruppa set identici (es. 3 x 10)';

  @override
  String get pdfDetailLevelDetailed => 'Dettagliato con Peso';

  @override
  String get pdfDetailLevelDetailedDesc =>
      'Mostra ogni set con peso (es. Set 1: 20kg x 10)';

  @override
  String get pdfDetailLevelNoWeight => 'Dettagliato senza Peso';

  @override
  String get pdfDetailLevelNoWeightDesc =>
      'Mostra ogni set solo con reps (es. Set 1: 10 reps)';

  @override
  String get rememberMyChoice => 'Ricorda la mia scelta';

  @override
  String get deleteTemplateSubtitle => 'Rimuovi definitivamente';

  @override
  String workoutStartError(String error) {
    return 'Errore nell\'avvio: $error';
  }

  @override
  String get restComplete => 'Riposo Completato';

  @override
  String get workoutComplete => 'Allenamento Completato';

  @override
  String get warmupComplete => 'Riscaldamento Completato';

  @override
  String get cooldownComplete => 'Defaticamento Completato';

  @override
  String get timerFinished => 'Il tuo timer è terminato';

  @override
  String setComplete(String exercise, int currentSet, int totalSets) {
    return '$exercise - Serie $currentSet/$totalSets completata';
  }

  @override
  String exerciseComplete(String exercise) {
    return '$exercise completato';
  }

  @override
  String get workoutSaved => 'Allenamento salvato!';

  @override
  String get errorSavingWorkout => 'Errore nel salvataggio';

  @override
  String get effortLevel => 'Sforzo';

  @override
  String get unsavedChanges => 'Modifiche Non Salvate';

  @override
  String get unsavedChangesMessage =>
      'Hai modifiche non salvate. Sei sicuro di volerle scartare?';

  @override
  String get enterWorkoutName => 'Inserisci nome workout';

  @override
  String get replacementKeepsSetsAndReps =>
      'La sostituzione mantiene serie e ripetizioni';

  @override
  String get smartSuggestions => 'Suggerimenti Intelligenti';

  @override
  String get errorLoadingExercises => 'Errore nel caricamento esercizi';

  @override
  String get confirmReplacement => 'Conferma Sostituzione';

  @override
  String replaceExerciseConfirmation(String oldExercise, String newExercise) {
    return 'Sostituire $oldExercise con $newExercise?';
  }

  @override
  String get exerciseReplaced => 'Esercizio sostituito con successo';

  @override
  String get excellentReplacement => 'Sostituzione eccellente';

  @override
  String get highlyCompatible => 'Altamente compatibile';

  @override
  String get goodAlternative => 'Buona alternativa';

  @override
  String get possibleAlternative => 'Possibile alternativa';

  @override
  String get differentMuscleGroup => 'Gruppo muscolare diverso';

  @override
  String get browseExerciseDatabase => 'Sfoglia Database Esercizi';

  @override
  String get chooseFromLibrary => 'Scegli dalla nostra libreria di esercizi';

  @override
  String get cantFindExercise =>
      'Non trovi l\'esercizio? Creane uno personalizzato';

  @override
  String get enterCustomExerciseDetails =>
      'Inserisci i dettagli dell\'esercizio personalizzato qui sotto:';

  @override
  String get singleTab => 'Singolo';

  @override
  String get advancedTab => 'Avanzati';

  @override
  String get notesOptional => 'Note (opzionale)';

  @override
  String get addNotesAboutForm =>
      'Aggiungi note sulla forma, progressione peso, ecc.';

  @override
  String get exerciseNameLabel => 'Nome Esercizio';

  @override
  String get exerciseNameExample => 'es. Panca Piana';

  @override
  String addedToWorkout(String exerciseName) {
    return 'Aggiunto $exerciseName all\'allenamento';
  }

  @override
  String get apreProtocol => 'Protocollo APRE';

  @override
  String get apreAdjustment => 'Regolazione APRE';

  @override
  String apreSetWeight(int setNumber) {
    return 'Peso Serie $setNumber:';
  }

  @override
  String apreCompletedReps(int actual, int target) {
    return 'Hai completato $actual reps (target: $target)';
  }

  @override
  String get apreApply => 'Applica';

  @override
  String apreWeightAdjusted(int setNumber, String weight) {
    return 'APRE: Peso serie $setNumber regolato a $weight kg';
  }

  @override
  String get apreAutoregulation => 'Autoregolazione APRE';

  @override
  String get apreAutoregulationDescription =>
      'Regolazione automatica del peso basata sulla performance';

  @override
  String get apreProtocolSelect => 'Seleziona Protocollo APRE';

  @override
  String get apreProtocol3Description =>
      'Protocollo forza pesante (target 3 reps)';

  @override
  String get apreProtocol6Description =>
      'Protocollo forza e ipertrofia (target 6 reps)';

  @override
  String get apreProtocol10Description =>
      'Protocollo ipertrofia e resistenza (target 10 reps)';

  @override
  String get apreBaseWeight => 'Peso Base APRE';

  @override
  String get apreBaseWeightHint => 'Inserisci il tuo peso per 3RM, 6RM o 10RM';

  @override
  String get apreProtocol3Helper => 'Usa il tuo massimale per 3 ripetizioni';

  @override
  String get apreProtocol6Helper => 'Usa il tuo massimale per 6 ripetizioni';

  @override
  String get apreProtocol10Helper => 'Usa il tuo massimale per 10 ripetizioni';

  @override
  String get apreProtocolPreview => 'Anteprima Cambio Protocollo';

  @override
  String get aprePreviewDescription =>
      'Vedi come cambieranno i tuoi pesi con il nuovo protocollo';

  @override
  String apreCurrentProtocol(int protocol) {
    return 'Attuale (APRE $protocol)';
  }

  @override
  String apreNewProtocol(int protocol) {
    return 'Nuovo (APRE $protocol)';
  }

  @override
  String get apreSet1Preview => 'Serie 1 (50%)';

  @override
  String get apreSet2Preview => 'Serie 2 (75%)';

  @override
  String get apreSet3Preview => 'Serie 3 (100%)';

  @override
  String get apreSet4Preview => 'Serie 4';

  @override
  String get apreAdjustedBasedOnPerformance =>
      'Adattato in base alla performance';

  @override
  String get apreApplyChanges => 'Applica Modifiche';

  @override
  String get autoAdjustment => 'Regolazione Automatica';

  @override
  String get autoAdjustmentDescription =>
      'Regolazione automatica del peso basata sulla tua performance';

  @override
  String get selectAutoAdjustmentType => 'Seleziona Tipo di Regolazione';

  @override
  String get rpeBasedAdjustment => 'Basato su RPE/RIR';

  @override
  String get rpeBasedDescription =>
      'Regola il peso in base alla tua percezione dello sforzo';

  @override
  String get rpeTargetRange => 'Range RPE Target';

  @override
  String get rpeTargetRangeHint => 'es. 7-9 RPE';

  @override
  String get adjustmentPercentage => '% Regolazione';

  @override
  String increaseWeightBy(String percent) {
    return 'Aumenta del $percent%';
  }

  @override
  String decreaseWeightBy(String percent) {
    return 'Diminuisci del $percent%';
  }

  @override
  String get maintainWeight => 'Mantieni il peso attuale';

  @override
  String get rpeAutoregulation => 'Autoregolazione RPE';

  @override
  String get actualRpe => 'RPE Effettivo';

  @override
  String targetRange(Object range) {
    return 'Target: $range';
  }

  @override
  String get actualRir => 'RIR Effettivo';

  @override
  String get targetRir => 'RIR Obiettivo';

  @override
  String get suggestedWeight => 'Peso Suggerito';

  @override
  String get nextSetWeight => 'Peso Prossima Serie';

  @override
  String get weightAdjustedTo => 'Peso regolato a';

  @override
  String get templateOnboardingNameTitle =>
      'Qui inserisci il nome della scheda';

  @override
  String get templateOnboardingDescriptionTitle =>
      'Questa è una descrizione di cosa comprende la scheda';

  @override
  String get templateOnboardingDescriptionSubtitle =>
      'Opzionale - ti aiuta a ricordare di cosa tratta questa scheda';

  @override
  String get templateOnboardingTagsTitle =>
      'Tag per il riconoscimento nella community';

  @override
  String get templateOnboardingTagsSubtitle =>
      'Seleziona i tag che descrivono il tuo template per aiutare gli altri a trovarlo nella community';

  @override
  String get templateOnboardingRestTimerTitle =>
      'Timer di recupero di default per tutti gli esercizi';

  @override
  String get templateOnboardingRestTimerSubtitle =>
      'Quando aggiungi un nuovo esercizio senza impostare manualmente il timer, verrà applicato questo timer di default';

  @override
  String get templateOnboardingNext => 'Avanti';

  @override
  String get templateOnboardingSkip => 'Salta Tutorial';

  @override
  String get templateOnboardingGotIt => 'Ho capito!';

  @override
  String get exerciseOnboardingSingleTabTitle =>
      'Inizia aggiungendo un singolo esercizio';

  @override
  String get exerciseOnboardingSingleTabSubtitle =>
      'Questa scheda ti permette di aggiungere un esercizio alla volta. Puoi anche aggiungere superset, dropset o rest-pause dalle altre schede';

  @override
  String get exerciseOnboardingSelectButtonTitle =>
      'Tocca qui per sfogliare gli esercizi';

  @override
  String get exerciseOnboardingSelectButtonSubtitle =>
      'Apri il database degli esercizi per scegliere tra centinaia di esercizi';

  @override
  String get exerciseOnboardingSearchTitle => 'Cerca gli esercizi';

  @override
  String get exerciseOnboardingSearchSubtitle =>
      'Digita il nome dell\'esercizio che stai cercando, come \"panca piana\" o \"squat\"';

  @override
  String get exerciseOnboardingExerciseItemTitle => 'Seleziona un esercizio';

  @override
  String get exerciseOnboardingExerciseItemSubtitle =>
      'Tocca per aggiungerlo al tuo allenamento. Tieni premuto per vedere informazioni dettagliate e consigli di esecuzione';

  @override
  String get exerciseOnboardingFiltersTitle =>
      'Filtra per categoria o gruppo muscolare';

  @override
  String get exerciseOnboardingFiltersSubtitle =>
      'Usa i filtri per trovare rapidamente esercizi per parti del corpo specifiche';

  @override
  String get exerciseOnboardingConfirmTitle =>
      'Conferma per aggiungere l\'esercizio';

  @override
  String get exerciseOnboardingConfirmSubtitle =>
      'Una volta selezionati gli esercizi, tocca qui per aggiungerli al tuo allenamento';

  @override
  String get exerciseOnboardingNext => 'Avanti';

  @override
  String get exerciseOnboardingSkip => 'Salta Tutorial';

  @override
  String get exerciseOnboardingGotIt => 'Ho capito!';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingDesc =>
      'Mostra nuovamente le guide per template ed esercizi';

  @override
  String get resetOnboardingConfirm =>
      'Questo resetterà tutti i tutorial di onboarding. Verranno mostrati nuovamente la prossima volta che crei un template o aggiungi un esercizio.';

  @override
  String get onboardingResetSuccess =>
      'Tutorial di onboarding ripristinati con successo';

  @override
  String get templateDescriptionOptional => 'Descrizione (opzionale)';

  @override
  String get templateNameLabel => 'Nome Template *';

  @override
  String get templateNameRequired => 'Il nome è obbligatorio';

  @override
  String get templateDescriptionHint => 'Breve descrizione del workout...';

  @override
  String get tags => 'Tag';

  @override
  String get selectTagsDescription =>
      'Seleziona i tag che descrivono il tuo template';

  @override
  String get defaultRestTimer => 'Timer di Recupero Default';

  @override
  String get defaultRestTimerDescription =>
      'Imposta un timer di default che verrà applicato a tutti gli esercizi del template';

  @override
  String get warmupProtocol => 'Protocollo Riscaldamento';

  @override
  String get warmupPhaseInfo => 'Comprendere le Fasi del Riscaldamento';

  @override
  String get warmupPhase1Title => 'Mobilità';

  @override
  String get warmupPhase1Desc =>
      'Prepara articolazioni e ampiezza di movimento con stretching dinamico. Esempi: cerchi anche, oscillazioni braccia, leg swings.';

  @override
  String get warmupPhase2Title => 'Attivazione';

  @override
  String get warmupPhase2Desc =>
      'Attiva muscoli target e stabilizzatori con contrazioni leggere. Esempi: glute bridge, lavoro con elastici, serie leggere.';

  @override
  String get warmupPhase3Title => 'Riscaldamento Specifico';

  @override
  String get warmupPhase3Desc =>
      'Progressione graduale verso il peso di lavoro con l\'esercizio reale. Esempi: Bilanciere×10, 40%×8, 60%×5, 80%×3.';

  @override
  String get warmupSetsLabel => 'Serie di Riscaldamento';

  @override
  String get warmupTimeLabel => 'Tempo Riscaldamento';

  @override
  String get warmupInfoDialogTitle => 'Protocollo Riscaldamento Completo';

  @override
  String get warmupWhyImportant =>
      'Perché è importante un riscaldamento adeguato?';

  @override
  String get warmupWhyImportantAnswer =>
      'Un riscaldamento adeguato riduce il rischio di infortuni, migliora le prestazioni, prepara il sistema nervoso e ottimizza la qualità dell\'allenamento.';

  @override
  String get customizeWorkout => 'Personalizza Workout';

  @override
  String get customizeWorkoutSubtitle => 'Attiva o disattiva le funzionalità';

  @override
  String get displayMode => 'Modalità Visualizzazione';

  @override
  String get displayModeDescription =>
      'Scegli il livello di dettaglio delle metriche';

  @override
  String get baseMode => '🌱 Base';

  @override
  String get proMode => '🚀 Pro';

  @override
  String get baseModeActivated => 'Modalità Base attivata';

  @override
  String get proModeActivated => 'Modalità Pro attivata';

  @override
  String get coreFeaturesSection => '🏋️ Funzionalità Base';

  @override
  String get autoRestTimerTitle => 'Timer Riposo Automatico';

  @override
  String get autoRestTimerDescription =>
      'Avvia automaticamente il timer dopo ogni serie';

  @override
  String get autoRestTimerTooltip =>
      'Quando attivo, il timer di riposo si avvia automaticamente al completamento di una serie, aiutandoti a mantenere intervalli di recupero consistenti.';

  @override
  String get warmupSuggestionsTitle => 'Suggerimenti Riscaldamento';

  @override
  String get warmupSuggestionsDescription =>
      'Calcola automaticamente i set di warmup';

  @override
  String get warmupSuggestionsTooltip =>
      'Il sistema suggerirà serie di riscaldamento progressive basate sul tuo carico di lavoro, preparando muscoli e sistema nervoso.';

  @override
  String get autoCollapseTitle => 'Auto-Collapse Completati';

  @override
  String get autoCollapseDescription =>
      'Collassa automaticamente gli esercizi completati';

  @override
  String get autoCollapseTooltip =>
      'Gli esercizi completati verranno minimizzati automaticamente per mantenere la schermata pulita e focalizzata sugli esercizi attivi.';

  @override
  String get intelligentAutoRegulation => '⚡ Auto-Regolazione Intelligente';

  @override
  String get apreSystemTitle => '📈 Sistema APRE';

  @override
  String get apreSystemSubtitle => 'Auto-Regolazione Basata su Ripetizioni';

  @override
  String get enableApreTitle => 'Abilita APRE';

  @override
  String get enableApreDescription =>
      'Calcolo automatico pesi da storico per nuovi esercizi';

  @override
  String get enableApreTooltip =>
      'APRE analizza lo storico degli allenamenti per calcolare il tuo 1RM e suggerire automaticamente i pesi appropriati per ogni protocollo (3, 6 o 10 ripetizioni).';

  @override
  String get apreProtocolTitle => 'Protocollo APRE';

  @override
  String get apre3 => 'APRE 3';

  @override
  String get apre6 => 'APRE 6';

  @override
  String get apre10 => 'APRE 10';

  @override
  String get apre3Description =>
      'Ideale per forza massima (3+ reps fino al cedimento)';

  @override
  String get apre6Description => 'Bilanciato per forza e ipertrofia (6+ reps)';

  @override
  String get apre10Description =>
      'Perfetto per ipertrofia e resistenza (10+ reps)';

  @override
  String get autoAdjustRestApreTitle => 'Auto-Regola Recupero';

  @override
  String get autoAdjustRestApreDescription =>
      'Aumenta recupero se cali il carico';

  @override
  String get autoAdjustRestApreTooltip =>
      'Quando il peso sollevato diminuisce, il sistema aumenta automaticamente il tempo di recupero per aiutarti a gestire la fatica.';

  @override
  String get rpeSystemTitle => '💪 Sistema RPE/RIR';

  @override
  String get rpeSystemSubtitle => 'Auto-Regolazione Basata su Sforzo';

  @override
  String get enableRpeTitle => 'Abilita Monitoraggio RPE';

  @override
  String get enableRpeDescription =>
      'Richiedi lo sforzo percepito dopo ogni serie';

  @override
  String get enableRpeTooltip =>
      'RPE (Rate of Perceived Exertion) ti aiuta a tracciare quanto è impegnativa ogni serie, permettendo un\'auto-regolazione intelligente basata sul tuo livello di affaticamento.';

  @override
  String get attentionRequired => 'Attenzione';

  @override
  String get enable => 'Abilita';

  @override
  String get essentialsSection => 'Essenziali';

  @override
  String get essentialsSectionDesc => 'Impostazioni fondamentali per iniziare';

  @override
  String get advancedSection => 'Avanzate';

  @override
  String get advancedSectionDesc => 'Personalizzazioni per utenti esperti';

  @override
  String get visualizationCategory => 'Visualizzazione';

  @override
  String get autoRegulationCategory => 'Auto-regolazione';

  @override
  String get interfaceCategory => 'Interfaccia';

  @override
  String get enableTutTitle => 'Abilita Monitoraggio TUT';

  @override
  String get enableTutDescription =>
      'Traccia il Tempo Sotto Tensione per ogni serie';

  @override
  String get enableTutTooltip =>
      'TUT (Tempo Sotto Tensione) misura quanto dura ogni serie, aiutandoti a ottimizzare la crescita muscolare tracciando velocità di esecuzione e tempi di riposo.';

  @override
  String get setDurationTrackingTitle => 'Traccia Durata Serie (TUT)';

  @override
  String get setDurationTrackingDescription =>
      'Misura il Time Under Tension per ogni serie';

  @override
  String get setDurationTrackingTooltip =>
      'Traccia automaticamente quanto tempo dura ogni serie dall\'inizio al completamento, escludendo il tempo di riposo. Questo aiuta ad analizzare la velocità di esecuzione e ottimizzare la crescita muscolare.';

  @override
  String get startTrackingDuration => 'Inizia tracciamento durata';

  @override
  String get getReady => 'Preparati...';

  @override
  String get goStartYourSet => 'VIA! Inizia la serie';

  @override
  String get autoAdjustWeightRpeTitle => 'Auto-Regola Peso';

  @override
  String get autoAdjustWeightRpeDescription =>
      'Regola il peso in base al feedback RPE';

  @override
  String get autoAdjustWeightRpeTooltip =>
      'RPE 9-10: suggerisce -2.5kg/-5%. RPE ≤6: suggerisce +2.5kg/+5%. Ti aiuta a trovare il carico ottimale per il tuo stato attuale.';

  @override
  String get autoAdjustRestRpeTitle => 'Auto-Regola Tempo Riposo';

  @override
  String get autoAdjustRestRpeDescription =>
      'Regola il riposo in base al livello di sforzo';

  @override
  String get autoAdjustRestRpeTooltip =>
      'RPE 8-10: +30s di riposo. RPE ≤6: -15s di riposo. Adatta automaticamente il tempo di recupero al tuo livello di affaticamento.';

  @override
  String get informationInsightsSection => '📊 Informazioni & Statistiche';

  @override
  String get exerciseDetailsTitle => 'Dettagli Esercizio';

  @override
  String get exerciseDetailsDescription =>
      'Mostra note e statistiche dettagliate';

  @override
  String get exerciseDetailsTooltip =>
      'Visualizza informazioni complete sull\'esercizio incluse note personali, statistiche di progresso e insights sulle performance.';

  @override
  String get communitySuggestionsTitle => 'Suggerimenti Community';

  @override
  String get communitySuggestionsDescription =>
      'Mostra consigli dalla community';

  @override
  String get communitySuggestionsTooltip =>
      'Ricevi consigli utili e suggerimenti da altri atleti esperti per ogni esercizio.';

  @override
  String get tutInfoTitle => 'Informazioni TUT';

  @override
  String get tutInfoDescription => 'Visualizza info Time Under Tension';

  @override
  String get tutInfoTooltip =>
      'Mostra il tempo (es. 3-1-2-0) per controllare la velocità dell\'esercizio e massimizzare l\'impegno muscolare.';

  @override
  String get quickAccessSection => '🎯 Accesso Rapido';

  @override
  String get quickAccessIconsTitle => 'Icone Accesso Rapido';

  @override
  String get quickAccessIconsDescription =>
      'Mostra icone info, riscaldamento e prevenzione';

  @override
  String get quickAccessIconsTooltip =>
      'Abilita pulsanti di accesso rapido negli header degli esercizi per accesso istantaneo a informazioni, suggerimenti riscaldamento e consigli prevenzione infortuni.';

  @override
  String get interfaceSection => '⚙️ Interfaccia & Performance';

  @override
  String get advancedMenuTitle => 'Menu Opzioni Avanzate';

  @override
  String get advancedMenuDescription =>
      'Mostra opzioni avanzate nel menu esercizi';

  @override
  String get advancedMenuTooltip =>
      'Visualizza opzioni avanzate aggiuntive come sostituzione esercizi, varianti tecniche e impostazioni dettagliate.';

  @override
  String get customTimersTitle => 'Timer Personalizzati';

  @override
  String get customTimersDescription =>
      'Mostra impostazioni timer custom per esercizio';

  @override
  String get customTimersTooltip =>
      'Imposta tempi di riposo specifici per singoli esercizi, perfetto per diverse intensità di allenamento.';

  @override
  String get collapseCountdownTitle => 'Animazione Countdown Collapse';

  @override
  String get collapseCountdownDescription =>
      'Mostra il conto alla rovescia prima del collasso';

  @override
  String get collapseCountdownTooltip =>
      'Visualizza un conto alla rovescia visivo prima che gli esercizi si collassino automaticamente, dandoti tempo per rivedere.';

  @override
  String get simplifiedAnimationsTitle => 'Animazioni Semplificate';

  @override
  String get simplifiedAnimationsDescription =>
      'Usa animazioni più semplici e veloci';

  @override
  String get simplifiedAnimationsTooltip =>
      'Riduci la complessità delle animazioni per migliori performance su dispositivi meno recenti o se preferisci un\'interfaccia più scattante.';

  @override
  String get settingsAutoSaved =>
      'Le impostazioni vengono salvate automaticamente e applicate a tutti i workout futuri';

  @override
  String replaceExerciseReason(String exercise, String reason) {
    return 'Sostituisci $exercise ($reason)';
  }

  @override
  String get plateauDetected => 'Plateau Rilevato';

  @override
  String get formRisk => 'Rischio Forma';

  @override
  String get selectReplacement => 'Seleziona Esercizio Sostitutivo';

  @override
  String get similarExercises => 'Esercizi Simili';

  @override
  String get selectTemplates => 'Seleziona Schede da Aggiornare';

  @override
  String applyToTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schede',
      one: '1 scheda',
    );
    return 'Applica a $_temp0';
  }

  @override
  String exerciseReplacedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schede',
      one: '1 scheda',
    );
    return 'Esercizio sostituito con successo in $_temp0';
  }

  @override
  String get noSimilarExercises => 'Nessun esercizio simile trovato';

  @override
  String get selectAtLeastOneTemplate => 'Seleziona almeno una scheda';

  @override
  String get weightHandling => 'Gestione Peso';

  @override
  String get keepCurrentWeight => 'Mantieni peso attuale';

  @override
  String get resetWeight => 'Reset peso (ricomincia da zero)';

  @override
  String get setManually => 'Imposta manualmente dopo';

  @override
  String get volumeDistribution => 'Distribuzione Volume';

  @override
  String get scientificRatios => 'Rapporti Scientifici';

  @override
  String get noMuscleGroupData =>
      'Nessun dato sui gruppi muscolari disponibile';

  @override
  String get muscleBalanceScience => 'Scienza del Bilanciamento Muscolare';

  @override
  String get muscleBalanceExplanation =>
      'L\'analisi del bilanciamento muscolare mostra la distribuzione del volume e rapporti scientificamente validati per prevenire infortuni e ottimizzare le prestazioni.';

  @override
  String get insightProgressiveOverloadRegressionTitle =>
      'Regressione Volume Rilevata';

  @override
  String insightProgressiveOverloadRegressionMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return 'Volume diminuito del $overloadPercent% su $exerciseName';
  }

  @override
  String get insightProgressiveOverloadRegressionRec =>
      'Verifica stato di recupero e stress allenante. Riferimento: Kraemer & Ratamess (2004)';

  @override
  String get insightProgressiveOverloadExcessiveTitle =>
      'Aumento Volume Eccessivo';

  @override
  String insightProgressiveOverloadExcessiveMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return '$exerciseName volume aumentato del $overloadPercent%';
  }

  @override
  String get insightProgressiveOverloadExcessiveRec =>
      'ALTO rischio di sovrallenamento/infortunio. Considera di ridurre il volume. Riferimento: ACSM (2009)';

  @override
  String get insightProgressiveOverloadOptimalTitle =>
      'Sovraccarico Progressivo Ottimale';

  @override
  String insightProgressiveOverloadOptimalMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return '$exerciseName: +$overloadPercent% aumento volume';
  }

  @override
  String get insightProgressiveOverloadOptimalRec =>
      'Perfetto tasso di progressione sostenibile! Riferimento: Kraemer & Ratamess (2004)';

  @override
  String get insightVolumeLowTitle => 'Volume Sotto Ottimale';

  @override
  String insightVolumeLowMessage(
    String muscleGroup,
    String currentSets,
    String targetMin,
  ) {
    return '$muscleGroup: $currentSets serie/settimana (obiettivo: $targetMin+)';
  }

  @override
  String get insightVolumeLowRec =>
      'Considera di aggiungere serie per ipertrofia ottimale. Riferimento: Schoenfeld et al. (2017)';

  @override
  String get insightVolumeExcessiveTitle => 'Volume Settimanale Eccessivo';

  @override
  String insightVolumeExcessiveMessage(
    String muscleGroup,
    String currentSets,
    String maxRecommended,
  ) {
    return '$muscleGroup: $currentSets serie/settimana (max consigliato: $maxRecommended)';
  }

  @override
  String get insightVolumeExcessiveRec =>
      'Rischio di sovrallenamento. Considera settimana di scarico. Riferimento: Schoenfeld et al. (2017)';

  @override
  String get insightIntensityLowTitle => 'Intensità Allenamento Bassa';

  @override
  String insightIntensityLowMessage(
    String exerciseName,
    String percentOf1RM,
    String weight,
    String reps,
  ) {
    return '$exerciseName: $percentOf1RM% 1RM (${weight}kg × $reps reps)';
  }

  @override
  String get insightIntensityLowRec =>
      'Meglio per resistenza muscolare. Aumenta carico per ipertrofia/forza. Riferimento: Reynolds et al. (2006)';

  @override
  String get insightPushPullImbalanceTitle => 'Sbilanciamento Push:Pull';

  @override
  String insightPushPullImbalanceMessage(
    String ratio,
    String pushSets,
    String pullSets,
  ) {
    return 'Rapporto: $ratio:1 ($pushSets serie push, $pullSets serie pull)';
  }

  @override
  String insightPushPullImbalanceRec(String feedback) {
    return '$feedback Riferimento: Boyle (2016)';
  }

  @override
  String get insightQuadHamHighRiskTitle =>
      'ALTO Rischio Infortunio Ischiocrurali';

  @override
  String insightQuadHamHighRiskMessage(
    String ratio,
    String quadSets,
    String hamSets,
  ) {
    return 'Rapporto Quad:Ham $ratio:1 ($quadSets serie quad, $hamSets serie ischiocrurali)';
  }

  @override
  String insightQuadHamHighRiskRec(String riskMultiplier) {
    return 'Ischiocrurali gravemente sotto-allenati ($riskMultiplier rischio infortunio). Aggiungi RDL, leg curl immediatamente. Riferimento: Croisier et al. (2008)';
  }

  @override
  String get processing => 'Elaborazione...';

  @override
  String get errorAuthenticationRequired =>
      'Autenticazione richiesta. Per favore accedi di nuovo.';

  @override
  String get errorCannotModifyTemplate =>
      'Non puoi modificare questo template. Puoi modificare solo i tuoi template.';

  @override
  String get errorNetworkConnection =>
      'Errore di rete. Controlla la connessione.';

  @override
  String get errorUnexpected =>
      'Si è verificato un errore imprevisto. Riprova.';

  @override
  String get pushPullRatio => 'Rapporto Push:Pull';

  @override
  String get quadHamstringRatio => 'Rapporto Quadricipiti:Ischiocrurali';

  @override
  String pushSetsLabel(Object count) {
    return '$count serie Push';
  }

  @override
  String pullSetsLabel(Object count) {
    return '$count serie Pull';
  }

  @override
  String quadSetsLabel(Object count) {
    return '$count serie Quadricipiti';
  }

  @override
  String hamstringSetsLabel(Object count) {
    return '$count serie Ischiocrurali';
  }

  @override
  String get pushPullExplanation =>
      'Equilibrato o enfatizzato su Pull per salute spalle e postura';

  @override
  String get quadHamExplanation =>
      'Rapporto <0.6 aumenta il rischio di infortunio agli ischiocrurali di 17 volte';

  @override
  String get feedbackTooMuchPull => 'Troppo volume Pull - aumenta lavoro Push';

  @override
  String get feedbackTooMuchPush =>
      'Troppo volume Push - rischio squilibri posturali. Aumenta lavoro Pull';

  @override
  String get feedbackSlightPushExcess =>
      'Leggero eccesso Push - considera più volume Pull per salute spalle';

  @override
  String get feedbackOptimalPushPull => 'Bilanciamento Push:Pull ottimale';

  @override
  String get feedbackGoodPullEmphasis =>
      'Buona enfasi Pull - ideale per salute spalle';

  @override
  String get feedbackHamstringSeverelyUndertrained =>
      'Ischiocrurali gravemente sotto-allenati - ALTO rischio infortunio. Aggiungi RDL, leg curl';

  @override
  String get feedbackHamstringUndertrained =>
      'Ischiocrurali sotto-allenati - aumenta volume catena posteriore';

  @override
  String get feedbackOptimalQuadHam =>
      'Bilanciamento Quadricipiti:Ischiocrurali ottimale';

  @override
  String get feedbackHamstringOveremphasized =>
      'Ischiocrurali potenzialmente sovra-enfatizzati vs quadricipiti';

  @override
  String get insightDisclaimer =>
      'Gli insight si basano sui tuoi dati di allenamento recenti e ricerca scientifica';

  @override
  String get mediumPriority => 'Priorità Media';

  @override
  String get lowPriority => 'Priorità Bassa';

  @override
  String get whyThisMatters => 'Perché è Importante';

  @override
  String get yourData => 'I Tuoi Dati';

  @override
  String get evidenceBasedSolutions => 'Soluzioni Basate su Evidenze';

  @override
  String get howToImplement => 'Come implementare:';

  @override
  String get trackYourFitnessJourney => 'Monitora il tuo percorso fitness';

  @override
  String get trackYourWorkoutsAndMonitorProgress =>
      'Monitora i tuoi allenamenti e i tuoi progressi';

  @override
  String get signInToViewAnalytics => 'Accedi per visualizzare le statistiche';

  @override
  String get startYourFirstWorkout => 'Inizia il Tuo Primo Allenamento';

  @override
  String get startYourFirstWorkoutDesc =>
      'Inizia il tuo primo allenamento per vedere le statistiche';

  @override
  String get fitnessQuoteEmptyState =>
      'Il viaggio di mille miglia inizia con una singola ripetizione';

  @override
  String get proTip => '💡 Suggerimento:';

  @override
  String get proTipFirstWorkout =>
      'Inizia con esercizi composti come squat e panca piana per massimi risultati';

  @override
  String get errorLoadingAnalytics => 'Errore caricamento statistiche';

  @override
  String get accountError => 'Errore Account';

  @override
  String get unableToLoadUserData =>
      'Impossibile caricare i dati utente. Esci e accedi di nuovo.';

  @override
  String get year => 'Anno';

  @override
  String get all => 'Tutti';

  @override
  String get thisWeekProgress => 'Progresso di Questa Settimana';

  @override
  String get thisMonthProgress => 'Progresso di Questo Mese';

  @override
  String get thisYearProgress => 'Progresso di Quest\'Anno';

  @override
  String get allTimeProgress => 'Progresso Totale';

  @override
  String get last7Days => 'Ultimi 7 giorni';

  @override
  String get last30Days => 'Ultimi 30 giorni';

  @override
  String get last365Days => 'Ultimi 365 giorni';

  @override
  String get allTime => 'Da sempre';

  @override
  String get keepItUp => 'Continua così!';

  @override
  String get viewStats => 'Vedi Statistiche';

  @override
  String get noRecentWorkoutsDesc =>
      'Inizia un allenamento per vedere i tuoi progressi';

  @override
  String get noRecentWorkouts => 'Nessun allenamento recente';

  @override
  String workoutsCount(int count, int goal) {
    return '$count / $goal allenamenti';
  }

  @override
  String repsCount(int count) {
    return '$count reps';
  }

  @override
  String get noActivitiesInPeriod => 'Nessuna attività in questo periodo';

  @override
  String get noActivitiesForSelectedMuscleGroups =>
      'Nessuna attività per i gruppi muscolari selezionati';

  @override
  String get noCompletedExercises =>
      'Nessun esercizio completato trovato nei tuoi allenamenti';

  @override
  String get unableToLoadActivities =>
      'Impossibile caricare le attività degli esercizi';

  @override
  String allActivitiesCount(int count) {
    return 'Tutte le Attività ($count)';
  }

  @override
  String get muscleGroupStatistics => 'Statistiche Gruppi Muscolari';

  @override
  String get setsDetails => 'Dettagli Serie';

  @override
  String volumeWithValue(String value) {
    return 'Volume: $value kg';
  }

  @override
  String rpeWithValue(String value) {
    return 'RPE: $value';
  }

  @override
  String kgMax(String value) {
    return '$value kg max';
  }

  @override
  String totalRepsCount(int count) {
    return '$count ripetizioni';
  }

  @override
  String aiWeightJumpAnalysis(Object absoluteIncrease, Object percentIncrease) {
    return 'Peso aumentato del $percentIncrease% (${absoluteIncrease}kg) in una singola sessione. La ricerca indica che aumenti improvvisi del carico >15-20% aumentano significativamente il rischio di infortuni, in particolare per il tessuto connettivo che si adatta più lentamente del muscolo. Il cedimento della forma tecnica si verifica spesso quando il drive neurale non riesce a supportare il nuovo carico.';
  }

  @override
  String dataPreviousWeight(Object weight) {
    return 'Peso precedente: ${weight}kg';
  }

  @override
  String dataCurrentWeight(Object weight) {
    return 'Peso attuale: ${weight}kg';
  }

  @override
  String dataAbsoluteJump(Object weight) {
    return 'Salto assoluto: +${weight}kg';
  }

  @override
  String dataPercentageIncrease(Object percent) {
    return 'Aumento percentuale: $percent%';
  }

  @override
  String dataSafeThreshold(Object threshold) {
    return 'Soglia sicura: <$threshold%';
  }

  @override
  String get dataRiskFactors =>
      'Rischio: Cedimento tecnico, affaticamento tendini';

  @override
  String get strategyUseSmallerIncrementsTitle => 'Usa Incrementi Più Piccoli';

  @override
  String get strategyUseSmallerIncrementsDesc =>
      'La progressione graduale del carico permette l\'adattamento del tessuto connettivo e mantiene la forma tecnica corretta';

  @override
  String get strategyUseSmallerIncrementsHow =>
      'Aumenta il peso del 2.5-5% per sessione (2.5kg per parte inferiore, 1.25kg per parte superiore). Usa dischi frazionari o microcarichi';

  @override
  String get strategyUseSmallerIncrementsOutcome =>
      'Progresso sostenuto con ridotto rischio infortuni. I tendini si adattano in 6-8 settimane';

  @override
  String get strategyFocusRepQualityTitle =>
      'Concentrati sulla Qualità delle Ripetizioni';

  @override
  String get strategyFocusRepQualityDesc =>
      'La competenza tecnica deve essere mantenuta in tutti i range di ripetizioni. Velocità e controllo sono indicatori di carico appropriato';

  @override
  String get strategyFocusRepQualityHow =>
      'Filma le tue serie. Se la velocità del bilanciere diminuisce >20% o la tecnica cede, riduci il peso del 10% e ricostruisci';

  @override
  String get strategyFocusRepQualityOutcome =>
      'Migliori pattern motori e guadagni di forza a lungo termine';

  @override
  String get strategyDeloadWeekTitle => 'Settimana di Scarico';

  @override
  String get strategyDeloadWeekDesc =>
      'Dopo rapidi aumenti di carico, il tessuto connettivo necessita tempo di consolidamento';

  @override
  String get strategyDeloadWeekHow =>
      'Riduci il peso del 20-30% per una settimana mantenendo il volume. Concentrati su tecnica e recupero';

  @override
  String get strategyDeloadWeekOutcome =>
      'Ridotto rischio infortuni e migliore adattamento a lungo termine';

  @override
  String get insightsAICoach => 'Approfondimenti AI Coach';

  @override
  String aiMuscleImbalanceAnalysis(Object muscleGroup, Object sets) {
    return '$muscleGroup è attualmente a $sets serie/settimana, al di sotto del Volume Minimo Efficace (MEV) di 10 serie. La ricerca scientifica dimostra che i muscoli richiedono almeno 10-20 serie per settimana per un\'ipertrofia ottimale.';
  }

  @override
  String dataCurrentVolume(Object sets) {
    return 'Volume attuale: $sets serie/settimana';
  }

  @override
  String get dataMEV => 'MEV (Minimo): 10 serie/settimana';

  @override
  String get dataMAV => 'MAV (Ottimale): 15-20 serie/settimana';

  @override
  String dataDeficit(Object deficit) {
    return 'Deficit: $deficit serie sotto MEV';
  }

  @override
  String dataExercisesList(Object exercises) {
    return 'Esercizi: $exercises';
  }

  @override
  String aiHighVolumeAnalysis(Object muscleGroup, Object sets) {
    return '$muscleGroup è a $sets serie/settimana, superando il Volume Massimo Recuperabile (MRV) di 25 serie. Questo livello di volume può portare a fatica sistemica, recupero compromesso e rendimenti decrescenti. La ricerca mostra che superare l\'MRV aumenta il rischio di infortuni senza benefici aggiuntivi per la crescita muscolare.';
  }

  @override
  String get dataMRV => 'MRV (Massimo): 25 serie/settimana';

  @override
  String dataExcess(Object excess) {
    return 'Eccesso: $excess serie sopra MRV';
  }

  @override
  String get dataRiskOvertraining => 'Rischio: Sindrome da sovrallenamento';

  @override
  String get strategyReduceVolumeTitle => 'Riduci Volume Gradualmente';

  @override
  String get strategyReduceVolumeDesc =>
      'Cali improvvisi di volume possono causare detraining. Una riduzione graduale mantiene gli adattamenti permettendo il recupero';

  @override
  String get strategyReduceVolumeHow =>
      'Riduci del 20-30% per settimana fino a raggiungere 15-20 serie. Esempio: 28 serie → 22 serie → 18 serie in 2 settimane';

  @override
  String get strategyReduceVolumeOutcome =>
      'Capacità di recupero ripristinata e performance migliorata in 2-3 settimane';

  @override
  String get strategyDeloadTitle => 'Implementa Settimana di Scarico';

  @override
  String get strategyDeloadDesc =>
      'Una settimana strategica di recupero permette la supercompensazione e la dissipazione della fatica';

  @override
  String get strategyDeloadHow =>
      'Riduci il volume del 40-50% per una settimana. Mantieni l\'intensità ma dimezza le serie';

  @override
  String get strategyDeloadOutcome =>
      'Sistema nervoso fresco e performance successiva migliorata';

  @override
  String get strategyReallocateTitle => 'Rialloca il Volume';

  @override
  String get strategyReallocateDesc =>
      'Distribuisci il volume in eccesso ai gruppi muscolari poco sviluppati per uno sviluppo equilibrato';

  @override
  String get strategyReallocateHow =>
      'Identifica i muscoli sotto MEV. Trasferisci 1-2 esercizi dal muscolo sovrallenato alle aree sottoallenate';

  @override
  String get strategyReallocateOutcome =>
      'Sviluppo bilanciato e risorse di recupero ottimizzate';

  @override
  String aiPlateauAnalysis(Object variation) {
    return 'La variazione di peso nelle ultime 3 sessioni è $variation% (soglia: 5%). Questo indica uno stimolo di sovraccarico progressivo insufficiente per l\'adattamento.';
  }

  @override
  String dataWeightVariation(Object variation) {
    return 'Variazione di peso: $variation%';
  }

  @override
  String get dataThreshold => 'Soglia di progressione: >5%';

  @override
  String dataLastWeights(Object weights) {
    return 'Pesi recenti: $weights';
  }

  @override
  String dataRecommendedIncrease(Object increase) {
    return 'Aumento raccomandato: ${increase}kg';
  }

  @override
  String aiInsufficientRecoveryAnalysis(Object days) {
    return 'Solo $days giorni dall\'ultimo allenamento. La ricerca mostra che i muscoli necessitano di 24-48 ore per una sintesi proteica ottimale e il ripristino del glicogeno. Allenarsi troppo frequentemente può compromettere il recupero e aumentare il rischio di infortuni.';
  }

  @override
  String dataLastWorkout(Object days) {
    return 'Ultimo allenamento: $days giorni fa';
  }

  @override
  String get dataMinimumRecovery => 'Minimo raccomandato: 1.0 giorni (24 ore)';

  @override
  String get dataOptimalRange => 'Range ottimale: 1-3 giorni tra sessioni';

  @override
  String get dataCurrentStatus => 'Status: Recupero insufficiente';

  @override
  String get dataMuscleProteinSynthesis => 'Finestra MPS: Ancora attiva';

  @override
  String aiLongRecoveryAnalysis(Object days) {
    return '$days giorni senza allenamento. Sebbene il recupero sia importante, pause più lunghe di 4 giorni possono portare a effetti di detraining. La sintesi proteica muscolare ritorna ai valori basali dopo 48-72 ore, e gli adattamenti di forza iniziano a diminuire.';
  }

  @override
  String get dataMaxRecommended => 'Massimo raccomandato: 4.0 giorni';

  @override
  String get dataProteinSynthesisPeak =>
      'Picco sintesi proteica: 24-48h post-allenamento';

  @override
  String get dataDetrainingRisk => 'Rischio: Effetti di detraining';

  @override
  String get strategyActiveRecoveryTitle => 'Sessioni di Recupero Attivo';

  @override
  String get strategyActiveRecoveryDesc =>
      'Il movimento leggero mantiene gli adattamenti senza aggiungere fatica';

  @override
  String get strategyActiveRecoveryHow =>
      'Esegui 20-30 min di cardio leggero o esercizi a corpo libero al 40-60% di intensità nei giorni di riposo';

  @override
  String get strategyActiveRecoveryOutcome =>
      'Adattamenti mantenuti e qualità del recupero migliorata';

  @override
  String get strategyScheduleWorkoutsTitle =>
      'Programma il Prossimo Allenamento';

  @override
  String get strategyScheduleWorkoutsDesc =>
      'La costanza è la chiave per il progresso a lungo termine. Pianifica in anticipo per evitare pause prolungate';

  @override
  String get strategyScheduleWorkoutsHow =>
      'Imposta giorni e orari specifici per l\'allenamento. Usa promemoria sul calendario. Punta a max 3 giorni di pausa';

  @override
  String get strategyScheduleWorkoutsOutcome =>
      'Stimolo costante per adattamento continuo';

  @override
  String aiLowFrequencyAnalysis(Object frequency) {
    return 'La frequenza di allenamento attuale di $frequency sessioni/settimana è sotto la soglia minima per adattamenti significativi. La ricerca dimostra che allenare un gruppo muscolare meno di una volta a settimana risulta in ipertrofia e guadagni di forza minimi. La sintesi proteica muscolare raggiunge il picco 24-48h post-allenamento e ritorna ai valori basali entro 72h.';
  }

  @override
  String dataCurrentFrequency(Object frequency) {
    return 'Frequenza attuale: $frequency allenamenti/settimana';
  }

  @override
  String get dataMinimumEffective =>
      'Minimo efficace: 1-2 allenamenti/settimana';

  @override
  String get dataOptimalFrequency =>
      'Range ottimale: 3-5 allenamenti/settimana';

  @override
  String get dataAdaptationStatus =>
      'Status: Stimolo di adattamento subottimale';

  @override
  String dataMPSCycle(Object hours) {
    return 'Ciclo MPS: finestra di ${hours}h sottoutilizzata';
  }

  @override
  String get strategyIncreaseFrequencyTitle =>
      'Aumenta la Frequenza di Allenamento';

  @override
  String get strategyIncreaseFrequencyDesc =>
      'Maggiore frequenza fornisce stimolo più frequente per l\'adattamento';

  @override
  String get strategyIncreaseFrequencyHow =>
      'Aggiungi 1 sessione per settimana inizialmente. Arriva a 3-4 sessioni. Concentrati su gruppi muscolari diversi per sessione';

  @override
  String get strategyIncreaseFrequencyOutcome =>
      'Frequenza di sintesi proteica muscolare aumentata e guadagni più rapidi';

  @override
  String get strategyFullBodyTitle => 'Adotta Allenamenti Full-Body';

  @override
  String get strategyFullBodyDesc =>
      'Le sessioni full-body permettono di colpire ogni muscolo 2-3x/settimana anche con bassa frequenza';

  @override
  String get strategyFullBodyHow =>
      'Progetta 2-3 allenamenti che colpiscono tutti i muscoli principali. Includi 1-2 esercizi per gruppo muscolare';

  @override
  String get strategyFullBodyOutcome =>
      'Frequenza di stimolo ottimale anche con giorni di allenamento limitati';

  @override
  String aiHighFrequencyAnalysis(Object frequency) {
    return 'Allenarsi $frequency volte a settimana può superare la frequenza ottimale per il recupero. Sebbene l\'alta frequenza possa funzionare per atleti avanzati con programmazione corretta, aumenta il rischio di sovrallenamento, fatica del SNC e rendimenti decrescenti. Gli studi mostrano nessun beneficio aggiuntivo di ipertrofia oltre 5-6 sessioni/settimana quando il volume è equiparato.';
  }

  @override
  String get dataMaxBeneficial => 'Massimo benefico: ~6 allenamenti/settimana';

  @override
  String get dataRecoveryStatus => 'Status: Potenziale overreaching';

  @override
  String get dataCNSFatigue => 'Rischio fatica SNC: Elevato';

  @override
  String get strategyReduceFrequencyTitle =>
      'Riduci la Frequenza di Allenamento';

  @override
  String get strategyReduceFrequencyDesc =>
      'Frequenza più bassa con volume mantenuto può migliorare recupero e risultati';

  @override
  String get strategyReduceFrequencyHow =>
      'Consolida gli allenamenti in 4-5 sessioni di qualità. Aumenta leggermente il volume per sessione';

  @override
  String get strategyReduceFrequencyOutcome =>
      'Miglior recupero, ridotto rischio infortuni, guadagni mantenuti o migliorati';

  @override
  String get strategyImplementRestDaysTitle =>
      'Implementa Giorni di Riposo Strategici';

  @override
  String get strategyImplementRestDaysDesc =>
      'Il riposo programmato permette l\'adattamento e previene l\'accumulo di fatica';

  @override
  String get strategyImplementRestDaysHow =>
      'Prendi almeno 1-2 giorni di riposo completo per settimana. Posizionali dopo i giorni di allenamento più duri';

  @override
  String get strategyImplementRestDaysOutcome =>
      'Recupero ottimizzato e performance sostenuta';

  @override
  String dataSession1(Object weight) {
    return 'Sessione 1: ${weight}kg';
  }

  @override
  String dataSession2(Object weight) {
    return 'Sessione 2: ${weight}kg';
  }

  @override
  String dataSession3(Object weight) {
    return 'Sessione 3: ${weight}kg';
  }

  @override
  String dataAverageWeight(Object weight) {
    return 'Media: ${weight}kg';
  }

  @override
  String dataWeightVariation2(Object percent, Object weight) {
    return 'Variazione: ${weight}kg ($percent%)';
  }

  @override
  String get strategyPlateauincreasevolumeTitle =>
      'Aumenta il Volume di Allenamento';

  @override
  String get strategyPlateauincreasevolumeDesc =>
      'L\'aumento progressivo del volume è uno dei principali fattori di adattamento per l\'ipertrofia';

  @override
  String get strategyPlateauincreasevolumeImpl =>
      'Aggiungi 1-2 serie a settimana fino a raggiungere 15-20 serie per gruppo muscolare. Esempio: se fai 3 serie, aumenta a 4-5 serie';

  @override
  String get strategyPlateauincreasevolumeOutcome =>
      'Nuovo stimolo di crescita entro 2-4 settimane. Il volume deve aumentare gradualmente per evitare sovrallenamento';

  @override
  String get strategyPlateauvaryrepsTitle => 'Varia i Range di Ripetizioni';

  @override
  String get strategyPlateauvaryrepsDesc =>
      'Diversi range di ripetizioni reclutano diversi tipi di fibre muscolari e creano nuova tensione meccanica';

  @override
  String get strategyPlateauvaryrepsImpl =>
      'Alterna tra range di forza (4-6 rip), ipertrofia (8-12 rip) e resistenza (15-20 rip) nelle diverse settimane';

  @override
  String get strategyPlateauvaryrepsOutcome =>
      'Sviluppo muscolare complessivo e guadagni di forza migliorati in tutti i range';

  @override
  String get strategyPlateauadvancedtechniquesTitle =>
      'Implementa Tecniche Avanzate';

  @override
  String get strategyPlateauadvancedtechniquesDesc =>
      'Le tecniche di intensità aumentano lo stress metabolico e la tensione meccanica oltre le serie tradizionali';

  @override
  String get strategyPlateauadvancedtechniquesImpl =>
      'Usa drop set (riduci peso 20-30% dopo il cedimento), rest-pause (10-15 sec riposo tra mini-serie), o ripetizioni forzate nell\'ultima serie';

  @override
  String get strategyPlateauadvancedtechniquesOutcome =>
      'Aumento immediato del reclutamento delle fibre muscolari e dello stress metabolico';

  @override
  String get strategyPlateauchangeexercisesTitle =>
      'Cambia Variante dell\'Esercizio';

  @override
  String get strategyPlateauchangeexercisesDesc =>
      'Esercizi nuovi creano vettori di forza e pattern di reclutamento differenti';

  @override
  String get strategyPlateauchangeexercisesImpl =>
      'Sostituisci esercizi simili con angolazioni diverse. Esempio: panca piana → panca inclinata, squat → front squat';

  @override
  String get strategyPlateauchangeexercisesOutcome =>
      'Rinnovati guadagni di forza e attivazione muscolare in 1-2 settimane';

  @override
  String get strategyPlateaudeloadweekTitle => 'Settimana di Scarico';

  @override
  String get strategyPlateaudeloadweekDesc =>
      'Il recupero strategico permette la supercompensazione e il recupero del sistema nervoso';

  @override
  String get strategyPlateaudeloadweekImpl =>
      'Riduci il volume del 40-50% per 1 settimana (metà serie, stesso peso). Mantieni la frequenza ma riduci il lavoro totale';

  @override
  String get strategyPlateaudeloadweekOutcome =>
      'Ritorna più forte dopo lo scarico con ridotta fatica e migliore efficienza neuromuscolare';

  @override
  String get strategyBalanceincreasefrequencyTitle =>
      'Aumenta la Frequenza di Allenamento';

  @override
  String get strategyBalanceincreasefrequencyDesc =>
      'Maggiore frequenza offre più opportunità per accumulare volume e pratica tecnica';

  @override
  String get strategyBalanceincreasefrequencyImpl =>
      'Dividi il volume attuale in 2-3 sessioni settimanali invece di 1. Esempio: 10 serie → 5 serie × 2 giorni';

  @override
  String get strategyBalanceincreasefrequencyOutcome =>
      'Miglior recupero tra sessioni e serie di qualità superiore';

  @override
  String get strategyBalanceprioritizeweakTitle =>
      'Dai Priorità ai Muscoli Deboli';

  @override
  String get strategyBalanceprioritizeweakDesc =>
      'Allenare i muscoli carenti per primi quando l\'energia è massima ottimizza l\'adattamento';

  @override
  String get strategyBalanceprioritizeweakImpl =>
      'Esegui esercizi per muscoli deboli all\'inizio dell\'allenamento quando sei fresco neurologicamente';

  @override
  String get strategyBalanceprioritizeweakOutcome =>
      'Migliori prestazioni e sovraccarico progressivo sui punti deboli';

  @override
  String get strategyBalanceaddisolationTitle =>
      'Aggiungi Esercizi di Isolamento';

  @override
  String get strategyBalanceaddisolationDesc =>
      'L\'isolamento diretto permette volume mirato senza affaticamento sistemico';

  @override
  String get strategyBalanceaddisolationImpl =>
      'Aggiungi 2-3 esercizi di isolamento (12-15 rip) dopo i multiarticolari per il muscolo debole';

  @override
  String get strategyBalanceaddisolationOutcome =>
      'Aumento del volume locale e connessione mente-muscolo';

  @override
  String get strategyRecoveryoptimizesleepTitle =>
      'Ottimizza la Durata del Sonno';

  @override
  String get strategyRecoveryoptimizesleepDesc =>
      'Il sonno è il principale meccanismo di recupero per l\'adattamento neuromuscolare';

  @override
  String get strategyRecoveryoptimizesleepImpl =>
      'Punta a 7-9 ore a notte. Dai priorità a orari costanti (stessa ora di addormentamento/risveglio)';

  @override
  String get strategyRecoveryoptimizesleepOutcome =>
      'Sintesi proteica muscolare migliorata e livelli di cortisolo ridotti';

  @override
  String get strategyRecoveryperiodizeTitle => 'Periodizza lo Stress Allenante';

  @override
  String get strategyRecoveryperiodizeDesc =>
      'Alternare settimane ad alto e basso stress previene l\'affaticamento cronico';

  @override
  String get strategyRecoveryperiodizeImpl =>
      '3 settimane di sovraccarico progressivo → 1 settimana scarico (riduzione 50% volume)';

  @override
  String get strategyRecoveryperiodizeOutcome =>
      'Progresso sostenuto senza esaurimento o rischio infortuni';

  @override
  String get strategyRecoveryactiverecoveryTitle =>
      'Sessioni di Recupero Attivo';

  @override
  String get strategyRecoveryactiverecoveryDesc =>
      'Attività leggera migliora il flusso sanguigno e rimozione scorie senza aggiungere fatica';

  @override
  String get strategyRecoveryactiverecoveryImpl =>
      'Aggiungi 20-30 min di cardio a bassa intensità o mobilità nei giorni di riposo';

  @override
  String get strategyRecoveryactiverecoveryOutcome =>
      'Recupero più veloce e ridotto dolore muscolare';

  @override
  String get strategyLongrecoveryscheduleTitle =>
      'Stabilisci un Programma Costante';

  @override
  String get strategyLongrecoveryscheduleDesc =>
      'La frequenza di allenamento è più importante della qualità delle singole sessioni per il progresso a lungo termine';

  @override
  String get strategyLongrecoveryscheduleImpl =>
      'Programma 3-5 giorni fissi di allenamento a settimana. Usa promemoria calendario. Prepara borsa palestra la sera prima';

  @override
  String get strategyLongrecoveryscheduleOutcome =>
      'Migliore formazione dell\'abitudine e aderenza all\'allenamento entro 3-4 settimane';

  @override
  String get strategyLongrecoverymindoseTitle => 'Usa la Dose Minima Efficace';

  @override
  String get strategyLongrecoverymindoseDesc =>
      'Sessioni brevi e frequenti mantengono gli adattamenti meglio di allenamenti lunghi e sporadici';

  @override
  String get strategyLongrecoverymindoseImpl =>
      'Se hai poco tempo, fai sessioni di 20-30 min invece di saltare. Concentrati su multiarticolari';

  @override
  String get strategyLongrecoverymindoseOutcome =>
      'Forza e massa muscolare mantenute con il 60% di volume in meno';

  @override
  String get strategyLowfrequencyminviableTitle =>
      'Inizia con Frequenza Minima Praticabile';

  @override
  String get strategyLowfrequencyminviableDesc =>
      'Anche 2 sessioni settimanali producono l\'80% dei benefici di frequenze maggiori per principianti';

  @override
  String get strategyLowfrequencyminviableImpl =>
      'Programma 2 sessioni full-body a settimana (es. Lunedì/Giovedì). 45-60 min ciascuna con 4-5 multiarticolari';

  @override
  String get strategyLowfrequencyminviableOutcome =>
      'Guadagni di forza misurabili entro 4-6 settimane. Formazione abitudine in 3-4 settimane';

  @override
  String get strategyLowfrequencytimeefficientTitle =>
      'Usa Protocolli Efficienti nel Tempo';

  @override
  String get strategyLowfrequencytimeefficientDesc =>
      'Selezione strategica degli esercizi massimizza i risultati per minuto investito';

  @override
  String get strategyLowfrequencytimeefficientImpl =>
      'Concentrati sui multiarticolari: Squat, Panca, Stacco, Rematore, Lento. 3 serie da 8-12 rip. Totale: 30-40 min';

  @override
  String get strategyLowfrequencytimeefficientOutcome =>
      'Stimolo total body con investimento minimo di tempo';

  @override
  String get strategyHighfrequencyconsolidateTitle =>
      'Consolida le Sessioni di Allenamento';

  @override
  String get strategyHighfrequencyconsolidateDesc =>
      'Sessioni meno frequenti ma di qualità superiore spesso superano lavoro ad alta frequenza ma bassa qualità';

  @override
  String get strategyHighfrequencyconsolidateImpl =>
      'Combina gruppi muscolari simili. Esempio: invece di 7 sessioni separate, fai 4-5 sessioni mirate con più volume per allenamento';

  @override
  String get strategyHighfrequencyconsolidateOutcome =>
      'Miglior recupero, volume mantenuto, ridotto accumulo di fatica';

  @override
  String get strategyHighfrequencyrestdaysTitle =>
      'Implementa Giorni di Riposo Strategici';

  @override
  String get strategyHighfrequencyrestdaysDesc =>
      'Giorni di riposo completo o recupero attivo sono essenziali per la supercompensazione';

  @override
  String get strategyHighfrequencyrestdaysImpl =>
      'Prenditi 1-2 giorni di riposo completo a settimana. Nei giorni di riposo, fai solo camminata leggera o mobilità (no resistance)';

  @override
  String get strategyHighfrequencyrestdaysOutcome =>
      'Miglior rimbalzo di forza e ridotto rischio infortuni entro 2-3 settimane';

  @override
  String get strategyHighvolumereducegraduallyTitle =>
      'Riduci Volume Gradualmente';

  @override
  String get strategyHighvolumereducegraduallyDesc =>
      'Riduzioni improvvise del volume possono causare detraining. La riduzione graduale mantiene gli adattamenti permettendo il recupero';

  @override
  String get strategyHighvolumereducegraduallyImpl =>
      'Riduci del 20-30% a settimana fino a raggiungere 15-20 serie. Esempio: 28 serie → 22 serie → 18 serie in 2 settimane';

  @override
  String get strategyHighvolumereducegraduallyOutcome =>
      'Capacità di recupero ripristinata e prestazioni migliorate entro 2-3 settimane';

  @override
  String get strategyHighvolumedeloadTitle => 'Implementa Settimana di Scarico';

  @override
  String get strategyHighvolumedeloadDesc =>
      'Una settimana di recupero strategico permette la supercompensazione e dissipazione della fatica';

  @override
  String get strategyHighvolumedeloadImpl =>
      'Riduci volume del 50% per una settimana. Mantieni peso ma fai metà serie. Poi riprendi a volume ottimale (15-20 serie)';

  @override
  String get strategyHighvolumedeloadOutcome =>
      'Ritorna più forte con fatica accumulata ridotta. Rimbalzo di forza in 7-10 giorni';

  @override
  String get strategyHighvolumeincreasefreqTitle =>
      'Aumenta Frequenza di Allenamento';

  @override
  String get strategyHighvolumeincreasefreqDesc =>
      'Stesso volume distribuito su più sessioni riduce la fatica per sessione';

  @override
  String get strategyHighvolumeincreasefreqImpl =>
      'Dividi volume attuale su più giorni. Esempio: 28 serie/settimana → 7 serie × 4 giorni invece di 14 serie × 2 giorni';

  @override
  String get strategyHighvolumeincreasefreqOutcome =>
      'Miglior recupero tra sessioni e serie di qualità superiore';

  @override
  String get filterByType => 'Filtra per Tipo';

  @override
  String get filterByPriority => 'Filtra per Priorità';

  @override
  String get success => 'Successo';

  @override
  String get info => 'Info';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Medio';

  @override
  String get low => 'Bassa';

  @override
  String get criticalSeverity => 'Gravità critica - azione immediata richiesta';

  @override
  String get highSeverity => 'Gravità alta - azione consigliata';

  @override
  String get mediumSeverity => 'Gravità media - considera l\'azione';

  @override
  String get lowSeverity => 'Gravità bassa - informativo';

  @override
  String get filterRecommendations => 'Filtra Raccomandazioni';

  @override
  String get noRecommendationsFound =>
      'Nessuna raccomandazione corrisponde ai filtri';

  @override
  String get totalVolumeTooltip =>
      'Il Volume Totale rappresenta la somma di peso × ripetizioni di tutti gli esercizi. È un indicatore chiave dello stress di allenamento e della progressione.';

  @override
  String get workoutFrequencyTooltip =>
      'La Frequenza di Allenamento indica quante volte ti alleni a settimana. La ricerca mostra che 3-5 sessioni settimanali sono ottimali per la maggior parte degli obiettivi.';

  @override
  String get consistencyTooltip =>
      'Il Punteggio di Consistenza misura quanto regolarmente rispetti il tuo programma. Punteggi più alti (80%+) portano a risultati migliori a lungo termine.';

  @override
  String get currentStreakTooltip =>
      'La Serie Attuale traccia i giorni consecutivi con almeno un allenamento. Mantenere serie costruisce abitudini di allenamento sostenibili.';

  @override
  String get muscleBalanceTooltip =>
      'L\'Equilibrio Muscolare mostra la distribuzione del volume di allenamento tra i gruppi muscolari. Punta a uno sviluppo equilibrato (15-20% per gruppo).';

  @override
  String get volumeTrendTooltip =>
      'Il Trend di Volume indica se il tuo volume totale di allenamento sta aumentando (+), stabile (=), o diminuendo (-) nel tempo.';

  @override
  String get weeklyDashboard => 'Dashboard Settimanale';

  @override
  String get consistencyHeatmap => 'Mappa Coerenza';

  @override
  String get adminMode => 'MODALITÀ ADMIN';

  @override
  String get premiumInsights => 'Insights Premium';

  @override
  String get unlockAdvancedAnalytics => 'Sblocca analytics e insights avanzati';

  @override
  String get weeklyPerformanceDashboard => 'Dashboard Performance Settimanale';

  @override
  String get muscleGroupBalanceAnalysis =>
      'Analisi Equilibrio Gruppi Muscolari';

  @override
  String get workoutConsistencyTracking => 'Tracciamento Coerenza Allenamenti';

  @override
  String get personalizedRecommendations => 'Raccomandazioni Personalizzate';

  @override
  String get unlockPremium => 'Sblocca Premium';

  @override
  String get scientificBasis => 'Base Scientifica';

  @override
  String get exerciseBreakdown => 'Dettaglio Esercizi';

  @override
  String get total => 'Totale';

  @override
  String get primary => 'Primario';

  @override
  String get secondary => 'Secondario';

  @override
  String get tapForScientificExplanation => 'Tocca per spiegazione scientifica';

  @override
  String get pectorals => 'PETT (Pettorali)';

  @override
  String get deltoids => 'DELT (Deltoidi)';

  @override
  String get premium => 'Premium';

  @override
  String get premiumAnalytics => 'Analytics Premium';

  @override
  String get scienceBasedInsights =>
      'Insights basati sulla scienza per atleti seri';

  @override
  String get repContinuum => 'Continuum Ripetizioni';

  @override
  String get repContinuumSubtitle =>
      'Distribuzione allenamento tra zone forza, ipertrofia ed endurance';

  @override
  String totalSetsAnalyzed(int count) {
    return '$count serie totali analizzate';
  }

  @override
  String get strengthZone => 'Forza (1-5 rip)';

  @override
  String get strengthZoneDesc => 'Forza massima, adattamenti neurali';

  @override
  String get hypertrophyZone => 'Ipertrofia (6-15 rip)';

  @override
  String get hypertrophyZoneDesc => 'Crescita muscolare, stress metabolico';

  @override
  String get enduranceZone => 'Resistenza (15+ rip)';

  @override
  String get enduranceZoneDesc => 'Resistenza muscolare, condizionamento';

  @override
  String get repContinuumRecommendationBalanced =>
      '✅ Eccellente! Il tuo allenamento è ben bilanciato per l\'ipertrofia. La maggior parte delle serie (60%+) è nel range ottimale 6-15 ripetizioni.';

  @override
  String get repContinuumRecommendationStrength =>
      '🏋️ Allenamento orientato alla forza rilevato. Considera di aggiungere più lavoro di ipertrofia (6-15 rip) per la crescita muscolare.';

  @override
  String get repContinuumRecommendationEndurance =>
      '🏃 Volume elevato di endurance. Aggiungi lavoro a ripetizioni più basse (6-15 rip) per forza e ipertrofia.';

  @override
  String get repContinuumRecommendationMixed =>
      '📊 Approccio misto rilevato. Assicurati che ogni gruppo muscolare abbia volume adeguato nei range target.';

  @override
  String get repContinuumScientificTitle => 'Il Continuum delle Ripetizioni';

  @override
  String get repContinuumScientificSubtitle =>
      'Raccomandazioni di carico per forza, ipertrofia ed endurance muscolare';

  @override
  String get repContinuumPaperSummary =>
      'Questa review completa ha analizzato 100+ studi per determinare strategie di carico ottimali. Risultato chiave: diversi range di ripetizioni producono adattamenti distinti - forza (1-5), ipertrofia (6-15), endurance (15+).';

  @override
  String get keyFindings => 'Risultati Chiave';

  @override
  String get repContinuumFinding1 =>
      'Zona Forza (1-5 rip): Massimizza adattamenti neurali e forza assoluta. Ideale per powerlifting e produzione forza massima.';

  @override
  String get repContinuumFinding2 =>
      'Zona Ipertrofia (6-15 rip): Ottimale per crescita muscolare tramite tensione meccanica e stress metabolico. Standard per bodybuilding.';

  @override
  String get repContinuumFinding3 =>
      'Zona Resistenza (15+ rip): Sviluppa resistenza muscolare e capacità di lavoro. Importante per condizionamento metabolico.';

  @override
  String get practicalApplication => 'Applicazione Pratica';

  @override
  String get repContinuumPracticalAdvice =>
      'Per sviluppo muscolare bilanciato, punta al 60-70% del volume nella zona ipertrofia (6-15 rip). Includi 15-20% lavoro forza e 10-15% endurance per adattamento completo.';

  @override
  String get volumeLandmarks => 'Volume Landmarks';

  @override
  String get volumeLandmarksSubtitle =>
      'Volume settimanale per gruppo muscolare con zone ottimali';

  @override
  String get maintenanceVolume => 'MV';

  @override
  String get minEffectiveVolume => 'MEV';

  @override
  String get maxAdaptiveVolume => 'MAV';

  @override
  String get maxRecoverableVolume => 'MRV';

  @override
  String get volumeZoneBelowMaintenance =>
      '⚠️ Sotto mantenimento - aggiungi volume';

  @override
  String get volumeZoneMaintenance => 'Zona mantenimento';

  @override
  String get volumeZoneEffective => '↗️ Zona efficace - crescita';

  @override
  String get volumeZoneOptimal => '✅ Zona ottimale - perfetto!';

  @override
  String get volumeZoneExcessive => '❌ Eccessivo - rischio sovrallenamento';

  @override
  String get volumeLandmarksScientificTitle => 'Volume Landmarks Spiegati';

  @override
  String get volumeLandmarksScientificSubtitle =>
      'Raccomandazioni basate su evidenza per ipertrofia muscolare';

  @override
  String get volumeLandmarksPaperSummary =>
      'Questa umbrella review ha sintetizzato dati da 50+ meta-analisi per stabilire i landmarks di volume. La ricerca mostra chiara relazione dose-risposta tra serie settimanali e crescita muscolare fino a MAV.';

  @override
  String get volumeZonesExplanation => 'Zone di Volume Spiegate';

  @override
  String get mvExplanation =>
      'Serie minime settimanali per mantenere massa muscolare. Sotto questo livello, perderai muscolo nel tempo.';

  @override
  String get mevExplanation =>
      'Serie minime per iniziare a vedere crescita. Questa è la tua baseline per sovraccarico progressivo.';

  @override
  String get mavExplanation =>
      'Sweet spot per crescita muscolare. Massima risposta ipertrofica con fatica gestibile.';

  @override
  String get mrvExplanation =>
      'Volume massimo recuperabile. Oltre questo punto, la fatica si accumula più velocemente del recupero.';

  @override
  String get volumeLandmarksPracticalAdvice =>
      'Parti da MEV e aumenta progressivamente il volume ogni settimana fino a raggiungere MAV. Quando arrivi a MRV o plateau, fai una settimana di deload a livelli MV, poi riparti con la progressione.';

  @override
  String get tutVelocityAnalytics => 'Analytics TUT & Velocità';

  @override
  String get tutVelocityDesc =>
      'Metriche tempo sotto tensione e velocità bilanciere per stimolo muscolare ottimale';

  @override
  String get dataConfidenceScore => 'Punteggio Affidabilità Dati';

  @override
  String get dataConfidenceDesc =>
      'Valutazione qualità della precisione e consistenza del tracking';

  @override
  String get anabolicSignals => 'Segnali Anabolici';

  @override
  String get anabolicSignalsDesc =>
      'Indicatori real-time di stimolo crescita muscolare e stato di recupero';

  @override
  String get unlockPremiumAnalytics => 'Sblocca Analytics Premium';

  @override
  String get premiumAnalyticsDescription =>
      'Ottieni insights basati sulla scienza tramite ricerca peer-reviewed. Prendi decisioni data-driven per crescita muscolare e performance ottimali.';

  @override
  String get repContinuumFeature =>
      'Analisi Rep Continuum - ottimizza zone allenamento';

  @override
  String get volumeLandmarksFeature =>
      'Volume Landmarks - raggiungi il tuo sweet spot di crescita';

  @override
  String get tutVelocityFeature =>
      'Tracking TUT & Velocità - massimizza stimolo';

  @override
  String get dataConfidenceFeature =>
      'Scoring Affidabilità Dati - fidati dei tuoi dati';

  @override
  String get premiumComingSoon => 'Funzioni Premium in arrivo! 🚀';

  @override
  String get repContinuumPreview =>
      'Vedi come il tuo allenamento è distribuito tra zone forza, ipertrofia ed endurance';

  @override
  String get volumeLandmarksPreview =>
      'Traccia il tuo volume settimanale contro landmarks scientificamente validati (MV, MEV, MAV, MRV)';

  @override
  String volumeBelowMaintenanceExplanation(int current, int mv) {
    return 'Stai facendo solo $current serie/settimana. Il minimo per mantenere muscolo è $mv serie. Rischio perdita muscolare.';
  }

  @override
  String volumeBelowMaintenanceAdvice(int sets) {
    return 'Aggiungi almeno $sets serie questa settimana per raggiungere volume di mantenimento ed evitare perdita muscolare.';
  }

  @override
  String volumeMaintenanceExplanation(int current, int mv, int mev) {
    return 'Stai facendo $current serie/settimana. Questo mantiene il muscolo ($mv-$mev serie) ma non innesca crescita.';
  }

  @override
  String volumeMaintenanceAdvice(int sets) {
    return 'Aggiungi $sets serie in più per raggiungere MEV e iniziare a vedere crescita muscolare.';
  }

  @override
  String volumeEffectiveExplanation(int current, int mev, int mav) {
    return 'Stai facendo $current serie/settimana, nella zona di crescita ($mev-$mav serie). Buoni progressi!';
  }

  @override
  String volumeEffectiveAdvice(int sets) {
    return 'Puoi aggiungere fino a $sets serie in più per raggiungere zona MAV ottimale per massimi guadagni.';
  }

  @override
  String volumeOptimalExplanation(int current, int mav, int mrv) {
    return 'Stai facendo $current serie/settimana, nella zona ottimale ($mav-$mrv serie). Stimolo ipertrofico massimo!';
  }

  @override
  String get volumeOptimalAdvice =>
      'Perfetto! Mantieni questo volume per 2-4 settimane, poi considera una settimana di deload.';

  @override
  String volumeExcessiveExplanation(int current, int mrv) {
    return 'Stai facendo $current serie/settimana, oltre il limite di recupero ($mrv serie). Rischio sovrallenamento!';
  }

  @override
  String volumeExcessiveAdvice(int sets) {
    return 'Riduci volume di $sets serie o fai subito una settimana di deload al 50% del volume per recuperare.';
  }

  @override
  String get exercisesThisWeek => 'Esercizi Questa Settimana';

  @override
  String get rpeAndIntensity => 'RPE & Intensità';

  @override
  String get rpeIntensityDistribution => 'Distribuzione intensità allenamento';

  @override
  String get setsWithRPETracked => 'Serie con RPE tracciato';

  @override
  String get noRPEDataAvailable => 'Nessun dato RPE disponibile';

  @override
  String get noRPEDataDescription =>
      'Inizia a tracciare l\'RPE (Rate of Perceived Exertion) durante i tuoi allenamenti per vedere l\'analisi dell\'intensità';

  @override
  String get rpeDistribution => 'Distribuzione RPE';

  @override
  String get rpeRecovery => 'Recovery (5-6)';

  @override
  String get rpeModerate => 'Moderate (7)';

  @override
  String get rpeHard => 'Hard (8)';

  @override
  String get rpeVeryHard => 'Very Hard (9)';

  @override
  String get rpeMaximal => 'Maximal (10)';

  @override
  String get averageRPEPerMuscleGroup => 'RPE Medio per Gruppo Muscolare';

  @override
  String get setsUnit => 'serie';

  @override
  String get rangeLabel => 'Range:';

  @override
  String get helmsEtAl2018 =>
      'Helms et al. (2018) - Strength & Conditioning Journal';

  @override
  String get intensityZoneTooEasy => 'Troppo Facile';

  @override
  String get intensityZoneTooEasyDesc =>
      'Oltre il 50% delle serie sono a bassa intensità (RPE 5-6). Rischio di mancanza di progressi.';

  @override
  String get intensityZoneTooEasyAdvice =>
      'Aumenta l\'intensità: porta il 60-80% delle serie a RPE 7-9 per stimolare ipertrofia.';

  @override
  String get intensityZoneOptimalHypertrophy => 'Ottimale per Ipertrofia';

  @override
  String get intensityZoneOptimalHypertrophyDesc =>
      'Il 60-80% delle serie sono a intensità produttiva (RPE 7-9). Perfetto per crescita muscolare!';

  @override
  String get intensityZoneOptimalHypertrophyAdvice =>
      'Continua così! Questa distribuzione è ideale per massimizzare l\'ipertrofia.';

  @override
  String get intensityZoneOptimalStrength => 'Ottimale per Forza';

  @override
  String get intensityZoneOptimalStrengthDesc =>
      'Il 50-70% delle serie sono ad alta intensità (RPE 8-10). Perfetto per guadagni di forza!';

  @override
  String get intensityZoneOptimalStrengthAdvice =>
      'Ottimo! Questa distribuzione massimizza i guadagni di forza. Considera deload ogni 4-6 settimane.';

  @override
  String get intensityZoneBalanced => 'Bilanciato';

  @override
  String get intensityZoneBalancedDesc =>
      'Buon mix di intensità. Adatto per progressi generali.';

  @override
  String get intensityZoneBalancedAdvice =>
      'Distribuzione equilibrata. Per ipertrofia, aumenta RPE 7-9. Per forza, aumenta RPE 8-10.';

  @override
  String get intensityZoneTooHard => 'Troppo Intenso';

  @override
  String get intensityZoneTooHardDesc =>
      'Oltre il 30% delle serie sono massimali (RPE 10). Rischio sovrallenamento e infortuni.';

  @override
  String get intensityZoneTooHardAdvice =>
      'Riduci intensità: max 20-30% serie a RPE 10. Aggiungi serie a RPE 7-8 per volume sostenibile.';

  @override
  String get rpeInfoTitle => 'RPE & Intensità';

  @override
  String get rpeInfoDescription =>
      'RPE (Rate of Perceived Exertion) è una scala di sforzo percepito 5-10:';

  @override
  String get rpeScale5_6 => 'RPE 5-6';

  @override
  String get rpeScale5_6Desc => 'Recovery - Facile';

  @override
  String get rpeScale7 => 'RPE 7';

  @override
  String get rpeScale7Desc => 'Moderate - 3 RIR';

  @override
  String get rpeScale8 => 'RPE 8';

  @override
  String get rpeScale8Desc => 'Hard - 2 RIR';

  @override
  String get rpeScale9 => 'RPE 9';

  @override
  String get rpeScale9Desc => 'Very Hard - 1 RIR';

  @override
  String get rpeScale10 => 'RPE 10';

  @override
  String get rpeScale10Desc => 'Maximal - 0 RIR';

  @override
  String get optimalDistribution =>
      'Distribuzione Ottimale (Helms et al. 2018):';

  @override
  String get hypertrophyDistribution => '• Ipertrofia: 60-80% serie a RPE 7-9';

  @override
  String get strengthDistribution => '• Forza: 50-70% serie a RPE 8-10';

  @override
  String get recoveryDistribution => '• Recovery: <50% serie a RPE 5-6';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get uncategorizedExercises => 'Esercizi Non Categorizzati';

  @override
  String get uncategorizedExercisesDesc =>
      'Questi esercizi hanno categoria \"altro\" o \"cardio\" e non vengono conteggiati nel volume. Tocca per assegnare il gruppo muscolare corretto.';

  @override
  String get categorizeExercise => 'Categorizza Esercizio';

  @override
  String get selectCorrectMuscleGroup =>
      'Seleziona il gruppo muscolare corretto:';

  @override
  String get chestMuscle => 'Petto';

  @override
  String get backMuscle => 'Schiena';

  @override
  String get shouldersMuscle => 'Spalle';

  @override
  String get armsMuscle => 'Braccia';

  @override
  String get legsMuscle => 'Gambe';

  @override
  String get coreMuscle => 'Core';

  @override
  String get cancelButton => 'Annulla';

  @override
  String remappingComingSoon(String exerciseName, String muscleGroup) {
    return 'Funzionalità in arrivo: salveremo \"$exerciseName\" come $muscleGroup';
  }

  @override
  String get setsPerWeek => 'serie/sett';

  @override
  String get unknownCategory => 'sconosciuto';

  @override
  String get watchAdForPremium => 'Guarda Ad per 24h Premium';

  @override
  String get premiumUnlockedFor24Hours => '🎉 Premium sbloccato per 24 ore!';

  @override
  String get adNotReady => 'Ad non pronto, riprova più tardi';

  @override
  String premiumActiveRemaining(String time) {
    return 'Premium attivo: $time rimanenti';
  }

  @override
  String get addTemporaryExercise => 'Aggiungi esercizio temporaneo';

  @override
  String get reportMissingExercise => 'Segnala esercizio mancante';

  @override
  String get temporaryExerciseAdded =>
      'Esercizio temporaneo aggiunto! Riceverai conferma presto.';

  @override
  String get enterExerciseName => 'Inserisci nome esercizio';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get pleaseEnterValidData => 'Inserisci dati validi';

  @override
  String get startRest => 'Inizia Riposo';

  @override
  String get restBetweenSets => 'Riposo tra Serie';

  @override
  String get completed => 'Completati';

  @override
  String get set => 'serie';

  @override
  String get complete => 'Completa';

  @override
  String get execute => 'Esegui';

  @override
  String get skipRest => 'Salta pausa';

  @override
  String get supersetCompleted => 'Superset Completato';

  @override
  String get greatJob => 'Ottimo lavoro!';

  @override
  String get cancelExercise => 'Annullare Esercizio?';

  @override
  String get cancelExerciseMessage =>
      'Sei sicuro di voler annullare? I tuoi progressi non verranno salvati.';

  @override
  String get dropsetTraining => 'Allenamento Dropset';

  @override
  String get dropsetDescription =>
      'Drop Set: Esegui l\'esercizio a cedimento, poi riduci immediatamente il peso e continua.';

  @override
  String get selectedExercise => 'Esercizio Selezionato';

  @override
  String get dropsetConfiguration => 'Configurazione Dropset';

  @override
  String get initialWeight => 'Peso Iniziale';

  @override
  String get selectWeight => 'Seleziona Peso';

  @override
  String get selectInitialWeight => 'Seleziona Peso Iniziale';

  @override
  String get selectTargetReps => 'Seleziona Ripetizioni Target';

  @override
  String get numberOfDrops => 'Numero di Drop';

  @override
  String get drops => 'drop';

  @override
  String get dropPercentage => 'Percentuale di Riduzione';

  @override
  String get dropStagesPreview => 'Anteprima Stadi Drop';

  @override
  String get mainSet => 'Serie Principale';

  @override
  String get drop => 'Drop';

  @override
  String get ofMax => 'del massimale';

  @override
  String get createDropset => 'Crea Dropset';

  @override
  String get pleaseSelectExerciseAndWeight =>
      'Seleziona un esercizio e imposta il peso iniziale';

  @override
  String get restPauseTraining => 'Allenamento Rest-Pause';

  @override
  String get restPauseDescription =>
      'Rest-Pause: Esegui a cedimento, riposa 10-15 secondi, ripeti fino al target di ripetizioni.';

  @override
  String get restPauseConfiguration => 'Configurazione Rest-Pause';

  @override
  String get pauseDuration => 'Durata Pausa';

  @override
  String get restPauseInstructions =>
      'Esegui la serie principale fino al cedimento, poi fai brevi pause e continua per mini-set aggiuntivi';

  @override
  String get createRestPause => 'Crea Rest-Pause';

  @override
  String get restPauseLabel => 'REST-PAUSE';

  @override
  String get restPauseMainSet => 'Serie Principale';

  @override
  String restPauseMiniSet(int index) {
    return 'Mini-Set $index';
  }

  @override
  String get miniSetProgress => 'Progresso Mini-Set';

  @override
  String get microPause => 'MICRO-PAUSA';

  @override
  String afterPauseDuration(int duration) {
    return 'Dopo ${duration}s di pausa';
  }

  @override
  String get rpeLabel => 'RPE Complessivo (Sforzo Percepito)';

  @override
  String get fitnessQuestionnaireTitle => 'Configurazione Profilo Fitness';

  @override
  String get fitnessQuestionnaireWelcomeTitle =>
      'Ottieni Suggerimenti di Peso Personalizzati';

  @override
  String get fitnessQuestionnaireWelcomeDescription =>
      'Rispondi ad alcune domande rapide per ricevere suggerimenti di peso iniziale basati su dati scientifici.';

  @override
  String get fitnessQuestionnaireWelcomeSkip => 'Salta per ora';

  @override
  String get fitnessQuestionnaireWelcomeStart => 'Inizia';

  @override
  String get fitnessQuestionnaireDemographicsTitle => 'Su di Te';

  @override
  String get fitnessQuestionnaireBodyweightLabel => 'Peso Corporeo Attuale';

  @override
  String get fitnessQuestionnaireBodyweightUnit => 'kg';

  @override
  String get fitnessQuestionnaireAgeLabel => 'Età';

  @override
  String get fitnessQuestionnaireSexLabel => 'Sesso Biologico';

  @override
  String get fitnessQuestionnaireSexMale => 'Uomo';

  @override
  String get fitnessQuestionnaireSexFemale => 'Donna';

  @override
  String get fitnessQuestionnaireExperienceTitle => 'Esperienza di Allenamento';

  @override
  String get fitnessQuestionnaireExperienceLevelLabel =>
      'Livello di Esperienza';

  @override
  String get fitnessQuestionnaireExperienceLevelUntrained => 'Principiante';

  @override
  String get fitnessQuestionnaireExperienceLevelNovice => 'Base';

  @override
  String get fitnessQuestionnaireExperienceLevelIntermediate => 'Intermedio';

  @override
  String get fitnessQuestionnaireExperienceLevelAdvanced => 'Avanzato';

  @override
  String get fitnessQuestionnaireExperienceLevelElite => 'Elite';

  @override
  String get fitnessQuestionnaireMonthsTrainingLabel =>
      'Mesi di allenamento costante (opzionale)';

  @override
  String get fitnessQuestionnaireMaxLiftsTitle => 'Massimali (Opzionale)';

  @override
  String get fitnessQuestionnaireMaxLiftsDescription =>
      'Inserire i tuoi massimali migliora l\'accuratezza dei suggerimenti. Puoi saltare se non li conosci.';

  @override
  String get fitnessQuestionnaireBenchPressLabel => 'Panca Piana 1RM';

  @override
  String get fitnessQuestionnaireSquatLabel => 'Squat 1RM';

  @override
  String get fitnessQuestionnaireDeadliftLabel => 'Stacco 1RM';

  @override
  String get fitnessQuestionnaireOhpLabel => 'Lento Avanti 1RM';

  @override
  String get fitnessQuestionnaireCalculateFrom => 'Calcola da ripetizioni';

  @override
  String get fitnessQuestionnaireGoalsTitle => 'Obiettivi e Preferenze';

  @override
  String get fitnessQuestionnaireTrainingGoalLabel => 'Obiettivo Principale';

  @override
  String get fitnessQuestionnaireTrainingGoalStrength => 'Forza (1-5 rip)';

  @override
  String get fitnessQuestionnaireTrainingGoalHypertrophy =>
      'Ipertrofia (8-12 rip)';

  @override
  String get fitnessQuestionnaireTrainingGoalEndurance =>
      'Resistenza (15+ rip)';

  @override
  String get fitnessQuestionnaireInjuryHistoryLabel =>
      'Ho avuto infortuni legati all\'allenamento';

  @override
  String get fitnessQuestionnaireSuggestionStyleLabel => 'Stile Suggerimenti';

  @override
  String get fitnessQuestionnaireSuggestionStyleConservative =>
      'Conservativo (più sicuro)';

  @override
  String get fitnessQuestionnaireSuggestionStyleBalanced =>
      'Bilanciato (consigliato)';

  @override
  String get fitnessQuestionnaireSuggestionStyleAggressive =>
      'Aggressivo (esperti)';

  @override
  String get fitnessQuestionnaireReviewTitle => 'Riepilogo e Completa';

  @override
  String get fitnessQuestionnaireReviewDescription =>
      'Rivedi le tue informazioni e completa la configurazione per ricevere suggerimenti di peso.';

  @override
  String get fitnessQuestionnaireComplete => 'Completa Configurazione';

  @override
  String get fitnessQuestionnaireBackButton => 'Indietro';

  @override
  String get fitnessQuestionnaireNextButton => 'Avanti';

  @override
  String get weightSuggestionSuggestedWeight => 'Suggerito';

  @override
  String get weightSuggestionUse => 'Usa Suggerimento';

  @override
  String get weightSuggestionConfidenceExcellent => 'Match eccellente';

  @override
  String get weightSuggestionConfidenceGood => 'Match buono';

  @override
  String get weightSuggestionConfidenceFair => 'Match discreto';

  @override
  String get weightSuggestionConfidenceLow => 'Bassa affidabilità';

  @override
  String get weightSuggestionWarningLow =>
      'Questo suggerimento ha bassa affidabilità. Inizia conservativo.';

  @override
  String get weightSuggestionNoData =>
      'Nessun suggerimento disponibile per questo esercizio';

  @override
  String get weightSuggestionCompleteQuestionnaire =>
      'Completa il profilo fitness per ricevere suggerimenti di peso';

  @override
  String get weightSuggestionBasedOn => 'Basato su strength standards';

  @override
  String get weightSuggestionViewDetails => 'Vedi Dettagli';

  @override
  String get weightSuggestionDetailsTitle => 'Dettagli Suggerimento Peso';

  @override
  String get weightSuggestionDetailsBaseOneRM => '1RM stimato';

  @override
  String get weightSuggestionDetailsIntensityFactor => 'Intensità obiettivo';

  @override
  String get weightSuggestionDetailsAppliedMultipliers =>
      'Aggiustamenti applicati';

  @override
  String get weightSuggestionDetailsNotes => 'Note importanti';

  @override
  String get oneRMCalculatorTitle => 'Calcolatore 1RM';

  @override
  String get oneRMCalculatorWeight => 'Peso sollevato';

  @override
  String get oneRMCalculatorReps => 'Ripetizioni completate';

  @override
  String get oneRMCalculatorEstimated => '1RM stimato';

  @override
  String get oneRMCalculatorFormula => 'Formula Brzycki';

  @override
  String get oneRMCalculatorUse => 'Usa Questo Valore';

  @override
  String get step => 'Passo';

  @override
  String get ofPreposition => 'di';

  @override
  String get fitnessBenchmarkCalculate => 'Calcola il Tuo Livello';

  @override
  String get fitnessBenchmarkUpdate => 'Aggiorna Benchmark';

  @override
  String get fitnessBenchmarkLevel => 'Livello';

  @override
  String get fitnessBenchmarkDescription =>
      'Ricevi suggerimenti di peso personalizzati';

  @override
  String get fitnessQuestionnaireFullyRecovered => 'Completamente Recuperato';

  @override
  String get fitnessQuestionnaireInRehabilitation =>
      'Attualmente in Riabilitazione';

  @override
  String get fitnessQuestionnaireCurrentPainLevel =>
      'Livello di Dolore Attuale';

  @override
  String get fitnessQuestionnaireMonthsHelperText =>
      'Opzionale - aiuta a validare il livello di esperienza';

  @override
  String get fitnessQuestionnaireReviewDemographics => 'Dati Anagrafici';

  @override
  String get fitnessQuestionnaireReviewExperience => 'Esperienza';

  @override
  String get fitnessQuestionnaireReviewMaxLifts => 'Massimali';

  @override
  String get fitnessQuestionnaireReviewGoals => 'Obiettivi';

  @override
  String get fitnessQuestionnaireReviewBodyweight => 'Peso Corporeo';

  @override
  String get fitnessQuestionnaireReviewAge => 'Età';

  @override
  String get fitnessQuestionnaireReviewSex => 'Sesso';

  @override
  String get fitnessQuestionnaireReviewLevel => 'Livello';

  @override
  String get fitnessQuestionnaireReviewTraining => 'Allenamento';

  @override
  String get fitnessQuestionnaireReviewMonths => 'mesi';

  @override
  String get fitnessQuestionnaireReviewBench => 'Panca';

  @override
  String get fitnessQuestionnaireReviewSquat => 'Squat';

  @override
  String get fitnessQuestionnaireReviewDeadlift => 'Stacco';

  @override
  String get fitnessQuestionnaireReviewOHP => 'Military';

  @override
  String get fitnessQuestionnaireReviewTrainingGoal => 'Obiettivo';

  @override
  String get fitnessQuestionnaireReviewSuggestionStyle => 'Stile Suggerimenti';

  @override
  String get fitnessQuestionnaireReviewSelfAssessment => 'Auto-valutazione';

  @override
  String get fitnessQuestionnaireSelfAssessmentTitle =>
      'Calibrazione Auto-valutazione';

  @override
  String get fitnessQuestionnaireSelfAssessmentDescription =>
      'Quanto sei preciso nel valutare le tue abilità?';

  @override
  String get fitnessMedicalClearanceTitle => 'Idoneità Medica (PAR-Q+)';

  @override
  String get fitnessMedicalClearanceDescription =>
      'Rispondi onestamente a queste domande di screening sanitario.';

  @override
  String get fitnessParqHeartCondition =>
      'Un medico ti ha mai detto che hai una condizione cardiaca?';

  @override
  String get fitnessParqChestPainActive =>
      'Senti dolore al petto durante l\'attività fisica?';

  @override
  String get fitnessParqChestPainRest =>
      'Nell\'ultimo mese, hai avuto dolore al petto quando NON facevi attività fisica?';

  @override
  String get fitnessParqDizziness =>
      'Perdi l\'equilibrio a causa di vertigini o perdi mai conoscenza?';

  @override
  String get fitnessParqBoneJoint =>
      'Hai un problema osseo o articolare che potrebbe peggiorare con l\'attività?';

  @override
  String get fitnessParqMedication =>
      'Stai attualmente assumendo farmaci per la pressione o per il cuore?';

  @override
  String get fitnessParqOtherReason =>
      'Conosci qualche altro motivo per cui non dovresti fare attività fisica?';

  @override
  String get fitnessAcsmTitle => 'Fattori di Rischio Aggiuntivi (ACSM)';

  @override
  String get fitnessAcsmAge => 'Età ≥45 (uomini) o ≥55 (donne)';

  @override
  String get fitnessAcsmFamilyHistory =>
      'Storia familiare di malattie cardiache prima dei 55 anni';

  @override
  String get fitnessAcsmSmoker => 'Fumatore attuale o smesso da meno di 6 mesi';

  @override
  String get fitnessAcsmObese =>
      'BMI ≥30 o vita >102cm (uomini) / >88cm (donne)';

  @override
  String get fitnessAcsmDiabetes => 'Diabete (Tipo 1 o 2)';

  @override
  String get fitnessAcsmHighBP => 'Pressione alta (≥140/90 o in terapia)';

  @override
  String get fitnessValidationWeight => 'Inserisci un peso valido (40-200 kg)';

  @override
  String get fitnessValidationAge => 'Inserisci un\'età valida (13-100)';

  @override
  String get fitnessInjuryHistoryTitle => 'Storico Infortuni';

  @override
  String get fitnessInjuryType => 'Tipo di Infortunio';

  @override
  String get fitnessInjuryBodyRegion => 'Zona del Corpo';

  @override
  String get fitnessInjuryMonthsSince => 'Mesi dall\'Infortunio';

  @override
  String get fitnessValidationRequired => 'Obbligatorio';

  @override
  String get fitnessInjuryTypeHint => 'es. Stiramento lombare';

  @override
  String get dropsetStage1Weight => 'Peso Stadio 1';

  @override
  String dropsetStageNWeight(int stageNumber) {
    return 'Peso Stadio $stageNumber';
  }

  @override
  String get previousStageWeight => 'Stadio precedente';

  @override
  String get detectedEquipmentType => 'Attrezzatura rilevata';

  @override
  String get barbell => 'Bilanciere';

  @override
  String get dumbbell => 'Manubrio';

  @override
  String get barbellRoundingInfo => 'Arrotonda a 2.5kg';

  @override
  String get dumbbellRoundingInfo => 'Incrementi personalizzati';

  @override
  String get selectEquipmentType => 'Seleziona Tipo Attrezzatura';

  @override
  String get selectWeightDrop => 'Seleziona Riduzione Peso';

  @override
  String get calculatedWeight => 'Peso Calcolato';

  @override
  String get dumbbellIncrementQuestion =>
      'Che incrementi di manubri ha la tua palestra?';

  @override
  String get dumbbellIncrementHalfKg =>
      'Incrementi da 0.5kg (17.5, 18, 18.5...)';

  @override
  String get dumbbellIncrementOneKg => 'Incrementi da 1kg (17, 18, 19...)';

  @override
  String get dumbbellIncrementTwoKg => 'Incrementi da 2kg (16, 18, 20...)';

  @override
  String get enterInitialWeight => 'Inserisci Peso Iniziale';

  @override
  String get confirmOrAdjustWeight => 'Conferma o Modifica Peso';

  @override
  String get appSubtitle => 'Traccia il tuo percorso fitness';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Inserisci la tua email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Inserisci la tua password';

  @override
  String get confirmPasswordLabel => 'Conferma Password';

  @override
  String get confirmPasswordHint => 'Conferma la tua password';

  @override
  String get fullNameLabel => 'Nome Completo';

  @override
  String get fullNameHint => 'Inserisci il tuo nome completo';

  @override
  String get signInButton => 'Accedi';

  @override
  String get signUpButton => 'Registrati';

  @override
  String get createAccountButton => 'Crea Account';

  @override
  String get createAccountTitle => 'Crea Account';

  @override
  String get joinGymBro => 'Unisciti a FitLog Pro';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get signInWithApple => 'Accedi con Apple';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get signInWithEmail => 'Accedi con Email';

  @override
  String get backToLogin => 'Torna al Login';

  @override
  String get pleaseEnterEmailFirst => 'Inserisci prima la tua email';

  @override
  String get passwordResetEmailSent =>
      'Email di reset password inviata! Controlla la tua casella.';

  @override
  String get restTimer => 'Timer Riposo';

  @override
  String get errorDialogTitle => 'Errore';

  @override
  String get workoutLoadError =>
      'Si è verificato un errore durante il caricamento dell\'allenamento';

  @override
  String get goHomeButton => 'Vai alla Home';

  @override
  String get createNewTemplate => 'Crea Nuovo Template';

  @override
  String get saveTemplateComingSoon => 'Funzione salva template in arrivo!';

  @override
  String get saveToFirebase => 'Salva su Firebase per riutilizzarlo';

  @override
  String get useTemplateScreenForImport =>
      'Usa la funzione di importazione nella schermata template';

  @override
  String get keepWorkoutActiveTitle => 'Mantenere Allenamento Attivo?';

  @override
  String get workoutPausedMessage =>
      'Allenamento in pausa - Continua quando vuoi dalla Home';

  @override
  String get completeWorkoutTitle => 'Completa Allenamento';

  @override
  String get completeWorkoutConfirmation =>
      'Sei sicuro di voler completare questo allenamento?';

  @override
  String get completeButton => 'Completa';

  @override
  String get workoutCompletedSuccess =>
      'Allenamento completato! Ottimo lavoro!';

  @override
  String get workoutResumed =>
      'Allenamento ripristinato - puoi continuare ad allenarti';

  @override
  String get saveAsTemplate => 'Salva come Template';

  @override
  String get signOutButton => 'Esci';

  @override
  String get addExerciseTitle => 'Aggiungi Esercizio';

  @override
  String get addButton => 'Aggiungi';

  @override
  String get supersetTab => 'Superset';

  @override
  String get dropsetTab => 'Dropset';

  @override
  String get restPauseTab => 'Rest-Pause';

  @override
  String get exerciseCategoryLabel => 'Categoria Esercizio';

  @override
  String get setsLabel => 'Serie';

  @override
  String get addSetButton => 'Aggiungi Serie';

  @override
  String get removeSetTooltip => 'Rimuovi Serie';

  @override
  String get weightHint => 'Inserisci peso';

  @override
  String get repsHint => 'Inserisci ripetizioni';

  @override
  String get notesLabel => 'Note (opzionale)';

  @override
  String exerciseAddedMessage(String exerciseName) {
    return 'Aggiunto $exerciseName all\'allenamento';
  }

  @override
  String dropsetAddedMessage(String exerciseName) {
    return 'Aggiunto $exerciseName Drop Set all\'allenamento';
  }

  @override
  String restPauseAddedMessage(String exerciseName) {
    return 'Aggiunto $exerciseName Rest-Pause all\'allenamento';
  }

  @override
  String supersetAddedMessage(String exerciseName) {
    return 'Aggiunto $exerciseName Superset all\'allenamento';
  }

  @override
  String get categoryChest => 'Petto';

  @override
  String get categoryBack => 'Dorso';

  @override
  String get categoryShoulders => 'Spalle';

  @override
  String get categoryArms => 'Braccia';

  @override
  String get categoryLegs => 'Gambe';

  @override
  String get categoryAbs => 'Addominali';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryOther => 'Altro';

  @override
  String exerciseCategorizedSuccess(
    String exerciseName,
    String muscleGroupName,
  ) {
    return '\"$exerciseName\" categorizzato come $muscleGroupName';
  }

  @override
  String get undo => 'Annulla';

  @override
  String get categorizationUndone => 'Categorizzazione rimossa';

  @override
  String get exerciseEditingComingSoon => 'Modifica esercizio in arrivo!';

  @override
  String get exerciseReplacementComingSoon =>
      'Sostituzione esercizio in arrivo!';

  @override
  String get errorUserNotAuthenticated => 'Utente non autenticato';

  @override
  String get errorEntityValidationFailed => 'Validazione fallita';

  @override
  String get errorAudioFileNotFound => 'File audio non trovato';

  @override
  String get errorAchievementNotFound => 'Achievement non trovato';

  @override
  String get errorRegistrationFailed => 'Registrazione fallita';

  @override
  String get errorSignInFailed => 'Accesso fallito';

  @override
  String errorLoadingWorkout(String error) {
    return 'Errore caricamento allenamento: $error';
  }

  @override
  String get orSeparator => 'OPPURE';

  @override
  String get alreadyHaveAccount => 'Hai già un account?';

  @override
  String get dontHaveAccount => 'Non hai un account?';

  @override
  String get backToOptions => 'Torna alle opzioni';

  @override
  String get pleaseEnterEmail => 'Inserisci la tua email';

  @override
  String get pleaseEnterValidEmail => 'Inserisci un\'email valida';

  @override
  String get pleaseEnterPassword => 'Inserisci la tua password';

  @override
  String get featureSmartTimer => 'Timer Intelligente';

  @override
  String get featureLiveActivities => 'Live Activities';

  @override
  String get featureAppleHealth => 'Apple Health';

  @override
  String get createAccount => 'Crea Account';

  @override
  String get startTrackingJourney =>
      'Inizia a tracciare il tuo percorso fitness';

  @override
  String get registerQuickly => 'Registrati Velocemente';

  @override
  String get autoAccountCreation =>
      'Il sistema creerà automaticamente il tuo account\nse è la prima volta che accedi';

  @override
  String get orDivider => 'OPPURE';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get enterYourName => 'Inserisci il tuo nome';

  @override
  String get nameRequired => 'Inserisci il tuo nome';

  @override
  String get nameMinLength => 'Il nome deve contenere almeno 2 caratteri';

  @override
  String get emailRequired => 'Inserisci la tua email';

  @override
  String get emailInvalid => 'Inserisci un\'email valida';

  @override
  String get passwordRequired => 'Inserisci una password';

  @override
  String get passwordMinLength =>
      'La password deve contenere almeno 6 caratteri';

  @override
  String get confirmPassword => 'Conferma Password';

  @override
  String get confirmPasswordRequired => 'Conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get signUpWithGoogle => 'Registrati con Google';

  @override
  String get signUpWithApple => 'Registrati con Apple';

  @override
  String get alreadyHaveAccountPrompt => 'Hai già un account? ';

  @override
  String get myWorkouts => 'Le Mie Schede';

  @override
  String get predefinedWorkouts => 'Schede Predefinite';

  @override
  String get noCustomTemplates => 'Nessun template personalizzato';

  @override
  String get noPredefinedWorkouts => 'Nessuna scheda predefinita';

  @override
  String get predefinedWorkoutsComingSoon =>
      'Le schede predefinite arriveranno presto!';

  @override
  String get customBadge => 'Personalizzato';

  @override
  String get keepWorkoutActive => 'Mantieni Allenamento Attivo?';

  @override
  String get keepWorkoutActiveMessage =>
      'Vuoi tornare alla Home e mantenere il tuo allenamento attivo in background?\\n\\nPotrai tornare a continuare l\'allenamento in qualsiasi momento.';

  @override
  String get goToHome => 'Vai alla Home';

  @override
  String get workoutPausedContinue =>
      'Allenamento in pausa - Continua quando vuoi dalla Home';

  @override
  String deleteTemplateConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get deleteTemplateWarning => 'Questa azione non può essere annullata.';

  @override
  String get timerRest => 'Timer Riposo';

  @override
  String get rpeTimerMore => 'RPE, Timer, e altro';

  @override
  String get completeWorkoutConfirm =>
      'Sei sicuro di voler completare questo allenamento?';

  @override
  String get error => 'Errore';

  @override
  String get goHome => 'Vai alla Home';

  @override
  String errorLoading(String error) {
    return 'Errore caricamento: $error';
  }

  @override
  String get jsonFormat => 'Formato JSON';

  @override
  String get pasteJsonHere =>
      'Incolla qui il JSON del tuo template di allenamento';

  @override
  String get jsonPlaceholder => 'Esempio: nome, descrizione, array di esercizi';

  @override
  String get useImportFunction =>
      'Usa la funzione import nella schermata template';

  @override
  String get saveAsTemplateTitle => 'Salva come Template';

  @override
  String get templateName => 'Nome Template';

  @override
  String get templateNameHint => 'Es: Push Day, Upper Body...';

  @override
  String get descriptionHint => 'Descrivi brevemente questo workout...';

  @override
  String get templateSyncInfo =>
      'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi';

  @override
  String get enterTemplateName => 'Inserisci un nome per il template';

  @override
  String get savingToFirebase => 'Salvataggio su Firebase...';

  @override
  String templateSavedSuccess(String name) {
    return 'Template \"$name\" salvato con successo!';
  }

  @override
  String get view => 'Visualizza';

  @override
  String templateLimitReached(int max) {
    return 'Hai raggiunto il limite di $max template privati.';
  }

  @override
  String get deleteOrUpgrade =>
      'Elimina un template esistente o passa a Premium per avere più spazio.';

  @override
  String templatesRemaining(int remaining) {
    return 'Solo $remaining template rimanenti nel piano Free';
  }

  @override
  String get customTemplate => 'Template personalizzato';

  @override
  String errorSaving(String error) {
    return 'Errore nel salvataggio: $error';
  }

  @override
  String get quotaExceeded => 'Limite Raggiunto';

  @override
  String get deleteExistingOrUpgrade =>
      'Elimina template esistenti o passa a Premium.';

  @override
  String get generatingPdf => 'Generazione PDF...';

  @override
  String get pdfSharedSuccess => 'PDF condiviso con successo!';

  @override
  String sharingError(String error) {
    return 'Errore nella condivisione: $error';
  }

  @override
  String get preparingPrint => 'Preparazione stampa...';

  @override
  String printError(String error) {
    return 'Errore nella stampa: $error';
  }

  @override
  String get templateUseFunctionComingSoon =>
      'Usa la schermata template per creare nuovi template';

  @override
  String get saveTemplateFunctionComingSoon =>
      'Funzione salva template in arrivo!';

  @override
  String get workoutStartedQuick => 'Allenamento avviato velocemente';

  @override
  String get quickWorkoutName => 'Allenamento Veloce';

  @override
  String get startWorkoutTitle => 'Avvia Allenamento';

  @override
  String get startNowAction => 'Inizia Ora';

  @override
  String get startExercise => 'Avvia Esercizio';

  @override
  String get modifyTemplate => 'Modifica Template';

  @override
  String get addOrRemoveExercises => 'Aggiungi o rimuovi esercizi';

  @override
  String get deleteTemplateAction => 'Elimina Template';

  @override
  String get removePermanently => 'Rimuovi definitivamente';

  @override
  String dropsetStages(int count) {
    return '$count stadi';
  }

  @override
  String dropsetStage(int number) {
    return 'Stadio $number';
  }

  @override
  String get dropsetGetReady => 'Preparati a ridurre il peso!';

  @override
  String get dropsetNoRest => 'Nessun riposo! Riduci il peso e vai di nuovo!';

  @override
  String get dropsetLastStage => 'Ultimo stadio! Dai tutto quello che hai!';

  @override
  String dropsetReduceWeightNow(String weight) {
    return 'Riduci il peso a $weight kg ORA!';
  }

  @override
  String get dropsetCompleted => 'DropSet completato! 💪';

  @override
  String get completeDropset => 'Completa DropSet';

  @override
  String completeStage(int number) {
    return 'Completa Stadio $number';
  }

  @override
  String get cancelDropset => 'Annullare DropSet?';

  @override
  String get cancelDropsetMessage =>
      'Il tuo progresso non sarà salvato. Sei sicuro?';

  @override
  String get executeDropset => 'Esegui DropSet';

  @override
  String get executeRestPause => 'Esegui Rest-Pause';

  @override
  String get keepWorkoutActiveContent =>
      'Vuoi tornare alla Home e mantenere il tuo allenamento attivo in background?\\n\\nPotrai tornare a continuare l\'allenamento in qualsiasi momento.';

  @override
  String deleteTemplateQuestion(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get cannotUndo => 'Questa azione non può essere annullata.';

  @override
  String errorLabel(String error) {
    return 'Errore: $error';
  }

  @override
  String templateQuotaLimit(int max) {
    return 'Hai raggiunto il limite di $max template privati.';
  }

  @override
  String get deleteExistingTemplateOrUpgrade =>
      'Elimina un template esistente o passa a Premium per avere più spazio.';

  @override
  String templatesRemainingWarning(int remaining) {
    return 'Solo $remaining template rimanenti nel piano Free';
  }

  @override
  String get customTemplateDescription => 'Template personalizzato';

  @override
  String templateSavedSuccessfully(String name) {
    return 'Template \"$name\" salvato con successo!';
  }

  @override
  String templateDeletedSuccessfully(String name) {
    return 'Template \"$name\" eliminato';
  }

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get pdfSharedSuccessfully => 'PDF condiviso con successo!';

  @override
  String sharingErrorMessage(String error) {
    return 'Errore nella condivisione: $error';
  }

  @override
  String printErrorMessage(String error) {
    return 'Errore nella stampa: $error';
  }

  @override
  String savingErrorMessage(String error) {
    return 'Errore nel salvataggio: $error';
  }

  @override
  String get useImportFunctionInTemplateScreen =>
      'Usa la funzione import nella schermata template';

  @override
  String get deleteExistingOrUpgradeToPremium =>
      'Elimina template esistenti o passa a Premium.';

  @override
  String get removePermanentlyAction => 'Rimuovi definitivamente';

  @override
  String get startWorkoutAction => 'Avvia Allenamento';

  @override
  String get startWorkoutDescription => 'Inizia immediatamente';

  @override
  String get templateSyncInformation =>
      'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi';

  @override
  String get tabSingle => 'Singolo';

  @override
  String get tabAdvanced => 'Avanzati';

  @override
  String get tabSuperset => 'Superset';

  @override
  String get tabDropSet => 'DropSet';

  @override
  String get tabRestPause => 'Rest-Pause';

  @override
  String get dropSetInfoCard =>
      'Drop Set: Esegui l\'esercizio fino al cedimento, poi riduci immediatamente il peso e continua.';

  @override
  String get restPauseInfoCard =>
      'Rest-Pause: Esegui fino al cedimento, riposa 10-15 secondi, ripeti fino alle ripetizioni target.';

  @override
  String get exerciseNameHintBicepCurl => 'es. Curl Bicipiti Drop Set';

  @override
  String get exerciseNameHintBenchPress => 'es. Panca Piana Rest-Pause';

  @override
  String get dropSetStagesTitle => 'Fasi Drop Set';

  @override
  String get stageHeavy => 'Fase 1 (Pesante)';

  @override
  String get stageMedium => 'Fase 2 (Medio)';

  @override
  String get stageLight => 'Fase 3 (Leggero)';

  @override
  String get addStageButton => 'Aggiungi Fase';

  @override
  String get notesHintWeightDrops => 'Calo pesi, riposo tra fasi, ecc.';

  @override
  String get notesHintFormCues =>
      'Indicazioni sulla forma, strategia di progressione, ecc.';

  @override
  String get weightKgLabel => 'Peso (kg)';

  @override
  String get targetRepsLabel => 'Ripetizioni Target';

  @override
  String get restPeriodSecondsLabel => 'Periodo di Riposo (secondi)';

  @override
  String get restPeriodSecondsHint => '10-15 secondi tipico';

  @override
  String get maxRestPauseSetsLabel => 'Massimo Serie Rest-Pause';

  @override
  String get maxRestPauseSetsHint => '3-4 tipico';

  @override
  String get addSetLabel => 'Aggiungi Serie';

  @override
  String get weightHintKg => 'Peso (kg)';

  @override
  String get repsHintLabel => 'Reps';

  @override
  String get customExercisePrompt =>
      'Non trovi l\'esercizio? Creane uno personalizzato';

  @override
  String get customExerciseDetails =>
      'Inserisci i dettagli dell\'esercizio personalizzato:';

  @override
  String get focusLabel => 'Focus';

  @override
  String exerciseAddedToWorkout(String exerciseName) {
    return 'Aggiunto $exerciseName all\'allenamento';
  }

  @override
  String exerciseAddedDropSet(String exerciseName) {
    return 'Aggiunto $exerciseName Drop Set all\'allenamento';
  }

  @override
  String exerciseAddedRestPause(String exerciseName) {
    return 'Aggiunto $exerciseName Rest-Pause all\'allenamento';
  }

  @override
  String get quickTimerOptions => 'Opzioni Timer Rapide';

  @override
  String exerciseUpdated(String exerciseName) {
    return 'Esercizio \"$exerciseName\" aggiornato';
  }

  @override
  String get timerLabel => 'Timer';

  @override
  String get errorLoadingEditor =>
      'Errore nel caricamento dell\'editor esercizi';

  @override
  String get errorOpeningEditor =>
      'Errore nell\'apertura dell\'editor esercizi. Riprova.';

  @override
  String get errorUnableToEdit =>
      'Errore: Impossibile modificare questo esercizio';

  @override
  String get errorUpdatingExercise =>
      'Errore nell\'aggiornamento dell\'esercizio. Riprova.';

  @override
  String exerciseNameCannotBeEmpty(String exerciseName) {
    return '$exerciseName non può essere vuoto';
  }

  @override
  String get invalidRestTimeError =>
      'Inserisci un tempo di riposo valido (1-3600 secondi)';

  @override
  String get invalidApreBaseWeight => 'Inserisci un peso base APRE valido';

  @override
  String get notesSavedMessage => 'Note salvate';

  @override
  String exerciseCompletedTapToExpand(String exerciseName) {
    return '$exerciseName completato! Tocca per espandere';
  }

  @override
  String get expandLabel => 'Espandi';

  @override
  String get settingsNotLoggedIn => 'Non loggato';

  @override
  String get settingsLoading => 'Caricamento...';

  @override
  String get settingsErrorLoadingUser => 'Errore caricamento utente';

  @override
  String get settingsGymBroUser => 'Utente FitLog Pro';

  @override
  String get settingsNoEmail => 'Nessuna email';

  @override
  String settingsLastUpdated(Object date) {
    return 'Ultimo aggiornamento: $date';
  }

  @override
  String get settingsUpdateProfile => 'Aggiorna Profilo';

  @override
  String get settingsAccentColor => 'Colore Accento';

  @override
  String get settingsFontSize => 'Dimensione Carattere';

  @override
  String get settingsFontSizeSmall => 'Piccolo';

  @override
  String get settingsFontSizeNormal => 'Normale';

  @override
  String get settingsFontSizeLarge => 'Grande';

  @override
  String get settingsWorkoutTitle => 'Allenamento';

  @override
  String get settingsAutoStartTimer => 'Timer Automatico';

  @override
  String get settingsAutoStartTimerDesc =>
      'Avvia timer di riposo dopo aver completato una serie';

  @override
  String get settingsDefaultRestTime => 'Tempo Riposo Predefinito';

  @override
  String get settingsAdvancedTechniques => 'Tecniche Avanzate';

  @override
  String get settingsAdvancedTechniquesDesc =>
      'Mostra drop set, superset, ecc.';

  @override
  String get settingsUnitsLanguage => 'Unità e Lingua';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsWeightUnits => 'Unità di Peso';

  @override
  String get settingsIOSFeatures => 'Funzioni iOS';

  @override
  String get settingsLiveActivities => 'Live Activities';

  @override
  String get settingsLiveActivitiesDesc =>
      'Mostra timer su schermata di blocco e Dynamic Island';

  @override
  String get settingsHealthAppSync => 'Sincronizzazione Health';

  @override
  String get settingsHealthAppSyncDesc =>
      'Sincronizza allenamenti con Apple Health';

  @override
  String get settingsAudioFeedback => 'Audio e Feedback';

  @override
  String get settingsSoundEffects => 'Effetti Sonori';

  @override
  String get settingsSoundEffectsDesc =>
      'Riproduci suoni per timer e completamento';

  @override
  String get settingsVibrations => 'Vibrazioni';

  @override
  String get settingsVibrationsDesc => 'Feedback aptico per le interazioni';

  @override
  String get settingsTestSounds => 'Testa Suoni';

  @override
  String get settingsAdvancedTitle => 'Avanzate';

  @override
  String get settingsExportSettings => 'Esporta Impostazioni';

  @override
  String get settingsImportSettings => 'Importa Impostazioni';

  @override
  String get settingsResetTimerPosition => 'Ripristina Posizione Timer';

  @override
  String get settingsResetTimerPositionDesc =>
      'Ripristina timer trascinabile alla posizione predefinita';

  @override
  String get settingsDataMigrationCompleted =>
      'Migrazione completata o non necessaria';

  @override
  String get settingsMigrationHasData =>
      'Hai dati da migrare dalla versione precedente';

  @override
  String get settingsMigrationAvailable => 'Disponibile';

  @override
  String get settingsBetaMode => 'Modalità Beta';

  @override
  String get settingsBetaModeEnabled =>
      'Modalità Beta abilitata - Tutte le funzioni premium sbloccate!';

  @override
  String get settingsBetaModeDisabled => 'Modalità Beta disabilitata';

  @override
  String get settingsBetaModeLabel => 'BETA';

  @override
  String get settingsBetaModeActivated =>
      '🧪 Modalità Beta attivata - Tutte le funzionalità premium sbloccate!';

  @override
  String get settingsBetaModeDeactivated => 'Modalità Beta disattivata';

  @override
  String get settingsResetToDefaults => 'Ripristina Predefiniti';

  @override
  String get settingsAccountActionsTitle => 'Azioni Account';

  @override
  String get settingsSignOut => 'Disconnetti';

  @override
  String get settingsChooseLanguage => 'Scegli Lingua';

  @override
  String get settingsEnglishUS => 'Inglese (US)';

  @override
  String get settingsItalianIT => 'Italiano (IT)';

  @override
  String get settingsWeightUnitsTitle => 'Unità di Peso';

  @override
  String get settingsKilogramsKg => 'Chilogrammi (kg)';

  @override
  String get settingsMetricSystem => 'Sistema metrico';

  @override
  String get settingsPoundsLbs => 'Libbre (lbs)';

  @override
  String get settingsImperialSystem => 'Sistema imperiale';

  @override
  String get settingsResetTimerPositionTitle => 'Ripristina Posizione Timer';

  @override
  String get settingsResetTimerPositionMessage =>
      'Questo ripristinerà il timer trascinabile alla posizione predefinita. Utile se il timer è bloccato fuori schermo.';

  @override
  String get settingsResetPosition => 'Ripristina Posizione';

  @override
  String get settingsTimerPositionReset => 'Posizione timer ripristinata';

  @override
  String get settingsResetSettingsTitle => 'Ripristina Impostazioni';

  @override
  String get settingsResetSettingsMessage =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get settingsResetSettingsButton => 'Ripristina';

  @override
  String get settingsSignOutTitle => 'Disconnetti';

  @override
  String get settingsSignOutMessage => 'Sei sicuro di voler disconnetterti?';

  @override
  String get settingsExportComingSoon => 'Funzione di esportazione in arrivo';

  @override
  String get settingsImportComingSoon => 'Funzione di importazione in arrivo';

  @override
  String get templateSearchPlaceholder => 'Cerca template...';

  @override
  String get templateDebugNotSeeing =>
      '❌ WorkoutTemplatesScreen - Qui NON VEDO i miei template';

  @override
  String get templateTemplatesCount => 'Template';

  @override
  String get templateNoTemplatesYet => 'Nessun template popolare ancora';

  @override
  String get templateMostUsedTemplatesWillAppear =>
      'I template più utilizzati appariranno qui';

  @override
  String get templateNoCustomTemplates => 'Nessun template personalizzato';

  @override
  String get templateCreateFirstTemplate =>
      'Crea il tuo primo template personalizzato';

  @override
  String get templateNoTemplatesFound => 'Nessun template trovato';

  @override
  String get templateSyncStateTitle => 'Stato Sincronizzazione';

  @override
  String get templateSyncStatus => 'Stato';

  @override
  String get templateLastSync => 'Ultima sincronizzazione';

  @override
  String get templateTotalTemplates => 'Template totali';

  @override
  String get templateOfflineChanges =>
      'Hai modifiche offline che verranno sincronizzate alla prossima connessione.';

  @override
  String get templateSyncNow => 'Sincronizza Ora';

  @override
  String get templateSyncCompleted => 'Sincronizzazione completata';

  @override
  String get templateDeleteTitle => 'Elimina Template';

  @override
  String templateDeleteMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get templateDeleteButton => 'Elimina';

  @override
  String get templateDeleteError =>
      'Errore durante l\'eliminazione del template';

  @override
  String get templateStartError => 'Errore nell\'avvio del workout';

  @override
  String get templateDay => 'Day';

  @override
  String get copyPreviousSet => 'Copia Set Precedente';

  @override
  String get routineWeeklyRoutine => 'Routine Settimanale';

  @override
  String get routineMyRoutine => 'La Mia Routine';

  @override
  String get routineAddToRoutine => 'Aggiungi alla Routine';

  @override
  String get routineSelectDay => 'Seleziona Giorno';

  @override
  String get routineSelectDaySubtitle =>
      'Scegli in quale giorno/i programmare questo allenamento';

  @override
  String get routineMonday => 'Lunedì';

  @override
  String get routineTuesday => 'Martedì';

  @override
  String get routineWednesday => 'Mercoledì';

  @override
  String get routineThursday => 'Giovedì';

  @override
  String get routineFriday => 'Venerdì';

  @override
  String get routineSaturday => 'Sabato';

  @override
  String get routineSunday => 'Domenica';

  @override
  String get routineDayAlreadyScheduled =>
      'Questo giorno ha già un template programmato';

  @override
  String get routineReplaceTemplate => 'Sostituire il template?';

  @override
  String routineReplaceTemplateMessage(
    String day,
    String currentTemplate,
    String newTemplate,
  ) {
    return '$day ha già \"$currentTemplate\" programmato. Sostituire con \"$newTemplate\"?';
  }

  @override
  String get routineNoTemplateScheduled => 'Nessun template programmato';

  @override
  String get routineRestDay => 'Giorno di Riposo';

  @override
  String get routineQuickStart => 'Avvio Rapido';

  @override
  String routineTemplateAddedSuccess(String day) {
    return 'Template aggiunto a $day';
  }

  @override
  String get routineNoWorkoutsScheduled => 'Nessun allenamento programmato';

  @override
  String get routineStartScheduling =>
      'Inizia a programmare i tuoi allenamenti settimanali';

  @override
  String get routineTapToAdd =>
      'Tocca un template e seleziona \'Aggiungi alla Routine\'';

  @override
  String get routineChangeTemplate => 'Cambia Template Allenamento';

  @override
  String get routineRemoveFromDay => 'Rimuovi dal giorno';

  @override
  String get routineClearAllDays => 'Cancella Tutti i Giorni';

  @override
  String get routineClearAllDaysConfirm =>
      'Sei sicuro di voler cancellare tutti i template programmati?';

  @override
  String routineWorkoutsScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'allenamenti',
      one: 'allenamento',
    );
    return '$count $_temp0 programmati';
  }

  @override
  String routineRestDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni di riposo',
      one: 'giorno di riposo',
    );
    return '$count $_temp0';
  }

  @override
  String routineExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'esercizi',
      one: 'esercizio',
    );
    return '$count $_temp0';
  }

  @override
  String get routineSaveChanges => 'Salva Modifiche';

  @override
  String get routineDiscardChanges => 'Annulla Modifiche';

  @override
  String get routineViewAndManage => 'Visualizza e gestisci la tua routine';

  @override
  String get feedbackQuestion =>
      'Valuta la tua esperienza con questo passaggio';

  @override
  String get feedbackHelpful => 'Utile';

  @override
  String get feedbackNotHelpful => 'Non Utile';

  @override
  String get feedbackThankYou => 'Grazie per il tuo feedback!';

  @override
  String get feedbackSubmitted => 'Feedback inviato';

  @override
  String get feedbackAlreadyGiven => 'Hai già valutato questo insight';

  @override
  String get dataQualityWarning => '⚠️ Basato su dati dubbi';

  @override
  String get dataQualityLow => 'Qualità dati bassa';

  @override
  String anomaliesDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problemi nei dati rilevati',
      one: '1 problema nei dati rilevato',
    );
    return '$_temp0';
  }

  @override
  String get viewAnomalies => 'Vedi problemi dati';

  @override
  String get anomalyImpossibleWeight => 'Peso impossibile rilevato';

  @override
  String get anomalyExtremeWeightJump => 'Salto di peso estremo rilevato';

  @override
  String get anomalyNegativeValues => 'Valori negativi rilevati';

  @override
  String get anomalyFutureDate => 'Data futura rilevata';

  @override
  String get correctData => 'Correggi dati';

  @override
  String get dismissAnomaly => 'Ignora';

  @override
  String get myFeedback => 'I Miei Feedback';

  @override
  String get feedbackHistory => 'Storico Feedback';

  @override
  String get viewMyFeedback => 'Vedi i Miei Feedback';

  @override
  String get noFeedbackYet => 'Nessun feedback ancora';

  @override
  String get startRatingInsights =>
      'Inizia a valutare gli insight per migliorare le raccomandazioni del Coach AI';

  @override
  String get ratedHelpful => 'Valutato utile';

  @override
  String get ratedNotHelpful => 'Valutato non utile';

  @override
  String get feedbackOn => 'Feedback su';

  @override
  String get routineEditorTitle => 'Crea Routine';

  @override
  String get routineEditorEditTitle => 'Modifica Routine';

  @override
  String get routineStepInfo => 'Info';

  @override
  String get routineStepPattern => 'Pattern';

  @override
  String get routineStepReview => 'Riepilogo';

  @override
  String get routinePatternChooseTitle => 'Scegli il Tuo Pattern';

  @override
  String get routinePatternChooseDescription =>
      'Seleziona una suddivisione di allenamento che si adatta ai tuoi obiettivi';

  @override
  String get routinePatternPreset => 'Predefinito';

  @override
  String get routinePatternCustom => 'Personalizzato';

  @override
  String get routinePatternPopular => 'Pattern Popolari';

  @override
  String routinePatternWorkouts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count allenamenti',
      one: '1 allenamento',
    );
    return '$_temp0';
  }

  @override
  String routinePatternRest(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riposi',
      one: '1 riposo',
    );
    return '$_temp0';
  }

  @override
  String get customPatternBuilderTitle => 'Costruttore Pattern Personalizzato';

  @override
  String get customPatternBuilderDescription =>
      'Costruisci il tuo programma di allenamento';

  @override
  String customPatternYourSchedule(int count) {
    return 'Il Tuo Programma ($count giorni)';
  }

  @override
  String get customPatternAddWorkout => 'Aggiungi Allenamento';

  @override
  String get customPatternAddRest => 'Aggiungi Giorno di Riposo';

  @override
  String get customPatternEmptyWarning =>
      'Aggiungi almeno un giorno di allenamento per continuare';

  @override
  String get customPatternAddWorkoutDialogTitle =>
      'Aggiungi Giorno di Allenamento';

  @override
  String get customPatternWorkoutNameLabel => 'Nome Allenamento';

  @override
  String get customPatternWorkoutNameHint =>
      'es. Push, Pull, Gambe, Upper, Lower';

  @override
  String customPatternDayNumber(int number) {
    return 'Giorno $number';
  }

  @override
  String get customPatternRestDay => 'Giorno di Riposo';

  @override
  String get customPatternRemoveDay => 'Rimuovi giorno';

  @override
  String get customPatternSelectTemplate => 'Seleziona Scheda di Allenamento';

  @override
  String get customPatternNoTemplates =>
      'Nessuna scheda disponibile. Crea prima delle schede.';

  @override
  String get routineButtonBack => 'Indietro';

  @override
  String get routineButtonNext => 'Avanti';

  @override
  String get routineButtonCreate => 'Crea Routine';

  @override
  String get routineErrorIncomplete => 'Completa tutti i campi richiesti';

  @override
  String get routineErrorNoPattern => 'Seleziona un pattern';

  @override
  String routineSuccessCreated(String name) {
    return 'Routine \"$name\" creata con successo! 🎉';
  }

  @override
  String get routineErrorCreateFailed => 'Creazione routine fallita';

  @override
  String get routineDiscardTitle => 'Scartare le modifiche?';

  @override
  String get routineDiscardMessage =>
      'I tuoi progressi andranno persi se torni indietro ora.';

  @override
  String get errorLoadingImage => 'Errore nel caricamento dell\'immagine';

  @override
  String get tapAnywhereToClose => 'Tocca ovunque per chiudere';

  @override
  String get routineOnboardingSkip => 'Salta';

  @override
  String get routineOnboardingBack => 'Indietro';

  @override
  String get routineOnboardingNext => 'Avanti';

  @override
  String get routineOnboardingGetStarted => 'Inizia! 🚀';

  @override
  String get routineOnboardingWelcomeTitle =>
      'Benvenuto nel\nCentro Routine! 🏋️';

  @override
  String get routineOnboardingWelcomeSubtitle =>
      'Il tuo gestore di piani di allenamento personale.\nImpariamo insieme come usarlo!';

  @override
  String get routineOnboardingWhatIsTitle => 'Cos\'è una Routine? 🤔';

  @override
  String get routineOnboardingWhatIsDescription =>
      'Una routine è un piano di allenamento strutturato con:';

  @override
  String get routineOnboardingFeatureScheduled =>
      'Giorni di Allenamento Programmati';

  @override
  String get routineOnboardingFeatureScheduledDesc =>
      'Pianifica le tue settimane di allenamento in anticipo';

  @override
  String get routineOnboardingFeatureTemplates =>
      'Schede di Allenamento Specifiche';

  @override
  String get routineOnboardingFeatureTemplatesDesc =>
      'Assegna esercizi ad ogni giorno';

  @override
  String get routineOnboardingFeatureProgression => 'Progressione Automatica';

  @override
  String get routineOnboardingFeatureProgressionDesc =>
      'Il tuo piano si ripete automaticamente';

  @override
  String get routineOnboardingFeatureTracking => 'Monitoraggio Progressi';

  @override
  String get routineOnboardingFeatureTrackingDesc =>
      'Visualizza la tua costanza nel tempo';

  @override
  String get routineOnboardingHowItWorksTitle => 'Come Funziona ⚙️';

  @override
  String get routineOnboardingStep1Title => 'Crea la Tua Routine';

  @override
  String get routineOnboardingStep1Desc =>
      'Nominala e scegli il pattern di allenamento\n(es. Push/Pull/Gambe)';

  @override
  String get routineOnboardingStep2Title => 'Assegna gli Allenamenti';

  @override
  String get routineOnboardingStep2Desc =>
      'Seleziona le schede per ogni giorno di allenamento';

  @override
  String get routineOnboardingStep3Title => 'Segui e Monitora';

  @override
  String get routineOnboardingStep3Desc =>
      'Completa gli allenamenti e guarda i tuoi progressi crescere!';

  @override
  String get routineOnboardingBenefitsTitle => 'Perché Usare le Routine? 💪';

  @override
  String get routineOnboardingBenefit1Title => 'Rimani Costante';

  @override
  String get routineOnboardingBenefit1Desc =>
      'Basta chiedersi \"cosa alleno oggi?\"';

  @override
  String get routineOnboardingBenefit2Title => 'Vedi i Progressi';

  @override
  String get routineOnboardingBenefit2Desc =>
      'Monitora tasso di completamento e serie';

  @override
  String get routineOnboardingBenefit3Title => 'Recupero Intelligente';

  @override
  String get routineOnboardingBenefit3Desc =>
      'Hai saltato un allenamento? Riprogrammalo facilmente';

  @override
  String get routineOnboardingReadyCTA =>
      'Pronto a creare la tua prima routine?';

  @override
  String get routineCenter => 'Centro Routine';

  @override
  String get routineCenterDescription =>
      'Routine multi-periodo con tracciamento intelligente';

  @override
  String get routineBasicInfoTitle => 'Informazioni di Base';

  @override
  String get routineBasicInfoSubtitle =>
      'Imposta le fondamenta della tua routine';

  @override
  String get routineNameLabel => 'Nome Routine *';

  @override
  String get routineNameHint => 'es. Bulk Estivo 2025';

  @override
  String get routineNameRequired => 'Nome routine richiesto';

  @override
  String get routineNameMinLength =>
      'Il nome deve essere di almeno 3 caratteri';

  @override
  String get routineDescriptionLabel => 'Descrizione (Opzionale)';

  @override
  String get routineDescriptionHint => 'Aggiungi note su questa routine...';

  @override
  String get routineTypeLabel => 'Tipo di Routine';

  @override
  String get routineTypeWeekly => 'Settimanale';

  @override
  String get routineTypeWeeklyDuration => '7 giorni';

  @override
  String get routineTypeMonthly => 'Mensile';

  @override
  String get routineTypeMonthlyDuration => '30 giorni';

  @override
  String get routineTypeBimonthly => 'Bimestrale';

  @override
  String get routineTypeBimonthlyDuration => '60 giorni';

  @override
  String get routineTypeSemester => 'Semestrale';

  @override
  String get routineTypeSemesterDuration => '6 mesi';

  @override
  String get routineTypeCustom => 'Personalizzata';

  @override
  String get routineTypeCustomDuration => 'Durata personalizzata';

  @override
  String get routineDurationLabel => 'Durata';

  @override
  String get routineStartDateLabel => 'Data Inizio';

  @override
  String get routineEndDateLabel => 'Data Fine';

  @override
  String routineDurationWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks settimane',
      one: '1 settimana',
    );
    return '$_temp0';
  }

  @override
  String routineDurationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String routineDurationInfo(String duration) {
    return 'Durata: $duration';
  }

  @override
  String get routinePatternOneWorkoutOneRest => '1 Allenamento + 1 Riposo';

  @override
  String get routinePatternOneWorkoutOneRestDesc =>
      '1 giorno di allenamento seguito da 1 giorno di riposo';

  @override
  String get routinePatternTwoWorkoutsOneRest => '2 Allenamenti + 1 Riposo';

  @override
  String get routinePatternTwoWorkoutsOneRestDesc =>
      '2 giorni di allenamento seguiti da 1 giorno di riposo';

  @override
  String get routinePatternThreeWorkoutsOneRest => '3 Allenamenti + 1 Riposo';

  @override
  String get routinePatternThreeWorkoutsOneRestDesc =>
      '3 giorni di allenamento seguiti da 1 giorno di riposo';

  @override
  String get routinePatternThreeWorkoutsTwoRest => '3 Allenamenti + 2 Riposi';

  @override
  String get routinePatternThreeWorkoutsTwoRestDesc =>
      '3 giorni di allenamento con 2 giorni di riposo a settimana';

  @override
  String get routinePatternFourWorkoutsOneRest => '4 Allenamenti + 1 Riposo';

  @override
  String get routinePatternFourWorkoutsOneRestDesc =>
      '4 giorni di allenamento seguiti da 1 giorno di riposo';

  @override
  String get routinePatternFourWorkoutsThreeRest => '4 Allenamenti + 3 Riposi';

  @override
  String get routinePatternFourWorkoutsThreeRestDesc =>
      '4 giorni di allenamento con 3 giorni di riposo a settimana';

  @override
  String get routinePatternFiveWorkoutsTwoRest => '5 Allenamenti + 2 Riposi';

  @override
  String get routinePatternFiveWorkoutsTwoRestDesc =>
      '5 giorni di allenamento seguiti da 2 giorni di riposo';

  @override
  String get routinePatternSixWorkoutsOneRest => '6 Allenamenti + 1 Riposo';

  @override
  String get routinePatternSixWorkoutsOneRestDesc =>
      '6 giorni di allenamento seguiti da 1 giorno di riposo';

  @override
  String get routineCalendarPreview => 'Anteprima Calendario';

  @override
  String get routineCalendarPreviewSubtitle =>
      'Come appare il tuo pattern sul calendario';

  @override
  String routineAndMoreDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return '... e altri $count $_temp0';
  }

  @override
  String routineTotalWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'allenamenti',
      one: 'allenamento',
    );
    return 'Totale: $count $_temp0';
  }

  @override
  String routineTotalRestDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni di riposo',
      one: 'giorno di riposo',
    );
    return 'Totale: $count $_temp0';
  }

  @override
  String get routineWorkoutDayLabel => 'Giorni Allenamento';

  @override
  String get routineRestDayLabel => 'Giorni Riposo';

  @override
  String get routineTotalDaysLabel => 'Giorni Totali';

  @override
  String get routineWeekdayMonday => 'Lunedì';

  @override
  String get routineWeekdayTuesday => 'Martedì';

  @override
  String get routineWeekdayWednesday => 'Mercoledì';

  @override
  String get routineWeekdayThursday => 'Giovedì';

  @override
  String get routineWeekdayFriday => 'Venerdì';

  @override
  String get routineWeekdaySaturday => 'Sabato';

  @override
  String get routineWeekdaySunday => 'Domenica';

  @override
  String routineWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: '',
    );
    return '$count allenamento$_temp0';
  }

  @override
  String routineRestCount(int count) {
    return '$count riposo';
  }

  @override
  String get routineRotationTitle => 'Ordine di Rotazione';

  @override
  String get routineRotationSubtitle =>
      'Trascina per riordinare come i template ruoteranno nei giorni di allenamento';

  @override
  String routineTemplatesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    return '$count template selezionat$_temp0';
  }

  @override
  String get routineDistributionPreview => 'Anteprima Distribuzione';

  @override
  String routineFirstDaysPreview(int shown, int total) {
    return 'Primi $shown giorni (totale: $total giorni)';
  }

  @override
  String routineMoreDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return '... e altri $count $_temp0';
  }

  @override
  String get routineNoTemplatesSelected => 'Nessun Template Selezionato';

  @override
  String get routineNoTemplatesMessage =>
      'Torna allo step precedente e seleziona almeno un template di allenamento';

  @override
  String get routineNoPatternSelected => 'Nessun pattern selezionato';

  @override
  String routineErrorLoading(String error) {
    return 'Errore: $error';
  }

  @override
  String get routineSelectionTitle => 'Seleziona Template di Allenamento';

  @override
  String get routineSelectionSubtitle =>
      'Scegli i template da alternare automaticamente nei giorni di allenamento';

  @override
  String get routineAvailableTemplates => 'Template Disponibili';

  @override
  String routineSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i',
      one: 'o',
    );
    return '$count selezionat$_temp0';
  }

  @override
  String get routineNextStepInfo =>
      'Nel prossimo step, organizzerai l\'ordine di rotazione di questi template';

  @override
  String get routineNoTemplatesYet => 'Nessun Template di Allenamento';

  @override
  String get routineNeedTemplatesMessage =>
      'Hai bisogno di template di allenamento per creare una routine.\nScegli una delle opzioni qui sotto per continuare.';

  @override
  String get routineCreateTemplatesFirst =>
      'Prima di creare una routine, devi creare dei template di allenamento con gli esercizi.';

  @override
  String get routineWorkflowTitle => 'Come funziona';

  @override
  String get routineWorkflowStep1 =>
      'Vai su \'Le mie schede\' e crea template di allenamento con esercizi';

  @override
  String get routineWorkflowStep2 =>
      'Torna qui e seleziona i tuoi template per la routine';

  @override
  String get routineWorkflowStep3 =>
      'Configura la rotazione e completa la configurazione della routine';

  @override
  String get routinePopularTemplates => 'Template Popolari';

  @override
  String get routinePopularTemplatesDesc =>
      'Inizia con programmi di allenamento collaudati';

  @override
  String get routineImportPopularTemplates => 'Importa Template Popolari';

  @override
  String get routineCustomTemplate => 'Template Personalizzato';

  @override
  String get routineCustomTemplateDesc =>
      'Progetta il tuo programma di allenamento';

  @override
  String get routineCreateFirstTemplate => 'Crea Primo Template';

  @override
  String get routineNavigatingToCreator =>
      'Navigando verso il creatore di template... 🏗️';

  @override
  String get routineSelectTemplatesDialog =>
      'Seleziona i template che vuoi importare';

  @override
  String get routineSelectTemplatesButton => 'Seleziona template';

  @override
  String routineImportCount(int count) {
    return 'Importa ($count)';
  }

  @override
  String get routineOr => 'OPPURE';

  @override
  String get routineErrorLoadingTemplates =>
      'Errore nel caricamento dei template';

  @override
  String routineSuccessCreatedInactive(String name) {
    return 'Routine \"$name\" creata! Vai al Centro Routine per attivarla.';
  }

  @override
  String get routineAnalyticsNoActiveRoutine => 'Nessuna Routine Attiva';

  @override
  String get routineAnalyticsNoActiveRoutineDesc =>
      'Crea e attiva una routine per vedere le statistiche qui';

  @override
  String get routineAnalyticsCreateRoutine => 'Crea Routine';

  @override
  String get routineAnalyticsErrorLoading => 'Errore Caricamento Statistiche';

  @override
  String get routineAnalyticsActiveRoutine => 'Statistiche Routine Attiva';

  @override
  String get routineAnalyticsPerformanceMetrics => 'Metriche di Performance';

  @override
  String get routineAnalyticsAdherence => 'Aderenza';

  @override
  String get routineAnalyticsSkipRate => 'Tasso Skip';

  @override
  String get routineAnalyticsRecovery => 'Recupero';

  @override
  String get routineAnalyticsAvgGap => 'Gap Medio';

  @override
  String get routineAnalyticsDays => 'giorni';

  @override
  String get routineAnalyticsSkipped => 'saltati';

  @override
  String get routineAnalyticsRecovered => 'recuperati';

  @override
  String get routineAnalyticsBetweenWorkouts => 'tra allenamenti';

  @override
  String get routineAnalyticsCurrentStreak => 'Striscia Corrente';

  @override
  String get routineAnalyticsBestStreak => 'Miglior Striscia';

  @override
  String get routineAnalyticsInsights => 'Insights';

  @override
  String get routineAnalyticsTemplateDistribution => 'Distribuzione Template';

  @override
  String get routineAnalyticsWeeklyPattern => 'Pattern Settimanale';

  @override
  String get routineAnalyticsWeeklyTrend => 'Trend Aderenza Settimanale';

  @override
  String get routineAnalyticsChartComingSoon => 'Grafico in arrivo';

  @override
  String get routine => 'Routine';

  @override
  String get feedbackPrompt => 'Come è stato questo passaggio?';

  @override
  String get feedbackPoor => 'Scarso';

  @override
  String get feedbackExcellent => 'Eccellente';

  @override
  String get staleProfileTitle => 'Aggiorna il Tuo Profilo Fitness';

  @override
  String staleProfileSubtitle1Month(int days) {
    return 'Il tuo profilo non è stato aggiornato da $days giorni. Aggiornalo per suggerimenti più precisi!';
  }

  @override
  String staleProfileSubtitleMonths(int months) {
    return 'Il tuo profilo ha $months mesi. È ora di aggiornarlo per suggerimenti migliori!';
  }

  @override
  String staleProfileSubtitleManyMonths(int months) {
    return 'Il tuo profilo non è stato aggiornato da $months mesi! Aggiornalo ora per suggerimenti accurati.';
  }

  @override
  String get staleProfileUpdateButton => 'Aggiorna';

  @override
  String get exerciseProgress => 'Progressi Esercizi';

  @override
  String get trackExerciseGrowth => 'Monitora i tuoi miglioramenti';

  @override
  String get exerciseProgressTitle => 'Progressi Esercizi';

  @override
  String get searchExercisesPlaceholder => 'Cerca esercizi...';

  @override
  String get weightProgression => 'Progressione Peso';

  @override
  String get repsProgression => 'Progressione Ripetizioni';

  @override
  String get effortProgression => 'Progressione Sforzo';

  @override
  String get personalRecord => 'Record Personale';

  @override
  String get averageWeight => 'Peso Medio';

  @override
  String get averageRPE => 'RPE Medio';

  @override
  String get totalSessions => 'Sessioni Totali';

  @override
  String get exerciseStats => 'Statistiche Esercizio';

  @override
  String get progressionCharts => 'Grafici Progressione';

  @override
  String get noExercisesFoundDesc =>
      'Completa un allenamento per vedere i progressi degli esercizi';

  @override
  String get avgReps => 'Reps Medie';

  @override
  String get lastWorkout => 'Ultimo Allenamento';

  @override
  String get viewProgress => 'Vedi Progressi';

  @override
  String get sessionHistory => 'Storico Sessioni';

  @override
  String get improving => 'Migliorando';

  @override
  String get declining => 'In Calo';

  @override
  String get stable => 'Stabile';

  @override
  String get periodSelectorLabel => 'Periodo';

  @override
  String get combinedView => 'Unificato';

  @override
  String get separatedView => 'Separato';

  @override
  String get combinedChart => 'Progressi Unificati';

  @override
  String get tapToToggle => 'Tocca per mostrare/nascondere';

  @override
  String get effort => 'Sforzo';

  @override
  String get weightSettings => 'Impostazioni Peso';

  @override
  String get errorLoadingSettings => 'Errore nel Caricamento';

  @override
  String get quickIncrements => 'Incrementi Rapidi';

  @override
  String get quickIncrementsDescription =>
      'Seleziona l\'incremento predefinito per i pulsanti +/-';

  @override
  String get customIncrement => 'Incremento Personalizzato';

  @override
  String get customIncrementDescription =>
      'Imposta un incremento personalizzato per regolazioni precise';

  @override
  String get plateCalculator => 'Calcolatore Dischi';

  @override
  String get plateCalculatorDescription =>
      'Calcola quali dischi caricare sul bilanciere';

  @override
  String get availablePlates => 'Dischi Disponibili';

  @override
  String get availablePlatesDescription =>
      'Dischi disponibili nella tua palestra';

  @override
  String get useCustomIncrement => 'Usa Incremento Personalizzato';

  @override
  String get customIncrementActive => 'Incremento personalizzato attivo';

  @override
  String get defaultIncrementActive => 'Incremento predefinito attivo';

  @override
  String get customIncrementValue => 'Valore Incremento Personalizzato';

  @override
  String get customIncrementHint => 'Inserisci un valore tra 0.5 e 100';

  @override
  String get pleaseEnterValue => 'Inserisci un valore';

  @override
  String get pleaseEnterValidNumber => 'Inserisci un numero positivo valido';

  @override
  String get incrementTooLarge => 'L\'incremento non può superare 100';

  @override
  String get saveCustomIncrement => 'Salva Incremento Personalizzato';

  @override
  String get customIncrementSaved =>
      'Incremento personalizzato salvato con successo';

  @override
  String get calculatePlatesNeeded => 'Calcola Dischi Necessari';

  @override
  String get barWeight => 'Peso Bilanciere';

  @override
  String get targetWeight => 'Peso Obiettivo';

  @override
  String get calculate => 'Calcola';

  @override
  String get platesInYourGym => 'Dischi nella Tua Palestra';

  @override
  String get quantity => 'Quantità';

  @override
  String get editPlates => 'Modifica Dischi';

  @override
  String get pleaseEnterValidWeights => 'Inserisci pesi validi';

  @override
  String get targetWeightTooLow =>
      'Il peso obiettivo deve essere maggiore o uguale al peso del bilanciere';

  @override
  String get plateCalculationResult => 'Risultato Calcolo Dischi';

  @override
  String get difference => 'Differenza';

  @override
  String get platesPerSide => 'Dischi per Lato';

  @override
  String get barOnly => 'Solo bilanciere (nessun disco necessario)';

  @override
  String get resetSettingsConfirmation =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get settingsReset => 'Impostazioni ripristinate ai valori predefiniti';

  @override
  String get feedbackSettings => 'Feedback Aptico';

  @override
  String get hapticFeedback => 'Feedback Aptico';

  @override
  String get enableHaptic => 'Abilita feedback aptico';

  @override
  String get hapticIntensity => 'Intensità Aptica';

  @override
  String get intensityLight => 'Leggera';

  @override
  String get intensityMedium => 'Media';

  @override
  String get intensityHeavy => 'Forte';

  @override
  String get hapticDescription =>
      'Senti vibrazioni sottili quando completi serie, esercizi e allenamenti';

  @override
  String get feedbackSettingsSaved => 'Impostazioni feedback salvate';

  @override
  String get historyViewSettings => 'Impostazioni Vista Cronologia';

  @override
  String get viewMode => 'Modalità Vista';

  @override
  String get viewModeList => 'Vista Lista';

  @override
  String get viewModeCompact => 'Compatta';

  @override
  String get viewModeCalendar => 'Vista Calendario';

  @override
  String get viewModeStats => 'Vista Statistiche';

  @override
  String get historyDisplayOptions => 'Opzioni Visualizzazione';

  @override
  String get showThumbnails => 'Mostra Miniature';

  @override
  String get showDuration => 'Mostra Durata';

  @override
  String get showExerciseCount => 'Mostra Conteggio Esercizi';

  @override
  String get viewSettingsDescription =>
      'Personalizza come viene visualizzata la cronologia degli allenamenti';

  @override
  String get historyViewSettingsSaved => 'Impostazioni vista salvate';

  @override
  String get reportExerciseIssue => 'Segnala Problema';

  @override
  String get feedbackType => 'Tipo Segnalazione';

  @override
  String get feedbackBug => '🐛 Bug';

  @override
  String get feedbackSuggestion => '💡 Suggerimento';

  @override
  String get feedbackTypo => '📝 Errore di Testo';

  @override
  String get feedbackOther => '❓ Altro';

  @override
  String get describeProblem => 'Descrivi il problema...';

  @override
  String get sendFeedback => 'Invia Segnalazione';

  @override
  String get cancelFeedback => 'Annulla';

  @override
  String get feedbackSentSuccess => '✅ Grazie per la segnalazione!';

  @override
  String get feedbackSentError => '❌ Errore nell\'invio della segnalazione';

  @override
  String get feedbackRequired => 'Descrivi il problema';

  @override
  String get exerciseReviewReport => 'Report di Revisione Esercizi';

  @override
  String get monthlyReview => 'Revisione Mensile';

  @override
  String get staleExercises => 'Esercizi Obsoleti';

  @override
  String get flaggedExercises => 'Esercizi Flaggati';

  @override
  String get exercisesObsolete => 'Esercizi Obsoleti';

  @override
  String get exercisesFlagged => 'Esercizi Flaggati';

  @override
  String get feedbackTotal => 'Feedback Totali';

  @override
  String get criticalIssues => 'Problemi Critici';

  @override
  String get daysThreshold => '>90 giorni';

  @override
  String get feedbackThreshold => '≥3 feedback';

  @override
  String get flagged => 'flaggati';

  @override
  String get critical => 'critici';

  @override
  String modifiedDaysAgo(int days) {
    return 'Modificato $days giorni fa';
  }

  @override
  String get noReportAvailable => 'Nessun report disponibile';

  @override
  String get reportWillBeAvailable =>
      'Il report mensile sarà disponibile dopo la prima esecuzione';

  @override
  String get exerciseFeedback => 'Feedback Esercizi';

  @override
  String get feedbackRefresh => 'Aggiorna';

  @override
  String get feedbackStatsTotal => 'Totale';

  @override
  String get feedbackStatsOpen => 'Aperti';

  @override
  String get feedbackStatsResolved => 'Risolti';

  @override
  String get feedbackByType => 'Feedback per Tipo';

  @override
  String get feedbackBySeverity => 'Feedback per Gravità';

  @override
  String get feedbackSeverityCritical => 'Critico';

  @override
  String get feedbackSeverityHigh => 'Alta';

  @override
  String get feedbackSeverityMedium => 'Media';

  @override
  String get feedbackSeverityLow => 'Bassa';

  @override
  String get feedbackCriticalIssues => 'Problemi Critici (Gravità ≥ 4)';

  @override
  String get feedbackCriticalIssuesTitle => 'Problemi Critici (Gravità ≥ 4)';

  @override
  String get feedbackNoCriticalIssues => 'Nessun problema critico';

  @override
  String get feedbackErrorLoadingCritical =>
      'Errore caricamento problemi critici';

  @override
  String get feedbackRecentOpen => 'Feedback Recenti Aperti';

  @override
  String get feedbackRecentOpenTitle => 'Feedback Recenti Aperti';

  @override
  String get feedbackNoOpenFeedback => 'Nessun feedback aperto';

  @override
  String get feedbackErrorLoading => 'Errore caricamento feedback';

  @override
  String get feedbackErrorLoadingList => 'Errore caricamento feedback';

  @override
  String get feedbackLoadingMessage => 'Caricamento feedback...';

  @override
  String feedbackSubmittedBy(String email) {
    return 'da $email';
  }

  @override
  String get feedbackDetailUserMessage => 'Messaggio Utente';

  @override
  String get feedbackDetailAdminNotes => 'Note Admin';

  @override
  String get feedbackDetailAdminNotesHint =>
      'Aggiungi note interne su questo feedback...';

  @override
  String get feedbackDetailSaveNotes => 'Salva Note';

  @override
  String get feedbackDetailNotesSaved => 'Note salvate con successo';

  @override
  String get feedbackDetailNotesError => 'Errore salvataggio note';

  @override
  String get feedbackDetailQuickActions => 'Azioni Rapide';

  @override
  String get feedbackActionStartReview => 'Inizia Revisione';

  @override
  String get feedbackActionMarkResolved => 'Segna Risolto';

  @override
  String get feedbackActionDismiss => 'Ignora';

  @override
  String get feedbackActionReopen => 'Riapri';

  @override
  String feedbackStatusUpdated(String status) {
    return 'Status aggiornato a $status';
  }

  @override
  String get feedbackStatusUpdateError => 'Errore aggiornamento status';

  @override
  String get feedbackDetailChangeSeverity => 'Cambia Gravità';

  @override
  String get feedbackSeverityUpdated => 'Gravità aggiornata';

  @override
  String get feedbackSeverityUpdateError => 'Errore aggiornamento gravità';

  @override
  String get feedbackDetailInfoUser => 'Utente';

  @override
  String get feedbackDetailInfoCreated => 'Creato';

  @override
  String get feedbackDetailInfoVersion => 'Versione';

  @override
  String get feedbackSeverityUrgent => 'Urgente';

  @override
  String feedbackTimeMinutesAgo(int minutes) {
    return '${minutes}m fa';
  }

  @override
  String feedbackTimeHoursAgo(int hours) {
    return '${hours}h fa';
  }

  @override
  String feedbackTimeDaysAgo(int days) {
    return '${days}g fa';
  }

  @override
  String feedbackByUser(String email) {
    return 'da $email';
  }

  @override
  String get savingWorkout => 'Salvataggio allenamento...';

  @override
  String get syncingToCloud => 'Sincronizzazione cloud...';

  @override
  String get workoutSavedLocally => 'Allenamento salvato localmente';

  @override
  String get cloudSyncComplete => 'Sincronizzazione completata';

  @override
  String get cloudSyncQueued => 'In coda per sincronizzazione';

  @override
  String get saveFailed => 'Salvataggio fallito';

  @override
  String get retryingSync => 'Nuovo tentativo di sincronizzazione...';

  @override
  String get localSaveFailed => 'Salvataggio locale fallito';

  @override
  String get retryOrExport => 'Riprova o esporta dati';

  @override
  String get quickRepPresets => 'Preset Ripetizioni Rapidi';

  @override
  String get quickSetCount => 'Scelta Serie Rapida';

  @override
  String get averageRpe => 'RPE Medio';

  @override
  String get routineDayCompleted => 'Giorno routine completato:';

  @override
  String get routineDayCompletionFailed =>
      'Impossibile completare giorno routine';

  @override
  String get repPresetStrengthLabel => '1-3';

  @override
  String get repPresetStrengthDescription => 'Forza Massimale';

  @override
  String get repPresetPowerLabel => '4-6';

  @override
  String get repPresetPowerDescription => 'Potenza';

  @override
  String get repPresetStrengthHypertrophyLabel => '6-8';

  @override
  String get repPresetStrengthHypertrophyDescription => 'Forza / Ipertrofia';

  @override
  String get repPresetHypertrophyLabel => '8-12';

  @override
  String get repPresetHypertrophyDescription => 'Ipertrofia';

  @override
  String get repPresetEnduranceLabel => '12-15';

  @override
  String get repPresetEnduranceDescription => 'Resistenza Muscolare';

  @override
  String get repPresetHighEnduranceLabel => '15+';

  @override
  String get repPresetHighEnduranceDescription => 'Alta Resistenza';

  @override
  String get restPresetNoTimer => 'Nessun Timer';

  @override
  String get restPresetThirtySeconds => '30 secondi';

  @override
  String get restPresetOneMinute => '1 minuto';

  @override
  String get restPresetOneMinuteThirty => '1:30 min';

  @override
  String get restPresetTwoMinutes => '2 minuti';

  @override
  String get restPresetThreeMinutes => '3 minuti';

  @override
  String get restPresetFiveMinutes => '5 minuti';

  @override
  String get restTimeDescription =>
      'Imposta il timer per il recupero tra le serie';

  @override
  String get useCustomTimer => 'Usa timer personalizzato';

  @override
  String get timerActiveForExercise => 'Timer attivo per questo esercizio';

  @override
  String get noSpecificTimer => 'Nessun timer specifico';

  @override
  String get quickPresets => 'Preset Rapidi';

  @override
  String get customTimer => 'Timer Personalizzato';

  @override
  String get timerSet => 'Timer impostato: ';

  @override
  String get swapDaysTitle => 'Scambiare i Giorni di Allenamento?';

  @override
  String get swapDaysDescription =>
      'La tua routine è programmata diversamente. Vuoi scambiare questi giorni?';

  @override
  String get daysSwappedSuccessfully =>
      'Giorni scambiati con successo! Continuando con';

  @override
  String get errorSwappingDays => 'Errore nello scambio dei giorni. Riprova.';

  @override
  String get errorMarkingDayAsSkipped =>
      'Errore nel marcare il giorno come saltato';

  @override
  String get workoutCompletedButRoutineNotUpdated =>
      'Allenamento completato. Routine non aggiornata.';

  @override
  String get continueNormal => 'Continua Normale';

  @override
  String get skipToday => 'Salta Oggi';

  @override
  String get swapDaysButtonLabel => 'Scambia i Giorni';

  @override
  String get routineRecoverSkippedDays => 'Recupera Giorni Saltati';

  @override
  String get routineRecoverSkippedDaysSubtitle =>
      'Seleziona un giorno saltato, poi scegli un giorno di riposo per recuperarlo';

  @override
  String routineSkippedDaysCount(int count) {
    return 'Giorni Saltati ($count)';
  }

  @override
  String routineAvailableDaysCount(int count) {
    return 'Giorni Disponibili ($count)';
  }

  @override
  String get routineSelectSkippedDayFirst =>
      '← Seleziona prima un giorno saltato';

  @override
  String get routineNoSkippedDays => 'Nessun giorno saltato!';

  @override
  String get routineOnTrack => 'Sei in linea con la tua routine 💪';

  @override
  String get routineNoRestDaysAvailable =>
      'Nessun giorno di riposo disponibile nei prossimi 30 giorni';

  @override
  String routineWorkoutRecovered(String date) {
    return 'Allenamento recuperato al $date';
  }

  @override
  String get routineRecoveryFailed => 'Impossibile recuperare l\'allenamento';

  @override
  String routineRecoveryError(String error) {
    return 'Errore nel recupero dell\'allenamento: $error';
  }

  @override
  String get routineNoActiveRoutine => 'Nessuna routine attiva trovata';

  @override
  String get routineSkipRecovery => 'Recupero Giorni';

  @override
  String notificationSkippedDaysSingle(int count, String routine) {
    return '$count giorno saltato in $routine';
  }

  @override
  String notificationSkippedDaysMultiple(int count, String routine) {
    return '$count giorni saltati in $routine';
  }

  @override
  String get notificationSkippedDaysBody =>
      'Tocca per vedere le opzioni di recupero e tornare in pista!';

  @override
  String notificationRoutineDayCompleted(String routine) {
    return 'Giorno di $routine completato!';
  }

  @override
  String notificationGreatJob(String workout) {
    return 'Ottimo lavoro completando $workout!';
  }

  @override
  String notificationRecoverySingle(int count) {
    return '$count giorno saltato può essere recuperato';
  }

  @override
  String notificationRecoveryMultiple(int count) {
    return '$count giorni saltati possono essere recuperati';
  }

  @override
  String notificationRecoveryBody(String routine) {
    return 'Tocca per programmare gli allenamenti di recupero in $routine';
  }

  @override
  String get errorJsonMalformed =>
      'Formato JSON non valido. Controlla parentesi e virgole.';

  @override
  String get errorJsonUnexpectedCharacter =>
      'Carattere imprevisto nel JSON. Controlla la sintassi.';

  @override
  String get errorJsonMissingFields => 'Campi obbligatori mancanti nel JSON.';

  @override
  String get errorFileNotFound => 'File non trovato. Seleziona un file valido.';

  @override
  String get errorFilePermission =>
      'Permesso negato. Impossibile accedere al file.';

  @override
  String get errorFileAccess => 'Impossibile accedere al file. Riprova.';

  @override
  String get errorFileTooLarge => 'File troppo grande (max 5MB).';

  @override
  String get errorFileEmpty => 'Il file è vuoto. Fornisci del contenuto.';

  @override
  String get errorFileAlreadyExists => 'Il file esiste già.';

  @override
  String get errorDiskFull => 'Disco pieno. Libera spazio e riprova.';

  @override
  String get errorTemplateNameMissing => 'Il nome del template è obbligatorio.';

  @override
  String get errorNoExercises => 'Aggiungi almeno un esercizio al template.';

  @override
  String get errorExercisesInvalid =>
      'Dati esercizio non validi. Controlla il formato.';

  @override
  String get errorSetsRequired =>
      'Ogni esercizio ha bisogno di almeno una serie.';

  @override
  String get errorInvalidNumbers =>
      'Peso e ripetizioni devono essere numeri validi.';

  @override
  String get errorDuplicateTemplate =>
      'Esiste già un template con questo nome.';

  @override
  String get errorImportFailed =>
      'Importazione fallita. Controlla il formato e riprova.';

  @override
  String get suggestionCheckJsonFormat =>
      'Controlla il formato JSON (parentesi, virgole, virgolette)';

  @override
  String get suggestionUseJsonValidator =>
      'Usa un validatore JSON online per controllare il formato';

  @override
  String get suggestionCopyExample =>
      'Copia il template di esempio e modificalo';

  @override
  String get suggestionCheckFilePath =>
      'Verifica che il file esista nel percorso specificato';

  @override
  String get suggestionReduceFileSize =>
      'Riduci le dimensioni del file o dividilo in più file';

  @override
  String get suggestionCheckPermissions =>
      'Controlla i permessi dell\'app nelle impostazioni';

  @override
  String get suggestionAddTemplateName =>
      'Aggiungi un campo nome al tuo template';

  @override
  String get suggestionAddExercises =>
      'Aggiungi almeno un esercizio con le serie';

  @override
  String get suggestionAddSets =>
      'Aggiungi informazioni serie (ripetizioni e peso)';

  @override
  String get suggestionCheckFormat =>
      'Verifica che il formato del template corrisponda all\'esempio';

  @override
  String get listView => 'Vista Lista';

  @override
  String get gridView => 'Vista Griglia';

  @override
  String get parsing => 'Analisi in corso...';

  @override
  String get matchingExercises => 'Abbinamento esercizi...';

  @override
  String get convertingWeights => 'Conversione pesi...';

  @override
  String get finalizing => 'Finalizzazione...';

  @override
  String get importFailed => '❌ Importazione fallita';

  @override
  String get noDescription => 'Nessuna descrizione';

  @override
  String get exerciseDetailSummary => 'Sommario';

  @override
  String get exerciseDetailHistory => 'Cronologia';

  @override
  String get exerciseDetailInstructions => 'Istruzioni';

  @override
  String get primaryMuscle => 'Muscolo Primario';

  @override
  String get last3MonthsChart => 'Ultimi 3 Mesi';

  @override
  String get best1RM => 'Miglior 1RM';

  @override
  String get bestSetVolume => 'Miglior Volume Set';

  @override
  String get bestSessionVolume => 'Miglior Volume Sessione';

  @override
  String get strengthLevel => 'Livello di Forza';

  @override
  String get strengthLevelComingSoon =>
      'I benchmark di forza arriveranno presto!';

  @override
  String get noHistoryYet => 'Nessuna cronologia';

  @override
  String get startWorkoutToSeeHistory =>
      'Inizia un allenamento per vedere la cronologia degli esercizi';

  @override
  String get unknownWorkout => 'Allenamento Sconosciuto';

  @override
  String get videoTutorial => 'Video Tutorial';

  @override
  String get formCues => 'Punti Tecnici';

  @override
  String get warmupPhase1Description =>
      'Mobilizzazione articolare e stretching dinamico (5-10 min)';

  @override
  String get warmupPhase2Description =>
      'Attivazione muscolare con esercizi a corpo libero';

  @override
  String get warmupPhase3Description =>
      '2-3 serie di riscaldamento con carico progressivo';

  @override
  String get warmupPhase4Title => 'Riposo & Recupero';

  @override
  String get warmupPhase4Description =>
      '1-2 minuti di riposo prima delle serie di lavoro';

  @override
  String get tips => 'Suggerimenti';

  @override
  String get backHint => 'Torna alla schermata precedente';

  @override
  String get createTemplateHint =>
      'Apri il modulo per creare un nuovo template di allenamento';

  @override
  String get syncStatus => 'Stato Sincronizzazione';

  @override
  String get syncStatusHint =>
      'Visualizza lo stato della sincronizzazione cloud e le modifiche offline';

  @override
  String get pageNotFound => 'Pagina Non Trovata';

  @override
  String modalTestSuccess(String modalName) {
    return '✅ $modalName - FUNZIONANTE';
  }

  @override
  String modalTestOpened(String modalName) {
    return '✅ $modalName - APERTO (verifica funzionalità)';
  }

  @override
  String modalTestError(String modalName, String error) {
    return '❌ $modalName - ERRORE: $error';
  }

  @override
  String modalTestRpeSuccess(String rpe) {
    return '✅ RpeSelectorBottomSheet - FUNZIONANTE: RPE $rpe';
  }

  @override
  String get historyButtonTapped => '📊 Pulsante cronologia premuto';

  @override
  String get editButtonTapped => '✏️ Pulsante modifica premuto';

  @override
  String get exerciseSelectVariation => 'Seleziona Variazione';

  @override
  String get exerciseFilterByEquipment => 'Filtra per attrezzatura disponibile';

  @override
  String get exerciseVariationStandard => 'Standard';

  @override
  String get exerciseVariationEquipment => 'Attrezzatura';

  @override
  String get exerciseVariationGrip => 'Presa';

  @override
  String get exerciseVariationAngle => 'Angolo';

  @override
  String get exerciseVariationTempo => 'Tempo';

  @override
  String get exerciseVariationROM => 'Range di Movimento';

  @override
  String get exerciseEquipmentNone => 'Corpo Libero';

  @override
  String exerciseVariationsFiltered(int filtered, int total) {
    return 'Mostrando $filtered di $total variazioni';
  }

  @override
  String exerciseVariationsTotal(int total) {
    return '$total variazioni disponibili';
  }

  @override
  String get exerciseNoVariationsWithEquipment =>
      'Nessuna variazione disponibile con la tua attrezzatura attuale';

  @override
  String get exerciseNoVariationsAvailable =>
      'Nessuna variazione disponibile per questo esercizio';

  @override
  String get exerciseShowAllVariations => 'Mostra Tutte le Variazioni';

  @override
  String get equipmentProfile => 'Profilo Attrezzatura';

  @override
  String get equipmentProfileCreate => 'Nuovo';

  @override
  String equipmentProfileItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get equipmentProfileSelectOne => 'Seleziona un profilo attrezzatura';

  @override
  String get equipmentProfileSelect => 'Seleziona Profilo Attrezzatura';

  @override
  String get equipmentProfileCreateError =>
      'Creazione profilo attrezzatura fallita';

  @override
  String get equipmentProfileLoadError =>
      'Caricamento profili attrezzatura fallito';

  @override
  String get equipmentProfileEmpty => 'Nessun profilo attrezzatura ancora';

  @override
  String get equipmentProfileCreateFirst => 'Crea Primo Profilo';

  @override
  String get equipmentProfileCreateNew => 'Crea Profilo Equipaggiamento';

  @override
  String get equipmentProfileSelectTemplate => 'Seleziona Template Iniziale';

  @override
  String get equipmentProfileCommercial => 'Palestra Commerciale';

  @override
  String get equipmentProfileCommercialDesc =>
      'Tutto disponibile - bilanciere, manubri, macchine, cavi';

  @override
  String get equipmentProfileHomeBasic => 'Home Gym (Base)';

  @override
  String get equipmentProfileHomeBasicDesc =>
      'Bilanciere, manubri, panca, elastici';

  @override
  String get equipmentProfileHomeComplete => 'Home Gym (Completa)';

  @override
  String get equipmentProfileHomeCompleteDesc =>
      'Setup avanzato - kettlebell, TRX, sbarra trazioni';

  @override
  String get equipmentProfileTravel => 'Viaggio / Hotel';

  @override
  String get equipmentProfileTravelDesc => 'Minimale - manubri e corpo libero';

  @override
  String get equipmentProfileBodyweight => 'Solo Corpo Libero';

  @override
  String get equipmentProfileBodyweightDesc =>
      'Nessun equipaggiamento - calisthenics';

  @override
  String get equipment_barbell => 'Bilanciere';

  @override
  String get equipment_dumbbell => 'Manubri';

  @override
  String get equipment_machine => 'Macchina';

  @override
  String get equipment_cables => 'Cavi';

  @override
  String get equipment_smith_machine => 'Smith Machine';

  @override
  String get equipment_ez_bar => 'EZ Bar';

  @override
  String get equipment_kettlebell => 'Kettlebell';

  @override
  String get equipment_bodyweight => 'Corpo libero';

  @override
  String get equipment_trx => 'TRX';

  @override
  String get equipment_bands => 'Elastici';

  @override
  String get equipment_pullup_bar => 'Sbarra per Trazioni';

  @override
  String get equipment_parallel_bars => 'Parallele';

  @override
  String get equipment_rack => 'Rack';

  @override
  String get equipment_bench => 'Panca';

  @override
  String get rotationConfigTitle => 'Impostazioni Rotazione';

  @override
  String get rotationEnabled => 'Abilita Rotazione';

  @override
  String get rotationEnabledDesc =>
      'Ruota automaticamente le variazioni degli esercizi';

  @override
  String get rotationFrequency => 'Frequenza Rotazione';

  @override
  String get rotationNotifications => 'Notifiche';

  @override
  String get rotationNotificationsDesc => 'Notifica prima dei cambi variazione';

  @override
  String get rotationNotifyDaysBefore => 'Giorni preavviso';

  @override
  String rotationFrequencyWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Ogni $weeks settimane',
      one: 'Ogni settimana',
    );
    return '$_temp0';
  }

  @override
  String rotationNotifyDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get rotationPreview => 'Anteprima';

  @override
  String get rotationNextDate => 'Prossima rotazione';

  @override
  String rotationInDays(int days) {
    return 'Tra $days giorni';
  }

  @override
  String get tomorrow => 'Domani';

  @override
  String get accessDenied => 'Accesso Negato';

  @override
  String get noPermissionMessage =>
      'Non hai il permesso per accedere a questa funzionalità. Per favore, aggiorna il tuo account o contatta il supporto.';

  @override
  String sessionExpiringSoon(int seconds) {
    return 'La tua sessione scadrà tra $seconds secondi. Tocca per estenderla.';
  }

  @override
  String get sessionExpired =>
      'La tua sessione è scaduta. Per favore, effettua nuovamente l\'accesso.';

  @override
  String get extendSession => 'Estendi Sessione';

  @override
  String get equipmentProfileName => 'Nome Profilo';

  @override
  String get equipmentProfileNameHint => 'es. Home Gym, Kit Viaggio';

  @override
  String get equipmentProfileBadge => 'Tipo';

  @override
  String get equipmentProfileSelectEquipment =>
      'Seleziona Equipaggiamento Disponibile';

  @override
  String get selectAll => 'Seleziona Tutto';

  @override
  String get equipmentProfileEdit => 'Modifica Profilo Equipaggiamento';

  @override
  String get equipmentProfileTemplateHint =>
      'Scegli un template da personalizzare o parti da zero';

  @override
  String get equipmentProfilesTitle => 'Profili Equipaggiamento';

  @override
  String get equipmentProfilesSubtitle =>
      'Gestisci la disponibilità del tuo equipaggiamento per raccomandazioni esercizi';

  @override
  String get equipmentProfilesHelp => 'Aiuto Profili Equipaggiamento';

  @override
  String get equipmentProfilesHelpText =>
      'I profili equipaggiamento aiutano l\'app a suggerire esercizi compatibili con ciò che hai a disposizione. Crea profili diversi per location diverse (palestra, casa, viaggio).';

  @override
  String get equipmentProfileBadgeFull =>
      'Palestra completa con 6+ tipi di equipaggiamento';

  @override
  String get equipmentProfileBadgeHome =>
      'Setup casalingo con 3-5 tipi di equipaggiamento';

  @override
  String get equipmentProfileBadgeMinimal =>
      'Setup minimale con 1-2 tipi di equipaggiamento';

  @override
  String get equipmentProfilesEmpty => 'Nessun Profilo Equipaggiamento';

  @override
  String get equipmentProfilesEmptyDescription =>
      'Crea il tuo primo profilo equipaggiamento per ricevere raccomandazioni esercizi basate su ciò che hai disponibile.';

  @override
  String get equipmentProfileUpdated => 'Profilo aggiornato con successo';

  @override
  String get equipmentProfileCreated => 'Profilo creato con successo';

  @override
  String get equipmentProfileSaveError => 'Errore salvataggio profilo';

  @override
  String get equipmentProfileDeleteConfirmTitle => 'Eliminare Profilo?';

  @override
  String equipmentProfileDeleteConfirmMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"? Questa azione non può essere annullata.';
  }

  @override
  String get equipmentProfileDeleted => 'Profilo eliminato con successo';

  @override
  String get equipmentProfileDeleteError => 'Errore eliminazione profilo';

  @override
  String get equipmentProfileSetDefault => 'Profilo predefinito aggiornato';

  @override
  String get equipmentProfileDefaultError =>
      'Errore impostazione profilo predefinito';

  @override
  String get equipmentProfileDefault => 'Predefinito';

  @override
  String get equipmentProfileMakeDefault => 'Imposta Come Predefinito';

  @override
  String get equipmentProfileStepTitle => 'Equipaggiamento Disponibile';

  @override
  String get equipmentProfileStepDescription =>
      'Seleziona quale equipaggiamento hai disponibile per questa routine. Questo aiuterà a filtrare gli esercizi compatibili con il tuo setup.';

  @override
  String get equipmentProfileStepDescriptionOptional =>
      'Seleziona quale equipaggiamento hai disponibile. Puoi saltare questo passaggio e configurarlo più tardi.';

  @override
  String get equipmentProfileOptional => '(Opzionale)';

  @override
  String get equipmentProfileSkipForNow => 'Salta per ora';

  @override
  String get equipmentProfileSkipConfirmTitle =>
      'Saltare Profilo Equipaggiamento?';

  @override
  String get equipmentProfileSkipConfirmMessage =>
      'Puoi aggiungere un profilo equipaggiamento più tardi dalle Impostazioni. Senza, saranno disponibili tutti gli esercizi.';

  @override
  String get equipmentProfileStepInfoTitle => 'Perché è importante?';

  @override
  String get equipmentProfileStepInfoMessage =>
      'L\'app suggerirà solo esercizi compatibili con l\'equipaggiamento selezionato, garantendo che tu possa eseguire gli allenamenti raccomandati.';

  @override
  String get equipmentProfileManageInSettings =>
      'Gestisci Profili nelle Impostazioni';

  @override
  String get migrationWizardTitle => 'Cambio Profilo Equipaggiamento';

  @override
  String get migrationWizardImpactAnalysisTitle => 'Analisi Impatto';

  @override
  String get migrationWizardImpactSummary => 'Impact Summary';

  @override
  String get migrationWizardFromProfile => 'From';

  @override
  String get migrationWizardToProfile => 'To';

  @override
  String migrationWizardAffectedExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi',
      one: '1 esercizio',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardWithAlternatives => 'with alternatives';

  @override
  String get migrationWizardWithoutAlternatives => 'without alternatives';

  @override
  String migrationWizardAffectedRoutines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routine interessate',
      one: '1 routine interessata',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardAffectedTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count template interessati',
      one: '1 template interessato',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardReviewChanges => 'Review Changes';

  @override
  String get migrationWizardNoImpact =>
      'No exercises are affected by this change.';

  @override
  String get migrationWizardNoImpactMessage =>
      'Tutti gli esercizi nelle tue routine e template sono compatibili con il nuovo profilo equipaggiamento.';

  @override
  String get migrationWizardExerciseReviewTitle => 'Revisione Esercizi';

  @override
  String migrationWizardExerciseProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String migrationWizardRequiredEquipment(Object equipment) {
    return 'Richiede: $equipment (non disponibile)';
  }

  @override
  String get migrationWizardUsedIn => 'Usato in:';

  @override
  String get migrationWizardSuggestedAlternatives =>
      'Alternative Suggerite (Classificate):';

  @override
  String get migrationWizardNoAlternatives =>
      'No compatible alternatives found';

  @override
  String get migrationWizardNoAlternativesMessage =>
      'Nessun esercizio nel database corrisponde ai tuoi criteri di equipaggiamento. Puoi mantenere questo esercizio se prevedi di avere l\'equipaggiamento.';

  @override
  String migrationWizardSimilarityScore(Object score) {
    return 'Punteggio: $score';
  }

  @override
  String get migrationWizardReplaceWith => 'Sostituisci con';

  @override
  String get migrationWizardKeepExercise => 'Mantieni Comunque';

  @override
  String get migrationWizardKeepExerciseHint => 'I\'ll get this equipment';

  @override
  String get migrationWizardRemoveExercise => 'Rimuovi Esercizio';

  @override
  String get migrationWizardConfirmationTitle => 'Conferma Modifiche';

  @override
  String get migrationWizardConfirmationMessage =>
      'Rivedi le tue decisioni prima di applicare le modifiche:';

  @override
  String get migrationWizardSummaryReplaced => 'Replaced';

  @override
  String get migrationWizardSummaryKept => 'Kept';

  @override
  String get migrationWizardSummaryRemoved => 'Removed';

  @override
  String get migrationWizardWillUpdate => 'This will update';

  @override
  String get migrationWizardApplyChanges => 'Applica Modifiche';

  @override
  String get migrationWizardApplying => 'Applying changes...';

  @override
  String get migrationWizardSuccessTitle => 'Migrazione Completata';

  @override
  String get migrationWizardSuccessMessage =>
      'Il tuo profilo equipaggiamento è stato aggiornato con successo!';

  @override
  String get migrationWizardChangesApplied => 'Modifiche Applicate:';

  @override
  String migrationWizardExercisesReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi sostituiti',
      one: '1 esercizio sostituito',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi mantenuti',
      one: '1 esercizio mantenuto',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esercizi rimossi',
      one: '1 esercizio rimosso',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardUpdated => 'Updated';

  @override
  String get migrationWizardAnalyzing => 'Analisi in corso...';

  @override
  String get migrationWizardScanningRoutines => 'Scansione routine attive';

  @override
  String get migrationWizardScanningTemplates =>
      'Scansione template allenamento';

  @override
  String get migrationWizardFindingAffected => 'Ricerca esercizi interessati';

  @override
  String get migrationWizardGeneratingAlternatives => 'Generazione alternative';

  @override
  String get migrationWizardImpactSummaryTitle =>
      'Riepilogo Impatto Migrazione';

  @override
  String get migrationWizardTotalAffected => 'Totale Interessati:';

  @override
  String migrationWizardExercisesWithAlternatives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count con alternative',
      one: '1 con alternative',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesWithoutAlternatives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count senza alternative',
      one: '1 senza alternative',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardImpactLabel => 'Impatto:';

  @override
  String get migrationWizardNoImpactTitle => 'Nessun Impatto';

  @override
  String get migrationWizardContinueToReview => 'Continua alla Revisione';

  @override
  String get migrationWizardSkipToConfirmation => 'Salta alla Conferma';

  @override
  String migrationWizardExerciseXOfY(int current, int total) {
    return 'Esercizio $current di $total';
  }

  @override
  String get migrationWizardNoAlternativesFound =>
      'Nessuna alternativa compatibile trovata';

  @override
  String get migrationWizardPreviousExercise => 'Esercizio Precedente';

  @override
  String get migrationWizardNextExercise => 'Prossimo Esercizio';

  @override
  String get migrationWizardDecisionsSummary => 'Riepilogo Decisioni:';

  @override
  String migrationWizardReplaceAction(String original, String replacement) {
    return 'Sostituisci: $original → $replacement';
  }

  @override
  String migrationWizardKeepAction(String exercise) {
    return 'Mantieni: $exercise';
  }

  @override
  String migrationWizardRemoveAction(String exercise) {
    return 'Rimuovi: $exercise';
  }

  @override
  String get migrationWizardBackToReview => 'Torna alla Revisione';

  @override
  String get migrationWizardApplyingChanges => 'Applicazione modifiche...';

  @override
  String migrationWizardRoutinesUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routine aggiornate',
      one: '1 routine aggiornata',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardTemplatesUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count template aggiornati',
      one: '1 template aggiornato',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardProfileSwitched(String profileName) {
    return 'Profilo cambiato in: $profileName';
  }

  @override
  String get migrationWizardDone => 'Fatto';

  @override
  String get migrationWizardCancel => 'Annulla';

  @override
  String get migrationWizardCancelConfirmTitle => 'Annullare Migrazione?';

  @override
  String get migrationWizardCancelConfirmMessage =>
      'Le tue decisioni non saranno salvate e il profilo equipaggiamento non sarà modificato.';

  @override
  String migrationWizardProgress(int percent) {
    return 'Progresso: $percent%';
  }

  @override
  String migrationWizardError(String error) {
    return 'Errore durante la migrazione: $error';
  }

  @override
  String get migrationWizardRetry => 'Riprova';

  @override
  String get routineShiftTitle => 'Routine Spostata Automaticamente';

  @override
  String routineShiftMessage(String workoutName, String date) {
    return 'Abbiamo spostato \'$workoutName\' a $date. Confermi o vuoi skippare definitivamente?';
  }

  @override
  String get routineShiftConfirm => 'OK, mantieni spostamento';

  @override
  String get routineShiftRevert => 'Skippa definitivamente';

  @override
  String get routineShiftConfirmed => 'Spostamento confermato';

  @override
  String get routineShiftConfirmFailed => 'Errore durante la conferma';

  @override
  String get routineShiftReverted => 'Spostamento annullato, workout skippato';

  @override
  String get routineShiftRevertFailed => 'Errore durante l\'annullamento';

  @override
  String get routineShiftRevertConfirmTitle => 'Skippare Definitivamente?';

  @override
  String get routineShiftRevertConfirmMessage =>
      'Questo annullerà lo spostamento e segnerà il workout come skippato. Non è consigliato. Sei sicuro?';

  @override
  String routineDateFormat(int day, int month, int year) {
    return '$day/$month/$year';
  }

  @override
  String get exerciseRotationTitle => 'Rotazione Variazioni Esercizi';

  @override
  String get exerciseRotationSubtitle =>
      'Ruota automaticamente le variazioni degli esercizi ogni poche settimane per mantenere i tuoi allenamenti freschi e prevenire l\'adattamento';

  @override
  String get exerciseChangeVariation => 'Cambia Esercizio';

  @override
  String get exerciseChangeVariationSuccess =>
      'Esercizio cambiato con successo';

  @override
  String get rotationDueNow => 'Rotazione Pronta!';

  @override
  String get rotationNextScheduled => 'Prossima Rotazione Programmata';

  @override
  String get rotationReadyToApply => 'Pronto per applicare nuove variazioni';

  @override
  String get rotationApplyNow => 'Applica Rotazione Ora';

  @override
  String get rotationApplyEarly => 'Applica in Anticipo';

  @override
  String rotationInWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Tra $weeks settimane',
      one: 'Tra 1 settimana',
    );
    return '$_temp0';
  }

  @override
  String get rotationApplyConfirmMessage =>
      'Questo cambierà tutte le variazioni degli esercizi nella tua routine. Questa azione non può essere annullata. Continuare?';

  @override
  String get rotationAppliedSuccess =>
      'Rotazione applicata con successo! Tutte le variazioni degli esercizi sono state aggiornate.';

  @override
  String get rotationAppliedError =>
      'Impossibile applicare la rotazione. Riprova.';

  @override
  String get settingsSaved => 'Impostazioni salvate';

  @override
  String get noSimilarExercisesFound => 'Nessun esercizio simile trovato';

  @override
  String get sameMuscleGroup => 'Stesso gruppo muscolare';

  @override
  String get sameEquipment => 'Stessa attrezzatura';

  @override
  String get favorites => 'Preferiti';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get allEquipment => 'Tutta l\'attrezzatura';

  @override
  String get replaceExerciseWith => 'Sostituisci questo esercizio con:';

  @override
  String get skipWorkoutTitle => 'Salta Allenamento';

  @override
  String skipConsecutiveWarning(int count) {
    return 'Hai $count skip consecutivi. Considera di recuperarli per mantenere la costanza.';
  }

  @override
  String get skipWhyQuestion => 'Perché stai saltando?';

  @override
  String get skipWhatToDo => 'Cosa vuoi fare?';

  @override
  String get skipRecoverTitle => 'Recupera (+1 giorno)';

  @override
  String get skipRecoverSubtitle =>
      'Sposta l\'intera routine di 1 giorno per recuperare questo allenamento';

  @override
  String get skipPermanentlyTitle => 'Salta definitivamente';

  @override
  String get skipPermanentlySubtitle =>
      'Salta completamente questo allenamento (non recuperabile)';

  @override
  String get skipAdditionalNotes => 'Note aggiuntive (opzionale)';

  @override
  String get skipNotesHint => 'es., Non mi sento bene...';

  @override
  String get skipImpactTitle => 'Impatto sul tuo progresso';

  @override
  String get skipCurrentStreak => 'Streak Attuale';

  @override
  String get skipWillBeLost => 'Andrà perso';

  @override
  String get skipAdherenceRate => 'Tasso di Aderenza';

  @override
  String skipDaysLabel(int count) {
    return '$count giorni';
  }

  @override
  String get skipReasonSick => 'Malato';

  @override
  String get skipReasonInjury => 'Infortunio';

  @override
  String get skipReasonBusy => 'Impegnato';

  @override
  String get skipReasonTired => 'Stanco';

  @override
  String get skipReasonTravel => 'Viaggio';

  @override
  String get skipReasonWeather => 'Meteo';

  @override
  String get skipReasonOther => 'Altro';

  @override
  String get rotationPreviewTitle => 'Anteprima Modifiche Rotazione';

  @override
  String get rotationSelectAll => 'Seleziona Tutto';

  @override
  String get rotationDeselectAll => 'Deseleziona Tutto';

  @override
  String rotationSelectedCount(int selected, int total) {
    return '$selected di $total selezionati';
  }

  @override
  String get rotationCurrentLabel => 'Attuale';

  @override
  String get rotationNewLabel => 'Nuovo';

  @override
  String get rotationApplyChanges => 'Applica Modifiche';

  @override
  String get newRecordBadge => 'NUOVO RECORD!';

  @override
  String get progressTrend => 'Tendenza Progresso';

  @override
  String get statsBreakdown => 'Riepilogo Statistiche';

  @override
  String get comparisonAndContext => 'Confronto e Contesto';

  @override
  String get notesAndMedia => 'Note e Media';

  @override
  String get relatedSessions => 'Sessioni Correlate';

  @override
  String get shareFunctionalityComingSoon =>
      'Funzionalità di condivisione in arrivo';

  @override
  String get editFunctionalityComingSoon =>
      'Funzionalità di modifica in arrivo';

  @override
  String get deleteRecordTitle => 'Elimina Record';

  @override
  String get deleteRecordConfirmation =>
      'Sei sicuro di voler eliminare questo record personale?';

  @override
  String get bodyweightMultiplier => 'Moltiplicatore Peso Corporeo';

  @override
  String get estimatedOneRM => '1RM Stimato';

  @override
  String relativeToBodyweight(String weight) {
    return 'Relativo a $weight kg di peso corporeo';
  }

  @override
  String get usingBrzyckiFormula => 'Usando formula Brzycki';

  @override
  String get totalWeightReps => 'Peso totale × ripetizioni';

  @override
  String get noTrendDataAvailable => 'Nessun dato tendenza disponibile';

  @override
  String get timeRangeLabel30D => '30G';

  @override
  String get timeRangeLabel90D => '90G';

  @override
  String get timeRangeLabelAll => 'Tutto';

  @override
  String daysAgo(int days) {
    return '${days}g fa';
  }

  @override
  String weeksAgo(int weeks) {
    return '$weeks sett. fa';
  }

  @override
  String monthsAgo(String months) {
    return '$months mesi fa';
  }

  @override
  String dAgo(String days) {
    return '${days}g fa';
  }

  @override
  String setsCountShort(String count) {
    return '$count serie';
  }

  @override
  String volumeInTons(String value) {
    return '${value}t volume';
  }

  @override
  String get kgLabel => 'kg';

  @override
  String get debugLogsTitle => 'Log di Debug';

  @override
  String get debugLogsSubtitle => 'Configura categorie di log';

  @override
  String get debugLogsDescription =>
      'Abilita o disabilita categorie di log specifiche per ridurre il rumore nella console durante il debug. Tutte le categorie sono disabilitate di default.';

  @override
  String get debugLogsEnableAll => 'Abilita Tutti';

  @override
  String get debugLogsDisableAll => 'Disabilita Tutti';

  @override
  String debugLogsEnabledCount(int count) {
    return '$count abilitati';
  }

  @override
  String get debugLogsCategoriesTitle => 'Categorie di Log';

  @override
  String get debugLogsAllEnabled => 'Tutti i log abilitati con successo';

  @override
  String get debugLogsAllDisabled => 'Tutti i log disabilitati con successo';

  @override
  String debugLogsCategoryEnabled(String category) {
    return '$category abilitato';
  }

  @override
  String debugLogsCategoryDisabled(String category) {
    return '$category disabilitato';
  }

  @override
  String get countingModeWeighted => 'Peso + Reps';

  @override
  String get countingModeReps => 'Solo Reps';

  @override
  String get countingModeTime => 'Basato su tempo';

  @override
  String get refreshed => 'Aggiornato';

  @override
  String get versionInformation => 'Informazioni Versione';

  @override
  String get quickStartTitle => 'Benvenuto in GymBro!';

  @override
  String get quickStartSubtitle =>
      'Il tuo percorso fitness personalizzato inizia qui';

  @override
  String get quickStartQuestion => 'Hai esperienza in palestra?';

  @override
  String get quickStartQuestionDescription =>
      'Questo ci aiuta a personalizzare la tua esperienza';

  @override
  String get quickStartBeginner => 'No, sono nuovo 🌱';

  @override
  String get quickStartBeginnerDescription => 'Ti guiderò passo dopo passo';

  @override
  String get quickStartExpert => 'Sì, sono esperto 💪';

  @override
  String get quickStartExpertDescription => 'Levati di mezzo';

  @override
  String get quickStartContinue => 'Continua';

  @override
  String get quickStartSkip => 'Salta per ora';

  @override
  String get homeEmptyBeginnerTitle =>
      'Pronto per iniziare il tuo percorso fitness? 🌱';

  @override
  String get homeEmptyBeginnerDescription =>
      'Non preoccuparti, ti guiderò in ogni passo. Iniziamo con il tuo primo allenamento!';

  @override
  String get homeEmptyBeginnerCTA => 'Inizia il Mio Primo Allenamento';

  @override
  String get homeEmptyExpertTitle => 'Nessun allenamento attivo';

  @override
  String get homeEmptyExpertDescription =>
      'Inizia un allenamento veloce o usa un template';

  @override
  String get homeEmptyExpertCTA => 'Inizia Allenamento';

  @override
  String get useTemplate => 'Usa Template';

  @override
  String get bullet => 'Punto elenco';

  @override
  String get skipTour => 'Salta Tour';

  @override
  String get autoAdvance => 'Avanzamento automatico';

  @override
  String autoAdvanceIn(int seconds) {
    return 'Avanza automaticamente tra ${seconds}s';
  }

  @override
  String get tourAiCoachTitle => 'AI Coach 👋';

  @override
  String get tourAiCoachDescription =>
      'Ciao! Sono il tuo AI Coach.\nTi darò consigli personalizzati dopo il tuo primo allenamento!';

  @override
  String get tourFabTitle => 'Avvio Rapido ⚡';

  @override
  String get tourFabDescription =>
      'Premi qui per iniziare un allenamento velocemente.\nÈ il modo più semplice per tracciare i tuoi progressi!';

  @override
  String get tourSmartWorkoutTitle => 'Allenamento Intelligente 🧠';

  @override
  String get tourSmartWorkoutDescription =>
      'Oppure lascia che io crei l\'allenamento perfetto per te basato sui tuoi obiettivi!';

  @override
  String get tourAnalyticsTitle => 'Analytics - I Tuoi Progressi 📊';

  @override
  String get tourAnalyticsDescription => 'Qui trovi grafici dettagliati di:';

  @override
  String get tourAnalyticsBullet1 => 'Volume totale per allenamento';

  @override
  String get tourAnalyticsBullet2 => 'Forza per esercizio (1RM stimato)';

  @override
  String get tourAnalyticsBullet3 => 'Record personali e miglioramenti';

  @override
  String get tourHistoryTitle => 'Storico Allenamenti 📅';

  @override
  String get tourHistoryDescription =>
      'Qui trovi lo storico completo dei tuoi allenamenti.\nRileggi le sessioni passate e traccia la tua costanza!';

  @override
  String get tourRoutineCenterTitle => 'Routine Center - Training Avanzato 🏋️';

  @override
  String get tourRoutineCenterDescription =>
      'Crea programmi multi-settimana con:';

  @override
  String get tourRoutineCenterBullet1 =>
      'Periodizzazione (forza → ipertrofia → deload)';

  @override
  String get tourRoutineCenterBullet2 => 'Swap automatico tra template';

  @override
  String get tourRoutineCenterBullet3 => 'Tracking progressi per ogni fase';

  @override
  String get tourCommunityTitle => 'Community 🤝';

  @override
  String get tourCommunityDescription =>
      'Connettiti con altri atleti per motivazione e supporto!';

  @override
  String get tourNotificationsTitle => 'Notifiche 🔔';

  @override
  String get tourNotificationsDescription =>
      'Le notifiche ti terranno aggiornato su traguardi e consigli!';

  @override
  String get suggestedNextWorkout => 'Prossimo Allenamento Suggerito';

  @override
  String get startThisWorkout => 'Inizia Questo Allenamento';

  @override
  String get alternatives => 'Alternative';

  @override
  String get whyThisSuggestion => 'Perché Questo Suggerimento?';

  @override
  String get confidence => 'Sicurezza';

  @override
  String get levelPattern => 'Pattern';

  @override
  String get levelRoutine => 'Routine';

  @override
  String get levelFrequent => 'Frequente';

  @override
  String get levelDefault => 'Predefinito';

  @override
  String get levelAlternative => 'Alternativo';

  @override
  String get notEnoughWorkoutData => 'Dati allenamenti insufficienti';

  @override
  String get completeWorkoutsForSuggestions =>
      'Completa almeno 6 allenamenti per ricevere suggerimenti personalizzati';

  @override
  String get createWorkout => 'Crea Allenamento';

  @override
  String get analyzingWorkoutPattern =>
      'Analisi del tuo pattern di allenamento...';

  @override
  String get workoutSuggestionError =>
      'Impossibile generare suggerimento allenamento';

  @override
  String get pauseRoutine => 'Metti in Pausa';

  @override
  String get pauseRoutineTitle => 'Metti in Pausa Questa Routine';

  @override
  String get pauseRoutineDescription =>
      'La tua routine sarà in pausa durante questo periodo. Non riceverai promemoria allenamenti.';

  @override
  String get pauseReason => 'Motivo della pausa';

  @override
  String get pauseReasonInjury => 'Infortunio';

  @override
  String get pauseReasonSick => 'Malattia';

  @override
  String get pauseReasonVacation => 'Vacanza';

  @override
  String get pauseReasonBusy => 'Troppo Impegnato';

  @override
  String get pauseReasonBurnout => 'Burnout';

  @override
  String get pauseReasonOther => 'Altro';

  @override
  String get startDate => 'Data Inizio';

  @override
  String get endDate => 'Data Fine';

  @override
  String get pauseNotes => 'Note (opzionale)';

  @override
  String get pauseNotesHint =>
      'Es: Infortunio spalla - evitare pressioni sopra la testa';

  @override
  String get confirmPause => 'Metti in Pausa';

  @override
  String get pausedBadge => 'In Pausa';

  @override
  String pausedUntil(String date) {
    return 'In pausa fino al $date';
  }

  @override
  String get daysRemaining => 'giorni rimanenti';

  @override
  String get resumeRoutine => 'Riprendi Routine';

  @override
  String get routineResumed => 'Routine ripresa!';

  @override
  String get pauseValidationStartInPast =>
      'La data di inizio non può essere nel passato';

  @override
  String get pauseValidationEndBeforeStart =>
      'La data di fine deve essere dopo la data di inizio';

  @override
  String pauseValidationTooLong(int maxDays) {
    return 'La pausa non può superare $maxDays giorni';
  }

  @override
  String pauseValidationOverlap(String date) {
    return 'Routine già in pausa fino al $date';
  }

  @override
  String get conflictingWorkouts =>
      'Allenamenti Programmati nel Periodo di Pausa';

  @override
  String conflictingWorkoutsMessage(int count) {
    return 'Hai $count allenamenti programmati durante questa pausa. Verranno saltati automaticamente.';
  }

  @override
  String get confirmAndPause => 'Conferma e Metti in Pausa';

  @override
  String get selectDate => 'Seleziona Data';

  @override
  String get pause => 'Pausa';

  @override
  String get routinePaused => 'Routine messa in pausa con successo';

  @override
  String get routineTemplateCreatedSuccess =>
      'Template creato! Selezionalo qui sotto per continuare.';

  @override
  String get levelSystem => 'Sistema Livelli';

  @override
  String get currentLevel => 'Livello Attuale';

  @override
  String get toNextLevel => 'al prossimo livello';

  @override
  String get level => 'Livello';

  @override
  String get current => 'Attuale';

  @override
  String get elite => 'Élite';

  @override
  String get novice => 'Principiante';

  @override
  String get expert => 'Esperto';

  @override
  String get master => 'Maestro';

  @override
  String get grandmaster => 'Gran Maestro';

  @override
  String get champion => 'Campione';

  @override
  String get legend => 'Leggenda';

  @override
  String get titan => 'Titano';

  @override
  String get levelDesc1 =>
      'Stai appena iniziando! Completa i tuoi primi allenamenti per salire di livello.';

  @override
  String get levelDesc2 =>
      'Hai completato i tuoi primi allenamenti. Mantieni lo slancio!';

  @override
  String get levelDesc3 =>
      'Stai costruendo solide abitudini di allenamento. La costanza è la chiave!';

  @override
  String get levelDesc4 =>
      'Atleta avanzato! La tua dedizione si riflette nei tuoi progressi.';

  @override
  String get levelDesc5 =>
      'Livello esperto raggiunto! Stai padroneggiando il tuo allenamento.';

  @override
  String get levelDesc6 =>
      'Maestro del fitness! La tua costanza ispira gli altri.';

  @override
  String get levelDesc7 =>
      'Status di Gran Maestro! Pochi raggiungono questo livello di dedizione.';

  @override
  String get levelDesc8 => 'Campione! Sei nel livello più alto degli atleti.';

  @override
  String get levelDesc9 =>
      'Status leggendario! La tua disciplina è ineguagliabile.';

  @override
  String get levelDesc10 =>
      'Titano! Il livello massimo di maestria nel fitness.';

  @override
  String get benefit1_1 => 'Traccia i tuoi primi allenamenti';

  @override
  String get benefit1_2 => 'Impara le basi del monitoraggio progressi';

  @override
  String get benefit2_1 => 'Sblocca analytics degli allenamenti';

  @override
  String get benefit2_2 => 'Accedi a grafici progressi base';

  @override
  String get benefit3_1 => 'Accesso libreria esercizi avanzata';

  @override
  String get benefit3_2 => 'Template allenamenti disponibili';

  @override
  String get benefit3_3 => 'Creazione allenamenti personalizzati';

  @override
  String get benefit4_1 => 'Tracciamento record personali';

  @override
  String get benefit4_2 => 'Dashboard analytics avanzata';

  @override
  String get benefit4_3 => 'Insights su volume e intensità';

  @override
  String get benefit5_1 => 'Raccomandazioni allenamento esperte';

  @override
  String get benefit5_2 => 'Suggerimenti periodizzazione';

  @override
  String get benefit5_3 => 'Ottimizzazione recupero';

  @override
  String get benefit6_1 => 'Programmi allenamento livello maestro';

  @override
  String get benefit6_2 => 'Tracciamento progressione avanzato';

  @override
  String get benefit6_3 => 'Analisi bilanciamento gruppi muscolari';

  @override
  String get benefit7_1 => 'Protocolli allenamento élite';

  @override
  String get benefit7_2 => 'Strumenti preparazione gare';

  @override
  String get benefit7_3 => 'Ottimizzazione performance';

  @override
  String get benefit8_1 => 'Strategie allenamento da campione';

  @override
  String get benefit8_2 => 'Pianificazione picco performance';

  @override
  String get benefit8_3 => 'Protocolli recupero avanzati';

  @override
  String get benefit9_1 => 'Metodi allenamento leggendari';

  @override
  String get benefit9_2 => 'Analytics livello professionista';

  @override
  String get benefit9_3 => 'Tracciamento performance definitivo';

  @override
  String get benefit10_1 => 'Maestria allenamento da titano';

  @override
  String get benefit10_2 => 'Ecosistema allenamento completo';

  @override
  String get benefit10_3 => 'Massimo potenziale sbloccato';

  @override
  String get averageEffortLevel => 'Livello Sforzo Medio';

  @override
  String get fitnessLevel => 'Livello Fitness';

  @override
  String get levelAndXpOnly => 'Solo Livello & XP';

  @override
  String levelRequired(int level) {
    return 'Richiesto Livello $level';
  }

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Gio';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Dom';

  @override
  String get velocityAnalytics => 'Analytics Velocità';

  @override
  String get performanceHeatmap => 'Mappa Performance';

  @override
  String get loadVelocity => 'Carico-Velocità';

  @override
  String get velocity => 'Velocità';

  @override
  String get load => 'Carico';

  @override
  String get minVelocity => 'Velocità Min';

  @override
  String get avgVelocityLoss => 'Perdita Velocità Media';

  @override
  String get optimalLoad => 'Carico Ottimale';

  @override
  String get executionTime => 'Tempo Esecuzione';

  @override
  String get formScore => 'Punteggio Forma';

  @override
  String get quality => 'Qualità';

  @override
  String get fatigueIndex => 'Indice Fatica';

  @override
  String get explosiveZone => 'Zona Esplosiva';

  @override
  String get speedZone => 'Zona Velocità';

  @override
  String get zones => 'Zone';

  @override
  String get analyzingVelocityData => 'Analisi dati velocità...';

  @override
  String get insufficientVelocityData => 'Dati velocità insufficienti';

  @override
  String get velocityAnalysisError => 'Errore analisi velocità';

  @override
  String get noPerformanceData => 'Nessun dato performance disponibile';

  @override
  String get startWorkoutToSeeData => 'Inizia un allenamento per vedere i dati';

  @override
  String get keyInsights => 'Insights Chiave';

  @override
  String get tapForMoreInfo => 'Tocca per più info';

  @override
  String get tapToCollapse => 'Tocca per comprimere';

  @override
  String get whatDoesThisMean => 'Cosa significa?';

  @override
  String get helpTitle => 'Aiuto';

  @override
  String get defaultHelpContent => 'Maggiori informazioni in arrivo';

  @override
  String get formula => 'Formula';

  @override
  String get example => 'Esempio';

  @override
  String get generalTip => 'Consiglio Generale';

  @override
  String get volumeExplanation =>
      'Il volume è la quantità totale di lavoro che svolgi nei tuoi allenamenti. Tracciamo la frequenza settimanale per mostrare la tua progressione nel tempo. Una progressione positiva significa che stai facendo più allenamenti rispetto alla settimana scorsa!';

  @override
  String get volumeExplanationDesc =>
      'Volume totale = Serie × Ripetizioni × Peso. Misura il carico totale di allenamento.';

  @override
  String get volumeTip =>
      'Aumenta gradualmente il volume del 5-10% a settimana per evitare sovrallenamento.';

  @override
  String get intensityExplanation => 'Intensità Allenamento';

  @override
  String get intensityExplanationDesc =>
      'Percentuale del tuo massimale (1RM) usata nell\'allenamento.';

  @override
  String get intensityTip =>
      'Varia intensità: 60-75% per volume, 80-90% per forza, 90%+ per potenza.';

  @override
  String get setsExplanation => 'Serie Totali';

  @override
  String get setsExplanationDesc =>
      'Numero di serie eseguite su tutti gli esercizi.';

  @override
  String get setsTip =>
      'La ricerca suggerisce 10-20 serie per gruppo muscolare a settimana per ipertrofia.';

  @override
  String get streakExplanation => 'Serie Allenamenti';

  @override
  String get streakExplanationDesc =>
      'Giorni consecutivi con almeno un allenamento completato.';

  @override
  String get streakTip =>
      'La costanza batte l\'intensità. Anche allenamenti leggeri mantengono la serie.';

  @override
  String get oneRmExplanation => 'Massimale (1RM)';

  @override
  String get oneRmExplanationDesc =>
      'Peso massimo che puoi sollevare per una singola ripetizione.';

  @override
  String get oneRmTip =>
      'Testa il massimale ogni 4-8 settimane per monitorare i progressi in modo sicuro.';

  @override
  String get whatIsTotalVolume => 'Cos\'è il Volume Totale?';

  @override
  String get totalVolumeExplanation =>
      'Peso totale sollevato su tutte le serie e ripetizioni (Serie × Rip × Peso).';

  @override
  String get totalVolumeExample =>
      'Esempio: 3 serie × 10 rip × 50kg = 1.500kg volume totale';

  @override
  String get whatAreTotalSets => 'Cosa sono le Serie Totali?';

  @override
  String get totalSetsExplanation =>
      'Numero di serie eseguite su tutti gli esercizi del tuo allenamento.';

  @override
  String get totalSetsExample =>
      'Esempio: 4 serie squat + 3 serie panca = 7 serie totali';

  @override
  String get whatIsWorkoutFrequency => 'Cos\'è la Frequenza Allenamento?';

  @override
  String get workoutFrequencyExplanation =>
      'Numero di sessioni di allenamento a settimana o stimoli per gruppo muscolare.';

  @override
  String get workoutFrequencyExample =>
      'Esempio: Allenare petto 2 volte a settimana = frequenza 2×';

  @override
  String get whatIsPersonalRecord => 'Cos\'è un Record Personale (PR)?';

  @override
  String get personalRecordExplanation =>
      'La tua migliore performance per un esercizio specifico (peso max, ripetizioni o volume).';

  @override
  String get personalRecordExample =>
      'Esempio: Panca 100kg × 5 rip supera il tuo precedente 95kg × 5 rip';

  @override
  String get whatIsMuscleBalance => 'Cos\'è il Bilanciamento Muscolare?';

  @override
  String get muscleBalanceExample =>
      'Esempio: Allenare petto 3 volte a settimana ma schiena solo 1 volta crea squilibrio';

  @override
  String get daysToGo => 'giorni rimanenti';

  @override
  String get vsLastPeriod => 'vs periodo precedente';

  @override
  String get lastYear => 'Anno Scorso';

  @override
  String get shade400 => 'Tonalità 400';

  @override
  String lastNMonths(int n) {
    return 'Ultimi $n mesi';
  }

  @override
  String lastNDays(int n) {
    return 'Ultimi $n giorni';
  }

  @override
  String get completeDayWithWorkout => 'Completa Giorno con Workout';

  @override
  String get selectWorkoutToLinkTo => 'Seleziona workout da collegare a';

  @override
  String get completeWithoutWorkout => 'Completa senza workout';

  @override
  String get noRecentWorkoutsFound => 'Nessun workout recente trovato';

  @override
  String get completeDayWithoutWorkout =>
      'Completa questo giorno senza collegare un workout';

  @override
  String get completeDay => 'Completa Giorno';

  @override
  String get failedToLoadWorkouts => 'Impossibile caricare i workout';

  @override
  String get dayCompletedWithWorkout => 'Giorno completato con workout!';

  @override
  String get dayCompletedManually => 'Giorno completato manualmente';

  @override
  String get failedToCompleteDay => 'Impossibile completare il giorno';

  @override
  String get changeCountingFormat => 'Cambia formato counting';

  @override
  String get currentFormat => 'Formato attuale';

  @override
  String get countingModeWeightedDesc => 'Input: Peso (kg/lb) + Ripetizioni';

  @override
  String get countingModeWeightedExample => 'Esempio: 80kg × 10 rip';

  @override
  String get countingModeRepsDesc => 'Input: Solo ripetizioni (senza peso)';

  @override
  String get countingModeRepsExample => 'Esempio: 15 rip';

  @override
  String get countingModeTimeDesc => 'Input: Durata (mm:ss)';

  @override
  String get countingModeTimeExample => 'Esempio: 1:30 (90 secondi)';

  @override
  String get confirmChange => 'Conferma cambio';

  @override
  String get countingModeWarningTitle => 'Attenzione';

  @override
  String countingModeWarningMessage(int count, String fromMode, String toMode) {
    return 'Hai $count serie completate con formato \"$fromMode\".\n\nCambiare in \"$toMode\" potrebbe invalidare i dati esistenti.';
  }

  @override
  String get countingModeWarningInfo =>
      'Cambiare formato durante un workout non è consigliato. Considera di finire prima il workout.';

  @override
  String get keepData => 'Mantieni dati';

  @override
  String get resetAll => 'Resetta Tutto';

  @override
  String get countingModeChanged => 'Formato counting aggiornato!';

  @override
  String get analyticsFeedbackThankYou => 'Grazie per il tuo feedback!';

  @override
  String get analyticsFeedbackThankYouSubtitle =>
      'Il tuo feedback ci aiuta a migliorare l\'esperienza delle analitiche';

  @override
  String get analyticsFeedbackQuestion =>
      'Questa vista delle analitiche è utile?';

  @override
  String get analyticsFeedbackHelpful => 'Utile';

  @override
  String get analyticsFeedbackNotHelpful => 'Non utile';

  @override
  String get analyticsFeedbackCommentPlaceholder =>
      'Raccontaci di più (opzionale)';

  @override
  String get analyticsFeedbackSubmitting => 'Invio in corso...';

  @override
  String get analyticsFeedbackSubmit => 'Invia feedback';

  @override
  String get analyticsFeedbackError =>
      'Impossibile inviare il feedback. Riprova.';

  @override
  String get analyticsFeedbackSuccess => 'Feedback inviato con successo!';

  @override
  String autoEnabledMaster(String masterName) {
    return '✅ $masterName auto-abilitato (richiesto per questa funzione)';
  }

  @override
  String dependentsDisabled(int count) {
    return '⚠️ $count funzioni dipendenti auto-disabilitate';
  }

  @override
  String get quickInfoIconTitle => 'Icona Info Rapida';

  @override
  String get quickInfoIconDescription => 'Tocca per dettagli esercizio';

  @override
  String get quickInfoIconTooltip =>
      'Mostra modal con informazioni esercizio, cues e suggerimenti';

  @override
  String get quickWarmupIconTitle => 'Icona Riscaldamento';

  @override
  String get quickWarmupIconDescription =>
      'Tocca per suggerimenti riscaldamento';

  @override
  String get quickWarmupIconTooltip =>
      'Mostra raccomandazioni serie di riscaldamento basate sul peso di lavoro';

  @override
  String get quickPreventionIconTitle => 'Icona Prevenzione';

  @override
  String get quickPreventionIconDescription =>
      'Tocca per consigli prevenzione infortuni';

  @override
  String get quickPreventionIconTooltip =>
      'Mostra consigli prevenzione infortuni ed esercizi mobilità';

  @override
  String get exerciseNotesTitle => 'Note Esercizio';

  @override
  String get exerciseNotesDescription => 'Aggiungi note su tecnica e cues';

  @override
  String get exerciseNotesTooltip =>
      'Note personali visibili solo a te durante allenamenti';

  @override
  String get exerciseInsightsTitle => 'Analisi Esercizio';

  @override
  String get exerciseInsightsDescription => 'Visualizza grafici e statistiche';

  @override
  String get exerciseInsightsTooltip =>
      'Grafici analytics con volume, PR e trend progresso';

  @override
  String get insightsPerformanceWarning =>
      'ℹ️ I grafici potrebbero rallentare su dispositivi meno recenti';

  @override
  String modeSwitchWarningTitle(String mode) {
    return 'Passare a Modalità $mode?';
  }

  @override
  String modeSwitchWarningMessage(String mode) {
    return 'Questo resetterà le tue impostazioni personalizzate ai default $mode.';
  }

  @override
  String get modeSwitchUndoHint =>
      'Avrai 5 secondi per annullare dopo la conferma.';

  @override
  String get undoSuccessful => '✅ Impostazioni ripristinate';

  @override
  String get sortByHelpful => 'Più Utili';

  @override
  String get sortByRecent => 'Più Recenti';

  @override
  String get sortBySaved => 'Più Salvati';

  @override
  String get sortByTrending => 'Trending';

  @override
  String get filterByDifficulty => 'Difficoltà';

  @override
  String get filterByAuthorTier => 'Autore';

  @override
  String get filterByDateRange => 'Periodo';

  @override
  String get resetFilters => 'Ripristina';

  @override
  String get dateFrom => 'Da';

  @override
  String get dateTo => 'A';

  @override
  String get contributionTypeCorrection => 'Correzione';

  @override
  String get contributionTypeTip => 'Consiglio';

  @override
  String get contributionTypeWarning => 'Avviso';

  @override
  String get contributionTypeVariant => 'Variante';

  @override
  String get contributionTypeTranslation => 'Traduzione';

  @override
  String get contributionTypeTechnique => 'Tecnica';

  @override
  String get difficultyBeginner => 'Principiante';

  @override
  String get difficultyIntermediate => 'Intermedio';

  @override
  String get difficultyAdvanced => 'Avanzato';

  @override
  String get authorTierCommunity => 'Community';

  @override
  String get authorTierExpert => 'Esperto';

  @override
  String get authorTierAdmin => 'Admin';

  @override
  String get saves => 'Salvati';

  @override
  String get views => 'Visualizzazioni';

  @override
  String get comments => 'Commenti';

  @override
  String get upvotes => 'Mi piace';

  @override
  String get bookmarkContribution => 'Salva contributo';

  @override
  String get saveContribution => 'Salva';

  @override
  String get unsaveContribution => 'Rimuovi';

  @override
  String get saved => 'Salvato';

  @override
  String get legalDisclaimerTitle => 'Disclaimer Medico';

  @override
  String get legalDisclaimerContent =>
      '⚠️ AVVISO IMPORTANTE\n\nFITlog Pro è uno strumento di tracciamento workout.\n\nNON è sostituto di:\n• Consulenza medica\n• Personal trainer\n• Medico sportivo\n• Consulente fitness\n\nDEVI:\n✓ Consultare un medico prima di iniziare qualsiasi programma di allenamento\n✓ Interrompere immediatamente in caso di dolore o disagio\n✓ Assumerti la piena responsabilità per la tua sicurezza durante l\'allenamento\n\nIl fornitore NON è responsabile per:\n• Infortuni fisici\n• Peggioramento condizioni mediche\n• Mancato raggiungimento obiettivi fitness\n\nAccettando, riconosci questi rischi e accetti i Termini di Servizio e l\'Informativa Privacy.';

  @override
  String get legalDisclaimerAccept => 'Accetto';

  @override
  String get legalDisclaimerDecline => 'Rifiuto';

  @override
  String get legalDocuments => 'Documenti Legali';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get privacyPolicySubtitle =>
      'Come gestiamo i tuoi dati (conforme GDPR)';

  @override
  String get termsOfService => 'Termini di Servizio';

  @override
  String get tosSubtitle => 'Accordi utente e limitazioni di responsabilità';

  @override
  String get disclaimerSubtitle => 'Informazioni importanti sulla sicurezza';

  @override
  String get errorLoadingDocument =>
      'Errore nel caricamento del documento. Riprova.';

  @override
  String get apreCalculationMetadata => 'Analisi Calcolo';

  @override
  String get apreShowCalculationDetails => 'Mostra Dettagli Calcolo';

  @override
  String get apreHideCalculationDetails => 'Nascondi Dettagli Calcolo';

  @override
  String get apreFormula => 'Formula';

  @override
  String get apreDataPoints => 'Dati Analizzati';

  @override
  String get apreDataAge => 'Età Dati';

  @override
  String get apreStandardDeviation => 'Variabilità';

  @override
  String get apreConfidence => 'Affidabilità';

  @override
  String get apreLastCalculation => 'Ultimo Aggiornamento';

  @override
  String apreDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni fa',
      one: 'Ieri',
      zero: 'Oggi',
    );
    return '$_temp0';
  }

  @override
  String get apreNoHistory => 'Nessuno Storico Disponibile';

  @override
  String get apreNoHistoryDescription =>
      'Nessun dato storico disponibile per i calcoli APRE. Seleziona come vuoi stimare il tuo 1RM per iniziare.';

  @override
  String get apreOptionFromLastWorkout => 'Dall\'Ultimo Allenamento';

  @override
  String get apreOptionManualEstimate => 'Stima Manuale';

  @override
  String get apreOptionTestSet => 'Serie di Test';

  @override
  String get apreOptionFromLastWorkoutDescription =>
      'Usa peso/ripetizioni dell\'ultima serie come stima';

  @override
  String get apreOptionManualEstimateDescription =>
      'Inserisci direttamente il 1RM stimato';

  @override
  String get apreOptionTestSetDescription =>
      'Guida per fare prima una serie di test';

  @override
  String get apreEnter1RM => 'Inserisci 1RM Stimato (kg)';

  @override
  String get aprePreviewWeights => 'Anteprima Pesi';

  @override
  String get apreContinue => 'Continua';

  @override
  String get apreCancel => 'Annulla';

  @override
  String get ageGateTitle => 'Verifica la Tua Età';

  @override
  String get ageGateInstructions =>
      'Inserisci la tua data di nascita per continuare.';

  @override
  String get ageGateBirthDate => 'Data di Nascita';

  @override
  String get ageGateContinue => 'Continua';

  @override
  String get ageRestrictionTitle => 'Limitazione di Età';

  @override
  String get ageRestrictionMessage =>
      'Devi avere almeno 14 anni per usare FITlog Pro.\n\nQuesto requisito è richiesto dal GDPR (Regolamento UE 2016/679) e dalle leggi italiane sulla privacy.';

  @override
  String get ageRestrictionOk => 'Ho Capito';

  @override
  String get ageMinorWarningTitle => 'Avviso Importante per Minori';

  @override
  String get ageMinorWarningMessage =>
      'Se hai tra 14 e 17 anni:\n\n• DEVI avere il consenso dei genitori per usare questa app\n• DEVI consultare un medico prima di allenarti\n• DEVI essere supervisionato da un adulto durante gli allenamenti\n• I tuoi genitori sono legalmente responsabili per il tuo uso di questa app\n\nConfermi di avere il consenso dei genitori?';

  @override
  String get ageMinorWarningConfirm => 'Sì, Ho il Consenso';

  @override
  String get ageMinorWarningDecline => 'No';

  @override
  String get footerDisclaimerShort =>
      'NON è consulenza medica • Consulta un medico • Uso a tuo rischio';

  @override
  String get footerDisclaimerTapHint => 'Tocca per disclaimer completo';

  @override
  String get apreProtocolChangeWarningTitle => 'Allenamento in Corso';

  @override
  String get apreProtocolChangeWarningMessage =>
      'Non puoi cambiare protocollo APRE durante un allenamento attivo. Completa prima l\'allenamento corrente, poi torna per modificare le impostazioni del protocollo.';

  @override
  String get apreGotIt => 'Ho capito';

  @override
  String get apreCalculationMethodTitle => 'Metodo Calcolo APRE';

  @override
  String get apreCalculationMethodDescription =>
      'Scegli come vengono selezionate le serie storiche per la stima del 1RM negli allenamenti APRE. Strategie diverse ottimizzano recency, volume dati o stabilità.';

  @override
  String get about => 'About';

  @override
  String get accurate => 'Accurate';

  @override
  String get achievementsCopied => 'Achievements copied';

  @override
  String get activeDays => 'Active days';

  @override
  String get activeMatches => 'Active corrispondenze';

  @override
  String get addRep => 'Aggiungi ripetizione';

  @override
  String get advancedTemplate => 'Advanced modello';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get ageRange => 'Age range';

  @override
  String get applyProgressiveOverload => 'Apply progressive overload';

  @override
  String get availability => 'Disponibilità';

  @override
  String get averageVolume => 'Average volume';

  @override
  String get avgPerWeek => 'Avg per week';

  @override
  String get batterySaverActive => 'Battery saver active';

  @override
  String get beginnerTemplate => 'Beginner modello';

  @override
  String get bestDay => 'Best day';

  @override
  String get bio => 'Bio';

  @override
  String get blockUser => 'Block user';

  @override
  String get boosted => 'Boosted';

  @override
  String get bothWorkoutAndGym => 'Both allenamento and gym';

  @override
  String get buddyMatching => 'Compagno accoppiamento';

  @override
  String get changeLayout => 'Change layout';

  @override
  String get cityPicker => 'Città selettore';

  @override
  String get clearAllSets => 'Pulisci all sets';

  @override
  String get clearDemoData => 'Pulisci demo dati';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get compactView => 'Compact visualizza';

  @override
  String get comparedTo => 'Confrontato a';

  @override
  String get comparedToLast => 'Confrontato a ultimo';

  @override
  String get comparedToPrevious => 'Confrontato a precedente';

  @override
  String get completeAllSets => 'Completa all sets';

  @override
  String get completeAnalysis => 'Completa analysis';

  @override
  String get completeStatistics => 'Completa statistiche';

  @override
  String get consecutiveDays => 'Consecutive days';

  @override
  String get copyFromLastWorkout => 'Copiato from ultimo allenamento';

  @override
  String get criticalPriority => 'Critical priority';

  @override
  String get customDateRange => 'Custom date range';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get dailyTrend => 'Daily trend';

  @override
  String get dataExported => 'Dati exported';

  @override
  String get dateRange => 'Date range';

  @override
  String get declined => 'Peggiorato';

  @override
  String get demoProfiles => 'Demo profiles';

  @override
  String get detailedStats => 'Detailed stats';

  @override
  String get developmentMode => 'Sviluppo modalità';

  @override
  String get discardWorkoutMessage => 'Discard allenamento message';

  @override
  String get discardWorkoutTitle => 'Discard allenamento title';

  @override
  String get distance => 'Distance';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get duplicateWorkout => 'Duplicate allenamento';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get editTemplateDescription => 'Modifica modello descrizione';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get enableLocationForBetterMatches =>
      'Enable location per better corrispondenze';

  @override
  String get endWorkoutTitle => 'End allenamento title';

  @override
  String get endurance => 'Endurance';

  @override
  String get errorAuth => 'Errore auth';

  @override
  String get errorGeneric => 'Errore generic';

  @override
  String get errorInvalidEmail => 'Errore invalid email';

  @override
  String get errorNetwork => 'Errore network';

  @override
  String get errorUserNotFound => 'Errore user not found';

  @override
  String get errorWeakPassword => 'Errore weak password';

  @override
  String get essentialStatistics => 'Essential statistiche';

  @override
  String get evening => 'Evening';

  @override
  String get executing => 'Executing';

  @override
  String get expertTemplate => 'Expert modello';

  @override
  String get export => 'Esporta';

  @override
  String get exporting => 'Exporting';

  @override
  String get failed => 'Failed';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get fatto => 'Fatto';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get filterWorkouts => 'Filtra workouts';

  @override
  String get findYourWorkoutPartner => 'Trova your allenamento partner';

  @override
  String get flexibility => 'Flexibility';

  @override
  String get form => 'Form';

  @override
  String get fullView => 'Full visualizza';

  @override
  String get generalFitness => 'General fitness';

  @override
  String get goPremium => 'Go premium';

  @override
  String get gymBuddyOnly => 'Gym compagno only';

  @override
  String get hypertrophy => 'Hypertrophy';

  @override
  String get iceBreakerCategoryCasual => 'Rompighiaccio  category casual';

  @override
  String get iceBreakerCategoryExperience =>
      'Rompighiaccio  category experience';

  @override
  String get iceBreakerCategoryFitness => 'Rompighiaccio  category fitness';

  @override
  String get iceBreakerCategoryGoals => 'Rompighiaccio  category goals';

  @override
  String get iceBreakerCategoryMotivation =>
      'Rompighiaccio  category motivation';

  @override
  String get iceBreakerCategoryWorkout => 'Rompighiaccio  category allenamento';

  @override
  String get iceBreakers => 'Rompighiaccio rompighiaccio';

  @override
  String get improved => 'Migliorato';

  @override
  String get improvementDetected => 'Miglioramento rilevato';

  @override
  String get instagramHandle => 'Instagram handle';

  @override
  String get instagramVerified => 'Instagram verified';

  @override
  String get intensity => 'Intensità';

  @override
  String get intermediateTemplate => 'Intermediate modello';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get itsAMatch => 'È a abbinamento';

  @override
  String get km => 'Km';

  @override
  String get last => 'Ultimo';

  @override
  String get lastSync => 'Ultimo sync';

  @override
  String get like => 'Like';

  @override
  String get localStorageOnly => 'Local storage only';

  @override
  String get location => 'Location';

  @override
  String get locationHelpsFindNearbyBuddies =>
      'Location helps trova nearby buddies';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionExplanation => 'Location permission explanation';

  @override
  String get locationPermissionGranted => 'Location permission granted';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get locationUpdateError => 'Location update errore';

  @override
  String get locationUpdated => 'Location updated';

  @override
  String get lookingForWorkoutBuddy => 'Cercando per allenamento compagno';

  @override
  String get matchFilters => 'Abbinamento filters';

  @override
  String get matchingPurpose => 'Accoppiamento purpose';

  @override
  String get matchingPurposeBoth => 'Accoppiamento purpose both';

  @override
  String get matchingPurposeGymBuddy => 'Accoppiamento purpose gym compagno';

  @override
  String get matchingPurposeOpenToEverything =>
      'Accoppiamento purpose apri a everything';

  @override
  String get matchingPurposeWorkoutPartner =>
      'Accoppiamento purpose allenamento partner';

  @override
  String get maxAge => 'Max age';

  @override
  String get maxDistance => 'Max distance';

  @override
  String get midday => 'Midday';

  @override
  String get minAge => 'Min age';

  @override
  String get minimalView => 'Minimal visualizza';

  @override
  String get morning => 'Morning';

  @override
  String get muscleGain => 'Muscle gain';

  @override
  String get needMoreWorkouts => 'Necessario più workouts';

  @override
  String get newPersonalRecordsAchieved => 'Nuovo personale records achieved';

  @override
  String get noComparisonData => 'Nessun confronto dati';

  @override
  String get noMatchesFound => 'Nessun corrispondenze found';

  @override
  String get noPRsYet => 'Nessun PR Ancora';

  @override
  String get noWorkoutsFound => 'Nessun workouts found';

  @override
  String get noWorkoutsFoundDescription => 'Nessun workouts found descrizione';

  @override
  String get noWorkoutsRecorded => 'Nessun workouts recorded';

  @override
  String get notNow => 'Not now';

  @override
  String get oops => 'Ops';

  @override
  String get openCityPicker => 'Apri città selettore';

  @override
  String get openIceBreakers => 'Apri rompighiaccio rompighiaccio';

  @override
  String get openInstagram => 'Apri instagram';

  @override
  String get openSettings => 'Apri settings';

  @override
  String get openToDating => 'Apri a dating';

  @override
  String get openToFriendship => 'Apri a friendship';

  @override
  String get overallAssessment => 'Complessivo valutazione';

  @override
  String get partnerships => 'Partnerships';

  @override
  String get pass => 'Pass';

  @override
  String get perDay => 'Per day';

  @override
  String get performanceDeclined => 'Prestazione peggiorato';

  @override
  String get photoVerified => 'Photo verified';

  @override
  String get pleaseSelectAtLeastOneGoal => 'Please seleziona at least one goal';

  @override
  String get pleaseSelectPreferredTimes => 'Please seleziona preferred times';

  @override
  String get pleaseSelectYourCity => 'Please seleziona your città';

  @override
  String get preferredTimes => 'Preferred times';

  @override
  String get preparing => 'Preparing';

  @override
  String get profileUpdatedSuccessfully => 'Profilo updated successfully';

  @override
  String get progressTitle => 'Progresso title';

  @override
  String get rating => 'Rating';

  @override
  String get redo => 'Redo';

  @override
  String get refreshMatches => 'Refresh corrispondenze';

  @override
  String get rep => 'Ripetizione';

  @override
  String get reportReasonFakeProfile => 'Report reason fake profilo';

  @override
  String get reportReasonHarassment => 'Report reason harassment';

  @override
  String get reportReasonInappropriatePhotos =>
      'Report reason inappropriate photos';

  @override
  String get reportReasonOther => 'Altro';

  @override
  String get reportReasonSpam => 'Spam o pubblicità';

  @override
  String get reportReasonUnderage => 'Report reason underage';

  @override
  String get reportUser => 'Report user';

  @override
  String get resetDefaults => 'Reset defaults';

  @override
  String get resetLayout => 'Reset layout';

  @override
  String get resting => 'Resting';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get rpeTimerAndMore => 'Rpe timer and più';

  @override
  String get saveToFirebaseForReuse => 'Salva a firebase per reuse';

  @override
  String get screenWontTurnOff => 'Screen wont turn off';

  @override
  String get search => 'Cerca';

  @override
  String get searchCity => 'Cerca città';

  @override
  String get searchingForMatches => 'Ricerca per corrispondenze';

  @override
  String get seedDemoData => 'Inizializza demo dati';

  @override
  String get selectDataType => 'Seleziona dati tipo';

  @override
  String get selectDates => 'Seleziona dates';

  @override
  String get selectExportFormat => 'Seleziona esporta formato';

  @override
  String get selectMetrics => 'Seleziona metrics';

  @override
  String get setTrackingReady => 'Serie tracking ready';

  @override
  String get setupYourProfile => 'Setup your profilo';

  @override
  String get similarPerformance => 'Simile prestazione';

  @override
  String get sinceRegistration => 'Since registration';

  @override
  String get skipTimer => 'Skip timer';

  @override
  String get startWorkoutNow => 'Inizia allenamento now';

  @override
  String get stopSet => 'Ferma serie';

  @override
  String get streakLabel => 'Streak label';

  @override
  String get superLike => 'Super like';

  @override
  String get swipeToDecide => 'Swipe a decide';

  @override
  String get syncAllWorkouts => 'Sync all workouts';

  @override
  String get syncWorkouts => 'Sync workouts';

  @override
  String get syncing => 'Sincronizzazione...';

  @override
  String get tapPlusToAddExercise => 'Tap plus a aggiungi esercizio';

  @override
  String get tapToViewMore => 'Tap a visualizza più';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get templateLimitSuggestion => 'Modello limit suggestion';

  @override
  String get templateSyncDescription => 'Modello sync descrizione';

  @override
  String get thisMonth => 'This month';

  @override
  String get older => 'Precedenti';

  @override
  String get timeRange => 'Time range';

  @override
  String get toggleToShowInMatching => 'Toggle a mostra in accoppiamento';

  @override
  String get totalWeightLifted => 'Totale peso sollevato';

  @override
  String get trainingDays => 'Giorni di Allenamento';

  @override
  String get unableToGetLocation => 'Unable a get location';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get updateLocation => 'Update location';

  @override
  String get upgradeForMoreTemplates => 'Upgrade per più templates';

  @override
  String get upgradeToPremiumForSync => 'Upgrade a premium per sync';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get valueTooHigh => 'Value too high';

  @override
  String get valueTooLow => 'Value too low';

  @override
  String get velocityProfile => 'Velocity profilo';

  @override
  String get verified => 'Verified';

  @override
  String get verifiedOnly => 'Verified only';

  @override
  String get viewProfile => 'Visualizza profilo';

  @override
  String get viewWorkout => 'Visualizza allenamento';

  @override
  String get volumeDetails => 'Dettagli Volume';

  @override
  String get volumePerDay => 'Volume per day';

  @override
  String get volumeSettings => 'Volume settings';

  @override
  String get vsLastWeek => 'Vs ultimo week';

  @override
  String get weeklyDistribution => 'Weekly distribution';

  @override
  String get weeklyDistributionDesc => 'Weekly distribution desc';

  @override
  String get weeklyDistributionInfo => 'Weekly distribution informazione';

  @override
  String get weeklyVolume => 'Weekly volume';

  @override
  String get weightLoss => 'Peso loss';

  @override
  String get weightUnit => 'Peso unit';

  @override
  String get workoutComparison => 'Allenamento confronto';

  @override
  String get workoutDeclineDescription => 'Allenamento declino descrizione';

  @override
  String get workoutDeleted => 'Allenamento deleted';

  @override
  String get workoutDuplicated => 'Allenamento duplicated';

  @override
  String get workoutGoals => 'Allenamento goals';

  @override
  String get workoutImprovementDescription =>
      'Allenamento miglioramento descrizione';

  @override
  String get workoutPartnerOnly => 'Allenamento partner only';

  @override
  String get workoutSimilarDescription => 'Allenamento simile descrizione';

  @override
  String get workoutType => 'Allenamento tipo';

  @override
  String get workoutsLabel => 'Workouts label';

  @override
  String get years => 'Years';

  @override
  String get zenMode => 'Zen modalità';

  @override
  String get zenModeActiveDescription => 'Zen modalità active descrizione';

  @override
  String get zenModeInactiveDescription => 'Zen modalità inactive descrizione';

  @override
  String get zonePicker => 'Zone selettore';

  @override
  String get workoutDuration => 'Durata allenamento';

  @override
  String get tryAgain => 'Riprova';

  @override
  String andMoreRecords(int count) {
    return 'e $count altri record';
  }

  @override
  String andXMore(int count) {
    return 'e altri $count';
  }

  @override
  String get errorDeleting => 'Errore durante l\'eliminazione';

  @override
  String get errorPickingImage => 'Errore durante la selezione dell\'immagine';

  @override
  String get errorSharing => 'Errore durante la condivisione';

  @override
  String get errorStartingWorkout =>
      'Errore durante l\'avvio dell\'allenamento';

  @override
  String exercisesCompleted(int count) {
    return '$count esercizi completati';
  }

  @override
  String exportFailedError(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get saveAndEndWorkout => 'Salva e termina allenamento';

  @override
  String saveError(String error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String superLikesRemaining(int count) {
    return '$count super like rimanenti';
  }

  @override
  String templateLimitMessage(int max) {
    return 'Hai raggiunto il limite di $max template';
  }

  @override
  String trustScore(int score) {
    return 'Punteggio di fiducia: $score';
  }

  @override
  String workoutStartedFromTemplate(String name) {
    return 'Allenamento avviato dal template: $name';
  }

  @override
  String xpPoints(int count) {
    return '$count XP';
  }

  @override
  String get keepScreenOn => 'Mantieni schermo acceso';

  @override
  String get recoveryWorkout => 'Recupera Allenamento';

  @override
  String get recoverNow => 'Recupera Ora';

  @override
  String completedOn(String date) {
    return 'Completato il $date';
  }

  @override
  String get doWorkoutNow => 'Fai Allenamento Ora';

  @override
  String get extendRoutine => 'Estendi Routine';

  @override
  String get addToEndOfRoutine => 'Aggiungi alla fine della routine';

  @override
  String get skipPermanently => 'Salta Permanentemente';

  @override
  String get skipThisWorkout => 'Salta questo allenamento';

  @override
  String get manageUncompletedWorkout => 'Gestisci allenamento mancato';

  @override
  String get chooseHowToProceed => 'Scegli come procedere';

  @override
  String get routineExtendedSuccessfully => 'Routine estesa con successo';

  @override
  String get workoutSkipped => 'Allenamento saltato';

  @override
  String get recoveryComplete => 'Recupero completato';

  @override
  String get workoutCompletedSuccessfully =>
      'Allenamento completato con successo';

  @override
  String get missedWorkoutRecovered => 'Allenamento mancato recuperato';

  @override
  String get routineSchedule => 'Programma';

  @override
  String get routineStatusCompleted => 'Completato';

  @override
  String get routineStatusScheduled => 'Programmato';

  @override
  String get routineStatusSkipped => 'Saltato';

  @override
  String get routineStatusRest => 'Riposo';

  @override
  String get routineExtraWorkout => 'Allenamento Extra 💪';

  @override
  String get routineExtraWorkoutMessage =>
      'Ti sei allenato in un giorno di riposo programmato! Grande dedizione!';

  @override
  String get routineTodayPerformance => 'PRESTAZIONE DI OGGI';

  @override
  String get routineVolume => 'Volume';

  @override
  String get routineDuration => 'Durata';

  @override
  String get exercisesLabel => 'Esercizi';

  @override
  String get routineAverageRPE => 'RPE Medio';

  @override
  String get routineWorkoutPreview => 'ANTEPRIMA ALLENAMENTO';

  @override
  String get routineChange => 'Cambia';

  @override
  String get routineTemplateNotFound => 'Template non trovato';

  @override
  String get routineShowLess => 'Mostra Meno';

  @override
  String routineShowAll(int count) {
    return 'Mostra Tutti ($count in più)';
  }

  @override
  String get routineWorkoutHistory => 'CRONOLOGIA ALLENAMENTI';

  @override
  String get routineInsightsSuggestions => 'INSIGHT E SUGGERIMENTI';

  @override
  String get routineAiInsightsBased =>
      'Insight basati su AI:\n• Le tue prestazioni\n• Metriche di recupero\n• Pattern di allenamento';

  @override
  String get routineBasedOnMetrics =>
      'Basato sulle tue metriche di prestazione';

  @override
  String get routineStartWorkout => 'Inizia Allenamento';

  @override
  String get routineViewFullDetails => 'Visualizza Dettagli Completi';

  @override
  String get routineComplete => 'Completa';

  @override
  String get routineSkip => 'Salta';

  @override
  String get routineStatusRecovered => 'Recuperato';

  @override
  String get routineWorkoutStarted => 'Allenamento iniziato! 💪';

  @override
  String routineErrorStartingWorkout(String error) {
    return 'Errore nell\'avvio dell\'allenamento: $error';
  }

  @override
  String get routineSkipDay => 'Salta Giorno';

  @override
  String get routineSkipDayConfirm => 'Segnare questo giorno come saltato?';

  @override
  String get routineDaySkipped => 'Giorno saltato';

  @override
  String get routineFailedToSkip => 'Impossibile saltare il giorno';

  @override
  String get routineNoTemplatesAvailable => 'Nessun template disponibile';

  @override
  String get routineActiveRoutine => 'Routine Attiva';

  @override
  String get routineOtherRoutines => 'Altre Routine';

  @override
  String get routineArchived => 'Routine archiviata';

  @override
  String get routineGoBack => 'Indietro';

  @override
  String get routineActivateRoutine => 'Attiva Routine';

  @override
  String get routineArchiveRoutine => 'Archivia Routine';

  @override
  String get routineDeleteRoutine => 'Elimina Routine';

  @override
  String get routineWhyThisSuggestion => 'Perché Questo Suggerimento?';

  @override
  String get routineGotIt => 'Capito';

  @override
  String get routineViewCompletedWorkout => 'Visualizza Allenamento Completato';

  @override
  String get routineNotFound => 'Routine non trovata';

  @override
  String routineTemplateChanged(String templateName) {
    return 'Template cambiato in \"$templateName\"';
  }

  @override
  String get routineFailedToChange => 'Impossibile cambiare template';

  @override
  String routineErrorChanging(String error) {
    return 'Errore nel cambio template: $error';
  }

  @override
  String get routineTodayWorkout => 'Allenamento di Oggi';

  @override
  String smartButtonStartWorkout(String workoutName) {
    return 'Inizia $workoutName';
  }

  @override
  String get smartButtonViewRecap => 'Visualizza Recap';

  @override
  String smartButtonRestDay(String nextDate) {
    return 'Riposa. Prossimo: $nextDate';
  }

  @override
  String get smartButtonExploreWorkouts => 'Esplora Workout';

  @override
  String get smartButtonRecoveryTips => 'Consigli Recupero';

  @override
  String get smartWorkoutCTAStart => 'INIZIA ALLENAMENTO';

  @override
  String get smartWorkoutCTARestDay => 'Giorno di Riposo 🌟';

  @override
  String get smartWorkoutCTARestDayHint =>
      'Usa il pulsante \"+ Sessione Libera\" per un allenamento libero';

  @override
  String smartWorkoutCTASuggestedToday(int duration) {
    return 'Suggerito per oggi • ~$duration min';
  }

  @override
  String get smartWorkoutCTAErrorLoading => 'Errore caricamento';

  @override
  String get smartWorkoutCTAErrorTemplate => 'Errore caricamento template';

  @override
  String get smartWorkoutCTAIncompleteRoutine => 'Routine incompleta';

  @override
  String get smartWorkoutCTATemplateNotFound => 'Template non trovato';

  @override
  String get smartWorkoutCTARoutineUpdated => 'Routine aggiornata ✓';

  @override
  String get smartWorkoutCTARestModeTitle => '💪 Goditi il meritato riposo';

  @override
  String get smartWorkoutCTARestModeSubtitle =>
      'Hai fatto un allenamento pazzesco!';

  @override
  String smartWorkoutCTARestModeVolume(String volume) {
    return 'Volume: $volume kg';
  }

  @override
  String smartWorkoutCTARestModeDuration(String duration) {
    return 'Durata: $duration';
  }

  @override
  String smartWorkoutCTARestModeSets(int sets) {
    return 'Serie: $sets';
  }

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get selectAtLeastOneMetric => 'Seleziona almeno una metrica';

  @override
  String get errorNormalizingData =>
      'Errore durante la normalizzazione dei dati';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get aiCoachInsights => 'AI Coach Insights';

  @override
  String get syncAlreadyInProgress => 'Sync already in progress';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get invalidTemplateId => 'Invalid template ID';

  @override
  String get pesoKg => 'Peso (kg)';

  @override
  String get volumeTotale => 'Volume Totale';

  @override
  String get vediDettagli => 'Vedi dettagli';

  @override
  String get yourePremium => 'You\\\'re Premium!';

  @override
  String get manageSubscription => 'Gestisci Abbonamento';

  @override
  String get creaTemplate => 'Crea Template';

  @override
  String get erroriComuni => 'Errori comuni';

  @override
  String get datiEsercizioNonDisponibili => 'Dati esercizio non disponibili';

  @override
  String get useWheel => 'Use wheel';

  @override
  String get typeManually => 'Type manually';

  @override
  String get templateNameIsRequired => 'Template name is required';

  @override
  String get livelloLevel => 'Livello \$level';

  @override
  String get volumeProgress => 'Volume Progress';

  @override
  String get createRoutine => 'Crea Routine';

  @override
  String get nessunEsercizioTrovato => 'Nessun esercizio trovato';

  @override
  String get dMmmYyyy => 'd MMM yyyy';

  @override
  String get nessunDatoDisponibile => 'Nessun dato disponibile';

  @override
  String get noExerciseDataAvailable => 'No exercise data available';

  @override
  String get muscleEfficiencyScore => 'Muscle Efficiency Score';

  @override
  String get upperBodyPush => 'Upper Body • Push';

  @override
  String get showMe => 'Show me';

  @override
  String get benvenutoInGymbro => 'Benvenuto in GymBro! 👋';

  @override
  String get iniziaIlTuoViaggioFitnessToccaLaCampanel =>
      'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.';

  @override
  String get iniziaOra => 'Inizia ora';

  @override
  String get vediAchievement => 'Vedi achievement';

  @override
  String get milestoneRaggiunto => 'Milestone Raggiunto!';

  @override
  String get aggiornamentoProgressi => 'Aggiornamento Progressi';

  @override
  String get forcedCleanupCompletedAfterDisposalError =>
      '🔧 Forced cleanup completed after disposal error';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get premiumStatus => 'Premium Status';

  @override
  String get noPurchasesFoundToRestore => 'No purchases found to restore';

  @override
  String get seriePrincipale => 'Serie Principale';

  @override
  String get weightSuggestions => 'Weight Suggestions';

  @override
  String get erroreNelCaricamento => 'Errore nel caricamento';

  @override
  String get errorUnableToEditThisSet => 'Error: Unable to edit this set';

  @override
  String get contribuisciAllaCommunity => 'Contribuisci alla Community';

  @override
  String get inviaContributo => 'Invia Contributo';

  @override
  String get segnalaProblema => 'Segnala problema';

  @override
  String get weightToAll => 'Weight to All';

  @override
  String get repsToAll => 'Reps to All';

  @override
  String get ddMmmmYyyy => 'dd MMMM yyyy';

  @override
  String get patternIsEmpty => 'Pattern is empty';

  @override
  String get syncAvailableForPremiumUsersOnly =>
      'Sync available for premium users only';

  @override
  String get adminOnly => 'Admin Only';

  @override
  String get nessunContributo => 'Nessun Contributo';

  @override
  String get rifiutaContributo => 'Rifiuta Contributo';

  @override
  String get motivoOpzionale => 'Motivo (opzionale)';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get trovaIlTuoWorkoutBuddy => 'Trova il tuo Workout Buddy';

  @override
  String get adminModerationNotImplementedInHybridrep =>
      'Admin moderation not implemented in HybridRepository';

  @override
  String get descriviIlProblemaInDettaglio =>
      'Descrivi il problema in dettaglio...';

  @override
  String get templateNameCannotBeEmpty => 'Template name cannot be empty';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get invalidWeight => 'invalid weight';

  @override
  String get addSetInformationInFormatSet1X580kg =>
      'Add set information in format: Set1 x 5: 80kg';

  @override
  String get templateMustHaveAtLeastOneExercise =>
      'Template must have at least one exercise';

  @override
  String get atLeastOne => 'at least one';

  @override
  String get noWorkoutSectionsFoundInText =>
      'No workout sections found in text';

  @override
  String get noSetInformation => 'no set information';

  @override
  String get fatalErrorInGetusertemplates =>
      'Fatal error in getUserTemplates()';

  @override
  String get noEmail => 'No email';

  @override
  String get adminAccessRequired => 'Admin access required';

  @override
  String get analyticsInfo => 'Analytics Info';

  @override
  String get totalEvents => 'Total Events';

  @override
  String get avgDuration => 'Avg Duration';

  @override
  String get userProperties => 'User Properties';

  @override
  String get syncDashboard => 'Sync Dashboard';

  @override
  String get featureStatus => 'Feature Status';

  @override
  String get segnaComeCompletato => 'Segna come Completato';

  @override
  String get changeEquipment => 'Change Equipment';

  @override
  String get startSync => 'Start Sync';

  @override
  String get segnalazioniEBugUtenti => 'Segnalazioni e bug utenti';

  @override
  String get systemSoundTest => 'SYSTEM SOUND TEST';

  @override
  String get cleanhandle => '@\$cleanHandle';

  @override
  String get noTemplate => 'No template';

  @override
  String get recoverWorkout => 'Recover Workout';

  @override
  String get adherenceRate => 'Adherence Rate';

  @override
  String get skipWorkout => 'Skip Workout';

  @override
  String get gymbroUser => 'GymBro User';

  @override
  String get consigliPersonalizzati => 'Consigli Personalizzati';

  @override
  String get vediAnalytics => 'Vedi Analytics';

  @override
  String get scegliTemplate => 'Scegli Template';

  @override
  String get selezionaUnWorkoutSalvato => 'Seleziona un workout salvato';

  @override
  String get allenamentiRecenti => 'Allenamenti Recenti';

  @override
  String get esercizioDelGiorno => 'Esercizio del Giorno';

  @override
  String get progressiAchievement => '🏆 Progressi & Achievement';

  @override
  String get inarrestabile30GiorniDiStreak =>
      '🔥 Inarrestabile! 30+ giorni di streak!';

  @override
  String get modalTesterDebugMode => '🧪 MODAL TESTER - Debug Mode';

  @override
  String get testAllWorkoutModalsToIdentifyDuplicates =>
      'Test all workout modals to identify duplicates and determine which ones to keep';

  @override
  String get providerIsInErrorState => '💥 Provider is in ERROR state';

  @override
  String get workoutRecenti => 'Workout Recenti';

  @override
  String get streakAttuale => 'Streak Attuale';

  @override
  String get allenamentiTotali => 'Allenamenti Totali';

  @override
  String get questoMese => 'Questo Mese';

  @override
  String get secondaryActionsPreview => 'Secondary Actions Preview';

  @override
  String get resetTimerPosition => 'Reset Timer Position';

  @override
  String get apreCalculationMethod => 'APRE Calculation Method';

  @override
  String get errorDetails => 'Error Details';

  @override
  String get requestTimeout => 'Request timeout';

  @override
  String get sslHandshakeFailedPossibleMitmAttack =>
      'SSL handshake failed - possible MITM attack';

  @override
  String get errormsg => '❌ \$errorMsg';

  @override
  String get debugLogs => 'Debug Logs';

  @override
  String get timerDebugLogsAutorefreshEvery2sn =>
      'Timer Debug Logs - Auto-refresh every 2s\\n';

  @override
  String get pleaseLogInToViewYourAnalytics =>
      'Please log in to view your analytics';

  @override
  String get loadingYourAnalytics => 'Caricamento analisi...';

  @override
  String get noWorkoutDataYet => 'Nessun dato allenamento ancora';

  @override
  String get completeSomeWorkoutsToSeeYournanalyticsA =>
      'Complete some workouts to see your\\nanalytics and progress!';

  @override
  String get noPersonalRecordsYet => 'No personal records yet';

  @override
  String get newPr => 'NEW PR!';

  @override
  String get analyticsErrorNoValidWorkoutsFound =>
      '❌ [Analytics] ERROR: No valid workouts found!';

  @override
  String get noCompletedExercisesFoundInYourWorkouts =>
      'No completed exercises found in your workouts';

  @override
  String get analyticsErrorSyntheticactivitiesIsEmpty =>
      '❌ [Analytics] ERROR: syntheticActivities is EMPTY after processing!';

  @override
  String get unableToLoadExerciseActivities =>
      'Unable to load exercise activities';

  @override
  String get loadingRoutineAnalytics => 'Loading routine analytics...';

  @override
  String get noActiveRoutine => 'Nessuna routine attiva';

  @override
  String get createAndActivateARoutineToSeeAnalyticsH =>
      'Create and activate a routine to see analytics here';

  @override
  String get errorLoadingAnalytics2 => 'Error Loading Analytics';

  @override
  String get activeRoutineAnalytics => 'Active Routine Analytics';

  @override
  String get performanceMetrics => 'Performance Metrics';

  @override
  String get skipRate => 'Skip Rate';

  @override
  String get avgGap => 'Avg Gap';

  @override
  String get betweenWorkouts => 'between workouts';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get templateDistribution => 'Template Distribution';

  @override
  String get weeklyPattern => 'Weekly Pattern';

  @override
  String get weeklyAdherenceTrend => 'Weekly Adherence Trend';

  @override
  String get chartVisualizationComingSoon => 'Chart visualization coming soon';

  @override
  String get workoutmetricsBoxNotOpenedCallHiveopenbo =>
      'workoutMetrics box not opened. Call Hive.openBox<Map>(\\\'workoutMetrics\\\') first.';

  @override
  String get workoutmetricsBoxMustBeOpenedBeforeUsing =>
      'workoutMetrics box must be opened before using analytics';

  @override
  String get cannotCreateWorkoutFromEmptyActivitiesLi =>
      'Cannot create workout from empty activities list';

  @override
  String get trainingRecommendations => 'Training Recommendations';

  @override
  String get loadingAnalytics => 'Loading analytics...';

  @override
  String get noExercisesMatch_searchquery =>
      'No exercises match \"\$_searchQuery\"';

  @override
  String get noRpeDataAvailable => 'No RPE data available';

  @override
  String get storicoEsercizi => 'Storico Esercizi';

  @override
  String get cercaUnEsercizio => 'Cerca un esercizio...';

  @override
  String get pesoAttuale => 'Peso attuale';

  @override
  String get iniziaARegistrareIlTuoPeso => 'Inizia a registrare il tuo peso';

  @override
  String get allExercisesStatistics => 'All Exercises Statistics';

  @override
  String get attendiQualcheSecondo => 'Attendi qualche secondo...';

  @override
  String get tuttiIDatiSonoStatiSincronizzati =>
      'Tutti i dati sono stati sincronizzati!';

  @override
  String get siEVerificatoUnErroreDuranteLaSincronizz =>
      'Si è verificato un errore durante la sincronizzazione.';

  @override
  String get mostraTutti => 'Mostra tutti';

  @override
  String get periodoDiVisualizzazione => 'Periodo di visualizzazione';

  @override
  String get proiezione30Giorni => 'Proiezione 30 giorni';

  @override
  String get rmRmeffettivo => '1RM Effettivo';

  @override
  String get nessunDato1rmDisponibile => 'Nessun dato 1RM disponibile';

  @override
  String get datiInsufficientiPerAnalisi => 'Dati insufficienti per analisi';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get rateYourFatigueLevelToImproveRecoveryIns =>
      'Rate your fatigue level to improve recovery insights';

  @override
  String get anySpecificMuscleSorenessOrObservations =>
      'Any specific muscle soreness or observations?';

  @override
  String get e1rmTrackerTopExercises => 'e1RM Tracker - Top Exercises';

  @override
  String get bestSetOfTheWeek => 'Best Set of the Week';

  @override
  String get dataSyncedToCloud => 'Data synced to cloud';

  @override
  String get syncToCloud => 'Sync to Cloud';

  @override
  String get noWorkoutDataThisWeek => 'No workout data this week';

  @override
  String get completeWorkoutsToSeeYourProgress =>
      'Complete workouts to see your progress';

  @override
  String get fullHistoryComingSoon => 'Full history coming soon!';

  @override
  String get trainingInsight => '💡 Training Insight';

  @override
  String get considera23GiorniDiRecuperoCompletoOUnAl =>
      'Considera 2-3 giorni di recupero completo o un allenamento molto leggero.';

  @override
  String get sePianificatoOttimoAltrimentiVerificaSeS =>
      'Se pianificato, ottimo! Altrimenti, verifica se stai recuperando bene.';

  @override
  String get puoiMantenereQuestoRitmoMaMonitoraIlRecu =>
      'Puoi mantenere questo ritmo, ma monitora il recupero nei prossimi giorni.';

  @override
  String get consideraDiMantenereIlVolumeAttualePerCo =>
      'Considera di mantenere il volume attuale per consolidare i progressi.';

  @override
  String get sonoPassatiDayssincelastworkoutGiorniDal =>
      'Sono passati \$daysSinceLastWorkout giorni dall\'ultimo allenamento.';

  @override
  String get ripartiConCalmaMagariConUnVolumeRidottoD =>
      'Riparti con calma, magari con un volume ridotto del 20-30%.';

  @override
  String get assicuratiDiBilanciareConGiorniDiRecuper =>
      'Assicurati di bilanciare con giorni di recupero adeguati.';

  @override
  String get frequenzaDiAllenamentoElevataConWorkoutc =>
      'Frequenza di allenamento elevata con \$workoutCount sessioni questa settimana.';

  @override
  String get valutaSeRidurreLaFrequenzaPerMigliorareI =>
      'Valuta se ridurre la frequenza per migliorare il recupero.';

  @override
  String get continuaCosiAscoltandoSempreISegnaliDelT =>
      'Continua così, ascoltando sempre i segnali del tuo corpo.';

  @override
  String get analisiDettagliata => '📊 Analisi Dettagliata';

  @override
  String get sbloccaAnalisiAvanzate => '🎯 Sblocca Analisi Avanzate';

  @override
  String get previsioniPersonalizzateBasateSuAin =>
      '• Previsioni personalizzate basate su AI\\n';

  @override
  String get esempiPratici => 'Esempi Pratici';

  @override
  String get volumeSetsRepsWeight => 'Volume = Sets × Reps × Weight';

  @override
  String get strengthCurrentVolumeMaxVolume100 =>
      'Strength % = (Current Volume / Max Volume) × 100';

  @override
  String get loadOlderWorkouts => 'Load older workouts';

  @override
  String get boyle2016 => 'Boyle (2016)';

  @override
  String get croisierEtAl2008 => 'Croisier et al. (2008)';

  @override
  String get reference => '📚 \$reference';

  @override
  String get setsCompleted => 'Sets Completed';

  @override
  String get streakAttuale2 => 'Streak attuale';

  @override
  String get piu => 'Più';

  @override
  String get giornoDiRiposo => 'Giorno di riposo';

  @override
  String get optimalBalance17PerMuscleGroupResearchSh =>
      'Optimal balance: ~17% per muscle group. Research shows balanced training prevents injuries and maximizes growth (Baz-Valle 2022)';

  @override
  String get cercaEsercizio => 'Cerca Esercizio';

  @override
  String get cercaNeiTuoiEsercizi => 'Cerca nei tuoi esercizi';

  @override
  String get focusMoreOnNeglected => 'Focus more on \$neglected';

  @override
  String get considerReducingOverdevelopedVolume =>
      'Consider reducing \$overdeveloped volume';

  @override
  String get noMuscleGroupDataAvailable => 'No muscle group data available';

  @override
  String get ricaricaAnimazione => 'Ricarica animazione';

  @override
  String get forzaAttuale => 'Forza attuale';

  @override
  String get vsUltimoMese => 'vs ultimo mese';

  @override
  String get mmmmYyyy => 'MMMM yyyy';

  @override
  String get performanceTrends => 'Performance Trends';

  @override
  String get trackYourMuscleEfficiency => 'Track your muscle efficiency';

  @override
  String get efficiencyVolumeRecoveryTime =>
      'Efficiency = Volume / Recovery Time';

  @override
  String get rateTodaysFatigue => 'Rate Today\\\'s Fatigue';

  @override
  String get noWorkoutsTodayToRate => 'No workouts today to rate';

  @override
  String get fatigueLevelFatiguelevelRecorded =>
      'Fatigue level \$fatigueLevel recorded';

  @override
  String get noDataAvailableYet => 'No data available yet';

  @override
  String get currentScore => 'Current Score';

  @override
  String get scoreBreakdown => 'Dettaglio Punteggio';

  @override
  String get statsTemporarilyUnavailable => 'Stats temporarily unavailable';

  @override
  String get heatmapImplementationComingSoon =>
      'Heatmap implementation coming soon';

  @override
  String get chartImplementationComingSoon =>
      'Chart implementation coming soon';

  @override
  String get bernrdezvzquezEtAl2022Healthcare =>
      'Bernárdez-Vázquez et al. (2022) - Healthcare';

  @override
  String get schoenfeldEtAl2021JStrengthCondRes =>
      'Schoenfeld et al. (2021) - J Strength Cond Res';

  @override
  String get doesNotAccountForFatigueOrTrainingState =>
      'Does not account for fatigue or training state';

  @override
  String get errorMarginTypically510EvenInBestConditi =>
      'Error margin typically ±5-10% even in best conditions';

  @override
  String get gymbroAnalyticsReport => 'GymBro Analytics Report';

  @override
  String get trainingPerformanceAnalysis => 'Training Performance Analysis';

  @override
  String get trainingStatistics => 'Training Statistics';

  @override
  String get bestSet => 'Best Set';

  @override
  String get boxNotFound => 'Box not found';

  @override
  String get analyticsHiveBoxErrorDetectedRetrying =>
      '🔧 [Analytics] Hive box error detected. Retrying...';

  @override
  String get pleaseSelectYourDateOfBirth => 'Please select your date of birth';

  @override
  String get requiredByGdprAndItalianPrivacyLaws =>
      'Required by GDPR and Italian privacy laws';

  @override
  String get toggleAttivi => 'Toggle Attivi:';

  @override
  String get toggleDisattivi => 'Toggle Disattivi:';

  @override
  String get allenamentoRapido => 'Allenamento Rapido';

  @override
  String get daTemplate => 'Da Template';

  @override
  String get fromTemplate => 'From Template';

  @override
  String get nuovoAllenamento => 'Nuovo Allenamento';

  @override
  String get pettoETricipiti => 'Petto e Tricipiti';

  @override
  String get chestTriceps => 'Chest & Triceps';

  @override
  String get n45Min => '45 min';

  @override
  String get n4Esercizi => '4 esercizi';

  @override
  String get n4Exercises => '4 exercises';

  @override
  String get pettoTric => 'PETTO, TRIC';

  @override
  String get modificaRapida => 'Modifica Rapida';

  @override
  String get quickEdit => 'Modifica Veloce';

  @override
  String get rpe610 => 'RPE (6-10)';

  @override
  String get tapTheButtonToCreateYourFirstWorkout =>
      'Tap the + button to create your first workout';

  @override
  String get welcomeLetsCreateYourFirstWorkoutTogethe =>
      'Welcome! Let\\\'s create your first workout together. I\\\'ll guide you step-by-step.';

  @override
  String get letsGo => 'Andiamo!';

  @override
  String get greatNowTapHereToAddYourFirstExercise =>
      'Great! Now tap here to add your first exercise.';

  @override
  String get searchByNameOrBrowseByMuscleGroupChooseA =>
      'Search by name or browse by muscle group. Choose any exercise to get started!';

  @override
  String get asIs => 'AS IS';

  @override
  String get noValueAssociatedWithKey_errordescriptio =>
      'No value associated with key \\(_errorDescription(of: key)).';

  @override
  String get unkeyedContainerIsAtEnd => 'Unkeyed container is at end.';

  @override
  String get initCoderHasNotBeenImplemented =>
      'init(coder:) has not been implemented';

  @override
  String get expectedTypeValueButFoundNullInstead =>
      'Expected \\(type) value but found null instead.';

  @override
  String get expectedTypeButFoundNullInstead =>
      'Expected \\(type) but found null instead.';

  @override
  String get erroreError => 'Errore: \$error';

  @override
  String get barbellBenchPress => 'Barbell Bench Press';

  @override
  String get expectImagepickercontroller => 'Expect imagePickerController';

  @override
  String get centroStorico => 'Centro Storico';

  @override
  String get noData => 'No data';

  @override
  String get benchPress => 'Bench Press';

  @override
  String get erroreE => 'Errore: \$e';

  @override
  String get parsedJsonNumberNumberDoesNotFitInType =>
      'Parsed JSON number <\\(number)> does not fit in \\(type).';

  @override
  String get expectGroup => 'Expect group';

  @override
  String get thisMethodMustBeOverridden => 'This method must be overridden.';

  @override
  String get workout1 => 'Workout 1';

  @override
  String get corpoLibero => 'Corpo Libero';

  @override
  String get stackStack => 'Stack: \$stack';

  @override
  String get workout2 => 'Workout 2';

  @override
  String get eeeeDMmmmYyyy => 'EEEE, d MMMM yyyy';

  @override
  String get pancaPiana => 'Panca Piana';

  @override
  String get timerComplete => '⏰ Timer Completato!';

  @override
  String get unknownExercise => 'Unknown Exercise';

  @override
  String get workout3 => 'Workout 3';

  @override
  String get syncFailedE => 'Sync failed: \$e';

  @override
  String get legCurl => 'Leg Curl';

  @override
  String get unauthorizedAdminOnly => 'Unauthorized: Admin only';

  @override
  String get testExercise => 'Test Exercise';

  @override
  String get myRoutine => 'My Routine';

  @override
  String get achievementNotFound => 'Achievement not found';

  @override
  String get cannotCastTypeOfObjcvalueToValueSelf =>
      'Cannot cast \\(type(of: objCValue)) to \\(Value.self)';

  @override
  String get expectCollectionview => 'Expect collectionView';

  @override
  String get iAut000017 => 'I-AUT000017';

  @override
  String get thisClassIsNotMeantToBeInitialized =>
      'This class is not meant to be initialized.';

  @override
  String get mmmD => 'MMM d';

  @override
  String get informazioniTut => 'Informazioni TUT';

  @override
  String get frenchPress => 'French Press';

  @override
  String get ezBar => 'EZ Bar';

  @override
  String get workoutReminders => 'Promemoria Allenamento';

  @override
  String get dailyWorkoutReminder => 'Promemoria Allenamento Giornaliero';

  @override
  String get progressAndMotivation => 'Progressi & Motivazione';

  @override
  String get questaAzioneNonPuEssereAnnullata =>
      'Questa azione non può essere annullata.';

  @override
  String get exception => 'Exception: ';

  @override
  String get eliminaTemplate => 'Elimina Template';

  @override
  String get jump => '+\$jump';

  @override
  String get prevenzioneInfortuni => 'Prevenzione infortuni';

  @override
  String get hapticFeedbackErrorE => 'Haptic feedback error: \$e';

  @override
  String get ezCurl => 'EZ Curl';

  @override
  String get legPress => 'Leg Press';

  @override
  String get barbellBackSquat => 'Barbell Back Squat';

  @override
  String get erroreE2 => '❌ Errore: \$e';

  @override
  String get overheadPress => 'Overhead Press';

  @override
  String get rpeMedio => 'RPE Medio';

  @override
  String get mmmDY => 'MMM d, y';

  @override
  String get key1Workout1Rest => '1 Workout + 1 Rest';

  @override
  String get key2Workouts1Rest => '2 Workouts + 1 Rest';

  @override
  String get key3Workouts1Rest => '3 Workouts + 1 Rest';

  @override
  String get key3Workouts2Rest => '3 Workouts + 2 Rest';

  @override
  String get key4Workouts1Rest => '4 Workouts + 1 Rest';

  @override
  String get key4Workouts3Rest => '4 Workouts + 3 Rest';

  @override
  String get key5Workouts2Rest => '5 Workouts + 2 Rest';

  @override
  String get key6Workouts1Rest => '6 Workouts + 1 Rest';

  @override
  String get workout4 => 'Workout 4';

  @override
  String get key3Set => '3 set';

  @override
  String get continuaCos => 'Continua così!';

  @override
  String get avviaAllenamento => 'Avvia Allenamento';

  @override
  String get exerciseCurrentOfTotal => 'Exercise \$current of \$total';

  @override
  String get missingActivityid => 'Missing activityId';

  @override
  String get iAut000008 => 'I-AUT000008';

  @override
  String get idIdentifier => '   - ID: \\(identifier)';

  @override
  String get liveActivitiesRequireIos161OrLater =>
      'Live Activities require iOS 16.1 or later';

  @override
  String get stackStacktrace => 'Stack: \$stackTrace';

  @override
  String get workoutSummary => 'Riepilogo Allenamento';

  @override
  String get tracciamentoRpe => 'Tracciamento RPE';

  @override
  String get timerAutomatico => 'Timer Automatico';

  @override
  String get suggerimentiCommunity => 'Suggerimenti Community';

  @override
  String get pettoTricDelt_ant => 'PETTO, TRIC, DELT_ANT';

  @override
  String get advancedFeatures => 'Advanced Features';

  @override
  String get useUnreadnotificationcountproviderFromUn =>
      'Use unreadNotificationCountProvider from unified_notification_provider.dart';

  @override
  String get useTodaynotificationsproviderFromUnified =>
      'Use todayNotificationsProvider from unified_notification_provider.dart';

  @override
  String get providerDisposed => 'Provider disposed';

  @override
  String get notificationPermissionsNotGranted =>
      'Notification permissions not granted';

  @override
  String get workoutReminder => 'Workout Reminder';

  @override
  String get advancedAnalytics => 'Analisi Avanzate';

  @override
  String get save33 => 'Save 33%';

  @override
  String get bestValue => 'Best Value';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get youRePremium => 'You\\\'re Premium!';

  @override
  String get communityAccess => 'Community Access';

  @override
  String get shoulderPress => 'Shoulder Press';

  @override
  String get eliminaUnTemplateEsistenteOPassaAPremium =>
      'Elimina un template esistente o passa a Premium per avere più spazio.';

  @override
  String get ilTemplateVerrSalvatoSuFirebaseESarDispo =>
      'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi';

  @override
  String get templatePersonalizzato => 'Template personalizzato';

  @override
  String get eliminaTemplateEsistentiOPassaAPremium =>
      'Elimina template esistenti o passa a Premium.';

  @override
  String get fitlogPro => 'FitLog Pro';

  @override
  String get continueYourRoutine => 'Continue your routine';

  @override
  String get nessunTemplatePersonalizzato => 'Nessun template personalizzato';

  @override
  String get statoSincronizzazione => 'Stato Sincronizzazione';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get confermaSerie => 'Conferma Serie';

  @override
  String get muscoliSecondari => 'Muscoli secondari';

  @override
  String get tipoEsercizio => 'Tipo esercizio';

  @override
  String get rangeRipetizioni => 'Range ripetizioni';

  @override
  String get patternMovimento => 'Pattern movimento';

  @override
  String get serieRiscaldamento => 'Serie riscaldamento';

  @override
  String get durataRiscaldamento => 'Durata riscaldamento';

  @override
  String get mobilitArticolare => 'Mobilità articolare';

  @override
  String get attivazioneMuscolare => 'Attivazione muscolare';

  @override
  String get progressioneCarico => 'Progressione carico';

  @override
  String get noteTecniche => 'Note tecniche';

  @override
  String get drillTecnico => 'Drill tecnico';

  @override
  String get cooldownConsigliato => 'Cooldown consigliato';

  @override
  String get muscoliTarget => 'Muscoli target';

  @override
  String get serieDiRiscaldamento => 'Serie di Riscaldamento';

  @override
  String get prevenzioneInfortuni2 => 'Prevenzione Infortuni';

  @override
  String get hoCapito => 'Ho capito!';

  @override
  String get preLoadedFixedBar => 'Pre-loaded fixed bar';

  @override
  String get nonTroviLEsercizioCreaneUnoPersonalizzat =>
      'Non trovi l\\\'esercizio? Creane uno personalizzato';

  @override
  String get miniSetIndex => 'Mini-Set \$index';

  @override
  String get votoPositivo => '👍 Voto positivo!';

  @override
  String get votoNegativo => '👎 Voto negativo';

  @override
  String get inAttesa => 'In attesa';

  @override
  String get partnershipAttiva => 'Partnership attiva';

  @override
  String get dettagliEsercizio => 'Dettagli Esercizio';

  @override
  String get bug => '🐛 Bug';

  @override
  String get errorLoadingFeedback => 'Error loading feedback';

  @override
  String get eserciziObsoleti => 'Esercizi Obsoleti';

  @override
  String get eserciziFlaggati => 'Esercizi Flaggati';

  @override
  String get key3Feedback => '≥3 feedback';

  @override
  String get allenamentiFunzionali => 'allenamenti funzionali';

  @override
  String get key2Anni => '2 anni';

  @override
  String get barbellSquat => 'Barbell Squat';

  @override
  String get daySkipped => 'Day skipped';

  @override
  String get useridEmail => ', userId: email)';

  @override
  String get progressioneCarico2 => 'Progressione Carico';

  @override
  String get recuperoOttimale => 'Recupero Ottimale';

  @override
  String get bilanciamentoMuscolare => 'Bilanciamento Muscolare';

  @override
  String get accediPerVedereIWorkout => 'Accedi per vedere i workout';

  @override
  String get azioniRapide => 'Azioni Rapide';

  @override
  String get startRestTimerAfterCompletingSet =>
      'Start rest timer after completing set';

  @override
  String get showDropSetsSupersetsEtc => 'Show drop sets, supersets, etc.';

  @override
  String get showTimerOnLockScreenDynamicIsland =>
      'Show timer on lock screen & Dynamic Island';

  @override
  String get syncWorkoutsToAppleHealth => 'Sync workouts to Apple Health';

  @override
  String get playSoundsForTimerAndCompletion =>
      'Play sounds for timer and completion';

  @override
  String get hapticFeedbackForInteractions =>
      'Haptic feedback for interactions';

  @override
  String get englishUs => 'English (US)';

  @override
  String get italianIt => 'Italian (IT)';

  @override
  String get kilogramsKg => 'Kilograms (kg)';

  @override
  String get metricSystem => 'Metric system';

  @override
  String get poundsLbs => 'Pounds (lbs)';

  @override
  String get imperialSystem => 'Imperial system';

  @override
  String get areYouSureYouWantToResetAllSettingsToDef =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get areYouSureYouWantToSignOut => 'Are you sure you want to sign out?';

  @override
  String get exportFunctionalityComingSoon =>
      'Export functionality coming soon';

  @override
  String get importFunctionalityComingSoon =>
      'Import functionality coming soon';

  @override
  String get cercaEsercizi => 'Cerca esercizi...';

  @override
  String get aggiungiSerie => 'Aggiungi Serie';

  @override
  String get dropSet => 'Drop Set';

  @override
  String get unitDiPeso => 'Unità di Peso';

  @override
  String get seiSicuroDiVolerRipristinareTutteLeImpos =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get templateNonTrovato => 'Template non trovato';

  @override
  String get rimuoviDefinitivamente => 'Rimuovi definitivamente';

  @override
  String get noteOpzionale => 'Note (opzionale)';

  @override
  String get aggiuntoExercisenameAllAllenamento =>
      'Aggiunto \$exerciseName all\\\'allenamento';

  @override
  String get applicaModifiche => 'Applica Modifiche';

  @override
  String get saltaPerOra => 'Salta per ora';

  @override
  String get inserisciLaTuaEmail => 'Inserisci la tua email';

  @override
  String get creaAccount => 'Crea Account';

  @override
  String get vaiAllaHome => 'Vai alla Home';

  @override
  String get seiSicuroDiVolerEliminareName =>
      'Sei sicuro di voler eliminare \\\"\$name\\\"?';

  @override
  String get creaRoutine => 'Crea Routine';

  @override
  String get noCompatibleAlternativesFound =>
      'No compatible alternatives found';

  @override
  String get applyingChanges => 'Applying changes...';

  @override
  String get dropSetPerformExerciseToFailureThenImmed =>
      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.';

  @override
  String get restPausePerformToFailureRest1015Seconds =>
      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get addedExercisenameToWorkout => 'Added \$exerciseName to workout';

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String get key1Template => '1 template';

  @override
  String get increaseTrainingFrequency => 'Increase Training Frequency';

  @override
  String get estimated1rm => 'Estimated 1RM';

  @override
  String get useTheImportFunctionInTheTemplateScreen =>
      'Use the import function in the template screen';

  @override
  String get areYouSureYouWantToDeleteName =>
      'Are you sure you want to delete \\\"\$name\\\"?';

  @override
  String get errorSavingError => 'Error saving: \$error';

  @override
  String get noRateLimiterForEndpointEndpoint =>
      '⚠️ No rate limiter for endpoint: \$endpoint';

  @override
  String get liveActivitiesAreDisabled => 'Live Activities are disabled';

  @override
  String get missingRequiredParameters => 'Missing required parameters';

  @override
  String get yearly => 'Annuale';

  @override
  String get lifetime => 'A vita';

  @override
  String get saveThirtyThreePercent => 'Risparmia 33%';

  @override
  String get prioritySupport => 'Supporto Prioritario';

  @override
  String get fullAccess => 'Accesso Completo';

  @override
  String get active => 'Attivo';

  @override
  String get unlockGymbroPremium => 'Sblocca GymBro Premium';

  @override
  String get premiumTagline =>
      'Sincronizzazione ovunque • Backup permanente • Unisciti alla community';

  @override
  String get allDevicesAlwaysInSync =>
      'Tutti i dispositivi, sempre sincronizzati';

  @override
  String get neverLoseYourData => 'Non perdere mai i tuoi dati';

  @override
  String get shareDiscoverWorkouts => 'Condividi e scopri allenamenti';

  @override
  String get analyticsPro => 'Analytics Pro';

  @override
  String get liveUpdates => 'Aggiornamenti in Tempo Reale';

  @override
  String get realTimeSync => 'Sincronizzazione in tempo reale';

  @override
  String get getHelpFast => 'Ottieni aiuto velocemente';

  @override
  String get yearlyPlanMonthlyPrice => 'Solo €3,33/mese';

  @override
  String get recommended => 'CONSIGLIATO';

  @override
  String get termsAndConditions => 'Termini e Condizioni';

  @override
  String get cancelAnytimeAppStore =>
      '• Annulla in qualsiasi momento dall\'App Store\n• L\'abbonamento si rinnova automaticamente a meno che non venga disattivato\n• Il pagamento viene addebitato sull\'account iTunes';

  @override
  String get cancelAnytimeGooglePlay =>
      '• Annulla in qualsiasi momento da Google Play\n• L\'abbonamento si rinnova automaticamente a meno che non venga disattivato\n• Il pagamento viene addebitato sull\'account Google Play';

  @override
  String continueWithPlan(String plan) {
    return 'Continua con $plan';
  }

  @override
  String get pleaseWait =>
      'Attendere prego, potrebbe richiedere qualche istante';

  @override
  String accountTier(String tier) {
    return 'Livello account: $tier';
  }

  @override
  String get automatic => 'Automatico';

  @override
  String get premiumRestoredSuccess => '✅ Premium ripristinato con successo!';

  @override
  String get noPurchasesToRestore => 'Nessun acquisto da ripristinare';

  @override
  String get annual => 'Annuale';

  @override
  String get premiumMembership => 'Abbonamento Premium';

  @override
  String get welcomeToPremium => 'Benvenuto in Premium! 🎉';

  @override
  String get purchaseCancelled => 'Acquisto annullato';

  @override
  String get templateCategoryStrength => 'Forza';

  @override
  String get templateCategoryCardio => 'Cardio';

  @override
  String get templateCategoryFlexibility => 'Flessibilità';

  @override
  String get templateCategoryHybrid => 'Ibrido';

  @override
  String get difficultyExpert => 'Esperto';

  @override
  String get templateStatsNew => '🆕 Nuovo';

  @override
  String get templateStatsToday => '✅ Oggi';

  @override
  String get templateStatsYesterday => '🕐 Ieri';

  @override
  String templateStatsDaysAgo(int days) {
    return '🕐 $days giorni fa';
  }

  @override
  String get templateStatsResume => '🔄 Riprendi?';

  @override
  String get templateActionShare => 'Condividi';

  @override
  String get templateActionDuplicate => 'Duplica';

  @override
  String get templateActionEdit => 'Modifica';

  @override
  String get templateActionDelete => 'Elimina';

  @override
  String purchaseError(String error) {
    return 'Errore: $error';
  }

  @override
  String get unlockYourFullPotential => 'Sblocca il Tuo Pieno Potenziale';

  @override
  String get syncAcrossAllDevices =>
      'Sincronizza su tutti i dispositivi, accedi alle funzionalità della community e non perdere mai i tuoi progressi';

  @override
  String get popular => 'POPOLARE';

  @override
  String get whatUsersSay => 'Cosa Dicono gli Utenti';

  @override
  String get frequentlyAskedQuestions => 'Domande Frequenti';

  @override
  String get startFreeTrialThen => 'Inizia Prova Gratuita - Poi €39.99/anno';

  @override
  String get thankYouForSupporting => 'Grazie per il supporto a GymBro';

  @override
  String get faqCanICancel => 'Posso annullare in qualsiasi momento?';

  @override
  String get faqWhatHappensToData => 'Cosa succede ai miei dati se annullo?';

  @override
  String get faqCanIChangePlans => 'Posso cambiare piano?';

  @override
  String get faqIsPaymentSecure => 'Il pagamento è sicuro?';

  @override
  String get faqCancelAnswer =>
      'Sì! Puoi annullare l\'abbonamento in qualsiasi momento dalle impostazioni.';

  @override
  String get faqDataAnswer =>
      'I tuoi dati rimangono al sicuro localmente. Perderai solo la sincronizzazione cloud.';

  @override
  String get faqChangePlansAnswer =>
      'Sì, puoi fare upgrade o downgrade in qualsiasi momento.';

  @override
  String get faqPaymentSecureAnswer =>
      'Sì, utilizziamo i sistemi di pagamento Apple/Google per la massima sicurezza.';

  @override
  String get testimonialJohnD =>
      'La funzione di sincronizzazione è rivoluzionaria! Posso iniziare un allenamento sul telefono e finirlo sul tablet.';

  @override
  String get testimonialSarahM =>
      'I template della community mi hanno fatto risparmiare ore di pianificazione. Ne vale ogni centesimo!';

  @override
  String get testimonialMikeR =>
      'Non ho mai perso un allenamento da quando sono premium. Il backup è automatico e affidabile.';

  @override
  String get enjoyAllPremiumFeatures => 'Goditi tutte le funzionalità premium';

  @override
  String get getUnlimitedAccess =>
      'Ottieni accesso illimitato a tutte le funzionalità';

  @override
  String get trackWorkoutVolume =>
      'Monitora il volume dei tuoi allenamenti nel tempo';

  @override
  String get comprehensiveWeeklyAnalytics =>
      'Analisi settimanale completa degli allenamenti';

  @override
  String get analyzeMuscleGroupBalance =>
      'Analizza l\'equilibrio dei gruppi muscolari';

  @override
  String get deepInsights =>
      'Approfondimenti dettagliati sulle tue prestazioni';

  @override
  String get detailedHistory => 'Cronologia Dettagliata';

  @override
  String get completeWorkoutHistory =>
      'Cronologia completa degli allenamenti con dettagli';

  @override
  String get syncAcrossDevices => 'Sincronizza su tutti i tuoi dispositivi';

  @override
  String get noAds => 'Nessuna Pubblicità';

  @override
  String get enjoyAdFreeExperience => 'Goditi un\'esperienza senza pubblicità';

  @override
  String get inAppPurchasesComingSoon =>
      'Acquisti in-app in arrivo!\nLe funzionalità premium sono attualmente in beta.';

  @override
  String get thankYouForBeingPremium => 'Grazie per essere Premium!';

  @override
  String get gymbroPremium => 'GymBro Premium';

  @override
  String get youArePremium => 'Sei Premium!';

  @override
  String get youHaveAccessToAllFeatures =>
      'Hai accesso a tutte le funzionalità';

  @override
  String planWillBeAvailableSoon(String plan) {
    return 'Il piano $plan sarà presto disponibile!';
  }

  @override
  String get saveVsMonthly => 'Risparmia 33% rispetto al mensile';

  @override
  String get pleaseLoginToViewAnalytics =>
      'Accedi per visualizzare le tue analisi';

  @override
  String get adminPanel => 'Pannello Admin';

  @override
  String get userReportsAndBugs => 'Segnalazioni e bug utenti';

  @override
  String get onboardingResetComplete => 'Onboarding reset completato';

  @override
  String get customizeHome => 'Personalizza Home';

  @override
  String get dragToReorderTapToConfigure =>
      'Trascina per riordinare, tocca per configurare';

  @override
  String get manageExerciseReports => 'Gestisci segnalazioni esercizi';

  @override
  String get compact => 'Compatto';

  @override
  String get standard => 'Standard';

  @override
  String get expanded => 'Espanso';

  @override
  String get small => 'Piccolo';

  @override
  String get large => 'Grande';

  @override
  String get addWidget => 'Aggiungi Widget';

  @override
  String get createNewRoutine => 'Crea Nuova Routine';

  @override
  String get noRoutinesYet => 'Nessuna routine ancora';

  @override
  String get createFirstRoutineDescription =>
      'Crea la tua prima routine di allenamento per iniziare';

  @override
  String get createFirstRoutineButton => 'Crea routine';

  @override
  String get chooseFromPopularPatterns =>
      'Oppure scegli tra i pattern popolari';

  @override
  String get activateRoutineConfirm => 'Attivare questa routine?';

  @override
  String get archiveRoutineConfirm => 'Archiviare questa routine?';

  @override
  String get deleteRoutineConfirm => 'Eliminare questa routine?';

  @override
  String get routineUnarchived => 'Routine ripristinata';

  @override
  String get routineDeleted => 'Routine eliminata';

  @override
  String get failedToActivate => 'Impossibile attivare la routine';

  @override
  String get failedToArchive => 'Impossibile archiviare la routine';

  @override
  String get failedToDelete => 'Impossibile eliminare la routine';

  @override
  String get failedToUnarchive => 'Impossibile ripristinare la routine';

  @override
  String get failedToLoadTemplate => 'Impossibile caricare il template';

  @override
  String get alternativesComingSoon => 'Alternative in arrivo';

  @override
  String get checkFirebasePermissions =>
      'Controlla i permessi Firebase o contatta il supporto';

  @override
  String get errorLoadingRoutines => 'Errore caricamento routine';

  @override
  String get suggestionLevel => 'Livello suggerimento';

  @override
  String get noExercises => 'Nessun esercizio';

  @override
  String get settingsWorkout => 'Allenamento';

  @override
  String get settingsIosFeatures => 'Funzioni iOS';

  @override
  String get settingsAdvanced => 'Avanzate';

  @override
  String get settingsExport => 'Esporta Impostazioni';

  @override
  String get settingsExportDesc => 'Salva impostazioni come file JSON';

  @override
  String get settingsImport => 'Importa Impostazioni';

  @override
  String get settingsImportDesc => 'Carica impostazioni da file JSON';

  @override
  String get settingsDataMigrationAvailable =>
      'Hai dati da migrare dalla versione precedente';

  @override
  String get settingsDataMigrationComplete =>
      'Migrazione completata o non necessaria';

  @override
  String get settingsAvailable => 'Disponibile';

  @override
  String get settingsBetaModeEnabledDesc =>
      'Tutte le funzioni premium sbloccate per test';

  @override
  String get settingsBetaModeDisabledDesc =>
      'Abilita accesso temporaneo a tutte le funzioni premium';

  @override
  String get settingsResetToDefaultsDesc =>
      'Ripristina tutte le impostazioni predefinite';

  @override
  String get settingsAccountActions => 'Azioni Account';

  @override
  String get settingsSignOutDesc => 'Disconnetti dal tuo account';

  @override
  String get settingsItaliano => 'Italiano';

  @override
  String get settingsAccentColorDialog => 'Colore Accento';

  @override
  String get settingsDefaultRestTimeDialog => 'Tempo Riposo Predefinito';

  @override
  String get settingsResetTimerPositionDialog => 'Ripristina Posizione Timer';

  @override
  String get settingsResetTimerPositionDialogDesc =>
      'Questo ripristinerà la posizione del timer trascinabile alla posizione predefinita. Utile se il timer è bloccato fuori schermo.';

  @override
  String get settingsTimerPositionResetSuccess =>
      'Posizione timer ripristinata a predefinita';

  @override
  String settingsFailedToClearCache(Object error) {
    return 'Impossibile svuotare cache: $error';
  }

  @override
  String get settingsResetSettingsDialog => 'Ripristina Impostazioni';

  @override
  String get settingsResetSettingsDialogDesc =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get settingsSignOutConfirm => 'Sei sicuro di volerti disconnettere?';

  @override
  String settingsApreCalculationMethodUpdated(Object method) {
    return 'Metodo di calcolo APRE aggiornato a $method';
  }

  @override
  String get settingsApreCalculationMethodLoading => 'Metodo Calcolo APRE';

  @override
  String get settingsLoadingGeneric => 'Caricamento...';

  @override
  String get settingsApreCalculationMethodError => 'Metodo Calcolo APRE';

  @override
  String settingsErrorGeneric(Object error) {
    return 'Errore: $error';
  }

  @override
  String get exerciseListEdit => 'Modifica';

  @override
  String get exerciseListDuplicate => 'Duplica';

  @override
  String get exerciseListInsight => 'Analisi';

  @override
  String get exerciseListAddNotesHint => 'Aggiungi note...';

  @override
  String get exerciseListTapToAddNotes => 'Tocca per aggiungere note';

  @override
  String exerciseListSetsProgress(Object completed, Object total) {
    return 'Serie ($completed/$total)';
  }

  @override
  String exerciseListSetAdded(Object setNumber) {
    return 'Serie $setNumber aggiunta';
  }

  @override
  String exerciseListSetRestTimeMessage(Object exerciseName) {
    return 'Imposta tempo riposo tra serie per \"$exerciseName\"';
  }

  @override
  String get exerciseListCancel => 'Annulla';

  @override
  String get exerciseListSave => 'Salva';

  @override
  String get exerciseListSetRestTimer => 'Imposta Timer Riposo';

  @override
  String exerciseListCustomTime(Object time) {
    return 'Personalizzato: $time';
  }

  @override
  String get exerciseListCustom => 'Personalizzato';

  @override
  String get exerciseListConfirm => 'Conferma';

  @override
  String get exerciseListCustomRestTime => 'Tempo Riposo Personalizzato';

  @override
  String get exerciseListMinutes => 'Minuti';

  @override
  String get exerciseListSeconds => 'Secondi';

  @override
  String get exerciseListSetButton => 'Imposta';

  @override
  String exerciseListRestTimerSetTo(Object time) {
    return '⏱️ Timer riposo impostato a $time';
  }

  @override
  String get workoutTemplateSearchHint => 'Cerca template...';

  @override
  String get workoutTemplateRetry => 'Riprova';

  @override
  String get workoutTemplateNoPopularYet => 'Nessun template popolare ancora';

  @override
  String get workoutTemplateMostUsedWillAppear =>
      'I template più usati appariranno qui';

  @override
  String get workoutTemplateNoCustom => 'Nessun template personalizzato';

  @override
  String get workoutTemplateCreateFirstCustom =>
      'Crea il tuo primo template personalizzato';

  @override
  String get workoutTemplateNoneFound => 'Nessun template trovato';

  @override
  String get workoutTemplateSharingComingSoon =>
      '📤 Condivisione template in arrivo...';

  @override
  String workoutTemplateDuplicatedSuccess(Object templateName) {
    return '✅ Template duplicato: \"$templateName\"';
  }

  @override
  String workoutTemplateDuplicationError(Object error) {
    return 'Errore duplicazione: $error';
  }

  @override
  String get workoutTemplateDeleteTitle => 'Elimina Template';

  @override
  String workoutTemplateDeleteConfirm(Object templateName) {
    return 'Sei sicuro di voler eliminare \"$templateName\"?';
  }

  @override
  String get workoutTemplateCancel => 'Annulla';

  @override
  String get workoutTemplateSyncStatus => 'Stato Sincronizzazione';

  @override
  String get exerciseOptionsTapToEnlarge => 'Tocca per ingrandire';

  @override
  String get exerciseOptionsExerciseInfo => 'Info esercizio';

  @override
  String get exerciseOptionsExerciseInfoSubtitle =>
      'Muscoli coinvolti e tecnica';

  @override
  String get exerciseOptionsWarmupInfo => 'Info riscaldamento';

  @override
  String get exerciseOptionsWarmupInfoSubtitle =>
      'Consigli per il riscaldamento';

  @override
  String get exerciseOptionsNoWarmupDataAvailable =>
      'Nessun dato riscaldamento disponibile';

  @override
  String get exerciseOptionsInjuryPrevention => 'Prevenzione infortuni';

  @override
  String get exerciseOptionsInjuryPreventionSubtitle =>
      'Consigli per evitare infortuni';

  @override
  String get exerciseOptionsNoInjuryPreventionDataAvailable =>
      'Nessun dato prevenzione infortuni disponibile';

  @override
  String get exerciseOptionsReportIssue => 'Segnala problema';

  @override
  String get exerciseOptionsReportIssueSubtitle => 'Bug, errori o suggerimenti';

  @override
  String get exerciseOptionsHistory => 'Storico';

  @override
  String get exerciseOptionsEditNameAndNotes => 'Modifica nome e note';

  @override
  String get exerciseOptionsEditNameAndNotesSubtitle =>
      'Personalizza nome esercizio e aggiungi note';

  @override
  String get exerciseOptionsChangeCountingFormat => 'Cambia formato conteggio';

  @override
  String get exerciseOptionsChangeCountingFormatSubtitle =>
      'Passa tra peso/ripetizioni/tempo';

  @override
  String get exerciseOptionsDuplicate => 'Duplica esercizio';

  @override
  String get exerciseOptionsDelete => 'Elimina esercizio';

  @override
  String get exerciseOptionsExerciseInfoTitle => 'Info Esercizio';

  @override
  String get exerciseOptionsPrimaryMuscles => 'Muscoli Primari';

  @override
  String get exerciseOptionsSecondaryMuscles => 'Muscoli Secondari';

  @override
  String get exerciseOptionsEquipment => 'Attrezzatura';

  @override
  String get exerciseOptionsDifficultyLevel => 'Livello Difficoltà';

  @override
  String get exerciseOptionsWarmupInfoTitle => 'Info Riscaldamento';

  @override
  String get exerciseOptionsPreWorkoutMobility => 'Mobilità Pre-Allenamento';

  @override
  String get exerciseOptionsPreWorkoutActivation =>
      'Attivazione Pre-Allenamento';

  @override
  String get exerciseOptionsWarmupSets => 'Serie Riscaldamento';

  @override
  String get exerciseOptionsInjuryPreventionTitle => 'Prevenzione Infortuni';

  @override
  String get exerciseOptionsInjuryPreventionSection => 'Prevenzione Infortuni';

  @override
  String get exerciseOptionsRecommendedCooldown => 'Defaticamento Consigliato';

  @override
  String get exerciseOptionsTechnicalTips => 'Consigli Tecnici';

  @override
  String get dailyWorkoutAutoCompleting =>
      'Completamento automatico giorno... ✨';

  @override
  String get dailyWorkoutDifferentWorkoutCompleted =>
      'Hai completato un allenamento diverso oggi';

  @override
  String get dailyWorkoutSubstitute => 'Sostituisci';

  @override
  String get dailyWorkoutSkip => 'Salta';

  @override
  String get dailyWorkoutComplete => 'Completa';

  @override
  String get dailyWorkoutRestAndRecovery => 'Riposo e Recupero';

  @override
  String get dailyWorkoutRestAndRecoverySubtitle =>
      'Prenditi una pausa e lascia che il tuo corpo recuperi';

  @override
  String get dailyWorkoutDefaultWorkoutName => 'Allenamento';

  @override
  String get dailyWorkoutLoading => 'Caricamento...';

  @override
  String get dailyWorkoutTapCompleteWhenDone => 'Tocca completa quando finito';

  @override
  String get dailyWorkoutGreatWork => 'Ottimo lavoro! Continua così 💪';

  @override
  String get dailyWorkoutDaySkipped =>
      'Giorno saltato. Considera di recuperarlo!';

  @override
  String get dailyWorkoutDayRecovered => 'Giorno recuperato con successo!';

  @override
  String get dailyWorkoutStatusCompleted => 'Completato ✓';

  @override
  String get dailyWorkoutStatusSkipped => 'Saltato';

  @override
  String get dailyWorkoutStatusRecovered => 'Recuperato';

  @override
  String get dailyWorkoutStatusReadyToGo => 'Pronto per iniziare';

  @override
  String get dailyWorkoutSubstituteDialogTitle => 'Sostituisci Allenamento?';

  @override
  String get dailyWorkoutSubstituteDialogMessage =>
      'Hai completato un allenamento diverso oggi. Vuoi segnare questo giorno come completato con quell\'allenamento invece?';

  @override
  String get dailyWorkoutSubstituteDialogConfirm => 'Sostituisci';

  @override
  String get dailyWorkoutSubstituteDialogCancel => 'Annulla';

  @override
  String get exerciseListUseDefaultTimer => 'Usa timer predefinito';

  @override
  String get exerciseListUsesGlobalRestTimer => 'Usa timer di riposo globale';

  @override
  String get exerciseListQuickOptions => 'Opzioni rapide';

  @override
  String get exerciseListUsingDefaultTimer => 'Utilizzo timer predefinito';

  @override
  String get settingsThemeColor => 'Colore Tema';

  @override
  String get settingsThemeColorDesc => 'Tocca per cambiare';

  @override
  String get settingsTextSize => 'Dimensione Testo';

  @override
  String settingsTextSizePreview(Object size) {
    return 'Testo di esempio ($size)';
  }

  @override
  String get settingsWorkoutEssentials => 'Allenamento';

  @override
  String get settingsApreAutoAdjustment => 'Auto-Regolazione APRE';

  @override
  String get settingsApreAutoAdjustmentDesc =>
      'Progressione automatica del peso';

  @override
  String get settingsApreProtocol => 'Protocollo APRE';

  @override
  String settingsApreProtocolDesc(Object number) {
    return 'Protocollo $number';
  }

  @override
  String settingsApreProtocolUpdated(Object protocol) {
    return 'Protocollo APRE aggiornato a $protocol';
  }

  @override
  String get settingsDayCutoffHour => 'Orario Limite Giornata';

  @override
  String settingsDayCutoffHourDesc(int hour) {
    return 'Allenamenti dopo le $hour:00 contano come \'oggi\'';
  }

  @override
  String get settingsDayCutoffHourDialog => 'Orario Limite Giornata';

  @override
  String settingsDayCutoffHourValue(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsDayCutoffHourHint =>
      'Gli allenamenti completati dopo quest\'orario conteranno come \'oggi\'. Utile per lavoratori a turni o sessioni notturne.';

  @override
  String settingsDayCutoffHourUpdated(int hour) {
    return 'Orario limite aggiornato alle $hour:00';
  }

  @override
  String get daysAgoShort => 'g fa';

  @override
  String get weeksAgoShort => 'sett fa';

  @override
  String get monthsAgoShort => 'mesi fa';

  @override
  String get previousDataCopied => 'Dati precedenti copiati in tutti i set';

  @override
  String get chooseWorkoutCategory => 'Scegli categoria workout:';

  @override
  String get fullBody => 'Total Body';

  @override
  String get hiit => 'HIIT';

  @override
  String get customWorkout => 'Personalizza...';

  @override
  String get chestWorkout => 'Allenamento Petto';

  @override
  String get legsWorkout => 'Allenamento Gambe';

  @override
  String get backWorkout => 'Allenamento Schiena';

  @override
  String get armsWorkout => 'Allenamento Braccia';

  @override
  String get cardioWorkout => 'Allenamento Cardio';

  @override
  String get fullBodyWorkout => 'Allenamento Total Body';

  @override
  String get hiitWorkout => 'Allenamento HIIT';

  @override
  String get selectChestWorkout => 'Seleziona allenamento petto';

  @override
  String get selectLegsWorkout => 'Seleziona allenamento gambe';

  @override
  String get selectBackWorkout => 'Seleziona allenamento schiena';

  @override
  String get selectArmsWorkout => 'Seleziona allenamento braccia';

  @override
  String get selectCardioWorkout => 'Seleziona allenamento cardio';

  @override
  String get selectFullBodyWorkout => 'Seleziona allenamento total body';

  @override
  String get selectHiitWorkout => 'Seleziona allenamento HIIT';

  @override
  String get selectCustomWorkout => 'Inserisci nome personalizzato';

  @override
  String get workoutNameRequired => 'Inserisci un nome per il workout';

  @override
  String get workoutNameTooShort => 'Il nome deve contenere almeno 2 caratteri';

  @override
  String get workoutNameTooLong => 'Il nome può contenere massimo 50 caratteri';

  @override
  String workoutCreated(String workoutName) {
    return 'Allenamento $workoutName creato';
  }

  @override
  String get usePreviousWeights => 'Usa Pesi Precedenti';

  @override
  String get selectWeightIncrease => 'Seleziona quanto aumentare i pesi';

  @override
  String get sameWeights => 'Stessi pesi';

  @override
  String get sameWeightsInfo => 'Usa gli stessi pesi dell\'ultimo allenamento';

  @override
  String increaseWeightsInfo(String percentage) {
    return 'Aumenta tutti i pesi del $percentage%';
  }

  @override
  String get morningPrefix => '🌅 Mattutino';

  @override
  String get afternoonPrefix => '☀️ Pomeridiano';

  @override
  String get eveningPrefix => '🌆 Serale';

  @override
  String get nightPrefix => '🌙 Notturno';

  @override
  String get contextTimeTitle => 'Quanto tempo hai disponibile oggi?';

  @override
  String get contextTimeSubtitle =>
      'Ti aiutiamo a scegliere l\'allenamento perfetto';

  @override
  String get contextTimeHelp => 'Scegli quanti minuti puoi allenarti oggi';

  @override
  String timeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String selectTimeMinutes(int minutes) {
    return 'Seleziona $minutes minuti';
  }

  @override
  String get contextExperienceTitle => 'Qual è il tuo livello?';

  @override
  String get contextExperienceSubtitle =>
      'Per suggerirti pesi e ripetizioni giusti';

  @override
  String get experienceBeginner => 'Principiante';

  @override
  String get experienceBeginnerDesc => '< 6 mesi di allenamento';

  @override
  String get experienceIntermediate => 'Intermedio';

  @override
  String get experienceIntermediateDesc => '6-24 mesi';

  @override
  String get experienceAdvanced => 'Avanzato';

  @override
  String get experienceAdvancedDesc => '2+ anni';

  @override
  String selectExperienceLevel(String level) {
    return 'Seleziona $level';
  }

  @override
  String get contextDemographicsTitle => 'Personalizza il tuo allenamento';

  @override
  String get contextDemographicsSubtitle =>
      'Suggeriremo pesi ed esercizi più adatti a te';

  @override
  String get contextDemographicsReassurance =>
      'Puoi sempre cambiarlo nelle impostazioni';

  @override
  String get contextSkipForNow => 'Salta per ora';

  @override
  String get genderMale => 'Maschile';

  @override
  String get genderFemale => 'Femminile';

  @override
  String get genderOther => 'Altro';

  @override
  String selectGender(String gender) {
    return 'Seleziona $gender';
  }

  @override
  String get quickConfirmation => 'Conferma rapida';

  @override
  String quickConfirmationMessage(int minutes, String level) {
    return 'Hai selezionato:\n⏱️ $minutes min\n💪 $level\n\nConfermi?';
  }

  @override
  String get changeAnswers => 'Cambia risposte';

  @override
  String get monthlyProgress => 'Progresso Mensile';

  @override
  String get thisMonthVsLast => 'Questo mese vs scorso mese';

  @override
  String get bestImprovement => 'Miglior Progresso';

  @override
  String get peak => 'Picco';

  @override
  String get newPersonalRecord => 'Nuovo Record Personale';

  @override
  String get awesome => 'Fantastico';

  @override
  String get alternativeExercises => 'Esercizi Alternativi';

  @override
  String get streakMessageNone => 'Inizia la tua serie oggi!';

  @override
  String get streakMessagePersonalRecord => 'Nuovo record personale!';

  @override
  String get streakMessageActive => 'Continua così!';

  @override
  String get streakMessageAtRisk => 'Non rompere la serie! Allenati oggi';

  @override
  String get streakMessageBroken => 'Serie interrotta. Ricomincia oggi!';

  @override
  String get milestoneWeek => 'Guerriero Settimanale';

  @override
  String get milestoneTwoWeeks => 'Campione Bisettimanale';

  @override
  String get milestoneMonth => 'Maestro Mensile';

  @override
  String get milestoneTwoMonths => 'Eroe Bimestrale';

  @override
  String get milestoneQuarter => 'Bestia Trimestrale';

  @override
  String get milestoneSixMonths => 'Leggenda Semestrale';

  @override
  String get milestoneYear => 'Titano Annuale';

  @override
  String milestoneCustom(int days) {
    return '$days giorni';
  }

  @override
  String get achievementUnlocked => 'Obiettivo Sbloccato!';

  @override
  String get rarityCommon => 'Comune';

  @override
  String get rarityUncommon => 'Non Comune';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Epico';

  @override
  String get rarityLegendary => 'Leggendario';

  @override
  String get submit => 'Invia';

  @override
  String get feedbackWhyNotHelpful => 'Perché non è stato utile?';

  @override
  String get dismissReasonAlreadyKnow => 'Lo sapevo già';

  @override
  String get dismissReasonNotRelevant => 'Non rilevante per i miei obiettivi';

  @override
  String get dismissReasonIncorrect => 'Sembra incorretto';

  @override
  String get dismissReasonTooAdvanced => 'Troppo avanzato per me';

  @override
  String get dismissReasonTooBasic => 'Troppo basilare per me';

  @override
  String get dismissReasonNotInterested => 'Non interessato a questo argomento';

  @override
  String get dismissReasonOther => 'Altro motivo';

  @override
  String get feedbackCommentOptional => 'Commenti aggiuntivi (opzionale)';

  @override
  String get feedbackCommentHint =>
      'Raccontaci di più sul perché non è stato utile...';

  @override
  String get featureInsightsName => 'Consigli AI';

  @override
  String get featureInsightsDescription =>
      'Ricevi suggerimenti intelligenti durante gli allenamenti';

  @override
  String get featureNotificationsName => 'Notifiche Intelligenti';

  @override
  String get featureNotificationsDescription =>
      'Promemoria personalizzati per restare motivato';

  @override
  String get featureAchievementsName => 'Obiettivi';

  @override
  String get featureAchievementsDescription =>
      'Sblocca traguardi e celebra i tuoi progressi';

  @override
  String get featureStreakTrackingName => 'Serie di Allenamenti';

  @override
  String get featureStreakTrackingDescription =>
      'Mantieni la tua striscia di allenamenti consecutivi';

  @override
  String get featureAdvancedAnalyticsName => 'Analisi Avanzate';

  @override
  String get featureAdvancedAnalyticsDescription =>
      'Grafici dettagliati e tendenze dei tuoi progressi';

  @override
  String get featureWorkoutSuggestionsName => 'Suggerimenti Allenamento';

  @override
  String get featureWorkoutSuggestionsDescription =>
      'Consigli personalizzati per i tuoi prossimi allenamenti';

  @override
  String get featureRecoveryInsightsName => 'Consigli Recupero';

  @override
  String get featureRecoveryInsightsDescription =>
      'Raccomandazioni per ottimizzare il tuo recupero';

  @override
  String get featureFormCorrectionsName => 'Correzioni Tecnica';

  @override
  String get featureFormCorrectionsDescription =>
      'Suggerimenti per migliorare la tua esecuzione';

  @override
  String get featureGateReasonGloballyDisabled =>
      'Funzionalità non ancora disponibile';

  @override
  String get featureGateReasonUserDisabled =>
      'Hai disabilitato questa funzionalità nelle impostazioni';

  @override
  String get featureGateReasonDefaultEnabled =>
      'Funzionalità abilitata di default';

  @override
  String get featureGateReasonAllRulesPassed => 'Tutti i requisiti soddisfatti';

  @override
  String get featureGateReasonInsufficientExperience =>
      'Livello di esperienza insufficiente';

  @override
  String get featureGateReasonInsufficientWorkouts =>
      'Completa più allenamenti per sbloccare questa funzionalità';

  @override
  String get featureGateReasonAccountTooNew => 'Account troppo recente';

  @override
  String get featureGateReasonLowEffectiveness =>
      'Funzionalità non abbastanza efficace per te';

  @override
  String get featureGateReasonUnknown => 'Motivo sconosciuto';

  @override
  String get notificationSettings => 'Impostazioni Notifiche';

  @override
  String get notificationSettingsDesc =>
      'Gestisci promemoria allenamenti, streak e altro';

  @override
  String get frequencyCaps => 'Limiti di Frequenza';

  @override
  String get frequencyCapsDescription =>
      'Limita le notifiche per prevenire l\'affaticamento';

  @override
  String get maxPerDay => 'Massimo Giornaliero';

  @override
  String get maxPerWeek => 'Massimo Settimanale';

  @override
  String get maxPerWeekDescription =>
      'Ricerche mostrano che >5/settimana aumenta il rischio abbandono del 64%';

  @override
  String get minIntervalHours => 'Intervallo Minimo (ore)';

  @override
  String get minIntervalHoursDescription =>
      'Tempo minimo tra notifiche (previene spam)';

  @override
  String get notificationsPerDay => 'notifiche/giorno';

  @override
  String get notificationsPerWeek => 'notifiche/settimana';

  @override
  String get exceedsResearchLimit =>
      '⚠️ >5/settimana aumenta rischio abbandono del 64% (ricerca scientifica)';

  @override
  String get quietHours => 'Ore Silenziose';

  @override
  String get quietHoursDescription =>
      'Imposta finestre Non Disturbare per categoria';

  @override
  String get quietHoursStart => 'Ora Inizio';

  @override
  String get quietHoursEnd => 'Ora Fine';

  @override
  String get allowPriorityBypass => 'Consenti Priorità Bypass';

  @override
  String get privacyAndGDPR => 'Privacy e GDPR';

  @override
  String get consentStatus => 'Stato Consenso';

  @override
  String get consentGiven => 'Consenso Dato';

  @override
  String get consentNotGiven => 'Consenso Non Dato';

  @override
  String get giveConsent => 'Dai Consenso';

  @override
  String get revokeConsent => 'Revoca Consenso';

  @override
  String get enableAnalytics => 'Abilita Analytics';

  @override
  String get analyticsDescription =>
      'Aiuta a migliorare l\'app condividendo dati di utilizzo';

  @override
  String get dataRetention => 'Conservazione Dati';

  @override
  String dataRetentionDays(int days) {
    return '$days giorni';
  }

  @override
  String get deleteAllData => 'Elimina Tutti i Dati';

  @override
  String get deleteAllDataWarning =>
      'Questo eliminerà permanentemente tutti i dati delle notifiche. Questa azione NON PUÒ essere annullata!';

  @override
  String get deleteAllDataConfirm => 'Scrivi ELIMINA per confermare';

  @override
  String lastSyncedAt(String time) {
    return 'Ultima sincronizzazione: $time';
  }

  @override
  String get syncNow => 'Sincronizza Ora';

  @override
  String get resetToDefaultsConfirm =>
      'Ripristinare tutte le impostazioni notifiche ai valori predefiniti?';

  @override
  String get frequencyCapPresets => 'Preset';

  @override
  String get presetConservative => 'Conservativo (2/giorno, 3/settimana)';

  @override
  String get presetBalanced => 'Bilanciato (3/giorno, 5/settimana)';

  @override
  String get presetAggressive => 'Aggressivo (5/giorno, 10/settimana)';

  @override
  String get presetMinimal => 'Minimale (1/giorno, 2/settimana)';

  @override
  String get quietHoursPresets => 'Preset';

  @override
  String get presetOvernight => 'Notturno (22:00 - 08:00)';

  @override
  String get presetWorkHours => 'Ore Lavorative (09:00 - 17:00)';

  @override
  String get presetWeekendMorning => 'Weekend Mattina (Sab-Dom 08:00 - 12:00)';

  @override
  String get presetSiesta => 'Siesta (14:00 - 16:00)';

  @override
  String get categorySpecificSettings => 'Impostazioni per Categoria';

  @override
  String get recoveryAlerts => 'Avvisi Recupero';

  @override
  String get privacyConsentDialogTitle => 'Privacy e Raccolta Dati';

  @override
  String get privacyConsentDialogBody =>
      'Raccogliamo tempi di consegna notifiche, tipi e stato lettura per migliorare l\'app. I tuoi dati allenamento rimangono sul dispositivo.\n\nPuoi revocare il consenso in qualsiasi momento in Impostazioni.';

  @override
  String get iConsentToDataCollection => 'Acconsento alla raccolta dati';

  @override
  String get acceptConsent => 'Accetta';

  @override
  String get declineConsent => 'Rifiuta';

  @override
  String get syncingSettings => 'Sincronizzazione impostazioni...';

  @override
  String get notificationTypes => 'Tipi di Notifiche';

  @override
  String get dailyWorkoutRemindersDescription =>
      'Ricevi promemoria per completare i tuoi allenamenti giornalieri';

  @override
  String get recoveryAlertsDescription =>
      'Notifiche quando hai giorni da recuperare';

  @override
  String get streakMotivationDescription =>
      'Rimani motivato con la tua serie di allenamenti attiva';

  @override
  String get timingPreferences => 'Preferenze Orario';

  @override
  String get preferredTime => 'Orario Preferito';

  @override
  String get smartScheduling => 'Pianificazione Intelligente';

  @override
  String get smartSchedulingDescription =>
      'L\'IA impara le tue abitudini e pianifica le notifiche in modo ottimale';

  @override
  String get maxPerDayDescription => 'Notifiche massime al giorno';

  @override
  String get quietHoursWindow => 'Finestra Ore Silenziose';

  @override
  String get enableDoNotDisturb => 'Abilita Non Disturbare';

  @override
  String get doNotDisturbDescription =>
      'Silenzia notifiche durante ore specifiche';

  @override
  String get viewConsent => 'Visualizza';

  @override
  String get dataRetentionPeriod => 'Periodo di Conservazione Dati';

  @override
  String get lastSynced => 'Ultima Sincronizzazione';

  @override
  String get neverSynced => 'Mai sincronizzato';

  @override
  String get outOfSync => 'Non Sincronizzato';

  @override
  String get outOfSyncDescription => 'Impostazioni locali e cloud sono diverse';

  @override
  String get resetToDefaultsDescription =>
      'Ripristina tutte le impostazioni ai valori predefiniti';

  @override
  String get deleteAllDataDescription =>
      'Elimina permanentemente tutti i dati delle notifiche';

  @override
  String get custom => 'Personalizzato';

  @override
  String get allDataDeleted => 'Tutti i dati delle notifiche eliminati';

  @override
  String get privacyConsent => 'Consenso Privacy';

  @override
  String get consentDescription =>
      'Attivando le notifiche, acconsenti a ricevere promemoria allenamento personalizzati, avvisi recupero e motivazione serie. Le tue preferenze notifiche e cronologia sono archiviate localmente e sincronizzate su cloud per accesso multi-dispositivo. Puoi revocare il consenso in qualsiasi momento disabilitando le notifiche o eliminando tutti i dati.';

  @override
  String get consentVersion => 'Versione Consenso';

  @override
  String get startTime => 'Ora Inizio';

  @override
  String get endTime => 'Ora Fine';

  @override
  String get supplementReminders => 'Promemoria Integratori';

  @override
  String get supplementRemindersDescription =>
      'Ricevi promemoria per assumere i tuoi integratori (pre-workout, proteine, ecc.)';

  @override
  String get notificationHistory => 'Cronologia Notifiche';

  @override
  String get searchHistory => 'Cerca cronologia...';

  @override
  String get showAll => 'Mostra Tutto';

  @override
  String get unreadOnly => 'Solo Non Lette';

  @override
  String get clearHistory => 'Pulisci Cronologia';

  @override
  String get settingsVersion => 'Versione Impostazioni';

  @override
  String get migrationRequired => 'Migrazione Richiesta';

  @override
  String get migrateNow => 'Migra Ora';

  @override
  String get migrationInProgress => 'Migrazione impostazioni...';

  @override
  String get migrationComplete => 'Migrazione Completata';

  @override
  String get useDefaultTime => 'Usa ora predefinita';

  @override
  String get pr_celebration_title => 'Nuovo Record Personale!';

  @override
  String get pr_previous_value => 'Precedente';

  @override
  String get pr_new_value => 'Nuovo';

  @override
  String get continue_text => 'Continua';

  @override
  String get near_pr_so_close => 'Sei vicinissimo a un PR!';

  @override
  String get near_pr_almost_there => 'Quasi ci sei!';

  @override
  String get near_pr_keep_pushing => 'Continua così!';

  @override
  String get near_pr_to_go => 'per arrivare';

  @override
  String get recovery_tier_basic => 'Base';

  @override
  String get recovery_tier_intermediate => 'Intermedio';

  @override
  String get recovery_tier_advanced => 'Avanzato';

  @override
  String get recovery_tier_basic_desc =>
      'Punteggio prontezza basato su frequenza allenamenti';

  @override
  String get recovery_tier_intermediate_desc =>
      'Stato recupero per muscolo con tracking volume';

  @override
  String get recovery_tier_advanced_desc =>
      'Rilevamento sovrallenamento con metriche HRV + TSB';

  @override
  String get readiness_optimal => 'Ottimale';

  @override
  String get readiness_good => 'Buona';

  @override
  String get readiness_moderate => 'Moderata';

  @override
  String get readiness_low => 'Bassa';

  @override
  String get readiness_very_low => 'Molto Bassa';

  @override
  String get readiness_locked => 'Bloccato';

  @override
  String get muscle_group_chest => 'Petto';

  @override
  String get muscle_group_back => 'Schiena';

  @override
  String get muscle_group_shoulders => 'Spalle';

  @override
  String get muscle_group_biceps => 'Bicipiti';

  @override
  String get muscle_group_triceps => 'Tricipiti';

  @override
  String get muscle_group_legs => 'Gambe';

  @override
  String get muscle_group_core => 'Core';

  @override
  String get recovery_fully_recovered => 'Completamente Recuperato';

  @override
  String get recovery_recovered => 'Recuperato';

  @override
  String get recovery_partially_recovered => 'Parzialmente Recuperato';

  @override
  String get recovery_fatigued => 'Affaticato';

  @override
  String get risk_level_low => 'Rischio Basso';

  @override
  String get risk_level_moderate => 'Rischio Moderato';

  @override
  String get risk_level_high => 'Rischio Alto';

  @override
  String get risk_level_very_high => 'Rischio Molto Alto';

  @override
  String get training_load_very_fresh => 'Molto Fresco';

  @override
  String get training_load_optimal => 'Ottimale';

  @override
  String get training_load_normal => 'Carico Normale';

  @override
  String get training_load_moderate_fatigue => 'Affaticamento Moderato';

  @override
  String get training_load_high_fatigue => 'Affaticamento Elevato';

  @override
  String get training_load_very_high_fatigue => 'Affaticamento Molto Elevato';

  @override
  String get tier_workouts_label => 'Allenamenti';

  @override
  String get tier_days_label => 'Giorni di Dati';

  @override
  String get tier_unlocked => 'Sbloccato!';

  @override
  String get tier_unlock_message => 'Questo tier è ora disponibile';

  @override
  String tier_unlock_requirement(int workouts, int days) {
    return 'Completa $workouts allenamenti in $days giorni per sbloccare';
  }

  @override
  String get migrateWorkoutHistory => 'Migra Storico Allenamenti';

  @override
  String get migrationWarning =>
      'Questo migrerà tutti i tuoi dati storici di allenamento al nuovo sistema di analytics.';

  @override
  String get migrationDescription =>
      'Questa è un\'operazione una tantum che analizza tutti i workout passati e crea uno storico dettagliato degli esercizi. I tuoi workout originali rimarranno invariati.';

  @override
  String get migrate => 'Migra';

  @override
  String get migratingWorkouts => 'Migrazione Allenamenti...';

  @override
  String get workoutsProcessed => 'Allenamenti Processati';

  @override
  String get uniqueExercises => 'Esercizi Unici';

  @override
  String get skipped => 'Saltati';

  @override
  String get migrationFailed => 'Migrazione Fallita';

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String get tryAnotherSearch =>
      'Prova a cercare un esercizio o un gruppo muscolare diverso';

  @override
  String get months => 'Mesi';

  @override
  String get noDataForTimeframe =>
      'Nessun dato disponibile per questo intervallo temporale';

  @override
  String get tryDifferentTimeframe =>
      'Prova a selezionare un intervallo temporale diverso per vedere i tuoi progressi';

  @override
  String get volumeRecord => 'Record di Volume';

  @override
  String get heaviestSingleSet => 'Serie più pesante';

  @override
  String get calculatedMaxStrength => 'Forza massima calcolata';

  @override
  String get highestSingleWorkout => 'Singolo allenamento più alto';

  @override
  String get setsRecord => 'Record di Serie';

  @override
  String get mostSetsInOneWorkout => 'Più serie in un allenamento';

  @override
  String get activityStatistics => 'Statistiche Attività';

  @override
  String get averageLast4Weeks => 'Media (ultime 4 settimane)';

  @override
  String get noRecordsYet => 'Nessun record ancora';

  @override
  String get completeWorkoutsToTrackRecords =>
      'Completa allenamenti per tracciare i record';

  @override
  String get noWorkoutHistory => 'Nessuna cronologia allenamenti';

  @override
  String get noWorkoutHistoryYet => 'Nessuna cronologia allenamenti ancora';

  @override
  String get completeWorkoutToSeeHistory =>
      'Completa un allenamento per vedere la cronologia';

  @override
  String get pr => 'PR';

  @override
  String get records => 'Record';

  @override
  String get expandAll => 'Espandi Tutto';

  @override
  String get collapseAll => 'Comprimi Tutto';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get correctionSavedLocally => 'Correzione salvata localmente';

  @override
  String get correctMuscleGroup => 'Correggi Gruppo Muscolare';

  @override
  String get currentMuscleGroup => 'Gruppo Muscolare Attuale';

  @override
  String get selectMuscleGroup => 'Seleziona Gruppo Muscolare';

  @override
  String get saveCorrection => 'Salva Correzione';

  @override
  String get feedbackSubmittedSuccess =>
      'Feedback inviato! Riceverai una notifica quando l\'admin lo esaminerà.';

  @override
  String get reportToAdmin => 'Segnalare all\'Admin?';

  @override
  String get reportToAdminExplanation =>
      'La tua correzione è già salvata localmente. Vuoi segnalarla al team admin così possono correggerla globalmente per tutti gli utenti?';

  @override
  String get adminWillReviewNotification =>
      'Un admin esaminerà il tuo suggerimento e riceverai una notifica con la decisione.';

  @override
  String get noKeepLocal => 'No, Mantieni Locale';

  @override
  String get yesReportToAdmin => 'Sì, Segnala';

  @override
  String get viewModeByMuscleGroup => 'Per Gruppo Muscolare';

  @override
  String get viewModeByDate => 'Per Data';

  @override
  String get consistencyScore => 'Punteggio Costanza';

  @override
  String get scoreRatingExcellent => 'Eccellente';

  @override
  String get scoreRatingGreat => 'Ottimo';

  @override
  String get scoreRatingGood => 'Buono';

  @override
  String get scoreRatingFair => 'Discreto';

  @override
  String get scoreRatingNeedsImprovement => 'Da Migliorare';

  @override
  String get frequencyScore => 'Frequenza';

  @override
  String get restScore => 'Riposo';

  @override
  String get volumeScore => 'Volume';

  @override
  String get progressionScore => 'Progressione';

  @override
  String get overtrainingRisk => 'Rischio Sovrallenamento';

  @override
  String get riskLow => 'Basso';

  @override
  String get riskMedium => 'Medio';

  @override
  String get riskHigh => 'Alto';

  @override
  String get weeklyAverage => 'Media Settimanale';

  @override
  String get workoutsPerWeek => 'allenamenti a settimana';

  @override
  String get restDaysPerWeek => 'giorni riposo/settimana';

  @override
  String get weeklyStats => 'Statistiche Settimanali (Ultime 4 Settimane)';

  @override
  String get aiCoachChatWelcome => 'Chatta con AI Coach';

  @override
  String get aiCoachChatDescription =>
      'Chiedimi dei tuoi allenamenti, progressi e recupero';

  @override
  String get onboardingWelcomeSubtitle => 'Il tuo coach fitness AI personale';

  @override
  String get onboardingCapabilitiesTitle => 'In cosa posso aiutarti:';

  @override
  String get onboardingProgressionTitle => 'Monitoraggio Progressione';

  @override
  String get onboardingProgressionExample =>
      '\"Come sto progredendo?\" o \"Mostrami i record\"';

  @override
  String get onboardingVolumeTitle => 'Analisi Volume';

  @override
  String get onboardingVolumeExample =>
      '\"Mi sto allenando troppo?\" o \"Volume ottimale?\"';

  @override
  String get onboardingRecoveryTitle => 'Analisi Recupero';

  @override
  String get onboardingRecoveryExample =>
      '\"Devo riposare?\" o \"Sono recuperato?\"';

  @override
  String get onboardingBalanceTitle => 'Equilibrio Muscolare';

  @override
  String get onboardingBalanceExample => '\"I miei muscoli sono bilanciati?\"';

  @override
  String get onboardingFormTitle => 'Forma & Tecnica';

  @override
  String get onboardingFormExample =>
      '\"Consigli sulla tecnica\" o \"Come fare squat?\"';

  @override
  String get onboardingMotivationTitle => 'Spinta Motivazionale';

  @override
  String get onboardingMotivationExample =>
      '\"Ho bisogno di motivazione\" o \"Mostrami i successi\"';

  @override
  String get onboardingPlanTitle => 'Pianificazione Programma';

  @override
  String get onboardingPlanExample =>
      '\"Serve un nuovo programma?\" o \"Frequenza ottimale?\"';

  @override
  String get onboardingPatternExplanation =>
      '💡 Analizzo i tuoi dati di allenamento localmente usando analisi basate su pattern. Nessun servizio AI cloud necessario!';

  @override
  String get onboardingGotIt => 'Perfetto!';

  @override
  String get voiceInputTap => 'Tocca per parlare';

  @override
  String get voiceInputListening => 'Ascolto...';

  @override
  String get voiceInputProcessing => 'Elaborazione...';

  @override
  String get voiceInputError => 'Riconoscimento vocale non disponibile';

  @override
  String get voiceInputPermissionDenied => 'Permesso microfono negato';

  @override
  String get aiCoachQuestionProgress => 'Come sto progredendo?';

  @override
  String get aiCoachQuestionRest => 'Dovrei riposare oggi?';

  @override
  String get aiCoachQuestionVolume => 'Mi sto allenando troppo?';

  @override
  String get clearHistoryConfirm =>
      'Sei sicuro di voler eliminare tutta la cronologia delle conversazioni?';

  @override
  String get aiCoachRespondingHint => 'L\'AI sta rispondendo...';

  @override
  String get typeMessage => 'Scrivi un messaggio...';

  @override
  String get mostUsed => 'Più usati';

  @override
  String get recent => 'Recenti';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get matchBreakdownTitle => 'Dettaglio Compatibilità';

  @override
  String get matchBreakdownPrimaryMuscles => 'Muscoli Primari';

  @override
  String get matchBreakdownEquipment => 'Attrezzatura';

  @override
  String get matchBreakdownMovementPattern => 'Pattern Movimento';

  @override
  String get matchBreakdownSecondaryMuscles => 'Muscoli Secondari';

  @override
  String get matchBreakdownCategory => 'Categoria';

  @override
  String get matchBreakdownTotalScore => 'Punteggio Totale';

  @override
  String get matchBreakdownScore => 'Punteggio';

  @override
  String get matchBreakdownWeight => 'Peso';

  @override
  String get matchBreakdownPrimaryMusclesDesc => 'Pettorali, Deltoidi';

  @override
  String get matchBreakdownEquipmentDesc =>
      'Bilanciere → Manubri (compatibile)';

  @override
  String get matchBreakdownMovementPatternDesc => 'Pattern spinta compatibile';

  @override
  String get matchBreakdownSecondaryMusclesDesc => 'Attivazione diversa';

  @override
  String get matchBreakdownCategoryDesc => 'Petto vs Spalle';

  @override
  String get reportError => 'Segnala Errore';

  @override
  String get reportErrorTitle => 'Segnala Errore Esercizio';

  @override
  String get reportErrorDescription =>
      'Hai trovato informazioni errate? Faccelo sapere e le verificheremo.';

  @override
  String get selectFieldToCorrect => 'Seleziona campo da correggere';

  @override
  String get reasonForChange => 'Motivo della modifica';

  @override
  String get reasonHint =>
      'Spiega perché questa modifica è necessaria (min 10 caratteri)';

  @override
  String get submitCorrection => 'Invia Correzione';

  @override
  String get patchSubmittedSuccess =>
      'Correzione inviata con successo! Sarà revisionata dagli admin.';

  @override
  String get patchSubmittedLocalSuccess =>
      'Correzione applicata localmente. La tua vista è aggiornata immediatamente.';

  @override
  String get patchSubmissionError => 'Errore nell\'invio della correzione';

  @override
  String get reasonTooShort =>
      'La motivazione deve essere di almeno 10 caratteri';

  @override
  String get duplicatePatchError =>
      'Hai già una correzione in attesa per questo campo';

  @override
  String get patchStatusPending => 'In Revisione';

  @override
  String get patchStatusApproved => 'Approvata';

  @override
  String get patchStatusRejected => 'Rifiutata';

  @override
  String get patchStatusAutoRejected => 'Auto-Rifiutata';

  @override
  String get patchStatusExpired => 'Scaduta';

  @override
  String get myCorrections => 'Le Mie Correzioni';

  @override
  String get noPatchesYet => 'Nessuna correzione inviata ancora';

  @override
  String get noPatchesDescription =>
      'Non ci sono correzioni agli esercizi in attesa di revisione';

  @override
  String patchesCount(int count) {
    return '$count correzione/i';
  }

  @override
  String pendingPatchesCount(int count) {
    return '$count in attesa';
  }

  @override
  String get patchApprovedMessage => 'La tua correzione è stata approvata!';

  @override
  String get patchRejectedMessage => 'La tua correzione è stata rifiutata';

  @override
  String get patchExpiredMessage =>
      'Questa correzione è scaduta dopo 30 giorni';

  @override
  String get adminNote => 'Nota admin';

  @override
  String get rejectReason => 'Motivo rifiuto';

  @override
  String daysUntilExpiration(int days) {
    return 'Scade tra $days giorno/i';
  }

  @override
  String get patchExpired => 'Scaduta';

  @override
  String get viewPatchDetails => 'Vedi Dettagli';

  @override
  String get patchDetailsTitle => 'Dettagli Correzione';

  @override
  String get fieldName => 'Campo';

  @override
  String get oldValue => 'Valore vecchio';

  @override
  String get reviewedAt => 'Revisionata';

  @override
  String get pendingReview => 'In attesa di revisione admin';

  @override
  String get approvedAndApplied => 'Approvata e applicata al database';

  @override
  String get rejectedNotApplied => 'Rifiutata - non applicata';

  @override
  String get expiredNotReviewed => 'Scaduta senza revisione';

  @override
  String get reportExerciseError => 'Segnala Errore Esercizio';

  @override
  String get reportErrorSubtitle =>
      'Aiutaci a migliorare il database degli esercizi';

  @override
  String get pleaseSelectField => 'Seleziona un campo';

  @override
  String get enterCorrectedValue => 'Inserisci il valore corretto';

  @override
  String get pleaseEnterNewValue => 'Inserisci un nuovo valore';

  @override
  String get newValueMustDiffer =>
      'Il nuovo valore deve essere diverso dall\'attuale';

  @override
  String get reason => 'Motivazione';

  @override
  String get explainWhyCorrection =>
      'Spiega perché questa correzione è necessaria';

  @override
  String get pleaseProvideReason => 'Fornisci una motivazione';

  @override
  String get exercisePatchReview => 'Revisione Correzioni Esercizi';

  @override
  String get pendingPatches => 'Patch In Attesa';

  @override
  String get reviewedPatches => 'Patch Revisionate';

  @override
  String get noPatches => 'Nessuna patch da revisionare';

  @override
  String get allCaughtUp => 'Tutto fatto!';

  @override
  String get pendingCount => 'In Attesa';

  @override
  String get approvedCount => 'Approvate';

  @override
  String get rejectedCount => 'Rifiutate';

  @override
  String get expiredCount => 'Scadute';

  @override
  String get refreshPatches => 'Aggiorna patch';

  @override
  String get approvePatch => 'Approva';

  @override
  String get rejectPatch => 'Rifiuta';

  @override
  String get patchApproved => 'Patch approvata con successo';

  @override
  String get patchRejected => 'Patch rifiutata con successo';

  @override
  String get patchActionError => 'Errore nell\'elaborazione della patch';

  @override
  String get loadingPatches => 'Caricamento patch...';

  @override
  String get noPatchesToReview => 'Nessuna patch da revisionare';

  @override
  String get allPatchesReviewed => 'Tutte le patch sono state revisionate';

  @override
  String get errorLoadingPatches => 'Errore nel caricamento delle patch';

  @override
  String get feedbackDashboard => 'Dashboard Feedback';

  @override
  String get totalFeedback => 'Feedback Totali';

  @override
  String get allTypes => 'Tutti i Tipi';

  @override
  String get allStatuses => 'Tutti gli Stati';

  @override
  String get allPriorities => 'Tutte le Priorità';

  @override
  String get searchFeedback => 'Cerca feedback...';

  @override
  String get statusOpen => 'Aperto';

  @override
  String get statusReviewing => 'In Revisione';

  @override
  String get statusResolved => 'Risolto';

  @override
  String get statusDismissed => 'Archiviato';

  @override
  String get statusClosed => 'Chiuso';

  @override
  String get severityLow => 'Bassa';

  @override
  String get severityMedium => 'Media';

  @override
  String get severityHigh => 'Alta';

  @override
  String get severityCritical => 'Critica';

  @override
  String get typeExercise => 'Esercizio';

  @override
  String get typeAiInsight => 'AI Coach';

  @override
  String get typeAnalytics => 'Analytics';

  @override
  String get typeBuddyReport => 'Segnalazione Utente';

  @override
  String get typeGeneral => 'Generale';

  @override
  String get typeExercisePatch => 'Correzione Esercizio';

  @override
  String get submitted => 'Inviato';

  @override
  String get user => 'Utente';

  @override
  String get noFeedbackFound => 'Nessun feedback trovato';

  @override
  String get noFeedbackSubmittedYet => 'Nessun feedback inviato';

  @override
  String get noFeedbackSubmittedDescription =>
      'Non hai ancora inviato alcun feedback. Quando lo farai, apparirà qui.';

  @override
  String get yourMessage => 'Il tuo messaggio';

  @override
  String get adminResponded => 'Admin ha risposto';

  @override
  String get adminResponse => 'Risposta Admin';

  @override
  String get createYourFirstRoutine => 'Crea la tua prima routine per iniziare';

  @override
  String get selectRoutineBelow =>
      'Seleziona una routine qui sotto per attivarla';

  @override
  String get activeRoutine => 'Routine Attiva';

  @override
  String get daysPerWeek => 'giorni/settimana';

  @override
  String get activate => 'Attiva';

  @override
  String get activatingRoutine => 'Attivazione routine...';

  @override
  String get createRoutineComingSoon => 'Funzione creazione routine in arrivo';

  @override
  String get viewDetailsComingSoon => 'Funzione dettagli in arrivo';

  @override
  String get deleteComingSoon => 'Funzione eliminazione in arrivo';

  @override
  String get selectPreset => 'Seleziona Preset';

  @override
  String get selectPresetDescription =>
      'Scegli uno split di allenamento che corrisponde ai tuoi obiettivi';

  @override
  String get step2ComingSoon => 'Funzione step 2 in arrivo';

  @override
  String get configureRoutine => 'Configura Routine';

  @override
  String get configureRoutineDescription =>
      'Seleziona giorni di allenamento e assegna template workout';

  @override
  String get routineName => 'Nome Routine';

  @override
  String get assignTemplates => 'Assegna Template';

  @override
  String get tapToAssignTemplate => 'Tocca per assegnare template';

  @override
  String get templatePickerComingSoon => 'Selettore template in arrivo';

  @override
  String get userNotLoggedIn => 'Utente non autenticato';

  @override
  String get routineCreated => 'Routine creata con successo!';

  @override
  String get noPresetSelected => 'Nessun preset selezionato';

  @override
  String get basicInfo => 'Informazioni Base';

  @override
  String get presetType => 'Tipo Preset';

  @override
  String get presetPpl6DayDescription =>
      'Allenati 6 giorni a settimana con una divisione spinta/tirata/gambe. Ideale per atleti intermedi che vogliono alta frequenza e volume.';

  @override
  String get presetUpperLower4DayDescription =>
      'Alterna allenamenti parte alta e bassa del corpo 4 giorni a settimana. Perfetto per principianti che costruiscono forza.';

  @override
  String get presetFullBody3DayDescription =>
      'Allena tutto il corpo 3 volte a settimana. Ottimo per principianti o chi ha poco tempo.';

  @override
  String get presetBroSplit5DayDescription =>
      'Isola un gruppo muscolare al giorno, 5 giorni a settimana. Approccio bodybuilding tradizionale per atleti avanzati.';

  @override
  String get presetCustomDescription =>
      'Crea il tuo programma di allenamento personalizzato. Scegli i giorni e i gruppi muscolari.';

  @override
  String get createdAt => 'Creata';

  @override
  String get workoutSchedule => 'Programma Allenamento';

  @override
  String get completedDays => 'Giorni Completati';

  @override
  String get deleteRoutine => 'Elimina Routine';

  @override
  String get deleteRoutineConfirmation =>
      'Sei sicuro di voler eliminare questa routine? Questa azione non può essere annullata.';

  @override
  String get routineActivated => 'Routine attivata';

  @override
  String get routineDeactivated => 'Routine disattivata';

  @override
  String get deactivate => 'Disattiva';

  @override
  String get noTemplateAssigned => 'Nessun template assegnato';

  @override
  String get selectTemplate => 'Seleziona Template';

  @override
  String get publicTemplates => 'Template Pubblici';

  @override
  String get noTemplatesAvailable => 'Nessun template disponibile';

  @override
  String get createTemplateFirst =>
      'Crea prima un template da assegnare a questo giorno';

  @override
  String get powerlifting => 'Powerlifting';

  @override
  String get bodybuilding => 'Bodybuilding';

  @override
  String get crossfit => 'CrossFit';

  @override
  String get calisthenics => 'Calisthenics';

  @override
  String get mixed => 'Misto';

  @override
  String get outOf => 'su';

  @override
  String get routineNameTooLong =>
      'Nome routine troppo lungo (max 50 caratteri)';

  @override
  String get enterRoutineName => 'Inserisci nome routine';

  @override
  String get routineUpdated => 'Routine aggiornata con successo';

  @override
  String get stepOneOfTwo => '1/2';

  @override
  String get stepTwoOfTwo => '2/2';

  @override
  String get choosePreset => 'Scegli un preset';

  @override
  String get volumeProgressionExceptional =>
      'Crescita eccezionale! Stai stracciando i tuoi obiettivi! 🚀';

  @override
  String get volumeProgressionGreat => 'Ottimi progressi! Continua così! 💪';

  @override
  String get volumeProgressionSteady =>
      'Miglioramento costante! Sei sulla strada giusta! 📈';

  @override
  String get volumeProgressionMinorDip =>
      'Piccolo calo, ma ce la fai! Resta costante! 💫';

  @override
  String get volumeProgressionRefocus =>
      'Tempo di rifocalizzarsi! Ricorda i tuoi obiettivi! 🎯';

  @override
  String get volumeTrend => 'Trend Volume';

  @override
  String get whatIsVolume => 'Cos\'è il Volume?';

  @override
  String get lastFourWeeks => 'Ultime 4 Settimane';

  @override
  String weekNumber(int number) {
    return 'Settimana $number';
  }

  @override
  String get thisWeekDetails => 'Dettagli Questa Settimana';

  @override
  String weekNumberDetails(int number) {
    return 'Dettagli Settimana $number';
  }

  @override
  String get avgPerWorkout => 'Media per Allenamento';

  @override
  String get weeklyConsistencyExcellent =>
      'Eccellente costanza! Hai raggiunto il tuo obiettivo settimanale! 🎯';

  @override
  String get weeklyConsistencyAlmost =>
      'Quasi! Ancora un allenamento per raggiungere l\'obiettivo! 💪';

  @override
  String get weeklyConsistencyGood => 'Buoni progressi! Continua così! 📈';

  @override
  String get weeklyConsistencyOnTrack =>
      'Sei sulla buona strada! Non fermarti! 🔥';

  @override
  String get weeklyConsistencyStart =>
      'Ogni viaggio inizia con un singolo passo! Andiamo! 🚀';

  @override
  String get weeklyDetails => 'Dettagli Settimanali';

  @override
  String get weeklyWorkouts => 'Allenamenti Settimanali';

  @override
  String get thisWeekShort => 'Questa Settimana';

  @override
  String get goalAchieved => 'Obiettivo!';

  @override
  String get lastSevenDays => 'Ultimi 7 Giorni';

  @override
  String get motivation => 'Motivazione';

  @override
  String get consistencyTips => 'Suggerimenti sulla Costanza';

  @override
  String get tipScheduleWorkouts =>
      'Programma gli allenamenti come appuntamenti';

  @override
  String get tipStartSmall => 'Inizia gradualmente: costanza > intensità';

  @override
  String get tipRestDays => 'I giorni di riposo fanno parte del progresso!';

  @override
  String get weeklyGoal => 'Obiettivo Settimanale';

  @override
  String workoutsGoalLabel(int count) {
    return '$count allenamenti';
  }

  @override
  String get prToday => 'Oggi';

  @override
  String get prYesterday => 'Ieri';

  @override
  String prDaysAgo(int days) {
    return '$days giorni fa';
  }

  @override
  String get resetAllPRsQuestion => 'Resettare tutti i PR?';

  @override
  String get resetAllPRsMessage =>
      'Questo cancellerà permanentemente tutti i dati dei record personali. La cronologia allenamenti rimarrà, ma il tracciamento PR ripartirà da zero. \n\nQuesta azione non può essere annullata.';

  @override
  String get prResetComingSoon => '🔄 Funzionalità reset PR in arrivo presto!';

  @override
  String get prDetails => 'Dettagli PR';

  @override
  String get recentPRsLastSevenDays => 'PR Recenti (Ultimi 7 Giorni)';

  @override
  String prAchievements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'traguardi',
      one: 'traguardo',
    );
    return '$count $_temp0';
  }

  @override
  String get newBadge => 'Nuovo!';

  @override
  String get whatIsPR => 'Cos\'è un PR?';

  @override
  String get prExplanation =>
      'PR (Record Personale) è la tua migliore performance per un esercizio, misurato con l\'1RM stimato (massimale su una ripetizione). Tracciamo automaticamente i tuoi PR mentre ti alleni, così puoi vedere i tuoi progressi nel tempo.';

  @override
  String get noPRsYetMessage =>
      'Inizia a tracciare i tuoi allenamenti per vedere i tuoi record personali qui!';

  @override
  String get allPersonalRecords => 'Tutti i Record Personali';

  @override
  String get newLabel => 'NUOVO';

  @override
  String get resetPRs => 'Resetta PR';

  @override
  String get resetPRsMessage =>
      'Vuoi ricominciare da capo? Puoi resettare tutti i record personali. Questo NON cancellerà la cronologia allenamenti.';

  @override
  String resetAllPRsButton(int count) {
    return 'Resetta Tutti i PR ($count record)';
  }

  @override
  String get consistencyIndicators => 'Indicatori Consistenza';

  @override
  String get training => 'Allenamento';

  @override
  String get rest => 'Riposo';

  @override
  String get doingWell => 'Stai andando bene!';

  @override
  String get canImprove => 'Puoi migliorare';

  @override
  String get reviewRoutine => 'Rivedi la tua routine';

  @override
  String get frequencyOptimalTip =>
      'Perfetto! Sei nel range ottimale di 3-5 allenamenti a settimana.';

  @override
  String get frequencyImproveTip =>
      'Prova ad allenarti 3-5 volte a settimana per risultati migliori secondo la ricerca.';

  @override
  String get restOptimalTip =>
      'Ottimo equilibrio! Stai recuperando correttamente con 2-3 giorni di riposo a settimana.';

  @override
  String get restImproveTip =>
      'Punta a 2-3 giorni di riposo a settimana per prevenire infortuni e favorire il recupero.';

  @override
  String get progressionOptimalTip =>
      'Eccellente! Stai progredendo con un miglioramento >5%.';

  @override
  String get progressionImproveTip =>
      'Prova ad aumentare peso o ripetizioni gradualmente (5-10% a settimana è ottimale).';

  @override
  String get optimalRange => 'Range ottimale';

  @override
  String get source => 'Fonte';

  @override
  String get weeklyStatistics => 'Statistiche Settimanali';

  @override
  String get workoutsCompleted => 'Allenamenti completati';

  @override
  String get restDays => 'Giorni di riposo';

  @override
  String get averageFrequency => 'Frequenza media';

  @override
  String get errorLoadingConsistencyScore =>
      'Errore caricamento punteggio coerenza';

  @override
  String get errorOpeningLink => 'Errore apertura link';

  @override
  String get cannotOpenLink => 'Impossibile aprire il link';

  @override
  String get buddyOnboardingWelcome => 'Benvenuto!';

  @override
  String get buddyOnboardingYourLevel => 'Il tuo livello';

  @override
  String get buddyOnboardingYourGoals => 'I tuoi obiettivi';

  @override
  String get buddyOnboardingYourSchedule => 'I tuoi orari';

  @override
  String get buddyOnboardingYourLocation => 'La tua zona';

  @override
  String get buddyOnboardingYourProfile => 'Il tuo profilo';

  @override
  String get buddyOnboardingAllSet => 'Tutto pronto!';

  @override
  String get skipOnboardingTitle => 'Salta configurazione?';

  @override
  String get skipOnboardingMessage =>
      'Puoi sempre modificare le tue preferenze successivamente';

  @override
  String get importExercisesReady => 'Pronto per importare gli esercizi';

  @override
  String get firebaseExerciseImporter => 'Importatore Esercizi Firebase';

  @override
  String get testSingleExercise => '🧪 Testa Singolo Esercizio';

  @override
  String get importAllExercises => '🔥 Importa Tutti gli Esercizi';

  @override
  String get importExercisesDescription =>
      'Questo importerà tutti gli esercizi da assets/data/exercises.json a Firebase Firestore.';

  @override
  String get testingExercise => '🧪 Test conversione singolo esercizio...';

  @override
  String get testSuccess =>
      '✅ Test completato con successo! Controlla la console per i dettagli.';

  @override
  String get testFailed => '❌ Test fallito';

  @override
  String get confirmImportTitle => 'Conferma Importazione';

  @override
  String get confirmImportMessage =>
      'Questo eliminerà tutti gli esercizi esistenti e ne importerà di nuovi dal JSON. Continuare?';

  @override
  String get importAction => 'Importa';

  @override
  String get importStarting => '🔥 Avvio processo di importazione...';

  @override
  String get importSuccess =>
      '✅ Importazione completata con successo! Tutti gli esercizi importati su Firebase.';

  @override
  String get importSuccessTitle => 'Importazione Riuscita';

  @override
  String get importSuccessMessage =>
      'Tutti gli esercizi sono stati importati su Firebase. Ora puoi usarli nell\'app!';

  @override
  String get importFailedTitle => 'Importazione Fallita';

  @override
  String get contributionDetails => 'Dettagli Contributo';

  @override
  String get adminActions => 'Azioni Admin';

  @override
  String commentsCount(int count) {
    return 'Commenti ($count)';
  }

  @override
  String get noCommentsYet => 'Nessun commento ancora';

  @override
  String get beFirstToComment => 'Sii il primo a commentare!';

  @override
  String get addCommentHint => 'Aggiungi un commento...';

  @override
  String get reportContribution => 'Segnala contributo';

  @override
  String get upvoteSuccess => '👍 Voto positivo!';

  @override
  String get downvoteSuccess => '👎 Voto negativo';

  @override
  String get commentAddedSuccess => '💬 Commento aggiunto!';

  @override
  String get contributionApprovedSuccess => '✅ Contributo approvato!';

  @override
  String get contributionRejectedSuccess => '🚫 Contributo rifiutato';

  @override
  String get reportSubmittedSuccess => '🚨 Segnalazione inviata';

  @override
  String get rejectContributionTitle => 'Rifiuta Contributo';

  @override
  String get rejectReasonLabel => 'Specifica il motivo del rifiuto:';

  @override
  String get rejectReasonHint => 'Es: Informazioni non accurate';

  @override
  String get reportReasonOffensive => 'Contenuto offensivo';

  @override
  String get reportReasonWrongInfo => 'Informazioni errate';

  @override
  String get reportReasonDuplicate => 'Duplicato';

  @override
  String get reportContributionTitle => 'Segnala Contributo';

  @override
  String get reportReasonLabel => 'Motivo della segnalazione:';

  @override
  String get reportReasonOtherHint => 'Specifica il motivo';

  @override
  String get reportAction => 'Segnala';

  @override
  String get newContribution => 'Nuovo Contributo';

  @override
  String get titleLabel => 'Titolo';

  @override
  String get titleHintContribution => 'Es: Migliore presa per principianti';

  @override
  String get titleRequired => 'Il titolo è obbligatorio';

  @override
  String get titleMinLength => 'Il titolo deve essere almeno 10 caratteri';

  @override
  String get descriptionLabel => 'Descrizione';

  @override
  String get descriptionRequired => 'La descrizione è obbligatoria';

  @override
  String get descriptionMinLength =>
      'La descrizione deve essere almeno 20 caratteri';

  @override
  String get currentValueIncorrect => 'Valore Attuale (Errato)';

  @override
  String get currentValueHint => 'Es: Presa stretta';

  @override
  String get currentValueRequired =>
      'Valore attuale obbligatorio per correzioni';

  @override
  String get correctedValue => 'Valore Corretto';

  @override
  String get correctedValueHint => 'Es: Presa larga';

  @override
  String get correctedValueRequired => 'Valore corretto obbligatorio';

  @override
  String get contributionReviewInfo =>
      'Il tuo contributo sarà revisionato da un admin prima di essere pubblicato. Riceverai +50 XP se approvato!';

  @override
  String get sending => 'Invio...';

  @override
  String get submitContribution => 'Invia Contributo';

  @override
  String get exerciseLabel => 'Esercizio';

  @override
  String get tapToSelectExercise => 'Tocca per selezionare un esercizio';

  @override
  String get contributionType => 'Tipo di Contributo';

  @override
  String get selectExerciseWarning => '⚠️ Seleziona un esercizio';

  @override
  String get descriptionHintTip =>
      'Condividi un consiglio utile per questo esercizio...';

  @override
  String get descriptionHintWarning =>
      'Descrivi cosa evitare e perché è pericoloso...';

  @override
  String get descriptionHintCorrection =>
      'Spiega qual è l\'errore comune e come correggerlo...';

  @override
  String get descriptionHintTechnique =>
      'Descrivi la tecnica corretta passo per passo...';

  @override
  String get descriptionHintVariant =>
      'Descrivi la variante dell\'esercizio...';

  @override
  String get descriptionHintTranslation => 'Fornisci la traduzione corretta...';

  @override
  String get typeDescriptionTip =>
      'Consiglio pratico per migliorare l\'esecuzione';

  @override
  String get typeDescriptionWarning => 'Avviso su errori comuni o rischi';

  @override
  String get typeDescriptionCorrection => 'Correzione di informazioni errate';

  @override
  String get typeDescriptionTechnique => 'Spiegazione tecnica dettagliata';

  @override
  String get typeDescriptionVariant => 'Variante dell\'esercizio';

  @override
  String get typeDescriptionTranslation => 'Traduzione dell\'esercizio';

  @override
  String get typeLabelTip => 'Consiglio';

  @override
  String get typeLabelWarning => 'Avviso';

  @override
  String get typeLabelCorrection => 'Correzione';

  @override
  String get typeLabelTechnique => 'Tecnica';

  @override
  String get typeLabelVariant => 'Variante';

  @override
  String get typeLabelTranslation => 'Traduzione';
}
