import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/models/app_currency.dart';

void main() {
  group('AppCurrency', () {
    test('utilise l’euro par défaut', () {
      expect(appCurrencyFromCode(null), AppCurrency.eur);
      expect(appCurrencyFromCode('inconnue'), AppCurrency.eur);
    });

    test('reconnaît le dollar américain', () {
      expect(appCurrencyFromCode('usd'), AppCurrency.usd);
      expect(AppCurrency.usd.symbol, r'$');
    });
  });
}
