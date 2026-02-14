package com.mk.autosecure.ui.activity;

import static com.mk.autosecure.ui.activity.settings.AudioActivity.AUDIO_SETTING;
import static com.mk.autosecure.ui.activity.settings.NightVisionActivity.NIGHTVISION_SETTING;
import static com.mk.autosecure.ui.activity.settings.ProtectVoltageActivity.BALANCED_VOLTAGE;
import static com.mk.autosecure.ui.activity.settings.ProtectVoltageActivity.DAILY_DRIVER_VOLTAGE;
import static com.mk.autosecure.ui.activity.settings.ProtectVoltageActivity.EXTENDED_VOLTAGE;
import static com.mk.autosecure.ui.activity.settings.ProtectVoltageActivity.EXTREME_VOLTAGE;
import static com.mk.autosecure.ui.activity.settings.SenseActivity.SENSE_SETTING;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_FAILURE;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_START;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_SUCCESS;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;

import com.google.android.material.snackbar.Snackbar;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CameraSubscriber;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DebugHelper;
import com.mk.autosecure.libs.utils.DialogUtils;
import com.mk.autosecure.libs.utils.FirmwareUpgradeHelper;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest.request.CameraControlBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.response.DataUsageResponse;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.AdasCfgActivity;
import com.mk.autosecure.ui.activity.settings.ApnSettingActivity;
import com.mk.autosecure.ui.activity.settings.AudioActivity;
import com.mk.autosecure.ui.activity.settings.CalibActivity;
import com.mk.autosecure.ui.activity.settings.CameraInfoActivity;
import com.mk.autosecure.ui.activity.settings.CameraServerActivity;
import com.mk.autosecure.ui.activity.settings.DetectionActivity;
import com.mk.autosecure.ui.activity.settings.DirectSwitchActivity;
import com.mk.autosecure.ui.activity.settings.DirectTestActivity;
import com.mk.autosecure.ui.activity.settings.EventParamActivity;
import com.mk.autosecure.ui.activity.settings.ExboardActivity;
import com.mk.autosecure.ui.activity.settings.FirmwareUpdateActivity;
import com.mk.autosecure.ui.activity.settings.LensActivity;
import com.mk.autosecure.ui.activity.settings.MacActivity;
import com.mk.autosecure.ui.activity.settings.ModeVisionActivity;
import com.mk.autosecure.ui.activity.settings.NightVisionActivity;
import com.mk.autosecure.ui.activity.settings.ProtectVoltageActivity;
import com.mk.autosecure.ui.activity.settings.SenseActivity;
import com.mk.autosecure.ui.activity.settings.SpaceInfoActivity;
import com.mk.autosecure.ui.activity.settings.SradarActivity;
import com.mk.autosecure.ui.activity.settings.VideoQualityActivity;
import com.mk.autosecure.ui.activity.settings.VinMirrorActivity;
import com.mk.autosecure.ui.activity.settings.WifiModeActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FirmwareBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mkgroup.camera.event.AdasCfgChangeEvent;
import com.mkgroup.camera.event.ApnChangeEvent;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.event.FactoryResetEvent;
import com.mkgroup.camera.event.HdrModeChangeEvent;
import com.mkgroup.camera.event.MountSettingChangeEvent;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.event.SleepDelayChangeEvent;
import com.mkgroup.camera.event.SupportWlanChangeEvent;
import com.mkgroup.camera.event.VoltageChangeEvent;
import com.mkgroup.camera.log.CameraLogClient;
import com.mkgroup.camera.message.bean.AdasCfgInfo;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.message.bean.MountVersion;
import com.mkgroup.camera.message.bean.RecordConfigListBean;
import com.mkgroup.camera.message.bean.TCVN01Bean;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/8/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class DevicesActivity extends RxFragmentActivity {
    public static final String TAG = DevicesActivity.class.getSimpleName();

    public static void launch(Context context, String sn) {
        Intent intent = new Intent(context, DevicesActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        context.startActivity(intent);
    }

    public static void launch(Context context, CameraBean cameraBean) {
        Intent intent = new Intent(context, DevicesActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        context.startActivity(intent);
    }

    public static void launch(Context context, FleetCameraBean fleetCamera) {
        Intent intent = new Intent(context, DevicesActivity.class);
        intent.putExtra(IntentKey.FLEET_CAMERA, fleetCamera);
        context.startActivity(intent);
    }

    private PublishSubject<ErrorEnvelope> error = PublishSubject.create();

    // low level error, network etc.
    private PublishSubject<Throwable> llError = PublishSubject.create();
    BehaviorSubject<CameraLogClient.CopyLogStatus> status = BehaviorSubject.create();

    protected AppCompatDialog progressDialog;

    //设置是否发生变化
    private volatile boolean isSettingChanged = false;

    private CurrentUser currentUser;
    private TCVN01Bean mTCVN01Bean = null;
    private EvCamera mEVCamera = null;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.ll_setting_request)
    LinearLayout llSettingRequest;
    @BindView(R.id.iv_request)
    ImageView ivRequest;
    @BindView(R.id.tv_request)
    TextView tvRequest;
    @BindView(R.id.view_shadow)
    View viewShadow;

    @BindView(R.id.rl_fourg_plan)
    RelativeLayout rlFourgPlan;
    @BindView(R.id.btn_trial)
    Button btnTrial;
    @BindView(R.id.tv_fourg_plan)
    TextView tvFourgPlan;
    @BindView(R.id.tv_plan_status)
    TextView tvPlanStatus;
    @BindView(R.id.iv_plan_more)
    ImageView ivPlanMore;
    @BindView(R.id.tv_plan_content)
    TextView tvPlanContent;
    @BindView(R.id.v_divider1)
    View vDivider1;
    @BindView(R.id.rl_expired)
    RelativeLayout rlExpired;
    @BindView(R.id.v_divider2)
    View vDivider2;

    @BindView(R.id.rl_data_usage)
    RelativeLayout rlDataUsage;
    @BindView(R.id.tv_data_usage)
    TextView tvDataUsage;

    @BindView(R.id.tv_upToDate)
    TextView tvUpToDate;

    @BindView(R.id.rl_recording)
    RelativeLayout rlRecording;
    @BindView(R.id.switch_recording)
    Switch switchRecording;

    @BindView(R.id.ll_advanced_setting)
    LinearLayout llAdvancedSetting;

    @BindView(R.id.ll_sensitivity)
    LinearLayout llSensitivity;

    @BindView(R.id.rl_audio)
    RelativeLayout rlAudio;

    @BindView(R.id.rl_nightVision)
    LinearLayout rlNightVision;

    @BindView(R.id.rl_modeVision)
    LinearLayout rlModeVision;

    @BindView(R.id.rl_logoLED)
    RelativeLayout rlLogoLED;

    @BindView(R.id.switch_LogoLED)
    Switch switchLogoLED;

    @BindView(R.id.rl_hdr)
    RelativeLayout rlHDR;
    @BindView(R.id.switch_hdr)
    Switch switchHDR;

    @BindView(R.id.rl_hdr_auto)
    RelativeLayout rlHdrAuto;
    @BindView(R.id.tv_hdr_mode)
    TextView tvHdrMode;

    @BindView(R.id.rl_sdcard)
    RelativeLayout rlSdcard;

    @BindView(R.id.rl_detection)
    RelativeLayout rlDetection;

    @BindView(R.id.ll_wifi_direct)
    LinearLayout llWifiDirect;

    @BindView(R.id.ll_lens)
    LinearLayout llLens;

    @BindView(R.id.rl_factoryReset)
    RelativeLayout rlFactoryReset;

    @BindView(R.id.ll_fvt_setting)
    LinearLayout llFvtSetting;

    @BindView(R.id.ll_evcam_setting)
    LinearLayout llEvcamSetting;

    @BindView(R.id.ll_calib_camera)
    LinearLayout llCalibCamera;

    @BindView(R.id.ll_adas_settings)
    LinearLayout llAdasSettings;

    @BindView(R.id.tv_config)
    TextView tvConfig;

    @BindView(R.id.tv_codec)
    TextView tvCodec;

    @BindView(R.id.ll_vin_mirror)
    LinearLayout llVinMirror;

    @BindView(R.id.ll_Mac_Wlan0)
    LinearLayout llMacWlan0;

    @BindView(R.id.ll_set_Sradar)
    LinearLayout llSetSradar;

    @BindView(R.id.ll_Exboard)
    LinearLayout ll_Exboard;

    @BindView(R.id.tv_debug_description)
    TextView tvDebugDescription;

    @BindView(R.id.ll_camera_server)
    LinearLayout llCameraServer;

    @BindView(R.id.ll_ip_address)
    LinearLayout llIpAddress;
    @BindView(R.id.tv_address)
    TextView tvAddress;

    @BindView(R.id.ll_video_quality)
    LinearLayout llVideoQuality;

    @BindView(R.id.ll_voltage_setting)
    LinearLayout llVoltageSetting;
    @BindView(R.id.tv_voltage_mode)
    TextView tvVoltageMode;

    @BindView(R.id.ll_sleep_delay)
    LinearLayout llSleepDelay;
    @BindView(R.id.tv_sleep_delay)
    TextView tvSleepDelay;

    @BindView(R.id.ll_apn_setting)
    LinearLayout llApnSetting;
    @BindView(R.id.tv_apn_setting)
    TextView tvApnSetting;

    @BindView(R.id.ll_wifi_mode)
    LinearLayout llWifiMode;

    @BindView(R.id.ll_event_detection)
    LinearLayout llEventDetection;

    @BindView(R.id.rl_unbind)
    RelativeLayout rlUnbind;

    @OnClick(R.id.rl_camera_info)
    public void onCameraInfoClicked() {
        if (mCamera != null) {
            CameraInfoActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            CameraInfoActivity.launch(this, mCameraBean);
        } else if (mFleetCamera != null) {
            CameraInfoActivity.launch(this, mFleetCamera);
        }
    }


    @OnClick({R.id.rl_fourg_plan, R.id.rl_expired})
    public void toWebView() {
        if (mCameraBean != null) {
            WebPlanActivity.launch(this, mCameraBean.sn, false);
        } else if (mCamera != null) {
            WebPlanActivity.launch(this, mCamera.getSerialNumber(), false);
        }
    }

    @OnClick(R.id.ll_firmware)
    public void onFirmwareClicked() {
        if (mCamera != null) {
            FirmwareUpdateActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            FirmwareUpdateActivity.launch(this, mCameraBean);
        } else if (mFleetCamera != null) {
            FirmwareUpdateActivity.launch(this, mFleetCamera);
        }
    }


    @OnClick(R.id.ll_sensitivity)
    public void toSensitivity() {
        if (mCamera != null) {
            SenseActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            SenseActivity.launch(this, mCameraBean);
        }
    }

    @OnClick(R.id.rl_audio)
    public void onAudioClicked() {
        if (mCamera != null) {
            AudioActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            AudioActivity.launch(this, mCameraBean);
        }
    }

    @OnClick(R.id.rl_nightVision)
    public void onNightVisionClicked() {
        if (mCamera != null) {
            NightVisionActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            NightVisionActivity.launch(this, mCameraBean);
        }
    }

    @OnClick(R.id.rl_modeVision)
    public void onModeVisionClicked() {
        if (mCamera != null) {
            ModeVisionActivity.launch(this, mCamera.getSerialNumber());
        } else if (mCameraBean != null) {
            ModeVisionActivity.launch(this, String.valueOf(mCameraBean));
        }
    }



    @OnClick(R.id.rl_hdr_auto)
    public void onHdrMode() {
        if (mCamera != null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            final String[] items = new String[]{getString(R.string.on), getString(R.string.auto), getString(R.string.off)};

            int hdrMode = mCamera.getHdrMode();
            Logger.t(TAG).d("hdrMode: " + hdrMode);

            builder.setSingleChoiceItems(items, hdrMode, (dialog, which) -> {
                Logger.t(TAG).d("setHdrMode: " + which);
                mCamera.setHdrMode(which);
                dialog.dismiss();
            });

            builder.show();
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.rl_sdcard)
    public void onSDCardClicked() {
        if (mCamera != null) {
            SpaceInfoActivity.launch(this, false);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.rl_detection)
    public void toDetection() {
        if (mCamera != null) {
            DetectionActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_wifi_direct)
    public void wifiDirect() {
        if (mCamera != null) {
            DirectSwitchActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_lens)
    public void lensUpDown() {
        if (mCamera != null) {
            LensActivity.Companion.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    private void showModeSelectionPopup() {
        final String[] modes = getResources().getStringArray(R.array.camera_modes);

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Chọn chế độ ghi hình");
        builder.setItems(modes, (dialog, which) -> {
            String selectedMode = modes[which];
            Toast.makeText(this, "Chọn chế độ: " + selectedMode, Toast.LENGTH_SHORT).show();

            // Gửi chế độ đã chọn lên API
            sendModeToAPI(selectedMode);
        });
        builder.show();
    }

    private void sendModeToAPI(String mode) {
        if (mCamera != null) {
            try {
                JSONObject setting = new JSONObject();
                setting.put("recording_mode", mode);
                mCamera.setMountSettings(setting.toString());

                Toast.makeText(this, "Đã gửi chế độ " + mode + " thành công!", Toast.LENGTH_SHORT).show();
            } catch (JSONException e) {
                e.printStackTrace();
                Toast.makeText(this, "Lỗi khi gửi chế độ ghi hình", Toast.LENGTH_SHORT).show();
            }
        } else {
            Toast.makeText(this, "Không tìm thấy camera để gửi chế độ", Toast.LENGTH_SHORT).show();
        }
    }

//    @OnClick(R.id.ll_setting_record_cord)
//    public void onRecordModeClicked() {
//        showModeSelectionPopup();
//    }

    @OnClick(R.id.ll_power_cord)
    public void onPowerCord() {
        DirectTestActivity.launch(this, false);
    }

    @OnClick(R.id.ll_network)
    public void onNetwork() {
        if (mCamera != null) {
//            List<FleetCameraBean> devices = HornApplication.getComponent().fleetInfo().getDevices();
//            Logger.t(TAG).d("onNetwork devices: " + devices);
//            boolean owner = false;
//            for (FleetCameraBean cameraBean : devices) {
//                if (cameraBean != null && cameraBean.getCameraSN().equals(mCamera.getSerialNumber())) {
//                    owner = true;
//                    break;
//                }
//            }
//
//            if (owner) {
//                NetworkTestActivity.launch(this, false);
//            } else {
//                Toast.makeText(DevicesActivity.this, getString(R.string.camera_not_fleet_devices), Toast.LENGTH_SHORT).show();
//            }
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_camera_tour)
    public void onCameraTour() {
        if (mCamera != null) {
//            List<FleetCameraBean> devices = HornApplication.getComponent().fleetInfo().getDevices();
//            Logger.t(TAG).d("onCameraTour devices: " + devices);
//            boolean owner = false;
//            for (FleetCameraBean cameraBean : devices) {
//                if (cameraBean != null && cameraBean.getCameraSN().equals(mCamera.getSerialNumber())) {
//                    owner = true;
//                    break;
//                }
//            }

//            if (owner) {
//                SetupFleetActivity.launch(this);
//            } else {
//                Toast.makeText(DevicesActivity.this, getString(R.string.camera_not_fleet_devices), Toast.LENGTH_SHORT).show();
//            }
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.rl_factoryReset)
    public void onFactoryResetClick() {
        DialogHelper.showFactoryResetDialog(this, () -> {
            if (mCamera != null) {
                mCamera.factoryReset();
                showLoadingDialog();
            }
        });
    }

    @OnClick(R.id.ll_record_config)
    public void onRecordConfig() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);

            List<RecordConfigListBean.ConfigListBean> recordConfigList = ((EvCamera) mCamera).getRecordConfigList();
            Logger.t(TAG).d("recordConfigList: " + recordConfigList);

            String curRecordConfig = ((EvCamera) mCamera).getCurRecordConfig();
            Logger.t(TAG).d("curRecordConfig: " + curRecordConfig);
            int index = 0;

            String[] items = new String[recordConfigList.size()];
            for (int i = 0; i < items.length; i++) {
                RecordConfigListBean.ConfigListBean listBean = recordConfigList.get(i);
                String name = listBean.getName();
                items[i] = name;
                if (curRecordConfig.equals(name)) {
                    index = i;
                }
            }

            builder.setSingleChoiceItems(items, index, (dialog, which) -> {
                Logger.t(TAG).d("setCurRecordConfig: " + which);
                ((EvCamera) mCamera).setCurRecordConfig(which);
                dialog.dismiss();
            });

            builder.show();
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_set_Cover)
    public void onSradarConfig() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);

            String curRecordConfig = ((EvCamera) mCamera).getCurRecordConfig();
            int index = 0;

            String[] displayItems = new String[]{
                    "IR_lens_stop", "IR_lens_wide", "IR_lens_tele", "Wiper_on",
                    "Wiper_off", "Wiper_Washer_on",
                    "Wiper_Washer_off", "IrLed_force_on", "IrLed_force_off", "IrMode",
                    "IR_lens_lv1", "IR_lens_lv2", " Factory_reset"
            };

            // Thay đổi thành dữ liệu JSON theo yêu cầu
            String[] valueItems = new String[]{
                    "{\"mode\":1}",
                    "{\"mode\":2}",
                    "{\"mode\":3}",
                    "{\"mode\":4}",
                    "{\"mode\":5}",
                    "{\"mode\":6}",
                    "{\"mode\":7}",
                    "{\"mode\":8}",
                    "{\"mode\":9}",
                    "{\"mode\":10}",
                    "{\"mode\":11}",
                    "{\"mode\":12}",
                    "{\"mode\":13}"
            };

            for (int i = 0; i < valueItems.length; i++) {
                if (curRecordConfig.equals(valueItems[i])) {
                    index = i;
                }
            }

            builder.setSingleChoiceItems(displayItems, index, (dialog, which) -> {
                ((EvCamera) mCamera).setStatusCover(valueItems[which]);
                dialog.dismiss();
            });

            builder.show();
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }



    @OnClick(R.id.ll_calib_camera)
    public void onCalibCamera() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            if (!mCamera.isCalibCameraAvailable()) {
                Toast.makeText(DevicesActivity.this, R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
                return;
            }

            CalibActivity.launch(this, false);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_adas_settings)
    public void onAdasSettings() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            if (!mCamera.isAdasCfgAvailable()) {
                Toast.makeText(DevicesActivity.this, R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
                return;
            }

            AdasCfgActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_force_codec)
    public void onForceCodec() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            final String[] items = new String[]{getString(R.string.off), getString(R.string.on)};

            int forceCodec = ((EvCamera) mCamera).getForceCodec();
            Logger.t(TAG).d("forceCodec: " + forceCodec);

            builder.setSingleChoiceItems(items, forceCodec, (dialog, which) -> {
                Logger.t(TAG).d("setForceCodec: " + which);
                ((EvCamera) mCamera).setForceCodec(which);
                dialog.dismiss();
            });

            builder.show();
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_vin_mirror)
    public void onVinMirror() {
        if (mCamera != null) {
            VinMirrorActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_Mac_Wlan0)
    public void onMAC() {
        if (mCamera != null) {
            MacActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_set_Sradar)
    public void onSradar() {
        if (mCamera != null) {
            SradarActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_Exboard)
    public void onExboard() {
        if (mCamera != null) {
            ExboardActivity.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_camera_server)
    public void toCameraServer() {
        if (mCamera != null) {
            CameraServerActivity.launch(this);
        }
    }

    @OnClick(R.id.ll_video_quality)
    public void toQuality() {
        if (mCamera != null) {
            VideoQualityActivity.launch(this);
        }
    }

    @OnClick(R.id.ll_voltage_setting)
    public void toVoltageSetting() {
        if (mCamera != null) {
            ProtectVoltageActivity.Companion.launch(this);
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_sleep_delay)
    public void onSleepDelay() {
        if (mCamera != null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            final String[] items = new String[]{getString(R.string._30s), getString(R.string._1min),
                    getString(R.string._2min), getString(R.string._5min)};

            int sleepDelay = mCamera.getParkSleepDelay();
            Logger.t(TAG).d("sleepDelay: " + sleepDelay);
            int i = sleepDelay / 60 == 5 ? 3 : sleepDelay / 60;

            TextView textView = new TextView(this);
            textView.setText(R.string.driving_timeout_tips);
            textView.setPadding(ViewUtils.dp2px(16), ViewUtils.dp2px(16), ViewUtils.dp2px(16), 0);
            builder.setCustomTitle(textView);

            builder.setSingleChoiceItems(items, i, (dialog, which) -> {
                Logger.t(TAG).d("setParkSleepDelay: " + which);
                mCamera.setParkSleepDelay(which);
                dialog.dismiss();
            });

            builder.show();
        } else {
            Toast.makeText(DevicesActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_apn_setting)
    public void toApnSetting() {
        if (mCamera != null) {
            ApnSettingActivity.Companion.launch(this);
        }
    }

    @OnClick(R.id.ll_wifi_mode)
    public void toWifiMode() {
        if (mCamera != null) {
            WifiModeActivity.launch(this);
        }
    }

    @OnClick(R.id.ll_event_detection)
    public void toDetectionParam() {
        if (mCamera != null) {
            EventParamActivity.Companion.launch(this);
        }
    }

    @OnClick(R.id.btn_unbind)
    public void onUnBindClicked() {
        DialogHelper.showUnbindConfirmDialog(this, () -> {
            if (!TextUtils.isEmpty(serialNum)) {
                unbindDevices(serialNum);
            }
        });
    }

    private CameraWrapper mCamera;

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private String serialNum;

    private boolean logoFromUser = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_devices);
        ButterKnife.bind(this);
        setupToolbar();

        mEVCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();

        if (getIntent() != null) {
            serialNum = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
            mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
            mFleetCamera = (FleetCameraBean) getIntent().getSerializableExtra(IntentKey.FLEET_CAMERA);

            Logger.t(TAG).e("serialNum: " + serialNum);
            if (mCameraBean != null) Logger.t(TAG).e("mCameraBean: " + mCameraBean.sn);
            if (mFleetCamera != null)
                Logger.t(TAG).e("mFleetCamera: " + mFleetCamera.getSn());
        }

        currentUser = HornApplication.getComponent().currentUser();

        if (mCameraBean != null) {
            String string = HornApplication.getSettingResult();
            Logger.t(TAG).d("current setting request: " + string);
            if (!TextUtils.isEmpty(string)) {
                updateSettingUI(string);
            } else {
                ApiService.createApiService().getCameras()
                        .compose(Transformers.switchSchedulers())
                        .subscribe(new CameraSubscriber());
            }
        } else if (mFleetCamera != null) {

        } else if (!TextUtils.isEmpty(serialNum)) {
            mCamera = VdtCameraManager.getManager().getCamera(serialNum);
        }

        if (TextUtils.isEmpty(serialNum)) {
            if (mCameraBean != null) {
                serialNum = mCameraBean.sn;
            } else if (mFleetCamera != null) {
                serialNum = mFleetCamera.getSn();
            }
        }

        switchRecording.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).d("switchRecording = " + isChecked);
            if (mCamera != null) {
                if (isChecked && mCamera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
                    switchRecording.setChecked(true);
                    mCamera.startRecording();
                } else if (!isChecked && mCamera.getRecordState() != VdtCamera.STATE_RECORD_STOPPED) {
                    switchRecording.setChecked(false);
                    mCamera.stopRecording();
                }
            }
        });

        switchHDR.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (mCamera != null) {
                mCamera.setHdrMode(isChecked ? 0 : 2);
            } else {
                switchHDR.setChecked(!isChecked);
            }
        });

        switchLogoLED.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).i("switchLogoLED onCheckedChange: isChecked = " + isChecked + " logoFromUser = " + logoFromUser);
            if (logoFromUser) {
                setCameraMountSetting(MountSetting.KEY_LOGO_LED, isChecked);
            } else {
                logoFromUser = true;
            }
        });
    }

    private void onSettingChangeEvent(SettingChangeEvent changeEvent) {
        Logger.t(TAG).d("onSettingChangeEvent: " + changeEvent.getAction() + "--" + changeEvent.isUpdated());
        if (ACTION_FAILURE.equals(changeEvent.getAction()) || ACTION_SUCCESS.equals(changeEvent.getAction())) {
            updateSettingUI(changeEvent.getAction());
        }
    }

    private void onAdasCfgChange(AdasCfgChangeEvent event) {
        AdasCfgInfo adasCfgInfo = event.getAdasCfgInfo();
        Logger.t(TAG).d("onAdasCfgChange: " + adasCfgInfo);
        llAdasSettings.setVisibility(View.GONE);
    }

    private void updateSettingUI(String status) {
        switch (status) {
            case ACTION_START:
                viewShadow.setVisibility(View.VISIBLE);
                viewShadow.setOnTouchListener((v, event) -> true);
                llSettingRequest.setVisibility(View.VISIBLE);
                llSettingRequest.setBackgroundResource(R.color.colorApplySetting);
                ivRequest.setImageResource(R.drawable.icon_setting_loading);
                tvRequest.setText(R.string.setting_requesting);
                break;
            case ACTION_FAILURE:
                viewShadow.setVisibility(View.GONE);
                llSettingRequest.setVisibility(View.VISIBLE);
                llSettingRequest.setBackgroundResource(R.color.colorSettingFailed);
                ivRequest.setImageResource(R.drawable.icon_setting_fail);
                tvRequest.setText(R.string.setting_request_fail);

                //更新设置失败，退回旧设置
                if (currentUser != null) {
                    ArrayList<CameraBean> devices = currentUser.getDevices();
                    for (CameraBean cameraBean : devices) {
                        if (cameraBean != null && mCameraBean != null && cameraBean.sn.equals(mCameraBean.sn)) {
                            mCameraBean = cameraBean;
                            updateFourGStateUI();
                            break;
                        }
                    }
                }

                new Handler().postDelayed(() -> {
                    llSettingRequest.setVisibility(View.GONE);
                    HornApplication.setSettingResult("");
                }, 6000);
                break;
            case ACTION_SUCCESS:
                viewShadow.setVisibility(View.GONE);
                llSettingRequest.setVisibility(View.VISIBLE);
                llSettingRequest.setBackgroundResource(R.color.colorSettingApplied);
                ivRequest.setImageResource(R.drawable.icon_setting_success);
                tvRequest.setText(R.string.setting_request_success);

                //更新设置成功，刷新设置
                ApiService.createApiService().getCameras()
                        .compose(Transformers.switchSchedulers())
                        .subscribe(new CameraSubscriber());

                new Handler().postDelayed(() -> {
                    llSettingRequest.setVisibility(View.GONE);
                    HornApplication.setSettingResult("");
                }, 3000);
                break;
        }
    }

    private void onCameraList(Optional<ArrayList<CameraBean>> listOptional) {
        ArrayList<CameraBean> cameraBeans = listOptional.get();
        for (CameraBean bean : cameraBeans) {
            if (bean != null && mCameraBean != null && bean.sn.equals(mCameraBean.sn)) {
                Logger.t(TAG).e("cameraBean: " + bean.toString());
                mCameraBean = bean;
                updateFourGStateUI();
                break;
            }
        }
    }

    private void onFleetCameraList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeans = listOptional.get();
        for (FleetCameraBean bean : cameraBeans) {
            if (bean != null && mFleetCamera != null
                    && bean.getSn().equals(mFleetCamera.getSn())) {
                Logger.t(TAG).e("onFleetCameraList: " + bean.toString());
                mFleetCamera = bean;
                updateFleetStateUI();
                break;
            }
        }
    }

    private void query4GPlan(String sn) {
        Logger.t(TAG).d("query4GPlan ownerDevice: " + currentUser.ownerDevice(sn));
        if (currentUser.ownerDevice(sn)) {
            if (Constants.isFleet()) {
                ApiClient.createApiService().getCurrentSub(sn)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(new BaseObserver<DataUsageResponse>() {
                            @Override
                            protected void onHandleSuccess(DataUsageResponse data) {
                                onDataUsage(data);
                            }
                        });
            } else {
                ApiService.createApiService().getCurrentSub(sn)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(new BaseObserver<SubscribeResponse>() {
                            @Override
                            protected void onHandleSuccess(SubscribeResponse data) {
                                currentPlan(data);
                            }
                        });
            }
        }
    }

    private void onDataUsage(DataUsageResponse data) {
        List<DataUsageResponse.CycleUsageBean> cycleUsage = data.getCycleUsage();
        if (cycleUsage != null && cycleUsage.size() > 0) {
            DataUsageResponse.CycleUsageBean usageBean = cycleUsage.get(0);
            int inKB = usageBean.getDataUsageInKB();

            String plan = inKB / 1024 / 1024 > 0 ? String.format(getString(R.string._gb), inKB / 1024 / 1024)
                    : String.format(getString(R.string._mb), inKB / 1024);
            tvDataUsage.setText(plan);
        }
    }

    private void currentPlan(SubscribeResponse response) {
        String status = response.getStatus();
        Logger.t(TAG).d("status: " + status);
        if ("none".equals(status)) {

            tvPlanStatus.setBackgroundResource(R.drawable.bg_plan_subscribe);
            tvPlanStatus.setText(R.string.subscribe);
            tvPlanStatus.setVisibility(View.VISIBLE);

            tvPlanContent.setVisibility(View.GONE);
            ivPlanMore.setVisibility(View.GONE);
            btnTrial.setVisibility(View.GONE);

            rlExpired.setVisibility(View.GONE);
            vDivider2.setVisibility(View.GONE);

        } else if ("in_service".equals(status) || "paid".equals(status)) {

            long ended = response.getSubscriptionEnded();

            boolean renew = getRenew(ended);
            if (renew) {
                rlExpired.setVisibility(View.VISIBLE);
                vDivider2.setVisibility(View.GONE);
            } else {
                rlExpired.setVisibility(View.GONE);
                vDivider2.setVisibility(View.GONE);
            }

            SubscribeResponse.CurrentSubCycleBean currentSubCycle = response.getCurrentSubCycle();
            int usageInKB = currentSubCycle.getCtdDataUsageInKB();
            int totalQuotaInKB = currentSubCycle.getTotalQuotaInKB();
            int temp = (totalQuotaInKB - usageInKB) > 0 ? (totalQuotaInKB - usageInKB) : 0;
            String plan = temp / 1024 / 1024 > 0 ? String.format(getString(R.string.camera_plan_gb), temp / 1024 / 1024)
                    : String.format(getString(R.string.camera_plan_mb), temp / 1024);
            tvPlanContent.setText(plan);
            tvPlanContent.setVisibility(View.VISIBLE);
            ivPlanMore.setVisibility(View.VISIBLE);

            tvPlanStatus.setVisibility(View.GONE);

            String ratePlanName = response.getCurrentRatePlanSubscription().getRatePlanName();
            if (ratePlanName.contains("trial")) {
                btnTrial.setVisibility(View.VISIBLE);
            } else {
                btnTrial.setVisibility(View.GONE);
            }

        } else if ("suspended".equals(status)) {

            tvPlanStatus.setBackgroundResource(R.drawable.bg_plan_suspended);
            tvPlanStatus.setText(R.string.suspended);
            tvPlanStatus.setVisibility(View.VISIBLE);

            tvPlanContent.setVisibility(View.GONE);
            ivPlanMore.setVisibility(View.GONE);
            btnTrial.setVisibility(View.GONE);

            rlExpired.setVisibility(View.GONE);
            vDivider2.setVisibility(View.GONE);

        } else if ("canceled".equals(status)) {
        } else if ("expired".equals(status)) {

            tvPlanStatus.setBackgroundResource(R.drawable.bg_plan_expired);
            tvPlanStatus.setText(R.string.expired);
            tvPlanStatus.setVisibility(View.VISIBLE);

            tvPlanContent.setVisibility(View.GONE);
            ivPlanMore.setVisibility(View.GONE);
            btnTrial.setVisibility(View.GONE);

            rlExpired.setVisibility(View.GONE);
            vDivider2.setVisibility(View.GONE);
        }
    }

    private boolean getRenew(long ended) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(ended);
        int endDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int endDateYear = calendar.get(Calendar.YEAR);

        long currentTime = System.currentTimeMillis();
        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        if (endDateYear == currentDateYear) {
            if (endDateDay - currentDateDay < 8) {
                return true;
            }
        }
        return false;
    }

    @Override
    protected void onResume() {
        super.onResume();
        initView();
        initEvent();

        if (mCameraBean != null && mCameraBean.is4G != null && mCameraBean.is4G) {
            query4GPlan(mCameraBean.sn);
        } else if (mCamera != null && mCamera.getMountVersion().support_4g) {
            query4GPlan(mCamera.getSerialNumber());
        } else if (mFleetCamera != null) {
            query4GPlan(mFleetCamera.getSn());
        }

        CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(serialNum);
        Logger.t(TAG).e("cameraItem: " + cameraItem);
        if (cameraItem != null) {
            checkFirmwareVersion(cameraItem.getHardwareName(), cameraItem.getApiVersion(), cameraItem.getBspVersion());
        } else if (mCameraBean != null && mCameraBean.state != null) {
            checkFirmwareVersion(mCameraBean.hardwareVersion, mCameraBean.state.firmwareShort, mCameraBean.state.firmware);
        } else if (mFleetCamera != null) {
            checkFirmwareVersion(mFleetCamera.getHardwareVersion(), mFleetCamera.getFirmwareShort(), mFleetCamera.getFirmware());
        }

        if (mCamera != null) {
            boolean showQuality = PreferenceUtils.getBoolean(PreferenceUtils.SHOW_VIDEO_QUALITY, false);

            if (showQuality && mCamera instanceof VdtCamera) {
                llVideoQuality.setVisibility(View.VISIBLE);
            }

//            boolean showDebug = PreferenceUtils.getBoolean(PreferenceUtils.SHOW_DEBUG_SETTING, false);
//            UserLogin fleetUser = currentUser.getUserLogin();

            if (DebugHelper.isInDebugMode()) {
                tvDebugDescription.setVisibility(View.VISIBLE);
                llCameraServer.setVisibility(View.VISIBLE);

                if (mCamera.isWLanModeAvailable()) {
                    boolean supportWlan = mCamera.getSupportWlan();
                    Logger.t(TAG).d("supportWlan: " + supportWlan);
                    if (supportWlan) {
                        llWifiMode.setVisibility(View.VISIBLE);
                    }
                }
            }
        }
    }

    private void initView() {
        if (mCamera != null) {
            updateCameraStateUI();
        } else if (mCameraBean != null) {
            updateFourGStateUI();
        } else if (mFleetCamera != null) {
            updateFleetStateUI();
        }
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));

        currentUser.devicesObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraList, new ServerErrorHandler(TAG));

        currentUser.fleetDevicesObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onFleetCameraList, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(CameraStateChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHandleCameraStateChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(MountSettingChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountSettingChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(HdrModeChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHdrModeChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(FactoryResetEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onFactoryResetEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(VoltageChangeEvent.class)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(this::onVoltageChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(SleepDelayChangeEvent.class)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(this::onDelayChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(ApnChangeEvent.class)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(this::onApnChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(SupportWlanChangeEvent.class)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(this::onSupportWlanEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(SettingChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSettingChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(AdasCfgChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAdasCfgChange, new ServerErrorHandler(TAG));

        error
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onUnbindCameraError, new ServerErrorHandler(TAG));

        llError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLowLevelError, new ServerErrorHandler(TAG));
    }

    @SuppressLint("CheckResult")
    private void checkFirmwareVersion(String hardwareVersion, String apiVersion, String bspVersion) {
        Gson gson = HornApplication.getComponent().gson();
        if (Constants.isFleet()) {
            FirmwareBean firmwareBean = gson.fromJson(PreferenceUtils.getString(PreferenceUtils.KEY_LATEST_FLEET_FIRMWARE, null),
                    new TypeToken<FirmwareBean>() {
                    }.getType());
            Logger.t(TAG).e("latestFleetFirmware: " + firmwareBean);
            FirmwareBean newerFirmwareBean = (FirmwareBean) FirmwareUpgradeHelper.getNewerFirmware(Optional.ofNullable(firmwareBean), hardwareVersion, apiVersion, bspVersion);
            if (newerFirmwareBean != null) {
                showCurrentVersion(newerFirmwareBean.getFirmwareShort(), newerFirmwareBean.getFirmware(), apiVersion, bspVersion);
            }
        } else {
            List<Firmware> latestFirmwareList = gson.fromJson(PreferenceUtils.getString(PreferenceUtils.KEY_LATEST_FIRMWARE_LIST, null),
                    new TypeToken<List<Firmware>>() {
                    }.getType());
            Logger.t(TAG).e("latestFirmwareList: " + latestFirmwareList);
            Firmware newerFirmware = (Firmware) FirmwareUpgradeHelper.getNewerFirmware(latestFirmwareList, hardwareVersion, apiVersion, bspVersion);
            if (newerFirmware != null) {
                showCurrentVersion(newerFirmware.version, newerFirmware.BSPVersion, apiVersion, bspVersion);
            }
        }
    }

    private void showCurrentVersion(String serverApiVersion, String serverBspVersion, String cameraApiVersion, String cameraBspVersion) {
        FirmwareUpgradeHelper.FirmwareVersion versionFromServer = new FirmwareUpgradeHelper.FirmwareVersion(serverApiVersion, serverBspVersion);
        FirmwareUpgradeHelper.FirmwareVersion versionInCamera = new FirmwareUpgradeHelper.FirmwareVersion(cameraApiVersion, cameraBspVersion);
        Logger.t(TAG).d("latest version: " + versionFromServer);
        Logger.t(TAG).d("version of camera: " + versionInCamera);
        Logger.t(TAG).d("check version isGreaterThan: " + versionFromServer.isGreaterThan(versionInCamera));
        if (versionFromServer.isGreaterThan(versionInCamera)) {
            tvUpToDate.setText(R.string.firmware_update_old);
            tvUpToDate.setTextColor(getResources().getColor(R.color.colorRed));
        }
    }

//    private void checkVersion(CameraItem cameraItem) {
//        Gson gson = HornApplication.getComponent().gson();
//        List<Firmware> latestFirmwareList = gson.fromJson(PreferenceUtils.getString(PreferenceUtils.KEY_LATEST_FIRMWARE_LIST, null),
//                new TypeToken<List<Firmware>>() {
//                }.getType());
//        Logger.t(TAG).e("latestFirmwareList: " + latestFirmwareList);
//        Firmware newerFirmware = FirmwareUpgradeHelper.getNewerFirmware(latestFirmwareList, cameraItem);
//        if (newerFirmware != null) {
//            FirmwareUpgradeHelper.FirmwareVersion versionFromServer = new FirmwareUpgradeHelper.FirmwareVersion(newerFirmware.version, newerFirmware.BSPVersion);
//            FirmwareUpgradeHelper.FirmwareVersion versionInCamera = new FirmwareUpgradeHelper.FirmwareVersion(cameraItem.getApiVersion(), cameraItem.getBspVersion());
//            Logger.t(TAG).d("latest version: " + versionFromServer);
//            Logger.t(TAG).d("version of camera: " + versionInCamera);
//            Logger.t(TAG).d("check version isGreaterThan: " + versionFromServer.isGreaterThan(versionInCamera));
//            if (versionFromServer.isGreaterThan(versionInCamera)) {
//                tvUpToDate.setText(R.string.firmware_update_old);
//                tvUpToDate.setTextColor(getResources().getColor(R.color.colorRed));
//            }
//        }
//    }

//    @SuppressLint("CheckResult")
//    private void checkFleetFirmware(CameraItem cameraItem) {
//        ApiClient.createApiService().getFirmware(cameraItem.getSerialNumber())
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(response -> {
//                    FirmwareBean firmware = response.getFirmware();
//                    if (firmware != null) {
//                        FirmwareUpgradeHelper.FirmwareVersion versionFromServer = new FirmwareUpgradeHelper.FirmwareVersion(firmware.getFirmwareShort(), firmware.getFirmware());
//                        FirmwareUpgradeHelper.FirmwareVersion versionInCamera = new FirmwareUpgradeHelper.FirmwareVersion(cameraItem.getApiVersion(), cameraItem.getBspVersion());
//                        Logger.t(TAG).d("latest version: " + versionFromServer);
//                        Logger.t(TAG).d("version of camera: " + versionInCamera);
//                        Logger.t(TAG).d("check version isGreaterThan: " + versionFromServer.isGreaterThan(versionInCamera));
//                        if (versionFromServer.isGreaterThan(versionInCamera)) {
//                            tvUpToDate.setText(R.string.firmware_update_old);
//                            tvUpToDate.setTextColor(getResources().getColor(R.color.colorRed));
//                        }
//                    }
//                }, new ServerErrorHandler(TAG));
//    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper cameraWrapper = camera.getIncludeNull();
        Logger.t(TAG).e("onCurrentCamera: " + cameraWrapper);
        if (cameraWrapper != null) {
            //判断是否是同一个相机
            if (mCamera != null && mCamera.getSerialNumber().equals(cameraWrapper.getSerialNumber())) {
                mCamera = cameraWrapper;
                onNewCamera(cameraWrapper);
            } else if (mCameraBean != null && mCameraBean.sn.equals(cameraWrapper.getSerialNumber())) {
                mCamera = cameraWrapper;
                onNewCamera(cameraWrapper);
            } else if (mFleetCamera != null && mFleetCamera.getSn().equals(cameraWrapper.getSerialNumber())) {
                mCamera = cameraWrapper;
                onNewCamera(cameraWrapper);
            }
        } else if (mCameraBean != null) {
            onNewCamera(mCameraBean);
        } else if (mFleetCamera != null) {
            onNewCamera(mFleetCamera);
        } else {
            onDisconnectCamera();
        }
    }

    private void onNewCamera(CameraBean cameraBean) {
        Logger.t(TAG).d("onNewCamera: " + cameraBean.sn);

        if (cameraBean.is4G != null && cameraBean.is4G && cameraBean.isOnline) {
            llAdvancedSetting.setVisibility(View.VISIBLE);
        } else {
            llAdvancedSetting.setVisibility(View.GONE);
        }

        llAdasSettings.setVisibility(View.GONE);
    }

    private void onNewCamera(FleetCameraBean camerasBean) {
        Logger.t(TAG).d("onNewCamera: " + camerasBean.getSn());

//        OnlineStatusResponse onlineStatus = camerasBean.getOnlineStatus();
//        if (onlineStatus != null && onlineStatus.isIsOnline()) {
//            llAdvancedSetting.setVisibility(View.VISIBLE);
//        } else {
//            llAdvancedSetting.setVisibility(View.GONE);
//        }

        llAdasSettings.setVisibility(View.GONE);
    }

    private void onNewCamera(CameraWrapper cameraWrapper) {
        Logger.t(TAG).d("onNewCamera: " + cameraWrapper.getSerialNumber());
        if (!Constants.isFleet()) rlRecording.setVisibility(View.VISIBLE);

        llAdvancedSetting.setVisibility(View.VISIBLE);

        if (cameraWrapper.isAdasCfgAvailable()) {
            if (cameraWrapper instanceof EvCamera) {
                AdasCfgInfo adasCfgInfo = ((EvCamera) cameraWrapper).getAdasCfgInfo();
                Logger.t(TAG).i("isAdasCfgAvailable adasCfgInfo = " + adasCfgInfo);
                if (adasCfgInfo != null) {
                    llAdasSettings.setVisibility(View.GONE);
                } else {
                    llAdasSettings.setVisibility(View.GONE);
                }
            }
        } else {
            llAdasSettings.setVisibility(View.GONE);
        }
    }

    private void onDisconnectCamera() {
        Logger.t(TAG).d("onDisconnectCamera");
        rlRecording.setVisibility(View.GONE);
        llAdvancedSetting.setVisibility(View.GONE);

        Toast.makeText(this, getResources().getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show();
        LocalLiveActivity.launch(this, true);
    }

    private void updateFourGStateUI() {
        hideSettingsRemote();

        if (mCameraBean.is4G != null && mCameraBean.is4G) {
            rlFourgPlan.setVisibility(View.VISIBLE);
            vDivider1.setVisibility(View.GONE);
        }

        if (mCameraBean.settings != null && !TextUtils.isEmpty(mCameraBean.settings.logoLED)) {
            if (switchLogoLED.isChecked() != MountSetting.isOn(mCameraBean.settings.logoLED))
                logoFromUser = false;
            switchLogoLED.setChecked("on".equals(mCameraBean.settings.logoLED));
        }

        rlUnbind.setVisibility(View.VISIBLE);
    }

    private void updateFleetStateUI() {
        hideSettingsInFleet();
        hideSettingsRemote();

//        rlDataUsage.setVisibility(View.VISIBLE);
        vDivider1.setVisibility(View.GONE);
    }

    private void updateCameraStateUI() {
        if (mCamera != null) {
            if (Constants.isFleet()) {
                hideSettingsInFleet();
//                rlDataUsage.setVisibility(View.VISIBLE);
                vDivider1.setVisibility(View.GONE);
            } else {
                updateRecording();

                MountVersion mountVersion = mCamera.getMountVersion();
                if (mountVersion != null && mountVersion.support_4g) {
                    rlFourgPlan.setVisibility(View.VISIBLE);
                    vDivider1.setVisibility(View.GONE);
                }

                MountSetting mountSetting = mCamera.getMountSettings(true);
                if (mountSetting != null && !TextUtils.isEmpty(mountSetting.logoLED)) {
                    if (switchLogoLED.isChecked() != MountSetting.isOn(mountSetting.logoLED))
                        logoFromUser = false;
                    switchLogoLED.setChecked(MountSetting.isOn(mountSetting.logoLED));
                }

                if (currentUser.ownerDevice(mCamera.getSerialNumber())) {
                    rlUnbind.setVisibility(View.VISIBLE);
                }

                if (!mCamera.isAudioPromptsAvailable()) {
                    hideSettingsBelow9();
                } else if (!mCamera.isHDRAutoAvailable()) {
                    hideSettingsBelow12();
                } else {
                    hideSettingsAbove12();
                    if (!mCamera.isWifiDirectAvailable()) {
                        hideSettingsBelow13();
                    } else if (!mCamera.isDrivingModeTimeoutSettingsAvailable()
                            && !mCamera.isProtectionVoltageAvailable()) {
                        hideSettingsBelow14();
                    } else {
                        showSettingsAbove14();
                    }
                }
            }

            llLens.setVisibility(mCamera.getSupportUpsidedown() ? View.GONE : View.GONE);

            if (mCamera instanceof EvCamera) {
                llFvtSetting.setVisibility(View.VISIBLE);
                llEvcamSetting.setVisibility(View.GONE);

                if (mCamera.isRecordConfigAvailable()) {
                    String curRecordConfig = ((EvCamera) mCamera).getCurRecordConfig();
//                Logger.t(TAG).d("test curRecordConfig: " + curRecordConfig);
                    tvConfig.setText(curRecordConfig);
                }

                int forceCodec = ((EvCamera) mCamera).getForceCodec();
//                Logger.t(TAG).d("test forceCodec: " + forceCodec);
                tvCodec.setText(String.format(Locale.getDefault(), "%d", forceCodec));

                if (mCamera.isVinMirrorAvailable()) {
                    llVinMirror.setVisibility(View.VISIBLE);
                }

                if (mCamera.isMacWlan0Available()) {
                    llMacWlan0.setVisibility(View.VISIBLE);
                }

                if (mCamera.isSradarAvailable()) {
                    llSetSradar.setVisibility(View.VISIBLE);
                }

                if (mCamera.isExBoardvailable()) {
                    ll_Exboard.setVisibility(View.VISIBLE);
                }

            } else {
                llFvtSetting.setVisibility(View.GONE);
                llEvcamSetting.setVisibility(View.GONE);
            }
        }
    }

    private void updateRecording() {
        int recordState = mCamera.getRecordState();
        Logger.t(TAG).d("%s", "record state = " + recordState);
        switch (recordState) {
            case VdtCamera.STATE_RECORD_STOPPED:
                switchRecording.setChecked(false);
                break;
            case VdtCamera.STATE_RECORD_RECORDING:
                switchRecording.setChecked(true);
                break;
            default:
                break;
        }
    }

    private void setCameraMountSetting(String item, boolean enable) {
        try {
            if (mCamera != null) {
                JSONObject setting = new JSONObject();
                setting.put(item, MountSetting.getValueString(enable));
                Logger.t(TAG).d("setting = %s", setting.toString());
                mCamera.setMountSettings(setting.toString());
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    public void onHandleCameraStateChangeEvent(CameraStateChangeEvent event) {
        Logger.t(TAG).d("%s", "cameraStateChangeEvent = " + ToStringUtils.getString(event));

        if (event.getWhat() == CameraStateChangeEvent.CAMERA_STATE_REC) {
            updateCameraStateUI();
        }
    }

    private void onMountSettingChangeEvent(MountSettingChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            MountSetting mountSetting = event.getMountSetting();
            if (!TextUtils.isEmpty(mountSetting.logoLED)) {
                if (switchLogoLED.isChecked() != MountSetting.isOn(mountSetting.logoLED))
                    logoFromUser = false;
                switchLogoLED.setChecked(MountSetting.isOn(mountSetting.logoLED));
            }
        }
    }

    private void onHdrModeChangeEvent(HdrModeChangeEvent event) {
        Logger.t(TAG).d("onHdrModeChangeEvent: " + ToStringUtils.getString(event));
        if (event != null && event.getCamera().equals(mCamera)) {
            int hdrMode = event.getHdrMode();
            if (mCamera != null && !mCamera.isHDRAutoAvailable()) {
                switchHDR.setChecked(hdrMode == VdtCamera.HDR_MODE_ON);
            } else {
                judgeHdrMode(hdrMode);
            }
        }
    }

    private void judgeHdrMode(int hdrMode) {
        switch (hdrMode) {
            case VdtCamera.HDR_MODE_ON:
                tvHdrMode.setText(R.string.on);
                break;
            case VdtCamera.HDR_MODE_OFF:
                tvHdrMode.setText(R.string.off);
                break;
            case VdtCamera.HDR_MODE_AUTO:
                tvHdrMode.setText(R.string.auto);
                break;
        }
    }

    private void onFactoryResetEvent(FactoryResetEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            hideLoadingDialog();
            String str = event.getResult() ? getResources().getString(R.string.camera_setting_factory_reset_successfully)
                    : getResources().getString(R.string.camera_setting_factory_reset_failed);

            Snackbar.make(rlFactoryReset, str, Snackbar.LENGTH_SHORT).show();
        }
    }

    private void showLoadingDialog() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(this);
        }
        progressDialog.show();
    }

    private void hideLoadingDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            try {
                progressDialog.hide();
                progressDialog.dismiss();
                progressDialog = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }
    }

    public void unbindDevices(String sn) {
        Logger.t(TAG).d("unbindDevices: " + sn);

        ApiService.createApiService().unbindDevice(sn)
                .compose(Transformers.switchSchedulers())
                .compose(Transformers.pipeErrorsTo(llError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<Response<BooleanResponse>>() {
                    @Override
                    protected void onHandleSuccess(Response<BooleanResponse> data) {
                        boolean result = data.body().result;
                        Logger.t(TAG).d("unbindDevice: %s", result);
                        String str = result ? getResources().getString(R.string.camera_setting_unbind_successfully)
                                : getResources().getString(R.string.camera_setting_unbind_failed);

                        Toast.makeText(DevicesActivity.this, str, Toast.LENGTH_SHORT).show();

                        if (result) {
                            rlUnbind.setVisibility(View.GONE);
                            ApiService.createApiService().getCameras()
                                    .compose(Transformers.switchSchedulers())
                                    .subscribe(new CameraSubscriber());
                        }
                    }
                });
    }

    private void onUnbindCameraError(ErrorEnvelope error) {
        Toast.makeText(this, error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void onLowLevelError(Throwable e) {
        NetworkErrorHelper.handleCommonError(this, e);
    }

    @Override
    protected void onDestroy() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        super.onDestroy();
    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> {
            if (mCameraBean != null && mCameraBean.is4G != null && mCameraBean.is4G && mCameraBean.isOnline) {
                uploadSetting();
            } else {
                finish();
            }
        });
    }

    private void uploadSetting() {
        String logoLED = switchLogoLED.isChecked() ? "on" : "off";

        Logger.t(TAG).d("settings: " + mCameraBean.settings);

        if (mCameraBean.settings != null
                && mCameraBean.settings.parkingMode != null
                && mCameraBean.settings.drivingMode != null) {

            if (!logoLED.equals(mCameraBean.settings.logoLED)) {
                isSettingChanged = true;
                mCameraBean.settings.logoLED = logoLED;
            }
        }

        Logger.t(TAG).e("camera setting modify：" + isSettingChanged);
        if (isSettingChanged) {
            CameraControlBody controlBody = CameraControlBody.makeBody(mCameraBean);

            Logger.t(TAG).e("controlBody: " + controlBody);

            ApiService.createApiService().controlCamera(serialNum, controlBody)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .doOnError(throwable -> {
                        RxBus.getDefault().post(new SettingChangeEvent(ACTION_FAILURE, false));
                        HornApplication.setSettingResult(ACTION_FAILURE);
                        finish();
                    })
                    .subscribe(new BaseObserver<BooleanResponse>() {
                        @Override
                        protected void onHandleSuccess(BooleanResponse data) {
                            Logger.t(TAG).d("controlCamera onHandleSuccess: " + data.result);
                            HornApplication.checkSettingUpdated();
                            HornApplication.setSettingResult(ACTION_START);
                            finish();
                        }
                    });
        } else {
            finish();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null && data.getExtras() != null) {
            Bundle extras = data.getExtras();
            if (requestCode == AUDIO_SETTING) {
                String siren = extras.getString("siren");
                Logger.t(TAG).e("siren: " + siren);

                if (siren != null && mCameraBean.settings != null
                        && !siren.equals(mCameraBean.settings.siren)) {
                    isSettingChanged = true;
                    mCameraBean.settings.siren = siren;
                }
            } else if (requestCode == NIGHTVISION_SETTING) {
                String nightVisionParking = extras.getString("nightVision_parking");
                String nightVisionDriving = extras.getString("nightVision_driving");
                int from = extras.getInt("from");
                int to = extras.getInt("to");
                Logger.t(TAG).e("nightVisionParking: " + nightVisionParking);
                Logger.t(TAG).e("nightVisionDriving: " + nightVisionDriving);
                Logger.t(TAG).e("from: " + from);
                Logger.t(TAG).e("to: " + to);

                Logger.t(TAG).d("settings: " + mCameraBean.settings);

                if (mCameraBean.settings != null
                        && mCameraBean.settings.parkingMode != null
                        && mCameraBean.settings.drivingMode != null) {

                    if (nightVisionDriving != null && nightVisionParking != null &&
                            (!nightVisionParking.equals(mCameraBean.settings.parkingMode.nightVision)
                                    || !nightVisionDriving.equals(mCameraBean.settings.drivingMode.nightVision)
                                    || from != mCameraBean.settings.drivingMode.nightVisionTime.from
                                    || to != mCameraBean.settings.drivingMode.nightVisionTime.to)) {

                        isSettingChanged = true;
                        mCameraBean.settings.parkingMode.nightVision = nightVisionParking;
                        mCameraBean.settings.drivingMode.nightVision = nightVisionDriving;
                        mCameraBean.settings.drivingMode.nightVisionTime.from = from;
                        mCameraBean.settings.drivingMode.nightVisionTime.to = to;
                    }
                }
            } else if (requestCode == SENSE_SETTING) {
                String parkDetection = extras.getString("parkDetection");
                String parkUpload = extras.getString("parkUpload");
                String driveDetection = extras.getString("driveDetection");
                String driveUpload = extras.getString("driveUpload");
                Logger.t(TAG).e("parkDetection: " + parkDetection);
                Logger.t(TAG).e("parkUpload: " + parkUpload);
                Logger.t(TAG).e("driveDetection: " + driveDetection);
                Logger.t(TAG).e("driveUpload: " + driveUpload);

                Logger.t(TAG).d("settings: " + mCameraBean.settings);

                if (mCameraBean.settings != null
                        && mCameraBean.settings.parkingMode != null
                        && mCameraBean.settings.drivingMode != null
                        && parkDetection != null
                        && parkUpload != null
                        && driveDetection != null
                        && driveUpload != null) {

                    if (!parkDetection.equals(mCameraBean.settings.parkingMode.detectionSensitivity)
                            || !parkUpload.equals(mCameraBean.settings.parkingMode.uploadSensitivity)
                            || !driveDetection.equals(mCameraBean.settings.drivingMode.detectionSensitivity)
                            || !driveUpload.equals(mCameraBean.settings.drivingMode.uploadSensitivity)) {

                        isSettingChanged = true;
                        mCameraBean.settings.parkingMode.detectionSensitivity = parkDetection;
                        mCameraBean.settings.parkingMode.uploadSensitivity = parkUpload;
                        mCameraBean.settings.drivingMode.detectionSensitivity = driveDetection;
                        mCameraBean.settings.drivingMode.uploadSensitivity = driveUpload;
                    }
                }
            }
        }
    }

    private void onVoltageChangeEvent(VoltageChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int voltage = event.getVoltage();
            Logger.t(TAG).d("onVoltageChangeEvent voltage: " + voltage);
            judgeVoltage(voltage);
        }
    }

    private void onDelayChangeEvent(SleepDelayChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int sleepDelay = event.getSleepDelay();
            Logger.t(TAG).d("onDelayChangeEvent sleepDelay: " + sleepDelay);

            int i = sleepDelay / 60;
            if (i == 0) {
                tvSleepDelay.setText(String.format(Locale.ENGLISH, "%ds", sleepDelay));
            } else {
                tvSleepDelay.setText(String.format(Locale.ENGLISH, "%dmin", i));
            }
        }
    }

    private void onSupportWlanEvent(SupportWlanChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            boolean supportWlan = event.getSupportWlan();
            Logger.t(TAG).d("onSupportWlanEvent supportWlan: " + supportWlan);
            if (supportWlan) {
                llWifiMode.setVisibility(View.VISIBLE);
            }
        }
    }

    private void onApnChangeEvent(ApnChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            String apn = event.getApn();
            Logger.t(TAG).e("onApnChangeEvent apn: " + apn);
            tvApnSetting.setText(apn);
        }
    }

    private void judgeVoltage(int voltage) {
        switch (voltage) {
            case DAILY_DRIVER_VOLTAGE:
                tvVoltageMode.setText(R.string.daily_driver);
                break;
            case BALANCED_VOLTAGE:
                tvVoltageMode.setText(R.string.balanced);
                break;
            case EXTENDED_VOLTAGE:
                tvVoltageMode.setText(R.string.extended);
                break;
            case EXTREME_VOLTAGE:
                tvVoltageMode.setText(R.string.extreme);
                break;
            default:
                break;
        }
    }

    @Override
    public void onBackPressed() {
        if (mCameraBean != null && mCameraBean.is4G != null && mCameraBean.is4G && mCameraBean.isOnline) {
            uploadSetting();
        } else {
            finish();
        }
    }

    private void hideSettingsInFleet() {
        llSensitivity.setVisibility(View.GONE);
        rlAudio.setVisibility(View.GONE);
//        rlNightVision.setVisibility(View.GONE);

        rlLogoLED.setVisibility(View.GONE);

        rlHDR.setVisibility(View.GONE);
        rlHdrAuto.setVisibility(View.GONE);

        rlDetection.setVisibility(View.VISIBLE);
        llWifiDirect.setVisibility(View.GONE);

        llSleepDelay.setVisibility(View.GONE);
        llVoltageSetting.setVisibility(View.GONE);

        rlFactoryReset.setVisibility(View.GONE);
        rlUnbind.setVisibility(View.GONE);
    }

    private void hideSettingsBelow9() {
        llSensitivity.setVisibility(View.GONE);
    }

    private void hideSettingsBelow12() {
        rlHdrAuto.setVisibility(View.GONE);
        rlDetection.setVisibility(View.VISIBLE);

        switchHDR.setChecked(mCamera.hdr_mode == VdtCamera.HDR_MODE_ON);
    }

    private void hideSettingsAbove12() {
        rlHDR.setVisibility(View.GONE);

        int hdrMode = mCamera.getHdrMode();
        Logger.t(TAG).e("hdrMode: " + hdrMode);
        judgeHdrMode(hdrMode);
    }

    private void hideSettingsBelow13() {
        llWifiDirect.setVisibility(View.GONE);
    }

    private void hideSettingsBelow14() {
        llSleepDelay.setVisibility(View.GONE);
        llVoltageSetting.setVisibility(View.GONE);
    }

    private void showSettingsAbove14() {
        llSleepDelay.setVisibility(View.VISIBLE);
        llVoltageSetting.setVisibility(View.VISIBLE);

        int parkSleepDelay = mCamera.getParkSleepDelay();
        Logger.t(TAG).d("parkSleepDelay: " + parkSleepDelay);
        int i = parkSleepDelay / 60;
        if (i == 0) {
            tvSleepDelay.setText(String.format(Locale.ENGLISH, "%ds", parkSleepDelay));
        } else {
            tvSleepDelay.setText(String.format(Locale.ENGLISH, "%dmin", i));
        }

        int protectVoltage = mCamera.getProtectVoltage();
        Logger.t(TAG).d("protectVoltage: " + protectVoltage);
        judgeVoltage(protectVoltage);
    }

    private void hideSettingsRemote() {
        rlHDR.setVisibility(View.GONE);
        rlHdrAuto.setVisibility(View.GONE);

        rlSdcard.setVisibility(View.GONE);

        rlDetection.setVisibility(View.VISIBLE);
        llWifiDirect.setVisibility(View.GONE);

        llLens.setVisibility(View.GONE);

        llSleepDelay.setVisibility(View.GONE);
        llVoltageSetting.setVisibility(View.GONE);

        rlFactoryReset.setVisibility(View.GONE);
    }
}
