/// Coach Feature - Barrel File
///
/// Export all public APIs for the coach feature.
/// Use this for importing coach functionality in other features.
///
/// ```dart
/// import 'package:gymbro_flutter_new/features/coach/coach.dart';
/// ```
library;

// Domain - Entities
export 'domain/entities/account_mode.dart';
export 'domain/entities/coach_relationship.dart';

// Domain - Repositories
export 'domain/repositories/coach_repository.dart';

// Data - Repositories
export 'data/repositories/coach_repository_impl.dart';

// Presentation - Providers
export 'presentation/providers/coach_providers.dart';

// Presentation - Screens
export 'presentation/screens/athletes_list_screen.dart';
export 'presentation/screens/coach_dashboard_screen.dart';
export 'presentation/screens/link_coach_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/athlete_card.dart';
