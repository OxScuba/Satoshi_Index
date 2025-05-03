import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static const String _fileName = 'cache.json';
  Map<String, dynamic> _cache = {};

  Future<void> loadCache() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        _cache = jsonDecode(content);
      }
    } catch (e) {
      print("⚠️ Erreur lecture cache : $e");
      _cache = {};
    }
  }

  Future<void> saveCache() async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(jsonEncode(_cache));
    } catch (e) {
      print("⚠️ Erreur écriture cache : $e");
    }
  }

  Future<File> _getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  double? getPrice(String dateKey) {
    return _cache[dateKey]?.toDouble();
  }

  void setPrice(String dateKey, double value) {
    _cache[dateKey] = value;
  }
}
