package com.mk.autosecure.ui.activity.settings

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.mk.autosecure.R
import com.mk.autosecure.libs.utils.Constants
import com.mk.autosecure.rest.ServerErrorHandler
import com.mk.autosecure.rest_fleet.ApiClient
import com.mk.autosecure.rest_fleet.request.SettingBody
import com.orhanobut.logger.Logger
import com.trello.rxlifecycle2.components.RxActivity
import com.mkgroup.camera.CameraWrapper
import com.mkgroup.camera.VdtCameraManager
import com.mkgroup.camera.event.LensChangeEvent
import com.mkgroup.camera.model.Clip.LENS_NORMAL
import com.mkgroup.camera.model.Clip.LENS_UPSIDEDOWN
import com.mkgroup.camera.utils.RxBus
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_lens.*
import kotlinx.android.synthetic.main.default_toolbar.*

class LensActivity : RxActivity() {

    companion object {

        private val TAG = LensActivity::class.java.simpleName

        fun launch(activity: Activity) {
            val intent = Intent(activity, LensActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private var isChangeForUser = true

    var currentCamera: CameraWrapper? = null

    var isLensNormal = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_lens)

        initView()
        initEvent()
    }

    @SuppressLint("CheckResult")
    private fun initEvent() {
        RxBus.getDefault().toObservable(LensChangeEvent::class.java)
            .compose(bindToLifecycle())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                Consumer { onLensChangeEvent(it) },
                ServerErrorHandler(TAG)
            )
    }

    private fun onLensChangeEvent(event: LensChangeEvent?) {
        val lensNormal = event!!.isLensNormal
        val isChecked = rb_lens_up.isChecked
        Logger.t(TAG).d("onLensChangeEvent lensNormal: $lensNormal isChecked: $isChecked")
        if (lensNormal != isChecked) {
            isChangeForUser = false
            setCurrentMode(lensNormal)
        }
    }

    private fun initView() {
        tv_toolbarTitle.text = getString(R.string.camera_view)
        toolbar.setNavigationOnClickListener { finish() }

        currentCamera = VdtCameraManager.getManager().currentCamera
        Logger.t(TAG).d("currentCamera: $currentCamera")

        val lensNormal = currentCamera?.isLensNormal ?: true

        Logger.t(TAG).d("lensNormal: $lensNormal")
        setCurrentMode(lensNormal)

        rg_lens_install.setOnCheckedChangeListener { _, checkedId ->
            Logger.t(TAG).d("isChangeForUser: $isChangeForUser")
            if (isChangeForUser) {
                setCurrentMode(checkedId == rb_lens_up.id)
            } else {
                isChangeForUser = true
            }
        }
    }

    override fun onStop() {
        setLensMode()
        super.onStop()
    }

    @SuppressLint("NewApi")
    private fun setCurrentMode(isNormal: Boolean) {
        isLensNormal = isNormal

        if (isNormal) rb_lens_up.isChecked = true else rb_lens_down.isChecked = true

        rb_lens_up.setTextColor(
            if (isNormal) resources.getColor(R.color.colorAccent, theme)
            else resources.getColor(R.color.colorPrimary,theme)
        )

        rb_lens_down.setTextColor(
            if (isNormal) resources.getColor(R.color.colorPrimary,theme)
            else resources.getColor(R.color.colorAccent,theme)
        )
    }

    override fun onBackPressed() {
        finish()
    }

    @SuppressLint("CheckResult")
    private fun setLensMode() {
        val lensNormal = currentCamera?.isLensNormal
        Logger.t(TAG).d("curLensNormal: $lensNormal isLensNormal: $isLensNormal")

        if (lensNormal != isLensNormal) {
            currentCamera?.setLensNormal(isLensNormal)
        }

        if (Constants.isFleet()) {
            val body = SettingBody(
                SettingBody.SettingsBean(if (isLensNormal) LENS_NORMAL else LENS_UPSIDEDOWN)
            )
            ApiClient.createApiService().uploadRotate(currentCamera?.serialNumber, body)
                .subscribeOn(Schedulers.io())
                .subscribe(
                    Consumer { Logger.t(TAG).d("uploadRotate: " + it.result) },
                    ServerErrorHandler(TAG)
                )
        }
    }

}
