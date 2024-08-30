import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:steganograph/src/binary.dart';
import 'package:steganograph/src/exceptions.dart';
import 'package:steganograph/src/utils.dart';

String _terminatingSequence = '#~#';
String _terminatingSequenceBits = '001000110111111000100011';

class Steganograph {
  /// Terminator used for testing purposes only.
  @visibleForTesting
  static String get terminator => _terminatingSequence;

  /// Terminator bits used for testing purposes only.
  @visibleForTesting
  static String get terminatorBits => _terminatingSequenceBits;

  /// Sets [terminator] which is used to indicate the end of a message.
  /// [terminator] is appended to the messages embedded in images by [cloak] and [cloakBytes].
  /// [terminator] is also used by [uncloak] and [uncloakBytes] to find the end of a message.
  static void setTerminator(String terminator) {
    _terminatingSequence = terminator;

    String terminatingSequenceBits = '';

    for (var charCode in utf8.encode(terminator)) {
      terminatingSequenceBits += Binary.fromBase10(charCode).toString();
    }
    _terminatingSequenceBits = terminatingSequenceBits;
  }

  /// Writes [message] into [image] without altering rgb channels
  /// and returns image [File] with [message] embedded.
  static Future<File?> cloak({
    required File image,
    required String message,
    String? outputFilePath,
  }) async {
    final bytes = await image.readAsBytes();
    final cloakedBytes = await _cloak(bytes: bytes, message: message);

    File? file;

    if (cloakedBytes != null) {
      file = File(
        _normalizeOutputPath(
          inputFilePath: image.path,
          outputPath: outputFilePath,
        ),
      );

      await file.writeAsBytes(cloakedBytes);
    }

    return file;
  }

  /// Writes [message] into [imageBytes] without altering rgb channels
  /// and returns [Uint8List] byte array of the image with [message] embedded.
  static Future<Uint8List?> cloakBytes({
    required Uint8List imageBytes,
    required String message,
    String? outputFilePath,
  }) {
    return _cloak(bytes: imageBytes, message: message);
  }

  /// Writes [message] into [bytes] without altering rgb channels
  /// and returns [File] containing image bytes with message embedded.
  static Future<Uint8List?> _cloak({
    required Uint8List bytes,
    required String message,
  }) async {
    try {
      final cloakMessage = message + _terminatingSequence;
      final wordLength = cloakMessage.length * 8;

      Image? img = await decodeImage(bytes);

      if (img == null) {
        throw SteganographCloakException('Image format not supported');
      }

      img = img.convert(numChannels: 4);

      final pixelCount = img.height * img.width;

      if (pixelCount < wordLength) {
        throw SteganographCloakException('Not enough pixels to cloak message');
      }

      String cloakMessageInBinary = '';
      for (var charCode in utf8.encode(cloakMessage)) {
        cloakMessageInBinary += Binary.fromBase10(charCode).toString();
      }

      int round = 0;
      int nextCharIndex = 0;

      for (var frame in img.frames) {
        for (final pixel in frame) {
          if (nextCharIndex == wordLength) {
            return Uint8List.fromList(encodePng(img));
          }

          switch (round) {
            case 0:
              final red = Binary.fromBase10(pixel.r).lsbSwap(
                cloakMessageInBinary[nextCharIndex],
              );
              pixel.r = Binary.toBase10(red);
            case 1:
              final green = Binary.fromBase10(pixel.g).lsbSwap(
                cloakMessageInBinary[nextCharIndex],
              );
              pixel.g = Binary.toBase10(green);
            case 2:
              final blue = Binary.fromBase10(pixel.b).lsbSwap(
                cloakMessageInBinary[nextCharIndex],
              );
              pixel.b = Binary.toBase10(blue);
          }

          nextCharIndex++;
          round++;
          if (round > 2) round = 0;
        }
      }

      return Uint8List.fromList(encodePng(img));
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  /// Extracts embedded text from [image].
  static Future<String?> uncloak(File image) async {
    _assertIsPng(image);
    final bytes = await image.readAsBytes();
    return _uncloak(bytes);
  }

  /// Extracts embedded text from [bytes].
  static String? uncloakBytes(Uint8List bytes) {
    return _uncloak(bytes);
  }

  /// Extracts embedded text from [bytes].
  static String? _uncloak(Uint8List bytes) {
    try {
      Image img = decodePng(bytes)!;
      String leastSignificantBits = '';
      String terminator = '';
      int round = 0;

      for (var frame in img.frames) {
        for (final pixel in frame) {
          if (terminator == _terminatingSequenceBits) {
            return _getCloakedMessage(leastSignificantBits);
          }

          final color = switch (round) {
            0 => Binary.fromBase10(pixel.r),
            1 => Binary.fromBase10(pixel.g),
            _ => Binary.fromBase10(pixel.b),
          };

          final lsb = color.bits[7];
          leastSignificantBits += lsb;
          terminator += lsb;

          if (terminator.length > _terminatingSequenceBits.length) {
            terminator = terminator.substring(1);
          }

          round++;
          if (round > 2) round = 0;
        }
      }

      return _getCloakedMessage(leastSignificantBits);
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  /// Extracts cloaked message from [leastSignificantBits].
  static String? _getCloakedMessage(String leastSignificantBits) {
    String cloakedMessage = '';

    for (int i = 0; i < leastSignificantBits.length; i += 8) {
      final bits = leastSignificantBits.substring(i, i + 8);
      final charCode = Binary.toBase10(Binary(bits));
      cloakedMessage += String.fromCharCode(charCode);
    }
    if (!cloakedMessage.endsWith(_terminatingSequence)) {
      return null;
    }

    return cloakedMessage.substring(
      0,
      cloakedMessage.length - _terminatingSequence.length,
    );
  }

  /// Only rethrow [SteganographException]s.
  static void _handleException(Object e) {
    if (e is SteganographException) throw e;
  }

  /// Throws [SteganographCloakException] if [image] is not a PNG file.
  static void _assertIsPng(File image) {
    if (Util.getExtension(image.path) != 'png') {
      throw SteganographCloakException(
        '${image.path} is not a supported file type for decoding',
      );
    }
  }

  /// Generates a file path in the same directory as [inputFilePath]
  /// if [outputPath] is `null` or isn't a valid `PNG` file path.
  /// Otherwise, [outputPath] is returned.
  static String _normalizeOutputPath({
    required String inputFilePath,
    String? outputPath,
  }) {
    try {
      if (Util.getExtension(outputPath!) == 'png') {
        return outputPath;
      }
    } catch (e) {}
    return Util.generatePath(inputFilePath);
  }
}
