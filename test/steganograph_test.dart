import 'dart:io';
import 'package:steganograph/steganograph.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Steganograph Tests | ',
    () {
      test(
        'setTerminator',
        () {
          expect(Steganograph.terminator, '#~#');
          expect(Steganograph.terminatorBits, '001000110111111000100011');

          Steganograph.setTerminator('terminator');

          expect(Steganograph.terminator, 'terminator');
          expect(
            Steganograph.terminatorBits,
            '01110100011001010111001001101101011010010110111001100001011101000110111101110010',
          );
        },
      );

      test(
        'uncloak throws SteganographCloakException if image is not PNG',
        () {
          expect(
            Steganograph.uncloak(File('image.jpeg')),
            throwsA(isA<SteganographCloakException>()),
          );
        },
      );
    },
  );
}
