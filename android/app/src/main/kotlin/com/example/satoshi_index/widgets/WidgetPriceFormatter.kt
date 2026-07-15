
package com.example.satoshi_index.widgets

import android.content.Context
import android.graphics.Typeface
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import com.example.satoshi_index.R
import java.util.Locale
import kotlin.math.roundToLong

object WidgetPriceFormatter {
    private const val SATS_PER_BITCOIN =
        100_000_000.0

    fun formatBitcoinOrSats(
        context: Context,
        sats: Double,
        showSats: Boolean,
    ): CharSequence {
        val safeSats = sats.coerceAtLeast(0.0)

        return if (showSats) {
            val text =
                "${groupInteger(
                    safeSats.roundToLong(),
                )} sats"

            styleFromFirstSignificantDigit(
                context,
                text,
                colorEverythingWhenNoDigit = true,
            )
        } else {
            val bitcoin =
                safeSats / SATS_PER_BITCOIN
            val raw = String.format(
                Locale.US,
                "%.8f",
                bitcoin,
            )
            val parts = raw.split(".")
            val decimals = parts[1]

            val grouped =
                "${groupInteger(
                    parts[0].toLong(),
                )}." +
                    "${decimals.substring(0, 2)} " +
                    "${decimals.substring(2, 5)} " +
                    "${decimals.substring(5, 8)} ₿"

            styleFromFirstSignificantDigit(
                context,
                grouped,
                colorEverythingWhenNoDigit = false,
            )
        }
    }

    fun formatFiat(
        value: Double,
        currency: String,
    ): String {
        val info =
            WidgetCurrencyCatalog.info(currency)
        val safeValue =
            value.coerceAtLeast(0.0)
        val raw = String.format(
            Locale.US,
            "%.${info.fractionDigits}f",
            safeValue,
        )
        val parts = raw.split(".")
        val integerPart =
            groupInteger(parts[0].toLong())

        val formatted = if (
            info.fractionDigits == 0
        ) {
            integerPart
        } else {
            "$integerPart.${parts[1]}"
        }

        return "$formatted ${info.symbol}"
    }

    fun productPriceEuro(
        product: WidgetProductSnapshot,
        market: WidgetMarketSnapshot,
    ): Double {
        return when (product.liveAsset) {
            "ethereum" ->
                market.ethereumPrice("eur")

            else -> product.priceEuro
        }
    }

    fun productPriceFiat(
        product: WidgetProductSnapshot,
        snapshot: WidgetDataSnapshot,
    ): Double {
        val currency =
            WidgetCurrencyCatalog.normalize(
                snapshot.currency,
            )
        val priceEuro =
            productPriceEuro(
                product,
                snapshot.market,
            )

        if (currency == "eur") {
            return priceEuro
        }

        return when (product.liveAsset) {
            "ethereum" ->
                snapshot.market.ethereumPrice(
                    currency,
                )

            else -> {
                val bitcoinEuro =
                    snapshot.market.bitcoinPrice(
                        "eur",
                    )
                val bitcoinTarget =
                    snapshot.market.bitcoinPrice(
                        currency,
                    )

                if (
                    bitcoinEuro <= 0.0 ||
                    bitcoinTarget <= 0.0
                ) {
                    0.0
                } else {
                    priceEuro *
                        bitcoinTarget /
                        bitcoinEuro
                }
            }
        }
    }

    fun productPriceSats(
        product: WidgetProductSnapshot,
        snapshot: WidgetDataSnapshot,
    ): Double {
        val bitcoinEuro =
            snapshot.market.bitcoinPrice("eur")

        if (bitcoinEuro <= 0.0) {
            return 0.0
        }

        return productPriceEuro(
            product,
            snapshot.market,
        ) /
            bitcoinEuro *
            SATS_PER_BITCOIN
    }

    private fun groupInteger(
        value: Long,
    ): String {
        return value.toString().replace(
            Regex("(\\d)(?=(\\d{3})+(?!\\d))"),
            "\$1 ",
        )
    }

    @Suppress("DEPRECATION")
    private fun styleFromFirstSignificantDigit(
        context: Context,
        text: String,
        colorEverythingWhenNoDigit: Boolean,
    ): CharSequence {
        val orange =
            context.resources.getColor(
                R.color.widget_accent,
            )
        val spannable = SpannableString(text)

        val firstSignificantIndex =
            text.indexOfFirst {
                it in '1'..'9'
            }

        val start = when {
            firstSignificantIndex >= 0 ->
                firstSignificantIndex

            colorEverythingWhenNoDigit -> 0
            else -> text.length
        }

        if (start < text.length) {
            spannable.setSpan(
                ForegroundColorSpan(orange),
                start,
                text.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
            spannable.setSpan(
                StyleSpan(Typeface.BOLD),
                start,
                text.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
        }

        return spannable
    }
}
