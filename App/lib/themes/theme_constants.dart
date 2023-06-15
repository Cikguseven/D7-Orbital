import 'package:flutter/material.dart';
import 'package:my_first_flutter/utils.dart';

final NUS_ORANGE = Utils.createMaterialColor(const Color(0xFFEFC700));
final NUS_BLUE = Utils.createMaterialColor(const Color(0xFF003D7C));
final LIGHT_FRAME_BACKGROUND =
    Utils.createMaterialColor(const Color(0xFFF5F5F5));
final INPUT_BORDER_GREY = Utils.createMaterialColor(const Color(0xFFC9C9C9));

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: NUS_BLUE,
  scaffoldBackgroundColor: LIGHT_FRAME_BACKGROUND,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(NUS_BLUE),
      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
          foreground: Paint()..color = Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
    ),
  ),
  textTheme: const TextTheme(
    // Used for smaller main text
    headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),

    // Used for Main Text
    headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),

    // Used for smaller regular text
    titleSmall: TextStyle(color: Colors.black, fontSize: 14),

    // Used for regular text
    titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),

    // Used for text fields text
    labelSmall: TextStyle(color: Color(0xFF989898), fontSize: 14), // GREY
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8.0),
    ),
    filled: true,
    fillColor: Colors.white,
    outlineBorder: BorderSide(
      color: INPUT_BORDER_GREY,
    ),
    labelStyle: const TextStyle(color: Color(0xFF989898), fontSize: 14),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
);
