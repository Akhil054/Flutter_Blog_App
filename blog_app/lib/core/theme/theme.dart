
import 'package:blog_app/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class AppTheme{

  /// Define the border as final so as to not define again & created border as function
  /// ([Color color =  AppPalette.borderColor]) is define as default colour is color : color is not taken by app
  static _border([Color color =  AppPalette.borderColor]) => OutlineInputBorder(
    borderSide: BorderSide(
    color: color,
    width: 3,
    ),
      borderRadius: BorderRadius.circular(10)
  );

  static final darkThemeMode = ThemeData.dark().copyWith(

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundColor,
    ),
    scaffoldBackgroundColor: AppPalette.backgroundColor,

    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(
        AppPalette.backgroundColor,
      ),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      /// TextField Form Deco
      contentPadding: const EdgeInsets.all(22),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPalette.gradient2),
      errorBorder: _border(AppPalette.errorColor),
    ),


  );
}