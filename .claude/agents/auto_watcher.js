#!/usr/bin/env node

/**
 * 🤖 Auto Watcher - Sistema di manutenzione automatica
 * Monitora i file e attiva gli agenti appropriati
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

// Configurazione
const WATCH_DIRS = ['lib', 'test', 'ios/Runner', 'android/app'];
const IGNORE_PATTERNS = ['.g.dart', '.freezed.dart', 'generated'];

// Mappa file -> agenti
const AGENT_TRIGGERS = {
  'lib/**/*.dart': ['test_maintainer', 'kb_updater'],
  'test/**/*.dart': ['coverage_checker'],
  'ios/Runner/**/*.swift': ['kb_updater', 'ios_doc_updater'],
  'pubspec.yaml': ['dependency_checker', 'kb_updater'],
  'lib/features/*/presentation/screens/*.dart': ['app_descriptor', 'screenshot_generator'],
};

// Stato
let processingQueue = [];
let isProcessing = false;

console.log('🤖 Auto Watcher avviato...');
console.log('👀 Monitorando:', WATCH_DIRS.join(', '));

// Setup file watching (usando fs.watch nativo per semplicità)
WATCH_DIRS.forEach(dir => {
  if (fs.existsSync(dir)) {
    watchDirectory(dir);
  }
});

function watchDirectory(dir) {
  fs.watch(dir, { recursive: true }, async (eventType, filename) => {
    if (!filename) return;
    
    const filepath = path.join(dir, filename);
    
    // Ignora pattern da escludere
    if (IGNORE_PATTERNS.some(pattern => filepath.includes(pattern))) {
      return;
    }
    
    // Aggiungi alla coda
    if (!processingQueue.includes(filepath)) {
      processingQueue.push(filepath);
      console.log(`📝 File modificato: ${filepath}`);
      
      // Processa coda
      if (!isProcessing) {
        await processQueue();
      }
    }
  });
}

async function processQueue() {
  if (processingQueue.length === 0) {
    isProcessing = false;
    return;
  }
  
  isProcessing = true;
  const filepath = processingQueue.shift();
  
  console.log(`🔧 Processando: ${filepath}`);
  
  try {
    // Determina quali agenti attivare
    const agents = determineAgents(filepath);
    
    // Attiva agenti in sequenza
    for (const agent of agents) {
      await runAgent(agent, filepath);
    }
    
    // Analizza se è una nuova feature
    if (await isNewFeature(filepath)) {
      console.log('🎉 Nuova feature detectata!');
      await runAgent('app_descriptor', filepath);
    }
    
  } catch (error) {
    console.error(`❌ Errore processando ${filepath}:`, error);
  }
  
  // Continua con il prossimo file
  setTimeout(() => processQueue(), 1000);
}

function determineAgents(filepath) {
  const agents = new Set();
  
  // Controlla pattern specifici
  for (const [pattern, agentList] of Object.entries(AGENT_TRIGGERS)) {
    if (matchesPattern(filepath, pattern)) {
      agentList.forEach(agent => agents.add(agent));
    }
  }
  
  // Regole speciali basate sul contenuto
  if (filepath.endsWith('.dart')) {
    const content = fs.readFileSync(filepath, 'utf8');
    
    // Se contiene timer/workout logic
    if (content.includes('Timer') || content.includes('RestTimer')) {
      agents.add('timer_test_specialist');
    }
    
    // Se è una nuova screen
    if (content.includes('extends ConsumerWidget') && filepath.includes('/screens/')) {
      agents.add('screen_documenter');
    }
  }
  
  return Array.from(agents);
}

async function runAgent(agentName, filepath) {
  console.log(`  🤖 Eseguendo ${agentName}...`);
  
  const scriptPath = path.join(__dirname, 'scripts', `${agentName}.sh`);
  
  if (!fs.existsSync(scriptPath)) {
    // Usa Claude direttamente se lo script non esiste
    const command = `claude-code --agent ${agentName} --file "${filepath}"`;
    try {
      const { stdout, stderr } = await execAsync(command);
      if (stdout) console.log(`    ✅ ${stdout.trim()}`);
      if (stderr) console.error(`    ⚠️ ${stderr.trim()}`);
    } catch (error) {
      console.error(`    ❌ Errore agente ${agentName}:`, error.message);
    }
  } else {
    // Esegui script specifico
    try {
      const { stdout } = await execAsync(`bash "${scriptPath}" "${filepath}"`);
      if (stdout) console.log(`    ✅ Output: ${stdout.trim()}`);
    } catch (error) {
      console.error(`    ❌ Errore script:`, error.message);
    }
  }
}

async function isNewFeature(filepath) {
  try {
    // Controlla ultimo commit
    const { stdout } = await execAsync('git log -1 --pretty=%B');
    return stdout.toLowerCase().includes('feat:') || 
           stdout.toLowerCase().includes('feature:');
  } catch {
    return false;
  }
}

function matchesPattern(filepath, pattern) {
  // Semplice pattern matching (in produzione useresti minimatch)
  const regex = pattern
    .replace(/\*\*/g, '.*')
    .replace(/\*/g, '[^/]*')
    .replace(/\//g, '\\/');
  
  return new RegExp(regex).test(filepath);
}

// Gestione shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Auto Watcher terminato');
  process.exit(0);
});

// Notifica avvio
console.log('✅ Sistema di manutenzione automatica attivo!');
console.log('💡 Modifica qualsiasi file per vedere gli agenti in azione');
console.log('🛑 Premi Ctrl+C per fermare\n');