import 'package:flutter/material.dart' hide RichText, Text, TextSpan;

import '../l10n/app_translations.dart';
import '../l10n/localized_widgets.dart';

import '../models/app_currency.dart';

class CurrencySelectionPage extends StatefulWidget {
  final AppCurrency selectedCurrency;

  const CurrencySelectionPage({super.key, required this.selectedCurrency});

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppCurrency> get _filteredCurrencies {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return AppCurrency.values;
    }

    return AppCurrency.values
        .where((currency) {
          return currency.localizedLabel.toLowerCase().contains(query) ||
              currency.code.toLowerCase().contains(query) ||
              currency.symbol.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final currencies = _filteredCurrencies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devise d’affichage'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: tr('Rechercher une devise'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _query.isEmpty
                        ? null
                        : IconButton(
                          tooltip: tr('Effacer'),
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _query = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                currencies.isEmpty
                    ? const Center(child: Text('Aucune devise ne correspond.'))
                    : ListView.separated(
                      itemCount: currencies.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final currency = currencies[index];
                        final selected = currency == widget.selectedCurrency;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: Colors.orange,
                            child: Text(
                              currency.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(currency.localizedLabel),
                          subtitle: Text(currency.code.toUpperCase()),
                          trailing:
                              selected
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.orange,
                                  )
                                  : null,
                          onTap: () {
                            Navigator.pop(context, currency);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
