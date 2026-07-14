import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetSyncService {
  static const MethodChannel _channel = MethodChannel('satoshi_index/widgets');

  static bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<void> sync(String jsonPayload) async {
    if (!_isAndroid) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('syncWidgetData', <String, dynamic>{
        'json': jsonPayload,
      });
    } on MissingPluginException {
      // Autorise les tests et les autres plateformes sans plugin natif.
    } on PlatformException catch (error) {
      debugPrint(
        'Synchronisation des widgets impossible : '
        '${error.code} ${error.message}',
      );
    }
  }

  static Future<void> refresh() async {
    if (!_isAndroid) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('refreshWidgets');
    } on MissingPluginException {
      // Rien à faire hors Android.
    } on PlatformException catch (error) {
      debugPrint(
        'Actualisation des widgets impossible : '
        '${error.code} ${error.message}',
      );
    }
  }
}
