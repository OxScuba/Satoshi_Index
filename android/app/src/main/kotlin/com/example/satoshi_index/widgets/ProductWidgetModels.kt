
package com.example.satoshi_index.widgets

data class WidgetMarketSnapshot(
    val bitcoinPrices: Map<String, Double>,
    val ethereumPrices: Map<String, Double>,
) {
    fun bitcoinPrice(currency: String): Double {
        return bitcoinPrices[
            WidgetCurrencyCatalog.normalize(currency)
        ] ?: 0.0
    }

    fun ethereumPrice(currency: String): Double {
        return ethereumPrices[
            WidgetCurrencyCatalog.normalize(currency)
        ] ?: 0.0
    }

    val btcEur: Double
        get() = bitcoinPrice("eur")

    val ethEur: Double
        get() = ethereumPrice("eur")
}

data class WidgetProductSnapshot(
    val id: String,
    val name: String,
    val emoji: String,
    val priceEuro: Double,
    val liveAsset: String?,
    val priceAmount: Double = 0.0,
    val priceCurrency: String = "eur",
    val isUserProduct: Boolean = false,
)

data class WidgetDataSnapshot(
    val schemaVersion: Int,
    val language: String,
    val currency: String,
    val showSats: Boolean,
    val updatedAt: Long,
    val market: WidgetMarketSnapshot,
    val products: List<WidgetProductSnapshot>,
)
