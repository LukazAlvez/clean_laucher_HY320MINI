package com.antigravity.darklauncher

import android.app.Activity
import android.content.Intent
import android.content.pm.ResolveInfo
import android.os.Bundle
import android.widget.GridLayout
import android.widget.TextView
import android.widget.Toast

class AllAppsActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_all_apps)
        val grid = findViewById<GridLayout>(R.id.grid)
        val pm = packageManager

        // Apps de TV (Leanback) e apps comuns, sem duplicados
        val found = LinkedHashMap<String, ResolveInfo>()
        for (cat in listOf(Intent.CATEGORY_LEANBACK_LAUNCHER, Intent.CATEGORY_LAUNCHER)) {
            for (ri in pm.queryIntentActivities(Intent(Intent.ACTION_MAIN).addCategory(cat), 0)) {
                val pkg = ri.activityInfo.packageName
                if (pkg != packageName && pkg !in found) found[pkg] = ri
            }
        }

        val favs = Favorites.load(this).toHashSet()
        val apps = found.values.map { it to it.loadLabel(pm).toString() }.sortedBy { it.second.lowercase() }
        findViewById<TextView>(R.id.count).text = "${apps.size}"

        for ((ri, label) in apps) {
            val pkg = ri.activityInfo.packageName
            val tile = Ui.tile(this, grid, ri.loadIcon(pm), mark(label, pkg in favs))
            tile.setOnClickListener {
                val i = Favorites.launchIntent(pm, pkg)
                try { startActivity(i!!.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
                catch (_: Exception) { toast("Não foi possível abrir: $label") }
            }
            tile.setOnLongClickListener {
                val added = Favorites.toggle(this, pkg)
                Ui.setLabel(tile, mark(label, added))
                toast(if (added) "Adicionado aos favoritos" else "Removido dos favoritos")
                true
            }
            grid.addView(tile)
        }
        if (grid.childCount > 0) grid.getChildAt(0).requestFocus()
    }

    private fun mark(label: String, fav: Boolean) = if (fav) "★ $label" else label

    private fun toast(msg: String) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
}
