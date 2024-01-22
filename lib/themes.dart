import 'package:flutter/material.dart';

class HabitColors {
  static List<Color> lightColorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  HabitColors._();
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Color.fromARGB(255, 247, 253, 255),
    surface: Colors.white,
    surfaceTint: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    surface: Color.fromARGB(255, 25, 25, 25),
    surfaceTint: Color.fromARGB(255, 25, 25, 25),
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
);
