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

  /// Rotating backgrounds for blog list cards - every swatch tone EXCEPT
  /// whichever one is currently the scaffold's own background, so a card
  /// never blends invisibly into the page behind it. Two lists because that
  /// "own background" tone differs by theme: backgroundColor (navy) in dark
  /// mode, lightBackgroundColor (cream) in light mode. backgroundColor
  /// itself is untouched - only which colors the *card* picks from changes.
  static const List<Color> blogCardColorsDark = [
    gradient1, // slate
    gradient2, // mauve
    lightBorderColor, // dusty rose
    lightBackgroundColor, // cream
  ];

  static const List<Color> blogCardColorsLight = [
    backgroundColor, // navy
    gradient1, // slate
    gradient2, // mauve
    lightBorderColor, // dusty rose
  ];

  /// The two lightest swatch tones (dusty rose, cream) don't give white
  /// overlay text enough contrast, so cards using them need dark text
  /// instead - everything else is dark enough for white text.
  static Color onBlogCard(Color cardColor) {
    return (cardColor == lightBorderColor || cardColor == lightBackgroundColor)
        ? blackColor
        : whiteColor;
  }
}
