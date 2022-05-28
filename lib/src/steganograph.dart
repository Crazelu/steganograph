// ignore_for_file: body_might_complete_normally_nullable

import 'dart:io';
import 'package:igodo/igodo.dart';
import 'package:image/image.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:steganograph/src/exceptions.dart';
import 'package:steganograph/src/utils.dart';

class Steganograph {
  ///Writes [message] into [image] without altering rgb channels.
  ///If [encryptionKey] is provided, [message] is encrypted
  ///symmetrically with it.
  ///
  ///Supported file types for encoding include `png` and `jpg`.
  ///
  ///Resulting bytes list represents a PNG image.
  static Future<List<int>?> encode({
    required File image,
    required String message,
    String? encryptionKey,
  }) async {
    _assertIsImage(image);
    try {
      final encodedImage = await _encodeToPng(image);

      final size = ImageSizeGetter.getSize(FileInput(image));

      String messageToEmbed = message;

      if (encryptionKey != null) {
        messageToEmbed = IgodoEncryption.encryptSymmetric(
          messageToEmbed,
          encryptionKey,
        );
      }

      final im = Image.fromBytes(
        size.width,
        size.height,
        await encodedImage!.getBytes(),
        textData: {
          Util.SECRET_KEY: messageToEmbed,
        },
      );

      return encodePng(im);
    } catch (e) {
      _handleException(e);
    }
  }

  ///Extracts embedded text from image.
  ///If [encryptionKey] is provided, resulting embedded text (if any)
  ///will be assumed as encoded from [encode] hence [decode] will try to decrypt it with
  ///[encryptionKey].
  static Future<String?> decode({
    required File image,
    String? encryptionKey,
  }) async {
    try {
      _assertIsPng(image);
      final decodedImage = await decodePng(await image.readAsBytes());

      final textualData = decodedImage!.textData![Util.SECRET_KEY];

      return encryptionKey != null
          ? IgodoEncryption.decryptSymmetric(
              textualData!,
              encryptionKey,
            )
          : textualData;
    } catch (e) {
      _handleException(e);
    }
  }

  static void _handleException(Object e) {
    if (e is SteganographException) throw e;
    print(e);
  }

  static void _assertIsImage(File image) {
    if (!Util.isImage(image.path)) {
      throw SteganographFileException(
        "${image.path} is not a supported file type",
      );
    }
  }

  static void _assertIsPng(File image) {
    if (Util.getExtension(image.path) != "png") {
      throw SteganographDecodingException(
        "${image.path} is not a supported file type for decoding",
      );
    }
  }

  ///Ensures image is a png to take advantage of the iText chunk.
  ///Encodes to png if necessary.
  static Future<Image?> _encodeToPng(File image) async {
    try {
      final extension = Util.getExtension(image.path);

      switch (extension) {
        case "png":
          return decodePng(await image.readAsBytes());
        case "jpg":
        case "jpeg":
          final jpgImage = decodeJpg(await image.readAsBytes());
          final size = ImageSizeGetter.getSize(FileInput(image));

          final img = Image.fromBytes(
            size.width,
            size.height,
            jpgImage!.getBytes(),
          );

          final pngBytes = encodePng(img);

          return decodePng(pngBytes);
      }
    } catch (e, trace) {
      throw SteganographFileException(
        "${image.path} is not a supported file type",
        trace,
      );
    }
  }
}
