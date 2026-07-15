import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_currency.dart';
import '../models/market_prices.dart';

class BitcoinService {
  static const String _cacheKey = 'cachedMarketPricesV2';

  static const String _legacyBtcEurCacheKey = 'cachedBtcEur';
  static const String _legacyBtcUsdCacheKey = 'cachedBtcUsd';
  static const String _legacyEthEurCacheKey = 'cachedEthEur';
  static const String _legacyEthUsdCacheKey = 'cachedEthUsd';
  static const String _legacyTimestampCacheKey = 'cachedMarketTimestamp';

  static Uri get _priceUrl {
    final currencies = AppCurrency.values
        .map((currency) => currency.code)
        .join(',');

    return Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price'
      '?ids=bitcoin,ethereum'
      '&vs_currencies=$currencies',
    );
  }

  static Future<MarketPrices> fetchMarketPrices() async {
    try {
      final response = await http
          .get(_priceUrl, headers: const {'accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur CoinGecko HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Réponse CoinGecko invalide');
      }

      final bitcoinPrices = _parseAssetPrices(decoded['bitcoin']);
      final ethereumPrices = _parseAssetPrices(decoded['ethereum']);

      _validatePrices(
        bitcoinPrices: bitcoinPrices,
        ethereumPrices: ethereumPrices,
      );

      final fetchedAt = DateTime.now();

      final prices = MarketPrices(
        bitcoinPrices: bitcoinPrices,
        ethereumPrices: ethereumPrices,
        fetchedAt: fetchedAt,
      );

      await _saveCache(prices);

      return prices;
    } catch (error) {
      final cached = await _loadCache();

      if (cached != null) {
        return cached;
      }

      throw Exception(
        'Impossible de récupérer les cours BTC/ETH et aucun cache '
        'n’est disponible : $error',
      );
    }
  }

  static Future<double> fetchBitcoinPriceEUR() async {
    return (await fetchMarketPrices()).btcEur;
  }

  static Future<double> fetchBitcoinPriceUSD() async {
    return (await fetchMarketPrices()).btcUsd;
  }

  static Future<double> fetchEthereumPriceEUR() async {
    return (await fetchMarketPrices()).ethEur;
  }

  static Future<double> fetchEthereumPriceUSD() async {
    return (await fetchMarketPrices()).ethUsd;
  }

  static Map<AppCurrency, double> _parseAssetPrices(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('Prix de marché absents');
    }

    final prices = <AppCurrency, double>{};

    for (final currency in AppCurrency.values) {
      final value = raw[currency.code];

      if (value is num) {
        prices[currency] = value.toDouble();
      }
    }

    return prices;
  }

  static void _validatePrices({
    required Map<AppCurrency, double> bitcoinPrices,
    required Map<AppCurrency, double> ethereumPrices,
  }) {
    for (final currency in AppCurrency.values) {
      final bitcoin = bitcoinPrices[currency];
      final ethereum = ethereumPrices[currency];

      if (bitcoin == null ||
          ethereum == null ||
          !bitcoin.isFinite ||
          !ethereum.isFinite ||
          bitcoin <= 0 ||
          ethereum <= 0) {
        throw FormatException('Cours CoinGecko invalide pour ${currency.code}');
      }
    }
  }

  static Future<void> _saveCache(MarketPrices prices) async {
    final prefs = await SharedPreferences.getInstance();

    final payload = <String, dynamic>{
      'bitcoin': prices.bitcoinPricesByCode,
      'ethereum': prices.ethereumPricesByCode,
      'timestamp': prices.fetchedAt.millisecondsSinceEpoch,
    };

    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  static Future<MarketPrices?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is Map<String, dynamic>) {
          final bitcoinPrices = _parseAssetPrices(decoded['bitcoin']);
          final ethereumPrices = _parseAssetPrices(decoded['ethereum']);
          final timestamp = decoded['timestamp'];

          if (timestamp is num &&
              bitcoinPrices[AppCurrency.eur] != null &&
              ethereumPrices[AppCurrency.eur] != null) {
            return MarketPrices(
              bitcoinPrices: bitcoinPrices,
              ethereumPrices: ethereumPrices,
              fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()),
              isFromCache: true,
            );
          }
        }
      } catch (_) {
        // On tente ensuite le cache historique EUR/USD.
      }
    }

    return _loadLegacyCache(prefs);
  }

  static MarketPrices? _loadLegacyCache(SharedPreferences prefs) {
    final btcEur = prefs.getDouble(_legacyBtcEurCacheKey);
    final btcUsd = prefs.getDouble(_legacyBtcUsdCacheKey);
    final ethEur = prefs.getDouble(_legacyEthEurCacheKey);
    final ethUsd = prefs.getDouble(_legacyEthUsdCacheKey);
    final timestamp = prefs.getInt(_legacyTimestampCacheKey);

    if (btcEur == null ||
        btcUsd == null ||
        ethEur == null ||
        ethUsd == null ||
        timestamp == null ||
        btcEur <= 0 ||
        btcUsd <= 0 ||
        ethEur <= 0 ||
        ethUsd <= 0) {
      return null;
    }

    return MarketPrices(
      bitcoinPrices: {AppCurrency.eur: btcEur, AppCurrency.usd: btcUsd},
      ethereumPrices: {AppCurrency.eur: ethEur, AppCurrency.usd: ethUsd},
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      isFromCache: true,
    );
  }
}
