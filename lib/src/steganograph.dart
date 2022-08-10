// ignore_for_file: body_might_complete_normally_nullable

import 'dart:convert';
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
  ///Embeds [fileToEmbed] in [image] and returns resulting image file.
  ///
  ///If [encryptionKey] is provided, [fileToEmbed] is encrypted
  ///symmetrically or asymmetrically depending on specified [encryptionType].
  ///
  ///For [EncryptionType.asymmetric], make sure to pass the public
  ///key from [generateKeypair] as [encryptionKey].
  ///
  ///Supported extensions for [image] include `png`, `jpeg` and `jpg`.
  ///
  ///If [outputFilePath] is specified, the resulting image will
  ///be saved at that path.
  ///A unique path is generated in the same directory as [image]
  ///if [outputFilePath] is not specified or if it is invalid.
  ///
  ///[unencryptedPrefix] if specified, is appended unencrypted to the encrypted [fileToEmbed]
  ///(if encryption is required) in the format `"{unencryptedPrefix : encryptedFile}"`.
  static Future<File?> encodeFile({
    required File image,
    required File fileToEmbed,
    String? unencryptedPrefix,
    EncryptionType encryptionType = EncryptionType.symmetric,
    String? outputFilePath,
    String? encryptionKey,
  }) async {
    _assertIsImage(image);
    try {
      final encodedImage = await _encodeToPng(image);

      final size = ImageSizeGetter.getSize(FileInput(image));

      String messageToEmbed = base64Encode(fileToEmbed.readAsBytesSync());
      String extension = Util.getExtension(fileToEmbed.path);

      if (encryptionKey != null) {
        messageToEmbed = _encrypt(
          key: encryptionKey,
          type: encryptionType,
          message: messageToEmbed,
        );

        extension = _encrypt(
          key: encryptionKey,
          type: encryptionType,
          message: extension,
        );
      }

      if (unencryptedPrefix != null) {
        messageToEmbed = jsonEncode({unencryptedPrefix: messageToEmbed});
      }

      final imageWithHiddenMessage = Image.fromBytes(
        size.width,
        size.height,
        await encodedImage!.getBytes(),
        textData: {
          Util.SECRET_KEY: messageToEmbed,
          Util.FILE_EXTENSION_KEY: extension,
        },
      );

      final imageBytes = encodePng(imageWithHiddenMessage);

      final file = File(
        _normalizeOutputPath(
          inputFilePath: image.path,
          outputPath: outputFilePath,
        ),
      );

      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      _handleException(e);
    }
  }

  ///Extracts embedded file from [image].
  ///If [encryptionKey] is provided, resulting embedded file (if any)
  ///will be assumed as encrypted from [encodeFile] hence [decodeFile] will
  ///try to decrypt it with [encryptionKey] symmetrically
  ///or asymmetrically depending on specified [encryptionType].
  ///
  ///For [EncryptionType.asymmetric], make sure to pass the private
  ///key from [generateKeypair] as [encryptionKey].
  ///
  ///[unencryptedPrefix] if specified, is processed and removed from the
  ///embedded file before decryption is performed.
  static Future<File?> decodeFile({
    required File image,
    String? unencryptedPrefix,
    EncryptionType encryptionType = EncryptionType.symmetric,
    String? encryptionKey,
  }) async {
    try {
      _assertIsPng(image);
      final decodedImage = await decodePng(await image.readAsBytes());

      String encodedFile = decodedImage?.textData?[Util.SECRET_KEY] ?? "";
      String extension = decodedImage?.textData?[Util.FILE_EXTENSION_KEY] ?? "";

      if (encodedFile.isEmpty || extension.isEmpty) return null;

      if (encryptionKey != null) {
        encodedFile = _handleDecryption(
          type: encryptionType,
          key: encryptionKey,
          message: encodedFile,
          unencryptedPrefix: unencryptedPrefix,
        );
        extension = _handleDecryption(
          type: encryptionType,
          key: encryptionKey,
          message: extension,
        );
      }

      final file = File(Util.generatePath(image.path, extension));
      final bytes = base64Decode(encodedFile);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e, trace) {
      _handleException(e, trace);
    }
  }

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
  ///
  ///[unencryptedPrefix] if specified, is appended unencrypted to the encrypted [message]
  ///(if encryption is required) in the format `"{unencryptedPrefix : encryptedMessage}"`.
  static Future<File?> encode({
    required File image,
    required String message,
    String? unencryptedPrefix,
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

      if (unencryptedPrefix != null) {
        messageToEmbed = jsonEncode({unencryptedPrefix: messageToEmbed});
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

      final file = File(
        _normalizeOutputPath(
          inputFilePath: image.path,
          outputPath: outputFilePath,
        ),
      );

      await file.writeAsBytes(imageBytes);
      return file;
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
  ///
  ///[unencryptedPrefix] if specified, is processed and removed from the
  ///embedded message before decryption is performed.
  static Future<String?> decode({
    required File image,
    String? unencryptedPrefix,
    EncryptionType encryptionType = EncryptionType.symmetric,
    String? encryptionKey,
  }) async {
    try {
      _assertIsPng(image);
      final decodedImage = await decodePng(await image.readAsBytes());

      final textualData = decodedImage?.textData?[Util.SECRET_KEY];

      if (textualData != null &&
          textualData.isNotEmpty &&
          encryptionKey != null) {
        return _handleDecryption(
          type: encryptionType,
          key: encryptionKey,
          message: textualData,
          unencryptedPrefix: unencryptedPrefix,
        );
      }
      return textualData;
    } catch (e, trace) {
      _handleException(e, trace);
    }
  }

  static void _handleException(Object e, [StackTrace? trace]) {
    if (e is SteganographException) throw e;
    print(e);
    if (trace != null) print(trace);
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
    final rsaPublicKey = RSAPublicKey.fromString(key);
    return rsaPublicKey.encrypt(message);
  }

  static String _handleDecryption({
    required EncryptionType type,
    required String key,
    required String message,
    String? unencryptedPrefix,
  }) {
    if (unencryptedPrefix != null)
      return _verifyUnencryptedPrefixAndDecrypt(
        type: type,
        key: key,
        message: message,
        unencryptedPrefix: unencryptedPrefix,
      );

    return _decrypt(
      type: type,
      key: key,
      message: message,
    );
  }

  static String _verifyUnencryptedPrefixAndDecrypt({
    required EncryptionType type,
    required String key,
    required String message,
    required String unencryptedPrefix,
  }) {
    String encryptedMessage = message;
    if (unencryptedPrefix.isNotEmpty) {
      final decodedMessage =
          jsonDecode(encryptedMessage) as Map<String, dynamic>;
      if (decodedMessage.keys.first == unencryptedPrefix) {
        encryptedMessage = (decodedMessage).values.first;
        return _decrypt(
          type: type,
          key: key,
          message: encryptedMessage,
        );
      }
    }
    return "";
  }

  static String _decrypt({
    required EncryptionType type,
    required String key,
    required String message,
  }) {
    if (type == EncryptionType.symmetric) {
      return IgodoEncryption.decryptSymmetric(message, key);
    }
    final rsaPrivateKey = RSAPrivateKey.fromString(key);
    return rsaPrivateKey.decrypt(message);
  }

  ///Generates a keypair with public and private keys for
  ///asymmetric encryption.
  static SteganographKeypair generateKeypair() {
    final rsaKeypair = RSAKeypair.fromRandom();
    return SteganographKeypair(
      publicKey: rsaKeypair.publicKey.toString(),
      privateKey: rsaKeypair.privateKey.toString(),
    );
  }
}
