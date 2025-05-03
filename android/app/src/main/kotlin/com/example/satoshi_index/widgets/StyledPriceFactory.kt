package com.example.satoshi_index.widgets

import android.content.Context
import android.content.Intent
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.satoshi_index.R
import com.example.satoshi_index.utils.JsonUtils
import com.example.satoshi_index.utils.ProductWidgetData

class StyledPriceFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var product: ProductWidgetData? = null

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val productName = intent.getStringExtra("product_name") ?: return
        product = JsonUtils.readProductData(context).find { it.name == productName }
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_price_container)

        product?.let {
            val formattedPrice = insertSpaces(it.price_btc) + " ₿" 
            val styledText = formatStyledSats(formattedPrice)
            views.setTextViewText(R.id.styled_price, styledText)
        }

        return views
    }

    override fun getCount() = 1
    override fun getLoadingView() = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = position.toLong()
    override fun hasStableIds() = true
    override fun onDestroy() {}

    private fun insertSpaces(price_btc: String): String {
        // Exemple : "0.00001456" → "0.00 001 456"
        if (price_btc.length < 10) return price_btc // sécurité
        return "${price_btc.substring(0, 4)} ${price_btc.substring(4, 7)} ${price_btc.substring(7)}"
    }

    private fun formatStyledSats(text: String): CharSequence {
        val firstSigIndex = text.indexOfFirst { it in '1'..'9' }
        val spannable = SpannableString(text)
        if (firstSigIndex >= 0) {
            spannable.setSpan(
                ForegroundColorSpan(0xFFFFA500.toInt()),  // Orange
                firstSigIndex,
                text.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        return spannable
    }
}