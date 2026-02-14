package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.response.ActivateResponse;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

import static com.mkgroup.camera.bean.FleetCameraBean.ACTIVATED;

public class SimActivateActivity extends RxAppCompatActivity {

    private final static String TAG = SimActivateActivity.class.getSimpleName();

    @BindView(R.id.tv_camera_sn)
    TextView tvCameraSn;

    @OnClick(R.id.btn_activate)
    public void activate() {
        View view = LayoutInflater.from(this).inflate(R.layout.layout_loading_progress, null);
        ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(view);

        ApiClient.createApiService().activateSim(sn)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(view))
                .subscribe(new BaseObserver<ActivateResponse>() {
                    @Override
                    protected void onHandleSuccess(ActivateResponse data) {
                        String state = data.getState();
                        Logger.t(TAG).d("activateSim state: " + state);
                        HornApplication.getComponent().fleetInfo().updateDeviceActivate(sn, state);

                        if (ACTIVATED.equals(state)) {
                            setResult(RESULT_OK);
                        }
                        finish();
                    }
                });
    }

    private String sn = "";

    public static void launch(Activity activity, boolean setup) {
        Intent intent = new Intent(activity, SimActivateActivity.class);
        if (setup) {
            activity.startActivityForResult(intent, SetupFleetActivity.REQUEST_SIM_ACTIVATE);
        } else {
            activity.startActivity(intent);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sim_activate);
        ButterKnife.bind(this);

        initView();
    }

    private void initView() {
        setToolbar();

        CameraWrapper cameraWrapper = VdtCameraManager.getManager().getCurrentCamera();
        if (cameraWrapper != null) {
            sn = cameraWrapper.getSerialNumber();
            tvCameraSn.setText(sn);
        }
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }
}
