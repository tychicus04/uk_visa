import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../shared/providers/bilingual_provider.dart';
import '../shared/providers/locale_provider.dart';
import '../shared/providers/theme_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class UKVisaTestApp extends ConsumerWidget {
  const UKVisaTestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(bilingualProvider, (previous, next) {
      if (previous?.isEnabled != next.isEnabled) {
        print('Bilingual mode changed: ${next.isEnabled}');
      }
    });
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'UK Visa Test',
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: router,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('vi', ''), // Vietnamese
      ],
      locale: locale,

      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Prevent text scaling
          ),
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(bilingualProvider);
              return child!;
            },
          )
        ),
    );
  }
}