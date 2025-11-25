import 'package:integration_test/integration_test.dart';
import 'timer_lockscreen_test.dart' as timer_tests;
import 'notification_system_test.dart' as notification_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Esegui tutti i test di integrazione
  timer_tests.main();
  notification_tests.main();
}