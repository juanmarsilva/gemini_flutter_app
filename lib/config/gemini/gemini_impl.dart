import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class GeminiImpl {
  final Dio _http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});

      final response = await _http.post('/basic-prompt', data: body);

      return response.data;
    } catch (e) {
      throw Exception("Can't get Gemini response");
    }
  }

  Stream<String> getResponseStream(
    String prompt, {
    List<XFile> files = const [],
  }) async* {
    try {
      yield* _getStreamResponse(
        endpoint: '/basic-prompt-stream',
        prompt: prompt,
        files: files,
      );
    } catch (e) {
      throw Exception("Can't get Gemini response");
    }
  }

  Stream<String> getChatStream(
    String prompt,
    String chatId, {
    List<XFile> files = const [],
  }) async* {
    try {
      Map<String, String> formFields = {'chatId': chatId};

      yield* _getStreamResponse(
        endpoint: '/chat-stream',
        prompt: prompt,
        files: files,
        formFields: formFields,
      );
    } catch (e) {
      throw Exception("Can't get Gemini response");
    }
  }

  Stream<String> _getStreamResponse({
    required String endpoint,
    required String prompt,
    List<XFile> files = const [],
    Map<String, dynamic> formFields = const {},
  }) async* {
    final formData = FormData();

    formData.fields.add(MapEntry('prompt', prompt));

    for (final entry in formFields.entries) {
      formData.fields.add(MapEntry(entry.key, entry.value));
    }

    if (files.isNotEmpty) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }

    final response = await _http.post(
      endpoint,
      data: formData,
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream as Stream<List<int>>;

    String buffer = '';

    await for (final chunk in stream) {
      final chunkString = utf8.decode(chunk, allowMalformed: true);

      buffer += chunkString;

      yield buffer;
    }
  }

  Future<String?> generateImage(
    String prompt, {
    List<XFile> files = const [],
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));

    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );
    }

    try {
      final response = await _http.post('/generate-image', data: formData);

      return response.data['imageUrl'];
    } catch (e) {
      return null;
    }
  }
}
