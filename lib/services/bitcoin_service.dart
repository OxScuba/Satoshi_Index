import 'dart:convert';
import 'package:http/http.dart' as http;

class BitcoinService {
  static Future<double> fetchBitcoinPriceEUR() async {
    final url = Uri.parse(
      "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["bitcoin"]["eur"]?.toDouble() ?? 0;
    } else {
      throw Exception("Erreur API BTC");
    }
  }
}
