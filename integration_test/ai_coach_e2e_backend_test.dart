import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart';
import 'package:gymbro_flutter_new/core/security/app_check_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/exceptions/ai_coach_exception.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

const _e2eAuthEmail = String.fromEnvironment('E2E_AUTH_EMAIL');
const _e2eAuthPassword = String.fromEnvironment('E2E_AUTH_PASSWORD');
const _e2eAuthCustomToken = String.fromEnvironment('E2E_AUTH_CUSTOM_TOKEN');

Future<void> _ensureAuthenticatedForE2E() async {
  final auth = FirebaseAuth.instance;

  // Reuse current session when available to avoid unnecessary auth churn.
  if (auth.currentUser != null) {
    return;
  }

  if (_e2eAuthCustomToken.isNotEmpty) {
    await auth.signInWithCustomToken(_e2eAuthCustomToken);
    return;
  }

  if (_e2eAuthEmail.isNotEmpty && _e2eAuthPassword.isNotEmpty) {
    await auth.signInWithEmailAndPassword(
      email: _e2eAuthEmail,
      password: _e2eAuthPassword,
    );
    return;
  }

  // Fallback for local debug runs: anonymous auth if enabled in Firebase.
  try {
    await auth.signInAnonymously();
    return;
  } on FirebaseAuthException catch (e) {
    throw TestFailure(
      'Nessuna autenticazione E2E disponibile e login anonimo fallito '
      '(code: ${e.code}). '
      'Fai login prima di avviare il test oppure passa '
      '--dart-define=E2E_AUTH_EMAIL=... --dart-define=E2E_AUTH_PASSWORD=... '
      'oppure --dart-define=E2E_AUTH_CUSTOM_TOKEN=...',
    );
  }

}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Coach E2E (debug authenticated)', () {
    late AIChatRepositoryImpl repository;

    setUpAll(() async {
      await EnvironmentConfig.load();

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        // iOS AppDelegate may have already configured [DEFAULT] natively,
        // and Firebase.apps.isEmpty can be false on the Dart side only after
        // initializeApp completes — so we always attempt and catch duplicate.
        final isDuplicateApp = e.toString().contains('duplicate-app');
        if (!isDuplicateApp) {
          rethrow;
        }
      }

      await AppCheckConfig.initialize();

      await _ensureAuthenticatedForE2E();

      repository = AIChatRepositoryImpl();
    });

    testWidgets('basic text response', (_) async {
      final response = await repository
          .sendMessage(
            model: 'meta-llama/llama-3.3-70b-instruct',
            messages: const [
              {
                'role': 'user',
                'content':
                    'Rispondi in italiano con una frase breve: "test e2e ok".',
              },
            ],
          )
          .timeout(const Duration(seconds: 90));

      expect(response.payload, isNotEmpty);
      expect(response.payload.startsWith('__TOOL_CALLS__:'), isFalse);
      expect(response.quota, isNotNull);
    });

    testWidgets('tool-calling response marker', (_) async {
      const pingTool = {
        'type': 'function',
        'function': {
          'name': 'ping',
          'description':
              'Tool di test. Chiamalo sempre quando l\'utente chiede ping.',
          'parameters': {
            'type': 'object',
            'properties': {
              'value': {'type': 'string', 'description': 'Payload libero'},
            },
            'required': ['value'],
          },
        },
      };

      final response = await repository
          .sendMessage(
            model: 'meta-llama/llama-3.3-70b-instruct',
            messages: const [
              {
                'role': 'system',
                'content':
                    'Quando ricevi una richiesta di ping devi usare il tool ping.',
              },
              {'role': 'user', 'content': 'Esegui ping adesso.'},
            ],
            tools: const [pingTool],
          )
          .timeout(const Duration(seconds: 90));

      expect(response.payload.startsWith('__TOOL_CALLS__:'), isTrue);
      expect(response.quota, isNotNull);
    });

    testWidgets('daily quota resource-exhausted', (_) async {
      bool exhausted = false;
      AICoachException? finalQuotaError;

      for (var i = 0; i < 25; i++) {
        try {
          await repository
              .sendMessage(
                model: 'meta-llama/llama-3.3-70b-instruct',
                messages: const [
                  {'role': 'user', 'content': 'ok'},
                ],
              )
              .timeout(const Duration(seconds: 90));
        } on AICoachException catch (e) {
          if (e.code == 'resource-exhausted') {
            exhausted = true;
            finalQuotaError = e;
            break;
          }
          rethrow;
        }
      }

      expect(exhausted, isTrue);
      expect(finalQuotaError?.code, 'resource-exhausted');
    });
  });
}
