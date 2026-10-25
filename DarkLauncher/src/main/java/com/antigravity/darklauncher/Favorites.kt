package com.antigravity.darklauncher

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager

/** Lista ordenada de favoritos (permite reorganizar pelo controle). */
object Favorites {
    private const val PREFS = "dark_launcher_prefs"
    private const val KEY = "fav_order"
    private val DEFAULTS = listOf(
        "com.google.android.youtube.tv",
        "com.netflix.mediaclient",
        "com.android.vending",
        "com.spocky.projengmenu"
    )

    fun load(ctx: Context): MutableList<String> {
        val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val raw = p.getString(KEY, null)
        if (raw != null) return if (raw.isEmpty()) mutableListOf() else raw.split(",").toMutableList()
        // Migra o formato antigo (Set sem ordem) ou aplica padroes instalados
        val legacy = p.getStringSet("favorites", null)
        val list = (legacy?.sorted() ?: DEFAULTS.filter { isInstalled(ctx.packageManager, it) }).toMutableList()
        save(ctx, list)
        return list
    }

    fun save(ctx: Context, list: List<String>) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY, list.joinToString(",")).apply()
    }

    /** Retorna true se o app passou a ser favorito. */
    fun toggle(ctx: Context, pkg: String): Boolean {
        val list = load(ctx)
        val added = if (list.remove(pkg)) false else { list.add(pkg); true }
        save(ctx, list)
        return added
    }

    fun launchIntent(pm: PackageManager, pkg: String): Intent? =
        pm.getLeanbackLaunchIntentForPackage(pkg) ?: pm.getLaunchIntentForPackage(pkg)

    private fun isInstalled(pm: PackageManager, pkg: String) =
        try { pm.getApplicationInfo(pkg, 0); true } catch (_: Exception) { false }
}
