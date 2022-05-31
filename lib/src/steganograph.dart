// ignore_for_file: body_might_complete_normally_nullable

import 'dart:io';
import 'package:crypton/crypton.dart';
import 'package:igodo/igodo.dart';
import 'package:image/image.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:steganograph/src/encryption_type.dart';
import 'package:steganograph/src/exceptions.dart';
import 'package:steganograph/src/keypair.dart';
import 'package:steganograph/src/utils.dart';

class Steganograph {
  ///Writes [message] into [image] without altering rgb channels
  ///and returns image file with message embedded.
  ///
  ///If [encryptionKey] is provided, [message] is encrypted
  ///symmetrically or asymmetrically depending on specified [encryptionType].
  ///
  ///For [EncryptionType.asymmetric], make sure to pass the public
  ///key from [generateKeypair] as [encryptionKey].
  ///
  ///Supported file types for encoding include `png`, `jpeg` and `jpg`.
  ///
  ///If [outputFilePath] is specified, the resulting image will
  ///be saved at that path.
  ///A unique path is generated in the same directory as [image]
  ///if [outputFilePath] is not specified or if it is invalid.
  static Future<List<int>?> encode({
    required File image,
    required String message,
    EncryptionType encryptionType = EncryptionType.symmetric,
    String? outputFilePath,
    String? encryptionKey,
  }) async {
    _assertIsImage(image);
    try {
      final encodedImage = await _encodeToPng(image);

      final size = ImageSizeGetter.getSize(FileInput(image));

      String messageToEmbed = message;

      if (encryptionKey != null) {
        messageToEmbed = _encrypt(
          key: encryptionKey,
          type: encryptionType,
          message: messageToEmbed,
        );
      }

      final imageWithHiddenMessage = Image.fromBytes(
        size.width,
        size.height,
        await encodedImage!.getBytes(),
        textData: {
          Util.SECRET_KEY: messageToEmbed,
        },
      );

      final imageBytes = encodePng(imageWithHiddenMessage);

      // final file = File(
      //   _normalizeOutputPath(
      //     inputFilePath: image.path,
      //     outputPath: outputFilePath,
      //   ),
      // );

      // await file.writeAsBytes(imageBytes);
      return imageBytes;
    } catch (e) {
      _handleException(e);
    }
  }

  ///Extracts embedded text from image.
  ///If [encryptionKey] is provided, resulting embedded text (if any)
  ///will be assumed as encrypted from [encode] hence [decode] will
  ///try to decrypt it with [encryptionKey] symmetrically
  ///or asymmetrically depending on specified [encryptionType].
  ///
  ///For [EncryptionType.asymmetric], make sure to pass the private
  ///key from [generateKeypair] as [encryptionKey].
  static Future<String?> decode({
    required File image,
    EncryptionType encryptionType = EncryptionType.symmetric,
    String? encryptionKey,
  }) async {
    try {
      _assertIsPng(image);
      final decodedImage = await decodePng(await image.readAsBytes());

      final textualData = decodedImage!.textData![Util.SECRET_KEY];

      if (encryptionKey != null &&
          textualData != null &&
          textualData.isNotEmpty) {
        return _decrypt(
          type: encryptionType,
          key: encryptionKey,
          message: textualData,
        );
      }
      return textualData;
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

  ///Ensures image is a png to take advantage of the tEXt chunk.
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

  ///Generates a file path in the same directory as [inputFilePath]
  ///if [outputPath] is `null` or isn't a valid `PNG` file path.
  ///Otherwise, [outputPath] is returned.
  static String _normalizeOutputPath({
    required String inputFilePath,
    String? outputPath,
  }) {
    try {
      if (Util.getExtension(outputPath!) == "png") {
        return outputPath;
      }
    } catch (e) {}
    return Util.generatePath(inputFilePath);
  }

  static String _encrypt({
    required EncryptionType type,
    required String key,
    required String message,
  }) {
    if (type == EncryptionType.symmetric) {
      return IgodoEncryption.encryptSymmetric(message, key);
    }
    final rsaPublicKey = RSAPublicKey.fromPEM(key);
    return rsaPublicKey.encrypt(message);
  }

  static String _decrypt({
    required EncryptionType type,
    required String key,
    required String message,
  }) {
    if (type == EncryptionType.symmetric) {
      return IgodoEncryption.decryptSymmetric(message, key);
    }
    final rsaPrivateKey = RSAPrivateKey.fromPEM(key);
    return rsaPrivateKey.decrypt(message);
  }

  ///Generates a keypair with public and private keys for
  ///asymmetric encryption.
  static SteganographKeypair generateKeypair() {
    final rsaKeypair = RSAKeypair.fromRandom();
    return SteganographKeypair(
      publicKey: rsaKeypair.publicKey.toPEM(),
      privateKey: rsaKeypair.privateKey.toPEM(),
    );
  }
}
