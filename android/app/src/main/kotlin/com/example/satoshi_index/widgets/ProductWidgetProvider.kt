package com.example.satoshi_index.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import com.example.satoshi_index.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.roundToInt

class ProductWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val ACTION_REFRESH =
            "com.example.satoshi_index.widgets.ACTION_REFRESH"

        private const val EXTRA_WIDGET_ID =
            "com.example.satoshi_index.widgets.EXTRA_WIDGET_ID"

        fun updateAllWidgets(
            context: Context,
            statusOverride: String? = null,
        ) {
            val manager =
                AppWidgetManager.getInstance(context)

            val ids = manager.getAppWidgetIds(
                ComponentName(
                    context,
                    ProductWidgetProvider::class.java,
                ),
            )

            ids.forEach { appWidgetId ->
                updateWidget(
                    context = context,
                    appWidgetManager = manager,
                    appWidgetId = appWidgetId,
                    statusOverride = statusOverride,
                )
            }
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            loading: Boolean = false,
            statusOverride: String? = null,
        ) {
            val snapshot =
                ProductWidgetRepository.readSnapshotOrFallback(
                    context,
                )

            val productId =
                ProductWidgetPreferences.readProductId(
                    context,
                    appWidgetId,
                )

            val appearance =
                ProductWidgetPreferences.readAppearance(
                    context,
                    appWidgetId,
                )

            val product = snapshot.products.firstOrNull {
                it.id == productId
            } ?: snapshot.products.firstOrNull()
                ?: ProductWidgetCatalog.fallbackProducts.first()

            val hasMarketData =
                snapshot.market.btcEur > 0.0 &&
                    snapshot.market.btcUsd > 0.0

            val sats = if (hasMarketData) {
                WidgetPriceFormatter.productPriceSats(
                    product,
                    snapshot,
                )
            } else {
                0.0
            }

            val fiat = if (hasMarketData) {
                WidgetPriceFormatter.productPriceFiat(
                    product,
                    snapshot,
                )
            } else {
                0.0
            }

            val views = RemoteViews(
                context.packageName,
                R.layout.widget_product,
            )

            applyAppearance(
                context = context,
                views = views,
                appearance = appearance,
            )

            val sizeProfile = readSizeProfile(
                appWidgetManager = appWidgetManager,
                appWidgetId = appWidgetId,
            )

            applySizeProfile(
                context = context,
                views = views,
                profile = sizeProfile,
            )

            views.setTextViewText(
                R.id.widget_product_emoji,
                product.emoji,
            )

            views.setTextViewText(
                R.id.widget_product_name,
                product.name,
            )

            if (hasMarketData) {
                views.setTextViewText(
                    R.id.widget_product_bitcoin_price,
                    WidgetPriceFormatter.formatBitcoinOrSats(
                        context = context,
                        sats = sats,
                        showSats = snapshot.showSats,
                    ),
                )

                views.setTextViewText(
                    R.id.widget_product_fiat_price,
                    WidgetPriceFormatter.formatFiat(
                        value = fiat,
                        currency = snapshot.currency,
                    ),
                )
            } else {
                views.setTextViewText(
                    R.id.widget_product_bitcoin_price,
                    "Actualisation nécessaire",
                )

                views.setTextViewText(
                    R.id.widget_product_fiat_price,
                    "Touchez le widget",
                )
            }

            val status = statusOverride ?: when {
                loading -> "Actualisation…"

                snapshot.updatedAt <= 0L ->
                    "En attente du premier cours"

                else ->
                    "Mis à jour à ${
                        formatUpdateTime(snapshot.updatedAt)
                    }"
            }

            views.setTextViewText(
                R.id.widget_product_status,
                status,
            )

            views.setViewVisibility(
                R.id.widget_product_status,
                if (sizeProfile.showStatus) {
                    View.VISIBLE
                } else {
                    View.GONE
                },
            )

            views.setViewVisibility(
                R.id.widget_product_progress,
                if (loading) View.VISIBLE else View.GONE,
            )

            val refreshIntent = Intent(
                context,
                ProductWidgetProvider::class.java,
            ).apply {
                action = ACTION_REFRESH
                putExtra(
                    EXTRA_WIDGET_ID,
                    appWidgetId,
                )
            }

            val pendingIntent =
                PendingIntent.getBroadcast(
                    context,
                    appWidgetId,
                    refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE,
                )

            views.setOnClickPendingIntent(
                R.id.widget_product_root,
                pendingIntent,
            )

            appWidgetManager.updateAppWidget(
                appWidgetId,
                views,
            )
        }

        private fun readSizeProfile(
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ): ProductWidgetSizeProfile {
            val options =
                appWidgetManager.getAppWidgetOptions(
                    appWidgetId,
                )

            val widthDp = options.getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH,
                0,
            )

            return ProductWidgetSizeProfile.fromWidthDp(
                widthDp,
            )
        }

        private fun applySizeProfile(
            context: Context,
            views: RemoteViews,
            profile: ProductWidgetSizeProfile,
        ) {
            views.setTextViewTextSize(
                R.id.widget_product_emoji,
                TypedValue.COMPLEX_UNIT_SP,
                profile.emojiTextSizeSp,
            )

            views.setTextViewTextSize(
                R.id.widget_product_name,
                TypedValue.COMPLEX_UNIT_SP,
                profile.nameTextSizeSp,
            )

            views.setTextViewTextSize(
                R.id.widget_product_bitcoin_price,
                TypedValue.COMPLEX_UNIT_SP,
                profile.bitcoinTextSizeSp,
            )

            views.setTextViewTextSize(
                R.id.widget_product_fiat_price,
                TypedValue.COMPLEX_UNIT_SP,
                profile.fiatTextSizeSp,
            )

            views.setTextViewTextSize(
                R.id.widget_product_status,
                TypedValue.COMPLEX_UNIT_SP,
                profile.statusTextSizeSp,
            )

            views.setViewPadding(
                R.id.widget_product_root,
                dpToPx(context, profile.paddingStartDp),
                dpToPx(context, profile.paddingTopDp),
                dpToPx(context, profile.paddingEndDp),
                dpToPx(context, profile.paddingBottomDp),
            )
        }

        private fun applyAppearance(
            context: Context,
            views: RemoteViews,
            appearance: ProductWidgetAppearance,
        ) {
            val colors = when (appearance) {
                ProductWidgetAppearance.CLASSIC ->
                    WidgetAppearanceColors(
                        background =
                            R.drawable.widget_product_background,
                        primary = color(
                            context,
                            R.color.widget_text_primary,
                        ),
                        secondary = color(
                            context,
                            R.color.widget_text_secondary,
                        ),
                        muted = color(
                            context,
                            R.color.widget_text_muted,
                        ),
                    )

                ProductWidgetAppearance.TRANSPARENT_WHITE_TEXT ->
                    WidgetAppearanceColors(
                        background =
                            R.drawable.widget_product_background_transparent,
                        primary = color(
                            context,
                            R.color.widget_fixed_white,
                        ),
                        secondary = color(
                            context,
                            R.color.widget_fixed_white_secondary,
                        ),
                        muted = color(
                            context,
                            R.color.widget_fixed_white_muted,
                        ),
                    )

                ProductWidgetAppearance.TRANSPARENT_BLACK_TEXT ->
                    WidgetAppearanceColors(
                        background =
                            R.drawable.widget_product_background_transparent,
                        primary = color(
                            context,
                            R.color.widget_fixed_black,
                        ),
                        secondary = color(
                            context,
                            R.color.widget_fixed_black_secondary,
                        ),
                        muted = color(
                            context,
                            R.color.widget_fixed_black_muted,
                        ),
                    )
            }

            views.setInt(
                R.id.widget_product_root,
                "setBackgroundResource",
                colors.background,
            )

            views.setTextColor(
                R.id.widget_product_name,
                colors.primary,
            )

            // Couleur de base des zéros non significatifs.
            // Les chiffres significatifs restent orange grâce aux spans.
            views.setTextColor(
                R.id.widget_product_bitcoin_price,
                colors.primary,
            )

            views.setTextColor(
                R.id.widget_product_fiat_price,
                colors.secondary,
            )

            views.setTextColor(
                R.id.widget_product_status,
                colors.muted,
            )
        }

        private fun dpToPx(
            context: Context,
            valueDp: Int,
        ): Int {
            return (
                valueDp *
                    context.resources.displayMetrics.density
                ).roundToInt()
        }

        @Suppress("DEPRECATION")
        private fun color(
            context: Context,
            colorResource: Int,
        ): Int {
            return context.resources.getColor(
                colorResource,
            )
        }

        private fun formatUpdateTime(
            timestamp: Long,
        ): String {
            return SimpleDateFormat(
                "HH:mm",
                Locale.getDefault(),
            ).format(Date(timestamp))
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        ProductWidgetScheduler.schedulePeriodic(context)

        appWidgetIds.forEach { appWidgetId ->
            updateWidget(
                context = context,
                appWidgetManager = appWidgetManager,
                appWidgetId = appWidgetId,
            )
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(
            context,
            appWidgetManager,
            appWidgetId,
            newOptions,
        )

        updateWidget(
            context = context,
            appWidgetManager = appWidgetManager,
            appWidgetId = appWidgetId,
        )
    }

    override fun onEnabled(context: Context) {
        ProductWidgetScheduler.schedulePeriodic(context)
        ProductWidgetScheduler.requestImmediateRefresh(context)
    }

    override fun onDisabled(context: Context) {
        ProductWidgetScheduler.cancelPeriodic(context)
    }

    override fun onDeleted(
        context: Context,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            ProductWidgetPreferences.delete(
                context,
                appWidgetId,
            )
        }
    }

    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        super.onReceive(context, intent)

        if (intent.action != ACTION_REFRESH) {
            return
        }

        val manager =
            AppWidgetManager.getInstance(context)

        val appWidgetId = intent.getIntExtra(
            EXTRA_WIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        )

        if (
            appWidgetId !=
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) {
            updateWidget(
                context = context,
                appWidgetManager = manager,
                appWidgetId = appWidgetId,
                loading = true,
            )
        } else {
            updateAllWidgets(
                context = context,
                statusOverride = "Actualisation…",
            )
        }

        ProductWidgetScheduler.requestImmediateRefresh(context)
    }
}

private data class WidgetAppearanceColors(
    val background: Int,
    val primary: Int,
    val secondary: Int,
    val muted: Int,
)
