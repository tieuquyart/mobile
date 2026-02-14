package com.mk.autosecure.ui.activity.settings;

import static com.mkgroup.camera.bean.FleetCameraBean.ACTIVATED;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_CAMERA_SETUP;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_DIRECT_TEST;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_ES_NETWORK_TEST;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_NETWORK_TEST;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_SELECT_CAMERA;
import static com.mk.autosecure.ui.activity.settings.AssetDeviceEditActivity.ARG_BIND_STATE;
import static com.mk.autosecure.ui.activity.settings.AssetDeviceEditActivity.ARG_SIM_STATE;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.Fragment;

import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.SetupActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class SetupFleetActivity extends AppCompatActivity {

    private final static String TAG = SetupFleetActivity.class.getSimpleName();

    public final static int REQUEST_ADD_VEHICLE = 1000;
    public final static int REQUEST_SIM_ACTIVATE = 2000;
    public final static int REQUEST_CALIB_CAMERA = 3000;

    @BindView(R.id.include_setup_fleet)
    ConstraintLayout includeSetupFleet;

    @BindView(R.id.toolbar_fleet)
    Toolbar toolbarFleet;

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.tv_vehicle_model)
    TextView tvVehicleModel;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.tv_camera_sn)
    TextView tvCameraSn;

    @BindView(R.id.include_setup_installer)
    ConstraintLayout includeSetupInstaller;

    @BindView(R.id.toolbar_installer)
    Toolbar toolbarInstaller;

    @BindView(R.id.iv_install_result)
    ImageView ivInstallResult;

    @BindView(R.id.tv_install_result)
    TextView tvInstallResult;

    @BindView(R.id.tv_install_tips)
    TextView tvInstallTips;

    @OnClick(R.id.btn_ok)
    public void ok() {
        exit();
    }

    private boolean isFirstInit = true;

    private String sn;

    private String plateNumber;

    private boolean isActivated = false;

    private String setupSn;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SetupFleetActivity.class);
        activity.startActivity(intent);
    }

    public static void launchForResult(Activity activity, String sn, int requestCode) {
        Intent intent = new Intent(activity, SetupFleetActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivityForResult(intent, requestCode);
    }

    public static void launchForInstaller(Fragment fragment, int requestCode) {
        Intent intent = new Intent(fragment.getContext(), SetupFleetActivity.class);
        fragment.startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_fleet);
        ButterKnife.bind(this);

        initView();
    }

    private void initView() {
        setToolbar();
        setupSn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
    }

    private void setToolbar() {
        toolbarFleet.setNavigationOnClickListener(v -> exit());
        toolbarInstaller.setNavigationOnClickListener(v -> exit());
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (isFirstInit) {
            isFirstInit = false;
            if (Constants.isFleet() && (Constants.isLogin() /*|| Constants.isDriver()*/)) {
//                SetupActivity.launchForInstaller(this, true);
                SelectCameraActvity.launch(this, GUIDE_SELECT_CAMERA);
            } else {
//                AddVehicleActivity.launch(this, true);
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        Logger.t(TAG).d("onActivityResult: " + requestCode + " " + resultCode);
        super.onActivityResult(requestCode, resultCode, data);
        String camera = "";
        if (resultCode == RESULT_OK && requestCode == REQUEST_ADD_VEHICLE && data != null) {
            plateNumber = data.getStringExtra(IntentKey.FLEET_PLATE_NUMBER);
            String vehicleModel = data.getStringExtra(IntentKey.FLEET_VEHICLE_MODEL);
            String driverName = data.getStringExtra(IntentKey.FLEET_DRIVER_NAME);
            sn = data.getStringExtra(IntentKey.SERIAL_NUMBER);
            tvPlateNumber.setText(plateNumber);
            tvVehicleModel.setText(vehicleModel);
            tvDriverName.setText(TextUtils.isEmpty(driverName) ? "Idle Vehicle" : driverName);
            tvCameraSn.setText(sn);

            SetupActivity.launchForFleet(this, sn);
        } else if (resultCode == RESULT_OK && requestCode == GUIDE_SELECT_CAMERA && data != null) {
            camera = data.getStringExtra("camera");
            if ("Secure360".equals(camera)) {
                SetupActivity.launchForInstaller(this, true);
            } else if ("SecureES".equals(camera)) {
                ARouter.getInstance()
                        .build("/ui/activity/settings/NetworkTestActivity")
                        .withString("skipSelect", "SecureES")
                        .navigation(this, GUIDE_ES_NETWORK_TEST);
            }
        } else if (resultCode == RESULT_OK && requestCode == GUIDE_CAMERA_SETUP) {
            DirectTestActivity.launch(this, true);
        } else if (resultCode == RESULT_OK && requestCode == GUIDE_DIRECT_TEST) {
            if (Constants.isFleet() /*&& (Constants.isLogin() || Constants.isDriver()*/) {
//                NetworkTestActivity.launch(this, true);
                ARouter.getInstance()
                        .build("/ui/activity/settings/NetworkTestActivity")
                        .withString("skipSelect", camera)
                        .navigation(this, GUIDE_NETWORK_TEST);
            } else {
                FleetCameraBean bean = HornApplication.getComponent().fleetInfo().queryDevice(sn);
                Logger.t(TAG).d("onActivityResult FleetCameraBean: " + bean);
                if (bean != null && ACTIVATED.equals(bean.getSimState())) {
                    isActivated = true;
//                    NetworkTestActivity.launch(this, true);
                    ARouter.getInstance()
                            .build("/ui/activity/settings/NetworkTestActivity")
                            .withString("skipSelect", camera)
                            .navigation(this, GUIDE_NETWORK_TEST);
                } else {
                    SimActivateActivity.launch(this, true);
                }
            }
        } else if (resultCode == RESULT_OK && requestCode == REQUEST_SIM_ACTIVATE) {
            isActivated = true;
            NetworkTestActivity.launch(this, true);
        } else if (requestCode == GUIDE_NETWORK_TEST) {
            Logger.t(TAG).d("GUIDE_NETWORK_TEST finish: " + resultCode);
            if (Constants.isFleet()/* && (Constants.isInstaller() || Constants.isDriver()*/) {
                if (resultCode == RESULT_OK) {
                    ivInstallResult.setImageResource(R.drawable.icon_network_success);
                    tvInstallResult.setText(R.string.finished);
                    tvInstallTips.setText(R.string.camera_installed_successfully);
                } else if (resultCode == RESULT_CANCELED) {
                    ivInstallResult.setImageResource(R.drawable.icon_error_offline);
                    tvInstallResult.setText(R.string.almost_finished);
                    tvInstallTips.setText(R.string.contact_supplier_for_network_error);
                }
                // network both success and fail

                CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                Logger.t(TAG).d("currentCamera: " + currentCamera);

                if (currentCamera == null) {
//                    Toast.makeText(this, R.string.setting_request, Toast.LENGTH_LONG).show();
                    return;
                }

                if (!currentCamera.isCalibCameraAvailable()) {
//                    Toast.makeText(this, R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
                    return;
                }

                CalibActivity.launch(this, true);
            }
        } else if (resultCode == RESULT_OK && requestCode == REQUEST_CALIB_CAMERA) {
            Logger.t(TAG).d("REQUEST_CALIB_CAMERA finish");
        } else {
            exit();
        }
    }

    private void exit() {
        HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
        HornApplication.getComponent().fleetInfo().refreshDeviceInfo();

        if (!TextUtils.isEmpty(setupSn)) {
            setResult();
        }

        if (Constants.isFleet()/* && (Constants.isInstaller() || Constants.isDriver())*/) {
            setResult(RESULT_OK);
        }

        finish();
    }

    private void setResult() {
        Intent intent = new Intent();
        boolean bindState = setupSn.equals(sn);
        Logger.t(TAG).d("setResult setupSn: " + setupSn + " sn: " + sn
                + " isActivated: " + isActivated
                + " plateNumber: " + plateNumber);
        intent.putExtra(ARG_BIND_STATE, bindState);
        intent.putExtra(ARG_SIM_STATE, isActivated);
        intent.putExtra(IntentKey.FLEET_PLATE_NUMBER, plateNumber);
        setResult(RESULT_OK, intent);
    }
}