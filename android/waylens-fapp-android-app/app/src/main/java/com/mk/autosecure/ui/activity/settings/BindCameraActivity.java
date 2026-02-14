package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.settings.PersonnelEditActivity.INFO;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.BindCameraBody;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

public class BindCameraActivity extends RxAppCompatActivity {

    private final static String TAG = BindCameraActivity.class.getSimpleName();

    private final static String VEHICLE_ID = "vehicle_id";

    public final static int REQUEST_CODE_SN = 0x01;

    @BindView(R.id.rg_cameras)
    RadioGroup rgCameras;

    @BindView(R.id.btn_bind)
    Button btnBind;

    @OnClick(R.id.ll_add_camera)
    public void addCamera() {
        Logger.t(TAG).d("addCamera");
        AddCameraActivity.launch(this, null);
    }

    @OnClick(R.id.btn_bind)
    public void bind() {
        View loadingView = LayoutInflater.from(BindCameraActivity.this).inflate(R.layout.layout_loading_progress, null);
        ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

        RadioButton button = findViewById(currentCheckedId);
        String sn = button.getText().toString().trim();
        Logger.t(TAG).d("bind: " + vehicleID + " " + sn);

        BindCameraBody body = new BindCameraBody(-1);
        ApiClient.createApiService().bindVehicleCamera(body)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                .subscribe(new BaseObserver<BooleanResponse>() {
                    @Override
                    protected void onHandleSuccess(BooleanResponse data) {
                        boolean result = data.result;
                        Logger.t(TAG).d("bindVehicleCamera result: " + result);
                        if (result) {
                            HornApplication.getComponent().fleetInfo().updateBindVehicleDevice(vehicleID, sn, false);

                            Intent intent = new Intent();
                            intent.putExtra(INFO, sn);
                            setResult(RESULT_OK, intent);
                            finish();
                        }
                    }
                });
    }

    public static void launch(Activity activity, String vehicleID) {
        Intent intent = new Intent(activity, BindCameraActivity.class);
        intent.putExtra(VEHICLE_ID, vehicleID);
        activity.startActivityForResult(intent, REQUEST_CODE_SN);
    }

    private List<RadioButton> radioButtonList = new ArrayList<>();

    private int currentCheckedId = -1;

    private int vehicleID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_bind_camera);
        ButterKnife.bind(this);

        vehicleID = getIntent().getIntExtra(VEHICLE_ID, -1);

        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        setToolbar();

        rgCameras.setOnCheckedChangeListener((group, checkedId) -> {
            currentCheckedId = checkedId;

            if (!btnBind.isEnabled()) {
                btnBind.setEnabled(true);
            }
        });

        HornApplication.getComponent().fleetInfo().deviceObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDeviceList, new ServerErrorHandler(TAG));

        ApiClient.createApiService().getDeviceList(HornApplication.getComponent().currentUser().getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(response -> {
                    List<FleetCameraBean> cameraInfos = response.getData();
                    HornApplication.getComponent().fleetInfo().refreshDevices(cameraInfos);
                    initDeviceList(cameraInfos);
                }, throwable -> {
                    Logger.t(TAG).e("getDeviceInfoList throwable: " + throwable.getMessage());
                    List<FleetCameraBean> devices = HornApplication.getComponent().fleetInfo().getDevices();
                    initDeviceList(devices);
                });
    }

    private void onDeviceList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeans = listOptional.getIncludeNull();
        if (cameraBeans != null && cameraBeans.size() != 0) {
            Logger.t(TAG).d("onDeviceList: " + cameraBeans.size());
            initDeviceList(cameraBeans);
        }
    }

    private void initDeviceList(List<FleetCameraBean> devices) {
        Logger.t(TAG).d("initDeviceList: " + devices.size());
        radioButtonList.clear();
        rgCameras.removeAllViews();

        for (int i = 0; i < devices.size(); i++) {
            FleetCameraBean infoBean = devices.get(i);
            if (infoBean.getStatus() != 2) {
                RadioButton radio = createRadio(infoBean.getSn(), i);
                radioButtonList.add(radio);
                rgCameras.addView(radio);
            }
        }
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

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }
}
