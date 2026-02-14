package com.mk.autosecure.ui.activity.settings

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Toast;
import com.google.android.material.snackbar.Snackbar
import com.mk.autosecure.R
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers
import com.mk.autosecure.rest.ServerErrorHandler
import com.mk.autosecure.ui.activity.LocalLiveActivity
import com.orhanobut.logger.Logger
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity
import com.mkgroup.camera.CameraWrapper
import com.mkgroup.camera.VdtCameraManager
import com.mkgroup.camera.event.EventParamChangeEvent
import com.mkgroup.camera.rest.Optional
import com.mkgroup.camera.utils.RxBus
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_event_param.*
import kotlinx.android.synthetic.main.default_toolbar.*

class EventParamActivity : RxAppCompatActivity() {

    private var mCamera: CameraWrapper? = null

    private var mCurSupport: Boolean = false

    private var mSubscribe: Disposable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_event_param)
        initView()
    }

    @SuppressLint("CheckResult")
    override fun onResume() {
        super.onResume()
        mSubscribe = RxBus.getDefault()
            .toObservable(EventParamChangeEvent::class.java)
            .compose(Transformers.switchSchedulers())
            .compose(bindToLifecycle())
            .subscribe(
                { this.onParamChangeEvent(it) },
                ServerErrorHandler(TAG)
            )

        VdtCameraManager.getManager().currentCamera()
            .compose(bindToLifecycle())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { this.onCurrentCamera(it) },
                ServerErrorHandler(TAG)
            )
    }

    private fun onParamChangeEvent(changeEvent: EventParamChangeEvent?) {
        if (changeEvent != null && changeEvent.camera == mCamera) {
            val eventParam = changeEvent.eventParam
            Logger.t(TAG).e("onParamChangeEvent param: $eventParam")
            et_event_param!!.setText(eventParam)
        }
    }

    private fun onCurrentCamera(cameraOptional: Optional<CameraWrapper>) {
        val vdtCamera = cameraOptional.includeNull
        Logger.t(TAG).d("onCurrentCamera: $vdtCamera")

        if (vdtCamera != null) {
            mCamera = vdtCamera
        } else {
            Logger.t(TAG).d("onDisconnectCamera")
            Toast.makeText(
                this,
                resources.getString(R.string.camera_disconnected),
                Toast.LENGTH_SHORT
            ).show()
            LocalLiveActivity.launch(this, true)
        }
    }

    private fun initView() {
        (findViewById<View>(R.id.toolbar) as androidx.appcompat.widget.Toolbar).setNavigationOnClickListener { finish() }
        tv_toolbarTitle!!.setText(R.string.event_detection_param)

        mCamera = VdtCameraManager.getManager().currentCamera
        if (mCamera != null) {
            mCurSupport = mCamera!!.supportRiskEvent
            Logger.t(TAG).d("mCurSupport: $mCurSupport")

            switch_riskDrive!!.setOnCheckedChangeListener { _, isChecked -> setEnable(isChecked) }
            switch_riskDrive!!.isChecked = mCurSupport

            val eventParam = mCamera!!.eventParam
            Logger.t(TAG).d("eventParam: $eventParam")
            et_event_param!!.setText(eventParam)

            btn_event_apply.setOnClickListener {
                val trim = et_event_param!!.text.toString().lowercase().trim { it <= ' ' }
                if (TextUtils.isEmpty(trim)) {
                    return@setOnClickListener
                }

                if (mCamera != null) {
                    val param = mCamera!!.eventParam

                    if (trim == param) {
                        Toast.makeText(
                            this,
                            getString(R.string.param_no_change),
                            Toast.LENGTH_SHORT
                        ).show()
                    } else {
                        hideSoftInput(et_event_param)
                        unSubscribeEvent()

                        mCamera!!.eventParam = trim

                        Snackbar.make(
                            et_event_param!!,
                            getString(R.string.apply_success),
                            Snackbar.LENGTH_LONG
                        ).show()
                        Handler(Looper.getMainLooper()).postDelayed({ this.finish() }, 2000)
                    }
                }
            }
        }
    }

    private fun setEnable(enable: Boolean) {
        Logger.t(TAG).d("enable: $enable mCurSupport: $mCurSupport")
        et_event_param!!.isEnabled = enable
        et_event_param!!.clearFocus()
        btn_event_apply!!.isEnabled = enable

        if (mCurSupport != enable) {
            mCurSupport = enable
            mCamera!!.supportRiskEvent = enable
        }
    }

    private fun hideSoftInput(view: View) {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(view.windowToken, 0)
    }

    private fun unSubscribeEvent() {
        if (mSubscribe != null && !mSubscribe!!.isDisposed) {
            mSubscribe!!.dispose()
        }
    }

    companion object {

        private val TAG = EventParamActivity::class.java.simpleName

        fun launch(activity: Activity) {
            val intent = Intent(activity, EventParamActivity::class.java)
            activity.startActivity(intent)
        }
    }

}
