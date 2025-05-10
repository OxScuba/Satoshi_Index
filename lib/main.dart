import 'dart:async';
import 'package:flutter/material.dart';
import 'models/product.dart';
import 'pages/product_detail_page.dart';
import 'pages/donation_page.dart';
import 'pages/logo_page.dart';
import 'pages/satoshi_page.dart';
import 'pages/bullbitcoin_page.dart';
import 'services/bitcoin_service.dart';
import 'services/product_export_service.dart';

void main() {
  runApp(SatoshiIndexApp());
}

class SatoshiIndexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satoshi Index',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? bitcoinPriceEUR;
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
    fetchBitcoinPrice();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetchBitcoinPrice();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                onTap: fetchBitcoinPrice,
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
                      "= ${bitcoinPriceEUR!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => "${match[1]} ")} €",
                      style: const TextStyle(fontSize: 14, color: Colors.black),
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
                          final formattedSats = formatSatsDisplay(sats);

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
                              title: formattedSats,
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
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DonationPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                            label: const Text("Tip me"),
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BullBitcoinPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            label: const Text("Buy Bitcoin"),
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SatoshiPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.currency_bitcoin,
                              color: Colors.white,
                            ),
                            label: const Text("Sat ⇄ BTC"),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget formatSatsDisplay(int sats) {
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
        style: const TextStyle(fontSize: 18, color: Colors.black),
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
