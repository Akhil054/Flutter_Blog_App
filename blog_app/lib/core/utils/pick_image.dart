import 'dart:io';
import 'dart:developer' as developer;

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    // #region debug-point A:image-pick-start
    developer.log(
      '[DEBUG] pickImage started',
      name: 'blog-upload-web',
    );
    // #endregion
    /// picks an image from the gallery
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    /// returns the file if the user has picked an image, otherwise returns null
    if (xFile != null) {
      // #region debug-point B:image-pick-result
      developer.log(
        '[DEBUG] pickImage success path=${xFile.path}',
        name: 'blog-upload-web',
      );
      // #endregion
      return File(xFile.path);
    } else {
      // #region debug-point C:image-pick-null
      developer.log(
        '[DEBUG] pickImage returned null',
        name: 'blog-upload-web',
      );
      // #endregion
      return null;
    }
  } catch (e) {
    // #region debug-point D:image-pick-error
    developer.log(
      '[DEBUG] pickImage failed error=$e',
      name: 'blog-upload-web',
    );
    // #endregion
    return null;
  }
}
