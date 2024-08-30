import 'dart:io';
import 'package:steganograph/src/exceptions.dart';

class Util {
  static String getExtension(String path) {
    try {
      final split = path.split(Platform.pathSeparator).last.split(".");

      if (split.length == 1 && split.first == path) {
        throw SteganographFileException('Invalid file: $path');
      }

      return split.last.toLowerCase();
    } catch (e) {
      if(e is SteganographException) rethrow;
      throw SteganographFileException('Invalid file: $path');
    }
  }

  static String generatePath(String path, [String ext = 'png']) {
    try {
      final fileName = DateTime.now().toIso8601String() + '.$ext';

      final splitPath = path.split(Platform.pathSeparator);
      splitPath.removeLast();

      if (splitPath.isEmpty) {
        return fileName;
      }

      return splitPath.join(Platform.pathSeparator) +
          '${Platform.pathSeparator}$fileName';
    } catch (e) {
      throw SteganographFileException('Invalid file: $path');
    }
  }
}
