package com.mk.autosecure.ui.activity.settings

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.Toast;
import androidx.appcompat.app.AppCompatDialog
import butterknife.ButterKnife
import com.mk.autosecure.HornApplication
import com.mk.autosecure.R
import com.mk.autosecure.libs.BaseActivity
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel
import com.mk.autosecure.libs.utils.DialogUtils
import com.mk.autosecure.rest.ServerErrorHandler
import com.mk.autosecure.ui.activity.DevicesActivity
import com.mk.autosecure.viewmodels.setting.SpaceInfoViewModel
import com.orhanobut.logger.Logger
import com.mkgroup.camera.CameraWrapper
import com.mkgroup.camera.EvCamera
import com.mkgroup.camera.VdtCameraManager
import com.mkgroup.camera.bean.CameraBean
import com.mkgroup.camera.command.EvCameraCmdConsts.MK.*
import com.mkgroup.camera.event.TCVNEvent
import com.mkgroup.camera.message.bean.*
import com.mkgroup.camera.model.SpaceInfo
import com.mkgroup.camera.utils.RxBus
import com.mkgroup.camera.utils.StringUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import kotlinx.android.synthetic.main.activity_tcvn.*
import kotlinx.android.synthetic.main.activity_tcvn.toolbar
import kotlinx.android.synthetic.main.activity_tcvn.tv_toolbarTitle

@RequiresActivityViewModel(SpaceInfoViewModel.ViewModel::class)
class TCVNActivity : BaseActivity<SpaceInfoViewModel.ViewModel>() {
    companion object {
        @JvmStatic
        fun launch(activity: Activity, tcvN01Bean: TCVN01Bean) {
            val intent = Intent(activity, TCVNActivity::class.java)
            intent.putExtra(CMD_MK_TCVN01, tcvN01Bean)
            intent.putExtra("Layout", CMD_MK_TCVN01)
            activity.startActivity(intent)
        }

        @JvmStatic
        fun launch(activity: Activity, tcvN02Bean: TCVN02Bean) {
            val intent = Intent(activity, TCVNActivity::class.java)
            intent.putExtra(CMD_MK_TCVN02, tcvN02Bean)
            intent.putExtra("Layout", CMD_MK_TCVN02)
            activity.startActivity(intent)
        }

        @JvmStatic
        fun launch(activity: Activity, tcvN03Bean: TCVN03Bean) {
            val intent = Intent(activity, TCVNActivity::class.java)
            intent.putExtra(CMD_MK_TCVN03, tcvN03Bean)
            intent.putExtra("Layout", CMD_MK_TCVN03)
            activity.startActivity(intent)
        }

        @JvmStatic
        fun launch(activity: Activity, tcvN04Bean: TCVN04Bean) {
            val intent = Intent(activity, TCVNActivity::class.java)
            intent.putExtra(CMD_MK_TCVN04, tcvN04Bean)
            intent.putExtra("Layout", CMD_MK_TCVN04)
            activity.startActivity(intent)
        }

        @JvmStatic
        fun launch(activity: Activity, tcvN05Bean: TCVN05Bean) {
            val intent = Intent(activity, TCVNActivity::class.java)
            intent.putExtra(CMD_MK_TCVN05, tcvN05Bean)
            intent.putExtra("Layout", CMD_MK_TCVN05)
            activity.startActivity(intent)
        }

        @JvmStatic
        fun launch(activity: Activity, cmd: String?) {
            val intent = Intent(activity, TCVNActivity::class.java)
//            intent.putExtra("cmd", cmd)
            intent.putExtra("Layout", cmd)
            activity.startActivity(intent)
        }
    }

    private val TAG = TCVNActivity::class.java.simpleName
    private var tcvn01: TCVN01Bean? = null
    private var tcvn02: TCVN02Bean? = null
    private var tcvn03: TCVN03Bean? = null
    private var tcvn04: TCVN04Bean? = null
    private var tcvn05: TCVN05Bean? = null
    private var evCamera: EvCamera? = null
    private var mCamera: CameraWrapper? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_tcvn)
        ButterKnife.bind(this)
        setupToolbar()
        initViews()
        initListener()
        Log.d(TAG, "onCreate")
        evCamera = VdtCameraManager.getManager().currentCamera as? EvCamera
        if (intent != null) {
            tcvn01 = intent.getSerializableExtra(CMD_MK_TCVN01) as TCVN01Bean?
            tcvn02 = intent.getSerializableExtra(CMD_MK_TCVN02) as TCVN02Bean?
            tcvn03 = intent.getSerializableExtra(CMD_MK_TCVN03) as TCVN03Bean?
            tcvn04 = intent.getSerializableExtra(CMD_MK_TCVN04) as TCVN04Bean?
            tcvn05 = intent.getSerializableExtra(CMD_MK_TCVN05) as TCVN05Bean?

            var keyLayout = intent.getStringExtra("Layout")
            setView(keyLayout)
        }
    }

    fun setupToolbar() {
        toolbar.setNavigationOnClickListener {
            finish()
        }
    }

    private fun initViews() {
        mCamera = VdtCameraManager.getManager().currentCamera
        if (mCamera != null) {
            viewModel.inputs.loadSpaceInfo()
        }
    }

    @SuppressLint("CheckResult")
    private fun initListener() {
        viewModel.outputs.spaceInfoData()
            .compose(bindToLifecycle())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ spaceInfo: SpaceInfo? ->
                this.updateSpaceInfo(
                    spaceInfo
                )
            }, ServerErrorHandler(TAG))
    }

    private fun updateSpaceInfo(spaceInfo: SpaceInfo?) {
        txt_mem_stt.text = getString(R.string.sdcard_working)
        txt_total_mem.text = StringUtils.getSpaceString(spaceInfo!!.total)
    }

    private fun initViewTCVN01() {
        if (tcvn01 != null) {
            Log.d(TAG, "CameraSN: ${tcvn01?.sn}")
            tv_toolbarTitle.text = getString(R.string.camera_base_info)
            txt_sup.text = tcvn01?.sup
            txt_type.text = tcvn01?.type
            txt_sn.text = tcvn01?.sn
            txt_plateNum.text = tcvn01?.plate_num
            txt_method_speed.text = tcvn01?.spd_method
            txt_pulse_cfg.text = tcvn01?.pulse_cfg
            txt_spd_limit.text = tcvn01?.spd_limit
            txt_last_modified.text = tcvn01?.last_modified
            txt_last_update.text = tcvn01?.last_updated
            if (StringUtils.isEmpty(tcvn01?.last_updated)) txt_last_update.visibility = View.GONE
            txt_sig_stt.text = tcvn01?.sig_stt
            if (StringUtils.isEmpty(tcvn01?.sig_stt)) txt_sig_stt.visibility = View.GONE
            txt_gps_stt.text = tcvn01?.gpS_stt
            if (StringUtils.isEmpty(tcvn01?.gpS_stt)) txt_gps_stt.visibility = View.GONE
            txt_mem_stt.text = tcvn01?.mem_stt
            txt_total_mem.text = getCurrentCameraWithSN(tcvn01?.sn)?.state?.sdCardUsage.toString()
            txt_cur_driver.text = tcvn01?.cur_driver
            txt_cont_drv_time.text = tcvn01?.cont_drv_time
            if (StringUtils.isEmpty(tcvn01?.cont_drv_time)) txt_cont_drv_time.visibility = View.GONE
            txt_gps_info.text = tcvn01?.gpS_info
            if (StringUtils.isEmpty(tcvn01?.gpS_info)) txt_gps_info.visibility = View.GONE
            txt_speed.text = tcvn01?.speed
            if (StringUtils.isEmpty(tcvn01?.speed)) txt_speed.visibility = View.GONE
            txt_time.text = tcvn01?.time
            txt_stop_time_cfg.text = tcvn01?.stop_time_cfg
            if (StringUtils.isEmpty(tcvn01?.stop_time_cfg)) txt_stop_time_cfg.visibility = View.GONE
        }
    }

    private fun initViewTCVN02() {
        if (tcvn02 != null) {
            Log.d(TAG, "driver: ${tcvn02?.drv_name}")
            tv_toolbarTitle.text = getString(R.string.tcvn02)
            txt_drv_name.text = tcvn02?.drv_name
            txt_license_id.text = tcvn02?.license_id
            txt_start_time.text = tcvn02?.start_time
            txt_start_gps.text = tcvn02?.start_GPS
            txt_finish_time.text = tcvn02?.finish_time
            txt_finish_gps.text = tcvn02?.finish_GPS

        }
    }

    private fun initViewTCVN03() {
        if (tcvn03 != null) {
            Log.d(TAG, "time prk: ${tcvn03?.time}")
            tv_toolbarTitle.text = getString(R.string.tcvn03)
            txt_prk_time.text = tcvn03?.time
            txt_gps.text = tcvn03?.gps
            txt_time_stop.text = tcvn03?.time_stop.toString()

        }
    }

    private fun initViewTCVN04() {
        if (tcvn04 != null) {
            Log.d(TAG, "time journey: ${tcvn04?.cur_time}")
            tv_toolbarTitle.text = getString(R.string.tcvn04)
            txt_cur_time.text = tcvn04?.cur_time
            txt_gps_04.text = tcvn04?.gps
            txt_speed_04.text = tcvn04?.speed

        }
    }

    private fun initViewTCVN05() {
        if (tcvn05 != null) {
            Log.d(TAG, "time record: ${tcvn05?.speed_record_time}")
            tv_toolbarTitle.text = getString(R.string.tcvn05)
            txt_spd_time_record.text = tcvn05?.speed_record_time
            txt_speed_list.text = tcvn05?.speed.toString()

        }
    }

    private fun getCurrentCameraWithSN(sn: String?): CameraBean? {
        var list: ArrayList<CameraBean>? = HornApplication.getComponent().currentUser().devices
        Log.d(TAG, "get CameraBeanList: ${list?.size}")
        var result: CameraBean? = null
        for (bean: CameraBean in list!!) {
            if (bean.sn.equals(sn)) {
                result = bean
            }
        }

        return result
    }

    @SuppressLint("CheckResult")
    fun setView(key: String?) {
        when (key) {
            CMD_MK_TCVN01 -> {
                ll_tcvn01.visibility = View.VISIBLE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN01()
            }
            CMD_MK_TCVN02 -> {
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.VISIBLE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN02()
            }
            CMD_MK_TCVN03 -> {
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.VISIBLE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN03()
            }
            CMD_MK_TCVN04 -> {
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.VISIBLE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN04()
            }
            CMD_MK_TCVN05 -> {
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.VISIBLE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN05()
            }
            CMD_MK_SET_DRIVER_INFO -> {
                tv_toolbarTitle.text = getString(R.string.set_driver_info)
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.VISIBLE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                ll_result_driver.visibility = View.GONE

                btn_save_driver_info.setOnClickListener {
                    Log.d(TAG, "onClick save driver info ")
                    showLoadingDialog()
                    val body = DriverInfoBody(
                        et_driver_name.text.toString(),
                        et_driver_license_no.text.toString(),
                        et_plate_number.text.toString()
                    )

                    evCamera?.setDriverInfoWithMK(body)

                    RxBus.getDefault().toObservable(
                        TCVNEvent::class.java)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({ tcvnEvent: TCVNEvent ->
                            Logger.t(DevicesActivity.TAG)
                                .i("initListener driverInfo = " + tcvnEvent.driverInfoBody.driverName)
                            et_driver_name.text = null
                            et_driver_license_no.text = null
                            et_plate_number.text = null
                            hideLoadingDialog()
                            showResultDriver(tcvnEvent.driverInfoBody)
                        },
                            ServerErrorHandler(
                                DevicesActivity.TAG
                            )
                        )
                }
            }

            CMD_MK_SETTING_CFG -> {
                tv_toolbarTitle.text = getString(R.string.setting_config)
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.VISIBLE
                ll_tcvn_inout.visibility = View.GONE

                btn_save_setting_cfg.setOnClickListener {
                    showLoadingDialog()
                    val date = et_lasted_modify.text
                    Log.d(TAG, "date: $date")
                    val body = SettingCfgBean(
                        et_lasted_modify.text.toString().trim()
                    )

                    evCamera?.settingCfgWithMK(body)

                    RxBus.getDefault().toObservable(
                        TCVNEvent::class.java)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({ tcvnEvent: TCVNEvent ->
                            Logger.t(DevicesActivity.TAG)
                                .i("initListener settingCfg = " + tcvnEvent.settingCfgBean.lasted_modify)
                            et_lasted_modify.text = null
                            hideLoadingDialog()
                            Toast.makeText(
                                this,
                                "SettingCfg success:  ${tcvnEvent.settingCfgBean.lasted_modify}",
                                Toast.LENGTH_SHORT
                            ).show()
                        }, {
                            hideLoadingDialog()
                            ServerErrorHandler(
                                DevicesActivity.TAG
                            )
                        })
                }
            }

            CMD_MK_INOUT -> {
                tv_toolbarTitle.text = getString(R.string.log_in)
                ll_tcvn01.visibility = View.GONE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.VISIBLE
                var isLogin = false
                btn_in.setOnClickListener {
                    if (!TextUtils.isEmpty(et_in.text.toString())) {

                        showLoadingDialog()
                        val body = InoutBean(Integer.valueOf(et_in.text.toString()), null)
                        isLogin = true
                        evCamera?.login_outCamera(body)
                    } else {
                        Toast.makeText(
                            this@TCVNActivity,
                            "Vui lòng nhập dữ liệu",
                            Toast.LENGTH_SHORT
                        ).show()
                    }

                }

                btn_out.setOnClickListener {
                    if (!TextUtils.isEmpty(et_out.text.toString())) {
                        showLoadingDialog()
                        val bodyOut = InoutBean(null, Integer.valueOf(et_out.text.toString()))
                        isLogin = false
                        evCamera?.login_outCamera(bodyOut)
                    } else {
                        Toast.makeText(
                            this@TCVNActivity,
                            "Vui lòng nhập dữ liệu",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
                RxBus.getDefault().toObservable(
                    TCVNEvent::class.java)
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({ tcvnEvent: TCVNEvent ->
                        Logger.t(TAG)
                            .i("initListener login = " + tcvnEvent.inoutBody.loginRQ.toString())

                        hideLoadingDialog()
                        val msg = if (isLogin) {
                            et_in.text = null
                            "Login success:   ${tcvnEvent.inoutBody.loginRQ}"
                        } else {
                            et_out.text = null
                            "Logout success:   ${tcvnEvent.inoutBody.logoutRQ}"
                        }
                        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
                    }, ServerErrorHandler(TAG))
            }

            else -> {
                ll_tcvn01.visibility = View.VISIBLE
                ll_tcvn02.visibility = View.GONE
                ll_tcvn03.visibility = View.GONE
                ll_tcvn04.visibility = View.GONE
                ll_tcvn05.visibility = View.GONE
                ll_tcvn_driver_info.visibility = View.GONE
                ll_tcvn_setting_cfg.visibility = View.GONE
                ll_tcvn_inout.visibility = View.GONE
                initViewTCVN01()
            }
        }
    }

    private fun showResultDriver(body: DriverInfoBody) {
        ll_result_driver.visibility = View.VISIBLE
        txt_driver_name.text = body.driverName;
        txt_driver_license.text = body.driver_license_No
        txt_plate_no.text = body.plate_Number
    }

    var progressDialog: AppCompatDialog? = null

    private fun showLoadingDialog() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(this)
        }
        progressDialog?.show()
    }

    private fun hideLoadingDialog() {
        if (progressDialog != null && progressDialog!!.isShowing) {
            try {
                progressDialog?.hide()
                progressDialog?.dismiss()
                progressDialog = null
            } catch (ex: Exception) {
                Logger.t(DevicesActivity.TAG).d("error" + ex.message)
            }
        }
    }
}