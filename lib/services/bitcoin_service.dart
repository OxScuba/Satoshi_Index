import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/market_prices.dart';

class BitcoinService {
  static final Uri _priceUrl = Uri.parse(
    'https://api.coingecko.com/api/v3/simple/price'
    '?ids=bitcoin,ethereum&vs_currencies=eur,usd',
  );

  static const String _btcEurCacheKey = 'cachedBtcEur';
  static const String _btcUsdCacheKey = 'cachedBtcUsd';
  static const String _ethEurCacheKey = 'cachedEthEur';
  static const String _ethUsdCacheKey = 'cachedEthUsd';
  static const String _timestampCacheKey = 'cachedMarketTimestamp';

  static Future<MarketPrices> fetchMarketPrices() async {
    try {
      final response = await http
          .get(_priceUrl, headers: const {'accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur CoinGecko HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final bitcoin = decoded['bitcoin'];
      final ethereum = decoded['ethereum'];

      final btcEur = (bitcoin?['eur'] as num?)?.toDouble();
      final btcUsd = (bitcoin?['usd'] as num?)?.toDouble();
      final ethEur = (ethereum?['eur'] as num?)?.toDouble();
      final ethUsd = (ethereum?['usd'] as num?)?.toDouble();

      if (btcEur == null ||
          btcUsd == null ||
          ethEur == null ||
          ethUsd == null ||
          btcEur <= 0 ||
          btcUsd <= 0 ||
          ethEur <= 0 ||
          ethUsd <= 0) {
        throw const FormatException('Réponse CoinGecko invalide');
      }

      final fetchedAt = DateTime.now();

      await _saveCache(
        btcEur: btcEur,
        btcUsd: btcUsd,
        ethEur: ethEur,
        ethUsd: ethUsd,
        fetchedAt: fetchedAt,
      );

      return MarketPrices(
        btcEur: btcEur,
        btcUsd: btcUsd,
        ethEur: ethEur,
        ethUsd: ethUsd,
        fetchedAt: fetchedAt,
      );
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

  static Future<void> _saveCache({
    required double btcEur,
    required double btcUsd,
    required double ethEur,
    required double ethUsd,
    required DateTime fetchedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setDouble(_btcEurCacheKey, btcEur),
      prefs.setDouble(_btcUsdCacheKey, btcUsd),
      prefs.setDouble(_ethEurCacheKey, ethEur),
      prefs.setDouble(_ethUsdCacheKey, ethUsd),
      prefs.setInt(_timestampCacheKey, fetchedAt.millisecondsSinceEpoch),
    ]);
  }

  static Future<MarketPrices?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final btcEur = prefs.getDouble(_btcEurCacheKey);
    final btcUsd = prefs.getDouble(_btcUsdCacheKey);
    final ethEur = prefs.getDouble(_ethEurCacheKey);
    final ethUsd = prefs.getDouble(_ethUsdCacheKey);
    final timestamp = prefs.getInt(_timestampCacheKey);

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
      btcEur: btcEur,
      btcUsd: btcUsd,
      ethEur: ethEur,
      ethUsd: ethUsd,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      isFromCache: true,
    );
  }
}
