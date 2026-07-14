package com.example.satoshi_index.widgets

import android.appwidget.AppWidgetManager
import android.content.Context

object ProductWidgetPreferences {
    private const val PREFERENCES_NAME =
        "satoshi_index_product_widgets"

    private const val PRODUCT_KEY_PREFIX = "product_"
    private const val APPEARANCE_KEY_PREFIX = "appearance_"

    fun saveProductId(
        context: Context,
        appWidgetId: Int,
        productId: String,
    ) {
        context.getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).edit()
            .putString(
                "$PRODUCT_KEY_PREFIX$appWidgetId",
                productId,
            )
            .apply()
    }

    fun readProductId(
        context: Context,
        appWidgetId: Int,
    ): String? {
        if (
            appWidgetId ==
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) {
            return null
        }

        return context.getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).getString(
            "$PRODUCT_KEY_PREFIX$appWidgetId",
            null,
        )
    }

    fun saveAppearance(
        context: Context,
        appWidgetId: Int,
        appearance: ProductWidgetAppearance,
    ) {
        context.getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).edit()
            .putString(
                "$APPEARANCE_KEY_PREFIX$appWidgetId",
                appearance.storageValue,
            )
            .apply()
    }

    fun readAppearance(
        context: Context,
        appWidgetId: Int,
    ): ProductWidgetAppearance {
        if (
            appWidgetId ==
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) {
            return ProductWidgetAppearance.CLASSIC
        }

        val value = context.getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).getString(
            "$APPEARANCE_KEY_PREFIX$appWidgetId",
            null,
        )

        return ProductWidgetAppearance.fromStorageValue(value)
    }

    fun delete(
        context: Context,
        appWidgetId: Int,
    ) {
        context.getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).edit()
            .remove("$PRODUCT_KEY_PREFIX$appWidgetId")
            .remove("$APPEARANCE_KEY_PREFIX$appWidgetId")
            .apply()
    }
}
