import 'dart:io';
import 'package:steganograph/src/encryption_type.dart';
import 'package:steganograph/src/steganograph.dart';

void main() async {
  final keypair = Steganograph.generateKeypair();

  final file = await Steganograph.encode(
    image: File('example/assets/cat.png'),
    message: "Maybe I'm not ok!",
    encryptionKey: keypair.publicKey,
    encryptionType: EncryptionType.asymmetric,
    outputFilePath: 'example/assets/result.png',
  );

  final embeddedMessage = await Steganograph.decode(
    image: File(file!.path),
    encryptionKey: keypair.privateKey,
    encryptionType: EncryptionType.asymmetric,
  );

  print(embeddedMessage);
}
