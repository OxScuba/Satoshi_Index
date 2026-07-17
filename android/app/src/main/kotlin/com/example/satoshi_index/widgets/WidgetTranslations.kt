package com.example.satoshi_index.widgets

object WidgetTranslations {
    fun text(
        snapshot: WidgetDataSnapshot,
        french: String,
        english: String,
    ): String {
        return if (snapshot.language == "en") english else french
    }

    fun updatedAt(
        snapshot: WidgetDataSnapshot,
        time: String,
    ): String {
        return if (snapshot.language == "en") {
            "Updated at $time"
        } else {
            "Mis à jour à $time"
        }
    }
}
