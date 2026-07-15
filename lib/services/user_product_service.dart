import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_product.dart';

class UserProductService {
  static const String _storageKey = 'userProductsV1';

  static Future<List<UserProduct?>> loadSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    final emptySlots = List<UserProduct?>.filled(UserProduct.slotCount, null);

    if (raw == null || raw.trim().isEmpty) {
      return emptySlots;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return emptySlots;
      }

      for (var index = 0; index < UserProduct.slotCount; index++) {
        final id = UserProduct.idForSlot(index);
        emptySlots[index] = UserProduct.fromJson(decoded[id], slotIndex: index);
      }

      return emptySlots;
    } catch (_) {
      return emptySlots;
    }
  }

  static Future<void> saveSlots(List<UserProduct?> slots) async {
    if (slots.length != UserProduct.slotCount) {
      throw ArgumentError(
        '${UserProduct.slotCount} emplacements de '
        'produits personnels sont attendus.',
      );
    }

    final payload = <String, dynamic>{};

    for (var index = 0; index < slots.length; index++) {
      final product = slots[index];

      if (product == null) {
        continue;
      }

      final normalized = UserProduct(
        id: UserProduct.idForSlot(index),
        name: product.name.trim(),
        emoji: product.emoji.trim(),
        price: product.price,
        currency: product.currency,
      );

      if (normalized.name.isEmpty ||
          normalized.emoji.isEmpty ||
          !normalized.price.isFinite ||
          normalized.price <= 0) {
        continue;
      }

      payload[normalized.id] = normalized.toJson();
    }

    final prefs = await SharedPreferences.getInstance();

    if (payload.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }

    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  static Future<void> saveSlot({
    required int slotIndex,
    required UserProduct product,
  }) async {
    final slots = await loadSlots();

    slots[slotIndex] = UserProduct(
      id: UserProduct.idForSlot(slotIndex),
      name: product.name.trim(),
      emoji: product.emoji.trim(),
      price: product.price,
      currency: product.currency,
    );

    await saveSlots(slots);
  }

  static Future<void> deleteSlot(int slotIndex) async {
    final slots = await loadSlots();
    slots[slotIndex] = null;
    await saveSlots(slots);
  }
}
