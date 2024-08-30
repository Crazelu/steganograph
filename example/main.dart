import 'dart:io';
import 'package:steganograph/steganograph.dart';

void main() async {
  final file = await Steganograph.cloak(
    image: File('example/assets/scribble.png'),
    message: "Insert some really top secret message here!",
    outputFilePath: 'example/assets/result.png',
  );

  final embeddedMessage = await Steganograph.uncloak(File(file!.path));

  print(embeddedMessage);

  final coverImage = File('example/assets/scribble.png');
  final coverImageBytes = await coverImage.readAsBytes();

  final stegoImageBytes = await Steganograph.cloakBytes(
    imageBytes: coverImageBytes,
    message: 'Some other secret message',
  );

  final message = await Steganograph.uncloakBytes(stegoImageBytes!);

  print(message);
}
