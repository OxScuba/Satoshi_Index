package com.example.satoshi_index.widgets

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

class ProductWidgetUpdateWorker(
    appContext: Context,
    workerParams: WorkerParameters,
) : Worker(appContext, workerParams) {
    companion object {
        private const val TAG = "SatoshiWidget"
    }

    override fun doWork(): Result {
        return try {
            ProductWidgetRepository.refreshMarketPrices(
                applicationContext,
            )
            ProductWidgetProvider.updateAllWidgets(
                applicationContext,
            )
            Result.success()
        } catch (error: Exception) {
            Log.w(TAG, "Actualisation widget impossible", error)
            ProductWidgetProvider.updateAllWidgets(
                applicationContext,
                statusOverride = "Hors ligne",
            )
            Result.retry()
        }
    }
}
