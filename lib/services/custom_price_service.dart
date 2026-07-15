import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomPriceService {
  static const String _storageKey = 'customProductPricesV1';

  static Future<Map<String, double>> loadPrices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return <String, double>{};
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return <String, double>{};
      }

      final prices = <String, double>{};

      for (final entry in decoded.entries) {
        final id = entry.key.toString();
        final rawValue = entry.value;

        if (rawValue is! num) {
          continue;
        }

        final value = rawValue.toDouble();

        if (id.isNotEmpty && value.isFinite && value > 0) {
          prices[id] = value;
        }
      }

      return prices;
    } catch (_) {
      return <String, double>{};
    }
  }

  static Future<void> savePrices(Map<String, double> prices) async {
    final sanitized = <String, double>{};

    for (final entry in prices.entries) {
      final id = entry.key.trim();
      final value = entry.value;

      if (id.isNotEmpty && value.isFinite && value > 0) {
        sanitized[id] = value;
      }
    }

    final prefs = await SharedPreferences.getInstance();

    if (sanitized.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }

    await prefs.setString(_storageKey, jsonEncode(sanitized));
  }

  static Future<void> clearPrices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
