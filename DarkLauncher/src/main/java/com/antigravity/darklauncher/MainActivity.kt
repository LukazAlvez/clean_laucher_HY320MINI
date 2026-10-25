package com.antigravity.darklauncher

import android.app.Activity
import android.app.AlertDialog
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.provider.Settings
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Collections
import java.util.Locale

class MainActivity : Activity() {

    private val ptBR = Locale("pt", "BR")
    private val dateFmt = SimpleDateFormat("EEEE, d 'de' MMMM", ptBR)

    private lateinit var row: LinearLayout
    private lateinit var dateView: TextView
    private lateinit var greetView: TextView

    /** Lista atualmente exibida — evita reconstruir a tela sem necessidade. */
    private var shown: List<String>? = null

    private val timeReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) = updateDate()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        row = findViewById(R.id.row)
        dateView = findViewById(R.id.date)
        greetView = findViewById(R.id.greeting)
        setupPills()
    }

    override fun onResume() {
        super.onResume()
        // Receiver apenas enquanto visivel: zero trabalho em segundo plano
        registerReceiver(timeReceiver, IntentFilter().apply {
            addAction(Intent.ACTION_TIME_TICK)
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        })
        updateDate()
        val favs = Favorites.load(this)
        if (favs != shown) buildRow(favs, if (shown == null) 0 else focusedIndex())
    }

    override fun onPause() {
        super.onPause()
        unregisterReceiver(timeReceiver)
    }

    private fun updateDate() {
        val now = Calendar.getInstance()
        dateView.text = dateFmt.format(now.time).replaceFirstChar { it.titlecase(ptBR) }
        val h = now.get(Calendar.HOUR_OF_DAY)
        greetView.text = when {
            h < 5 -> "Boa noite"
            h < 12 -> "Bom dia"
            h < 18 -> "Boa tarde"
            else -> "Boa noite"
        }
    }

    private fun focusedIndex(): Int {
        for (i in 0 until row.childCount) if (row.getChildAt(i).hasFocus()) return i
        return -1
    }

    private fun buildRow(favs: List<String>, focusIndex: Int) {
        row.removeAllViews()
        val pm = packageManager
        for (pkg in favs) {
            val intent = Favorites.launchIntent(pm, pkg) ?: continue
            val info = try { pm.getApplicationInfo(pkg, 0) } catch (_: Exception) { continue }
            val label = pm.getApplicationLabel(info)
            val tile = Ui.tile(this, row, pm.getApplicationIcon(info), label)
            tile.setOnClickListener { safeStart(intent, label) }
            tile.setOnLongClickListener { showOptions(pkg, label); true }
            row.addView(tile)
        }
        val add = Ui.tile(this, row, getDrawable(R.drawable.ic_add), getString(R.string.add))
        add.setOnClickListener { startActivity(Intent(this, AllAppsActivity::class.java)) }
        row.addView(add)

        shown = favs.toList()
        if (focusIndex >= 0) row.getChildAt(focusIndex.coerceAtMost(row.childCount - 1)).requestFocus()
    }

    /** Segurar OK em um favorito: reorganizar ou remover. */
    private fun showOptions(pkg: String, label: CharSequence) {
        val opts = arrayOf("Mover para a esquerda", "Mover para a direita", "Remover dos favoritos")
        AlertDialog.Builder(this, android.R.style.Theme_DeviceDefault_Dialog_Alert)
            .setTitle(label)
            .setItems(opts) { _, which ->
                val list = Favorites.load(this)
                val i = list.indexOf(pkg)
                var target = i
                when (which) {
                    0 -> if (i > 0) { Collections.swap(list, i, i - 1); target = i - 1 }
                    1 -> if (i in 0 until list.size - 1) { Collections.swap(list, i, i + 1); target = i + 1 }
                    2 -> list.remove(pkg)
                }
                Favorites.save(this, list)
                buildRow(list, target.coerceAtLeast(0))
            }
            .show()
    }

    private fun setupPills() {
        val pills = listOf(R.id.btn_apps, R.id.btn_store, R.id.btn_settings)
            .map { findViewById<android.view.View>(it) }
        pills.forEach { it.onFocusChangeListener = Ui.focusZoom }

        pills[0].setOnClickListener { startActivity(Intent(this, AllAppsActivity::class.java)) }
        pills[1].setOnClickListener {
            val i = Favorites.launchIntent(packageManager, "com.android.vending")
            if (i != null) safeStart(i, "Play Store") else toast("Play Store não encontrada")
        }
        pills[2].setOnClickListener {
            val tv = Intent().setComponent(ComponentName("com.android.tv.set", "com.android.tv.set.MainSettings"))
            if (!safeStart(tv, null)) safeStart(Intent(Settings.ACTION_SETTINGS), "Configurações")
        }
    }

    private fun safeStart(intent: Intent, label: CharSequence?): Boolean = try {
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)); true
    } catch (_: Exception) {
        if (label != null) toast("Não foi possível abrir: $label"); false
    }

    private fun toast(msg: String) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()

    /** Voltar na tela inicial nao fecha o launcher; apenas retorna o foco ao inicio. */
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (row.childCount > 0) row.getChildAt(0).requestFocus()
    }
}
