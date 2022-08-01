import 'dart:io';
import 'package:steganograph/steganograph.dart';

void main() async {
  const ENCRYPTION_KEY = "heheheehehhehe";

  //Encode and decode text

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

  //Encode and decode file

  final encodedFile = await Steganograph.encodeFile(
    image: File('example/assets/dogs.jpeg'),
    fileToEmbed: File('example/assets/test.txt'),
    encryptionKey: ENCRYPTION_KEY,
    outputFilePath: 'example/assets/result1.png',
  );

  final embeddedFile = await Steganograph.decodeFile(
    image: File(encodedFile!.path),
    encryptionKey: ENCRYPTION_KEY,
  );

  print(embeddedFile?.path);
}
