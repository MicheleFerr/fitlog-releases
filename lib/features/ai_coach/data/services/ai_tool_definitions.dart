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
      'parameters': {
        'type': 'object',
        'properties': {},
        'required': [],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'suggestWorkout',
      'description':
          'Get personalized workout suggestions based on user\'s training history. '
          'Use this when the user asks what workout to do or needs training advice.',
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
            'description': 'Difficulty level (e.g., "beginner", "intermediate", "advanced")',
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
          'weight': {
            'type': 'number',
            'description': '1RM weight in kg',
          },
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
      'parameters': {
        'type': 'object',
        'properties': {},
        'required': [],
      },
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
      'parameters': {
        'type': 'object',
        'properties': {},
        'required': [],
      },
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
          'Add or update a body measurement for the user. '
          'Use when user wants to log a measurement like: "Oggi peso 83kg", "Ho misurato la vita: 85cm", '
          '"Aggiorna il mio peso a 80kg". '
          'For bilateral measurements (bicep, thigh, calf, forearm), ask which side (left/right) if not specified. '
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
            'description': 'Numeric value of the measurement (e.g., 83.5 for weight in kg)',
          },
          'unit': {
            'type': 'string',
            'description': 'Unit of measurement (kg, cm, %). Default based on metricType.',
          },
          'notes': {
            'type': 'string',
            'description': 'Optional notes (e.g., "mattina a digiuno", "dopo pranzo")',
          },
        },
        'required': ['metricType', 'value'],
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
          'target muscles, exercise count, and category. '
          'Use when suggesting workouts to reference user\'s existing templates.',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {
            'type': 'string',
            'description': 'Optional filter: strength, hypertrophy, cardio, etc.',
          },
        },
        'required': [],
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
];
