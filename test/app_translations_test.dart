import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/l10n/app_translations.dart';

void main() {
  tearDown(() {
    AppTranslations.setLanguage('fr');
  });

  test('French remains the fallback language', () {
    AppTranslations.setLanguage('fr');
    expect(tr('Paramètres'), 'Paramètres');
  });

  test('English translates interface labels and currencies', () {
    AppTranslations.setLanguage('en');
    expect(tr('Paramètres'), 'Settings');
    expect(tr('Dollar américain'), 'US Dollar');
    expect(tr('Pouvoir d’achat équivalent'), 'Equivalent purchasing power');
  });

  test('official product names are localized by stable identifier', () {
    AppTranslations.setLanguage('en');
    expect(AppTranslations.productName('café', 'Café'), 'Coffee');
    expect(AppTranslations.productName('or', 'Or (1 g)'), 'Gold (1 g)');
  });

  test('unknown user content is not translated', () {
    AppTranslations.setLanguage('en');
    expect(tr('Mon croissant du dimanche'), 'Mon croissant du dimanche');
  });

  test('dynamic slots are translated', () {
    AppTranslations.setLanguage('en');
    expect(tr('Emplacement 2 sur 3'), 'Slot 2 of 3');
  });
}
