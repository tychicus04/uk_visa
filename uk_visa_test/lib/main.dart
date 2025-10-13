import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/shared_prefs.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefs = await SharedPreferences.getInstance();
  SharedPrefsService.instance.setSharedPreferences(sharedPrefs);

  await SecureStorageService.instance.init();

  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
  } catch (e) {
    print('Database initialization failed: $e');
  }

  // Initialize AdService
  try {
    await AdService.initialize();
    print('🎯 AdService initialized successfully');
  } catch (e) {
    print('🎯 AdService initialization failed: $e');
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

  runApp(
    const ProviderScope(
      child: UKVisaTestApp(),
    ),
  );
}