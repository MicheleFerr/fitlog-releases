# FitLog Pro - Documentazione

**Benvenuto!** Questa è la documentazione principale del progetto FitLog Pro.

## 📚 Struttura Documentazione

La documentazione è organizzata in tre aree principali:

### 🎯 [FEATURES](FEATURES/) — Feature del Prodotto
Documentazione per **ogni feature del prodotto**. Leggi qui se vuoi capire come funziona una particolare funzionalità.

- Workout Management
- Timer & Notifications  
- Analytics & History
- Exercise Database
- User Profiles
- Premium Features

### 🔧 [TECHNICAL](TECHNICAL/) — Guide Tecniche
Guide tecniche per **sviluppatori**. Leggi qui se devi implementare o modificare il codice.

- Architecture Overview
- State Management (Riverpod)
- Data Layer Patterns
- iOS Native Integration
- Performance Guidelines
- Security Best Practices

### 📖 [GUIDES](GUIDES/) — Tutorial & Setup
Guide pratiche per **setup e workflow**.

- Development Setup
- Running Tests
- Building for iOS/Android
- TestFlight Release
- Debugging Guide

---

## 🚀 Quick Start

**Sono nuovo al progetto?**
1. Leggi [`GUIDES/DEVELOPMENT_SETUP.md`](GUIDES/DEVELOPMENT_SETUP.md)
2. Esplora [`TECHNICAL/ARCHITECTURE.md`](TECHNICAL/ARCHITECTURE.md)
3. Guarda [`FEATURES/OVERVIEW.md`](FEATURES/OVERVIEW.md)

**Devo implementare una feature?**
1. Leggi la feature documentation in [`FEATURES/`](FEATURES/)
2. Consulta i pattern in [`TECHNICAL/CODE_PATTERNS.md`](TECHNICAL/CODE_PATTERNS.md)
3. Segui le linee guida in [`TECHNICAL/PERFORMANCE.md`](TECHNICAL/PERFORMANCE.md)

**Ho un problema?**
→ Vedi [`GUIDES/DEBUGGING.md`](GUIDES/DEBUGGING.md)

---

## 🆕 Latest Features

### AI Coach (v1.0 - MVP Complete)
Assistente fitness intelligente basato su LLM (OpenRouter + Mistral 7B) con function calling per accesso ai dati utente reali.

- 📋 **Design**: [`AI_COACH_DESIGN.md`](AI_COACH_DESIGN.md)
- ✅ **Status**: [`AI_COACH_IMPLEMENTATION_STATUS.md`](AI_COACH_IMPLEMENTATION_STATUS.md)
- 🎯 **MVP Ready**: 8/8 success criteria passed
- 🔐 **Privacy**: GDPR compliant (ephemeral chat)
- 🚀 **Deploy**: Ready for beta testing

---

## 📋 Regole Importanti

Vedi [`CLAUDE.md`](../CLAUDE.md) per le regole di sviluppo critiche.

**Punti chiave:**
- ✅ `AppIcons.*` (no `Icons.*`)
- ✅ `context.l10n.*` (no hardcoded text)
- ✅ `context.colors.*` (no `Colors.*`)
- ✅ Performance: No I/O in loop, batch operations

---

## 📞 Support

Domande? Problemi?
- Controlla [`GUIDES/FAQ.md`](GUIDES/FAQ.md)
- Leggi [`GUIDES/DEBUGGING.md`](GUIDES/DEBUGGING.md)

---

**Last Updated:** February 2025
