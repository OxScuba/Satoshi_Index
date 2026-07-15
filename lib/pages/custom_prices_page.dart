import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../services/custom_price_service.dart';
import '../services/product_price_resolver.dart';

class CustomPricesPage extends StatefulWidget {
  final List<Product> products;

  const CustomPricesPage({super.key, required this.products});

  @override
  State<CustomPricesPage> createState() => _CustomPricesPageState();
}

class _CustomPricesPageState extends State<CustomPricesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  bool _isSaving = false;

  List<Product> get _customizableProducts {
    return widget.products
        .where((product) => product.allowCustomPrice)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final customPrices = await CustomPriceService.loadPrices();

    for (final product in _customizableProducts) {
      final price = customPrices[product.id];

      _controllers[product.id] = TextEditingController(
        text: price == null ? '' : _formatEditablePrice(price),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double? _parsePrice(String raw) {
    final normalized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

    final value = double.tryParse(normalized);

    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }

    return value;
  }

  String? _validatePrice(String? raw) {
    final value = raw?.trim() ?? '';

    if (value.isEmpty) {
      return null;
    }

    if (_parsePrice(value) == null) {
      return 'Entre un prix supérieur à zéro.';
    }

    return null;
  }

  Future<void> _savePrices() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prices = <String, double>{};

    for (final product in _customizableProducts) {
      final raw = _controllers[product.id]?.text ?? '';
      final parsed = _parsePrice(raw);

      if (parsed != null) {
        prices[product.id] = parsed;
      }
    }

    setState(() {
      _isSaving = true;
    });

    await CustomPriceService.savePrices(prices);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _resetAllPrices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réinitialiser les prix ?'),
          content: const Text(
            'Tous les produits utiliseront de nouveau leur '
            'dernier prix trimestriel de référence.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await CustomPriceService.clearPrices();

    for (final controller in _controllers.values) {
      controller.clear();
    }

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tous les prix personnalisés ont été supprimés.'),
      ),
    );
  }

  String _formatEditablePrice(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatFiat(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (match) => '${match[1]} ',
        )
        .replaceAll('.', ',');
  }

  Widget _buildProductCard(Product product) {
    final controller = _controllers[product.id]!;
    final referencePrice = ProductPriceResolver.referencePriceEuro(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prix de référence : '
                    '${_formatFiat(referencePrice)} €',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
                    ],
                    validator: _validatePrice,
                    decoration: InputDecoration(
                      labelText: 'Votre prix habituel',
                      hintText: 'Laisser vide pour la référence',
                      suffixText: '€',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Utiliser le prix de référence',
                        onPressed: () {
                          controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.restart_alt),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prix personnalisés'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            tooltip: 'Tout réinitialiser',
            onPressed: _isLoading || _isSaving ? null : _resetAllPrices,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.orange.withValues(alpha: 0.10),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Indique le prix que tu paies réellement. '
                          'Ces valeurs sont enregistrées en euros et '
                          'seront utilisées sur l’accueil, dans les '
                          'outils et dans les widgets. Les fiches et '
                          'graphiques historiques restent inchangés.\n\n'
                          'Laisse un champ vide pour utiliser le dernier '
                          'prix trimestriel de référence.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._customizableProducts.map(_buildProductCard),
                    const SizedBox(height: 6),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _savePrices,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Enregistrement…' : 'Enregistrer les prix',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}
