## 1.0.0

* Initial release.

## 2.0.0

* Major update of the Steganograph library.
    * `BREAKING_CHANGE`: replaces `encode` with `cloak` and `encodeBytes` with `cloakBytes`.
    * `BREAKING_CHANGE`: removes `encodeFile` and `decodeFile`.
    * Removes encryption and asymmetric keypair generation support.
    * Includes support for hiding messages in images using the Least Significant Bit steganography.
