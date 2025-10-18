# 🛡️ Setup Admin Custom Claims

Questa guida ti mostra come configurare gli admin della tua app usando **Firebase Custom Claims** invece di email hardcodate.

## ✅ Vantaggi Custom Claims

- 🔒 **Più sicuro**: Admin gestiti server-side, non nel codice client
- 🔄 **Revocabile**: Puoi rimuovere accesso admin senza rideploy
- 🎯 **Centralizzato**: Gestione admin unica via script/dashboard
- 📊 **Scalabile**: Puoi aggiungere altri ruoli (moderator, coach, etc.)

---

## 📋 Prerequisiti

1. **Node.js** installato (v14+)
2. **Firebase project** con accesso admin
3. **Service Account Key** da Firebase Console

---

## 🚀 Setup Iniziale (Una Tantum)

### Step 1: Installa Firebase Admin SDK

```bash
cd scripts
npm init -y
npm install firebase-admin
```

### Step 2: Scarica Service Account Key

1. Vai su [Firebase Console](https://console.firebase.google.com/)
2. **Project Settings** (⚙️) → **Service Accounts**
3. Clicca **Generate new private key**
4. Salva come `scripts/serviceAccountKey.json`

⚠️ **IMPORTANTE**: Questo file è nel `.gitignore` e **NON deve** essere committato!

### Step 3: Verifica Setup

```bash
node scripts/set_admin_custom_claims.js
```

Dovresti vedere il menu di aiuto.

---

## 🎯 Uso Quotidiano

### Aggiungere un Admin

```bash
node scripts/set_admin_custom_claims.js add email@example.com
```

Output:
```
✅ Admin claim impostato per: email@example.com
   UID: abc123xyz

⚠️  IMPORTANTE: L'utente deve fare logout e re-login
   per vedere il claim aggiornato nel token.
```

### Rimuovere un Admin

```bash
node scripts/set_admin_custom_claims.js remove email@example.com
```

### Listare Tutti gli Admin

```bash
node scripts/set_admin_custom_claims.js list
```

Output:
```
✅ Trovati 2 admin:

1. Email: admin@example.com
   UID: abc123xyz
   Created: Fri, 01 Dec 2023 10:00:00 GMT

2. Email: moderator@example.com
   UID: def456uvw
   Created: Mon, 15 Jan 2024 14:30:00 GMT
```

### Verificare Status Utente

```bash
node scripts/set_admin_custom_claims.js check email@example.com
```

Output:
```
📋 Informazioni utente:

Email: email@example.com
UID: abc123xyz
Created: Fri, 01 Dec 2023 10:00:00 GMT
Last Sign In: Mon, 15 Jan 2024 09:15:00 GMT

Custom Claims:
{
  "admin": true
}

✅ Questo utente è un ADMIN
```

---

## 🔄 Workflow Post-Modifica

Quando aggiungi/rimuovi un admin:

1. **Esegui lo script** (vedi sopra)
2. **L'utente deve fare logout dall'app**
3. **L'utente fa re-login**
4. **Il nuovo claim è attivo** ✅

I custom claims sono inclusi nel JWT token, quindi **non** sono immediatamente attivi. Serve il refresh del token (logout/login).

---

## 🧪 Testing

### Test Locale

```dart
// In debug mode, puoi testare i claims così:
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdTokenResult();

if (token?.claims?['admin'] == true) {
  debugPrint('✅ User is admin');
} else {
  debugPrint('❌ User is NOT admin');
}
```

### Test Firestore Rules

1. Vai su [Firebase Console](https://console.firebase.google.com/)
2. **Firestore Database** → **Rules**
3. Tab **Rules Playground**
4. Testa:
   ```
   Tipo: get
   Collezione: /exercises/{exerciseId}

   Auth: Custom
   Provider UID: <il tuo UID>
   Token Payload: {"admin": true}
   ```

---

## 🛠️ Troubleshooting

### Errore: "serviceAccountKey.json not found"

**Soluzione**: Scarica il service account key da Firebase Console (vedi Step 2 sopra).

### Errore: "User not found"

**Soluzione**: Verifica che l'utente esista in Firebase Authentication prima di impostare il claim.

### Custom claim non funziona dopo script

**Soluzione**: L'utente **deve** fare logout e re-login dall'app per refreshare il token.

### Script funziona ma Firestore rules negano accesso

**Soluzione**:
1. Verifica che le regole usino `request.auth.token.admin == true`
2. Verifica che l'utente abbia fatto logout/login
3. Testa con Rules Playground in Firebase Console

---

## 📱 Codice App (Dart)

Aggiorna il tuo admin provider per usare custom claims:

```dart
// lib/features/auth/presentation/providers/admin_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider che verifica se l'utente corrente è admin.
///
/// Usa Firebase custom claims invece di email hardcodate.
final isAdminProvider = StreamProvider<bool>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return false;

    // Ottieni token con custom claims
    final token = await user.getIdTokenResult();

    // Verifica claim admin
    return token.claims?['admin'] == true;
  });
});

/// Helper per verificare admin in modo sincrono (usa cache token).
final isAdminCachedProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(isAdminProvider);
  return asyncValue.value ?? false;
});
```

Uso nell'app:

```dart
class AdminScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return isAdmin.when(
      data: (admin) {
        if (!admin) {
          return Text('Accesso negato');
        }
        return AdminDashboard();
      },
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Errore: $e'),
    );
  }
}
```

---

## 🔒 Best Practices

1. **✅ NON committare** `serviceAccountKey.json` (è nel .gitignore)
2. **✅ Limita accesso** al service account key solo a team lead/DevOps
3. **✅ Ruota periodicamente** il service account key (ogni 3-6 mesi)
4. **✅ Usa claims granulari**: `admin`, `moderator`, `coach` invece di un unico ruolo
5. **✅ Log tutte le modifiche** admin (chi ha aggiunto/rimosso chi e quando)
6. **✅ Testa in staging** prima di modificare admin in produzione
7. **❌ NON hardcodare** mai email nel codice app o regole Firestore

---

## 📚 Risorse

- [Firebase Custom Claims Docs](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Best Practices Security](https://firebase.google.com/docs/rules/best-practices)

---

## 🆘 Supporto

Se hai problemi:
1. Verifica che Node.js e firebase-admin siano installati
2. Verifica che serviceAccountKey.json esista e sia valido
3. Testa con `check` command per vedere custom claims attuali
4. Verifica log Firebase Console per errori

---

**🎉 Ora la tua app usa admin sicuri con custom claims invece di email hardcodate!**
