import 'package:steganograph/src/binary.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Binary Tests | ',
    () {
      test(
        'Empty',
        () {
          final binary = Binary();
          expect(binary.bits, '00000000');
        },
      );

      test(
        'Non empty',
        () {
          const bits = '101';
          final binary = Binary(bits);
          expect(binary.bits, '00000101');
        },
      );

      test(
        'toBase10',
        () {
          expect(Binary.toBase10(Binary('100')), 4);
          expect(Binary.toBase10(Binary('1101')), 13);
        },
      );

      test(
        'fromBase10',
        () {
          expect(Binary.fromBase10(0), Binary('00000000'));
          expect(Binary.fromBase10(13), Binary('01101'));
        },
      );

      test(
        'lsbSwap',
        () {
          expect(Binary('00000000').lsbSwap('1'), Binary('00000001'));
          expect(Binary('1111').lsbSwap('1'), Binary('00001111'));
          expect(Binary('1111').lsbSwap('0'), Binary('00001110'));
          expect(Binary('01010000').lsbSwap('0'), Binary('01010000'));
        },
      );
    },
  );
}
