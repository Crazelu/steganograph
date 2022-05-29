import 'dart:io';
import 'package:steganograph/steganograph.dart';

void main() async {
  const ENCRYPTION_KEY = "heheheehehhehe";

  final file = await Steganograph.encode(
    image: File('example/assets/dogs.jpeg'),
    message: "Maybe I'm not ok!",
    encryptionKey: ENCRYPTION_KEY,
    outputFilePath: 'example/assets/result.png',
  );

  final embeddedMessage = await Steganograph.decode(
    image: File(file!.path),
    encryptionKey: ENCRYPTION_KEY,
  );

  print(embeddedMessage);
}
