import '../models/app_currency.dart';
import '../models/market_prices.dart';
import '../models/user_product.dart';

class UserProductPriceResolver {
  static const double satsPerBitcoin = 100000000;

  static double priceInBitcoin({
    required UserProduct product,
    required MarketPrices marketPrices,
  }) {
    final bitcoinInSourceCurrency = marketPrices.bitcoinPrice(product.currency);

    if (bitcoinInSourceCurrency <= 0) {
      return 0;
    }

    return product.price / bitcoinInSourceCurrency;
  }

  static double priceInSats({
    required UserProduct product,
    required MarketPrices marketPrices,
  }) {
    return priceInBitcoin(product: product, marketPrices: marketPrices) *
        satsPerBitcoin;
  }

  static double priceInCurrency({
    required UserProduct product,
    required AppCurrency targetCurrency,
    required MarketPrices marketPrices,
  }) {
    if (targetCurrency == product.currency) {
      return product.price;
    }

    final bitcoinValue = priceInBitcoin(
      product: product,
      marketPrices: marketPrices,
    );
    final bitcoinInTargetCurrency = marketPrices.bitcoinPrice(targetCurrency);

    if (bitcoinValue <= 0 || bitcoinInTargetCurrency <= 0) {
      return 0;
    }

    return bitcoinValue * bitcoinInTargetCurrency;
  }

  static double priceInEuro({
    required UserProduct product,
    required MarketPrices marketPrices,
  }) {
    return priceInCurrency(
      product: product,
      targetCurrency: AppCurrency.eur,
      marketPrices: marketPrices,
    );
  }
}
