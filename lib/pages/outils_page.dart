import 'package:flutter/material.dart';

import '../models/market_prices.dart';
import '../models/product.dart';

enum _ConversionUnit { sats, btc, eur, usd }

class OutilsPage extends StatefulWidget {
  final List<Product> products;
  final MarketPrices marketPrices;
  final bool isDark;

  const OutilsPage({
    super.key,
    required this.products,
    required this.marketPrices,
    required this.isDark,
  });

  @override
  State<OutilsPage> createState() => _OutilsPageState();
}

class _OutilsPageState extends State<OutilsPage> {
  static const double _satsPerBitcoin = 100000000;

  late Product selectedProduct;
  late final Map<_ConversionUnit, TextEditingController> _controllers;

  _ConversionUnit? _activeUnit;
  double _btcValue = 0;

  @override
  void initState() {
    super.initState();

    selectedProduct = widget.products.first;
    _controllers = {
      for (final unit in _ConversionUnit.values) unit: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _parseNumber(String raw) {
    final normalized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');

    if (normalized.isEmpty) return null;

    final value = double.tryParse(normalized);
    if (value == null || !value.isFinite || value < 0) {
      return null;
    }

    return value;
  }

  void _convertFrom(_ConversionUnit source, String raw) {
    final value = _parseNumber(raw);

    setState(() {
      _activeUnit = source;
    });

    if (raw.trim().isEmpty) {
      _clearOtherFields(source);
      setState(() => _btcValue = 0);
      return;
    }

    if (value == null) {
      _clearOtherFields(source);
      setState(() => _btcValue = 0);
      return;
    }

    final btc = switch (source) {
      _ConversionUnit.sats => value / _satsPerBitcoin,
      _ConversionUnit.btc => value,
      _ConversionUnit.eur => value / widget.marketPrices.btcEur,
      _ConversionUnit.usd => value / widget.marketPrices.btcUsd,
    };

    setState(() => _btcValue = btc);

    final calculated = <_ConversionUnit, double>{
      _ConversionUnit.sats: btc * _satsPerBitcoin,
      _ConversionUnit.btc: btc,
      _ConversionUnit.eur: btc * widget.marketPrices.btcEur,
      _ConversionUnit.usd: btc * widget.marketPrices.btcUsd,
    };

    for (final entry in calculated.entries) {
      if (entry.key == source) continue;

      _setControllerText(entry.key, _formatValue(entry.key, entry.value));
    }
  }

  void _clearOtherFields(_ConversionUnit source) {
    for (final entry in _controllers.entries) {
      if (entry.key != source) {
        entry.value.clear();
      }
    }
  }

  void _clearAll() {
    for (final controller in _controllers.values) {
      controller.clear();
    }

    setState(() {
      _activeUnit = null;
      _btcValue = 0;
    });
  }

  void _setControllerText(_ConversionUnit unit, String value) {
    final controller = _controllers[unit]!;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _formatValue(_ConversionUnit unit, double value) {
    switch (unit) {
      case _ConversionUnit.sats:
        return _groupInteger(value.round());
      case _ConversionUnit.btc:
        return _trimTrailingZeros(value.toStringAsFixed(8));
      case _ConversionUnit.eur:
      case _ConversionUnit.usd:
        return value.toStringAsFixed(2);
    }
  }

  String _groupInteger(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;

    return value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatQuantity(double quantity) {
    if (quantity >= 1000) {
      return _groupInteger(quantity.round());
    }
    if (quantity >= 10) {
      return quantity.toStringAsFixed(1);
    }
    return quantity.toStringAsFixed(2);
  }

  Widget _buildField({
    required _ConversionUnit unit,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    final isActive = _activeUnit == unit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[unit],
        keyboardType: TextInputType.numberWithOptions(
          decimal: unit != _ConversionUnit.sats,
        ),
        onChanged: (value) => _convertFrom(unit, value),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: isActive ? Colors.orange : null),
          suffixText: suffix,
          filled: isActive,
          fillColor: isActive ? Colors.orange.withOpacity(0.08) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildProductEquivalent() {
    if (_btcValue <= 0) {
      return const SizedBox.shrink();
    }

    final euroValue = _btcValue * widget.marketPrices.btcEur;
    final itemPriceEuro =
        (selectedProduct.data.last.priceEuro as num).toDouble();

    if (itemPriceEuro <= 0) {
      return const SizedBox.shrink();
    }

    final quantity = euroValue / itemPriceEuro;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Pouvoir d’achat équivalent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '≈ ${_formatQuantity(quantity)} × '
              '${selectedProduct.emoji} ${selectedProduct.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Prix unitaire de référence : '
              '${itemPriceEuro.toStringAsFixed(2)} €',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final fetchedAt = TimeOfDay.fromDateTime(
      widget.marketPrices.fetchedAt,
    ).format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outils'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: widget.isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/bitcoin.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '1 BTC = '
                      '${widget.marketPrices.btcEur.toStringAsFixed(2)} €'
                      '  •  '
                      '${widget.marketPrices.btcUsd.toStringAsFixed(2)} \$',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.marketPrices.isFromCache
                    ? 'Cours hors ligne mis en cache à $fetchedAt'
                    : 'Cours mis à jour à $fetchedAt',
                style: TextStyle(
                  color:
                      widget.marketPrices.isFromCache
                          ? Colors.orange
                          : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Convertisseur universel',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Saisis un montant dans une case : '
                'les trois autres se calculent immédiatement.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildField(
                unit: _ConversionUnit.sats,
                label: 'Satoshis',
                suffix: 'sats',
                icon: Icons.bolt,
              ),
              _buildField(
                unit: _ConversionUnit.btc,
                label: 'Bitcoin',
                suffix: 'BTC',
                icon: Icons.currency_bitcoin,
              ),
              _buildField(
                unit: _ConversionUnit.eur,
                label: 'Euros',
                suffix: '€',
                icon: Icons.euro,
              ),
              _buildField(
                unit: _ConversionUnit.usd,
                label: 'Dollars américains',
                suffix: r'$',
                icon: Icons.attach_money,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.close),
                  label: const Text('Effacer'),
                ),
              ),
              const Divider(height: 34),
              Row(
                children: [
                  const Text(
                    'Comparer avec :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<Product>(
                      value: selectedProduct,
                      isExpanded: true,
                      onChanged: (product) {
                        if (product == null) return;
                        setState(() => selectedProduct = product);
                      },
                      items:
                          widget.products
                              .map(
                                (product) => DropdownMenuItem<Product>(
                                  value: product,
                                  child: Text(
                                    '${product.emoji} ${product.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              _buildProductEquivalent(),
              const SizedBox(height: 18),
              Text(
                'Taux croisé : 1 € = '
                '${widget.marketPrices.eurToUsd.toStringAsFixed(4)} \$'
                '  •  '
                '1 \$ = '
                '${widget.marketPrices.usdToEur.toStringAsFixed(4)} €',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
