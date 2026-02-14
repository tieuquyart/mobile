package com.mk.autosecure.ui.activity.settings;

import static com.mkgroup.camera.bean.FleetCameraBean.ACTIVATED;
import static com.mk.autosecure.ui.activity.settings.AssetVehicleEditActivity.ARG_VEHICLE_INFO;
import static com.mk.autosecure.ui.activity.settings.AssetVehicleEditActivity.ARG_VEHICLE_VIEW;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.data.IntentKey;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.response.ActivateResponse;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.ObservableSource;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;


@SuppressLint("CheckResult")
public class AssetDeviceEditActivity extends RxAppCompatActivity {

    private final static String TAG = AssetDeviceEditActivity.class.getSimpleName();

    private final static String ARG_DEVICE_INFO = "arg_device_info";

    public final static String ARG_BIND_STATE = "arg_bind_state";
    public final static String ARG_SIM_STATE = "arg_sim_state";

    private final static int SETUP_REQUEST_CODE = 1001;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.tv_camera_sn)
    TextView tvBoundStatus;

    @BindView(R.id.tv_device_id)
    TextView tvDeviceId;

    @BindView(R.id.tv_device_password)
    TextView tvDevicePwd;

    @BindView(R.id.tv_device_sn)
    TextView tvDeviceSN;

    @BindView(R.id.tv_device_fccId)
    TextView tvDeviceFccid;

    @BindView(R.id.tv_device_phone)
    TextView tvDevicePhone;

    @BindView(R.id.tv_device_vehicle)
    TextView tvDeviceVehicle;

    @BindView(R.id.tv_device_status)
    TextView tvDeviceStatus;

    @BindView(R.id.btn_activate)
    Button btnActivate;

    @BindView(R.id.btn_go_edit)
    Button btnGoEdit;

    @BindView(R.id.btn_go_setup)
    Button btnGoSetup;

    @BindView(R.id.btn_remove)
    Button btnRemove;

    @OnClick(R.id.btn_activate)
    public void activate() {
        DialogHelper.showActivateCameraDialog(this, () -> {
            if (infoBean != null) {
                View loadingView = LayoutInflater.from(AssetDeviceEditActivity.this).inflate(R.layout.layout_loading_progress, null);
                ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                int cameraId = infoBean.getId();
                ApiClient.createApiService().activeCamera(cameraId, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                        .subscribe(booleanRs -> {
                                    if (booleanRs.isSuccess()) {
                                        HornApplication.getComponent().fleetInfo().refreshDeviceInfo();
                                        Toast.makeText(AssetDeviceEditActivity.this,
                                                "Kích hoạt thành công!", Toast.LENGTH_SHORT).show();
                                        finish();
                                    } else {
                                        NetworkErrorHelper.handleExpireToken(AssetDeviceEditActivity.this, booleanRs);
                                    }

                                }, throwable -> Toast.makeText(this, "Lỗi -- " + throwable.getMessage(), Toast.LENGTH_SHORT).show()
                        );
            }
        });
    }

    @OnClick(R.id.btn_go_edit)
    public void goEdit() {
        if (infoBean != null) {
            AddCameraActivity.launch(this, infoBean);
            finish();
        }
    }


    @OnClick(R.id.btn_go_setup)
    public void goSetup() {
        Logger.t(TAG).d("goSetup: " + infoBean);
        if (infoBean != null) {
            SetupFleetActivity.launchForResult(this, infoBean.getSn(), SETUP_REQUEST_CODE);
        }
    }

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_remove)
    public void remove() {
        Observable
                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                    View view = LayoutInflater.from(AssetDeviceEditActivity.this).inflate(R.layout.pop_remove_deactivate, null);
                    PopupWindow popupWindow = new PopupWindow(view,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            false);
                    popupWindow.setOutsideTouchable(false);

                    TextView textView = view.findViewById(R.id.tv_device_sn);
                    final int cameraId = infoBean.getId();
                    final String token = HornApplication.getComponent().currentUser()
                            .getAccessToken();
                    if (infoBean != null) {
                        textView.setText(String.format("S/N: %s", infoBean.getSn()));
                    }

                    view.findViewById(R.id.btn_remove_device).setOnClickListener(v -> {
                        popupWindow.dismiss();

                        if (infoBean != null) {
                            View loadingView = LayoutInflater.from(AssetDeviceEditActivity.this).inflate(R.layout.layout_loading_progress, null);
                            ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                            String simState = infoBean.getSimState();
                            Observable<BOOLResponse> observable;

                            if (ACTIVATED.equals(simState)) {
                                observable = ApiClient.createApiService().deactivateSim(infoBean.getSn())
                                        .subscribeOn(Schedulers.io())
                                        .compose(bindToLifecycle())
                                        .flatMap((Function<ActivateResponse, ObservableSource<BOOLResponse>>) activateResponse -> {
                                            if (activateResponse.isSuccess()) {
                                                String state = activateResponse.getState();
                                                Logger.t(TAG).d("deactivateSim state: " + state);
                                                HornApplication.getComponent().fleetInfo().updateDeviceActivate(infoBean.getSn(), state);

                                                if (ACTIVATED.equals(state)) {
                                                    return Observable.empty();
                                                } else {
                                                    return ApiClient.createApiService().deleteCamera(cameraId, token);
                                                }
                                            } else {
                                                NetworkErrorHelper.handleExpireToken(this, activateResponse);
                                                return Observable.empty();
                                            }
                                        });
                            } else {
                                observable = ApiClient.createApiService().deleteCamera(cameraId, token);
                            }

                            observable.compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(boolResponse -> {
                                        boolean result = boolResponse.isSuccess();
                                        Logger.t(TAG).d("deleteCamera result: " + result);
                                        if (result) {
                                            HornApplication.getComponent().fleetInfo().refreshDeviceInfo();
                                            finish();
                                            Toast.makeText(getApplicationContext(), "Xóa camera thành công", Toast.LENGTH_SHORT).show();
                                        } else {
                                            NetworkErrorHelper.handleExpireToken(this, boolResponse);
                                        }
                                    }, throwable -> Toast.makeText(getApplicationContext(), "Lỗi --" + throwable.getMessage(), Toast.LENGTH_SHORT).show());
                        }
                    });

                    view.findViewById(R.id.tv_cancel_remove).setOnClickListener(v -> popupWindow.dismiss());

                    emitter.onNext(Optional.ofNullable(popupWindow));
                })
                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(windowOptional -> windowOptional.get().showAsDropDown(btnRemove));
    }

    public static void launch(Activity activity, FleetCameraBean infoBean) {
        Intent intent = new Intent(activity, AssetDeviceEditActivity.class);
        intent.putExtra(ARG_DEVICE_INFO, infoBean);
        activity.startActivity(intent);
    }

    private FleetCameraBean infoBean;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_asset_device_edit);
        ButterKnife.bind(this);

        infoBean = (FleetCameraBean) getIntent().getSerializableExtra(ARG_DEVICE_INFO);
        Logger.t(TAG).d("infoBean: " + infoBean);

        initView();
    }

    private void initView() {
        setToolbar();

        if (infoBean != null) {
            tvToolbarTitle.setText(getString(R.string.device_information));

            if (infoBean.getStatus() == 0) {
                btnActivate.setVisibility(View.VISIBLE);
                btnGoEdit.setVisibility(View.VISIBLE);
            } else {
                btnActivate.setVisibility(View.GONE);
                btnGoEdit.setVisibility(View.GONE);
            }

            tvBoundStatus.setText(infoBean.getSn());
            tvDeviceId.setText(String.valueOf(infoBean.getId()));
            tvDevicePwd.setText(infoBean.getPassword());
            tvDeviceSN.setText(infoBean.getSn());
            tvDeviceFccid.setText(infoBean.getFccid());
            tvDevicePhone.setText(infoBean.getPhone());
            if (infoBean.getPlateNo() != null && !infoBean.getPlateNo().equals("")) {
                tvDeviceVehicle.setText(infoBean.getPlateNo());
                tvDeviceVehicle.setOnClickListener(view -> {
                    Log.d(TAG, infoBean.getPlateNo());
                    VehicleInfoBean bean = HornApplication.getComponent().fleetInfo().getVehicleWithPlateNo(infoBean.getPlateNo());
                    Logger.t(TAG).d("onClickItem VehicleInfoBean: " + bean);
                    Intent intent = new Intent(AssetDeviceEditActivity.this, AssetVehicleEditActivity.class);
                    intent.putExtra(ARG_VEHICLE_INFO, bean);
                    intent.putExtra(ARG_VEHICLE_VIEW, true);
                    startActivity(intent);
                });
            }

            tvDeviceStatus.setText(getStatusStringWithCode(infoBean.getStatus()));
        }
    }

    private String getStatusStringWithCode(int statusCode) {
        if (statusCode == 0)
            return "Đã thêm";
        else if (statusCode == 1)
            return "Đã đăng ký";
        else if (statusCode == 2)
            return "Đã kích hoạt";
        else return "Đã đăng ký";
    }

    private void initButton(boolean isBind, boolean isActivated) {
        tvBoundStatus.setText(isBind ? String.format(getString(R.string.bound_by_sth), infoBean.getPlateNo()) : getString(R.string.not_bound));

        btnActivate.setVisibility(isBind && !isActivated ? View.VISIBLE : View.INVISIBLE);
        btnGoSetup.setVisibility(isBind ? View.INVISIBLE : View.VISIBLE);

        btnRemove.setVisibility(isBind ? View.INVISIBLE : View.VISIBLE);
        btnRemove.setText(isActivated ? R.string.remove_and_deactivate : R.string.remove);
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == SETUP_REQUEST_CODE) {
//                boolean bindState = data.getBooleanExtra(ARG_BIND_STATE,
//                        infoBean != null && infoBean.isIsBind());
                boolean simState = data.getBooleanExtra(ARG_SIM_STATE,
                        infoBean != null && ACTIVATED.equals(infoBean.getSimState()));
                String plateNumber = data.getStringExtra(IntentKey.FLEET_PLATE_NUMBER);

                Logger.t(TAG).d("onActivityResult simState: " + simState
                        + " plateNumber: " + plateNumber);

//                initButton(bindState, simState);
//                if (bindState) {
//                    tvBoundStatus.setText(String.format(getString(R.string.bound_by_sth), plateNumber));
//                }
            }
        }
    }
}
