package com.example.satoshi_index

import android.util.Log
import com.example.satoshi_index.widgets.ProductWidgetProvider
import com.example.satoshi_index.widgets.ProductWidgetRepository
import com.example.satoshi_index.widgets.ProductWidgetScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "satoshi_index/widgets"
        private const val TAG = "SatoshiWidget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncWidgetData" -> {
                    val json = call.argument<String>("json")

                    if (json.isNullOrBlank()) {
                        result.error(
                            "INVALID_WIDGET_DATA",
                            "Le JSON du widget est vide.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        ProductWidgetRepository.saveRawSnapshot(
                            this,
                            json,
                        )
                        ProductWidgetScheduler.schedulePeriodic(this)
                        ProductWidgetProvider.updateAllWidgets(this)
                        result.success(null)
                    } catch (error: Exception) {
                        Log.e(
                            TAG,
                            "Synchronisation Flutter vers widget impossible",
                            error,
                        )
                        result.error(
                            "WIDGET_SYNC_FAILED",
                            error.message,
                            null,
                        )
                    }
                }

                "refreshWidgets" -> {
                    ProductWidgetScheduler.requestImmediateRefresh(this)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
