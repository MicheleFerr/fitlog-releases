# 📚 FitLog Pro - Documentation Index

**Framework**: Flutter | **Architecture**: Clean Architecture + Riverpod 3.x | **Status**: 🧪 Beta Testing

---

## 🚀 Quick Start

- **New Developer?** → Start with [`CLAUDE.md`](../CLAUDE.md) (project rules & patterns)
- **Working on Onboarding?** → [`ONBOARDING_COMPLETE_REFERENCE.md`](ONBOARDING_COMPLETE_REFERENCE.md)
- **Beta Launch?** → [`BETA_LAUNCH_CHECKLIST.md`](BETA_LAUNCH_CHECKLIST.md)
- **Debugging?** → [`DEBUG_AUDIT_ACTION_PLAN.md`](DEBUG_AUDIT_ACTION_PLAN.md) + [`CLAUDE.md`](../CLAUDE.md#debugging)

---

## 📖 Documentation Structure

### Core Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [`CLAUDE.md`](../CLAUDE.md) | **PROJECT RULES** - Must read first (includes code patterns & dev rules) | All developers |
| [`BRAND_GUIDELINES.md`](BRAND_GUIDELINES.md) | **BRAND IDENTITY** - Colori, tipografia, icone, spacing, componenti | All developers |
| [`BETA_LAUNCH_CHECKLIST.md`](BETA_LAUNCH_CHECKLIST.md) | Beta launch readiness checklist | All developers |
| [`USER_PERSONAS.md`](USER_PERSONAS.md) | 5 user personas for UX decisions | All developers |

### Feature Documentation

#### AI Coach System
| Document | Purpose | Status |
|----------|---------|--------|
| [`AI_COACH_DOCUMENTS_SYSTEM_DESIGN.md`](AI_COACH_DOCUMENTS_SYSTEM_DESIGN.md) | Backend design - Admin panel + Firebase + API endpoints | ✅ Complete |
| [`AI_COACH_DOCUMENTS_FLUTTER_DESIGN.md`](AI_COACH_DOCUMENTS_FLUTTER_DESIGN.md) | Flutter implementation - Sync service + Hive cache + AI integration | ✅ Complete |
| [`AI_COACH_DOCUMENTS_IMPLEMENTATION.md`](AI_COACH_DOCUMENTS_IMPLEMENTATION.md) | **Implementation Report** - Backend API + Flutter layers + Delta sync | ✅ Complete |
| [`AI_COACH_SMART_SUGGESTIONS_DESIGN.md`](AI_COACH_SMART_SUGGESTIONS_DESIGN.md) | **Smart Suggestions** - Autocomplete esercizi stile Perplexity | 📋 Proposta |

#### Exercise Popularity Ranking (✅ New - 2026-02-10)
| Document | Purpose | Status |
|----------|---------|--------|
| [`design/EXERCISE_POPULARITY_RANKING.md`](design/EXERCISE_POPULARITY_RANKING.md) | **System Design** - Data Bundles, Cloud Functions, Search Boost (1.0x-1.5x) | ✅ Implemented |
| [`EXERCISE_POPULARITY_TESTING.md`](EXERCISE_POPULARITY_TESTING.md) | **Testing Guide** - Manual testing steps, verification commands, success criteria | 📋 Ready for Testing |

#### Debug Audit (✅ New - 2026-02-08)
| Document | Purpose |
|----------|---------|
| [`DEBUG_AUDIT_ACTION_PLAN.md`](DEBUG_AUDIT_ACTION_PLAN.md) | **FULL CODEBASE AUDIT** - 23 critical issues, prioritized action plan, checklist esecuzione |

#### Firebase Memory Leak (🔥 Critical - 2026-02-10)
| Document | Purpose | Status |
|----------|---------|--------|
| [`FIREBASE_GRPC_MEMORY_LEAK_FIX.md`](FIREBASE_GRPC_MEMORY_LEAK_FIX.md) | **iOS gRPC Memory Leak** - Analisi Instruments, bug Firebase SDK confermati, workaround SICURI, testing plan | 🔴 In Testing |

#### Template Cloud Sync (✅ New - 2026-02-05)
| Document | Purpose |
|----------|---------|
| [`TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md`](TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md) | Exponential backoff retry system for Cloud Function failures (13/17 tests passing) |

#### Onboarding System (✅ Just Completed)
| Document | Purpose |
|----------|---------|
| [`ONBOARDING_FINAL_SUMMARY.md`](ONBOARDING_FINAL_SUMMARY.md) | **PROJECT SUMMARY** - 9 iterations, all bugs fixed, production ready |
| [`ONBOARDING_COMPLETE_REFERENCE.md`](ONBOARDING_COMPLETE_REFERENCE.md) | Complete system reference with architecture, flows, troubleshooting |
| [`ITERATION_8_IMPLEMENTATION.md`](ITERATION_8_IMPLEMENTATION.md) | Technical implementation details of P0 bug fixes |

#### Architecture
Architecture is documented in [`CLAUDE.md`](../CLAUDE.md) (section Architettura).

#### User Experience
| Document | Purpose |
|----------|---------|
| [`USER_PERSONAS.md`](USER_PERSONAS.md) | 5 user personas (Marco, Chiara, Luca, Sofia, Roberto) |

#### Design Proposals
| Document | Purpose |
|----------|---------|
| [`WORKOUT_TAB_REDESIGN_PLAN.md`](WORKOUT_TAB_REDESIGN_PLAN.md) | **Workout Tab Redesign** - Fix disconnessione UX, AI suggestion, carousel template recenti |
| [`design/PLATE_CALCULATOR_REDESIGN.md`](design/PLATE_CALCULATOR_REDESIGN.md) | Plate Calculator 2.0 - Gym Profiles, Quick Selection, Smart Recalc |
| [`design/TEMPLATE_CARDS_DESIGN_UNIFICATION.md`](design/TEMPLATE_CARDS_DESIGN_UNIFICATION.md) | Unificazione design template cards con analisi personas |
| [`design/EXERCISE_POPULARITY_RANKING.md`](design/EXERCISE_POPULARITY_RANKING.md) | Exercise Popularity Ranking (Cloud Functions + Data Bundles) |

### Archived Documentation

**Location**: [`docs/_archived/`](../_archived/)

Includes:
- Old ADRs (architectural decision records)
- Previous implementation guides
- Deprecated system documentation
- Legacy analysis (for reference only)

---

## 🎯 Task-Based Navigation

### "I need to..."

#### Implement a new feature
1. Read [`CLAUDE.md`](../CLAUDE.md) for project rules
2. Check [`CODE_PATTERNS.md`](CODE_PATTERNS.md) for similar implementations
3. Follow [`DEVELOPMENT_RULES.md`](DEVELOPMENT_RULES.md) checklist

#### Fix a bug
1. Search git log for context: `git log --grep="<bug>" --oneline`
2. Check CLAUDE.md debug section
3. Review [`CODE_PATTERNS.md`](CODE_PATTERNS.md) for best practices
4. Add tests before fixing

#### Understand the onboarding system
1. Start: [`ONBOARDING_FINAL_SUMMARY.md`](ONBOARDING_FINAL_SUMMARY.md) (high-level overview)
2. Details: [`ONBOARDING_COMPLETE_REFERENCE.md`](ONBOARDING_COMPLETE_REFERENCE.md)
3. Code: [`lib/features/onboarding/`](../lib/features/onboarding/)
4. Tests: [`test/features/onboarding/`](../test/features/onboarding/)

#### Make design decisions
1. Review [`USER_PERSONAS.md`](USER_PERSONAS.md) for impact analysis
2. Check [`BRAND_GUIDELINES.md`](BRAND_GUIDELINES.md) for visual identity
3. Check [`DESIGN_GUIDELINES.md`](DESIGN_GUIDELINES.md)
4. Reference [`architecture/OVERVIEW.md`](architecture/OVERVIEW.md)

#### Improve performance
1. Use tool: `.claude/scripts/performance-check.sh lib/features/<feature>/`
2. Review performance section in [`CLAUDE.md`](../CLAUDE.md)
3. Profile with DevTools (see [`DEVELOPMENT_RULES.md`](DEVELOPMENT_RULES.md))

---

## 🔍 Feature Map

| Feature | Status | Key Files | Documentation |
|---------|--------|-----------|-----------------|
| **AI Coach Documents** | ✅ Backend Complete | `lib/features/ai_coach/` + Next.js API | [`AI_COACH_DOCUMENTS_IMPLEMENTATION.md`](AI_COACH_DOCUMENTS_IMPLEMENTATION.md) |
| **Template Cloud Sync** | ✅ Complete | `lib/features/workout/data/services/` | [`TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md`](TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md) |
| **Onboarding** | ✅ Complete | `lib/features/onboarding/` | [`ONBOARDING_COMPLETE_REFERENCE.md`](ONBOARDING_COMPLETE_REFERENCE.md) |
| **Workouts** | 🟢 Active | `lib/features/workout/` | See code + tests |
| **Analytics** | ✅ P1 UX Complete | `lib/features/analytics/` | [`../IMPLEMENTATION_PLAN_P1.md`](../IMPLEMENTATION_PLAN_P1.md) + [`research/`](research/) |
| **AI Coach** | 🟢 Active | `lib/features/ai_coach/` | See code + tests |
| **Health Sync** | 🟢 Active | `lib/features/health_sync/` | See code + tests |
| **Settings** | 🟢 Active | `lib/features/settings/` | See code + tests |

---

## 💾 Iteration History

### Onboarding System Optimization (9 Iterations - ✅ COMPLETE)

| # | Phase | Status | Summary |
|---|-------|--------|---------|
| 1 | Bug Fixes + Analysis | ✅ | Identified P0-1,2,3 bugs + initial architectural analysis |
| 2 | System Architecture Audit | ✅ | Deep dive into OnboardingOrchestrator, tour system |
| 3 | UX Research & Best Practices | ✅ | Competitive analysis, Nielsen Norman guidelines |
| 4 | Bug Hunt & Edge Cases | ✅ | Found state management issues, race conditions |
| 5 | Personas Impact Analysis | ✅ | User impact assessment (Marco→Roberto personas) |
| 6 | Security & Privacy Audit | ✅ | GDPR compliance, encryption, data handling |
| 7 | Performance Optimization | ✅ | <2s launch, 60fps, <100MB memory |
| 8 | Implementation & Testing | ✅ | **P0 fixes + 16 tests passing** |
| 9 | Documentation & Finalization | ✅ | **Complete reference + final summary** |

**Result**: ✅ All bugs fixed, 16/16 tests passing, production ready

### Analytics UX Improvements (P0-P1 - ✅ COMPLETE)

**Implementation**: 2026-02-13 | **Plan**: [`IMPLEMENTATION_PLAN_P1.md`](../IMPLEMENTATION_PLAN_P1.md)

| Phase | Tasks | Status | Summary |
|-------|-------|--------|---------|
| **P0** | Critical Fixes | ✅ | Correlations, +0% Messages, WeeklySummaryBanner |
| **P1.2** | Progressive Disclosure | ✅ | Simple/Detailed view toggle with persistence |
| **P1.3** | Sparklines | ✅ | 60x24px mini charts in exercise list |
| **P1.4** | Delta Calculations | ✅ | Week-over-week trends for all summary cards |
| **P1.5** | Educational Tooltips | ✅ | Metric explanations (RPE, 1RM, Volume, Tonnage, Correlation) |
| **P1.6** | Enhanced Empty States | ✅ | Motivational messages for 3 scenarios |

**Research Materials**: [`docs/research/`](research/)
- UX Best Practices, Competitor Analysis, Persona Analysis
- Stats UX Improvement Plan, Implementation Prompt

**Results**:
- 4 new widgets/providers (~634 lines)
- 11 l10n keys (EN + IT)
- Code review: A+ (95/100)
- All 5 personas benefit (Marco +++, Chiara ++, Sofia +++)

---

## 🛠️ Developer Tools

### Useful Commands

```bash
# Code quality
flutter analyze lib/features/onboarding/
flutter format lib/features/onboarding/

# Testing
flutter test test/features/onboarding/
flutter test test/features/onboarding/ -v

# Localization
flutter gen-l10n

# Performance check
.claude/scripts/performance-check.sh lib/features/onboarding/

# Git workflow
git status && git diff
git log --oneline -20
git commit -m "feat: ..."
```

### Tools & Scripts

| Script | Purpose |
|--------|---------|
| `.claude/scripts/performance-check.sh` | Detects performance anti-patterns |
| `.claude/scripts/health-check.sh` | Finds zombie/orphaned files |
| `.claude/scripts/gather-context.sh` | Loads project context |

---

## 🎓 Learning Resources

### For New Developers

1. **Read First**:
   - [`CLAUDE.md`](../CLAUDE.md) - Project rules (15 min)
   - [`CODE_PATTERNS.md`](CODE_PATTERNS.md) - Common patterns (20 min)

2. **Explore Code**:
   - Start with simple widgets: `lib/features/onboarding/presentation/widgets/initial/`
   - Review providers: `lib/features/*/presentation/providers/`
   - Check tests: `test/features/onboarding/`

3. **Deep Dive** (if working on feature):
   - Architecture: [`architecture/OVERVIEW.md`](architecture/OVERVIEW.md)
   - Patterns: [`CODE_PATTERNS.md`](CODE_PATTERNS.md)
   - Tests: Look at existing test patterns

### For Architecture Decisions

1. Read user personas: [`USER_PERSONAS.md`](USER_PERSONAS.md)
2. Check architecture: [`architecture/OVERVIEW.md`](architecture/OVERVIEW.md)
3. Review decisions: [`CLAUDE.md`](../CLAUDE.md#tier-system---dual-architecture)

### For Debugging

1. Check [`CLAUDE.md`](../CLAUDE.md) debug section
2. Look at git history: `git log --oneline <file>`
3. Review recent commits for context
4. Check test files for expected behavior

---

## ✅ Quality Checklists

### 🚀 Beta Launch Checklist (NEW)
**Full pre-launch checklist** for beta testing expansion → [`BETA_LAUNCH_CHECKLIST.md`](BETA_LAUNCH_CHECKLIST.md)

Comprehensive 10-section checklist covering:
- Code quality & iOS compliance
- Performance & stability
- User experience (all 5 personas)
- Data & backend (Firebase, Hive, Cloud Functions)
- Testing & QA (automated + manual + device matrix)
- Documentation
- Deployment (TestFlight + Play Store Beta)
- Monitoring & feedback
- Legal & privacy (GDPR)
- Rollback plan

### 🤖 Autonomous Beta Verification (NEW - EXPERIMENTAL)

#### ⚡ Quick Start
**3-command workflow** → [`BETA_VERIFICATION_QUICK_START.md`](BETA_VERIFICATION_QUICK_START.md)

```bash
.claude/scripts/pre-verification.sh  # Pre-flight check
claude && /verify-beta               # Launch team
.claude/scripts/post-verification.sh # Generate report
```

#### 📖 Full Documentation
**Agent team design** → [`BETA_LAUNCH_AGENT_TEAM.md`](BETA_LAUNCH_AGENT_TEAM.md)

6 specialized agents working in parallel (30-45 min):
- **Code Guardian** 🛡️: Pre-commit rules, iOS compliance, performance
- **QA Specialist** 🧪: Test suite, coverage, manual test matrix
- **Backend Auditor** ☁️: Firebase rules, Cloud Functions, data integrity
- **UX Personas Inspector** 👥: 5-persona impact analysis
- **Docs & Compliance** 📚: Documentation, GDPR, beta resources
- **Deployment Checker** 🚀: Build config, store readiness, CI/CD

#### 🧪 Test First (Dry Run)
```bash
.claude/scripts/dry-run-verification.sh  # 5-10 min infrastructure test
```

### Feature Shipping Checklist

Before shipping a feature:

- [ ] Code follows [`CLAUDE.md`](../CLAUDE.md) patterns
- [ ] Tests written and passing (`flutter test`)
- [ ] No analysis warnings (`flutter analyze`)
- [ ] Localization keys in `app_en.arb` + `app_it.arb`
- [ ] Performance checked (`.claude/scripts/performance-check.sh`)
- [ ] Accessibility verified (WCAG 2.1 AA)
- [ ] Documentation updated (this INDEX.md + feature docs)
- [ ] Git history clean (meaningful commits)

---

## 📞 Getting Help

1. **Code Review Questions?** → Check similar code in codebase
2. **Architecture Decisions?** → Review [`architecture/OVERVIEW.md`](architecture/OVERVIEW.md)
3. **Common Patterns?** → See [`CODE_PATTERNS.md`](CODE_PATTERNS.md)
4. **Bug Debugging?** → Check git log, test files, CLAUDE.md
5. **Design System?** → [`DESIGN_GUIDELINES.md`](DESIGN_GUIDELINES.md)

---

## 📝 Documentation Standards

All documentation should:
- ✅ Start with high-level summary (3-5 sentences)
- ✅ Include table of contents or quick links
- ✅ Use code examples (copy-paste ready)
- ✅ Reference related files/docs
- ✅ Include troubleshooting section

See [`ONBOARDING_COMPLETE_REFERENCE.md`](ONBOARDING_COMPLETE_REFERENCE.md) for examples.

---

## 🔄 Contributing

When adding documentation:

1. **Create in `docs/`** - Not in code
2. **Link from INDEX.md** - Add to this file
3. **Include examples** - Copy-paste ready code
4. **Reference related docs** - Cross-link
5. **Keep current** - Update when code changes

---

**Last Updated**: 2026-02-03 | **Status**: ✅ Production Ready

For questions, refer to [`CLAUDE.md`](../CLAUDE.md) or git log.
