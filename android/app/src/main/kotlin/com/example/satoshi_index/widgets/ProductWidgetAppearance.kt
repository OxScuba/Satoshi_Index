package com.example.satoshi_index.widgets

enum class ProductWidgetAppearance(
    val storageValue: String,
) {
    CLASSIC("classic"),
    TRANSPARENT_WHITE_TEXT("transparent_white_text"),
    TRANSPARENT_BLACK_TEXT("transparent_black_text");

    companion object {
        fun fromStorageValue(
            value: String?,
        ): ProductWidgetAppearance {
            return values().firstOrNull {
                it.storageValue == value
            } ?: CLASSIC
        }
    }
}
