import 'dart:math' as math;

const _zero = '0';
const _one = '1';

/// Representation of a binary number.
class Binary {
  late final String _bits;
  String get bits => _bits;

  Binary([String bits = _zero]) : _bits = bits.padLeft(8, _zero);
  

  /// Returns base 10 value of a binary number.
  static int toBase10(Binary binary) {
    int result = 0;
    int step = 0;
    String bits = binary.bits;
    for (int i = bits.length - 1; i >= 0; i--) {
      result += int.parse(bits[i]) * math.pow(2, step).toInt();
      step += 1;
    }
    return result;
  }

  /// Returns a `Binary` object constructed from [number].
  static Binary fromBase10(num number) {
    if (number == 0) return Binary(_zero * 8);

    String result = '';
    while (number != 1) {
      result = '${number % 2}' '$result';
      number = (number / 2).floor();
    }

    result = '1' '$result';

    return Binary(result.padLeft(8, _zero));
  }

  /// Swaps least significant bit with [bit].
  Binary lsbSwap(String bit) {
    if (![_one, _zero].contains(bit)) {
      throw "Invalid binary operation: Trying to insert $bit";
    }
    if (bits[bits.length - 1] != bit) {
      return Binary(
        (bits.substring(0, bits.length - 1) + bit).padLeft(8, _zero),
      );
    }
    return this;
  }

  @override
  String toString() => bits;

  @override
  int get hashCode => Object.hashAll([bits]);

  @override
  bool operator ==(Object other){
    return other is Binary && other.bits == bits;
  }
}
