# Steganograph

***
Steganograph is a Dart library which supports hiding mesages in images using Least Significant Bit steganography.

## Install 🚀

In the `pubspec.yaml` of your Flutter/Dart project, add the following dependency:

```yaml 
dependencies:
  steganograph: ^2.0.0
```

## Import the package in your project 📥

```dart
import 'package:steganograph/steganograph.dart';
```

## Embed messages 🔏

```dart
// this returns an image file with the resulting image unaltered
// except now it has some secret embedded message
File? stegoImageFile = await Steganograph.cloak(
    image: File('sample_image.jpg'),
    message: 'Some secret message',
    outputFilePath: 'result.png',
  );
```

Or

```dart
Uint8List? stegoImageBytes = await Steganograph.cloakBytes(
    imageBytes: Uint8List(...), // cover image byte array
    message: 'Some secret message',
    outputFilePath: 'result.png',
  );
```

## Extract embedded messages 📨

```dart
String? message = await Steganograph.uncloak(File('result.png'));

// Or

String? message = await Steganograph.uncloakBytes(stegoImageBytes);
```

## Supported image formats 🗂

Currently, you can embed messages in:
* PNG
* JPEG
* WebP
* BMP
* GIF
* ICO
* PNM
* PSD

## Contributions 🫱🏾‍🫲🏼

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/Crazelu/steganograph/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/Crazelu/steganograph/pulls).