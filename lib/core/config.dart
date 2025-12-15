import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      // Production URL
      return 'https://diu-connect-backend.onrender.com/api';
    } else {
      // Local Development URLs
      if (kIsWeb) {
        return 'http://localhost:3000/api';
      } else if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      } else {
        // Fallback for iOS Simulator / Desktop
        return 'http://localhost:3000/api';
      }
    }
  }
}
