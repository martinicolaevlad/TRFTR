import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";


class TTextTheme {

  static TextTheme lightTextTheme = TextTheme(
      displayLarge: GoogleFonts.roboto(
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.roboto(
        color: Colors.red.shade800,

      )
  );

  static TextTheme darkTextTheme = TextTheme(
      displayLarge: GoogleFonts.roboto(
        color: Colors.white70,
      )
  );
}