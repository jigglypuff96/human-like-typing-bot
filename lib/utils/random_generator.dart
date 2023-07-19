import 'dart:math';

class RandomGenerator {
  static final random = Random();
  static int randomZeroOne() {
    // generate either 0 or 1
    final randomNumber = random.nextInt(2);
    return randomNumber;
  }

  static String randomAbc() {
    int randomAscii = random.nextInt(26) + 97;
    String randomChar = String.fromCharCode(randomAscii);
    return randomChar;
  }

  static int randomInt(int min, int max) {
    return min + random.nextInt(max - min + 1);
  }
}
