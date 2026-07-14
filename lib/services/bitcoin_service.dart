import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/market_prices.dart';

class BitcoinService {
  static final Uri _priceUrl = Uri.parse(
    'https://api.coingecko.com/api/v3/simple/price'
    '?ids=bitcoin&vs_currencies=eur,usd',
  );

  static const String _btcEurCacheKey = 'cachedBtcEur';
  static const String _btcUsdCacheKey = 'cachedBtcUsd';
  static const String _timestampCacheKey = 'cachedBtcTimestamp';

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

      final eur = (bitcoin?['eur'] as num?)?.toDouble();
      final usd = (bitcoin?['usd'] as num?)?.toDouble();

      if (eur == null || usd == null || eur <= 0 || usd <= 0) {
        throw const FormatException('Réponse CoinGecko invalide');
      }

      final fetchedAt = DateTime.now();
      await _saveCache(eur: eur, usd: usd, fetchedAt: fetchedAt);

      return MarketPrices(btcEur: eur, btcUsd: usd, fetchedAt: fetchedAt);
    } catch (error) {
      final cached = await _loadCache();
      if (cached != null) {
        return cached;
      }

      throw Exception(
        'Impossible de récupérer le cours du Bitcoin et aucun cache '
        'n’est disponible : $error',
      );
    }
  }

  // Compatibilité avec les pages existantes qui demandent encore un seul cours.
  static Future<double> fetchBitcoinPriceEUR() async {
    return (await fetchMarketPrices()).btcEur;
  }

  static Future<double> fetchBitcoinPriceUSD() async {
    return (await fetchMarketPrices()).btcUsd;
  }

  static Future<void> _saveCache({
    required double eur,
    required double usd,
    required DateTime fetchedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setDouble(_btcEurCacheKey, eur),
      prefs.setDouble(_btcUsdCacheKey, usd),
      prefs.setInt(_timestampCacheKey, fetchedAt.millisecondsSinceEpoch),
    ]);
  }

  static Future<MarketPrices?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final eur = prefs.getDouble(_btcEurCacheKey);
    final usd = prefs.getDouble(_btcUsdCacheKey);
    final timestamp = prefs.getInt(_timestampCacheKey);

    if (eur == null ||
        usd == null ||
        timestamp == null ||
        eur <= 0 ||
        usd <= 0) {
      return null;
    }

    return MarketPrices(
      btcEur: eur,
      btcUsd: usd,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      isFromCache: true,
    );
  }
}
