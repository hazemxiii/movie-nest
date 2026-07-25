import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/nest_dark_theme.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Prefs() {
    _prefs = SharedPreferencesAsync();
  }
  late final SharedPreferencesAsync _prefs;

  Future<void> setTheme(bool isDark, Color mainColor) async {
    await _prefs.setBool('theme', isDark);
    await _prefs.setInt('mainColor', mainColor.toARGB32());
  }

  Future<NestTheme> getTheme() async {
    final isDark = await _prefs.getBool('theme') ?? true;
    final mainColor = Color(await _prefs.getInt('mainColor') ?? 0xFFFF007F);
    return isDark ? NestDarkTheme(mainColor) : NestDarkTheme(mainColor);
  }
}

final prefsProvider = Provider<Prefs>((ref) => Prefs());
