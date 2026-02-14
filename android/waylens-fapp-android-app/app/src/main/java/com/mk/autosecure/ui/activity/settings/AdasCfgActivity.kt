package com.mk.autosecure.ui.activity.settings

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatDialog
import butterknife.ButterKnife
import com.mk.autosecure.R
import com.mk.autosecure.libs.utils.DebugHelper
import com.mk.autosecure.libs.utils.DialogUtils
import com.mk.autosecure.ui.activity.DevicesActivity
import com.orhanobut.logger.Logger
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity
import com.mkgroup.camera.EvCamera
import com.mkgroup.camera.VdtCameraManager
import com.mkgroup.camera.event.AdasCfgChangeEvent
import com.mkgroup.camera.message.bean.AdasCfgInfo
import com.mkgroup.camera.rest.ServerErrorHandler
import com.mkgroup.camera.utils.RxBus
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.functions.Consumer
import kotlinx.android.synthetic.main.activity_adas_cfg.*

class AdasCfgActivity : RxAppCompatActivity() {

    companion object {
        @JvmStatic
        fun launch(activity: Activity) {
            val intent = Intent(activity, AdasCfgActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private val TAG = AdasCfgActivity::class.java.simpleName

    private var progressDialog: AppCompatDialog? = null

    private var mCamera: EvCamera? = null

    private var mAdascfgInfo: AdasCfgInfo? = null

    private var saveManually = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_adas_cfg)
        ButterKnife.bind(this)

        initView()
        initListener()
    }

    @SuppressLint("CheckResult")
    private fun initListener() {
        et_input_fcttc?.addTextChangedListener(mTextWatcher)
        et_input_fctr?.addTextChangedListener(mTextWatcher)
        et_input_hmttc?.addTextChangedListener(mTextWatcher)
        et_input_hmtr?.addTextChangedListener(mTextWatcher)
        et_input_height?.addTextChangedListener(mTextWatcher)
        et_input_width?.addTextChangedListener(mTextWatcher)
        et_input_offset?.addTextChangedListener(mTextWatcher)

        btn_save_setting?.setOnClickListener {
            if (valueInvalid()) {
                Toast.makeText(this, "Please make sure you input the correct values.", Toast.LENGTH_LONG).show()
                return@setOnClickListener
            }
            saveManually = true
            showLoadingDialog()

            val fcw = if (llInputFcttc.visibility == View.VISIBLE) et_input_fcttc?.text.toString().toDouble() else mAdascfgInfo?.fcw
            val fcwr = if (llInputFctr.visibility == View.VISIBLE) et_input_fctr?.text.toString().toInt() else mAdascfgInfo?.fcwr
            val hdw = if (llInputHmttc.visibility == View.VISIBLE) et_input_hmttc?.text.toString().toDouble() else mAdascfgInfo?.hdw
            val hdwr = if (llInputHmtr.visibility == View.VISIBLE) et_input_hmtr?.text.toString().toInt() else mAdascfgInfo?.hdwr
            val rtc = if (llInputOffset.visibility == View.VISIBLE) et_input_offset?.text.toString().toDouble() else mAdascfgInfo?.rtc

            mCamera?.adasCfgInfo = AdasCfgInfo(
                    mAdascfgInfo?.enable,
                    fcw,
                    fcwr,
                    hdw,
                    hdwr,
                    et_input_height?.text.toString().toDouble(),
                    et_input_width?.text.toString().toDouble(),
                    rtc
            )
        }

        RxBus.getDefault().toObservable(AdasCfgChangeEvent::class.java)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(Consumer { event: AdasCfgChangeEvent? ->
                    run {
                        Logger.t(TAG).i("initListener adasCfgInfo = ${event?.adasCfgInfo}")
                        if (saveManually) {
                            saveManually = false
                            hideLoadingDialog()
                            checkValueModify(event?.adasCfgInfo)
                        } else {
                            setAdasCfg(event?.adasCfgInfo)
                        }
                    }
                }, ServerErrorHandler(TAG))
    }

    private fun valueInvalid(): Boolean {
        try {
            val cameraHeight = et_input_height?.text.toString().toDouble()
            if (cameraHeight <= 0 || cameraHeight >= 10) return true

            val vehicleWidth = et_input_width?.text.toString().toDouble()
            if (vehicleWidth <= 0 || vehicleWidth >= 10) return true

            if (llInputFcttc.visibility == View.VISIBLE) {
                val toDouble = et_input_fcttc?.text.toString().toDouble()
                if (toDouble < 0.5 || toDouble > 5) return true
            }
            if (llInputHmttc.visibility == View.VISIBLE) {
                val toDouble = et_input_hmttc?.text.toString().toDouble()
                if (toDouble < 0.5 || toDouble > 5) return true
            }
            if (llInputFctr.visibility == View.VISIBLE) {
                val toInt = et_input_fctr?.text.toString().toInt()
                if (toInt < 20 || toInt > 200) return true
            }
            if (llInputHmtr.visibility == View.VISIBLE) {
                val toInt = et_input_hmtr?.text.toString().toInt()
                if (toInt < 20 || toInt > 200) return true
            }
            if (llInputOffset.visibility == View.VISIBLE) {
//                val toDouble = et_input_offset?.text.toString().toDouble()
                // TODO: 2021/8/29 limit
            }
        } catch (ex: NumberFormatException) {
            Logger.t(TAG).e("valueInvalid NumberFormatException: $ex")
            return true
        }

        return false
    }

    private fun checkValueModify(adasCfgInfo: AdasCfgInfo?) {
        if (adasCfgInfo?.equals(mAdascfgInfo) == true) {
            btn_save_setting?.isEnabled = false
            Toast.makeText(this, "Please make sure you input the correct values.", Toast.LENGTH_LONG).show()
        } else {
            finish()
        }
    }

    private fun initView() {
        toolbar?.setNavigationOnClickListener { finish() }

        if (DebugHelper.isInDebugMode()) {
            llInputFcttc?.visibility = View.VISIBLE
            llInputFctr?.visibility = View.VISIBLE
            llInputHmttc?.visibility = View.VISIBLE
            llInputHmtr?.visibility = View.VISIBLE
            llInputTips?.visibility = View.VISIBLE
        }

        mCamera = VdtCameraManager.getManager().currentCamera as? EvCamera
        if (mCamera?.isAdasCfgAvailable == true) {
            val adasCfgInfo = mCamera?.adasCfgInfo
            Logger.t(TAG).i("initView adasCfgInfo = $adasCfgInfo")

            setAdasCfg(adasCfgInfo)
        }
    }

    private fun setAdasCfg(adasCfgInfo: AdasCfgInfo?) {
        mAdascfgInfo = adasCfgInfo

        et_input_height?.setText(adasCfgInfo?.cht?.toString())
        et_input_width?.setText(adasCfgInfo?.vwt?.toString())

        val toString = adasCfgInfo?.rtc?.toString()
        if (TextUtils.isEmpty(toString)) {
            llInputOffset?.visibility = View.GONE
        } else {
            llInputOffset?.visibility = View.VISIBLE
            et_input_offset?.setText(toString)
        }

        et_input_fcttc?.setText(adasCfgInfo?.fcw?.toString())
        et_input_fctr?.setText(adasCfgInfo?.fcwr?.toString())
        et_input_hmttc?.setText(adasCfgInfo?.hdw?.toString())
        et_input_hmtr?.setText(adasCfgInfo?.hdwr?.toString())

        btn_save_setting.isEnabled = false
    }

    private fun showLoadingDialog() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(this)
        }
        progressDialog?.show()
    }

    private fun hideLoadingDialog() {
        if (progressDialog != null && progressDialog?.isShowing == true) {
            try {
                progressDialog?.hide()
                progressDialog?.dismiss()
                progressDialog = null
            } catch (ex: Exception) {
                Logger.t(DevicesActivity.TAG).d("error" + ex.message)
            }
        }
    }

    override fun onDestroy() {
        if (progressDialog != null && progressDialog?.isShowing == true) {
            progressDialog?.dismiss()
            progressDialog = null
        }
        super.onDestroy()
    }

    private val mTextWatcher = object : TextWatcher {
        override fun afterTextChanged(s: Editable?) {
        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
        }

        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            btn_save_setting.isEnabled = true
        }
    }
}