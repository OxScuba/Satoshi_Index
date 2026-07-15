package com.example.satoshi_index.widgets

enum class ProductWidgetSizeProfile(
    val emojiTextSizeSp: Float,
    val nameTextSizeSp: Float,
    val bitcoinTextSizeSp: Float,
    val fiatTextSizeSp: Float,
    val statusTextSizeSp: Float,
    val showStatus: Boolean,
    val paddingStartDp: Int,
    val paddingTopDp: Int,
    val paddingEndDp: Int,
    val paddingBottomDp: Int,
) {
    // Taille initiale 2 × 1.
    COMPACT(
        emojiTextSizeSp = 25f,
        nameTextSizeSp = 11f,
        bitcoinTextSizeSp = 14f,
        fiatTextSizeSp = 10.5f,
        statusTextSizeSp = 8f,
        showStatus = false,
        paddingStartDp = 8,
        paddingTopDp = 2,
        paddingEndDp = 6,
        paddingBottomDp = 2,
    ),

    // Widget allongé approximativement sur trois colonnes.
    NORMAL(
        emojiTextSizeSp = 30f,
        nameTextSizeSp = 13f,
        bitcoinTextSizeSp = 17f,
        fiatTextSizeSp = 12f,
        statusTextSizeSp = 8.5f,
        showStatus = true,
        paddingStartDp = 12,
        paddingTopDp = 4,
        paddingEndDp = 10,
        paddingBottomDp = 4,
    ),

    // Widget très large, approximativement quatre colonnes ou plus.
    LARGE(
        emojiTextSizeSp = 36f,
        nameTextSizeSp = 15.5f,
        bitcoinTextSizeSp = 21f,
        fiatTextSizeSp = 14f,
        statusTextSizeSp = 9.5f,
        showStatus = true,
        paddingStartDp = 16,
        paddingTopDp = 5,
        paddingEndDp = 14,
        paddingBottomDp = 5,
    );

    companion object {
        fun fromWidthDp(widthDp: Int): ProductWidgetSizeProfile {
            return when {
                widthDp <= 0 -> COMPACT
                widthDp < 230 -> COMPACT
                widthDp < 330 -> NORMAL
                else -> LARGE
            }
        }
    }
}
