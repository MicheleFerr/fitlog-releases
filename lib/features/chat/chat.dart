/// Chat Feature
///
/// Real-time messaging between coach and athlete.
/// Supports text, images, and workout links.
///
/// **Layer**: Feature barrel export
library;

// Domain - Entities
export 'domain/entities/chat_conversation.dart';
export 'domain/entities/chat_message.dart';

// Domain - Repository interface
export 'domain/repositories/chat_repository.dart';

// Data - Repository implementation
export 'data/repositories/chat_repository_impl.dart';

// Presentation - Providers
export 'presentation/providers/chat_providers.dart';

// Presentation - Screens
export 'presentation/screens/conversations_list_screen.dart';
export 'presentation/screens/chat_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/conversation_tile.dart';
export 'presentation/widgets/message_bubble.dart';
export 'presentation/widgets/chat_input_bar.dart';
