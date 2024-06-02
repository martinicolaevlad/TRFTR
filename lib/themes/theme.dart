import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:sh_app/themes/text_theme.dart";

class TAppTheme {
  static ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.white60 ,
      brightness: Brightness.light,
      textTheme: TTextTheme.lightTextTheme,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade800)
  );


  static ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.red,

      brightness: Brightness.dark,
      textTheme: TTextTheme.darkTextTheme,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade800)

  );
}