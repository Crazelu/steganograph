import 'package:steganograph/src/exceptions.dart';
import 'package:steganograph/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Util Tests | ',
    () {
      test(
        'getExtension throws SteganographFileException for paths with no extension',
        () {
          expect(
            () => Util.getExtension('path'),
            throwsA(isA<SteganographFileException>()),
          );
        },
      );

      test(
        'generatePath',
        () {
          final generatedPath = Util.generatePath('me/you');

          final pattern = RegExp(
            'me\\/\\d{4}-([0-9][0-9])-([0-9][0-9])T([0-9][0-9]):([0-9][0-9]):([0-9][0-9]).\\d{6}.png',
          );

          expect(pattern.hasMatch(generatedPath), isTrue);
        },
      );
    },
  );
}
