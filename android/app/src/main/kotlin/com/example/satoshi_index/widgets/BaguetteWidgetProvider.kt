package com.example.satoshi_index.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.example.satoshi_index.R

class BaguetteWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_REFRESH_WIDGET = "com.example.satoshi_index.ACTION_REFRESH_WIDGET"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_baguette)

            // Quand on appuie, envoyer un broadcast pour rafraîchir
            val refreshIntent = Intent(context, BaguetteWidgetProvider::class.java).apply {
                action = ACTION_REFRESH_WIDGET
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_baguette_root, refreshPendingIntent)

            // RemoteViewsService pour le prix stylisé
            val serviceIntent = Intent(context, StyledPriceViewsService::class.java).apply {
                putExtra("product_name", "Baguette")
                data = Uri.parse("satoshi_index://baguette_widget/$appWidgetId")
            }
            views.setRemoteAdapter(R.id.widget_baguette_price_container, serviceIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (context != null && intent != null) {
            if (intent.action == ACTION_REFRESH_WIDGET) {
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, BaguetteWidgetProvider::class.java))
                onUpdate(context, manager, ids)
            }
        }
    }
}