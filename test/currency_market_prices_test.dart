import 'package:flutter_test/flutter_test.dart';
import 'package:satoshi_index/models/app_currency.dart';
import 'package:satoshi_index/models/market_prices.dart';

void main() {
  final prices = MarketPrices(
    bitcoinPrices: {
      AppCurrency.eur: 60000,
      AppCurrency.usd: 70000,
      AppCurrency.hkd: 546000,
      AppCurrency.jpy: 10500000,
      AppCurrency.rub: 5500000,
      AppCurrency.ils: 228000,
    },
    ethereumPrices: {
      AppCurrency.eur: 1800,
      AppCurrency.usd: 2100,
      AppCurrency.hkd: 16380,
      AppCurrency.jpy: 315000,
      AppCurrency.rub: 165000,
      AppCurrency.ils: 6840,
    },
    fetchedAt: DateTime(2026, 7, 15),
  );

  test('reconnaît les nouvelles devises', () {
    expect(appCurrencyFromCode('hkd'), AppCurrency.hkd);
    expect(appCurrencyFromCode('RUB'), AppCurrency.rub);
    expect(appCurrencyFromCode('ils'), AppCurrency.ils);
    expect(appCurrencyFromCode('inconnue'), AppCurrency.eur);
  });

  test('convertit un prix en euros via le taux BTC', () {
    expect(prices.convertEuro(2.20, AppCurrency.hkd), closeTo(20.02, 0.001));
  });

  test('utilise le dollar comme ligne secondaire en EUR', () {
    expect(AppCurrency.eur.toolsSecondaryCurrency, AppCurrency.usd);
  });

  test('utilise la devise choisie comme ligne secondaire', () {
    expect(AppCurrency.rub.toolsSecondaryCurrency, AppCurrency.rub);
  });

  test('le yen utilise zéro décimale', () {
    expect(AppCurrency.jpy.fractionDigits, 0);
    expect(AppCurrency.hkd.fractionDigits, 2);
  });
}
