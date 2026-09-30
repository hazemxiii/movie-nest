import 'dart:io';

import 'package:flutter/foundation.dart';

class NestPlatform {
  static bool get isMobile {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
  }

  static bool get isWindows {
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows;
  }
}
