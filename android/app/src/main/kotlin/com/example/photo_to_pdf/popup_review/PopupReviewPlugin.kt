package com.example.photo_to_pdf.popup_review

import com.tapuniverse.feedbackpopup.showPopupFeedback
import com.tapuniverse.phototopdf.MainActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PopupReviewPlugin(val activity: MainActivity) : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val channel = "com.tapuniverse.phototopdf/popup_review_channel"

    private val showPopupReviewMethod = "showPopupReview"
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        MethodChannel(binding.binaryMessenger, channel).setMethodCallHandler(this);
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == showPopupReviewMethod) {
            showPopupFeedback(activity.supportFragmentManager, "tapuniverse@gmail.com", activity, null)
        }
    }
}