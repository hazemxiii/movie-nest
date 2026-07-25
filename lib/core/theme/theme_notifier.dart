import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/prefs.dart';
import 'package:movie_nest/core/theme/nest_dark_theme.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';

class ThemeNotifier extends AsyncNotifier<NestTheme> {
  @override
  FutureOr<NestTheme> build() async {
    final prefs = ref.read(prefsProvider);
    return await prefs.getTheme();
  }

  void setTheme(Color mainColor, bool isDark) {
    state = AsyncValue.data(
      isDark ? NestDarkTheme(mainColor) : NestDarkTheme(mainColor),
    );
  }
}

final themeProvider = AsyncNotifierProvider<ThemeNotifier, NestTheme>(
  ThemeNotifier.new,
);
