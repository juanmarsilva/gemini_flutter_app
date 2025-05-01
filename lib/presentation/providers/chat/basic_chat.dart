import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:gemini_ui_app/config/gemini/gemini_impl.dart';
// import 'package:gemini_ui_app/presentation/providers/chat/is_gemini_writing.dart';
import 'package:gemini_ui_app/presentation/providers/users/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {
  final gemini = GeminiImpl();

  late User geminiUser;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    return [];
  }

  void addMessage({
    required PartialText partialText,
    required User user,
    List<XFile> images = const [],
  }) {
    if (images.isNotEmpty) {
      _addTextMessageWithImages(partialText, user, images);
      return;
    }

    _addTextMessage(partialText, user);
  }

  void _addTextMessage(PartialText partialText, User author) {
    _createTextMessage(partialText.text, author);

    // _geminiTextResponse(partialText.text);
    // _geminiTextResponseStream(partialText.text);
  }

  void _addTextMessageWithImages(
    PartialText partialText,
    User author,
    List<XFile> images,
  ) async {
    for (XFile image in images) {
      await _createImageMessage(image, author);
    }

    _createTextMessage(partialText.text, author);

    // _geminiTextResponse(partialText.text);
    _geminiTextResponseStream(partialText.text, images: images);
  }

  // void _geminiTextResponse(String prompt) async {
  //   _setGeminiWritingStatus(true);

  //   final textResponse = await gemini.getResponse(prompt);

  //   _setGeminiWritingStatus(false);

  //   _createTextMessage(textResponse, geminiUser);
  // }

  void _geminiTextResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async {
    _createTextMessage('Gemini esta pensando..', geminiUser);

    gemini.getResponseStream(prompt, files: images).listen((responseChunk) {
      if (responseChunk.isEmpty) return;

      final updatedMessages = [...state];
      final updateMessage = (updatedMessages.first as TextMessage).copyWith(
        text: responseChunk,
      );

      updatedMessages[0] = updateMessage;

      state = updatedMessages;
    });
  }

  // Helpers methods

  void _createTextMessage(String text, User author) {
    final message = TextMessage(
      id: uuid.v4(),
      author: author,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }

  Future<void> _createImageMessage(XFile image, User author) async {
    final message = ImageMessage(
      id: uuid.v4(),
      author: author,
      uri: image.path,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      name: image.name,
      size: await image.length(),
    );

    state = [message, ...state];
  }

  // void _setGeminiWritingStatus(bool isWriting) {
  //   final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);
  //   isWriting
  //       ? isGeminiWriting.setIsWriting()
  //       : isGeminiWriting.setIsNotWriting();
  // }
}
