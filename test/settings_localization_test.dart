import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/l10n/app_translations.dart';
import 'package:satoshi_index/models/product.dart';
import 'package:satoshi_index/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': 'en',
      'currency': 'eur',
    });
    AppTranslations.setLanguage('en');
  });

  tearDown(() {
    AppTranslations.setLanguage('fr');
  });

  testWidgets('settings page is displayed in English', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('fr'), Locale('en')],
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
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Display currency'), findsOneWidget);
    expect(find.text('Custom prices'), findsOneWidget);
    expect(find.text('My products'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });
}
