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
    private const val SNAPSHOT_FILE = "satoshi_widget_data.json"
    private const val PRICE_URL =
        "https://api.coingecko.com/api/v3/simple/price" +
            "?ids=bitcoin,ethereum&vs_currencies=eur,usd"

    private val lock = Any()

    fun saveRawSnapshot(
        context: Context,
        rawJson: String,
    ) {
        parseSnapshot(JSONObject(rawJson))
        writeAtomically(context, rawJson)
    }

    fun readSnapshot(context: Context): WidgetDataSnapshot? {
        synchronized(lock) {
            val file = snapshotFile(context)

            if (!file.exists()) {
                return null
            }

            return try {
                parseSnapshot(JSONObject(file.readText()))
            } catch (error: Exception) {
                Log.e(TAG, "Lecture du snapshot widget impossible", error)
                null
            }
        }
    }

    fun readSnapshotOrFallback(context: Context): WidgetDataSnapshot {
        return readSnapshot(context)
            ?: ProductWidgetCatalog.fallbackSnapshot()
    }

    fun readProductsForConfiguration(
        context: Context,
    ): List<WidgetProductSnapshot> {
        val products = readSnapshot(context)?.products.orEmpty()

        return if (products.isNotEmpty()) {
            products
        } else {
            ProductWidgetCatalog.fallbackProducts
        }
    }

    fun refreshMarketPrices(context: Context): WidgetDataSnapshot {
        val oldSnapshot = readSnapshotOrFallback(context)
        val refreshed = oldSnapshot.copy(
            updatedAt = System.currentTimeMillis(),
            market = fetchMarketPrices(),
        )

        writeAtomically(
            context,
            snapshotToJson(refreshed).toString(),
        )

        return refreshed
    }

    private fun fetchMarketPrices(): WidgetMarketSnapshot {
        val connection = (
            URL(PRICE_URL).openConnection() as HttpURLConnection
        ).apply {
            requestMethod = "GET"
            connectTimeout = 10_000
            readTimeout = 10_000
            setRequestProperty("Accept", "application/json")
            setRequestProperty(
                "User-Agent",
                "SatoshiIndex-Android-Widget/1.0",
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

            val bitcoin = root.getJSONObject("bitcoin")
            val ethereum = root.getJSONObject("ethereum")

            val market = WidgetMarketSnapshot(
                btcEur = bitcoin.getDouble("eur"),
                btcUsd = bitcoin.getDouble("usd"),
                ethEur = ethereum.getDouble("eur"),
                ethUsd = ethereum.getDouble("usd"),
            )

            require(
                market.btcEur > 0.0 &&
                    market.btcUsd > 0.0 &&
                    market.ethEur > 0.0 &&
                    market.ethUsd > 0.0,
            ) {
                "Cours CoinGecko invalide"
            }

            return market
        } finally {
            connection.disconnect()
        }
    }

    private fun snapshotFile(context: Context): File {
        return File(context.filesDir, SNAPSHOT_FILE)
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

    private fun parseSnapshot(root: JSONObject): WidgetDataSnapshot {
        val marketJson = root.optJSONObject("market") ?: JSONObject()
        val productsJson = root.optJSONArray("products") ?: JSONArray()

        val products = buildList {
            for (index in 0 until productsJson.length()) {
                val product = productsJson.getJSONObject(index)

                val id = product.optString("id").trim()
                val name = product.optString("name").trim()
                val emoji = product.optString("emoji").trim()

                if (id.isEmpty() || name.isEmpty()) {
                    continue
                }

                add(
                    WidgetProductSnapshot(
                        id = id,
                        name = name,
                        emoji = emoji,
                        priceEuro = product.optDouble("priceEuro", 0.0),
                        liveAsset = product
                            .optString("liveAsset")
                            .takeIf {
                                it.isNotBlank() && it != "null"
                            },
                    ),
                )
            }
        }

        return WidgetDataSnapshot(
            schemaVersion = root.optInt("schemaVersion", 1),
            currency = root.optString("currency", "eur").let {
                if (it == "usd") "usd" else "eur"
            },
            showSats = root.optBoolean("showSats", false),
            updatedAt = root.optLong("updatedAt", 0L),
            market = WidgetMarketSnapshot(
                btcEur = marketJson.optDouble("btcEur", 0.0),
                btcUsd = marketJson.optDouble("btcUsd", 0.0),
                ethEur = marketJson.optDouble("ethEur", 0.0),
                ethUsd = marketJson.optDouble("ethUsd", 0.0),
            ),
            products = if (products.isNotEmpty()) {
                products
            } else {
                ProductWidgetCatalog.fallbackProducts
            },
        )
    }

    private fun snapshotToJson(
        snapshot: WidgetDataSnapshot,
    ): JSONObject {
        return JSONObject().apply {
            put("schemaVersion", snapshot.schemaVersion)
            put("currency", snapshot.currency)
            put("showSats", snapshot.showSats)
            put("updatedAt", snapshot.updatedAt)

            put(
                "market",
                JSONObject().apply {
                    put("btcEur", snapshot.market.btcEur)
                    put("btcUsd", snapshot.market.btcUsd)
                    put("ethEur", snapshot.market.ethEur)
                    put("ethUsd", snapshot.market.ethUsd)
                },
            )

            put(
                "products",
                JSONArray().apply {
                    snapshot.products.forEach { product ->
                        put(
                            JSONObject().apply {
                                put("id", product.id)
                                put("name", product.name)
                                put("emoji", product.emoji)
                                put("priceEuro", product.priceEuro)
                                put(
                                    "liveAsset",
                                    product.liveAsset ?: JSONObject.NULL,
                                )
                            },
                        )
                    }
                },
            )
        }
    }
}
