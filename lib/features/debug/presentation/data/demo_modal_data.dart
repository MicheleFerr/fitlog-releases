/// Demo data for Modal Showcase screen
/// These are fake data used only for design preview purposes
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart'
    show WarmupSet;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as exercise_db;
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

/// Demo data generator for modal showcase
class DemoModalData {
  DemoModalData._();

  /// Generate demo exercise histories for analytics modals
  static List<ExerciseHistory> get exerciseHistories {
    final now = DateTime.now();

    return [
      // Bench Press - Chest
      ExerciseHistory(
        exerciseId: 'bench_press_demo',
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          _createSession(
            'Bench Press',
            'chest',
            now.subtract(const Duration(days: 0)),
            [
              (weight: 80.0, reps: 10),
              (weight: 85.0, reps: 8),
              (weight: 90.0, reps: 6),
            ],
          ),
          _createSession(
            'Bench Press',
            'chest',
            now.subtract(const Duration(days: 3)),
            [
              (weight: 77.5, reps: 10),
              (weight: 82.5, reps: 8),
              (weight: 87.5, reps: 6),
            ],
          ),
          _createSession(
            'Bench Press',
            'chest',
            now.subtract(const Duration(days: 7)),
            [
              (weight: 75.0, reps: 10),
              (weight: 80.0, reps: 8),
              (weight: 85.0, reps: 6),
            ],
          ),
          _createSession(
            'Bench Press',
            'chest',
            now.subtract(const Duration(days: 10)),
            [
              (weight: 72.5, reps: 10),
              (weight: 77.5, reps: 8),
              (weight: 82.5, reps: 6),
            ],
          ),
          _createSession(
            'Bench Press',
            'chest',
            now.subtract(const Duration(days: 14)),
            [
              (weight: 70.0, reps: 10),
              (weight: 75.0, reps: 8),
              (weight: 80.0, reps: 6),
            ],
          ),
        ],
      ),

      // Squat - Legs
      ExerciseHistory(
        exerciseId: 'squat_demo',
        exerciseName: 'Squat',
        muscleGroup: 'legs',
        sessions: [
          _createSession(
            'Squat',
            'legs',
            now.subtract(const Duration(days: 1)),
            [
              (weight: 100.0, reps: 8),
              (weight: 110.0, reps: 6),
              (weight: 120.0, reps: 4),
            ],
          ),
          _createSession(
            'Squat',
            'legs',
            now.subtract(const Duration(days: 4)),
            [
              (weight: 95.0, reps: 8),
              (weight: 105.0, reps: 6),
              (weight: 115.0, reps: 4),
            ],
          ),
          _createSession(
            'Squat',
            'legs',
            now.subtract(const Duration(days: 8)),
            [
              (weight: 90.0, reps: 8),
              (weight: 100.0, reps: 6),
              (weight: 110.0, reps: 4),
            ],
          ),
          _createSession(
            'Squat',
            'legs',
            now.subtract(const Duration(days: 15)),
            [
              (weight: 85.0, reps: 8),
              (weight: 95.0, reps: 6),
              (weight: 105.0, reps: 4),
            ],
          ),
        ],
      ),

      // Deadlift - Back
      ExerciseHistory(
        exerciseId: 'deadlift_demo',
        exerciseName: 'Deadlift',
        muscleGroup: 'back',
        sessions: [
          _createSession(
            'Deadlift',
            'back',
            now.subtract(const Duration(days: 2)),
            [
              (weight: 120.0, reps: 5),
              (weight: 130.0, reps: 4),
              (weight: 140.0, reps: 3),
            ],
          ),
          _createSession(
            'Deadlift',
            'back',
            now.subtract(const Duration(days: 5)),
            [
              (weight: 115.0, reps: 5),
              (weight: 125.0, reps: 4),
              (weight: 135.0, reps: 3),
            ],
          ),
          _createSession(
            'Deadlift',
            'back',
            now.subtract(const Duration(days: 9)),
            [
              (weight: 110.0, reps: 5),
              (weight: 120.0, reps: 4),
              (weight: 130.0, reps: 3),
            ],
          ),
        ],
      ),

      // Pull-ups - Back
      ExerciseHistory(
        exerciseId: 'pullups_demo',
        exerciseName: 'Pull-ups',
        muscleGroup: 'back',
        sessions: [
          _createSession(
            'Pull-ups',
            'back',
            now.subtract(const Duration(days: 2)),
            [
              (weight: 0.0, reps: 12),
              (weight: 5.0, reps: 10),
              (weight: 10.0, reps: 8),
            ],
          ),
          _createSession(
            'Pull-ups',
            'back',
            now.subtract(const Duration(days: 6)),
            [
              (weight: 0.0, reps: 10),
              (weight: 5.0, reps: 8),
              (weight: 10.0, reps: 6),
            ],
          ),
        ],
      ),

      // Shoulder Press - Shoulders
      ExerciseHistory(
        exerciseId: 'shoulder_press_demo',
        exerciseName: 'Shoulder Press',
        muscleGroup: 'shoulders',
        sessions: [
          _createSession(
            'Shoulder Press',
            'shoulders',
            now.subtract(const Duration(days: 1)),
            [
              (weight: 40.0, reps: 10),
              (weight: 45.0, reps: 8),
              (weight: 50.0, reps: 6),
            ],
          ),
          _createSession(
            'Shoulder Press',
            'shoulders',
            now.subtract(const Duration(days: 5)),
            [
              (weight: 37.5, reps: 10),
              (weight: 42.5, reps: 8),
              (weight: 47.5, reps: 6),
            ],
          ),
        ],
      ),

      // Bicep Curls - Arms
      ExerciseHistory(
        exerciseId: 'bicep_curls_demo',
        exerciseName: 'Bicep Curls',
        muscleGroup: 'arms',
        sessions: [
          _createSession(
            'Bicep Curls',
            'arms',
            now.subtract(const Duration(days: 3)),
            [
              (weight: 15.0, reps: 12),
              (weight: 17.5, reps: 10),
              (weight: 20.0, reps: 8),
            ],
          ),
          _createSession(
            'Bicep Curls',
            'arms',
            now.subtract(const Duration(days: 7)),
            [
              (weight: 12.5, reps: 12),
              (weight: 15.0, reps: 10),
              (weight: 17.5, reps: 8),
            ],
          ),
        ],
      ),
    ];
  }

  /// Number of workouts this week (demo)
  static int get weeklyWorkouts => 4;

  /// Volume progression percentage (demo)
  static double get volumeProgression => 12.5;

  /// Demo exercises performed list
  static List<String> get exercisesPerformed => [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Pull-ups',
    'Shoulder Press',
  ];

  /// Demo total volume
  static double get totalVolume => 15420.0;

  /// Helper to create a session
  static ExerciseSession _createSession(
    String exerciseName,
    String muscleGroup,
    DateTime date,
    List<({double weight, int reps})> sets,
  ) {
    return ExerciseSession(
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      date: date,
      sets: sets
          .map((s) => AnalyticsSet(weight: s.weight, reps: s.reps, date: date))
          .toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WORKOUT & TEMPLATE DATA (for Template Save Dialog)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo completed workout (modified from template)
  static Workout get completedWorkout {
    final now = DateTime.now();
    return Workout(
      id: 'demo-workout-001',
      name: 'Push Day (Modified)',
      exercises: [
        Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: true),
            ExerciseSet(setNumber: 2, weight: 85, reps: 8, isCompleted: true),
            ExerciseSet(setNumber: 3, weight: 90, reps: 6, isCompleted: true),
            ExerciseSet(
              setNumber: 4,
              weight: 92.5,
              reps: 5,
              isCompleted: true,
            ), // Extra set added
          ],
        ),
        Exercise(
          name: 'Incline Dumbbell Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 30, reps: 12, isCompleted: true),
            ExerciseSet(
              setNumber: 2,
              weight: 32.5,
              reps: 10,
              isCompleted: true,
            ),
            ExerciseSet(setNumber: 3, weight: 35, reps: 8, isCompleted: true),
          ],
        ),
        Exercise(
          name: 'Overhead Press',
          type: ExerciseType.single,
          category: ExerciseCategory.shoulders,
          sets: [
            ExerciseSet(setNumber: 1, weight: 40, reps: 10, isCompleted: true),
            ExerciseSet(setNumber: 2, weight: 45, reps: 8, isCompleted: true),
            ExerciseSet(setNumber: 3, weight: 50, reps: 6, isCompleted: true),
          ],
        ),
        // New exercise not in original template
        Exercise(
          name: 'Lateral Raises',
          type: ExerciseType.single,
          category: ExerciseCategory.shoulders,
          sets: [
            ExerciseSet(setNumber: 1, weight: 10, reps: 15, isCompleted: true),
            ExerciseSet(setNumber: 2, weight: 10, reps: 12, isCompleted: true),
          ],
        ),
      ],
      status: WorkoutStatus.completed,
      startTime: now.subtract(const Duration(hours: 1, minutes: 15)),
      endTime: now,
      createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      updatedAt: now,
      templateId: 'demo-template-001',
    );
  }

  /// Demo original workout template
  static WorkoutTemplate get originalTemplate {
    final now = DateTime.now();
    return WorkoutTemplate(
      id: 'demo-template-001',
      name: 'Push Day',
      description: 'Classic push workout: chest, shoulders, triceps',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'bench_press',
          exerciseName: 'Bench Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 80, targetReps: 10),
            SetTemplate(setNumber: 2, targetWeight: 85, targetReps: 8),
            SetTemplate(setNumber: 3, targetWeight: 90, targetReps: 6),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'incline_db_press',
          exerciseName: 'Incline Dumbbell Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 30, targetReps: 12),
            SetTemplate(setNumber: 2, targetWeight: 32.5, targetReps: 10),
            SetTemplate(setNumber: 3, targetWeight: 35, targetReps: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'overhead_press',
          exerciseName: 'Overhead Press',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 40, targetReps: 10),
            SetTemplate(setNumber: 2, targetWeight: 42.5, targetReps: 8),
            SetTemplate(setNumber: 3, targetWeight: 45, targetReps: 6),
          ],
        ),
      ],
      estimatedDuration: 60,
      tags: ['push', 'chest', 'shoulders', 'intermediate'],
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 7)),
      isCustom: true,
      usageCount: 12,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PR MODAL DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Recent PR count for PR Modal (demo)
  static int get recentPRCount => 5;

  // ═══════════════════════════════════════════════════════════════════════════
  // EXERCISE DETAILS MODAL DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo exercise definition for Exercise Details Modal
  static exercise_db.ExerciseDefinition get exerciseDefinition {
    return exercise_db.ExerciseDefinition(
      id: 'bench_press_001',
      nome: 'Panca Piana con Bilanciere',
      focus: const ['PETTO', 'TRICIPITI'],
      muscoliSecondari: const ['DELTOIDI ANTERIORI', 'CORE'],
      difficolta: 'Intermedio',
      tipoEsercizio: 'Compound',
      attrezzatura: 'Bilanciere',
      patternMovimento: 'Push Orizzontale',
      rangeRipetizioni: '6-12',
      noteTecniche:
          'Mantieni le scapole retratte e depresse | '
          'Arco lombare naturale, piedi saldi a terra | '
          'Abbassa il bilanciere controllato al petto | '
          'Spingi in verticale mantenendo i gomiti a 45° | '
          'Espira durante la spinta, inspira in discesa',
      mobilitaPre:
          'Rotazioni delle spalle (10 per lato) | '
          'Stretching pettorale al muro (30 sec per lato) | '
          'Dislocazioni con elastico (10 ripetizioni)',
      attivazionePre:
          'Face pull con elastico (15 reps) | '
          'Push-up leggeri (10 reps) | '
          'Band pull-aparts (15 reps)',
      aliases: const ['panca', 'bench press', 'BP', 'flat bench'],
    );
  }

  /// Demo exercise definition for Pull exercise
  static exercise_db.ExerciseDefinition get pullExerciseDefinition {
    return exercise_db.ExerciseDefinition(
      id: 'deadlift_001',
      nome: 'Stacco da Terra',
      focus: const ['DORSALI', 'GLUTEI', 'FEMORALI'],
      muscoliSecondari: const ['CORE', 'TRAPEZI', 'AVAMBRACCI'],
      difficolta: 'Avanzato',
      tipoEsercizio: 'Compound',
      attrezzatura: 'Bilanciere',
      patternMovimento: 'Hip Hinge',
      rangeRipetizioni: '1-8',
      noteTecniche:
          'Bilanciere a contatto con le tibie | '
          'Schiena neutra, core attivato | '
          'Spingi il pavimento con i piedi | '
          'Estendi anche e ginocchia simultaneamente | '
          'Mantieni il bilanciere vicino al corpo',
      mobilitaPre:
          'Hip circles (10 per direzione) | '
          'Cat-cow stretch (10 ripetizioni) | '
          'Stretching femorali dinamico',
      attivazionePre:
          'Glute bridges (15 reps) | '
          'Good mornings con elastico (12 reps) | '
          'Dead bugs (10 per lato)',
      aliases: const ['stacco', 'deadlift', 'DL', 'conventional deadlift'],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEIGHT & REPS PICKER DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo initial weight for Weight Picker Modal
  static double get demoWeight => 80.0;

  /// Demo initial reps for Reps Picker Modal
  static int get demoReps => 10;

  // ═══════════════════════════════════════════════════════════════════════════
  // RPE SELECTOR DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo ExerciseSet for RPE Selector
  static ExerciseSet get demoExerciseSet {
    return ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: false);
  }

  /// Demo Exercise for RPE Selector
  static Exercise get demoExercise {
    return Exercise(
      name: 'Bench Press',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [
        ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: false),
        ExerciseSet(setNumber: 2, weight: 85, reps: 8, isCompleted: false),
        ExerciseSet(setNumber: 3, weight: 90, reps: 6, isCompleted: false),
      ],
    );
  }

  /// Demo target reps for RPE Selector
  static int get demoTargetReps => 10;

  // ═══════════════════════════════════════════════════════════════════════════
  // REST TIME PICKER DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo initial rest time in seconds (90 seconds = 1:30)
  static int get demoRestTime => 90;

  // ═══════════════════════════════════════════════════════════════════════════
  // WARMUP CUSTOMIZATION DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo warmup sets for Warmup Customization Modal
  static List<WarmupSet> get demoWarmupSets {
    return const [
      WarmupSet(weight: 20.0, reps: 15, percentage: 0),
      WarmupSet(weight: 40.0, reps: 10, percentage: 50),
      WarmupSet(weight: 60.0, reps: 6, percentage: 75),
      WarmupSet(weight: 72.0, reps: 3, percentage: 90),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPERSET EXECUTION DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo superset exercise for Superset Execution Sheet
  static SupersetExercise get demoSuperset {
    return SupersetExercise(
      name: 'Chest & Back Superset',
      exercises: [
        Exercise(
          id: 'bench_press',
          name: 'Bench Press',
          type: ExerciseType.superset,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: false),
            ExerciseSet(
              setNumber: 2,
              weight: 82.5,
              reps: 8,
              isCompleted: false,
            ),
            ExerciseSet(setNumber: 3, weight: 85, reps: 6, isCompleted: false),
          ],
        ),
        Exercise(
          id: 'bent_over_row',
          name: 'Bent Over Row',
          type: ExerciseType.superset,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(setNumber: 1, weight: 70, reps: 10, isCompleted: false),
            ExerciseSet(setNumber: 2, weight: 75, reps: 8, isCompleted: false),
            ExerciseSet(setNumber: 3, weight: 80, reps: 6, isCompleted: false),
          ],
        ),
      ],
      supersetSets: [
        SupersetSet(
          setNumber: 1,
          exerciseData: {
            'bench_press': const SupersetExerciseData(
              exerciseId: 'bench_press',
              exerciseName: 'Bench Press',
              targetWeight: 80,
              targetReps: 10,
            ),
            'bent_over_row': const SupersetExerciseData(
              exerciseId: 'bent_over_row',
              exerciseName: 'Bent Over Row',
              targetWeight: 70,
              targetReps: 10,
            ),
          },
        ),
        SupersetSet(
          setNumber: 2,
          exerciseData: {
            'bench_press': const SupersetExerciseData(
              exerciseId: 'bench_press',
              exerciseName: 'Bench Press',
              targetWeight: 82.5,
              targetReps: 8,
            ),
            'bent_over_row': const SupersetExerciseData(
              exerciseId: 'bent_over_row',
              exerciseName: 'Bent Over Row',
              targetWeight: 75,
              targetReps: 8,
            ),
          },
        ),
        SupersetSet(
          setNumber: 3,
          exerciseData: {
            'bench_press': const SupersetExerciseData(
              exerciseId: 'bench_press',
              exerciseName: 'Bench Press',
              targetWeight: 85,
              targetReps: 6,
            ),
            'bent_over_row': const SupersetExerciseData(
              exerciseId: 'bent_over_row',
              exerciseName: 'Bent Over Row',
              targetWeight: 80,
              targetReps: 6,
            ),
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MUSCLE CORRECTION DATA (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo muscle correction for Feedback Submission Dialog
  static MuscleCorrection get demoMuscleCorrection {
    return MuscleCorrection(
      exerciseName: 'Bench Press',
      oldMuscleGroup: 'Back', // Incorrect muscle group (demo)
      newMuscleGroup: 'Chest', // Corrected muscle group
      timestamp: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXERCISE ACTIVITIES DATA (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo exercise activities for Exercise History Search Modal
  static List<ExerciseActivity> get exerciseActivities {
    final now = DateTime.now();
    return [
      ExerciseActivity(
        id: 'activity-bench-1',
        email: 'demo@gymbro.app',
        exerciseId: 'ex-bench-press',
        exerciseName: 'Bench Press',
        schedaName: 'Push Day A',
        sets: [
          ExerciseActivitySet(
            set: 1,
            weight: '100.0',
            reps: '5',
            done: true,
            effort: 5,
            rpe: 9,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        lastModified: now.subtract(const Duration(days: 2)),
        category: ExerciseCategory.chest,
      ),
      ExerciseActivity(
        id: 'activity-squat-1',
        email: 'demo@gymbro.app',
        exerciseId: 'ex-squat',
        exerciseName: 'Squat',
        schedaName: 'Leg Day',
        sets: [
          ExerciseActivitySet(
            set: 1,
            weight: '140.0',
            reps: '5',
            done: true,
            effort: 5,
            rpe: 9,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        lastModified: now.subtract(const Duration(days: 3)),
        category: ExerciseCategory.legs,
      ),
      ExerciseActivity(
        id: 'activity-deadlift-1',
        email: 'demo@gymbro.app',
        exerciseId: 'ex-deadlift',
        exerciseName: 'Deadlift',
        schedaName: 'Pull Day A',
        sets: [
          ExerciseActivitySet(
            set: 1,
            weight: '160.0',
            reps: '5',
            done: true,
            effort: 5,
            rpe: 9,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 5)),
        lastModified: now.subtract(const Duration(days: 5)),
        category: ExerciseCategory.back,
      ),
      ExerciseActivity(
        id: 'activity-ohp-1',
        email: 'demo@gymbro.app',
        exerciseId: 'ex-overhead-press',
        exerciseName: 'Overhead Press',
        schedaName: 'Push Day B',
        sets: [
          ExerciseActivitySet(
            set: 1,
            weight: '60.0',
            reps: '8',
            done: true,
            effort: 4,
            rpe: 8,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        lastModified: now.subtract(const Duration(days: 1)),
        category: ExerciseCategory.shoulders,
      ),
      ExerciseActivity(
        id: 'activity-pullups-1',
        email: 'demo@gymbro.app',
        exerciseId: 'ex-pullups',
        exerciseName: 'Pull-ups',
        schedaName: 'Pull Day B',
        sets: [
          ExerciseActivitySet(
            set: 1,
            weight: '15.0',
            reps: '10',
            done: true,
            effort: 4,
            rpe: 8,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 4)),
        lastModified: now.subtract(const Duration(days: 4)),
        category: ExerciseCategory.back,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING TOUR DATA (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo tour step for Tour Bottom Sheet
  static OnboardingTourStep get demoTourStep {
    return const OnboardingTourStep(
      id: 'welcome',
      position: 0,
      totalSteps: 5,
      titleKey: 'tourAiCoachTitle',
      descriptionKey: 'tourAiCoachDescription',
      targetWidgetKey: 'demo_widget_key',
      autoAdvanceDuration: Duration(seconds: 5),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WORKOUT HISTORY DETAIL DATA (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Demo workout history detail for Workout Detail Modal
  static WorkoutHistoryDetail get demoWorkoutHistoryDetail {
    final now = DateTime.now();
    return WorkoutHistoryDetail(
      id: 'workout-history-1',
      userId: 'demo-user-id',
      name: 'Push Day A',
      description: 'Chest and triceps workout',
      createdAt: now.subtract(const Duration(days: 1)),
      startedAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1, hours: -1)),
      updatedAt: now.subtract(const Duration(days: 1)),
      duration: const Duration(hours: 1, minutes: 15),
      exercises: [], // Empty for demo purposes
      metadata: {'totalVolume': 5000.0, 'averageRPE': 8.5},
      templateId: 'template-push-a',
    );
  }
}
