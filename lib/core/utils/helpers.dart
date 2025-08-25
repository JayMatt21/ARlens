import 'dart:math';

/// A collection of helper functions used across the app.
class Helpers {
  /// Formats a double value into a string with fixed decimal places.
  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Validates if the given string is a valid email.
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Converts degrees to radians.
  static double degToRad(double degrees) {
    return degrees * (pi / 180);
  }

  /// Converts radians to degrees.
  static double radToDeg(double radians) {
    return radians * (180 / pi);
  }

  /// Capitalizes the first letter of a string.
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Returns true if the string is null, empty, or only whitespace.
  static bool isNullOrEmpty(String? input) {
    return input == null || input.trim().isEmpty;
  }
}
