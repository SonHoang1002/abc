package com.tapuniverse.feedbackpopup

import android.app.Activity
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.google.android.play.core.review.ReviewManager
import com.google.android.play.core.review.ReviewManagerFactory

fun Fragment.showPopupFeedback(
    mail: String = "", reviewManager: ReviewManager?,
    onHandle: ((Unit) -> Unit)? = null,
) {
    val reviewManager = ReviewManagerFactory.create(requireContext())

    val feedbackPopup = FeedbackPopup.Builder()
        .setMail(mail)
        .setReviewManager(reviewManager)
        .setHandle(onHandle)
        .setActivity(requireActivity())
        .build()
    feedbackPopup.show(childFragmentManager, FeedbackPopup::class.simpleName)
}

fun AppCompatActivity.showPopupFeedback(
    mail: String = "",
    reviewManager: ReviewManager?,
    onHandle: ((Unit) -> Unit)? = null,
) {
    val feedbackPopup = FeedbackPopup.Builder()
        .setMail(mail)
        .setReviewManager(reviewManager)
        .setHandle(onHandle)
        .setActivity(this)
        .build()
    feedbackPopup.show(supportFragmentManager, FeedbackPopup::class.simpleName)
}

fun showPopupFeedback(
    fragmentManager: FragmentManager, mail: String, activity: Activity,
    onHandle: ((Unit) -> Unit)? = null,
) {
    val reviewManager = ReviewManagerFactory.create(activity.applicationContext)
    val feedbackPopup = FeedbackPopup
        .Builder()
        .setMail(mail)
        .setReviewManager(reviewManager)
        .setHandle(onHandle)
        .setActivity(activity)
        .build()
    feedbackPopup.show(fragmentManager, FeedbackPopup::class.simpleName)
}
