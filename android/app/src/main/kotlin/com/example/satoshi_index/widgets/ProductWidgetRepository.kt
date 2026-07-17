
package com.example.satoshi_index.widgets

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

object ProductWidgetRepository {
    private const val TAG = "SatoshiWidget"
    private const val SNAPSHOT_FILE =
        "satoshi_widget_data.json"
    private const val PRICE_BASE_URL =
        "https://api.coingecko.com/api/v3/simple/price"

    private val lock = Any()

    fun saveRawSnapshot(
        context: Context,
        rawJson: String,
    ) {
        parseSnapshot(JSONObject(rawJson))
        writeAtomically(context, rawJson)
    }

    fun readSnapshot(
        context: Context,
    ): WidgetDataSnapshot? {
        synchronized(lock) {
            val file = snapshotFile(context)

            if (!file.exists()) {
                return null
            }

            return try {
                parseSnapshot(
                    JSONObject(file.readText()),
                )
            } catch (error: Exception) {
                Log.e(
                    TAG,
                    "Lecture du snapshot widget impossible",
                    error,
                )
                null
            }
        }
    }

    fun readSnapshotOrFallback(
        context: Context,
    ): WidgetDataSnapshot {
        return readSnapshot(context)
            ?: ProductWidgetCatalog.fallbackSnapshot()
    }

    fun readProductsForConfiguration(
        context: Context,
    ): List<WidgetProductSnapshot> {
        val products =
            readSnapshot(context)?.products.orEmpty()

        return if (products.isNotEmpty()) {
            products
        } else {
            ProductWidgetCatalog.fallbackProducts
        }
    }

    fun refreshMarketPrices(
        context: Context,
    ): WidgetDataSnapshot {
        val oldSnapshot =
            readSnapshotOrFallback(context)
        val requestedCurrencies = linkedSetOf(
            "eur",
            WidgetCurrencyCatalog.normalize(
                oldSnapshot.currency,
            ),
        ).apply {
            oldSnapshot.products
                .filter { it.isUserProduct }
                .forEach { product ->
                    add(
                        WidgetCurrencyCatalog.normalize(
                            product.priceCurrency,
                        ),
                    )
                }
        }

        val refreshedMarket =
            fetchMarketPrices(requestedCurrencies)

        val refreshed = oldSnapshot.copy(
            schemaVersion = 4,
            currency = WidgetCurrencyCatalog.normalize(
                oldSnapshot.currency,
            ),
            updatedAt = System.currentTimeMillis(),
            market = WidgetMarketSnapshot(
                bitcoinPrices =
                    oldSnapshot.market.bitcoinPrices +
                        refreshedMarket.bitcoinPrices,
                ethereumPrices =
                    oldSnapshot.market.ethereumPrices +
                        refreshedMarket.ethereumPrices,
            ),
        )

        writeAtomically(
            context,
            snapshotToJson(refreshed).toString(),
        )

        return refreshed
    }

    private fun fetchMarketPrices(
        currencies: Set<String>,
    ): WidgetMarketSnapshot {
        val normalizedCurrencies = currencies
            .map(WidgetCurrencyCatalog::normalize)
            .toSet() +
            "eur"

        val requestedCurrencies =
            normalizedCurrencies.joinToString(",")

        val url =
            "$PRICE_BASE_URL" +
                "?ids=bitcoin,ethereum" +
                "&vs_currencies=$requestedCurrencies"

        val connection = (
            URL(url).openConnection() as HttpURLConnection
        ).apply {
            requestMethod = "GET"
            connectTimeout = 10_000
            readTimeout = 10_000
            setRequestProperty(
                "Accept",
                "application/json",
            )
            setRequestProperty(
                "User-Agent",
                "SatoshiIndex-Android-Widget/3.0",
            )
        }

        try {
            val responseCode = connection.responseCode

            if (responseCode !in 200..299) {
                throw IllegalStateException(
                    "CoinGecko HTTP $responseCode",
                )
            }

            val root = JSONObject(
                connection.inputStream
                    .bufferedReader()
                    .use { it.readText() },
            )

            val bitcoin =
                root.getJSONObject("bitcoin")
            val ethereum =
                root.getJSONObject("ethereum")

            val bitcoinPrices =
                readRequestedPrices(
                    bitcoin,
                    requestedCurrencies,
                )
            val ethereumPrices =
                readRequestedPrices(
                    ethereum,
                    requestedCurrencies,
                )

            require(
                bitcoinPrices["eur"] != null &&
                    bitcoinPrices["eur"]!! > 0.0 &&
                    ethereumPrices["eur"] != null &&
                    ethereumPrices["eur"]!! > 0.0 &&
                    normalizedCurrencies.all { code ->
                        bitcoinPrices[code] != null &&
                            bitcoinPrices[code]!! > 0.0 &&
                            ethereumPrices[code] != null &&
                            ethereumPrices[code]!! > 0.0
                    },
            ) {
                "Cours CoinGecko invalide"
            }

            return WidgetMarketSnapshot(
                bitcoinPrices = bitcoinPrices,
                ethereumPrices = ethereumPrices,
            )
        } finally {
            connection.disconnect()
        }
    }

    private fun readRequestedPrices(
        json: JSONObject,
        requestedCurrencies: String,
    ): Map<String, Double> {
        val result = mutableMapOf<String, Double>()

        requestedCurrencies
            .split(",")
            .forEach { code ->
                val value = json.optDouble(
                    code,
                    0.0,
                )

                if (value > 0.0) {
                    result[code] = value
                }
            }

        return result
    }

    private fun snapshotFile(
        context: Context,
    ): File {
        return File(
            context.filesDir,
            SNAPSHOT_FILE,
        )
    }

    private fun writeAtomically(
        context: Context,
        rawJson: String,
    ) {
        synchronized(lock) {
            val target = snapshotFile(context)
            val temporary = File(
                context.filesDir,
                "$SNAPSHOT_FILE.tmp",
            )

            temporary.writeText(rawJson)

            if (!temporary.renameTo(target)) {
                target.writeText(rawJson)
                temporary.delete()
            }
        }
    }

    private fun parseSnapshot(
        root: JSONObject,
    ): WidgetDataSnapshot {
        val marketJson =
            root.optJSONObject("market") ?: JSONObject()
        val productsJson =
            root.optJSONArray("products") ?: JSONArray()

        val bitcoinPrices =
            parsePriceMap(
                marketJson.optJSONObject("bitcoin"),
            ).toMutableMap()

        val ethereumPrices =
            parsePriceMap(
                marketJson.optJSONObject("ethereum"),
            ).toMutableMap()

        // Compatibilité avec le snapshot v1 EUR/USD.
        if (bitcoinPrices.isEmpty()) {
            addLegacyPrice(
                bitcoinPrices,
                "eur",
                marketJson.optDouble("btcEur", 0.0),
            )
            addLegacyPrice(
                bitcoinPrices,
                "usd",
                marketJson.optDouble("btcUsd", 0.0),
            )
        }

        if (ethereumPrices.isEmpty()) {
            addLegacyPrice(
                ethereumPrices,
                "eur",
                marketJson.optDouble("ethEur", 0.0),
            )
            addLegacyPrice(
                ethereumPrices,
                "usd",
                marketJson.optDouble("ethUsd", 0.0),
            )
        }

        val products = buildList {
            for (
                index in 0 until productsJson.length()
            ) {
                val product =
                    productsJson.getJSONObject(index)

                val id =
                    product.optString("id").trim()
                val name =
                    product.optString("name").trim()
                val emoji =
                    product.optString("emoji").trim()

                if (id.isEmpty() || name.isEmpty()) {
                    continue
                }

                add(
                    WidgetProductSnapshot(
                        id = id,
                        name = name,
                        emoji = emoji,
                        priceEuro =
                            product.optDouble(
                                "priceEuro",
                                0.0,
                            ),
                        liveAsset = product
                            .optString("liveAsset")
                            .takeIf {
                                it.isNotBlank() &&
                                    it != "null"
                            },
                        priceAmount =
                            product.optDouble(
                                "priceAmount",
                                product.optDouble(
                                    "priceEuro",
                                    0.0,
                                ),
                            ),
                        priceCurrency =
                            WidgetCurrencyCatalog.normalize(
                                product.optString(
                                    "priceCurrency",
                                    "eur",
                                ),
                            ),
                        isUserProduct =
                            product.optBoolean(
                                "isUserProduct",
                                false,
                            ),
                    ),
                )
            }
        }

        return WidgetDataSnapshot(
            schemaVersion =
                root.optInt("schemaVersion", 1),
            language = normalizeLanguage(
                root.optString("language", "fr"),
            ),
            currency = WidgetCurrencyCatalog.normalize(
                root.optString(
                    "currency",
                    "eur",
                ),
            ),
            showSats =
                root.optBoolean("showSats", false),
            updatedAt =
                root.optLong("updatedAt", 0L),
            market = WidgetMarketSnapshot(
                bitcoinPrices = bitcoinPrices,
                ethereumPrices = ethereumPrices,
            ),
            products = if (products.isNotEmpty()) {
                products
            } else {
                ProductWidgetCatalog.fallbackProducts
            },
        )
    }

    private fun parsePriceMap(
        json: JSONObject?,
    ): Map<String, Double> {
        if (json == null) {
            return emptyMap()
        }

        val result = mutableMapOf<String, Double>()
        val keys = json.keys()

        while (keys.hasNext()) {
            val rawCode = keys.next()
            val code =
                WidgetCurrencyCatalog.normalize(rawCode)

            if (
                rawCode.lowercase() != code ||
                !WidgetCurrencyCatalog
                    .supportedCodes
                    .contains(code)
            ) {
                continue
            }

            val value =
                json.optDouble(rawCode, 0.0)

            if (value > 0.0) {
                result[code] = value
            }
        }

        return result
    }

    private fun addLegacyPrice(
        prices: MutableMap<String, Double>,
        code: String,
        value: Double,
    ) {
        if (value > 0.0) {
            prices[code] = value
        }
    }

    private fun snapshotToJson(
        snapshot: WidgetDataSnapshot,
    ): JSONObject {
        return JSONObject().apply {
            put("schemaVersion", 4)
            put("language", normalizeLanguage(snapshot.language))
            put(
                "currency",
                WidgetCurrencyCatalog.normalize(
                    snapshot.currency,
                ),
            )
            put("showSats", snapshot.showSats)
            put("updatedAt", snapshot.updatedAt)

            put(
                "market",
                JSONObject().apply {
                    put(
                        "bitcoin",
                        priceMapToJson(
                            snapshot.market
                                .bitcoinPrices,
                        ),
                    )
                    put(
                        "ethereum",
                        priceMapToJson(
                            snapshot.market
                                .ethereumPrices,
                        ),
                    )
                },
            )

            put(
                "products",
                JSONArray().apply {
                    snapshot.products.forEach {
                            product ->
                        put(
                            JSONObject().apply {
                                put("id", product.id)
                                put(
                                    "name",
                                    product.name,
                                )
                                put(
                                    "emoji",
                                    product.emoji,
                                )
                                put(
                                    "priceEuro",
                                    product.priceEuro,
                                )
                                put(
                                    "liveAsset",
                                    product.liveAsset
                                        ?: JSONObject.NULL,
                                )
                                put(
                                    "priceAmount",
                                    product.priceAmount,
                                )
                                put(
                                    "priceCurrency",
                                    product.priceCurrency,
                                )
                                put(
                                    "isUserProduct",
                                    product.isUserProduct,
                                )
                            },
                        )
                    }
                },
            )
        }
    }

    private fun normalizeLanguage(value: String): String {
        return when (value.lowercase()) {
            "en" -> "en"
            "es" -> "es"
            else -> "fr"
        }
    }

    private fun priceMapToJson(
        prices: Map<String, Double>,
    ): JSONObject {
        return JSONObject().apply {
            prices.forEach {
                    (code, value) ->
                if (
                    WidgetCurrencyCatalog
                        .supportedCodes
                        .contains(code) &&
                    value > 0.0
                ) {
                    put(code, value)
                }
            }
        }
    }
}
