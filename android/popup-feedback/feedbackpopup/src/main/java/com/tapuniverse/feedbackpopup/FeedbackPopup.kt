package com.tapuniverse.feedbackpopup

import android.app.Activity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.animation.AnimationUtils
import android.view.animation.PathInterpolator
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.play.core.review.ReviewManager
import com.tapuniverse.feedbackpopup.databinding.PopupFeedbackBinding


class FeedbackPopup(
    private val mActivity: Activity? = null,
    private val email: String = "",
    private val reviewManager: ReviewManager? = null,
    private val onHandle: ((Unit) -> Unit)? = null,
) :
    BottomSheetDialogFragment() {
    private lateinit var binding: PopupFeedbackBinding

    private constructor(builder: Builder) : this(builder.mActivity, builder.email, builder.reviewManager, builder.onHandle)

    class Builder {
        var email: String = ""
            private set

        var reviewManager: ReviewManager? = null
            private set

        var mActivity: Activity? = null
            private set

        var onHandle: ((Unit) -> Unit)? = null
            private set

        fun setMail(email: String) = apply { this.email = email }

        fun setReviewManager(reviewManager: ReviewManager?) =
            apply { this.reviewManager = reviewManager }

        fun setHandle(onHandle: ((Unit) -> Unit)?) = apply { this.onHandle = onHandle }

        fun setActivity(mActivity: Activity?) =
            apply { this.mActivity = mActivity }

        fun build() = FeedbackPopup(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, R.style.SheetDialog)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.window?.setBackgroundDrawableResource(android.R.color.transparent)
        dialog?.window?.setDimAmount(0f)
        dialog?.setCancelable(false)
        //dialog?.window?.setWindowAnimations(-1)
        binding = PopupFeedbackBinding.inflate(
            inflater,
            container,
            false
        )
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        startAnimation()
        binding.btnSad.setOnClickListener {
            openEmail()
        }

        binding.btnNormal.setOnClickListener {
            openEmail()
        }

        binding.btnHappy.setOnClickListener {
            openRate()
        }
    }

    private fun startAnimation() {
        //startPostponedEnterTransition()
        val animFadeIn = AnimationUtils.loadAnimation(requireContext(), R.anim.fade_in)
        binding.layoutBg.startAnimation(animFadeIn)

        val animMoveToTop = AnimationUtils.loadAnimation(
            requireContext(),
            R.anim.slide_top
        )
        val pathInterpolator = PathInterpolator(0.35f, 0.12f, 0.02f, 0.99f)
        animMoveToTop.interpolator = pathInterpolator
        binding.layoutPopup.startAnimation(animMoveToTop)
    }

    private fun openEmail() {
        val confirmPopup = ConfirmFeedbackPopup.Builder().setMail(email).setHandle(onHandle).build()
        confirmPopup.show(parentFragmentManager, ConfirmFeedbackPopup::class.simpleName)
        dismiss()
    }

    private fun openRate() {
        val confirmPopup = ConfirmRatePopup.Builder()
            .setReviewManager(reviewManager)
            .setActivity(mActivity)
            .setHandle(onHandle).build()
        confirmPopup.show(parentFragmentManager, ConfirmFeedbackPopup::class.simpleName)
        dismiss()
    }
}