package com.tapuniverse.feedbackpopup

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.animation.AnimationUtils
import android.view.animation.PathInterpolator
import androidx.annotation.Nullable
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.play.core.review.ReviewManager
import com.tapuniverse.feedbackpopup.databinding.PopupConfirmFeedbackBinding


class ConfirmFeedbackPopup(
    private val email: String = "",
    private val reviewManager: ReviewManager? = null,
    private val onHandle: ((Unit) -> Unit)? = null,
) :
    BottomSheetDialogFragment() {
    private lateinit var binding: PopupConfirmFeedbackBinding

    private constructor(builder: Builder) : this(builder.email, builder.reviewManager, builder.onHandle)

    class Builder {
        var email: String = ""
            private set

        var reviewManager: ReviewManager? = null
            private set

        var onHandle: ((Unit) -> Unit)? = null
            private set

        fun setMail(email: String) = apply { this.email = email }

        fun setReviewManager(reviewManager: ReviewManager?) =
            apply { this.reviewManager = reviewManager }

        fun setHandle(onHandle: ((Unit) -> Unit)?) = apply { this.onHandle = onHandle }

        fun build() = ConfirmFeedbackPopup(this)
    }

    override fun onCreate(@Nullable savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, R.style.SheetDialog)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.window?.setBackgroundDrawableResource(android.R.color.transparent)
        dialog?.window?.setDimAmount(0f)
        dialog?.setCancelable(false)
        binding = PopupConfirmFeedbackBinding.inflate(
            inflater,
            container,
            false
        )
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        startAnimation()
        binding.btnDismiss.setOnClickListener {
            onHandle?.invoke(Unit)
            dismiss()
        }

        binding.btnWriteFeedback.setOnClickListener {
            dismiss()
            openEmail()
            onHandle?.invoke(Unit)
        }
    }

    private fun startAnimation() {
        startPostponedEnterTransition()
        val animFadeIn = AnimationUtils.loadAnimation(
            requireContext(),
            R.anim.fade_in
        )
        binding.layoutBg.startAnimation(animFadeIn)

        val animMoveToTop = AnimationUtils.loadAnimation(
            requireContext(),
            R.anim.slide_top
        )
        val pathInterpolator = PathInterpolator(.35f, .12f, .02f, .99f)
        animMoveToTop.interpolator = pathInterpolator
        binding.layoutPopup.startAnimation(animMoveToTop)
    }

    private fun openEmail() {
        val subject = "Feedback for Photo to PDF"
        val string =
            "mailto:" + email + "?subject=" + Uri.encode(subject) + "&body=" + Uri.encode("")
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse(string))
        emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject)
        emailIntent.putExtra(Intent.EXTRA_TEXT, "")
        startActivity(emailIntent)
    }
}