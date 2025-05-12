import 'package:gemini_ui_app/config/helpers/temporal_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_image_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedImage extends _$SelectedImage {
  @override
  String? build() => null;

  void setSelectedImage(String imageUrl) {
    if (state == imageUrl) {
      state = null;
      return;
    }

    state = imageUrl;
  }

  void clearSelectedImage() {
    state = null;
  }

  Future<XFile?> getXFileFromSelectedImage() async {
    if (state == null) return null;

    return await TemporalImages.xFileFromUrl(state!);
  }
}
