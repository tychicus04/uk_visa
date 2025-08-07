import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/shared_prefs.dart';
import 'core/storage/secure_storage.dart';
import 'core/utils/api_test_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final sharedPrefs = await SharedPreferences.getInstance();
  SharedPrefsService.instance.setSharedPreferences(sharedPrefs);

  // Initialize secure storage
  await SecureStorageService.instance.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Debug: Test API configuration in debug mode
  if (kDebugMode) {
    ApiTestHelper.printApiConfiguration();
    // Uncomment to run automatic connection tests on startup
    // await ApiTestHelper.runConnectionTests();
  }

  runApp(
    const ProviderScope(
      child: UKVisaTestApp(),
    ),
  );
}