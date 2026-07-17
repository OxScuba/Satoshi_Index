import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/l10n/app_translations.dart';
import 'package:satoshi_index/models/product.dart';
import 'package:satoshi_index/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    AppTranslations.setLanguage('fr');
  });

  testWidgets('settings page is displayed in English', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': 'en',
      'currency': 'eur',
    });
    AppTranslations.setLanguage('en');

    await tester.pumpWidget(_settingsApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Display currency'), findsOneWidget);
    expect(find.text('Custom prices'), findsOneWidget);
    expect(find.text('My products'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('settings page is displayed in Spanish', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': 'es',
      'currency': 'eur',
    });
    AppTranslations.setLanguage('es');

    await tester.pumpWidget(_settingsApp(const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Modo oscuro'), findsOneWidget);
    expect(find.text('Moneda de visualización'), findsOneWidget);
    expect(find.text('Precios personalizados'), findsOneWidget);
    expect(find.text('Mis productos'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });
}

Widget _settingsApp(Locale locale) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('fr'), Locale('en'), Locale('es')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: SettingsPage(
      onThemeChanged: (_) {},
      onLanguageChanged: (_) {},
      products: const <Product>[],
    ),
  );
}
