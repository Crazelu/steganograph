import 'dart:io';
import 'package:steganograph/src/exceptions.dart';

class Util {
  static const SECRET_KEY = "x-encrypted-message";
  static const FILE_EXTENSION_KEY = "x-file-extension";

  static bool isImage(String path) {
    return _allowedExtensions.contains(
      getExtension(path),
    );
  }

  static String getExtension(String path) {
    try {
      return path
          .split(Platform.pathSeparator)
          .last
          .split(".")
          .last
          .toLowerCase();
    } catch (e) {
      throw SteganographFileException("Invalid file: $path");
    }
  }

  static String generatePath(String path, [String ext = "png"]) {
    try {
      final fileName = DateTime.now().toIso8601String() + ".$ext";

      final splitPath = path.split(Platform.pathSeparator);
      splitPath.removeLast();

      if (splitPath.isEmpty) {
        return fileName;
      }

      return splitPath.join("/") + "/$fileName";
    } catch (e) {
      throw SteganographFileException("Invalid file: $path");
    }
  }

  static const List<String> _allowedExtensions = [
    "png",
    "jpg",
    "jpeg",
  ];
}
