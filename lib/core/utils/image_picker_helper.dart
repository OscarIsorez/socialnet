import 'package:image_picker/image_picker.dart';

/// Light wrapper around [ImagePicker] to make it easier to mock and to keep the
/// presentation layer focused on user interactions rather than plugin
/// configuration.
class ImagePickerHelper {
  ImagePickerHelper({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImageFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  Future<XFile?> captureImageWithCamera() {
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  }
}
