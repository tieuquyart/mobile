package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.settings.NotiManageActivity.LOAD_LIST_NOTI;
import static com.mk.autosecure.ui.data.IntentKey.RELOAD_LIST;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.request.BindCameraBody;
import com.mk.autosecure.rest_fleet.request.BindDriverBody;
import com.mk.autosecure.rest_fleet.response.CameraResponse;
import com.mk.autosecure.ui.data.IntentKey;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;

public class PersonnelEditActivity extends RxAppCompatActivity {

    private final static String TAG = PersonnelEditActivity.class.getSimpleName();

    private final static String ARGS = "args";
    public final static String INFO = "info";
    public final static String BEAN = "bean";

    public final static String EMAIL = "Email";
    public final static String NAME = "Name";
    public final static String PHONE_NUMBER = "Phone Number";

    public final static String PLATE_NUMBER = "Plate Number";
    public final static String VEHICLE_MODEL = "Vehicle Model";
    public final static String DRIVER = "Driver";
    public final static String DEVICE = "Device";
    public final static String VEHICLE_EDIT = "Vehicle edit";

    public final static String SETUP_CHOOSE_PLATE_NUMBER = "Choose a Plate Number";
    public final static String SETUP_ADD_PLATE_NUMBER = "Add New Plate Number";

    public final static int REQUEST_CODE_VEHICLE_MODEL = 2002;
    public final static int REQUEST_CODE_DRIVER = 2003;
    public final static int REQUEST_CODE_DEVICE = 2004;
    public final static int REQUEST_CODE_VEHICLE_EDIT = 2005;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.ll_input)
    LinearLayout llInput;

    @BindView(R.id.et_personnel)
    EditText etPersonnel;

    @BindView(R.id.ll_plate_number)
    LinearLayout llPlateNumber;

    @BindView(R.id.et_plate_number)
    EditText etPlateNumber;

    @BindView(R.id.ll_select_driver)
    RelativeLayout llSelectDriver;

    @BindView(R.id.rg_drivers)
    RadioGroup rgDrivers;

    @BindView(R.id.ll_select_device)
    RelativeLayout llSelectDevice;

    @BindView(R.id.rg_devices)
    RadioGroup rgDevices;
    //edit driver
    @BindView(R.id.ll_driver_edit)
    LinearLayout llDriverEdit;

    @BindView(R.id.ed_driver_name)
    EditText edDriverName;

    @BindView(R.id.ed_driver_gender)
    EditText edGender;

    @BindView(R.id.ed_driver_phone)
    EditText edDriverPhone;

    @BindView(R.id.ed_driver_idNo)
    EditText edDriverIdNo;

    @BindView(R.id.ed_driver_license)
    EditText edDriverLisence;

    @BindView(R.id.ed_license_type)
    EditText edLicenseType;

    @BindView(R.id.ed_driving_years)
    EditText edDrivingYears;

    @BindView(R.id.ed_employeeId)
    EditText edEmployee;

    //end

//    @BindView(R.id.ll_select_vehicle)
//    LinearLayout llSelectVehicle;

    @BindView(R.id.ll_vehicle_edit)
    LinearLayout llEditVehicle;

    @BindView(R.id.ed_plate_number)
    EditText edplateNo;

    @BindView(R.id.ed_vehicle_model)
    EditText edVehicleModel;

    @BindView(R.id.ed_vehicle_no)
    EditText edVehicleNo;

    @BindView(R.id.ed_vehicle_capacity)
    EditText edVehicleCapacity;

    @BindView(R.id.ed_vehicle_type)
    EditText edVehicleType;

    @BindView(R.id.rg_vehicles)
    RadioGroup rgVehicles;

    @BindView(R.id.btn_bind)
    Button btnBind;

    @BindView(R.id.ll_email_warning)
    LinearLayout llEmailWarning;

    @BindView(R.id.view_line)
    View viewLine;

    @BindView(R.id.ll_phone_warning)
    LinearLayout llPhoneWarning;


    @OnClick(R.id.btn_confirm)
    public void confirmOnClick(){
        if (vehicleID == -1) {
            setResult();
        } else if (DRIVER.equals(args) && currentDriverCheckedID != -1) {

            View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
            ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

            RadioButton button = findViewById(currentDriverCheckedID);
            int index = radioButtonList.indexOf(button);
            DriverInfoBean bean = unbindDriverList.get(index);

            if (bean != null) {
                int driverID = bean.getId();
                BindDriverBody bindDriverBody = new BindDriverBody(driverID);

                ApiClient.createApiService().assignVehicleDriver(vehicleID,bindDriverBody,HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                        .subscribe(new BaseObserver<BOOLResponse>() {
                            @Override
                            protected void onHandleSuccess(BOOLResponse data) {
                                boolean result = data.isSuccess();
                                Logger.t(TAG).d("updateBindVehicleDriver result: " + result);
                                if (result) {
                                    HornApplication.getComponent().fleetInfo().updateBindVehicleDriver(vehicleID, driverID, false);
                                    setResult();
                                }else{
                                    NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
                                }
                            }
                        });
            }
        }else if(DEVICE.equals(args) && currentCameraCheckedID != -1){
            View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
            ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

            RadioButton button = findViewById(currentCameraCheckedID);
            int index = radioButtonList.indexOf(button);
            FleetCameraBean bean = cameraList.get(index);

            if (bean != null) {
                int cameraId = bean.getId();
                String cameraSn = bean.getSn();
                BindCameraBody body = new BindCameraBody(cameraId);

                ApiClient.createApiService().assignVehicleCamera(vehicleID,body,HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                        .subscribe(new BaseObserver<BOOLResponse>() {
                            @Override
                            protected void onHandleSuccess(BOOLResponse data) {
                                boolean result = data.isSuccess();
                                Logger.t(TAG).d("updateBindVehicleCamera result: " + result);
                                if (result) {
                                    HornApplication.getComponent().fleetInfo().updateBindVehicleDevice(vehicleID, cameraSn, false);
                                    setResult();
                                }else{
                                    NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
//                                            Toast.makeText(PersonnelEditActivity.this,data.getMessage(),Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
            } else {
                BindCameraBody body = new BindCameraBody(cameraId);

                ApiClient.createApiService().assignVehicleCamera(vehicleID,body,HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                        .subscribe(new BaseObserver<BOOLResponse>() {
                            @Override
                            protected void onHandleSuccess(BOOLResponse data) {
                                boolean result = data.isSuccess();
                                Logger.t(TAG).d("updateBindVehicleCamera result: " + result);
                                if (result) {
                                    HornApplication.getComponent().fleetInfo().updateBindVehicleDevice(vehicleID, "", false);
                                    setResult();
                                }else{
                                    NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
//                                            Toast.makeText(PersonnelEditActivity.this,data.getMessage(),Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
            }
        }
    }

    @OnClick(R.id.btn_cancel)
    public void cancelOnClick(){
        finish();
    }



    @OnClick(R.id.ll_add_plate_number)
    public void addPlateNumber() {
        PersonnelEditActivity.launchForResult(this, SETUP_ADD_PLATE_NUMBER, etPlateNumber.getText().toString().trim(), AddVehicleActivity.REQUEST_SETUP_ADD_PLATE_NUMBER);
    }

    @OnClick(R.id.btn_bind)
    public void bind() {
        setResult();
    }

    public static void launchForResult(Activity activity, String args, String info, int REQUEST_CODE) {
        Intent intent = new Intent(activity, PersonnelEditActivity.class);
        intent.putExtra(ARGS, args);
        intent.putExtra(INFO, info);
        activity.startActivityForResult(intent, REQUEST_CODE);
    }

    public static void launchForResult(Activity activity, String args, String info, int REQUEST_CODE,
                                       int vehicleID, int driverID, int cameraId, String plateNumber) {
        Intent intent = new Intent(activity, PersonnelEditActivity.class);
        intent.putExtra(ARGS, args);
        intent.putExtra(INFO, info);
        intent.putExtra(IntentKey.FLEET_VEHICLE_ID, vehicleID);
        intent.putExtra(IntentKey.FLEET_DRIVER_ID, driverID);
        intent.putExtra(IntentKey.FLEET_CAMERA_ID, cameraId);
        intent.putExtra(IntentKey.FLEET_PLATE_NUMBER, plateNumber);
        activity.startActivityForResult(intent, REQUEST_CODE);
    }

    public static void launchForResult(Activity activity, String args, VehicleInfoBean bean, int REQUEST_CODE) {
        Intent intent = new Intent(activity, PersonnelEditActivity.class);
        intent.putExtra(ARGS, args);
        intent.putExtra(IntentKey.FLEET_VEHICLE_ID,bean.getId());
        intent.putExtra(BEAN, bean);
        activity.startActivityForResult(intent, REQUEST_CODE);
    }

    private String args;

    private String info;

    private int vehicleID;

    private int driverID;

    private int cameraId;

    private VehicleInfoBean infoBean;

    private String plateNumber;

    private List<RadioButton> radioButtonList = new ArrayList<>();

    private List<DriverInfoBean> unbindDriverList = new ArrayList<>();

    private List<FleetCameraBean> cameraList = new ArrayList<>();

    private List<VehicleInfoBean> unbindVehicleList = new ArrayList<>();

    private int currentDriverCheckedID = -1;

    private int currentVehicleCheckedID = -1;

    private int currentCameraCheckedID = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_personnel_edit);
        ButterKnife.bind(this);

        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        setupToolbar();

        args = getIntent().getStringExtra(ARGS);
        info = getIntent().getStringExtra(INFO);
        vehicleID = getIntent().getIntExtra(IntentKey.FLEET_VEHICLE_ID, -1);
        driverID = getIntent().getIntExtra(IntentKey.FLEET_DRIVER_ID, -1);
        cameraId = getIntent().getIntExtra(IntentKey.FLEET_CAMERA_ID, -1);
        plateNumber = getIntent().getStringExtra(IntentKey.FLEET_PLATE_NUMBER);
        infoBean = (VehicleInfoBean)getIntent().getSerializableExtra(BEAN);

        etPersonnel.setText(info);
//        etPersonnel.requestFocus();

        if (EMAIL.equals(args)) {

            llEmailWarning.setVisibility(View.VISIBLE);
            etPersonnel.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);

        } else if (NAME.equals(args)
                || VEHICLE_MODEL.equals(args)) {

            viewLine.setVisibility(View.VISIBLE);
            etPersonnel.setInputType(InputType.TYPE_CLASS_TEXT);

        } else if (PHONE_NUMBER.equals(args)) {

            llPhoneWarning.setVisibility(View.VISIBLE);
            etPersonnel.setInputType(InputType.TYPE_CLASS_PHONE);

        } else if (DRIVER.equals(args)) {
            tvToolbarTitle.setText(getString(R.string.title_driver_list));
            llInput.setVisibility(View.GONE);
            llEditVehicle.setVisibility(View.GONE);
            llSelectDriver.setVisibility(View.VISIBLE);
            llSelectDevice.setVisibility(View.GONE);
            rgDrivers.setOnCheckedChangeListener((group, checkedId) -> currentDriverCheckedID = checkedId);

            ApiClient.createApiService().getDriverList(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            List<DriverInfoBean> driverInfos = response.getData();
                            initDrivers(driverInfos);
                            HornApplication.getComponent().fleetInfo().refreshDrivers(driverInfos);
                        }else{
                            NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,response);
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getDriverList throwable: " + throwable.getMessage());
                        HornApplication.getComponent().fleetInfo().driverObservable()
                                .compose(bindToLifecycle())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe(this::onDriverList, new ServerErrorHandler(TAG));
                    });

        }else if(DEVICE.equals(args)){
            tvToolbarTitle.setText(getString(R.string.title_camera_list));
            llInput.setVisibility(View.GONE);
            llEditVehicle.setVisibility(View.GONE);
            llSelectDriver.setVisibility(View.GONE);
            llSelectDevice.setVisibility(View.VISIBLE);
            rgDevices.setOnCheckedChangeListener((group, checkedId) -> currentCameraCheckedID = checkedId);


            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<CameraResponse>() {
                        @Override
                        public void accept(CameraResponse cameraResponse) throws Exception {
                            if (cameraResponse.isSuccess()){
                                List<FleetCameraBean> cameraBeans = cameraResponse.getData();
                                initCameras(cameraBeans);
                                HornApplication.getComponent().fleetInfo().refreshDevices(cameraBeans);
                            }else {
                                NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,cameraResponse);
//                                Toast.makeText(PersonnelEditActivity.this,cameraResponse.getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getDriverList throwable: " + throwable.getMessage());
                        HornApplication.getComponent().fleetInfo().deviceObservable()
                                .compose(bindToLifecycle())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe(this::onDeviceList, new ServerErrorHandler(TAG));
                    });

        }else if(VEHICLE_EDIT.equals(args)){
            llInput.setVisibility(View.GONE);
            llEditVehicle.setVisibility(View.VISIBLE);
            llSelectDriver.setVisibility(View.GONE);
            llSelectDevice.setVisibility(View.GONE);
            if (infoBean == null){
                Toast.makeText(PersonnelEditActivity.this, "bean null", Toast.LENGTH_SHORT).show();
                return;
            }
            edplateNo.setText(infoBean.getPlateNo());
            edVehicleModel.setText(infoBean.getBrand());
            edVehicleNo.setText(infoBean.getVehicleNo());
            edVehicleCapacity.setText(infoBean.getCapacity());
            edVehicleType.setText(infoBean.getType());

        }else if (SETUP_CHOOSE_PLATE_NUMBER.equals(args)) {

            toolbar.getMenu().clear();
            llInput.setVisibility(View.GONE);
//            llSelectVehicle.setVisibility(View.VISIBLE);
            rgVehicles.setOnCheckedChangeListener((group, checkedId) -> {
                currentVehicleCheckedID = checkedId;
                if (!btnBind.isEnabled()) {
                    btnBind.setEnabled(true);
                }
            });

            HornApplication.getComponent().fleetInfo().vehicleObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::onVehicleList, new ServerErrorHandler(TAG));

            ApiClient.createApiService().getVehiclePage(1,15,HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        List<VehicleInfoBean> vehicleInfos = response.getData().getRecords();
                        initVehicles(vehicleInfos);
                        HornApplication.getComponent().fleetInfo().refreshVehicles(vehicleInfos);
                    }, throwable -> {
                        Logger.t(TAG).e("getVehicleInfoList throwable: " + throwable.getMessage());
                        List<VehicleInfoBean> vehicles = HornApplication.getComponent().fleetInfo().getVehicles();
                        initVehicles(vehicles);
                    });
        } else if (PLATE_NUMBER.equals(args)
                || SETUP_ADD_PLATE_NUMBER.equals(args)) {

            toolbar.getMenu().clear();
            toolbar.inflateMenu(R.menu.menu_add_camera);

            llInput.setVisibility(View.GONE);
            llPlateNumber.setVisibility(View.VISIBLE);
            viewLine.setVisibility(View.VISIBLE);
//            etPlateNumber.requestFocus();
            etPlateNumber.setInputType(InputType.TYPE_CLASS_TEXT);
        }
    }

    private void onVehicleList(Optional<List<VehicleInfoBean>> listOptional) {
        List<VehicleInfoBean> vehicleInfoBeans = listOptional.getIncludeNull();
        if (vehicleInfoBeans != null && vehicleInfoBeans.size() != 0) {
            Logger.t(TAG).d("onVehicleList: " + vehicleInfoBeans.size());
            initVehicles(vehicleInfoBeans);
        }
    }

    private void onDriverList(Optional<List<DriverInfoBean>> listOptional) {
        List<DriverInfoBean> driverInfoBeans = listOptional.getIncludeNull();
        if (driverInfoBeans != null && driverInfoBeans.size() != 0) {
            Logger.t(TAG).d("onDriverList: " + driverInfoBeans.size());
            initDrivers(driverInfoBeans);
        }
    }

    private void onDeviceList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeanList = listOptional.getIncludeNull();
        if (cameraBeanList != null && cameraBeanList.size() != 0) {
            Logger.t(TAG).d("onDriverList: " + cameraBeanList.size());
            initCameras(cameraBeanList);
        }
    }

    private void initDrivers(List<DriverInfoBean> drivers) {
        Logger.t(TAG).d("initDrivers: " + drivers.size());
        rgDrivers.removeAllViews();
        radioButtonList.clear();
        unbindDriverList.clear();

        for (int i = 0; i < drivers.size(); i++) {
            DriverInfoBean infoBean = drivers.get(i);
                RadioButton radio = createRadio(infoBean.getName(), i);
                rgDrivers.addView(radio);
                radioButtonList.add(radio);
                unbindDriverList.add(infoBean);

                if (info.equals(infoBean.getName())) {
                    currentDriverCheckedID = radio.getId();
                    rgDrivers.check(currentDriverCheckedID);
                }
        }

    }

    private void initCameras(List<FleetCameraBean> cameras) {
        Logger.t(TAG).d("initDrivers: " + cameras.size());
        rgDevices.removeAllViews();
        radioButtonList.clear();
        cameraList.clear();

        for (int i = 0; i < cameras.size(); i++) {
            FleetCameraBean infoBean = cameras.get(i);
            RadioButton radio = createRadio(infoBean.getSn(), i);
            rgDevices.addView(radio);
            radioButtonList.add(radio);
            cameraList.add(infoBean);

            if (info.equals(infoBean.getSn())) {
                currentCameraCheckedID = radio.getId();
                rgDevices.check(currentCameraCheckedID);
            }
        }

    }

    private void initVehicles(List<VehicleInfoBean> vehicles) {
        Logger.t(TAG).d("initVehicles: " + vehicles.size());
        rgVehicles.removeAllViews();
        radioButtonList.clear();
        unbindVehicleList.clear();

        for (int i = 0; i < vehicles.size(); i++) {
            VehicleInfoBean vehicleInfoBean = vehicles.get(i);

            if (TextUtils.isEmpty(vehicleInfoBean.getCameraSn())) {
                RadioButton radio = createRadio(vehicleInfoBean.getPlateNo(), i);
                rgVehicles.addView(radio);
                radioButtonList.add(radio);
                unbindVehicleList.add(vehicleInfoBean);

                if (info.equals(vehicleInfoBean.getPlateNo())) {
                    currentVehicleCheckedID = radio.getId();
                    rgVehicles.check(currentVehicleCheckedID);
                }
            }
        }

        RadioButton idleButton = createRadio("", vehicles.size());
        rgVehicles.addView(idleButton);
        radioButtonList.add(idleButton);
        unbindVehicleList.add(null); // null bean
    }

    private RadioButton createRadio(String name, int index) {
        RadioButton radioButton = new RadioButton(this);
        RadioGroup.LayoutParams params = new RadioGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(20), Gravity.CENTER_VERTICAL);
        params.setMargins(ViewUtils.dp2px(29), index == 0 ? 0 : ViewUtils.dp2px(12), 0, ViewUtils.dp2px(12));
        radioButton.setLayoutParams(params);
        radioButton.setText(name);
        radioButton.setTextColor(getResources().getColor(R.color.colorPrimary));
        radioButton.setTextSize(14f);
        return radioButton;
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
//        toolbar.inflateMenu(R.menu.menu_personnel_finish);

        toolbar.setOnMenuItemClickListener(item -> {

            if (item.getItemId() == R.id.finish) {
                if (vehicleID == -1) {
                    setResult();
                } else if (DRIVER.equals(args) && currentDriverCheckedID != -1) {

                    View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
                    ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

                    RadioButton button = findViewById(currentDriverCheckedID);
                    int index = radioButtonList.indexOf(button);
                    DriverInfoBean bean = unbindDriverList.get(index);

                    if (bean != null) {
                        int driverID = bean.getId();
                        BindDriverBody bindDriverBody = new BindDriverBody(driverID);

                        ApiClient.createApiService().assignVehicleDriver(vehicleID,bindDriverBody,HornApplication.getComponent().currentUser().getAccessToken())
                                .compose(Transformers.switchSchedulers())
                                .compose(bindToLifecycle())
                                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                                .subscribe(new BaseObserver<BOOLResponse>() {
                                    @Override
                                    protected void onHandleSuccess(BOOLResponse data) {
                                        boolean result = data.isSuccess();
                                        Logger.t(TAG).d("updateBindVehicleDriver result: " + result);
                                        if (result) {
                                            HornApplication.getComponent().fleetInfo().updateBindVehicleDriver(vehicleID, driverID, false);
                                            setResult();
                                        }else{
                                            NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
//                                            Toast.makeText(PersonnelEditActivity.this,data.getMessage(),Toast.LENGTH_SHORT).show();
                                        }
                                    }
                                });
                    }// else {
//                        BindDriverBody bindDriverBody = new BindDriverBody(driverID);
//
//                        ApiClient.createApiService().unbindVehicleDriver(bindDriverBody)
//                                .compose(Transformers.switchSchedulers())
//                                .compose(bindToLifecycle())
//                                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
//                                .subscribe(new BaseObserver<BooleanResponse>() {
//                                    @Override
//                                    protected void onHandleSuccess(BooleanResponse data) {
//                                        boolean result = data.result;
//                                        Logger.t(TAG).d("unbindVehicleDriver result: " + result);
//                                        if (result) {
//                                            HornApplication.getComponent().fleetInfo().updateBindVehicleDriver(vehicleID, driverID, true);
//                                            setResult();
//                                        }
//                                    }
//                                });
//                    }
                }else if(DEVICE.equals(args)){

                    View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
                    ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

                    RadioButton button = findViewById(currentCameraCheckedID);
                    int index = radioButtonList.indexOf(button);
                    FleetCameraBean bean = cameraList.get(index);

                    if (bean != null) {
                        int cameraId = bean.getId();
                        String cameraSn = bean.getSn();
                        BindCameraBody body = new BindCameraBody(cameraId);

                        ApiClient.createApiService().assignVehicleCamera(vehicleID,body,HornApplication.getComponent().currentUser().getAccessToken())
                                .compose(Transformers.switchSchedulers())
                                .compose(bindToLifecycle())
                                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                                .subscribe(new BaseObserver<BOOLResponse>() {
                                    @Override
                                    protected void onHandleSuccess(BOOLResponse data) {
                                        boolean result = data.isSuccess();
                                        Logger.t(TAG).d("updateBindVehicleCamera result: " + result);
                                        if (result) {
                                            HornApplication.getComponent().fleetInfo().updateBindVehicleDevice(vehicleID, cameraSn, false);
                                            setResult();
                                        }else{
                                            NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
//                                            Toast.makeText(PersonnelEditActivity.this,data.getMessage(),Toast.LENGTH_SHORT).show();
                                        }
                                    }
                                });
                    } else {
                        BindCameraBody body = new BindCameraBody(cameraId);

                        ApiClient.createApiService().assignVehicleCamera(vehicleID,body,HornApplication.getComponent().currentUser().getAccessToken())
                                .compose(Transformers.switchSchedulers())
                                .compose(bindToLifecycle())
                                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                                .subscribe(new BaseObserver<BOOLResponse>() {
                                    @Override
                                    protected void onHandleSuccess(BOOLResponse data) {
                                        boolean result = data.isSuccess();
                                        Logger.t(TAG).d("updateBindVehicleCamera result: " + result);
                                        if (result) {
                                            HornApplication.getComponent().fleetInfo().updateBindVehicleDevice(vehicleID, "", false);
                                            setResult();
                                        }else{
                                            NetworkErrorHelper.handleExpireToken(PersonnelEditActivity.this,data);
//                                            Toast.makeText(PersonnelEditActivity.this,data.getMessage(),Toast.LENGTH_SHORT).show();
                                        }
                                    }
                                });
                    }

                }else if(VEHICLE_EDIT.equals(args)){
//                    View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
//                    ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);
//
//                    String plateNo = edplateNo.getText().toString().trim();
//                    String brand = edVehicleModel.getText().toString().trim();
//                    String capacity = edVehicleCapacity.getText().toString().trim();
//                    String vehicleNo = edVehicleNo.getText().toString().trim();
//                    String type = edVehicleType.getText().toString().trim();
//
//                    EditVehicleBody body = new EditVehicleBody(plateNo,brand,vehicleNo,capacity,type,vehicleID);
//
//                    ApiClient.createApiService().editVehicle(vehicleID,body, HornApplication.getComponent().currentUser().getAccessToken())
//                            .compose(Transformers.switchSchedulers())
//                            .compose(bindToLifecycle())
//                            .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
//                            .subscribe(new BaseObserver<BOOLResponse>() {
//                                @Override
//                                protected void onHandleSuccess(BOOLResponse data) {
//                                    if (data.isSuccess()) {
//                                        HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
//                                        HornApplication.getComponent().fleetInfo().updateEditVehicle(vehicleID,brand,capacity,type);
//                                        setResult();
//                                    }else{
//                                        Toast.makeText(PersonnelEditActivity.this, data.getMessage(), 0).show();
//                                    }
//                                }
//                            });

                }/* else if (VEHICLE_MODEL.equals(args)) {

                    View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
                    ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

                    String model = etPersonnel.getText().toString().trim();
                    CreateVehicleBody createVehicleBody = new CreateVehicleBody(plateNumber, model);

                    ApiClient.createApiService().updateVehicleInfo(vehicleID, createVehicleBody)
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                            .subscribe(new BaseObserver<BooleanResponse>() {
                                @Override
                                protected void onHandleSuccess(BooleanResponse data) {
                                    boolean result = data.result;
                                    Logger.t(TAG).d("updateVehicleInfo result: " + result);
                                    if (result) {
                                        HornApplication.getComponent().fleetInfo().refreshVehicleInfo();
                                        setResult();
                                    }
                                }
                            });
                }*/
            } else if (item.getItemId() == R.id.add) {
                if (PLATE_NUMBER.equals(args) || SETUP_ADD_PLATE_NUMBER.equals(args)) {
                    String plateNumber = etPlateNumber.getText().toString().trim();
                    if (!TextUtils.isEmpty(plateNumber)) {
                        hideSoftInputWindow();
                        showPop(plateNumber);
                    } else {
                        Toast.makeText(this, "Please input the plate number.", Toast.LENGTH_SHORT).show();
                    }
                }
            }
            return true;
        });
    }

    private void hideSoftInputWindow() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(etPlateNumber.getWindowToken(), 0);
        }
    }

    @SuppressLint("CheckResult")
    private void showPop(String plateNumber) {
        Observable
                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                    View view = LayoutInflater.from(this).inflate(R.layout.pop_add_plate_number, null);
                    PopupWindow popupWindow = new PopupWindow(view,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            false);
                    popupWindow.setOutsideTouchable(false);

                    TextView textView = view.findViewById(R.id.tv_plate_number);
                    textView.setText(String.format("Plate Number: \n%s", plateNumber));

                    view.findViewById(R.id.btn_add_action).setOnClickListener(v -> {
                        popupWindow.dismiss();
                        setResult();
                    });

                    view.findViewById(R.id.tv_cancel_add).setOnClickListener(v -> popupWindow.dismiss());

                    emitter.onNext(Optional.ofNullable(popupWindow));
                })
                .delay(100, TimeUnit.MILLISECONDS)
                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(windowOptional -> windowOptional.get().showAsDropDown(toolbar));
    }

    private void setResult() {
        Intent intent = new Intent(RELOAD_LIST);
        if (currentDriverCheckedID != -1) {
            RadioButton button = findViewById(currentDriverCheckedID);
            int index = radioButtonList.indexOf(button);
            DriverInfoBean bean = unbindDriverList.get(index);
            intent.putExtra(INFO, bean);
        } else if (currentCameraCheckedID != -1) {
            RadioButton button = findViewById(currentCameraCheckedID);
            int index = radioButtonList.indexOf(button);
            FleetCameraBean bean = cameraList.get(index);
            intent.putExtra(INFO, bean);
        } else if (currentVehicleCheckedID != -1) {
            RadioButton button = findViewById(currentVehicleCheckedID);
            int index = radioButtonList.indexOf(button);
            VehicleInfoBean vehicleInfoBean = unbindVehicleList.get(index);
            if (vehicleInfoBean != null) {
                intent.putExtra(INFO, vehicleInfoBean);
            } else {
                String plateNumber = etPlateNumber.getText().toString().trim();
                intent.putExtra(INFO, plateNumber);
            }
        }else if(VEHICLE_EDIT.equals(args)){
            intent.putExtra(INFO,HornApplication.getComponent().fleetInfo().getVehicleWithId(vehicleID));
        } else if (PLATE_NUMBER.equals(args) || SETUP_ADD_PLATE_NUMBER.equals(args)) {
            intent.putExtra(INFO, etPlateNumber.getText().toString().trim());
        } else {
            intent.putExtra(INFO, etPersonnel.getText().toString().trim());
        }
        setResult(RESULT_OK, intent);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == AddVehicleActivity.REQUEST_SETUP_ADD_PLATE_NUMBER) {
                Intent intent = new Intent();
                intent.putExtra(INFO, data.getStringExtra(INFO));
                setResult(RESULT_OK, intent);
                finish();
            }
        }
    }
}
