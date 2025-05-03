class PriceEntry {
  final int year;
  final int quarter;
  final double priceEuro;
  final double? btcPrice;
  final double? priceSats;

  PriceEntry({
    required this.year,
    required this.quarter,
    required this.priceEuro,
    this.btcPrice,
    this.priceSats,
  });

  // Permet de trier chronologiquement
  DateTime get date => DateTime(year, (quarter - 1) * 3 + 1);

  String get label => "T$quarter $year";
}
