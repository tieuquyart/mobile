package com.mk.autosecure.ui.activity.settings

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast;
import com.mk.autosecure.R
import com.mk.autosecure.rest.ServerErrorHandler
import com.mk.autosecure.ui.DialogHelper
import com.mk.autosecure.ui.activity.LocalLiveActivity
import com.orhanobut.logger.Logger
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity
import com.mkgroup.camera.CameraWrapper
import com.mkgroup.camera.VdtCameraManager
import com.mkgroup.camera.event.VoltageChangeEvent
import com.mkgroup.camera.rest.Optional
import com.mkgroup.camera.utils.RxBus
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.functions.Consumer
import kotlinx.android.synthetic.main.activity_protect_voltage.*
import kotlinx.android.synthetic.main.default_toolbar.*

class ProtectVoltageActivity : RxAppCompatActivity() {

    private var mCamera: CameraWrapper? = null

    private var protectVoltage = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_protect_voltage)

        initView()
        initEvent()
    }

    @SuppressLint("CheckResult")
    private fun initEvent() {
        RxBus.getDefault().toObservable(VoltageChangeEvent::class.java)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(Consumer { onVoltageChangeEvent(it) },
                    ServerErrorHandler(TAG)
                )
    }

    private fun onVoltageChangeEvent(event: VoltageChangeEvent?) {
        val voltage = event!!.voltage
        Logger.t(TAG).d("onVoltageChangeEvent: $voltage")
        setCurrentMode(voltage)
    }

    private fun setCurrentMode(voltage: Int) {
        when (voltage) {
            DAILY_DRIVER_VOLTAGE -> rb_daily_driver.isChecked = true
            BALANCED_VOLTAGE -> rb_balanced.isChecked = true
            EXTENDED_VOLTAGE -> rb_extended.isChecked = true
            EXTREME_VOLTAGE -> {
                showExtreme()
                rb_extreme.isChecked = true
            }
            else -> rb_daily_driver.isChecked = true
        }
    }

    private fun initView() {
        (findViewById<View>(R.id.toolbar) as androidx.appcompat.widget.Toolbar).setNavigationOnClickListener { finish() }
        tv_toolbarTitle!!.setText(R.string.battery_protection)

        mCamera = VdtCameraManager.getManager().currentCamera
        if (mCamera != null) {
            protectVoltage = mCamera!!.protectVoltage
            Logger.t(TAG).d("protectVoltage: $protectVoltage")
            setCurrentMode(protectVoltage)

            rg_protection_mode.setOnCheckedChangeListener { _, checkedId ->
                when (checkedId) {
                    rb_daily_driver.id -> {
                        Logger.t(TAG).d("DAILY_DRIVER_VOLTAGE")
                        protectVoltage = DAILY_DRIVER_VOLTAGE
                        mCamera!!.protectVoltage = DAILY_DRIVER_VOLTAGE
                    }
                    rb_balanced.id -> {
                        Logger.t(TAG).d("BALANCED_VOLTAGE")
                        protectVoltage = BALANCED_VOLTAGE
                        mCamera!!.protectVoltage = BALANCED_VOLTAGE
                    }
                    rb_extended.id -> {
                        Logger.t(TAG).d("EXTENDED_VOLTAGE")
                        protectVoltage = EXTENDED_VOLTAGE
                        mCamera!!.protectVoltage = EXTENDED_VOLTAGE
                    }
                    rb_extreme.id -> {
                        Logger.t(TAG).d("EXTREME_VOLTAGE")
                        DialogHelper.showExtremeModeDialog(this, {
                            protectVoltage = EXTREME_VOLTAGE
                            mCamera!!.protectVoltage = EXTREME_VOLTAGE
                        }, {
                            setCurrentMode(protectVoltage)
                        })
                    }
                }
            }

            tv_enter_protection.setOnClickListener {
                showExtreme()
            }
        }
    }

    private fun showExtreme() {
        tv_enter_protection.visibility = View.GONE
        view_extreme.visibility = View.VISIBLE
        rb_extreme.visibility = View.VISIBLE
        tv_extreme_tips.visibility = View.VISIBLE
    }

    @SuppressLint("CheckResult")
    override fun onResume() {
        super.onResume()
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(Consumer<Optional<CameraWrapper>> { this.onCurrentCamera(it) },
                    ServerErrorHandler(TAG)
                )
    }

    private fun onCurrentCamera(cameraOptional: Optional<CameraWrapper>) {
        val includeNull = cameraOptional.includeNull
        Logger.t(TAG).d("onCurrentCamera: $includeNull")

        if (includeNull != null) {
            mCamera = includeNull
        } else {
            Logger.t(TAG).d("onDisconnectCamera")
            Toast.makeText(this, resources.getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show()
            LocalLiveActivity.launch(this, true)
        }
    }

    companion object {

        private val TAG = ProtectVoltageActivity::class.java.simpleName

        const val DAILY_DRIVER_VOLTAGE = 12000

        const val BALANCED_VOLTAGE = 11900

        const val EXTENDED_VOLTAGE = 11800

        const val EXTREME_VOLTAGE = 11700

        fun launch(activity: Activity) {
            val intent = Intent(activity, ProtectVoltageActivity::class.java)
            activity.startActivity(intent)
        }
    }

}
