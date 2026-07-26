import 'package:flutter/material.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';

class NestDarkTheme extends NestTheme {
  NestDarkTheme(Color mainColor)
    : super(
        backC: const Color(0xFF0A0A0E),
        textC: const Color(0xFFFAFAFB),
        mainC: mainColor,
        secBackC: const Color(0xFF131319),
        inputBackC: const Color(0xFF1F1F25),
        secTextC: const Color(0xFFa4a4ab),
        borderC: const Color(0xFF2F2F32),
        errorC: const Color(0xFFFF2F3A),
        innerBorderC: const Color(0xFF1A1A1E),
      );
}
