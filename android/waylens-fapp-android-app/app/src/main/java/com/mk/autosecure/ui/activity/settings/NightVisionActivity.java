package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.TimePickerDialogSpinner;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.SettingReportBody;
import com.mkgroup.camera.event.MountSettingChangeEvent;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by DoanVT on 2018/3/26.
 * Email: doanvt-hn@mk.com.vn
 */

public class NightVisionActivity extends RxActivity {
    private static final String TAG = "NightVisionActivity";

    public static final int NIGHTVISION_SETTING = 0x02;

    public static final String NIGHT_VISION_ON = "on";
    public static final String NIGHT_VISION_OFF = "off";
    public static final String NIGHT_VISION_AUTO = "auto";

    @BindView(R.id.switch_nightVision_parking)
    Switch switch_nightVision_parking;

    @BindView(R.id.switch_nightVision_driving)
    Switch switch_nightVision_driving;

    @BindView(R.id.ll_nightVision_start)
    RelativeLayout rl_nightVision_start;

    @BindView(R.id.ll_nightVision_end)
    RelativeLayout rl_nightVision_end;

    @BindView(R.id.rl_nightVision_parking)
    RelativeLayout rl_nightVision_parking;

    @BindView(R.id.tv_parking)
    TextView tv_parking;

    @BindView(R.id.rl_nightVision_driving)
    RelativeLayout rl_nightVision_driving;

    @BindView(R.id.tv_driving)
    TextView tv_driving;

    @BindView(R.id.rl_nightVision_driving_auto)
    RelativeLayout rl_nightVision_driving_auto;

    @BindView(R.id.tv_driving_auto)
    TextView tv_driving_auto;

    @BindView(R.id.tv_nightVision_driving)
    TextView tv_nightVision_driving;

    @BindView(R.id.tv_parking_nightVision_start)
    TextView tv_nightVision_parking_start;

    @BindView(R.id.tv_parking_nightVision_end)
    TextView tv_nightVision_parking_end;

    private String sn;

    private CameraWrapper mCamera;

    private CameraBean cameraBean;

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, NightVisionActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CameraBean cameraBean) {
        Intent intent = new Intent(activity, NightVisionActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        activity.startActivityForResult(intent, NIGHTVISION_SETTING);
    }

    @OnClick(R.id.rl_nightVision_driving_auto)
    public void drivingMode() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        final String[] items = new String[]{getString(R.string.manual), getString(R.string.auto), getString(R.string.off)};

        String nightVision = "";
        if (mCamera != null && mCamera.getMountSettings(false) != null && mCamera.getMountSettings(false).drivingMode != null) {
            nightVision = mCamera.getMountSettings(false).drivingMode.nightVision;
        } else if (cameraBean != null) {
//            nightVision = cameraBean.settings.drivingMode.nightVision;
            //这里不用远程的设置状态，而是使用本地的状态值
            nightVision = tv_nightVision_driving.getText().toString().toLowerCase(Locale.ENGLISH);
        }
        Logger.t(TAG).d("nightVision: " + nightVision);

        builder.setSingleChoiceItems(items, nightVisionIndex(nightVision), (dialog, which) -> {
            Logger.t(TAG).d("setNightVision: " + which);
            enableMountSettingDrivingMode(false, MountSetting.KEY_NIGHT_VISION, MountSetting.getValueString(which));
            dialog.dismiss();
        });

        builder.show();
    }

    private int nightVisionIndex(String nightVision) {
        switch (nightVision) {
            case NIGHT_VISION_ON:
                return 0;
            case NIGHT_VISION_AUTO:
                return 1;
            case NIGHT_VISION_OFF:
                return 2;
            default:
                return 0;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        cameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
        if (!TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }

        if (mCamera != null) {
            if (!mCamera.isNightVisionInDrivingAvailable()) {
                rl_nightVision_driving.setVisibility(View.GONE);
                rl_nightVision_start.setVisibility(View.GONE);
                rl_nightVision_end.setVisibility(View.GONE);
            } else if (!mCamera.isNightVisionAutoAvailable()) {
                rl_nightVision_driving_auto.setVisibility(View.GONE);
            } else {
                rl_nightVision_driving.setVisibility(View.GONE);
            }
        }

        if (cameraBean != null && cameraBean.state != null) {
            String firmwareShort = cameraBean.state.firmwareShort;
            if (StringUtils.compareToApiVersion(firmwareShort, "1.12.0") < 0) {
                rl_nightVision_driving_auto.setVisibility(View.GONE);
            } else {
                rl_nightVision_driving.setVisibility(View.GONE);
            }
        }

        if (mCamera != null && mCamera.getMountSettings(false) != null
                && mCamera.getMountSettings(false).parkingMode != null
                && mCamera.getMountSettings(false).drivingMode != null) {

            MountSetting mountSetting = mCamera.getMountSettings(false);

            switch_nightVision_parking.setChecked(MountSetting.isOn(mountSetting.parkingMode.nightVision));
            tv_parking.setText(MountSetting.isOn(mountSetting.parkingMode.nightVision)
                    ? R.string.nightVision_parking_on : R.string.nightVision_parking_off);

            String nightVision = mountSetting.drivingMode.nightVision;
            switch_nightVision_driving.setChecked(MountSetting.isOn(nightVision));
            judgeMode(false, nightVision);
            Logger.t(TAG).d("nightVision: " + nightVision);

            if (MountSetting.AUTO.equals(nightVision) || MountSetting.OFF.equals(nightVision)) {
                rl_nightVision_start.setVisibility(View.GONE);
                rl_nightVision_end.setVisibility(View.GONE);
            }

            MountSetting.ModeSetting drivingModeSetting = mountSetting.drivingMode;
            int startTime, endTime;
            if (drivingModeSetting != null && drivingModeSetting.nightVisionTime != null) {
                startTime = drivingModeSetting.nightVisionTime.from;
                endTime = drivingModeSetting.nightVisionTime.to;
                tv_nightVision_parking_start.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(startTime / 60), judgeTime(startTime % 60)));
                tv_nightVision_parking_end.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(endTime / 60), judgeTime(endTime % 60)));
            }
        } else if (cameraBean != null && cameraBean.settings != null
                && cameraBean.settings.parkingMode != null
                && cameraBean.settings.drivingMode != null) {

            SettingReportBody.Setting settings = cameraBean.settings;
            Logger.t(TAG).d("camerabean setting: " + settings);

            switch_nightVision_parking.setChecked(MountSetting.isOn(settings.parkingMode.nightVision));
            tv_parking.setText(MountSetting.isOn(settings.parkingMode.nightVision)
                    ? R.string.nightVision_parking_on : R.string.nightVision_parking_off);

            String nightVision = settings.drivingMode.nightVision;
            switch_nightVision_driving.setChecked(MountSetting.isOn(nightVision));
            judgeMode(false, nightVision);
            Logger.t(TAG).d("nightVision: " + nightVision);

            if (MountSetting.AUTO.equals(nightVision) || MountSetting.OFF.equals(nightVision)) {
                rl_nightVision_start.setVisibility(View.GONE);
                rl_nightVision_end.setVisibility(View.GONE);
            }

            MountSetting.ModeSetting drivingMode = settings.drivingMode;
            int startTime, endTime;
            if (drivingMode != null && drivingMode.nightVisionTime != null) {
                startTime = drivingMode.nightVisionTime.from;
                endTime = drivingMode.nightVisionTime.to;
                tv_nightVision_parking_start.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(startTime / 60), judgeTime(startTime % 60)));
                tv_nightVision_parking_end.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(endTime / 60), judgeTime(endTime % 60)));
            }
        }

        switch_nightVision_parking.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                enableMountSettingDrivingMode(true, MountSetting.KEY_NIGHT_VISION, isChecked ? MountSetting.ON : MountSetting.OFF);
            }
        });

        switch_nightVision_driving.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                enableMountSettingDrivingMode(false, MountSetting.KEY_NIGHT_VISION, isChecked ? MountSetting.ON : MountSetting.OFF);
            }
        });

        rl_nightVision_start.setOnClickListener(v -> {
            int start_hourOfDay = 0;
            int start_minute = 0;

            if (mCamera != null) {
                MountSetting.ModeSetting drivingModeSetting = mCamera.getMountSettings(false).drivingMode;
                if (drivingModeSetting != null && drivingModeSetting.nightVisionTime != null) {
                    start_hourOfDay = drivingModeSetting.nightVisionTime.from / 60;
                    start_minute = drivingModeSetting.nightVisionTime.from % 60;
                }
            } else if (cameraBean != null && cameraBean.settings != null && cameraBean.settings.drivingMode != null) {
                MountSetting.ModeSetting drivingMode = cameraBean.settings.drivingMode;
                if (drivingMode != null && drivingMode.nightVisionTime != null) {
                    start_hourOfDay = drivingMode.nightVisionTime.from / 60;
                    start_minute = drivingMode.nightVisionTime.from % 60;
                }
            }

            TimePickerDialog timePickerDialog;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                timePickerDialog = new TimePickerDialog(NightVisionActivity.this, TimePickerDialog.THEME_HOLO_LIGHT, (view, hourOfDay, minute) -> {
                    tv_nightVision_parking_start.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(hourOfDay), judgeTime(minute)));
                    setMountSettingDrivingModeTime(MountSetting.KEY_START_TIME, hourOfDay * 60 + minute);
                }, start_hourOfDay, start_minute, true);
            } else {
                timePickerDialog = new TimePickerDialogSpinner(NightVisionActivity.this, TimePickerDialog.THEME_HOLO_LIGHT, (view, hourOfDay, minute) -> {
                    tv_nightVision_parking_start.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(hourOfDay), judgeTime(minute)));
                    setMountSettingDrivingModeTime(MountSetting.KEY_START_TIME, hourOfDay * 60 + minute);
                }, start_hourOfDay, start_minute, true);
            }

            timePickerDialog.setTitle(getString(R.string.camera_setting_pick_time));
            timePickerDialog.show();
        });

        rl_nightVision_end.setOnClickListener(v -> {
            int end_hourOfDay = 0;
            int end_minute = 0;

            if (mCamera != null) {
                MountSetting.ModeSetting drivingModeSetting = mCamera.getMountSettings(false).drivingMode;
                if (drivingModeSetting != null && drivingModeSetting.nightVisionTime != null) {
                    end_hourOfDay = drivingModeSetting.nightVisionTime.to / 60;
                    end_minute = drivingModeSetting.nightVisionTime.to % 60;
                }
            } else if (cameraBean != null && cameraBean.settings != null && cameraBean.settings.drivingMode != null) {
                MountSetting.ModeSetting drivingMode = cameraBean.settings.drivingMode;
                if (drivingMode != null && drivingMode.nightVisionTime != null) {
                    end_hourOfDay = drivingMode.nightVisionTime.to / 60;
                    end_minute = drivingMode.nightVisionTime.to % 60;
                }
            }

            TimePickerDialog timePickerDialog;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                timePickerDialog = new TimePickerDialog(NightVisionActivity.this, TimePickerDialog.THEME_HOLO_LIGHT, (view, hourOfDay, minute) -> {
                    tv_nightVision_parking_end.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(hourOfDay), judgeTime(minute)));
                    setMountSettingDrivingModeTime(MountSetting.KEY_END_TIME, hourOfDay * 60 + minute);
                }, end_hourOfDay, end_minute, true);
            } else {
                timePickerDialog = new TimePickerDialogSpinner(NightVisionActivity.this, TimePickerDialog.THEME_HOLO_LIGHT, (view, hourOfDay, minute) -> {
                    tv_nightVision_parking_end.setText(String.format(Locale.getDefault(), getString(R.string.nightVision_hour_minute_string), judgeTime(hourOfDay), judgeTime(minute)));
                    setMountSettingDrivingModeTime(MountSetting.KEY_END_TIME, hourOfDay * 60 + minute);
                }, end_hourOfDay, end_minute, true);
            }

            timePickerDialog.setTitle(getString(R.string.camera_setting_pick_time));
            timePickerDialog.show();
        });

        RxBus.getDefault().toObservable(MountSettingChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountSettingChangeEvent, new ServerErrorHandler());

    }

    private String judgeTime(int time) {
        if (time < 10) {
            StringBuilder temp = new StringBuilder("0");
            temp.append(time);
            return temp.toString();
        }
        return String.valueOf(time);
    }

    private void initViews() {
        setContentView(R.layout.activity_night_vision);
        ButterKnife.bind(this);
        setupToolbar();
    }

    private void enableMountSettingDrivingMode(boolean isParking, String item, String status) {
        try {
            if (mCamera != null) {
                JSONObject setting = new JSONObject();
                JSONObject mode = new JSONObject();

                setting.put(item, status);
                if (isParking) {
                    mode.put("parkingMode", setting);
                } else {
                    mode.put("drivingMode", setting);
                }

                Logger.t(TAG).d("setting = %s", mode.toString());
                mCamera.setMountSettings(mode.toString());
            } else if (cameraBean != null) {
                judgeMode(isParking, status);
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    private void setMountSettingDrivingModeTime(String item, int time) {
        try {
            if (mCamera != null) {
                JSONObject inModeSetting = new JSONObject();
                JSONObject drivingSetting = new JSONObject();
                JSONObject nightVisionTime = new JSONObject();

                nightVisionTime.put(item, time);
                inModeSetting.put("nightVisionTime", nightVisionTime);
                drivingSetting.put("drivingMode", inModeSetting);

                Logger.t(TAG).d("setting = %s", drivingSetting.toString());
                mCamera.setMountSettings(drivingSetting.toString());
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    public void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        toolbar.setNavigationOnClickListener(v -> {
            if (cameraBean != null) {
                Bundle bundle = new Bundle();
                bundle.putString("nightVision_parking", switch_nightVision_parking.isChecked() ? "on" : "off");
                String toLowerCase = tv_nightVision_driving.getText().toString().toLowerCase();
                bundle.putString("nightVision_driving", "manual".equals(toLowerCase) ? "on" : toLowerCase);

                String from = tv_nightVision_parking_start.getText().toString().trim();
                if (!TextUtils.isEmpty(from)) {
                    String[] fromSplit = from.split(":");
                    bundle.putInt("from", Integer.parseInt(fromSplit[0]) * 60 + Integer.parseInt(fromSplit[1]));
                }

                String to = tv_nightVision_parking_end.getText().toString().trim();
                if (!TextUtils.isEmpty(to)) {
                    String[] toSplit = to.split(":");
                    bundle.putInt("to", Integer.parseInt(toSplit[0]) * 60 + Integer.parseInt(toSplit[1]));
                }

                setResult(NIGHTVISION_SETTING, NightVisionActivity.this.getIntent().putExtras(bundle));
            }
            finish();
        });
    }

    private void onMountSettingChangeEvent(MountSettingChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            MountSetting mountSetting = event.getMountSetting();
            if (mountSetting.parkingMode != null) {
                switch_nightVision_parking.setChecked(MountSetting.isOn(mountSetting.parkingMode.nightVision));
                tv_parking.setText(MountSetting.isOn(mountSetting.parkingMode.nightVision)
                        ? R.string.nightVision_parking_on : R.string.nightVision_parking_off);
            }
            if (mountSetting.drivingMode != null) {
                if (!mCamera.isNightVisionAutoAvailable()) {
                    switch_nightVision_driving.setChecked(MountSetting.isOn(mountSetting.drivingMode.nightVision));
                }
                judgeMode(false, mountSetting.drivingMode.nightVision);
            }
        }
    }

    private void judgeMode(boolean isParking, String nightVision) {
        if (isParking) {
            if (MountSetting.ON.equals(nightVision)) {
                tv_parking.setText(R.string.nightVision_parking_on);
            } else if (MountSetting.OFF.equals(nightVision)) {
                tv_parking.setText(R.string.nightVision_parking_off);
            }
        } else {
            if (MountSetting.ON.equals(nightVision)) {
                tv_driving.setText(R.string.nightVision_driving_on);
                tv_driving_auto.setText(R.string.nightVision_driving_on);

                tv_nightVision_driving.setText(R.string.manual);
                rl_nightVision_start.setVisibility(View.VISIBLE);
                rl_nightVision_end.setVisibility(View.VISIBLE);

            } else if (MountSetting.AUTO.equals(nightVision)) {
                tv_driving.setText(R.string.nightVision_driving_auto);
                tv_driving_auto.setText(R.string.nightVision_driving_auto);

                tv_nightVision_driving.setText(R.string.auto);
                rl_nightVision_start.setVisibility(View.GONE);
                rl_nightVision_end.setVisibility(View.GONE);

            } else if (MountSetting.OFF.equals(nightVision)) {
                tv_driving.setText(R.string.nightVision_driving_off);
                tv_driving_auto.setText(R.string.nightVision_driving_off);

                tv_nightVision_driving.setText(R.string.off);
                rl_nightVision_start.setVisibility(View.GONE);
                rl_nightVision_end.setVisibility(View.GONE);
            }
        }
    }

    @Override
    public void onBackPressed() {
        if (cameraBean != null) {
            Bundle bundle = new Bundle();
            bundle.putString("nightVision_parking", switch_nightVision_parking.isChecked() ? "on" : "off");
            String toLowerCase = tv_nightVision_driving.getText().toString().toLowerCase();
            bundle.putString("nightVision_driving", "manual".equals(toLowerCase) ? "on" : toLowerCase);

            String from = tv_nightVision_parking_start.getText().toString().trim();
            if (!TextUtils.isEmpty(from)) {
                String[] fromSplit = from.split(":");
                bundle.putInt("from", Integer.parseInt(fromSplit[0]) * 60 + Integer.parseInt(fromSplit[1]));
            }

            String to = tv_nightVision_parking_end.getText().toString().trim();
            if (!TextUtils.isEmpty(to)) {
                String[] toSplit = to.split(":");
                bundle.putInt("to", Integer.parseInt(toSplit[0]) * 60 + Integer.parseInt(toSplit[1]));
            }

            setResult(NIGHTVISION_SETTING, this.getIntent().putExtras(bundle));
        }
        finish();
    }
}
