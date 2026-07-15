
package com.example.satoshi_index.widgets

data class WidgetCurrencyInfo(
    val code: String,
    val symbol: String,
    val fractionDigits: Int,
)

object WidgetCurrencyCatalog {
    val currencies: List<WidgetCurrencyInfo> = listOf(
        WidgetCurrencyInfo("eur", "€", 2),
        WidgetCurrencyInfo("usd", "\$", 2),
        WidgetCurrencyInfo("gbp", "£", 2),
        WidgetCurrencyInfo("chf", "CHF", 2),
        WidgetCurrencyInfo("cad", "CA\$", 2),
        WidgetCurrencyInfo("aud", "A\$", 2),
        WidgetCurrencyInfo("jpy", "¥", 0),
        WidgetCurrencyInfo("cny", "CN¥", 2),
        WidgetCurrencyInfo("hkd", "HK\$", 2),
        WidgetCurrencyInfo("sgd", "S\$", 2),
        WidgetCurrencyInfo("rub", "₽", 2),
        WidgetCurrencyInfo("ils", "₪", 2),
    )

    val supportedCodes: Set<String> =
        currencies.map { it.code }.toSet()

    fun normalize(code: String?): String {
        val normalized = code
            ?.trim()
            ?.lowercase()

        return if (
            normalized != null &&
            supportedCodes.contains(normalized)
        ) {
            normalized
        } else {
            "eur"
        }
    }

    fun info(code: String?): WidgetCurrencyInfo {
        val normalized = normalize(code)

        return currencies.firstOrNull {
            it.code == normalized
        } ?: currencies.first()
    }
}
