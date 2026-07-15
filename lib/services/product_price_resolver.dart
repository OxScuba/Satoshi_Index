import '../models/app_currency.dart';
import '../models/market_prices.dart';
import '../models/product.dart';

class ProductPriceResolver {
  static double referencePriceEuro(Product product) {
    return product.data.last.priceEuro;
  }

  static double? customPriceEuro(
    Product product,
    Map<String, double> customPrices,
  ) {
    if (!product.allowCustomPrice) {
      return null;
    }

    final value = customPrices[product.id];

    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }

    return value;
  }

  static bool hasCustomPrice(
    Product product,
    Map<String, double> customPrices,
  ) {
    return customPriceEuro(product, customPrices) != null;
  }

  static double effectivePriceEuro({
    required Product product,
    required Map<String, double> customPrices,
    required MarketPrices marketPrices,
  }) {
    final liveAsset = product.liveMarketAsset;

    if (liveAsset != null) {
      return marketPrices.liveAssetPrice(liveAsset, AppCurrency.eur);
    }

    return customPriceEuro(product, customPrices) ??
        referencePriceEuro(product);
  }
}
