import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/product.dart';
import 'pages/product_detail_page.dart';
import 'pages/donation_page.dart';
import 'pages/logo_page.dart';
import 'pages/satoshi_page.dart';
import 'pages/bullbitcoin_page.dart';
import 'pages/settings_page.dart';
import 'pages/trading_chart_page.dart';
import 'services/bitcoin_service.dart';
import 'services/product_export_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  runApp(SatoshiIndexApp(isDarkMode: isDarkMode));
}

class SatoshiIndexApp extends StatefulWidget {
  final bool isDarkMode;

  const SatoshiIndexApp({super.key, required this.isDarkMode});

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
      home: HomePage(isDarkMode: isDarkMode, onThemeChanged: updateTheme),
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
  double? bitcoinPriceEUR;
  bool showSats = false;
  Timer? _timer;

  final List<Product> products = [
    baguetteProduct,
    gasolineProduct,
    cigaretteProduct,
    beerProduct,
    coffeeProduct,
    beefProduct,
    pizzaProduct,
    immobilierProduct,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    fetchBitcoinPrice();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetchBitcoinPrice();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSats = prefs.getBool('showSats') ?? false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchBitcoinPrice() async {
    final price = await BitcoinService.fetchBitcoinPriceEUR();
    setState(() {
      bitcoinPriceEUR = price;
    });
    await ProductExportService.exportProducts(products, price);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.orange),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            SettingsPage(onThemeChanged: widget.onThemeChanged),
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
                        MaterialPageRoute(builder: (_) => const LogoPage()),
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
            if (bitcoinPriceEUR != null)
              GestureDetector(
                onTap: () async {
                  await fetchBitcoinPrice();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TradingChartPage()),
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
                      "= ${bitcoinPriceEUR!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => '${match[1]} ')} €",
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      body:
          bitcoinPriceEUR == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final item = products[index];
                          final latestEntry = item.data.last;
                          final sats =
                              ((latestEntry.priceEuro / bitcoinPriceEUR!) *
                                      100000000)
                                  .round();
                          final formatted =
                              showSats
                                  ? formatSatsOnly(sats)
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
                              title: formatted,
                              subtitle: Text(
                                "${latestEntry.priceEuro.toStringAsFixed(2)} €",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetailPage(product: item),
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
                          Icons.favorite,
                          "Tip me",
                          const DonationPage(),
                        ),
                        const SizedBox(width: 8),
                        _buildImageNavButton(
                          'lib/assets/images/logo_bullbitcoin_2.png',
                          const BullBitcoinPage(),
                        ),
                        const SizedBox(width: 8),
                        _buildNavButton(
                          Icons.currency_bitcoin,
                          "Sat ⇄ BTC",
                          const SatoshiPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, Widget page) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildImageNavButton(String imagePath, Widget page) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Image.asset(imagePath, height: 40, fit: BoxFit.contain),
      ),
    );
  }

  Widget formatSatsOnly(int sats) {
    final formatted = sats.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return RichText(
      text: TextSpan(
        text: '',
        style: const TextStyle(fontSize: 18, color: Colors.black),
        children: [
          TextSpan(
            text: formatted,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const TextSpan(
            text: " sats",
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

  Widget formatSatsDisplay(int sats, bool isDark) {
    final str = (sats / 100000000).toStringAsFixed(8);
    final parts = str.split('.');
    final beforeDecimal = parts[0];
    final afterDecimal = parts[1];
    final grouped =
        "$beforeDecimal.${afterDecimal.substring(0, 2)} ${afterDecimal.substring(2, 5)} ${afterDecimal.substring(5)}";
    final plain = "$beforeDecimal.$afterDecimal";
    final firstSigIndex = plain.indexOf(RegExp(r'[1-9]'));

    int spaceOffset = 0;
    for (int i = 0; i < grouped.length && i < grouped.length - 2; i++) {
      if (grouped[i] == ' ') spaceOffset++;
      if (grouped[i] == plain[firstSigIndex]) break;
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
            text: " ₿",
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
