package com.mk.autosecure.ui.activity.settings;

import androidx.appcompat.widget.Toolbar;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.response.CameraResponse;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.functions.Consumer;

public class CameraDetailActivity extends RxAppCompatActivity {

    private final static String TAG = CameraDetailActivity.class.getSimpleName();

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.tv_serial_number)
    TextView tvSerialNumber;

    @BindView(R.id.tv_camera_status)
    TextView tvCameraStatus;

    @BindView(R.id.tv_camera_firmware)
    TextView tvCameraFirmware;

    @BindView(R.id.tv_data_usage)
    TextView tvDataUsage;

    public static void launch(Activity activity, String cameraSN, String plateNumber) {
        Intent intent = new Intent(activity, CameraDetailActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, cameraSN);
        intent.putExtra(IntentKey.FLEET_PLATE_NUMBER, plateNumber);
        activity.startActivity(intent);
    }

    private String sn;

    private String plateNumber;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_camera_detail);
        ButterKnife.bind(this);

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        plateNumber = getIntent().getStringExtra(IntentKey.FLEET_PLATE_NUMBER);

        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        setToolbar();

        Logger.t(TAG).d("initView sn: " + sn + " plateNumber: " + plateNumber);

//        if (!TextUtils.isEmpty(sn)) {
//            tvSerialNumber.setText(sn);

            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<CameraResponse>() {
                        @Override
                        public void accept(CameraResponse cameraResponse) throws Exception {
                            Logger.t(TAG).d("response: " + cameraResponse);
//                            tvCameraStatus.setText(data.getMode());
//                            tvCameraFirmware.setText(data.getFirmwareShort());
                        }
                    });
//        }

//        if (!TextUtils.isEmpty(plateNumber)) {
//            tvPlateNumber.setText(plateNumber);
//        }
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }
}
