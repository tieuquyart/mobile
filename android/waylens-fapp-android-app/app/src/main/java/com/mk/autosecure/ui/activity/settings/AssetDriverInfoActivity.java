package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.settings.PersonnelEditActivity.INFO;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.functions.Action;

public class AssetDriverInfoActivity extends RxAppCompatActivity {
    private final static String TAG = AssetDriverInfoActivity.class.getSimpleName();
    private final static String ARG_DRIVER_INFO = "arg_driver_info";
    private DriverInfoBean driverInfoBean;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.tv_bound_status)
    TextView tvBoundStatus;

    @BindView(R.id.tv_driver_id)
    TextView tvDriverId;

    @BindView(R.id.tv_employee_id)
    TextView tvEmployeeId;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.tv_gender)
    TextView tvGender;

    @BindView(R.id.tv_phone_number)
    TextView tvPhone;

    @BindView(R.id.tv_id_number)
    TextView tvIdNumber;

    @BindView(R.id.tv_driver_license)
    TextView tvDriverLicense;

    @BindView(R.id.tv_license_type)
    TextView tvLicenseType;

    @BindView(R.id.tv_driving_year)
    TextView tvDrivingYears;

    @OnClick(R.id.btn_driver_edit)
    public void editDriver() {
        DriverActivity.launch(this, driverInfoBean);
        finish();
    }

    @OnClick(R.id.btn_remove)
    public void removeDriver() {
        if (driverInfoBean != null) {
            DialogHelper.showRemoveDriverDialog(this, posAction);
        }
    }


    public static void launch(Activity activity, DriverInfoBean driverInfoBean) {
        Intent intent = new Intent(activity, AssetDriverInfoActivity.class);
        intent.putExtra(ARG_DRIVER_INFO, driverInfoBean);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_asset_driver_edit);
        ButterKnife.bind(this);
        driverInfoBean = (DriverInfoBean) getIntent().getSerializableExtra(ARG_DRIVER_INFO);
        Logger.t(TAG).d("infoBean: " + driverInfoBean);

        initView();
    }

    private void initView() {
        setToolbar();
        if (driverInfoBean != null) {
            tvToolbarTitle.setText(getString(R.string.driver_detail));
            tvBoundStatus.setText(driverInfoBean.getName());
            tvDriverId.setText(String.valueOf(driverInfoBean.getId()));
            tvEmployeeId.setText(driverInfoBean.getEmployeeId());
            tvDriverName.setText(driverInfoBean.getName());
            tvPhone.setText(driverInfoBean.getPhoneNo());
            tvIdNumber.setText(driverInfoBean.getIdNumber());
            tvDriverLicense.setText(driverInfoBean.getLicense());
            tvLicenseType.setText(driverInfoBean.getLicenseType());
            String[] arrTime = driverInfoBean.getDrivingYears().split("T");
            if (arrTime.length > 1) {
                tvDrivingYears.setText(arrTime[0]);
            } else {
                tvDrivingYears.setText(driverInfoBean.getDrivingYears());
            }
        }
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    private Action posAction = new Action() {
        @Override
        public void run() {
            if (driverInfoBean != null) {
                View view = LayoutInflater.from(AssetDriverInfoActivity.this).inflate(R.layout.layout_loading_progress, null);
                ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

                int driverId = driverInfoBean.getId();
                Observable<BOOLResponse> observable = ApiClient.createApiService().delDriver(driverId, HornApplication.getComponent().currentUser().getAccessToken());

                observable
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                        .subscribe(new BaseObserver<BOOLResponse>() {
                            @Override
                            protected void onHandleSuccess(BOOLResponse response) {
                                boolean result = response.isSuccess();
                                if (result) {
                                    Toast.makeText(getApplicationContext(), "Xóa xe tài xế thành công", Toast.LENGTH_SHORT).show();
                                    HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
                                    finish();
                                } else {
                                    Toast.makeText(getApplicationContext(), response.getMessage(), Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
            }
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == 1101) {
                DriverInfoBean driverInfoBean = (DriverInfoBean) data.getSerializableExtra(INFO);
                tvBoundStatus.setText(driverInfoBean.getName());
                tvDriverId.setText(String.valueOf(driverInfoBean.getId()));
                tvEmployeeId.setText(driverInfoBean.getEmployeeId());
                tvDriverName.setText(driverInfoBean.getName());
                tvGender.setText(driverInfoBean.getGender() == 1 ? getString(R.string.male) : getString(R.string.female));
                tvPhone.setText(driverInfoBean.getPhoneNo());
                tvIdNumber.setText(driverInfoBean.getIdNumber());
                tvDriverLicense.setText(driverInfoBean.getLicense());
                tvLicenseType.setText(driverInfoBean.getLicenseType());
                tvDrivingYears.setText(String.valueOf(driverInfoBean.getDrivingYears()));
            }
        }
    }
}
