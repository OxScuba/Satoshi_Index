import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/market_prices.dart';
import '../models/product.dart';

enum _ConversionUnit { sats, btc, eur, usd }

class _SignificantDigitsController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final value = text;
    final firstSignificantIndex = value.indexOf(RegExp(r'[1-9]'));

    if (value.isEmpty || firstSignificantIndex == -1) {
      return TextSpan(text: value, style: style);
    }

    return TextSpan(
      style: style,
      children: [
        TextSpan(text: value.substring(0, firstSignificantIndex)),
        TextSpan(
          text: value.substring(firstSignificantIndex),
          style: style?.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

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
  late final Map<_ConversionUnit, _SignificantDigitsController> _controllers;
  late final Map<_ConversionUnit, FocusNode> _focusNodes;

  _ConversionUnit? _activeUnit;
  double _btcValue = 0;

  @override
  void initState() {
    super.initState();

    selectedProduct = widget.products.first;

    _controllers = {
      for (final unit in _ConversionUnit.values)
        unit: _SignificantDigitsController(),
    };

    _focusNodes = {
      for (final unit in _ConversionUnit.values) unit: FocusNode(),
    };

    for (final unit in _ConversionUnit.values) {
      _focusNodes[unit]!.addListener(() {
        if (!_focusNodes[unit]!.hasFocus) {
          _formatFieldAfterEditing(unit);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    super.dispose();
  }

  double? _parseNumber(String raw) {
    final normalized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

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

      setState(() {
        _btcValue = 0;
      });

      return;
    }

    if (value == null) {
      _clearOtherFields(source);

      setState(() {
        _btcValue = 0;
      });

      return;
    }

    final btc = switch (source) {
      _ConversionUnit.sats => value / _satsPerBitcoin,
      _ConversionUnit.btc => value,
      _ConversionUnit.eur => value / widget.marketPrices.btcEur,
      _ConversionUnit.usd => value / widget.marketPrices.btcUsd,
    };

    setState(() {
      _btcValue = btc;
    });

    final calculated = <_ConversionUnit, double>{
      _ConversionUnit.sats: btc * _satsPerBitcoin,
      _ConversionUnit.btc: btc,
      _ConversionUnit.eur: btc * widget.marketPrices.btcEur,
      _ConversionUnit.usd: btc * widget.marketPrices.btcUsd,
    };

    for (final entry in calculated.entries) {
      if (entry.key == source) {
        continue;
      }

      _setControllerText(entry.key, _formatValue(entry.key, entry.value));
    }
  }

  void _formatFieldAfterEditing(_ConversionUnit unit) {
    final controller = _controllers[unit]!;
    final value = _parseNumber(controller.text);

    if (value == null) {
      return;
    }

    _setControllerText(unit, _formatValue(unit, value));
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

    FocusScope.of(context).unfocus();

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
        return _groupBitcoin(value);

      case _ConversionUnit.eur:
      case _ConversionUnit.usd:
        return _groupFiat(value);
    }
  }

  String _groupInteger(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  String _groupBitcoin(double value) {
    final fixed = value.toStringAsFixed(8);
    final parts = fixed.split('.');

    final integerPart = _groupInteger(int.parse(parts[0]));
    final decimals = parts[1];

    return '$integerPart.'
        '${decimals.substring(0, 2)} '
        '${decimals.substring(2, 5)} '
        '${decimals.substring(5, 8)}';
  }

  String _groupFiat(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');

    final integerPart = _groupInteger(int.parse(parts[0]));

    return '$integerPart.${parts[1]}';
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
    final textColor = widget.isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[unit],
        focusNode: _focusNodes[unit],
        keyboardType: TextInputType.numberWithOptions(
          decimal: unit != _ConversionUnit.sats,
        ),
        style: TextStyle(
          fontSize: 18,
          color: textColor,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        textAlign: TextAlign.right,
        onTap: () {
          setState(() {
            _activeUnit = unit;
          });
        },
        onChanged: (value) {
          _convertFrom(unit, value);
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: isActive ? Colors.orange : null),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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

  Widget _buildBitcoinPriceHeader() {
    final textColor = widget.isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('lib/assets/images/bitcoin.png', height: 24, width: 24),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              children: [
                const TextSpan(text: '1 BTC = '),
                TextSpan(
                  text: _groupFiat(widget.marketPrices.btcEur),
                  style: const TextStyle(color: Colors.orange),
                ),
                const TextSpan(
                  text: ' €',
                  style: TextStyle(color: Colors.orange),
                ),
                const TextSpan(text: '  •  '),
                TextSpan(
                  text: _groupFiat(widget.marketPrices.btcUsd),
                  style: const TextStyle(color: Colors.orange),
                ),
                const TextSpan(
                  text: ' \$',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductEquivalent() {
    if (_btcValue <= 0) {
      return const SizedBox.shrink();
    }

    final euroValue = _btcValue * widget.marketPrices.btcEur;
    final itemPriceEuro = selectedProduct.data.last.priceEuro;

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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
                children: [
                  const TextSpan(text: '≈ '),
                  TextSpan(
                    text: _formatQuantity(quantity),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' × ${selectedProduct.emoji} '
                        '${selectedProduct.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                ),
                children: [
                  const TextSpan(text: 'Prix unitaire de référence : '),
                  TextSpan(
                    text: _groupFiat(itemPriceEuro),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' €',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateFooter() {
    final textColor = widget.isDark ? Colors.white70 : Colors.black54;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(color: textColor, fontSize: 12),
        children: [
          const TextSpan(text: 'Taux croisé : 1 € = '),
          TextSpan(
            text: widget.marketPrices.eurToUsd.toStringAsFixed(4),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ' \$',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '  •  1 \$ = '),
          TextSpan(
            text: widget.marketPrices.usdToEur.toStringAsFixed(4),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ' €',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ],
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
              _buildBitcoinPriceHeader(),
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
              Text(
                'Saisis un montant dans une case : '
                'les trois autres se calculent immédiatement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
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
                suffix: '\$',
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
                        if (product == null) {
                          return;
                        }

                        setState(() {
                          selectedProduct = product;
                        });
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
              _buildExchangeRateFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
