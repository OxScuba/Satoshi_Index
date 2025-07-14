import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';

class OutilsPage extends StatefulWidget {
  final List<Product> products;
  final double bitcoinPriceEUR;
  final bool isDark;

  const OutilsPage({
    super.key,
    required this.products,
    required this.bitcoinPriceEUR,
    required this.isDark,
  });

  @override
  State<OutilsPage> createState() => _OutilsPageState();
}

class _OutilsPageState extends State<OutilsPage> {
  late Product selectedProduct;
  bool isEuroToBtc = true;
  final TextEditingController _controller = TextEditingController();
  String result = '';

  @override
  void initState() {
    super.initState();
    selectedProduct = widget.products.first;
  }

  void _convert() {
    final priceEuro = selectedProduct.data.last.priceEuro;
    final btcPrice = widget.bitcoinPriceEUR;
    final text = _controller.text.replaceAll(',', '.').replaceAll(' ', '');

    if (text.isEmpty || double.tryParse(text) == null) {
      setState(() => result = '');
      return;
    }

    if (isEuroToBtc) {
      // € -> ₿
      final amountEuro = double.parse(text);
      final btc = amountEuro / btcPrice;
      setState(() => result = btc.toStringAsFixed(8));
    } else {
      // ₿ -> €
      final btc = double.parse(text);
      final euro = btc * btcPrice;
      final nbItems = euro ~/ priceEuro;
      final itemEmoji = selectedProduct.emoji;
      final itemEuro = priceEuro.toStringAsFixed(2);
      final totalEuro = euro.toStringAsFixed(2);
      setState(
        () => result = "$nbItems x $itemEmoji à $itemEuro€ soit $totalEuro€",
      );
    }
  }

  String _groupBtcString(String btcString) {
    final parts = btcString.split('.');
    String beforeDecimal = parts[0];
    String afterDecimal =
        parts.length > 1 ? parts[1].padRight(8, '0') : '00000000';
    afterDecimal =
        "${afterDecimal.substring(0, 2)} ${afterDecimal.substring(2, 5)} ${afterDecimal.substring(5)}";
    return "$beforeDecimal.$afterDecimal";
  }

  Widget _formatBtc(String btcStr, bool isDark) {
    final grouped = _groupBtcString(btcStr);

    final plain = btcStr.replaceAll('.', '');
    final firstSigIndex = plain.indexOf(RegExp(r'[1-9]'));
    int spaceOffset = 0;
    int boldStart = 0;
    int found = 0;
    for (int i = 0; i < grouped.length; i++) {
      if (grouped[i] == ' ')
        spaceOffset++;
      else if (RegExp(r'[1-9]').hasMatch(grouped[i])) {
        found++;
        if (found == 1) {
          boldStart = i;
          break;
        }
      }
    }
    return RichText(
      text: TextSpan(
        text: grouped.substring(0, boldStart),
        style: TextStyle(
          fontSize: 20,
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
              fontSize: 20,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? Colors.black : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final btcPriceEUR = widget.bitcoinPriceEUR;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Outils"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/bitcoin.png',
                  height: 22,
                  width: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "= ${btcPriceEUR.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => '${match[1]} ')} €",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              "Convertisseur Bitcoin / Produits",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  "Produit : ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<Product>(
                  value: selectedProduct,
                  onChanged: (prod) {
                    if (prod != null) setState(() => selectedProduct = prod);
                    _convert();
                  },
                  items:
                      widget.products
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Text(
                                    p.emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(p.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => isEuroToBtc = true);
                      _convert();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEuroToBtc ? Colors.orange : Colors.grey[300],
                    ),
                    child: const Text(
                      "€ → ₿",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => isEuroToBtc = false);
                      _convert();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isEuroToBtc ? Colors.orange : Colors.grey[300],
                    ),
                    child: const Text(
                      "₿ → €",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isEuroToBtc ? "Montant en €" : "Montant en ₿",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    setState(() => result = '');
                  },
                ),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 26),
            Builder(
              builder: (context) {
                if (result.isEmpty) return Container();
                if (isEuroToBtc) {
                  return _formatBtc(result, widget.isDark);
                } else {
                  final btcValue = _controller.text
                      .replaceAll(',', '.')
                      .replaceAll(' ', '');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _formatBtc(
                        btcValue.isNotEmpty && double.tryParse(btcValue) != null
                            ? double.parse(btcValue).toStringAsFixed(8)
                            : "0.00000000",
                        widget.isDark,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          result,
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
