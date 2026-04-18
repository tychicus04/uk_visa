import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../shared/providers/theme_provider.dart';
import 'router_simple.dart';
import 'theme/app_theme.dart';

class UKVisaTestApp extends ConsumerStatefulWidget {
  const UKVisaTestApp({super.key});

  @override
  ConsumerState<UKVisaTestApp> createState() => _UKVisaTestAppState();
}

class _UKVisaTestAppState extends ConsumerState<UKVisaTestApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initTrackingAndAds();
    });
  }

  Future<void> _initTrackingAndAds() async {
    if (Platform.isIOS) {
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } catch (e) {
        print('🎯 ATT request failed: $e');
      }
    }

    try {
      await MobileAds.instance.initialize();
      print('🎯 Mobile Ads SDK initialized successfully');
    } catch (e) {
      print('🎯 Mobile Ads SDK initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'UK Visa Test',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: child!,
      ),
    );
  }
}
