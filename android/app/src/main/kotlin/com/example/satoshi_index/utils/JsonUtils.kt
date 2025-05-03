package com.example.satoshi_index.utils

import android.content.Context
import org.json.JSONArray
import java.io.File

data class ProductWidgetData(
    val name: String,
    val emoji: String,
    val price_btc: String,
    val price_sats: String,
)

object JsonUtils {
    fun readProductData(context: Context): List<ProductWidgetData> {
    val file = File(context.filesDir, "product_data.json")
    if (!file.exists()) return emptyList()

    return try {
        val content = file.readText()
        val jsonArray = JSONArray(content)
        List(jsonArray.length()) { i ->
            val item = jsonArray.getJSONObject(i)
            ProductWidgetData(
                name = item.getString("name"),
                emoji = item.getString("emoji"),
                price_btc = item.getString("price_btc"),
                price_sats = item.getString("price_sats"),
            )
        }
    } catch (e: Exception) {
        e.printStackTrace()
        emptyList()
    }
}
}