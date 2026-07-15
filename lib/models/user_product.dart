import 'app_currency.dart';

class UserProduct {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final AppCurrency currency;

  const UserProduct({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.currency,
  });

  static const int slotCount = 3;

  static String idForSlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= slotCount) {
      throw RangeError.range(slotIndex, 0, slotCount - 1, 'slotIndex');
    }

    return 'user_product_${slotIndex + 1}';
  }

  int? get slotIndex {
    for (var index = 0; index < slotCount; index++) {
      if (id == idForSlot(index)) {
        return index;
      }
    }

    return null;
  }

  UserProduct copyWith({
    String? name,
    String? emoji,
    double? price,
    AppCurrency? currency,
  }) {
    return UserProduct(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'emoji': emoji,
      'price': price,
      'currency': currency.code,
    };
  }

  static UserProduct? fromJson(dynamic raw, {required int slotIndex}) {
    if (raw is! Map) {
      return null;
    }

    final name = raw['name']?.toString().trim() ?? '';
    final emoji = raw['emoji']?.toString().trim() ?? '';
    final priceValue = raw['price'];
    final currency = appCurrencyFromCode(raw['currency']?.toString());

    if (name.isEmpty ||
        emoji.isEmpty ||
        priceValue is! num ||
        !priceValue.toDouble().isFinite ||
        priceValue.toDouble() <= 0) {
      return null;
    }

    return UserProduct(
      id: idForSlot(slotIndex),
      name: name,
      emoji: emoji,
      price: priceValue.toDouble(),
      currency: currency,
    );
  }
}
