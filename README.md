# steganograph

***
Steganography powered by Dart!
Embed texts in images and share them encrypted with anyone securely. All without altering the RGBA channels of the image.

## Install

In the `pubspec.yaml` of your Flutter/Dart project, add the following dependency:

```yaml 
dependencies:
  steganograph:
    git:
      url: git@github.com:Crazelu/steganograph.git
      ref: main
```

## Import the package in your project:

```dart
import 'package:steganograph/steganograph.dart';
```

## Embed messages

```dart
//this returns bytes that can be written into a *PNG* File
//to build the resulting image unaltered in RGBA channels
final bytes = await Steganograph.encode(
    image: File('sample_image.jpg'),
    message: "Secret message",
  );

  final file = File('result.png');
  await file.writeAsBytes(bytes!);
```

## Decode and extract embedded messages

```dart
 final embeddedMessage = await Steganograph.decode(
    image: File('result.png'),
  );
```

## Using encryption

Embedded messages can be encrypted to securely share images with embedded messages wherever without revealing the hidden content.

```dart
//this returns bytes that can be written into a *PNG* File
//to build the resulting image unaltered in RGBA channels
final bytes = await Steganograph.encode(
    image: File('sample_image.png'),
    message: "Secret message",
    encryptionKey: ENCRYPTION_KEY,
  );

  final file = File('result.png');
  await file.writeAsBytes(bytes!);
```

```dart
//decode with same encryption key used to encode to retrieve
//encrypted message
 final embeddedMessage = await Steganograph.decode(
    image: File('result.png'),
    encryptionKey: ENCRYPTION_KEY,
  );
```

## Allowed file types

Currently, you can embed messages in:
* PNG images
* JPEG, JPG images

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/Crazelu/steganograph/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/Crazelu/steganograph/pulls).