import 'app_currency.dart';
import 'live_market_asset.dart';

class MarketPrices {
  final double btcEur;
  final double btcUsd;
  final double ethEur;
  final double ethUsd;
  final DateTime fetchedAt;
  final bool isFromCache;

  const MarketPrices({
    required this.btcEur,
    required this.btcUsd,
    required this.ethEur,
    required this.ethUsd,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  double get eurToUsd => btcUsd / btcEur;

  double get usdToEur => btcEur / btcUsd;

  double get ethBtc => ethEur / btcEur;

  double get ethSats => ethBtc * 100000000;

  double bitcoinPrice(AppCurrency currency) {
    switch (currency) {
      case AppCurrency.eur:
        return btcEur;
      case AppCurrency.usd:
        return btcUsd;
    }
  }

  double ethereumPrice(AppCurrency currency) {
    switch (currency) {
      case AppCurrency.eur:
        return ethEur;
      case AppCurrency.usd:
        return ethUsd;
    }
  }

  double liveAssetPrice(
    LiveMarketAsset asset,
    AppCurrency currency,
  ) {
    switch (asset) {
      case LiveMarketAsset.ethereum:
        return ethereumPrice(currency);
    }
  }

  double liveAssetPriceInBitcoin(LiveMarketAsset asset) {
    switch (asset) {
      case LiveMarketAsset.ethereum:
        return ethBtc;
    }
  }

  double liveAssetPriceInSats(LiveMarketAsset asset) {
    return liveAssetPriceInBitcoin(asset) * 100000000;
  }

  double convertEuro(
    double amountEuro,
    AppCurrency currency,
  ) {
    switch (currency) {
      case AppCurrency.eur:
        return amountEuro;
      case AppCurrency.usd:
        return amountEuro * eurToUsd;
    }
  }
}
