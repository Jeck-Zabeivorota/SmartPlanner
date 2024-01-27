import 'package:flutter/material.dart';

abstract class _IColorsSet {
  abstract final Color text, text2, second, shadow, background, background2;
}

class _LigthColors implements _IColorsSet {
  @override
  final Color text = const Color.fromARGB(255, 35, 35, 35);
  @override
  final Color text2 = const Color.fromARGB(255, 165, 165, 165);
  @override
  final Color second = const Color.fromARGB(255, 245, 245, 245);
  @override
  final Color shadow = const Color.fromARGB(8, 0, 0, 0);
  @override
  final Color background = Colors.white;
  @override
  final Color background2 = const Color.fromARGB(255, 252, 252, 252);
}

class _DarkColors implements _IColorsSet {
  @override
  final Color text = Colors.white;
  @override
  final Color text2 = const Color.fromARGB(255, 125, 145, 165);
  @override
  final Color second = const Color.fromARGB(255, 40, 55, 70);
  @override
  final Color shadow = const Color.fromARGB(30, 0, 0, 0);
  @override
  final Color background = const Color.fromARGB(255, 25, 35, 45);
  @override
  final Color background2 = const Color.fromARGB(255, 30, 40, 55);
}

/// Class for storing application colors
abstract class ViewColors {
  static _IColorsSet _data = _LigthColors();
  static bool get isDarkMode => _data.runtimeType == _DarkColors;

  static set isDarkMode(bool value) =>
      _data = value ? _DarkColors() : _LigthColors();

  static Color get accent => Colors.blue;
  static Color get text => _data.text;
  static Color get text2 => _data.text2;
  static Color get second => _data.second;
  static Color get shadow => _data.shadow;
  static Color get background => _data.background;
  static Color get background2 => _data.background2;
}
