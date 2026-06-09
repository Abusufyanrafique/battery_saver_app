package com.example.battery_saver_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class MemoryWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.memory_widget)
            views.setTextViewText(R.id.widget_percentage, "85%")
            views.setTextViewText(R.id.widget_title, "Battery")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}