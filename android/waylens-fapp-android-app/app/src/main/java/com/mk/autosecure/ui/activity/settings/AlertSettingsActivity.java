package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.Toast;

import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.request.NotificationInfoBody;
import com.mk.autosecure.rest_fleet.response.NotificationInfoResponse;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

public class AlertSettingsActivity extends RxAppCompatActivity {

    private final static String TAG = AlertSettingsActivity.class.getSimpleName();

    public final static String PARKING_MODE = "PARKING_MODE";
    public final static String DRIVING_MODE = "DRIVING_MODE";

    public final static String PARKING_MOTION = "PARKING_MOTION";
    public final static String PARKING_HIT = "PARKING_HIT";
    public final static String PARKING_HEAVY_HIT = "PARKING_HEAVY_HIT";
    public final static String DRIVING_HIT = "DRIVING_HIT";
    public final static String DRIVING_HEAVY_HIT = "DRIVING_HEAVY_HIT";

    public final static String HARD_ACCEL = "HARD_ACCEL";
    public final static String HARD_BRAKE = "HARD_BRAKE";
    public final static String SHARP_TURN = "SHARP_TURN";
    public final static String HARSH_ACCEL = "HARSH_ACCEL";
    public final static String HARSH_BRAKE = "HARSH_BRAKE";
    public final static String HARSH_TURN = "HARSH_TURN";
    public final static String SEVERE_ACCEL = "SEVERE_ACCEL";
    public final static String SEVERE_BRAKE = "SEVERE_BRAKE";
    public final static String SEVERE_TURN = "SEVERE_TURN";

    public final static String SDCARD_STATUS = "SDCARD_STATUS";

    public final static String POWER_EVENT = "POWER_EVENT";

    public final static String GEO_FENCE_ENTER = "GEO_FENCE_ENTER";
    public final static String GEO_FENCE_EXIT = "GEO_FENCE_EXIT";

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, AlertSettingsActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.switch_return_vehicle)
    Switch switchReturnVehicle;

    @BindView(R.id.switch_driving_parking)
    Switch switchDrivingParking;

    @BindView(R.id.switch_geo_fence)
    Switch switchGeoFence;

    @BindView(R.id.switch_drivers_orders)
    Switch switchDriversOrders;

    @BindView(R.id.switch_behavior_type)
    Switch switchBehaviorType;

    @BindView(R.id.switch_hit_type)
    Switch switchHitType;

    private List<String> typesList;
    private List<String> hitTypeList;
    private List<String> behaviorTypeList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_alert_settings);
        ButterKnife.bind(this);
        setToolbar();

        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        hitTypeList = new ArrayList<>();
        hitTypeList.add(PARKING_MOTION);
        hitTypeList.add(PARKING_HEAVY_HIT);
        hitTypeList.add(PARKING_HIT);
        hitTypeList.add(DRIVING_HEAVY_HIT);
        hitTypeList.add(DRIVING_HIT);

        behaviorTypeList = new ArrayList<>();
        behaviorTypeList.add(HARD_ACCEL);
        behaviorTypeList.add(HARD_BRAKE);
        behaviorTypeList.add(SHARP_TURN);
        behaviorTypeList.add(HARSH_ACCEL);
        behaviorTypeList.add(HARSH_BRAKE);
        behaviorTypeList.add(HARSH_TURN);
        behaviorTypeList.add(SEVERE_ACCEL);
        behaviorTypeList.add(SEVERE_BRAKE);
        behaviorTypeList.add(SEVERE_TURN);

        typesList = new ArrayList<>();

        switchReturnVehicle.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

            }
        });

        switchDrivingParking.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                typesList.remove(DRIVING_MODE);
                typesList.remove(PARKING_MODE);
            } else {
                if (!typesList.contains(DRIVING_MODE)) typesList.add(DRIVING_MODE);
                if (!typesList.contains(PARKING_MODE)) typesList.add(PARKING_MODE);
            }
        });

        switchGeoFence.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                typesList.remove(GEO_FENCE_ENTER);
                typesList.remove(GEO_FENCE_EXIT);
            } else {
                if (!typesList.contains(GEO_FENCE_ENTER)) typesList.add(GEO_FENCE_ENTER);
                if (!typesList.contains(GEO_FENCE_EXIT)) typesList.add(GEO_FENCE_EXIT);
            }
        });

        switchDriversOrders.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

            }
        });

        switchBehaviorType.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                typesList.removeAll(behaviorTypeList);
            } else {
                if (!typesList.containsAll(behaviorTypeList)) typesList.addAll(behaviorTypeList);
            }
        });

        switchHitType.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                typesList.removeAll(hitTypeList);
            } else {
                if (!typesList.containsAll(hitTypeList)) typesList.addAll(hitTypeList);
            }
        });

//        ApiClient.createApiService().getNotificationInfo()
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(this::onNotificationInfo, new ServerErrorHandler(TAG));
    }

    private void onNotificationInfo(NotificationInfoResponse response) {
//        List<String> notificationType = response.getNotificationType();
//        Logger.t(TAG).d("onNotificationInfo: " + notificationType);
//        typesList.addAll(notificationType);
//
//        switchDrivingParking.setChecked(response.getDrivingOrParking());
//        switchGeoFence.setChecked(response.getGeoFenceType());
//        switchBehaviorType.setChecked(response.getBehaviorType());
//        switchHitType.setChecked(response.getHitType());
    }

    @SuppressLint("CheckResult")
    private void setSettings(String[] types) {
        Logger.t(TAG).d("setSettings: " + Arrays.toString(types));
        NotificationInfoBody body = new NotificationInfoBody();
        body.notificationType = types;

//        ApiClient.createApiService().setNotificationInfo(body)
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(this::onSetNotificationInfo, throwable -> {
//                    Logger.t(TAG).e("setNotificationInfo throwable: " + throwable.getMessage());
//                    Toast.makeText(AlertSettingsActivity.this, R.string.fleet_default_error, Toast.LENGTH_SHORT).show();
//                    toolbar.getMenu().findItem(R.id.save).setEnabled(true);
//                });
    }

    private void onSetNotificationInfo(BooleanResponse response) {
        boolean result = response.result;
        Logger.t(TAG).d("onSetNotificationInfo: " + result);
        if (result) {
            finish();
        } else {
            toolbar.getMenu().findItem(R.id.save).setEnabled(true);
        }
    }

    private void setToolbar() {
        if (toolbar == null) {
            return;
        }

        toolbar.setNavigationOnClickListener(v -> finish());
        toolbar.getMenu().clear();
        toolbar.inflateMenu(R.menu.username_save);
        toolbar.setOnMenuItemClickListener(item -> {
            if (item.getItemId() == R.id.save) {
                toolbar.getMenu().findItem(R.id.save).setEnabled(false);

                String[] types = typesList.toArray(new String[0]);
                setSettings(types);
            }
            return false;
        });
    }
}
