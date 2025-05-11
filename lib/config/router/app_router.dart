import 'package:gemini_ui_app/presentation/screens/basic-prompt/basic_prompt_screen.dart';
import 'package:gemini_ui_app/presentation/screens/chat-context/chat_context_screen.dart';
import 'package:gemini_ui_app/presentation/screens/image/image_playground.dart';
import 'package:go_router/go_router.dart';

import 'package:gemini_ui_app/presentation/screens/home/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/basic-prompt',
      builder: (context, state) => const BasicPropmpScreen(),
    ),

    GoRoute(
      path: '/history-chat',
      builder: (context, state) => const ChatContextScreen(),
    ),

    GoRoute(
      path: '/image-playground',
      builder: (context, state) => const ImagePlaygroundScreen(),
    ),
  ],
);
