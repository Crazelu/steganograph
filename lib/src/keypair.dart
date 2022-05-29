class SteganographKeypair {
  final String publicKey;
  final String privateKey;

  SteganographKeypair({
    required this.publicKey,
    required this.privateKey,
  });

  @override
  String toString() {
    return "SteganographKeypair(publicKey:$publicKey, privateKey:$privateKey)";
  }
}
