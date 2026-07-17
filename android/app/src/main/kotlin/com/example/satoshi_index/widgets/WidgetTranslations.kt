package com.example.satoshi_index.widgets

object WidgetTranslations {
    private val spanish = mapOf(
        "Actualisation nécessaire" to "Actualización necesaria",
        "Touchez le widget" to "Toca el widget",
        "Actualisation…" to "Actualizando…",
        "En attente du premier cours" to "Esperando el primer precio",
        "Produit supprimé" to "Producto eliminado",
        "Touchez pour choisir" to "Toca para elegir",
        "un autre produit" to "otro producto",
        "Configuration nécessaire" to "Configuración necesaria",
        "Hors ligne" to "Sin conexión",
    )

    fun text(
        snapshot: WidgetDataSnapshot,
        french: String,
        english: String,
    ): String {
        return when (snapshot.language) {
            "en" -> english
            "es" -> spanish[french] ?: french
            else -> french
        }
    }

    fun updatedAt(
        snapshot: WidgetDataSnapshot,
        time: String,
    ): String {
        return when (snapshot.language) {
            "en" -> "Updated at $time"
            "es" -> "Actualizado a las $time"
            else -> "Mis à jour à $time"
        }
    }
}
