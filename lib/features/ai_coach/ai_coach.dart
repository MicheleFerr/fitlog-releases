/// AI Coach Feature
///
/// AI-powered fitness coach using OpenRouter (Mistral 7B free model).
/// Provides personalized training advice based on user analytics.
///
/// **Layer**: Feature Barrel Export
/// **Feature**: AI Coach
library;

// Domain - Entities
export 'domain/entities/ai_message.dart';
export 'domain/entities/ai_context.dart';
export 'domain/entities/rate_limit_result.dart';

// Domain - Repositories
export 'domain/repositories/ai_chat_repository.dart';

// Domain - Services
export 'domain/services/ai_coach_service.dart';

// Presentation - Providers
export 'presentation/providers/ai_chat_provider.dart';
export 'presentation/providers/ai_context_provider.dart';
export 'presentation/providers/ai_rate_limit_provider.dart';

// Presentation - Screens
export 'presentation/screens/ai_coach_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/ai_message_bubble.dart';
export 'presentation/widgets/ai_typing_indicator.dart';
export 'presentation/widgets/ai_input_bar.dart';
export 'presentation/widgets/ai_rate_limit_banner.dart';
