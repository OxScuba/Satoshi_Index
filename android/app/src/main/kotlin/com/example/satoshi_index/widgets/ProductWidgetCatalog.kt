package com.example.satoshi_index.widgets

object ProductWidgetCatalog {
    val fallbackProducts: List<WidgetProductSnapshot> = listOf(
        WidgetProductSnapshot("baguette", "Baguette", "🥖", 1.03, null),
        WidgetProductSnapshot("essence", "Essence SP95 (l)", "⛽️", 2.04, null),
        WidgetProductSnapshot("cigarette", "Paquet de Cigarette", "🚬", 13.50, null),
        WidgetProductSnapshot("bière", "Bière (50cl)", "🍺", 7.31, null),
        WidgetProductSnapshot("café", "Café", "☕", 1.21, null),
        WidgetProductSnapshot("boeuf", "Boeuf (kg)", "🥩", 30.30, null),
        WidgetProductSnapshot("pizza", "Pizza", "🍕", 13.24, null),
        WidgetProductSnapshot("big_mac", "Big Mac (zone euro)", "🍔", 6.08, null),
        WidgetProductSnapshot("or", "Or (1 g)", "🪙", 125.33, null),
        WidgetProductSnapshot("ethereum", "Ethereum (1 ETH)", "💩", 0.0, "ethereum"),
        WidgetProductSnapshot("immobilier", "Immobilier (m2)", "🏠", 2908.50, null),
    )

    fun fallbackSnapshot(): WidgetDataSnapshot {
        return WidgetDataSnapshot(
            schemaVersion = 1,
            currency = "eur",
            showSats = false,
            updatedAt = 0L,
            market = WidgetMarketSnapshot(
                btcEur = 0.0,
                btcUsd = 0.0,
                ethEur = 0.0,
                ethUsd = 0.0,
            ),
            products = fallbackProducts,
        )
    }
}
