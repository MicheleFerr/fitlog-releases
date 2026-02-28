/// AI Tool Definitions
///
/// Function definitions for AI Coach tool calling.
/// Compatible with OpenAI/OpenRouter function calling format.
///
/// **Layer**: Data - Constants
/// **Feature**: AI Coach
library;

/// Tool definitions in OpenAI format
const List<Map<String, dynamic>> aiToolDefinitions = [
  {
    'type': 'function',
    'function': {
      'name': 'get1RMHistory',
      'description':
          'Get the user\'s 1RM (one rep max) history for a specific exercise over time. '
          'Use this when the user asks about their strength progression on a specific lift.',
      'parameters': {
        'type': 'object',
        'properties': {
          'exerciseName': {
            'type': 'string',
            'description':
                'Name of the exercise (e.g., "Panca piana", "Squat", "Stacco")',
          },
          'weeksBack': {
            'type': 'integer',
            'description': 'Number of weeks to look back (default: 12)',
            'default': 12,
          },
        },
        'required': ['exerciseName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getWeeklyVolume',
      'description':
          'Get the user\'s training volume per week for a specific muscle group. '
          'Use this when the user asks about their training volume or frequency.',
      'parameters': {
        'type': 'object',
        'properties': {
          'muscleGroup': {
            'type': 'string',
            'description':
                'Muscle group to analyze (e.g., "chest", "back", "legs", "all")',
          },
          'weeksBack': {
            'type': 'integer',
            'description': 'Number of weeks to analyze (default: 4)',
            'default': 4,
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'analyzeMuscleBalance',
      'description':
          'Analyze the balance between different muscle groups in the user\'s training. '
          'Use this when the user asks about muscle imbalances or training distribution.',
      'parameters': {
        'type': 'object',
        'properties': {
          'muscleGroups': {
            'type': 'array',
            'items': {'type': 'string'},
            'description':
                'Muscle groups to compare (e.g., ["chest", "back", "legs"])',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getRecoveryData',
      // BUG FIX #3: Updated description to reflect actual implementation
      'description':
          'Get recovery status based on recent workout frequency and rest days. '
          'Use this when the user asks about recovery or fatigue.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'suggestWorkout',
      'description':
          'Get HIGH-LEVEL workout direction based on user\'s training history (focus + intensity + recovery). '
          'Use for quick directional advice. For a COMPLETE session plan with exercises/sets/reps, use generateTemplate.',
      'parameters': {
        'type': 'object',
        'properties': {
          'muscleGroup': {
            'type': 'string',
            'description':
                'Target muscle group (e.g., "chest", "legs", "full body")',
          },
          'difficulty': {
            'type': 'string',
            'description':
                'Difficulty level (e.g., "beginner", "intermediate", "advanced")',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'compareToStandards',
      'description':
          'Compare user\'s lifts to strength standards (beginner/intermediate/advanced/elite). '
          'Use this when the user asks how they compare to others or their strength level.',
      'parameters': {
        'type': 'object',
        'properties': {
          'lift': {
            'type': 'string',
            'description': 'Name of the lift (e.g., "Squat", "Panca piana")',
          },
          'weight': {'type': 'number', 'description': '1RM weight in kg'},
          'bodyWeight': {
            'type': 'number',
            'description': 'User body weight in kg (default: 75)',
            'default': 75,
          },
        },
        'required': ['lift', 'weight'],
      },
    },
  },
  // ========== New Tools ==========
  {
    'type': 'function',
    'function': {
      'name': 'getWorkoutStats',
      'description':
          'Get overall workout statistics including total workouts, average duration, '
          'volume, training consistency, and most frequent exercises. '
          'Use when user asks about their general training stats or progress overview.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getPersonalRecords',
      'description':
          'Get personal records (PRs) for a specific exercise or all exercises. '
          'Returns weight PRs, volume PRs, rep PRs, and estimated 1RM records. '
          'Use when user asks about records, best lifts, or achievements.',
      'parameters': {
        'type': 'object',
        'properties': {
          'exerciseName': {
            'type': 'string',
            'description':
                'Exercise name to get PRs for. If omitted, returns all PRs.',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getStreak',
      'description':
          'Get the user\'s current workout streak (consecutive training days), '
          'best streak record, and total workout count. '
          'Use when user asks about consistency or training habit.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getWorkoutHistory',
      'description':
          'Get recent workout history with details. Shows what exercises were done, '
          'when, and for how long. '
          'Use when user asks about past workouts or what they trained recently.',
      'parameters': {
        'type': 'object',
        'properties': {
          'daysBack': {
            'type': 'integer',
            'description': 'Number of days to look back (default: 7)',
            'default': 7,
          },
          'limit': {
            'type': 'integer',
            'description': 'Maximum workouts to return (default: 5)',
            'default': 5,
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getUserProfileContext',
      'description':
          'Get profile personalization context used by the coach: experience level, primary goal, weekly target, '
          'latest body weight and missing fields. Use this before generating plans when personalization is incomplete.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'updateUserProfilePreferences',
      'description':
          'Update user personalization settings used by AI Coach. Use when the user provides or confirms '
          'experience level, goal, or weekly training target.',
      'parameters': {
        'type': 'object',
        'properties': {
          'experienceLevel': {
            'type': 'string',
            'description':
                'Experience level: beginner, some/intermediate, experienced/advanced, athlete.',
          },
          'goal': {
            'type': 'string',
            'description':
                'Primary goal: muscle, strength, fat_loss, recomposition, endurance.',
          },
          'weeklyTarget': {
            'type': 'integer',
            'description': 'Target weekly workouts (2-7).',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getWeeklyCheckin',
      'description':
          'Generate a weekly coaching review with adherence score, volume trend, PR highlights, and automatic '
          'adjustments for the upcoming week.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getWorkoutPreferences',
      'description':
          'Get workout preference presets used by AI Coach and Settings (default sets, reps, rest timers). '
          'Use for guided setup or when user asks to review current preferences.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'updateWorkoutPreferences',
      'description':
          'Update workout preference presets (defaultExerciseSets, defaultExerciseReps, defaultRestTime, defaultRestBetweenExercises). '
          'Use when user confirms preferred setup like 5x5, 4x8, etc.',
      'parameters': {
        'type': 'object',
        'properties': {
          'defaultExerciseSets': {
            'type': 'integer',
            'description': 'Default sets per exercise (1-8).',
          },
          'defaultExerciseReps': {
            'type': 'integer',
            'description': 'Default reps per exercise (3-30).',
          },
          'defaultRestTime': {
            'type': 'integer',
            'description': 'Default rest between sets in seconds (30-300).',
          },
          'defaultRestBetweenExercises': {
            'type': 'integer',
            'description':
                'Default rest between exercises in seconds (30-300).',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getAutoProgressionPlan',
      'description':
          'Autoregulated progression engine for a specific exercise. Uses recent performance trend to decide '
          'whether to increase load, add reps, hold, or deload.',
      'parameters': {
        'type': 'object',
        'properties': {
          'exerciseName': {
            'type': 'string',
            'description': 'Exercise to analyze (required).',
          },
          'targetRepsMin': {
            'type': 'integer',
            'description': 'Lower bound of target rep range (default: 6).',
            'default': 6,
          },
          'targetRepsMax': {
            'type': 'integer',
            'description': 'Upper bound of target rep range (default: 10).',
            'default': 10,
          },
        },
        'required': ['exerciseName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getAdherenceInsights',
      'description':
          'Analyze workout adherence and consistency over recent weeks. Returns dropout risk, likely barriers, '
          'and practical actions to improve motivation and consistency.',
      'parameters': {'type': 'object', 'properties': {}, 'required': []},
    },
  },
  // ========== Body Measurements ==========
  {
    'type': 'function',
    'function': {
      'name': 'getBodyProgress',
      'description':
          'Get the user\'s body measurement history (weight, body fat, lean mass, circumferences). '
          'Use when user asks about body composition, weight progress, or physical changes. '
          'Example: "Come sta andando il mio peso?", "Sono dimagrito?", "Progressi fisici?"',
      'parameters': {
        'type': 'object',
        'properties': {
          'metricType': {
            'type': 'string',
            'description':
                'Type of measurement: weight, bodyFatPercentage, leanMass, waistCircumference, '
                'chestCircumference, bicepCircumference, etc. If omitted, returns all essential metrics.',
          },
          'weeksBack': {
            'type': 'integer',
            'description': 'Number of weeks to look back (default: 12)',
            'default': 12,
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'addBodyMeasurement',
      'description':
          'Add or update a body measurement for the user with explicit two-step confirmation. '
          'Use when user wants to log a measurement like: "Oggi peso 83kg", "Ho misurato la vita: 85cm", '
          '"Aggiorna il mio peso a 80kg". '
          'For bilateral measurements (bicep, thigh, calf, forearm), ask which side (left/right) if not specified. '
          'Step 1 (prepare): call with metricType/value to prepare pending save and ask user confirmation. '
          'Step 2 (commit): call with confirmed=true (without metricType/value) to save pending measurement. '
          'ALWAYS confirm with user before saving. Show what was saved after.',
      'parameters': {
        'type': 'object',
        'properties': {
          'metricType': {
            'type': 'string',
            'description':
                'Type of measurement: weight, bodyFatPercentage, leanMass, waistCircumference, '
                'chestCircumference, bicepLeftCircumference, bicepRightCircumference, etc.',
          },
          'value': {
            'type': 'number',
            'description':
                'Numeric value of the measurement (e.g., 83.5 for weight in kg)',
          },
          'unit': {
            'type': 'string',
            'description':
                'Unit of measurement (kg, cm, %). Default based on metricType.',
          },
          'notes': {
            'type': 'string',
            'description':
                'Optional notes (e.g., "mattina a digiuno", "dopo pranzo")',
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Set true ONLY after the user explicitly confirms saving. '
                'When true and metricType/value are omitted, the tool saves the pending measurement prepared earlier.',
          },
        },
        'required': [],
      },
    },
  },
  // ========== Template Generation ==========
  {
    'type': 'function',
    'function': {
      'name': 'generateTemplate',
      'description':
          'Generate a structured workout plan with specific exercises, sets, reps, and rest times. '
          'Use when the user asks to create a workout, wants a training plan, or asks "cosa alleno oggi?" '
          'and wants specific exercises.',
      'parameters': {
        'type': 'object',
        'properties': {
          'muscleGroup': {
            'type': 'string',
            'description':
                'Target muscle group (chest, back, legs, shoulders, arms, full_body, push, pull, upper, lower)',
          },
          'difficulty': {
            'type': 'string',
            'description':
                'Difficulty level: beginner (3 exercises, higher reps), intermediate (4-5 exercises), advanced (5-6 exercises, more volume)',
          },
          'durationMinutes': {
            'type': 'integer',
            'description': 'Target workout duration in minutes (default: 45)',
            'default': 45,
          },
          'equipment': {
            'type': 'string',
            'description':
                'Available equipment: all, barbell, dumbbell, cables, bodyweight, home',
          },
        },
        'required': ['muscleGroup'],
      },
    },
  },
  // ========== User Templates ==========
  {
    'type': 'function',
    'function': {
      'name': 'getUserTemplates',
      'description':
          'Get the user\'s saved workout templates. Returns template names, '
          'target muscles, exercise count, category, and exercise preview. '
          'Also returns per-template set distribution and aggregate muscle-balance summary across all templates. '
          'Use when suggesting workouts to reference user\'s existing templates. '
          'If user asks a deep analysis, follow with getTemplateDetails for each relevant template.',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {
            'type': 'string',
            'description':
                'Optional filter: strength, hypertrophy, cardio, etc.',
          },
        },
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'getTemplateDetails',
      'description':
          'Get full details of a specific workout template including all exercises, '
          'sets, reps, rest times, and target muscles. '
          'MANDATORY: Use this when user asks about a specific template (e.g., "Is template X good for Y?", '
          '"What exercises are in template Z?", "Analyze my Push Day template"). '
          'Returns complete exercise list with workout structure.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to retrieve (case-insensitive, partial match supported)',
          },
        },
        'required': ['templateName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'addExerciseToTemplate',
      'description':
          'Add an exercise to one of the user\'s saved workout templates. '
          'Two-step safety flow: first call with confirmed=false (or omitted) to preview the exact change, '
          'then call again with confirmed=true only after the user explicitly confirms. '
          'Use this when user asks to insert/add an exercise in a template.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to modify (case-insensitive, partial match supported)',
          },
          'exerciseName': {
            'type': 'string',
            'description':
                'Exercise to add (can be a query; tool resolves best database match)',
          },
          'sets': {
            'type': 'integer',
            'description': 'Number of sets to assign (default: 3, range: 1-8)',
            'default': 3,
          },
          'reps': {
            'type': 'integer',
            'description': 'Target reps per set (default: 10, range: 3-30)',
            'default': 10,
          },
          'restSeconds': {
            'type': 'integer',
            'description':
                'Rest time for this exercise in seconds (default: 90, range: 20-300)',
            'default': 90,
          },
          'notes': {
            'type': 'string',
            'description': 'Optional exercise notes for the template',
          },
          'allowDuplicate': {
            'type': 'boolean',
            'description':
                'Set true to allow adding an exercise already present in the template',
            'default': false,
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Must be true only after explicit user confirmation to commit the edit',
            'default': false,
          },
        },
        'required': ['templateName', 'exerciseName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'replaceExerciseInTemplate',
      'description':
          'Replace an exercise inside one saved template. Two-step safety flow: '
          'first call with confirmed=false (or omitted) to preview, then call with confirmed=true '
          'only after explicit user confirmation.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to modify (case-insensitive, partial match supported)',
          },
          'oldExerciseName': {
            'type': 'string',
            'description': 'Exercise currently in template to replace',
          },
          'newExerciseName': {
            'type': 'string',
            'description': 'New exercise to insert in place of old exercise',
          },
          'sets': {
            'type': 'integer',
            'description': 'Number of sets for new exercise (default: 3)',
            'default': 3,
          },
          'reps': {
            'type': 'integer',
            'description': 'Target reps for new exercise (default: 10)',
            'default': 10,
          },
          'restSeconds': {
            'type': 'integer',
            'description': 'Rest time in seconds (default: 90)',
            'default': 90,
          },
          'notes': {
            'type': 'string',
            'description': 'Optional notes for the new exercise',
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Must be true only after explicit user confirmation to commit the replace',
            'default': false,
          },
        },
        'required': ['templateName', 'oldExerciseName', 'newExerciseName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'removeExerciseFromTemplate',
      'description':
          'Remove an exercise from one saved template. Two-step safety flow: '
          'first call with confirmed=false (or omitted) to preview removal, then confirmed=true after user confirmation.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to modify (case-insensitive, partial match supported)',
          },
          'exerciseName': {
            'type': 'string',
            'description': 'Exercise to remove from the template',
          },
          'removeAllMatches': {
            'type': 'boolean',
            'description':
                'If true removes all matching exercises, otherwise only first match',
            'default': false,
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Must be true only after explicit user confirmation to commit the removal',
            'default': false,
          },
        },
        'required': ['templateName', 'exerciseName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'updateTemplateRestTime',
      'description':
          'Update rest time in one saved template. Can target one exercise or all exercises. '
          'Two-step safety flow: first call with confirmed=false (or omitted) to preview, then call with confirmed=true '
          'only after explicit user confirmation.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to modify (case-insensitive, partial match supported)',
          },
          'exerciseName': {
            'type': 'string',
            'description':
                'Exercise to update. Optional only when applyToAllExercises=true',
          },
          'restSeconds': {
            'type': 'integer',
            'description':
                'Target rest time in seconds (range: 20-300). Use this OR deltaSeconds',
          },
          'deltaSeconds': {
            'type': 'integer',
            'description':
                'Increment/decrement to apply (e.g. +15, -15). Use this OR restSeconds',
          },
          'applyToAllExercises': {
            'type': 'boolean',
            'description':
                'If true, applies rest time to every exercise in the template',
            'default': false,
          },
          'updateAllMatches': {
            'type': 'boolean',
            'description':
                'If true updates all matching exercises with the same name',
            'default': false,
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Must be true only after explicit user confirmation to commit the edit',
            'default': false,
          },
        },
        'required': ['templateName'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'updateTemplateExerciseSetup',
      'description':
          'Update sets and reps in one saved template. Can target one exercise or all exercises. '
          'Two-step safety flow: first call with confirmed=false (or omitted) to preview, then call with confirmed=true '
          'only after explicit user confirmation.',
      'parameters': {
        'type': 'object',
        'properties': {
          'templateName': {
            'type': 'string',
            'description':
                'Name of the template to modify (case-insensitive, partial match supported)',
          },
          'exerciseName': {
            'type': 'string',
            'description':
                'Exercise to update. Optional only when applyToAllExercises=true',
          },
          'sets': {
            'type': 'integer',
            'description': 'Target number of sets (range: 1-8)',
          },
          'reps': {
            'type': 'integer',
            'description':
                'Target reps per set (range: 3-30). Use this OR minReps/maxReps',
          },
          'minReps': {
            'type': 'integer',
            'description':
                'Minimum reps for a rep range (e.g. 8 in 8-12). Use with maxReps',
          },
          'maxReps': {
            'type': 'integer',
            'description':
                'Maximum reps for a rep range (e.g. 12 in 8-12). Use with minReps',
          },
          'deltaSets': {
            'type': 'integer',
            'description':
                'Increment/decrement sets (e.g. +1, -1). Use this OR sets',
          },
          'deltaReps': {
            'type': 'integer',
            'description':
                'Increment/decrement reps (e.g. +2, -2). Use this OR reps',
          },
          'applyToAllExercises': {
            'type': 'boolean',
            'description':
                'If true, applies setup to every exercise in the template',
            'default': false,
          },
          'updateAllMatches': {
            'type': 'boolean',
            'description':
                'If true updates all matching exercises with the same name',
            'default': false,
          },
          'confirmed': {
            'type': 'boolean',
            'description':
                'Must be true only after explicit user confirmation to commit the edit',
            'default': false,
          },
        },
        'required': ['templateName'],
      },
    },
  },
  // ========== Exercise Search ==========
  {
    'type': 'function',
    'function': {
      'name': 'searchExercises',
      'description':
          'Search exercises from database (2327+ exercises). '
          'Supports fuzzy matching. Use for exercise alternatives or specifics.',
      'parameters': {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'Exercise name or keyword (e.g., "panca", "squat")',
          },
          'muscleGroup': {
            'type': 'string',
            'description': 'Optional: chest, back, legs, shoulders, arms, core',
          },
          'limit': {
            'type': 'integer',
            'description': 'Max results (default: 10, max: 20)',
            'default': 10,
          },
        },
        'required': ['query'],
      },
    },
  },
  // ========== Accessory Exercises ==========
  {
    'type': 'function',
    'function': {
      'name': 'getAccessoryExercises',
      'description':
          'Get accessory/support exercises that target the SAME muscle groups as a main lift. '
          'MANDATORY: Use this tool before suggesting accessory exercises to ensure anatomical correctness. '
          'Example: For "Panca piana" (chest), returns chest exercises like dips, cable crossover, incline press. '
          'NEVER suggest leg exercises for upper body lifts or vice versa.',
      'parameters': {
        'type': 'object',
        'properties': {
          'exerciseName': {
            'type': 'string',
            'description':
                'Name of the main exercise (e.g., "Panca piana", "Squat", "Stacco")',
          },
          'limit': {
            'type': 'integer',
            'description': 'Max accessory exercises to return (default: 8)',
            'default': 8,
          },
        },
        'required': ['exerciseName'],
      },
    },
  },
  // ========== Scientific Sources ==========
  {
    'type': 'function',
    'function': {
      'name': 'searchScientificSources',
      'description':
          'Search locally cached scientific papers and return short, citable references. '
          'Use only when the user asks for evidence, studies, sources, or scientific citations.',
      'parameters': {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description':
                'Keywords to search in title/summary/keywords (e.g., "ipertrofia volume", "forza panca")',
          },
          'category': {
            'type': 'string',
            'description':
                'Optional category filter (e.g., hypertrophy, strength, recovery)',
          },
          'limit': {
            'type': 'integer',
            'description': 'Max sources to return (default: 3, max: 5)',
            'default': 3,
          },
        },
        'required': [],
      },
    },
  },
];
