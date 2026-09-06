import 'package:flutter/material.dart';

/// Centralise color system
///
/// Palette: dark navy -> slate -> mauve -> dusty rose -> cream
/// (#22223B, #4A4E69, #9A8C98, #C9ADA7, #F2E9E4)
class AppPalette {
  static const Color backgroundColor = Color(0xFF22223B);
  static const Color lightBackgroundColor = Color(0xFFF2E9E4);
  static const Color lightBorderColor = Color(0xFFC9ADA7);
  static const Color gradient1 = Color(0xFF4A4E69);
  static const Color gradient2 = Color(0xFF9A8C98);
  static const Color gradient3 = Color(0xFFF2E9E4);
  static const Color borderColor = Color(0xFF4A4E69);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color greyColor = Colors.grey;
  static const Color errorColor = Colors.redAccent;
  static const Color transparantColor = Colors.transparent;

  /// Rotating backgrounds for blog list cards, drawn from the same swatch
  /// so they read as part of the palette instead of clashing with it.
  /// Restricted to the three darkest tones - the cards overlay white text
  /// (title/author/topic/like count), and the lighter two swatch tones
  /// (lightBorderColor, lightBackgroundColor) don't give white text enough
  /// contrast to stay readable.
  static const List<Color> blogCardColors = [backgroundColor, gradient1, gradient2];
}
