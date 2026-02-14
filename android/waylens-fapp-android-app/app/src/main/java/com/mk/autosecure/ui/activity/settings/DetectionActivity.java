package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.MountAccTrustChangeEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class DetectionActivity extends RxActivity {

    private final static String TAG = DetectionActivity.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.rg_detection)
    RadioGroup rg_detection;

    @BindView(R.id.rb_power_cable)
    RadioButton rb_power_cable;

    @BindView(R.id.rb_camera_sensors)
    RadioButton rb_camera_sensors;

    private CameraWrapper mCamera;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, DetectionActivity.class);
        activity.startActivity(intent);
    }

    @OnClick(R.id.ll_testing_connection)
    public void testing() {
        DirectTestActivity.launch(this, false);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detection);
        ButterKnife.bind(this);
        setToolbar();

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        initView();
        initListener();
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (mCamera != null) {
            int accTrust = mCamera.getMountAccTrust();
            Logger.t(TAG).d("accTrust: " + accTrust);

            if (VdtCamera.MOUNT_ACC_TRUST == accTrust) {
                rb_power_cable.setChecked(true);
            } else if (VdtCamera.MOUNT_ACC_NOT_TRUST == accTrust) {
                rb_camera_sensors.setChecked(true);
            }
        }
    }

    private void initListener() {
        RxBus.getDefault().toObservable(MountAccTrustChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAccTrustChangeEvent, new ServerErrorHandler());
    }

    private void onAccTrustChangeEvent(MountAccTrustChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int acctrust = event.getAcctrust();
            Logger.t(TAG).e("acctrust: " + acctrust);

            if (acctrust == VdtCamera.MOUNT_ACC_TRUST) {
                rb_power_cable.setChecked(true);
            } else if (acctrust == VdtCamera.MOUNT_ACC_NOT_TRUST) {
                rb_camera_sensors.setChecked(true);
            }
        }
    }

    private void initView() {
        tv_toolbarTitle.setText(R.string.detection);

        rg_detection.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rb_power_cable) {
                trustAcc();
            } else if (checkedId == R.id.rb_camera_sensors) {
                notTrustAcc();
            }
        });
    }

    private void trustAcc() {
        if (mCamera != null) {
            mCamera.setMountAccTrust(true);
        }
    }

    private void notTrustAcc() {
        if (mCamera != null) {
            mCamera.setMountAccTrust(false);
        }
    }

    private void setToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }
}
