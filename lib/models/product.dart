import 'price_entry.dart';
import '../data/data_baguette.dart';
import '../data/data_gasoline.dart';
import '../data/data_cigarette.dart';
import '../data/data_beer.dart';
import '../data/data_coffee.dart';
import '../data/data_beef.dart';
import '../data/data_pizza.dart';
import '../data/data_immobilier.dart';

class Product {
  final String id;
  final String name;
  final String emoji;
  final double staticPrice;
  final List<PriceEntry> data;
  final String? source;

  Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.staticPrice,
    required this.data,
    this.source,
  });
}

final Product baguetteProduct = Product(
  id: "baguette",
  name: "Baguette",
  emoji: "🥖",
  staticPrice: 1.20,
  data: baguettePriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/000442423",
);

final Product gasolineProduct = Product(
  id: "essence",
  name: "Essence SP95 (l)",
  emoji: "⛽️",
  staticPrice: 1.79,
  data: gasolinePriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/000849411",
);

final Product cigaretteProduct = Product(
  id: "cigarette",
  name: "Paquet de Cigarette",
  emoji: "🚬",
  staticPrice: 10.00,
  data: cigarettePriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/001763852",
);

final Product beerProduct = Product(
  id: "bière",
  name: "Bière (50cl)",
  emoji: "🍺",
  staticPrice: 5.10,
  data: beerPriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/000806957",
);

final Product coffeeProduct = Product(
  id: "café",
  name: "Café",
  emoji: "☕",
  staticPrice: 1.20,
  data: coffeePriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/001763484",
);

final Product beefProduct = Product(
  id: "boeuf",
  name: "Boeuf (kg)",
  emoji: "🥩",
  staticPrice: 23.70,
  data: beefPriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/000442437",
);

final Product pizzaProduct = Product(
  id: "pizza",
  name: "Pizza",
  emoji: "🍕",
  staticPrice: 13.60,
  data: pizzaPriceData,
  source: null,
);

final Product immobilierProduct = Product(
  id: "immobilier",
  name: "Immobilier (m2)",
  emoji: "🏠",
  staticPrice: 13.60,
  data: immobilierPriceData,
  source: "https://www.insee.fr/fr/statistiques/serie/010001868",
);
