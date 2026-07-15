import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_currency.dart';
import 'models/market_prices.dart';
import 'models/product.dart';
import 'models/user_product.dart';
import 'pages/bullbitcoin_page.dart';
import 'pages/logo_page.dart';
import 'pages/outils_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/satoshi_page.dart';
import 'pages/settings_page.dart';
import 'pages/trading_chart_page.dart';
import 'pages/user_products_page.dart';
import 'services/bitcoin_service.dart';
import 'services/custom_price_service.dart';
import 'services/product_export_service.dart';
import 'services/product_price_resolver.dart';
import 'services/user_product_price_resolver.dart';
import 'services/user_product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(SatoshiIndexApp(isDarkMode: isDarkMode));
}

class SatoshiIndexApp extends StatefulWidget {
  final bool isDarkMode;

  const SatoshiIndexApp({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<SatoshiIndexApp> createState() => _SatoshiIndexAppState();
}

class _SatoshiIndexAppState extends State<SatoshiIndexApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void updateTheme(bool darkMode) {
    setState(() {
      isDarkMode = darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satoshi Index',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData.dark(),
      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeChanged: updateTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MarketPrices? marketPrices;
  AppCurrency selectedCurrency = AppCurrency.eur;
  String? marketPriceError;

  bool showSats = false;
  Map<String, double> customPrices = <String, double>{};
  List<UserProduct?> userProductSlots = List<UserProduct?>.filled(
    UserProduct.slotCount,
    null,
  );
  Timer? _timer;

  final List<Product> products = [
    baguetteProduct,
    gasolineProduct,
    cigaretteProduct,
    beerProduct,
    coffeeProduct,
    beefProduct,
    pizzaProduct,
    bigMacProduct,
    goldProduct,
    ethereumProduct,
    immobilierProduct,
  ];

  @override
  void initState() {
    super.initState();

    _loadSettings();
    fetchMarketPrices();

    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      fetchMarketPrices();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedCustomPrices =
        await CustomPriceService.loadPrices();
    final loadedUserProductSlots =
        await UserProductService.loadSlots();

    if (!mounted) return;

    setState(() {
      showSats = prefs.getBool('showSats') ?? false;
      selectedCurrency = appCurrencyFromCode(
        prefs.getString('currency'),
      );
      customPrices = loadedCustomPrices;
      userProductSlots = loadedUserProductSlots;
    });

    await _exportAndSyncWidgets();
  }

  Future<void> fetchMarketPrices() async {
    try {
      final prices = await BitcoinService.fetchMarketPrices();

      if (!mounted) return;

      setState(() {
        marketPrices = prices;
        marketPriceError = null;
      });

      await _exportAndSyncWidgets();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        marketPriceError = error.toString();
      });
    }
  }


  Future<void> _exportAndSyncWidgets() async {
    final prices = marketPrices;

    if (prices == null) {
      return;
    }

    await ProductExportService.exportProducts(
      products,
      prices,
      selectedCurrency: selectedCurrency,
      showSats: showSats,
      customPrices: customPrices,
      userProducts: userProductSlots.whereType<UserProduct>().toList(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    final prices = marketPrices;
    final currencySymbol = selectedCurrency.symbol;
    final bitcoinPrice = prices?.bitcoinPrice(selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.orange,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      onThemeChanged: widget.onThemeChanged,
                      products: products,
                    ),
                  ),
                );

                await _loadSettings();
              },
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LogoPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Satoshi Index',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            if (bitcoinPrice != null)
              GestureDetector(
                onTap: () async {
                  await fetchMarketPrices();

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TradingChartPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/images/bitcoin.png',
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '= ${_formatFiat(bitcoinPrice, selectedCurrency)} $currencySymbol',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: prices == null
          ? Center(
              child: marketPriceError == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 42,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Impossible de charger le cours du Bitcoin.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            marketPriceError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: fetchMarketPrices,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          products.length + UserProduct.slotCount,
                      itemBuilder: (context, index) {
                        if (index >= products.length) {
                          final slotIndex = index - products.length;

                          return _buildUserProductSlotCard(
                            slotIndex: slotIndex,
                            prices: prices,
                            isDark: isDark,
                          );
                        }

                        final item = products[index];

                        final effectivePriceEuro =
                            ProductPriceResolver.effectivePriceEuro(
                          product: item,
                          customPrices: customPrices,
                          marketPrices: prices,
                        );

                        final hasCustomPrice =
                            ProductPriceResolver.hasCustomPrice(
                          item,
                          customPrices,
                        );

                        final displayedPrice = prices.convertEuro(
                          effectivePriceEuro,
                          selectedCurrency,
                        );

                        final displayedBitcoinPrice = prices.bitcoinPrice(
                          selectedCurrency,
                        );

                        final sats =
                            ((displayedPrice / displayedBitcoinPrice) *
                                    100000000)
                                .round();

                        final formatted = showSats
                            ? formatSatsOnly(sats, isDark)
                            : formatSatsDisplay(sats, isDark);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                formatted,
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text.rich(
                                TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                  children: [
                                    TextSpan(
                                      text:
                                          '${_formatFiat(displayedPrice, selectedCurrency)} '
                                          '$currencySymbol',
                                    ),
                                    if (hasCustomPrice)
                                      const TextSpan(
                                        text: ' · personnalisé',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(
                                    product: item,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavButton(
                        Icons.build,
                        'Outils',
                        OutilsPage(
                          products: products,
                          marketPrices: prices,
                          customPrices: customPrices,
                          userProducts:
                              userProductSlots.whereType<UserProduct>().toList(),
                          selectedCurrency: selectedCurrency,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildImageNavButton(
                        'lib/assets/images/logo_bullbitcoin_2.png',
                        const BullBitcoinPage(),
                      ),
                      const SizedBox(width: 8),
                      _buildNavButton(
                        Icons.currency_bitcoin,
                        'Sat ⇄ BTC',
                        const SatoshiPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _openUserProductsPage(int slotIndex) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProductsPage(
          defaultCurrency: selectedCurrency,
          initialSlotIndex: slotIndex,
        ),
      ),
    );

    await _loadSettings();
  }

  Widget _buildUserProductSlotCard({
    required int slotIndex,
    required MarketPrices prices,
    required bool isDark,
  }) {
    final product = userProductSlots[slotIndex];

    if (product == null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.orange.withValues(alpha: 0.45),
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            child: Icon(Icons.add),
          ),
          title: const Text(
            'Ajouter un produit personnel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Emplacement ${slotIndex + 1} sur ${UserProduct.slotCount}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _openUserProductsPage(slotIndex);
          },
        ),
      );
    }

    final displayedPrice =
        UserProductPriceResolver.priceInCurrency(
      product: product,
      targetCurrency: selectedCurrency,
      marketPrices: prices,
    );
    final sats = UserProductPriceResolver.priceInSats(
      product: product,
      marketPrices: prices,
    ).round();
    final formatted = showSats
        ? formatSatsOnly(sats, isDark)
        : formatSatsDisplay(sats, isDark);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.orange.withValues(alpha: 0.22),
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Text(
          product.emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            formatted,
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text:
                      '${_formatFiat(displayedPrice, selectedCurrency)} '
                      '${selectedCurrency.symbol}',
                ),
                const TextSpan(
                  text: ' · personnel',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () {
          _openUserProductsPage(slotIndex);
        },
      ),
    );
  }

  String _formatFiat(
    double value,
    AppCurrency currency,
  ) {
    final fixed = value.toStringAsFixed(
      currency.fractionDigits,
    );
    final parts = fixed.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    if (currency.fractionDigits == 0) {
      return integerPart;
    }

    return '$integerPart.${parts[1]}';
  }

  Widget _buildNavButton(
    IconData icon,
    String label,
    Widget page,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildImageNavButton(
    String imagePath,
    Widget page,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Image.asset(
          imagePath,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget formatSatsOnly(
    int sats,
    bool isDark,
  ) {
    final formatted = sats.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );

    return RichText(
      text: TextSpan(
        text: '',
        style: TextStyle(
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
        ),
        children: [
          TextSpan(
            text: formatted,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const TextSpan(
            text: ' sats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget formatSatsDisplay(
    int sats,
    bool isDark,
  ) {
    final str = (sats / 100000000).toStringAsFixed(8);
    final parts = str.split('.');
    final beforeDecimal = parts[0];
    final afterDecimal = parts[1];

    final grouped =
        '$beforeDecimal.'
        '${afterDecimal.substring(0, 2)} '
        '${afterDecimal.substring(2, 5)} '
        '${afterDecimal.substring(5)}';

    final plain = '$beforeDecimal.$afterDecimal';
    final firstSigIndex = plain.indexOf(RegExp(r'[1-9]'));

    if (firstSigIndex == -1) {
      return RichText(
        text: TextSpan(
          text: grouped,
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
          children: const [
            TextSpan(
              text: ' ₿',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    int spaceOffset = 0;

    for (int i = 0; i < grouped.length && i < grouped.length - 2; i++) {
      if (grouped[i] == ' ') {
        spaceOffset++;
      }

      if (grouped[i] == plain[firstSigIndex]) {
        break;
      }
    }

    final boldStart = firstSigIndex + spaceOffset;

    return RichText(
      text: TextSpan(
        text: grouped.substring(0, boldStart),
        style: TextStyle(
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
        ),
        children: [
          TextSpan(
            text: grouped.substring(boldStart),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const TextSpan(
            text: ' ₿',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
