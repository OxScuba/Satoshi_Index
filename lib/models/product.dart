import '../data/data_baguette.dart';
import '../data/data_beef.dart';
import '../data/data_beer.dart';
import '../data/data_bigmac.dart';
import '../data/data_cigarette.dart';
import '../data/data_coffee.dart';
import '../data/data_ethereum.dart';
import '../data/data_gasoline.dart';
import '../data/data_immobilier.dart';
import '../data/data_or.dart';
import '../data/data_pizza.dart';
import 'live_market_asset.dart';
import 'price_entry.dart';

class Product {
  final String id;
  final String name;
  final String emoji;
  final double staticPrice;
  final List<PriceEntry> data;
  final String? source;
  final LiveMarketAsset? liveMarketAsset;
  final bool allowCustomPrice;

  const Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.staticPrice,
    required this.data,
    this.source,
    this.liveMarketAsset,
    this.allowCustomPrice = false,
  });
}

final Product baguetteProduct = Product(
  id: 'baguette',
  name: 'Baguette',
  emoji: '🥖',
  staticPrice: 1.20,
  data: baguettePriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/000442423',
  allowCustomPrice: true,
);

final Product gasolineProduct = Product(
  id: 'essence',
  name: 'Essence SP95 (l)',
  emoji: '⛽️',
  staticPrice: 1.79,
  data: gasolinePriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/000849411',
  allowCustomPrice: true,
);

final Product cigaretteProduct = Product(
  id: 'cigarette',
  name: 'Paquet de Cigarette',
  emoji: '🚬',
  staticPrice: 10.00,
  data: cigarettePriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/001763852',
  allowCustomPrice: true,
);

final Product beerProduct = Product(
  id: 'bière',
  name: 'Bière (50cl)',
  emoji: '🍺',
  staticPrice: 5.10,
  data: beerPriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/000806957',
  allowCustomPrice: true,
);

final Product coffeeProduct = Product(
  id: 'café',
  name: 'Café',
  emoji: '☕',
  staticPrice: 1.20,
  data: coffeePriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/001763484',
  allowCustomPrice: true,
);

final Product beefProduct = Product(
  id: 'boeuf',
  name: 'Boeuf (kg)',
  emoji: '🥩',
  staticPrice: 23.70,
  data: beefPriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/000442437',
  allowCustomPrice: true,
);

final Product pizzaProduct = Product(
  id: 'pizza',
  name: 'Pizza',
  emoji: '🍕',
  staticPrice: 13.24,
  data: pizzaPriceData,
  allowCustomPrice: true,
);

final Product bigMacProduct = Product(
  id: 'big_mac',
  name: 'Big Mac (zone euro)',
  emoji: '🍔',
  staticPrice: 6.08,
  data: bigMacPriceData,
  source: 'https://www.economist.com/interactive/big-mac-index',
  allowCustomPrice: true,
);

final Product goldProduct = Product(
  id: 'or',
  name: 'Or (1 g)',
  emoji: '🪙',
  staticPrice: 125.33,
  data: goldPriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/010002100',
  allowCustomPrice: true,
);

final Product ethereumProduct = Product(
  id: 'ethereum',
  name: 'Ethereum (1 ETH)',
  emoji: '💩',
  staticPrice: 1678.72,
  data: ethereumPriceData,
  source: 'https://www.coingecko.com/en/coins/ethereum',
  liveMarketAsset: LiveMarketAsset.ethereum,
);

final Product immobilierProduct = Product(
  id: 'immobilier',
  name: 'Immobilier (m2)',
  emoji: '🏠',
  staticPrice: 2908.50,
  data: immobilierPriceData,
  source: 'https://www.insee.fr/fr/statistiques/serie/010001868',
);
