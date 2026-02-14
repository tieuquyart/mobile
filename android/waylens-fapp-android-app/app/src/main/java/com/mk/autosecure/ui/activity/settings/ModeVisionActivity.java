package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.widget.Switch;

import com.mk.autosecure.R;
import com.mk.autosecure.ui.data.IntentKey;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.message.bean.ModeVisionBean;
import com.orhanobut.logger.Logger;


import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnCheckedChanged;




public class ModeVisionActivity extends AppCompatActivity {

    private static final String TAG = MacActivity.class.getSimpleName();
    @BindView(R.id.switch_modeVision_stopParking)
    Switch switch_modeVision_stopParking;

    @BindView(R.id.switch_mode_overSpeed)
    Switch switch_mode_overSpeed;

    @BindView(R.id.switch_modeVision_trackingPlate)
    Switch switch_modeVision_trackingPlate;

    private String sn;
    private EvCamera mCamera;
    private CameraBean cameraBean;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mode_vision);
        ButterKnife.bind(this);

        initViews();
    }

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, ModeVisionActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    private void initViews() {
        switch_modeVision_stopParking.setChecked(false); // Default
        switch_mode_overSpeed.setChecked(false); // Default
        switch_modeVision_trackingPlate.setChecked(false);

        mCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            ModeVisionBean response = mCamera.getModeVision();
            Logger.t(TAG).d("getMAC Response: " + response);
//            Logger.t(TAG).d("getMAC Response: " + response.getStopParking());


            if (response != null) {
                switch_modeVision_stopParking.setChecked(response.getStopParking());
                switch_mode_overSpeed.setChecked(response.getOverSpeed());
                switch_modeVision_trackingPlate.setChecked(response.gettrackingPlate());
            }
        }
    }

    @OnCheckedChanged(R.id.switch_modeVision_stopParking)
    void onStopParkingSwitchChanged(boolean isChecked) {
        if (mCamera != null) {
            ModeVisionBean response = mCamera.getModeVision();
            Logger.t(TAG).d("check: " + isChecked);
            response.setStopParking(isChecked);
            mCamera.setModeVision(response);
        }
    }

    @OnCheckedChanged(R.id.switch_mode_overSpeed)
    void onOverSpeedSwitchChanged(boolean isChecked) {
        if (mCamera != null) {
            ModeVisionBean response = mCamera.getModeVision();
            Logger.t(TAG).d("check: " + isChecked);
            response.setOverSpeed(isChecked);
            mCamera.setModeVision(response);
        }
    }

    @OnCheckedChanged(R.id.switch_modeVision_trackingPlate)
    void onTrackingPlateSwitchChanged(boolean isChecked) {
        if (mCamera != null) {
            ModeVisionBean response = mCamera.getModeVision();
            Logger.t(TAG).d("check: " + isChecked);
            response.setTrackingPlate(isChecked);
            mCamera.setModeVision(response);

        }
    }


}