package com.example.satoshi_index.widgets

import android.content.Intent
import android.widget.RemoteViewsService

class StyledPriceViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return StyledPriceFactory(this.applicationContext, intent)
    }
}
