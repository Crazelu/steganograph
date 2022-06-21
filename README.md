# steganograph

***
A Dart package for carrying out steganography equipped with encryption for an additional layer of security.

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
//this returns a PNG File with the resulting image unaltered
//except now it has some secret embedded text
File? file = await Steganograph.encode(
    image: File('sample_image.jpg'),
    message: 'Some secret message',
    outputFilePath: 'result.png',
  );

```

## Decode and extract embedded messages

```dart
 String? embeddedMessage = await Steganograph.decode(
    image: File('result.png'),
  );
```

# Using encryption

Embedded messages can be encrypted to securely share images with secret messages wherever without revealing the hidden content.

## Symmetric Encryption

```dart
//this returns a PNG File with the resulting image unaltered
//except now it has some secret embedded text
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

## Asymmetric Encryption

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


## Allowed file types

Currently, you can embed messages in:
* PNG images
* JPEG, JPG images

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/Crazelu/steganograph/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/Crazelu/steganograph/pulls).