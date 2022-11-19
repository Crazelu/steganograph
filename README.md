# steganograph

***
Steganograph is a pure Dart steganography library which supports hiding mesages and files in images with an option to encrypt embedded secrets for more security.

## Install 🚀

In the `pubspec.yaml` of your Flutter/Dart project, add the following dependency:

```yaml 
dependencies:
  steganograph: ^1.0.0
```

## Import the package in your project 📥

```dart
import 'package:steganograph/steganograph.dart';
```

## Embed messages or files 🔏

```dart
//this returns an image file with the resulting image unaltered
//except now it has some secret embedded text
File? file = await Steganograph.encode(
    image: File('sample_image.jpg'),
    message: 'Some secret message',
    outputFilePath: 'result.png',
  );

//this returns an image file with the resulting image unaltered
//except now it has some secret embedded file
File? encodedFile = await Steganograph.encodeFile(
    image: File('sample_image.jpg'),
    fileToEmbed: File('sample_file.pdf'),
    outputFilePath: 'result.png',
  );

```

## Decode and extract embedded messages or files 📨

```dart
String? embeddedMessage = await Steganograph.decode(
  image: File('result.png'),
);

final embeddedFile = await Steganograph.decodeFile(
  image: File('result.png'),
);

```

# Using encryption 🔐

Embedded messages/files can be encrypted to securely share images with secret content wherever without revealing said content.

## Symmetric Encryption 🔗

```dart
//Encode image with an encryption key
File? file = await Steganograph.encode(
    image: File('sample_image.png'),
    message: 'Some secret message',
    encryptionKey: ENCRYPTION_KEY,
    outputFilePath: 'result.png',
  );
```

```dart
//decode with same encryption key used to encode 
//to retrieve encrypted message
 String? embeddedMessage = await Steganograph.decode(
    image: File('result.png'),
    encryptionKey: ENCRYPTION_KEY,
  );
```

## Asymmetric Encryption ⛓

```dart
//generate keypair
SteganographKeypair keypair = Steganograph.generateKeypair();
```

```dart
//Encode image with public key from keypair
File? file = await Steganograph.encode(
    image: File('sample_image.png'),
    message: 'Some secret message',
    encryptionKey: keypair.publicKey,
    encryptionType: EncryptionType.asymmetric,
    outputFilePath: 'result.png',
  );
```

```dart
//Decode image with private key from keypair to retrieve message
String? embeddedMessage = await Steganograph.decode(
    image: File(file!.path),
    encryptionKey: keypair.privateKey,
    encryptionType: EncryptionType.asymmetric,
  );
```


## Supported file types 🗂

Currently, you can embed messages and any kind of file in:
* PNG images
* JPEG images

## Contributions 🫱🏾‍🫲🏼

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/Crazelu/steganograph/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/Crazelu/steganograph/pulls).