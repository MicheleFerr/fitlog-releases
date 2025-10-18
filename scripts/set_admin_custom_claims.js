#!/usr/bin/env node

/**
 * Script per impostare Firebase custom claims per utenti admin.
 *
 * Questo script sostituisce l'uso di email hardcodate nelle regole Firestore
 * con custom claims sicuri gestiti da Firebase Admin SDK.
 *
 * USO:
 * 1. Installa Firebase Admin SDK:
 *    npm install firebase-admin
 *
 * 2. Scarica service account key da Firebase Console:
 *    Project Settings → Service Accounts → Generate new private key
 *    Salva come: scripts/serviceAccountKey.json
 *
 * 3. Esegui lo script:
 *    node scripts/set_admin_custom_claims.js add email@example.com
 *    node scripts/set_admin_custom_claims.js remove email@example.com
 *    node scripts/set_admin_custom_claims.js list
 *
 * NOTA: Il file serviceAccountKey.json è nel .gitignore per sicurezza.
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Path al service account key
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

// Verifica che il service account key esista
if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ Errore: serviceAccountKey.json non trovato!');
  console.error('');
  console.error('Per ottenere il file:');
  console.error('1. Vai su Firebase Console');
  console.error('2. Project Settings → Service Accounts');
  console.error('3. Generate new private key');
  console.error(`4. Salva come: ${serviceAccountPath}`);
  console.error('');
  process.exit(1);
}

// Inizializza Firebase Admin
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Funzioni helper
async function setAdminClaim(email) {
  try {
    // Cerca utente per email
    const user = await admin.auth().getUserByEmail(email);

    // Imposta custom claim admin
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });

    console.log(`✅ Admin claim impostato per: ${email}`);
    console.log(`   UID: ${user.uid}`);
    console.log('');
    console.log('⚠️  IMPORTANTE: L\'utente deve fare logout e re-login');
    console.log('   per vedere il claim aggiornato nel token.');
    console.log('');
  } catch (error) {
    console.error(`❌ Errore: ${error.message}`);
    process.exit(1);
  }
}

async function removeAdminClaim(email) {
  try {
    const user = await admin.auth().getUserByEmail(email);

    // Rimuovi custom claim admin
    await admin.auth().setCustomUserClaims(user.uid, { admin: false });

    console.log(`✅ Admin claim rimosso per: ${email}`);
    console.log(`   UID: ${user.uid}`);
    console.log('');
  } catch (error) {
    console.error(`❌ Errore: ${error.message}`);
    process.exit(1);
  }
}

async function listAdmins() {
  try {
    console.log('🔍 Cercando utenti admin...\n');

    const listUsersResult = await admin.auth().listUsers();
    const admins = listUsersResult.users.filter(
      (user) => user.customClaims && user.customClaims.admin === true
    );

    if (admins.length === 0) {
      console.log('⚠️  Nessun admin trovato.');
      console.log('');
      return;
    }

    console.log(`✅ Trovati ${admins.length} admin:\n`);

    admins.forEach((admin, index) => {
      console.log(`${index + 1}. Email: ${admin.email}`);
      console.log(`   UID: ${admin.uid}`);
      console.log(`   Created: ${admin.metadata.creationTime}`);
      console.log('');
    });
  } catch (error) {
    console.error(`❌ Errore: ${error.message}`);
    process.exit(1);
  }
}

async function checkUser(email) {
  try {
    const user = await admin.auth().getUserByEmail(email);

    console.log(`\n📋 Informazioni utente:\n`);
    console.log(`Email: ${user.email}`);
    console.log(`UID: ${user.uid}`);
    console.log(`Created: ${user.metadata.creationTime}`);
    console.log(`Last Sign In: ${user.metadata.lastSignInTime}`);
    console.log('');
    console.log('Custom Claims:');
    console.log(JSON.stringify(user.customClaims || {}, null, 2));
    console.log('');

    if (user.customClaims && user.customClaims.admin === true) {
      console.log('✅ Questo utente è un ADMIN');
    } else {
      console.log('⚠️  Questo utente NON è un admin');
    }
    console.log('');
  } catch (error) {
    console.error(`❌ Errore: ${error.message}`);
    process.exit(1);
  }
}

// Main
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('🛡️  Script Gestione Admin Custom Claims\n');
    console.log('USO:');
    console.log('  node set_admin_custom_claims.js add <email>     - Aggiungi admin');
    console.log('  node set_admin_custom_claims.js remove <email>  - Rimuovi admin');
    console.log('  node set_admin_custom_claims.js list            - Lista admin');
    console.log('  node set_admin_custom_claims.js check <email>   - Verifica utente');
    console.log('');
    console.log('ESEMPIO:');
    console.log('  node set_admin_custom_claims.js add admin@example.com');
    console.log('');
    process.exit(0);
  }

  const command = args[0].toLowerCase();
  const email = args[1];

  switch (command) {
    case 'add':
      if (!email) {
        console.error('❌ Specifica l\'email: node set_admin_custom_claims.js add <email>');
        process.exit(1);
      }
      await setAdminClaim(email);
      break;

    case 'remove':
      if (!email) {
        console.error('❌ Specifica l\'email: node set_admin_custom_claims.js remove <email>');
        process.exit(1);
      }
      await removeAdminClaim(email);
      break;

    case 'list':
      await listAdmins();
      break;

    case 'check':
      if (!email) {
        console.error('❌ Specifica l\'email: node set_admin_custom_claims.js check <email>');
        process.exit(1);
      }
      await checkUser(email);
      break;

    default:
      console.error(`❌ Comando non riconosciuto: ${command}`);
      console.error('Usa: add, remove, list, o check');
      process.exit(1);
  }

  process.exit(0);
}

// Esegui
main().catch((error) => {
  console.error('❌ Errore fatale:', error);
  process.exit(1);
});
