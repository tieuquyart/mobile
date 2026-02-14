package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CircleOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolygonOptions;
import com.mk.autosecure.ui.DialogHelper;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.AddressBean;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

import static com.mk.autosecure.ui.fragment.FenceDrawFragment.COLOR_FILL_FENCE;

public class FenceDetailActivity extends RxFragmentActivity implements OnMapReadyCallback {

    private final static String TAG = FenceDetailActivity.class.getSimpleName();

    public final static String FENCE_LIST_BEAN = "fence_list_bean";
    public final static String FENCE_RULE_BEAN = "fence_rule_bean";

//    public static void launch(Context context, FenceListBean listBean) {
//        Intent intent = new Intent(context, FenceDetailActivity.class);
//        intent.putExtra(FENCE_LIST_BEAN, listBean);
//        context.startActivity(intent);
//    }

    public static void launch(Context context, FenceRuleBean ruleBean) {
        Intent intent = new Intent(context, FenceDetailActivity.class);
        intent.putExtra(FENCE_RULE_BEAN, ruleBean);
        context.startActivity(intent);
    }

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_create_time)
    TextView tvCreateTime;

    @BindView(R.id.tv_location)
    TextView tvLocation;

    @BindView(R.id.tv_trigger_mode)
    TextView tvTriggerMode;

    @OnClick(R.id.btn_triggering_vehicles)
    public void intentTrig() {
//        Logger.t(TAG).d("intentTrig: " + fenceScope);
//        TrigVehicleActivity.launch(this, fenceScope, null);
//        if (listBean != null) {
//            TrigVehicleActivity.launch(this, listBean);
//        } else
        if (ruleBean != null) {
            TrigVehicleActivity.launch(this, ruleBean);
        }
    }

    @OnClick(R.id.btn_delete)
    public void delete() {
        Logger.t(TAG).d("delete: " + fenceRuleID + " " + fenceID);
        if (TextUtils.isEmpty(fenceRuleID)) {
            return;
        }

        DialogHelper.showDeleteGeoFenceDialog(this, () ->
                ApiClient.createApiService().deleteFenceRule(fenceRuleID)
                        .subscribeOn(Schedulers.newThread())
                        .observeOn(AndroidSchedulers.mainThread())
                        .compose(bindToLifecycle())
                        .subscribe(new BaseObserver<BooleanResponse>() {
                            @Override
                            protected void onHandleSuccess(BooleanResponse data) {
                                Logger.t(TAG).d("deleteFenceRule: " + data.result);
                                if (data.result) {
                                    //不关心delete fence的结果
                                    ApiClient.createApiService().deleteFence(fenceID)
                                            .subscribeOn(Schedulers.newThread())
                                            .subscribe();
                                }
                                finish();
                            }
                        }));
    }

    private GoogleMap mGoogleMap;

    private String fenceScope;
    private String fenceID;
    private String fenceRuleID;

    //    private FenceListBean listBean;
    private FenceRuleBean ruleBean;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fence_detail);
        ButterKnife.bind(this);

        setupToolbar();
        ininView();
    }

    @SuppressLint("CheckResult")
    private void ininView() {
        SupportMapFragment fragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.googleMap);
        if (fragment != null) {
            fragment.getMapAsync(this);
        }

//        listBean = (FenceListBean) getIntent().getSerializableExtra(FENCE_LIST_BEAN);
        ruleBean = (FenceRuleBean) getIntent().getSerializableExtra(FENCE_RULE_BEAN);
        Logger.t(TAG).d("FenceRuleBean: " + ruleBean);

//        if (listBean != null) {
//            fenceName = listBean.getName();
//            fenceID = listBean.getFenceID();
//            createTime = getFormattedDate(listBean.getCreateTime());
//            if (listBean.getAddress() != null) location = listBean.getAddress().getAddress();
//        } else
        if (ruleBean != null) {
            fenceID = ruleBean.getFenceID();
            fenceRuleID = ruleBean.getFenceRuleID();
            fenceScope = ruleBean.getScope();
            setTextView(ruleBean.getName(), getFormattedDate(ruleBean.getCreateTime()), ruleBean.getType());
        }


        if (!TextUtils.isEmpty(fenceID)) {
            ApiClient.createApiService().getFenceDetail(fenceID)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::onFenceDetail,
                            throwable -> Logger.t(TAG).e("getFenceDetail throwable: " + throwable.getMessage()));
        }
    }

    private void setTextView(String fenceName, String createTime, List<String> triggerMode) {
        tvToolbarTitle.setText(fenceName);

        tvCreateTime.setText(String.format("Create time: %s", createTime));
        if (triggerMode != null) {
            if (triggerMode.size() == 2) {
                tvTriggerMode.setText(String.format("Trigger Mode: %s", "When vehicles exit and enter"));
            } else if (triggerMode.contains("enter")) {
                tvTriggerMode.setText(String.format("Trigger Mode: %s", "When vehicles enter"));
            } else if (triggerMode.contains("exit")) {
                tvTriggerMode.setText(String.format("Trigger Mode: %s", "When vehicles exit"));
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        refreshRuleDetail();
    }

    @SuppressLint("CheckResult")
    private void refreshRuleDetail() {
        if (TextUtils.isEmpty(fenceRuleID)) {
            Logger.t(TAG).d("refreshRuleDetail fenceRuleID is null !!!");
            return;
        }

        ApiClient.createApiService().getFenceRuleDetail(fenceRuleID)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(this::onFenceRuleDetail,
                        throwable -> Logger.t(TAG).e("getFenceRuleDetail throwable: " + throwable.getMessage()));
    }

    private void onFenceRuleDetail(FenceRuleBean ruleBean) {
        Logger.t(TAG).d("onFenceRuleDetail: " + ruleBean);
        if (ruleBean != null) {
            this.ruleBean = ruleBean;
            fenceScope = ruleBean.getScope();
            setTextView(ruleBean.getName(), getFormattedDate(ruleBean.getCreateTime()), ruleBean.getType());
        }
    }

    private String getFormattedDate(long utcTimeMillis) {
//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        SimpleDateFormat format = new SimpleDateFormat("HH:mm MMM d", Locale.getDefault());
        format.setTimeZone(timeZone);

        long currentTime = System.currentTimeMillis();
        Calendar calendar = Calendar.getInstance();

        calendar.setTimeZone(timeZone);
        calendar.setTimeInMillis(utcTimeMillis);
        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int clipDateYear = calendar.get(Calendar.YEAR);

        calendar.setTimeZone(TimeZone.getTimeZone("UTC"));
        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        String dateString = format.format(utcTimeMillis);

        if (clipDateYear == currentDateYear) {
            if ((currentDateDay - clipDateDay) < 1) {
                format = new SimpleDateFormat("HH:mm", Locale.getDefault());
                format.setTimeZone(timeZone);
                dateString = format.format(utcTimeMillis);
            }
        } else {
            format = new SimpleDateFormat("HH:mm MMM d yyyy", Locale.getDefault());
            format.setTimeZone(timeZone);
            dateString = format.format(utcTimeMillis);
        }
        return dateString;
    }

    private void onFenceDetail(FenceDetailBean response) {
        Logger.t(TAG).d("onFenceDetail: " + response);

        AddressBean address = response.getAddress();
        tvLocation.setText(String.format("Location: %s", address == null ? "" : address.getAddress()));

        List<List<Double>> polygon = response.getPolygon();
        if (polygon != null) {
            if (polygon.size() == 0) {
                Logger.t(TAG).e("polygon size is 0 !!!");
                return;
            }

            List<LatLng> latLngs = new ArrayList<>();
            for (int i = 0; i < polygon.size(); i++) {
                List<Double> doubleList = polygon.get(i);
                latLngs.add(MapTransformUtil.gps84_To_Gcj02(new LatLng(doubleList.get(0), doubleList.get(1))));
            }
            latLngs.add(latLngs.get(0));

//            latLngs.add(new LatLng(28.06025, -82.41030));  // Should match last point
//            latLngs.add(new LatLng(28.06129, -82.40945));
//            latLngs.add(new LatLng(28.06206, -82.40917));
//            latLngs.add(new LatLng(28.06125, -82.40850));
//            latLngs.add(new LatLng(28.06035, -82.40834));
//            latLngs.add(new LatLng(28.06038, -82.40924));
//            latLngs.add(new LatLng(28.06025, -82.41030));  // Should match first point

            moveMapCenter(latLngs);

            mGoogleMap.addPolygon(new PolygonOptions()
                    .addAll(latLngs)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        } else {
            List<Double> center = response.getCenter();
            int radius = response.getRadius();

            LatLng latLng = MapTransformUtil.gps84_To_Gcj02(new LatLng(center.get(0), center.get(1)));
//            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 7));
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng,
                    MapTransformUtil.getZoomLevel(mGoogleMap, radius)));

            mGoogleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .anchor(0.5f, 0.5f)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_circular_point)));

            mGoogleMap.addCircle(new CircleOptions()
                    .center(latLng)
                    .radius(radius)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        }
    }

    private void moveMapCenter(List<LatLng> latLngs) {
//        Logger.t(TAG).d("moveMapCenter: " + latLngs.size());
        if (latLngs.size() == 0) {
            return;
        }

        LatLngBounds.Builder builder = new LatLngBounds.Builder();
        for (LatLng latLng : latLngs) {
            builder.include(latLng);
        }
        int width = getResources().getDisplayMetrics().widthPixels;
        int height = getResources().getDisplayMetrics().heightPixels - ViewUtils.dp2px(240);
        mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), width, height, ViewUtils.dp2px(80)));
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
        toolbar.inflateMenu(R.menu.menu_personnel_edit);
        toolbar.setOnMenuItemClickListener(item -> {
            if (item.getItemId() == R.id.resetPass) {
                Logger.t(TAG).d("onMenuItemClick");
                AddFenceActivity.launch(FenceDetailActivity.this, ruleBean);
            }
            return false;
        });
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Logger.t(TAG).d("onMapReady: " + googleMap);
        mGoogleMap = googleMap;
    }
}
