import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../models/price_entry.dart';
import '../services/bitcoin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double? bitcoinPriceEUR;
  bool showSats = false;

  @override
  void initState() {
    super.initState();
    fetchBitcoinPrice();
    loadSettings();
  }

  Future<void> fetchBitcoinPrice() async {
    final price = await BitcoinService.fetchBitcoinPriceEUR();
    setState(() => bitcoinPriceEUR = price);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => showSats = prefs.getBool('showSats') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final entries = product.data.where((e) => e.priceSats != null).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final euroPrices = entries.map((e) => e.priceEuro).toList();
    final priceBTC =
        entries.map((e) => e.priceEuro / (e.btcPrice ?? 1)).toList();
    final logPriceBTC = priceBTC.map((p) => log(p) / ln10).toList();

    final minYEuro = euroPrices.reduce(min) * 0.8;
    final maxYEuro = euroPrices.reduce(max) * 1.2;
    final minYBTC = logPriceBTC.reduce(min) - 0.2;
    final maxYBTC = logPriceBTC.reduce(max) + 0.2;

    final euroSpots =
        entries
            .map(
              (e) => FlSpot(_quarterToDouble(e.year, e.quarter), e.priceEuro),
            )
            .toList();

    final btcSpots =
        entries.map((e) {
          final btc = e.btcPrice ?? 1;
          final price = e.priceEuro / btc;
          return FlSpot(_quarterToDouble(e.year, e.quarter), log(price) / ln10);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name),
            if (bitcoinPriceEUR != null)
              Row(
                children: [
                  Image.asset(
                    'lib/assets/images/bitcoin.png',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "= ${bitcoinPriceEUR!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => "${m[1]} ")} €",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Prix du produit en BTC", Colors.orange.shade700),
            _buildChart(btcSpots, minYBTC, maxYBTC, true),
            const SizedBox(height: 24),
            _buildTitle("Prix du produit en €", Colors.green.shade700),
            _buildChart(euroSpots, minYEuro, maxYEuro, false),
            const SizedBox(height: 24),
            if (product.source != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "Les données affichées sont mises à jour chaque trimestre et proviennent de sources publiques comme l’INSEE pour les prix à la consommation, ou CoinGecko pour le cours du bitcoin. ",
                      ),
                      const TextSpan(
                        text:
                            "Dans certains cas, les données brutes sont ajustées pour correspondre à une unité plus parlante. ",
                      ),
                      const TextSpan(
                        text:
                            "Par exemple, le prix du pain est calculé à partir d’un tarif au kilo, ramené au prix moyen d’une baguette de 250g. ",
                      ),
                      const TextSpan(
                        text:
                            "De même, le prix de la bière correspond à une pinte (50cl), alors que la source INSEE indique le prix pour un demi (25cl). ",
                      ),
                      const TextSpan(text: "Voir la "),
                      TextSpan(
                        text: "source",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(product.source!);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                      ),
                      const TextSpan(text: " pour plus de détails."),
                    ],
                  ),
                ),
              ),
            const Text(
              "Données détaillées",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildTable(entries, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
    );
  }

  Widget _buildChart(List<FlSpot> spots, double minY, double maxY, bool isBTC) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: spots.first.x,
          maxX: spots.last.x,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: isBTC ? Colors.orange : Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final value = isBTC ? pow(10, spot.y) : spot.y;
                  final text =
                      isBTC
                          ? "${(value as double).toStringAsFixed(8)} BTC"
                          : "${value.toStringAsFixed(2)} €";
                  return LineTooltipItem(
                    text,
                    TextStyle(color: isBTC ? Colors.orange : Colors.green),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Text("Année"),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget:
                    (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 6),
                    ),
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(isBTC ? "Prix en BTC (log)" : "Prix en €"),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: isBTC ? 56 : 48,
                getTitlesWidget: (value, _) {
                  if (isBTC) {
                    if (value % 1 != 0) return const SizedBox.shrink();
                    final btc = pow(10, value) as double;
                    return Text(
                      btc.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), ''),
                    );
                  } else {
                    return Text(
                      "${value.toStringAsFixed(2)}€",
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildTable(List<PriceEntry> entries, bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 32,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 28,
          columns: const [
            DataColumn(label: Text("Année", style: TextStyle(fontSize: 12))),
            DataColumn(
              label: Text("Prix en €", style: TextStyle(fontSize: 12)),
            ),
            DataColumn(
              label: Text("Prix du BTC", style: TextStyle(fontSize: 12)),
            ),
            DataColumn(
              label: Text("Prix en Sats", style: TextStyle(fontSize: 12)),
            ),
          ],
          rows:
              entries.reversed.map((e) {
                final btcPrice = e.btcPrice ?? 0;
                final priceBTC = btcPrice > 0 ? e.priceEuro / btcPrice : 0;
                final sats = (priceBTC * 100000000).round();

                if (showSats) {
                  final raw = sats.toString();
                  final formatted = raw.replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]} ',
                  );
                  final firstSig = raw.indexOf(RegExp(r'[1-9]'));
                  int offset = 0;
                  for (
                    int i = 0;
                    i < formatted.length && i < formatted.length - 2;
                    i++
                  ) {
                    if (formatted[i] == ' ') offset++;
                    if (formatted[i] == raw[firstSig]) break;
                  }
                  final boldStart = firstSig + offset;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "T${e.quarter} ${e.year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${e.priceEuro.toStringAsFixed(2)} €",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${btcPrice.toStringAsFixed(2)} €",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        RichText(
                          text: TextSpan(
                            text: formatted.substring(0, boldStart),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: formatted.substring(boldStart),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const TextSpan(
                                text: " sats",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  final str = priceBTC.toStringAsFixed(8);
                  final parts = str.split('.');
                  final before = parts[0];
                  final after = parts[1];
                  final grouped =
                      "$before.${after.substring(0, 2)} ${after.substring(2, 5)} ${after.substring(5)}";
                  final plain = "$before.$after";
                  final sig = plain.indexOf(RegExp(r'[1-9]'));
                  int offset = 0;
                  for (int i = 0; i < grouped.length - 2; i++) {
                    if (grouped[i] == ' ') offset++;
                    if (grouped[i] == plain[sig]) break;
                  }
                  final boldStart = sig + offset;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "T${e.quarter} ${e.year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${e.priceEuro.toStringAsFixed(2)} €",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${btcPrice.toStringAsFixed(2)} €",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        RichText(
                          text: TextSpan(
                            text: grouped.substring(0, boldStart),
                            style: TextStyle(
                              fontSize: 12,
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
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }).toList(),
        ),
      ),
    );
  }

  double _quarterToDouble(int year, int quarter) => year + (quarter - 1) * 0.25;
}
