package com.example.satoshi_index.widgets

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.TextView
import com.example.satoshi_index.R
import java.util.Locale

class ProductWidgetConfigureActivity : Activity() {
    override fun attachBaseContext(newBase: Context) {
        val language =
            ProductWidgetRepository
                .readSnapshot(newBase)
                ?.language
                ?.takeIf { it == "en" }
                ?: "fr"

        val configuration = Configuration(
            newBase.resources.configuration,
        )
        configuration.setLocale(Locale(language))

        super.attachBaseContext(
            newBase.createConfigurationContext(
                configuration,
            ),
        )
    }

    private var appWidgetId =
        AppWidgetManager.INVALID_APPWIDGET_ID

    private lateinit var productGroup: RadioGroup
    private lateinit var appearanceGroup: RadioGroup
    private lateinit var saveButton: Button
    private lateinit var emptyMessage: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        setResult(
            RESULT_CANCELED,
            resultIntent(),
        )
        setContentView(
            R.layout.activity_product_widget_configure,
        )

        if (
            appWidgetId ==
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) {
            finish()
            return
        }

        productGroup = findViewById(
            R.id.widget_config_product_group,
        )
        appearanceGroup = findViewById(
            R.id.widget_config_appearance_group,
        )
        saveButton = findViewById(
            R.id.widget_config_save_button,
        )
        emptyMessage = findViewById(
            R.id.widget_config_empty_message,
        )

        populateProducts()
        restoreAppearance()

        saveButton.setOnClickListener {
            saveSelection()
        }
    }

    private fun populateProducts() {
        val products =
            ProductWidgetRepository.readProductsForConfiguration(
                this,
            )

        if (products.isEmpty()) {
            emptyMessage.visibility = View.VISIBLE
            saveButton.isEnabled = false
            return
        }

        emptyMessage.visibility = View.GONE

        val existingProductId =
            ProductWidgetPreferences.readProductId(
                this,
                appWidgetId,
            )

        var selectedButtonId: Int? = null

        products.forEachIndexed { index, product ->
            val radioButton = RadioButton(this).apply {
                id = View.generateViewId()
                text = "${product.emoji}  ${product.name}"
                textSize = 17f
                tag = product.id
                setPadding(8, 12, 8, 12)
            }

            productGroup.addView(radioButton)

            if (
                product.id == existingProductId ||
                existingProductId == null && index == 0
            ) {
                selectedButtonId = radioButton.id
            }
        }

        selectedButtonId?.let(productGroup::check)
    }

    private fun restoreAppearance() {
        val checkedId = when (
            ProductWidgetPreferences.readAppearance(
                this,
                appWidgetId,
            )
        ) {
            ProductWidgetAppearance.CLASSIC ->
                R.id.widget_config_appearance_classic

            ProductWidgetAppearance.TRANSPARENT_WHITE_TEXT ->
                R.id.widget_config_appearance_transparent_white

            ProductWidgetAppearance.TRANSPARENT_BLACK_TEXT ->
                R.id.widget_config_appearance_transparent_black
        }

        appearanceGroup.check(checkedId)
    }

    private fun saveSelection() {
        val selectedProductButtonId =
            productGroup.checkedRadioButtonId

        if (selectedProductButtonId == View.NO_ID) {
            return
        }

        val selectedProductButton =
            productGroup.findViewById<RadioButton>(
                selectedProductButtonId,
            )

        val productId =
            selectedProductButton.tag as? String
                ?: return

        val appearance = when (
            appearanceGroup.checkedRadioButtonId
        ) {
            R.id.widget_config_appearance_transparent_white ->
                ProductWidgetAppearance.TRANSPARENT_WHITE_TEXT

            R.id.widget_config_appearance_transparent_black ->
                ProductWidgetAppearance.TRANSPARENT_BLACK_TEXT

            else -> ProductWidgetAppearance.CLASSIC
        }

        ProductWidgetPreferences.saveProductId(
            context = this,
            appWidgetId = appWidgetId,
            productId = productId,
        )

        ProductWidgetPreferences.saveAppearance(
            context = this,
            appWidgetId = appWidgetId,
            appearance = appearance,
        )

        ProductWidgetProvider.updateWidget(
            context = this,
            appWidgetManager =
                AppWidgetManager.getInstance(this),
            appWidgetId = appWidgetId,
        )

        ProductWidgetScheduler.schedulePeriodic(this)
        ProductWidgetScheduler.requestImmediateRefresh(this)

        setResult(
            RESULT_OK,
            resultIntent(),
        )
        finish()
    }

    private fun resultIntent(): Intent {
        return Intent().putExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            appWidgetId,
        )
    }
}
