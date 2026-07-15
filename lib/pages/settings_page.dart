import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_currency.dart';
import '../models/product.dart';
import 'currency_selection_page.dart';
import 'custom_prices_page.dart';
import 'donation_page.dart';
import 'user_products_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final List<Product> products;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.products,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool showSats = false;
  String selectedLanguage = 'fr';
  AppCurrency selectedCurrency = AppCurrency.eur;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      showSats = prefs.getBool('showSats') ?? false;
      selectedLanguage = prefs.getString('language') ?? 'fr';
      selectedCurrency = appCurrencyFromCode(prefs.getString('currency'));
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() => isDarkMode = value);
    _updateSetting('darkMode', value);
    widget.onThemeChanged(value);
  }

  Future<void> _selectCurrency() async {
    final currency = await Navigator.push<AppCurrency>(
      context,
      MaterialPageRoute(
        builder:
            (_) => CurrencySelectionPage(selectedCurrency: selectedCurrency),
      ),
    );

    if (currency == null || !mounted) {
      return;
    }

    setState(() {
      selectedCurrency = currency;
    });

    await _updateSetting('currency', currency.code);
  }

  @override
  Widget build(BuildContext context) {
    final customizableCount =
        widget.products.where((product) => product.allowCustomPrice).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          SwitchListTile(
            title: const Text('Afficher les prix en sats'),
            subtitle: const Text('Remplace 0.00 00X XXX ₿ par X XXX sats'),
            value: showSats,
            onChanged: (value) {
              setState(() => showSats = value);
              _updateSetting('showSats', value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.currency_exchange, color: Colors.orange),
            title: const Text('Devise d’affichage'),
            subtitle: Text(
              '${selectedCurrency.label} '
              '(${selectedCurrency.code.toUpperCase()})\n'
              'Concerne l’accueil, les outils et les widgets.',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCurrency.symbol,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _selectCurrency,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.shopping_basket_outlined,
              color: Colors.orange,
            ),
            title: const Text('Prix personnalisés'),
            subtitle: Text(
              'Adaptez $customizableCount produits aux prix '
              'que vous payez réellement.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomPricesPage(products: widget.products),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart, color: Colors.orange),
            title: const Text('Mes produits'),
            subtitle: const Text('Ajoutez des produits personnels.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          UserProductsPage(defaultCurrency: selectedCurrency),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() => selectedLanguage = value);
                _updateSetting('language', value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.orange),
            title: const Text('Tip me in Bitcoin'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
