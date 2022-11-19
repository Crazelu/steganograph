import 'dart:io';

import 'package:steganograph/steganograph.dart';

void main() async {
  await encodeBytes();
  final embeddedMessage = await Steganograph.decode(
    image: File('example/assets/result.png'),
  );

  print(embeddedMessage);
}

Future<void> encodeBytes() async {
  final bytes = await File('example/assets/test.png').readAsBytes();

  final encodedBytes = await Steganograph.encodeBytes(
    bytes: bytes,
    message: "Please work!",
  );

  final file = File('example/assets/result.png');
  await file.writeAsBytes(encodedBytes!);
}
