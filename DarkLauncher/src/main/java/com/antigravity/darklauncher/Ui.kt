package com.antigravity.darklauncher

import android.app.Activity
import android.graphics.drawable.Drawable
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView

object Ui {
    /** Zoom suave no item focado pelo D-pad. */
    val focusZoom = View.OnFocusChangeListener { v, focused ->
        val s = if (focused) 1.08f else 1f
        v.animate().scaleX(s).scaleY(s).setDuration(110).start()
    }

    fun tile(act: Activity, parent: ViewGroup, icon: Drawable?, label: CharSequence): View {
        val v = act.layoutInflater.inflate(R.layout.item_tile, parent, false)
        v.findViewById<ImageView>(R.id.tile_icon).setImageDrawable(icon)
        v.findViewById<TextView>(R.id.tile_label).text = label
        v.onFocusChangeListener = focusZoom
        return v
    }

    fun setLabel(tile: View, label: CharSequence) {
        tile.findViewById<TextView>(R.id.tile_label).text = label
    }
}
