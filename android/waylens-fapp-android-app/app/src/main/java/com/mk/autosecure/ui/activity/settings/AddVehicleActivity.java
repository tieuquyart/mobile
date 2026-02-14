package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.widget.Toolbar;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.request.CreateVehicleBody;
import com.mk.autosecure.rest_fleet.request.EditVehicleBody;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class AddVehicleActivity extends RxAppCompatActivity {

    private final static String TAG = AddVehicleActivity.class.getSimpleName();

    public final static int REQUEST_CODE_PLATE_NUMBER = 2001;
    public final static int REQUEST_CODE_VEHICLE_MODEL = 2002;
    public final static int REQUEST_CODE_DRIVER = 2003;
    public final static int REQUEST_SETUP_CHOOSE_PLATE_NUMBER = 2004;
    public final static int REQUEST_SETUP_ADD_PLATE_NUMBER = 2005;
    public final static String VEHICLE_INFO = "Vehicle_info";

    VehicleInfoBean infoBean;
    boolean isPlateNo;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.et_plateNo)
    EditText etPlateNumber;

    @BindView(R.id.et_vehicle_brand)
    EditText etVehicleBrand;

    @BindView(R.id.et_vehicleNo)
    EditText etVehicleNo;

    @BindView(R.id.et_vehicle_type)
    EditText etVehicleType;

    @OnClick(R.id.btn_cancel_add)
    public void cancelAdd() {
        finish();
    }

    @BindView(R.id.btn_confirm_add)
    Button btnConfirmAdd;

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_confirm_add)
    public void confirmAdd() {
        Logger.t(TAG).d("addVehicle");

        loadingView = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
        ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);
        String plateNumber = etPlateNumber.getText().toString().trim();
        String brand = etVehicleBrand.getText().toString().trim();
        String vehicleNo = etVehicleNo.getText().toString().trim();
        String capacity = "";
        String type = etVehicleType.getText().toString().trim();
        String businessLicense = "";
        if (!TextUtils.isEmpty(plateNumber)
                && !TextUtils.isEmpty(brand)
                && !TextUtils.isEmpty(vehicleNo)
                && !TextUtils.isEmpty(type)) {

            if (infoBean != null) {
                EditVehicleBody body = new EditVehicleBody(infoBean.getPlateNo(), brand, infoBean.getVehicleNo(), capacity, type, infoBean.getId(), infoBean.getBusinessLicense());

                ApiClient.createApiService().editVehicle(infoBean.getId(), body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                        .doOnError(throwable -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                        .subscribe(booleanRes -> {
                            if (booleanRes.isSuccess()) {
//                                HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
//                                    HornApplication.getComponent().fleetInfo().updateEditVehicle(vehicleID,brand,capacity,type);
                                Toast.makeText(this, "Sửa xe thành công", Toast.LENGTH_SHORT).show();
                                handleFinish();
                            } else {
                                NetworkErrorHelper.handleExpireToken(this, booleanRes);
                            }
                        }, throwable -> new ServerErrorHandler(TAG));
            } else {
                CreateVehicleBody body = new CreateVehicleBody(plateNumber, brand, vehicleNo, capacity, type, businessLicense);
                ApiClient.createApiService().createVehicle(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(()-> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                        .doOnError(throwable -> ((FrameLayout) AddVehicleActivity.this.findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                        .subscribe(boolResponse -> {
                            if (boolResponse.isSuccess()) {
                                Toast.makeText(this, "Thêm xe thành công", Toast.LENGTH_SHORT).show();
//                                HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
                                handleFinish();
                            } else {
                                NetworkErrorHelper.handleExpireToken(this, boolResponse);
                            }
                        }, throwable -> new ServerErrorHandler(TAG));
            }
        } else {
            Toast.makeText(this, "Vui lòng nhập đầy đủ thông tin", Toast.LENGTH_SHORT).show();
        }
    }

    public void handleFinish(){
        Intent intent = new Intent(IntentKey.RELOAD_LIST);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        finish();
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, AddVehicleActivity.class);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, VehicleInfoBean bean) {
        Intent intent = new Intent(activity, AddVehicleActivity.class);
        intent.putExtra(VEHICLE_INFO, bean);
        activity.startActivity(intent);
    }


    private View loadingView;

    private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_vehicle);
        ButterKnife.bind(this);
        if (getIntent() != null) {
            infoBean = (VehicleInfoBean) getIntent().getSerializableExtra(VEHICLE_INFO);
        }
        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        setToolbar();

        if (infoBean != null) {
            tvToolbarTitle.setText(R.string.edit_vehicle_info);
            etPlateNumber.setText(infoBean.getPlateNo());
            etPlateNumber.setEnabled(false);
            etPlateNumber.setBackground(getDrawable(R.drawable.bg_uncheck_filter));

            etVehicleBrand.setText(infoBean.getBrand());
            etVehicleType.setText(infoBean.getType());

            etVehicleNo.setText(infoBean.getVehicleNo());
            etVehicleNo.setEnabled(false);
            etVehicleNo.setBackground(getDrawable(R.drawable.bg_uncheck_filter));
            isPlateNo = true;

        } else {
            tvToolbarTitle.setText(R.string.add_new_vehicle);
        }
        checkButtonEnable();

        etPlateNumber.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if(StringUtils.isPlateNoValid(textValidate)){
                    isPlateNo = true;
                }else{
                    isPlateNo = false;
                    etPlateNumber.setError("Sai định dạng biển số xe");
                }
                checkButtonEnable();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

        etVehicleBrand.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                checkButtonEnable();
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etVehicleType.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                checkButtonEnable();
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etVehicleType.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                checkButtonEnable();
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

    }

    @SuppressLint("CheckResult")
    @Override
    protected void onResume() {
        super.onResume();
    }


    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    private void checkButtonEnable() {
        String plateNumber = etPlateNumber.getText().toString().trim();
        String brand = etVehicleBrand.getText().toString().trim();
        String vehicleNo = etVehicleNo.getText().toString().trim();
        String type = etVehicleType.getText().toString().trim();
        btnConfirmAdd.setEnabled(!TextUtils.isEmpty(plateNumber)
                && !TextUtils.isEmpty(brand)
                && !TextUtils.isEmpty(vehicleNo)
                && !TextUtils.isEmpty(type)
                && isPlateNo
        );

    }
}
