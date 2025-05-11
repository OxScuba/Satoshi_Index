import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingChartPage extends StatefulWidget {
  const TradingChartPage({super.key});

  @override
  State<TradingChartPage> createState() => _TradingChartPageState();
}

class _TradingChartPageState extends State<TradingChartPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    const html = '''
    <html>
      <head>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
      </head>
      <body style="margin:0;">
        <div id="tradingview_widget" style="height:100vh;"></div>
        <script type="text/javascript">
          new TradingView.widget({
            "container_id": "tradingview_widget",
            "autosize": true,
            "symbol": "BITSTAMP:BTCEUR",
            "interval": "D",
            "timezone": "Etc/UTC",
            "theme": "dark",
            "style": "1",
            "locale": "fr",
            "toolbar_bg": "#f1f3f6",
            "enable_publishing": false,
            "allow_symbol_change": true,
            "hide_side_toolbar": false,
            "withdateranges": true
          });
        </script>
      </body>
    </html>
    ''';

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TradingView"),
        backgroundColor: Colors.orange,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
