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

  test('Spanish translates interface labels and currencies', () {
    AppTranslations.setLanguage('es');
    expect(tr('Paramètres'), 'Ajustes');
    expect(tr('Dollar américain'), 'Dólar estadounidense');
    expect(tr('Pouvoir d’achat équivalent'), 'Poder adquisitivo equivalente');
  });

  test('official product names are localized by stable identifier', () {
    AppTranslations.setLanguage('en');
    expect(AppTranslations.productName('café', 'Café'), 'Coffee');
    expect(AppTranslations.productName('or', 'Or (1 g)'), 'Gold (1 g)');

    AppTranslations.setLanguage('es');
    expect(AppTranslations.productName('café', 'Café'), 'Café');
    expect(AppTranslations.productName('or', 'Or (1 g)'), 'Oro (1 g)');
  });

  test('unknown user content is not translated', () {
    AppTranslations.setLanguage('es');
    expect(tr('Mi croissant del domingo'), 'Mi croissant del domingo');
  });

  test('dynamic slots are translated', () {
    AppTranslations.setLanguage('en');
    expect(tr('Emplacement 2 sur 3'), 'Slot 2 of 3');

    AppTranslations.setLanguage('es');
    expect(tr('Emplacement 2 sur 3'), 'Espacio 2 de 3');
  });

  test('unsupported languages fall back to French', () {
    AppTranslations.setLanguage('de');
    expect(AppTranslations.languageCode, 'fr');
    expect(tr('Paramètres'), 'Paramètres');
  });
}
