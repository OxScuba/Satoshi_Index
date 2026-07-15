import 'app_currency.dart';
import 'live_market_asset.dart';

class MarketPrices {
  final Map<AppCurrency, double> bitcoinPrices;
  final Map<AppCurrency, double> ethereumPrices;
  final DateTime fetchedAt;
  final bool isFromCache;

  MarketPrices({
    required Map<AppCurrency, double> bitcoinPrices,
    required Map<AppCurrency, double> ethereumPrices,
    required this.fetchedAt,
    this.isFromCache = false,
  }) : bitcoinPrices = Map<AppCurrency, double>.unmodifiable(bitcoinPrices),
       ethereumPrices = Map<AppCurrency, double>.unmodifiable(ethereumPrices);

  double get btcEur => bitcoinPrice(AppCurrency.eur);

  double get btcUsd => bitcoinPrice(AppCurrency.usd);

  double get ethEur => ethereumPrice(AppCurrency.eur);

  double get ethUsd => ethereumPrice(AppCurrency.usd);

  double get eurToUsd {
    return conversionRate(from: AppCurrency.eur, to: AppCurrency.usd);
  }

  double get usdToEur {
    return conversionRate(from: AppCurrency.usd, to: AppCurrency.eur);
  }

  double get ethBtc {
    final bitcoinEuro = btcEur;
    final ethereumEuro = ethEur;

    if (bitcoinEuro <= 0 || ethereumEuro <= 0) {
      return 0;
    }

    return ethereumEuro / bitcoinEuro;
  }

  double get ethSats => ethBtc * 100000000;

  double bitcoinPrice(AppCurrency currency) {
    return bitcoinPrices[currency] ?? 0;
  }

  double ethereumPrice(AppCurrency currency) {
    return ethereumPrices[currency] ?? 0;
  }

  double liveAssetPrice(LiveMarketAsset asset, AppCurrency currency) {
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

  double conversionRate({required AppCurrency from, required AppCurrency to}) {
    if (from == to) {
      return 1;
    }

    final fromPrice = bitcoinPrice(from);
    final toPrice = bitcoinPrice(to);

    if (fromPrice <= 0 || toPrice <= 0) {
      return 0;
    }

    return toPrice / fromPrice;
  }

  double convert({
    required double amount,
    required AppCurrency from,
    required AppCurrency to,
  }) {
    if (from == to) {
      return amount;
    }

    final rate = conversionRate(from: from, to: to);

    if (rate <= 0) {
      return 0;
    }

    return amount * rate;
  }

  double convertEuro(double amountEuro, AppCurrency currency) {
    return convert(amount: amountEuro, from: AppCurrency.eur, to: currency);
  }

  Map<String, double> get bitcoinPricesByCode {
    return {
      for (final entry in bitcoinPrices.entries) entry.key.code: entry.value,
    };
  }

  Map<String, double> get ethereumPricesByCode {
    return {
      for (final entry in ethereumPrices.entries) entry.key.code: entry.value,
    };
  }
}
