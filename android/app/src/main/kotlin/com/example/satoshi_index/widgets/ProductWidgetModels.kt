package com.example.satoshi_index.widgets

data class WidgetMarketSnapshot(
    val btcEur: Double,
    val btcUsd: Double,
    val ethEur: Double,
    val ethUsd: Double,
)

data class WidgetProductSnapshot(
    val id: String,
    val name: String,
    val emoji: String,
    val priceEuro: Double,
    val liveAsset: String?,
)

data class WidgetDataSnapshot(
    val schemaVersion: Int,
    val currency: String,
    val showSats: Boolean,
    val updatedAt: Long,
    val market: WidgetMarketSnapshot,
    val products: List<WidgetProductSnapshot>,
)
