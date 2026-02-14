package com.mk.autosecure.ui.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.view.multistatetogglebutton.MultiStateToggleButton;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.HornApiService;
import com.mk.autosecure.rest.ServerErrorHandler;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
/**
 * Created by DoanVT on 2017/10/16.
 * Email: doanvt-hn@mk.com.vn
 */

public class EmergencyAlertActivity extends AppCompatActivity {
    public static final String TAG = EmergencyAlertActivity.class.getSimpleName();

    public static void launch(Context context, CameraBean cameraBean) {
        Intent intent = new Intent(context, EmergencyAlertActivity.class);
        intent.putExtra("CameraBean", cameraBean);
        context.startActivity(intent);
    }

    HornApiService mApiService;

    private CameraWrapper mCamera;

    private CameraBean mCameraBean;

    @BindView(R.id.mstb_alert)
    MultiStateToggleButton mstb_alert;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emergency_alert_setting);
        ButterKnife.bind(this);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra("CameraBean");
        mApiService = ApiService.createApiService();

        setupToolbar();

        VdtCameraManager.getManager().currentCamera()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(vdtCameraOptional -> {
                    CameraWrapper cameraWrapper = vdtCameraOptional.getIncludeNull();
                    Logger.t(TAG).d("got one camera");
                    mCamera = cameraWrapper;
                }, new ServerErrorHandler());

        mstb_alert.setValue(0);
    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }
}
