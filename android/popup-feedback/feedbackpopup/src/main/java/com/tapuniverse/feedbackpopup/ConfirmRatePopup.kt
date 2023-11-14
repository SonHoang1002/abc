package com.tapuniverse.feedbackpopup

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.animation.AnimationUtils
import android.view.animation.PathInterpolator
import androidx.annotation.Nullable
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.play.core.review.ReviewManager
import com.tapuniverse.feedbackpopup.databinding.PopupConfirmRateBinding

class ConfirmRatePopup(
    private val mActivity: Activity? = null,
    private val reviewManager: ReviewManager? = null,
    private val onHandle: ((Unit) -> Unit)? = null,
) :
    BottomSheetDialogFragment() {
    private val TAG = "ConfirmRatePopup"
    private lateinit var binding: PopupConfirmRateBinding

    private constructor(builder: Builder) : this(
        builder.mActivity,
        builder.reviewManager,
        builder.onHandle
    )

    class Builder {
        var reviewManager: ReviewManager? = null
            private set

        var onHandle: ((Unit) -> Unit)? = null
            private set

        var mActivity: Activity? = null
            private set


        fun setReviewManager(reviewManager: ReviewManager?) =
            apply { this.reviewManager = reviewManager }

        fun setActivity(mActivity: Activity?) =
            apply { this.mActivity = mActivity }

        fun setHandle(onHandle: ((Unit) -> Unit)?) = apply { this.onHandle = onHandle }

        fun build() = ConfirmRatePopup(this)
    }

    override fun onCreate(@Nullable savedInstanceState: Bundle?) {
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
        binding = PopupConfirmRateBinding.inflate(
            inflater,
            container,
            false
        )
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        startAnimation()
        binding.btnRate.setOnClickListener {
            dismiss()
            openRate()
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

    private fun openRate() {
        Log.d(TAG, "openRate")
        val request = reviewManager?.requestReviewFlow()
        request?.addOnCompleteListener { task ->
            Log.d(TAG, "on request flow complete $task, is successful: ${task.isSuccessful}")
            if (task.isSuccessful) {
                mActivity?.let {
                    val flow = reviewManager?.launchReviewFlow(mActivity, task.result)
                    Log.d(TAG, "launch flow: ${flow?.isSuccessful}")
                    flow?.addOnCompleteListener {
                        onHandle?.invoke(Unit)
                        Log.d(TAG, "flow on complete, is successful: ${it.isSuccessful}")
                    }
                }
            }
        }
    }
}