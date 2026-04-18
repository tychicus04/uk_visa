import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/shared_prefs.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPrefs = await SharedPreferences.getInstance();
  SharedPrefsService.instance.setSharedPreferences(sharedPrefs);

  await SecureStorageService.instance.init();

  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
  } catch (e) {
    print('Database initialization failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Note: ATT prompt + MobileAds init are triggered from UKVisaTestApp.initState
  // after the first frame is rendered — iOS requires the app UI be on-screen
  // before requestTrackingAuthorization() will display the system prompt.
  runApp(
    const ProviderScope(
      child: UKVisaTestApp(),
    ),
  );
}
