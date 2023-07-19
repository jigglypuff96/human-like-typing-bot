import 'dart:math';

class TypingSpeed {
  static final random = Random();
  static final mean = 1; // Mean of the normal distribution
  static final standardDeviation =
      0.7; // Standard deviation of the normal distribution

  static double generateRandomNumber() {
    double u = 0, v = 0, s;

    while (u == 0) u = random.nextDouble(); // Ensure u is not zero
    while (v == 0) v = random.nextDouble(); // Ensure v is not zero

    s = sqrt(-2.0 * log(u)) * cos(2 * pi * v);

    // Scale and shift the random variable to the desired range (0 to 1)
    final randomNumber = mean + (standardDeviation * s);

    // Adjust the value if it falls outside the desired range (above 0)
    if (randomNumber < 0) {
      return 0;
    } else {
      return randomNumber;
    }
  }
}
