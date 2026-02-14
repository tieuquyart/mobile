package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.BaseObserver;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.functions.Action;

public class AssetVehicleEditActivity extends RxAppCompatActivity {

    private final static String TAG = AssetVehicleEditActivity.class.getSimpleName();

    public final static String ARG_VEHICLE_INFO = "arg_vehicle_info";
    public final static String ARG_VEHICLE_VIEW = "arg_vehicle_view";

    public final static int REQUEST_CODE_VEHICLE_MODEL = 2002;
    public final static int REQUEST_CODE_DRIVER = 2003;
    public final static int REQUEST_CODE_DEVICE = 2004;
    public final static int REQUEST_CODE_VEHICLE_EDIT = 2005;

    boolean checkView = false;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.tv_vehicle_id)
    TextView tvVehicleId;

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.tv_vehicle_model)
    TextView tvVehicleModel;

    @BindView(R.id.tv_vehicle_camera)
    TextView tvVehicleCamera;

    @BindView(R.id.tv_vehicle_type)
    TextView tvVehicleType;

    @BindView(R.id.tv_vehicle_capacity)
    TextView tvVehicleCapacity;

    @BindView(R.id.ll_bottom)
    LinearLayout llBottom;

    @BindView(R.id.img_driver_edit)
    ImageView imgDriveArrow;

    @BindView(R.id.img_camera_edit)
    ImageView imgCameraArrow;

    @BindView(R.id.btn_unbind_remove)
    Button btnUnbindRemove;

    @BindView(R.id.btn_vehicle_edit)
    Button btnVehicleEdit;

    @OnClick(R.id.ll_driver)
    public void editDriver() {
        if (!checkView)
            PersonnelEditActivity.launchForResult(this, PersonnelEditActivity.DRIVER, tvDriverName.getText().toString().trim(),
                    REQUEST_CODE_DRIVER, infoBean.getId(), infoBean.getDriverId(), infoBean.getCameraId(), infoBean.getPlateNo());
    }

//    @OnClick(R.id.ll_vehicle_model)
//    public void editModel() {
//        PersonnelEditActivity.launchForResult(this, VEHICLE_MODEL, tvVehicleModel.getText().toString().trim(),
//                REQUEST_CODE_VEHICLE_MODEL, infoBean.getId(), infoBean.getDriverId(), infoBean.getCameraId(), infoBean.getPlateNo());
//    }

    @OnClick(R.id.ll_vehicle_camera)
    public void cameraDetail() {
        if (infoBean != null && !checkView) {
            PersonnelEditActivity.launchForResult(this, PersonnelEditActivity.DEVICE, tvVehicleCamera.getText().toString().trim(),
                    REQUEST_CODE_DEVICE, infoBean.getId(), infoBean.getDriverId(), infoBean.getCameraId(), infoBean.getPlateNo());
        }
    }

    @OnClick(R.id.btn_unbind_remove)
    public void unbindOrRemove() {
        Logger.t(TAG).d("unbindOrRemove");
        if (infoBean != null) {
            String cameraSN = infoBean.getCameraSn();

            if (TextUtils.isEmpty(cameraSN)) {
                DialogHelper.showRemoveVehicleDialog(this, posAction);
            } else {
                DialogHelper.showUnbindDeviceDialog(this, posAction);
            }
        }
    }

    @OnClick(R.id.btn_vehicle_edit)
    public void editVehicle() {
        if (infoBean != null) {
//            PersonnelEditActivity.launchForResult(this, VEHICLE_EDIT, infoBean, REQUEST_CODE_VEHICLE_EDIT);
            AddVehicleActivity.launch(this, infoBean);
            finish();
        }
    }

    public static void launch(Activity activity, VehicleInfoBean infoBean) {
        Intent intent = new Intent(activity, AssetVehicleEditActivity.class);
        intent.putExtra(ARG_VEHICLE_INFO, infoBean);
        activity.startActivity(intent);
    }

    private VehicleInfoBean infoBean;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_asset_vehicle_edit);
        ButterKnife.bind(this);

        infoBean = (VehicleInfoBean) getIntent().getSerializableExtra(ARG_VEHICLE_INFO);
        checkView = getIntent().getBooleanExtra(ARG_VEHICLE_VIEW, false);
        if (checkView) {
            btnVehicleEdit.setVisibility(View.GONE);
            btnUnbindRemove.setVisibility(View.GONE);
            imgCameraArrow.setVisibility(View.GONE);
            imgDriveArrow.setVisibility(View.GONE);
            llBottom.setVisibility(View.INVISIBLE);
        }
        initView();
    }

    private void initView() {
        setToolbar();

        if (infoBean != null) {
            tvToolbarTitle.setText(getString(R.string.vehicle_detail));
            tvVehicleId.setText(String.valueOf(infoBean.getId()));
            tvPlateNumber.setText(infoBean.getPlateNo());
            tvVehicleModel.setText(infoBean.getBrand());
            tvVehicleType.setText(infoBean.getType());
            tvVehicleCapacity.setText(infoBean.getCapacity());

            DriverInfoBean driverInfoBean = HornApplication.getComponent().fleetInfo().queryDriver(infoBean.getDriverId());
            if (driverInfoBean != null) {
                tvDriverName.setText(driverInfoBean.getName());
            }

            String cameraSN = infoBean.getCameraSn();
            initButton(cameraSN);
        }
    }

    private void initButton(String cameraSN) {
        if (TextUtils.isEmpty(cameraSN)) {
            tvVehicleCamera.setText(R.string.bind);
        } else {
            tvVehicleCamera.setText(cameraSN);
        }
        btnUnbindRemove.setText(R.string.remove);
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == REQUEST_CODE_DRIVER) {
                DriverInfoBean driverInfoBean = (DriverInfoBean) data.getSerializableExtra(PersonnelEditActivity.INFO);
                infoBean.setDriverId(driverInfoBean == null ? 0 : driverInfoBean.getId());
                tvDriverName.setText(driverInfoBean == null ? "" : driverInfoBean.getName());
            } else if (requestCode == REQUEST_CODE_DEVICE) {
                FleetCameraBean bean = (FleetCameraBean) data.getSerializableExtra(PersonnelEditActivity.INFO);
                infoBean.setCameraSn(bean == null ? "" : bean.getSn());
                tvVehicleCamera.setText(bean == null ? "" : bean.getSn());
            } else if (requestCode == REQUEST_CODE_VEHICLE_EDIT) {
                VehicleInfoBean bean = (VehicleInfoBean) data.getSerializableExtra(PersonnelEditActivity.INFO);
                tvVehicleModel.setText(bean.getBrand());
                tvVehicleType.setText(bean.getType());
                tvVehicleCapacity.setText(bean.getCapacity());
            } else {
                String info = data.getStringExtra(PersonnelEditActivity.INFO);

                if (requestCode == REQUEST_CODE_VEHICLE_MODEL) {
                    tvVehicleModel.setText(info);
                } else if (requestCode == BindCameraActivity.REQUEST_CODE_SN) {
                    infoBean.setCameraSn(info);
                    initButton(info);
                }
            }
        }
    }

    private Action posAction = new Action() {
        @Override
        public void run() {
            if (infoBean != null) {
                View view = LayoutInflater.from(AssetVehicleEditActivity.this).inflate(R.layout.layout_loading_progress, null);
                ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

                int vehicleID = infoBean.getId();
                Observable<BOOLResponse> observable = ApiClient.createApiService().deleteVehicleInfo(vehicleID, HornApplication.getComponent().currentUser().getAccessToken());

                observable
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                        .subscribe(new BaseObserver<BOOLResponse>() {
                            @Override
                            protected void onHandleSuccess(BOOLResponse response) {
                                boolean result = response.isSuccess();
                                Logger.t(TAG).d("unbindOrRemove result: " + result);
                                if (response.isSuccess()) {
                                    Toast.makeText(getApplicationContext(), response.isSuccess() ? "Xóa xe thành công" : "Xóa xe lỗi", Toast.LENGTH_SHORT).show();
                                    HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
                                    finish();
                                } else {
                                    NetworkErrorHelper.handleExpireToken(AssetVehicleEditActivity.this,response);
                                }
                            }
                        });
            }
        }
    };
}
