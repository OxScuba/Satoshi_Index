package com.example.satoshi_index.widgets

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

object ProductWidgetScheduler {
    private const val PERIODIC_WORK_NAME =
        "satoshi_index_product_widget_periodic"
    private const val IMMEDIATE_WORK_NAME =
        "satoshi_index_product_widget_immediate"

    fun schedulePeriodic(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val request = PeriodicWorkRequest.Builder(
            ProductWidgetUpdateWorker::class.java,
            30,
            TimeUnit.MINUTES,
        )
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(
                PERIODIC_WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request,
            )
    }

    fun requestImmediateRefresh(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val request = OneTimeWorkRequest.Builder(
            ProductWidgetUpdateWorker::class.java,
        )
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(context)
            .enqueueUniqueWork(
                IMMEDIATE_WORK_NAME,
                ExistingWorkPolicy.REPLACE,
                request,
            )
    }

    fun cancelPeriodic(context: Context) {
        WorkManager.getInstance(context)
            .cancelUniqueWork(PERIODIC_WORK_NAME)
    }
}
