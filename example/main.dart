import 'dart:io';
import 'package:steganograph/steganograph.dart';

void main() async {
  const ENCRYPTION_KEY = "heheheehehhehe";

  final bytes = await Steganograph.encode(
    image: File('assets/dogs.jpeg'),
    message: "Maybe I'm not ok!",
    encryptionKey: ENCRYPTION_KEY,
  );

  final file = File('assets/result.png');
  await file.writeAsBytes(bytes ?? []);

  final embeddedMessage = await Steganograph.decode(
    image: File('assets/result.png'),
    encryptionKey: ENCRYPTION_KEY,
  );

  print(embeddedMessage);
}
