import 'package:flutter/material.dart' hide RichText, Text, TextSpan;
import 'package:flutter/services.dart';

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';
import '../models/app_currency.dart';
import '../models/user_product.dart';
import '../services/user_product_service.dart';
import 'currency_selection_page.dart';

class UserProductsPage extends StatefulWidget {
  final AppCurrency defaultCurrency;
  final int? initialSlotIndex;

  const UserProductsPage({
    super.key,
    required this.defaultCurrency,
    this.initialSlotIndex,
  });

  @override
  State<UserProductsPage> createState() => _UserProductsPageState();
}

class _UserProductsPageState extends State<UserProductsPage> {
  List<UserProduct?> _slots = List<UserProduct?>.filled(
    UserProduct.slotCount,
    null,
  );

  bool _isLoading = true;
  bool _openedInitialEditor = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await UserProductService.loadSlots();

    if (!mounted) {
      return;
    }

    setState(() {
      _slots = slots;
      _isLoading = false;
    });

    _openInitialEditorIfNeeded();
  }

  void _openInitialEditorIfNeeded() {
    final slotIndex = widget.initialSlotIndex;

    if (_openedInitialEditor ||
        slotIndex == null ||
        slotIndex < 0 ||
        slotIndex >= UserProduct.slotCount) {
      return;
    }

    _openedInitialEditor = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editSlot(slotIndex);
      }
    });
  }

  Future<void> _editSlot(int slotIndex) async {
    final result = await Navigator.push<UserProduct>(
      context,
      MaterialPageRoute(
        builder:
            (_) => _UserProductEditorPage(
              slotIndex: slotIndex,
              initialProduct: _slots[slotIndex],
              defaultCurrency: widget.defaultCurrency,
            ),
      ),
    );

    if (result == null) {
      return;
    }

    await UserProductService.saveSlot(slotIndex: slotIndex, product: result);

    if (!mounted) {
      return;
    }

    setState(() {
      _slots[slotIndex] = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.emoji} ${result.name} a été enregistré.'),
      ),
    );
  }

  Future<void> _deleteSlot(int slotIndex) async {
    final product = _slots[slotIndex];

    if (product == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce produit ?'),
          content: Text(
            '${product.emoji} ${product.name} disparaîtra de '
            'l’accueil, des outils et de la liste des widgets.',
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await UserProductService.deleteSlot(slotIndex);

    if (!mounted) {
      return;
    }

    setState(() {
      _slots[slotIndex] = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le produit personnel a été supprimé.')),
    );
  }

  String _formatPrice(UserProduct product) {
    final value = product.price.toStringAsFixed(
      product.currency.fractionDigits,
    );

    return '$value ${product.currency.symbol}';
  }

  Widget _buildSlotCard(int slotIndex) {
    final product = _slots[slotIndex];
    final slotNumber = slotIndex + 1;

    if (product == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.orange.withValues(alpha: 0.45)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            child: Icon(Icons.add),
          ),
          title: Text(
            'Produit personnel $slotNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Emplacement vide · Ajouter un nom, un emoji et un prix',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _editSlot(slotIndex);
          },
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UntranslatedText(
                    product.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(product),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Produit personnel $slotNumber',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: tr('Modifier'),
              onPressed: () {
                _editSlot(slotIndex);
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: tr('Supprimer'),
              onPressed: () {
                _deleteSlot(slotIndex);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
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
        title: const Text('Mes produits'),
        backgroundColor: Colors.orange,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.orange.withValues(alpha: 0.10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Créez jusqu’à ${UserProduct.slotCount} produits personnels. '
                        'Ils apparaîtront en bas de l’accueil, dans la '
                        'page Outils et dans les widgets Android.\n\n'
                        'Le prix est conservé dans sa devise d’origine '
                        'puis converti automatiquement dans la devise '
                        'd’affichage.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0; index < UserProduct.slotCount; index++)
                    _buildSlotCard(index),
                ],
              ),
    );
  }
}

class _UserProductEditorPage extends StatefulWidget {
  final int slotIndex;
  final UserProduct? initialProduct;
  final AppCurrency defaultCurrency;

  const _UserProductEditorPage({
    required this.slotIndex,
    required this.initialProduct,
    required this.defaultCurrency,
  });

  @override
  State<_UserProductEditorPage> createState() => _UserProductEditorPageState();
}

class _UserProductEditorPageState extends State<_UserProductEditorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late final TextEditingController _priceController;
  late AppCurrency _currency;

  @override
  void initState() {
    super.initState();

    final product = widget.initialProduct;

    _nameController = TextEditingController(text: product?.name ?? '');
    _emojiController = TextEditingController(text: product?.emoji ?? '');
    _priceController = TextEditingController(
      text:
          product == null
              ? ''
              : product.price
                  .toStringAsFixed(product.currency.fractionDigits)
                  .replaceAll('.', ','),
    );
    _currency = product?.currency ?? widget.defaultCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double? _parsePrice(String raw) {
    final normalized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');

    final value = double.tryParse(normalized);

    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }

    return value;
  }

  Future<void> _selectCurrency() async {
    final currency = await Navigator.push<AppCurrency>(
      context,
      MaterialPageRoute(
        builder: (_) => CurrencySelectionPage(selectedCurrency: _currency),
      ),
    );

    if (currency == null || !mounted) {
      return;
    }

    setState(() {
      _currency = currency;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = _parsePrice(_priceController.text);

    if (price == null) {
      return;
    }

    Navigator.pop(
      context,
      UserProduct(
        id: UserProduct.idForSlot(widget.slotIndex),
        name: _nameController.text.trim(),
        emoji: _emojiController.text.trim(),
        price: price,
        currency: _currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotNumber = widget.slotIndex + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialProduct == null
              ? 'Ajouter le produit $slotNumber'
              : 'Modifier le produit $slotNumber',
        ),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: 30,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: tr('Nom du produit'),
                hintText: tr('Exemple : Croissant'),
                prefixIcon: const Icon(Icons.edit_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';

                if (name.isEmpty) {
                  return tr('Le nom est obligatoire.');
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emojiController,
              maxLength: 16,
              decoration: InputDecoration(
                labelText: tr('Emoji ou symbole'),
                hintText: tr('Exemple : 🥐'),
                prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return tr('Ajoutez un emoji ou un symbole.');
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
              ],
              decoration: InputDecoration(
                labelText: tr('Prix habituel'),
                hintText: tr('Exemple : 1,60'),
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: _currency.symbol,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (_parsePrice(value ?? '') == null) {
                  return tr('Entrez un prix supérieur à zéro.');
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Devise du prix'),
              subtitle: Text(
                '${_currency.localizedLabel} '
                '(${_currency.code.toUpperCase()})',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currency.symbol,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _selectCurrency,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le produit'),
            ),
          ],
        ),
      ),
    );
  }
}
