import 'app_currency.dart';

class MarketPrices {
  final double btcEur;
  final double btcUsd;
  final DateTime fetchedAt;
  final bool isFromCache;

  const MarketPrices({
    required this.btcEur,
    required this.btcUsd,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  double get eurToUsd => btcUsd / btcEur;

  double get usdToEur => btcEur / btcUsd;

  double bitcoinPrice(AppCurrency currency) {
    switch (currency) {
      case AppCurrency.eur:
        return btcEur;
      case AppCurrency.usd:
        return btcUsd;
    }
  }

  double convertEuro(double amountEuro, AppCurrency currency) {
    switch (currency) {
      case AppCurrency.eur:
        return amountEuro;
      case AppCurrency.usd:
        return amountEuro * eurToUsd;
    }
  }
}
