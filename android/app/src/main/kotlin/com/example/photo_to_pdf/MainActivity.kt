package com.tapuniverse.phototopdf

import com.example.photo_to_pdf.popup_review.PopupReviewPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {

    val popupReviewPlugin = PopupReviewPlugin(this)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(popupReviewPlugin)
    }
}
