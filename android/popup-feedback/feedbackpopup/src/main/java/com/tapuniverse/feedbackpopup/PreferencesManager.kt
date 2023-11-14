package com.tapuniverse.feedbackpopup

import android.app.Activity
import android.content.Context

const val IS_SHOW_RATING = "IS_SHOW_RATING"

fun setIsShowRating(activity: Activity) {
    val sharedPref = activity.getPreferences(Context.MODE_PRIVATE)
    with(sharedPref.edit()) {
        putBoolean(IS_SHOW_RATING, true)
        apply()
    }
}

fun isShowRating(activity: Activity): Boolean {
    val sharedPref = activity.getPreferences(Context.MODE_PRIVATE)
    return sharedPref.getBoolean(IS_SHOW_RATING, false)
}
