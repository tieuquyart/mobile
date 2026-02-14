package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.multistatetogglebutton.MultiStateToggleButton;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.event.MountSettingChangeEvent;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;

import org.json.JSONException;
import org.json.JSONObject;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by DoanVT on 2017/10/9.
 * Email: doanvt-hn@mk.com.vn
 */

public class DrivingSettingFragment extends RxFragment {

    private static final String TAG = DrivingSettingFragment.class.getSimpleName();

    private static final String[] DRIVING_SETTING = {"off", "low", "medium"};

    private boolean wifiOnly = false;

    private String sn;

    private CameraBean cameraBean;

    private CameraWrapper mCamera;

    @BindView(R.id.mstb_alert)
    MultiStateToggleButton mstb_alert;

    @BindView(R.id.mstb_upload)
    MultiStateToggleButton mstb_upload;

    @BindView(R.id.ll_setting_upload)
    LinearLayout ll_settingUpload;

    @BindView(R.id.tv_alert_title)
    TextView tv_alertTitle;

    @BindView(R.id.tv_alert_content)
    TextView tv_alertContent;

    @BindView(R.id.tv_upload_title)
    TextView tv_uploadTitle;

    @BindView(R.id.tv_upload_content)
    TextView tv_uploadContent;

    @BindArray(R.array.driving_event_detection_title)
    String[] detectionTitles;

    @BindArray(R.array.driving_event_detection_content)
    String[] detectionContents;

    @BindArray(R.array.event_upload_title)
    String[] uploadTitles;

    @BindArray(R.array.event_upload_content)
    String[] uploadContents;

    public static DrivingSettingFragment newInstance(boolean wifiOnly, String sn) {
        DrivingSettingFragment fragment = new DrivingSettingFragment();
        Bundle args = new Bundle();
        args.putBoolean(IntentKey.WIFI_ONLY, wifiOnly);
        args.putString(IntentKey.SERIAL_NUMBER, sn);
        fragment.setArguments(args);
        return fragment;
    }

    public static DrivingSettingFragment newInstance(boolean wifiOnly, CameraBean cameraBean) {
        DrivingSettingFragment fragment = new DrivingSettingFragment();
        Bundle args = new Bundle();
        args.putBoolean(IntentKey.WIFI_ONLY, wifiOnly);
        args.putSerializable(IntentKey.CAMERA_BEAN, cameraBean);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_drive_setting, container, false);
        ButterKnife.bind(this, view);
        wifiOnly = getArguments().getBoolean(IntentKey.WIFI_ONLY, true);
        sn = getArguments().getString(IntentKey.SERIAL_NUMBER);
        cameraBean = (CameraBean) getArguments().getSerializable(IntentKey.CAMERA_BEAN);

        if (wifiOnly) {
            mstb_upload.setVisibility(View.GONE);
            ll_settingUpload.setVisibility(View.GONE);

            setDetectionText(0);
        } else {
            mstb_upload.setVisibility(View.VISIBLE);
            ll_settingUpload.setVisibility(View.VISIBLE);

            setDetectionText(0);
            setUploadText(0);
        }

        mstb_alert.setValue(0);
        mstb_upload.setValue(0);

        if (!TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
            if (mCamera != null) {
                Logger.t(TAG).d("mCamera: " + mCamera.getSerialNumber());
                MountSetting mountSetting = mCamera.getMountSettings(true);
                if (mountSetting != null) {
                    onMountSettingChangeEvent(new MountSettingChangeEvent(mCamera, mountSetting));
                }
            }
        } else if (cameraBean != null) {

            if (cameraBean.settings != null) {
                MountSetting.ModeSetting drivingMode = cameraBean.settings.drivingMode;
                if (drivingMode != null) {
                    onMountSettingChangeEvent(drivingMode);
                }
            }
        }

        mstb_alert.setOnValueChangedListener(value -> {
            mstb_alert.setValue(value);//这里如果不设置的话，下面set时候拿到的value是上一次的value，不准确
            Logger.t(TAG).d("mstb_alert onValueChanged");
            setMountSetting("detectionSensitivity", value);

            int temp = mstb_upload.getValue();
            if (temp > value) {
                mstb_upload.setValue(value);
                setMountSetting("uploadSensitivity", value);
                setUploadText(value);
            }

            setDetectionText(value);
        });

        mstb_upload.setOnValueChangedListener(value -> {
            mstb_upload.setValue(value);//这里如果不设置的话，下面set时候拿到的value是上一次的value，不准确
            Logger.t(TAG).d("mstb_upload onValueChanged");
            setMountSetting("uploadSensitivity", value);

            int temp = mstb_alert.getValue();
            if (value > temp) {
                mstb_alert.setValue(value);
                setMountSetting("detectionSensitivity", value);
                setDetectionText(value);
            }

            setUploadText(value);
        });

        RxBus.getDefault()
                .toObservable(MountSettingChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountSettingChangeEvent, new ServerErrorHandler());

        return view;
    }

    private void setDetectionText(int value) {
        if (value >= 0 && value < detectionTitles.length) {
            tv_alertTitle.setText(detectionTitles[value]);
            tv_alertContent.setText(detectionContents[value]);
        }
    }

    private void setUploadText(int value) {
        if (value >= 0 && value < detectionTitles.length) {
            tv_uploadTitle.setText(uploadTitles[value]);
            tv_uploadContent.setText(uploadContents[value]);
        }
    }

    public void onMountSettingChangeEvent(MountSettingChangeEvent event) {
        if (event != null) {
            MountSetting.ModeSetting drivingMode = event.getMountSetting().drivingMode;
            if (drivingMode != null) {
                Logger.t(TAG).e("cameraSetting: " + drivingMode.monitoring
                        + "--detection: " + drivingMode.detectionSensitivity
                        + "--alert: " + drivingMode.alertSensitivity
                        + "--upload: " + drivingMode.uploadSensitivity);

                if (wifiOnly) {
                    int detectIndex;
                    if ("off".equals(drivingMode.monitoring)) {
                        detectIndex = 0;
                    } else {
                        detectIndex = getIndex(drivingMode.detectionSensitivity);
                    }
                    mstb_alert.setValue(detectIndex);
                    setDetectionText(detectIndex);
                } else {
                    int detectIndex;
                    int uploadIndex;
                    if ("off".equals(drivingMode.monitoring)) {
                        detectIndex = 0;
                        uploadIndex = 0;
                    } else {
                        detectIndex = getIndex(drivingMode.detectionSensitivity);
                        uploadIndex = getIndex(drivingMode.uploadSensitivity);
                    }
                    mstb_alert.setValue(detectIndex);
                    mstb_upload.setValue(uploadIndex);
                    setDetectionText(detectIndex);
                    setUploadText(uploadIndex);
                }
            }
        }
    }

    private void onMountSettingChangeEvent(MountSetting.ModeSetting drivingMode) {
        Logger.t(TAG).e("cameraSetting: " + drivingMode.monitoring
                + "--detection: " + drivingMode.detectionSensitivity
                + "--alert: " + drivingMode.alertSensitivity
                + "--upload: " + drivingMode.uploadSensitivity);

        int detectIndex;
        int uploadIndex;
        if ("off".equals(drivingMode.monitoring)) {
            detectIndex = 0;
            uploadIndex = 0;
        } else {
            detectIndex = getIndex(drivingMode.detectionSensitivity);
            uploadIndex = getIndex(drivingMode.uploadSensitivity);
        }
        mstb_alert.setValue(detectIndex);
        mstb_upload.setValue(uploadIndex);
        setDetectionText(detectIndex);
        setUploadText(uploadIndex);
    }

    private int getIndex(String flag) {
        int index;
        switch (flag) {
            case "low":
                index = 1;
                break;
            case "medium":
                index = 2;
                break;
            default:
                index = 0;
                break;
        }
        return index;
    }

    private void setMountSetting(String item, int index) {
        try {
            if (mCamera != null) {
                String sensitivity = "";
                if (index >= 0 && index < DRIVING_SETTING.length) {
                    sensitivity = DRIVING_SETTING[index];
                }
                if (TextUtils.isEmpty(sensitivity)) {
                    return;
                }
                JSONObject inModeSetting = new JSONObject();
                JSONObject driveSetting = new JSONObject();
                inModeSetting.put(item, sensitivity);
                driveSetting.put("drivingMode", inModeSetting);

                Logger.t(TAG).e("driveSetting = %s", driveSetting.toString());

                mCamera.setMountSettings(driveSetting.toString());
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    public String getDetection() {
        if (mstb_alert != null) {
            return DRIVING_SETTING[mstb_alert.getValue()];
        }
        return DRIVING_SETTING[0];
    }

    public String getUpload() {
        if (mstb_upload != null) {
            return DRIVING_SETTING[mstb_upload.getValue()];
        }
        return DRIVING_SETTING[0];
    }
}
