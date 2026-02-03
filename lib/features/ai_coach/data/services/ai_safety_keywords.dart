/// AI Safety Keywords
///
/// Medical keywords that trigger safety blocking.
/// If detected in user message, AI refuses to respond and redirects to medical professional.
///
/// **Layer**: Data - Constants
/// **Feature**: AI Coach
library;

/// Medical keywords that block AI responses
///
/// These terms indicate the user may be seeking medical advice,
/// which is outside the AI Coach's scope and potentially dangerous.
const List<String> medicalSafetyKeywords = [
  // Pain & Acute Symptoms
  'dolore acuto',
  'dolore forte',
  'dolore intenso',
  'dolore lancinante',
  'dolore insopportabile',

  // Injuries
  'infortunio',
  'infortunato',
  'lesione',
  'lacerazione',
  'strappo muscolare',
  'strappo',
  'rottura',
  'frattura',
  'distorsione',
  'lussazione',

  // Inflammation & Swelling
  'gonfiore',
  'gonfiato',
  'infiammazione',
  'infiammato',
  'edema',

  // Medical Conditions
  'trauma',
  'traumatico',
  'ernia',
  'tendinite',
  'borsite',
  'artrite',

  // Emergency Signs
  'svenimento',
  'vertigini',
  'nausea',
  'vomito',
  'febbre',
  'sangue',
  'sanguinamento',

  // Medication/Treatment Requests
  'farmaco',
  'medicina',
  'antidolorifico',
  'antinfiammatorio',
  'cortisone',
  'diagnosi',
  'terapia medica',

  // Body System Issues
  'cuore',
  'respirazione',
  'palpitazioni',
  'pressione alta',
  'pressione bassa',

  // Rehabilitation (without professional guidance)
  'riabilitazione post-operatoria',
  'post-operatorio',
  'post-chirurgico',
];
