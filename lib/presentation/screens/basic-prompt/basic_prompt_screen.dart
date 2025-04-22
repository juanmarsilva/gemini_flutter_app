import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_ui_app/presentation/providers/chat/basic_chat.dart';
import 'package:gemini_ui_app/presentation/providers/chat/is_gemini_writing.dart';
import 'package:gemini_ui_app/presentation/providers/users/user_provider.dart';

class BasicPropmpScreen extends ConsumerWidget {
  const BasicPropmpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types.User geminiUser = ref.watch(geminiUserProvider);
    final types.User user = ref.watch(userProvider);
    final bool isGeminiWriting = ref.watch(isGeminiWritingProvider);
    final chatMessages = ref.watch(basicChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Básico')),
      body: Chat(
        messages: chatMessages,
        onSendPressed: (types.PartialText partialText) {
          final basicChatNotifier = ref.read(basicChatProvider.notifier);
          basicChatNotifier.addMessage(partialText: partialText, user: user);
        },
        user: user,
        theme: DarkChatTheme(),
        showUserNames: true,

        // showUserAvatars: true,
        typingIndicatorOptions: TypingIndicatorOptions(
          typingUsers: isGeminiWriting ? [geminiUser] : [], // todo
          customTypingWidget: Center(child: Text('Gemini esta pensando...')),
        ),
      ),
    );
  }
}
