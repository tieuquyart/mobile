package com.mk.autosecure.ui.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.GridView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.request.MarkReadBody;
import com.mk.autosecure.ui.adapter.DriverFilterAdapter;
import com.mk.autosecure.ui.adapter.FleetAlertsAdapter;
import com.mk.autosecure.ui.adapter.TypeFilterAdapter;
import com.mk.autosecure.ui.view.DropDownMenu;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;

public class AlertsActivity extends RxAppCompatActivity {

    private final static String TAG = AlertsActivity.class.getSimpleName();

    @BindView(R.id.refresh_alerts_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.dropDownMenu)
    DropDownMenu dropDownMenu;

    RecyclerView mRecyclerView;

    private List<View> mPopupViews = new ArrayList<>();

    private FleetAlertsAdapter mAlertsAdapter; //notification adapter

    private TypeFilterAdapter typeAdapter; //type filter adapter

    private DriverFilterAdapter driverAdapter; //driver filter adapter

    private List<NotificationBean> mNotificationList = new ArrayList<>(); //original notification list data

    private List<String> nameList = new ArrayList<>(); //driver name filter list

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, AlertsActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_alerts);
        ButterKnife.bind(this);

        initView();
        initEvent();
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        HornApplication.getComponent().fleetInfo().driverObservable()
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(this::onDriverList, new ServerErrorHandler(TAG));
    }

    private void onDriverList(Optional<List<DriverInfoBean>> listOptional) {
        List<DriverInfoBean> driverInfoBeans = listOptional.getIncludeNull();
        if (driverInfoBeans != null && driverInfoBeans.size() != 0) {
            Logger.t(TAG).d("onDriverList: " + driverInfoBeans.size());
            initDriverList(driverInfoBeans);
        }
    }

    @SuppressLint("CheckResult")
    private void initView() {
        setToolbar();

        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            requestNotification();
        });

        // init type view
        View typeView = LayoutInflater.from(this).inflate(R.layout.layout_type_filter, null);
        GridView gridView = typeView.findViewById(R.id.gridView);
        TextView clearTypeView = typeView.findViewById(R.id.clear_type);
        TextView doneTypeView = typeView.findViewById(R.id.done_type);

        String[] types = {"Driving/Parking", "Geo-fencing", "Behavior Type Events", "Hit Type Events"};
        typeAdapter = new TypeFilterAdapter(this, Arrays.asList(types));
        gridView.setAdapter(typeAdapter);
        gridView.setOnItemClickListener((parent, view, position, id) -> {
            typeAdapter.setCheckItem(position);
            int statusCount = typeAdapter.getStatusCount();
            doneTypeView.setText(statusCount == 0 ? getString(R.string.done)
                    : String.format(Locale.getDefault(), "Done (%d)", statusCount));
        });

        clearTypeView.setOnClickListener(v -> {
            filterNotificationByName(driverAdapter.getNameList());
            typeAdapter.clearStatus();
            doneTypeView.setText(R.string.done);
            dropDownMenu.showTabCount(0);
            dropDownMenu.closeMenu();
        });

        doneTypeView.setOnClickListener(v -> {
            filterNotification(typeAdapter.getStatusList(), driverAdapter.getNameList());
            dropDownMenu.showTabCount(typeAdapter.getStatusCount());
            dropDownMenu.closeMenu();
        });

        // init driver view
        View driverView = LayoutInflater.from(this).inflate(R.layout.layout_driver_filter, null);
        ListView listView = driverView.findViewById(R.id.listView);
        TextView clearDriverView = driverView.findViewById(R.id.clear_driver);
        TextView doneDriverView = driverView.findViewById(R.id.done_driver);

        driverAdapter = new DriverFilterAdapter(this, nameList);
        listView.setAdapter(driverAdapter);
        listView.setOnItemClickListener((parent, view, position, id) -> {
            driverAdapter.setCheckItem(position);
            int driverCount = driverAdapter.getNameList().size();
            doneDriverView.setText(driverCount == 0 ? getString(R.string.done)
                    : String.format(Locale.getDefault(), "Done (%d)", driverCount));
        });
        listView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                int topRowVerticalPosition =
                        view.getChildCount() == 0 ? 0 : view.getChildAt(0).getTop();
                refreshLayout.setEnabled(topRowVerticalPosition >= 0);
            }
        });

//        ApiClient.createApiService().getDriverList()
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(response -> {
//                    List<DriverInfoBean> driverInfos = response.getDriverInfos();
//                    initDriverList(driverInfos);
//                    HornApplication.getComponent().fleetInfo().refreshDrivers(driverInfos);
//                }, throwable -> {
//                    Logger.t(TAG).e("getDriverList throwable: " + throwable.getMessage());
//                    List<DriverInfoBean> drivers = HornApplication.getComponent().fleetInfo().getDrivers();
//                    initDriverList(drivers);
//                });

        clearDriverView.setOnClickListener(v -> {
            filterNotificationByStatus(typeAdapter.getStatusList());
            driverAdapter.clearDriver();
            doneDriverView.setText(R.string.done);
            dropDownMenu.showTabCount(0);
            dropDownMenu.closeMenu();
        });

        doneDriverView.setOnClickListener(v -> {
            filterNotification(typeAdapter.getStatusList(), driverAdapter.getNameList());
            dropDownMenu.showTabCount(driverAdapter.getNameList().size());
            dropDownMenu.closeMenu();
        });

        mPopupViews.add(typeView);
        mPopupViews.add(driverView);

        mRecyclerView = new RecyclerView(this);
        mRecyclerView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        mRecyclerView.setPadding(0, ViewUtils.dp2px(8), 0, ViewUtils.dp2px(8));

        String[] headers = {getString(R.string.video_type), getString(R.string.driver)};
        dropDownMenu.setDropDownMenu(Arrays.asList(headers), mPopupViews, mRecyclerView);

        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mRecyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, ViewUtils.dp2px(14));
            }
        });
        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                int topRowVerticalPosition =
                        recyclerView.getChildCount() == 0 ? 0 : recyclerView.getChildAt(0).getTop();
                refreshLayout.setEnabled(topRowVerticalPosition >= 0);
            }
        });

        mAlertsAdapter = new FleetAlertsAdapter(this);
        mRecyclerView.setAdapter(mAlertsAdapter);

        /*mAlertsAdapter.setTimelineOperationListener((driverID, clipID, driverName, plateNumber) -> {
            if (!TextUtils.isEmpty(driverID) && !TextUtils.isEmpty(clipID)) {
                ApiClient.createApiService().getEventDetail(driverID, clipID)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(detailBean -> ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                                .withString(VIDEO_URL, detailBean.getUrl())
                                .withString(EVENT_TYPE, detailBean.getEventType())
                                .withLong(START_TIME, detailBean.getStartTime())
                                .withInt(DURATION, detailBean.getDuration())
                                .withString(IntentKey.FLEET_DRIVER_NAME, driverName)
                                .withString(IntentKey.FLEET_PLATE_NUMBER, plateNumber)
                                .withString(IntentKey.FLEET_CAMERA_ROTATE, detailBean.getRotate())
                                .withString(IntentKey.SERIAL_NUMBER, detailBean.getCameraSN())
                                .withBoolean(LOCAL_VIDEO, false)
                                .navigation(), throwable -> {
                            Logger.t(TAG).e("getEventDetail throwable: " + throwable.getMessage());
                            Toast.makeText(AlertsActivity.this, "event video error", Toast.LENGTH_SHORT).show();
                        });
            } else {
                Toast.makeText(AlertsActivity.this, "event video error", Toast.LENGTH_SHORT).show();
            }
        });*/

        requestNotification();
    }

    @SuppressLint("CheckResult")
    private void requestNotification() {
        refreshLayout.setRefreshing(true);
        mNotificationList.clear();

        long toTime = System.currentTimeMillis();
        long fromTime = DashboardUtil.getZeroFromTime(3, toTime);

        ApiClient.createApiService().getNotificationList(fromTime, toTime)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(response -> {
//                    mNotificationList.addAll(response.getNotifications());
                    filterNotification(typeAdapter.getStatusList(), driverAdapter.getNameList());
                    markReadNotification(mNotificationList);
                }, throwable -> {
                    Logger.t(TAG).e("getNotificationList throwable: " + throwable.getMessage());
                    mAlertsAdapter.setNotificationList(new ArrayList<>());
                    NetworkErrorHelper.handleCommonError(this, throwable);
                });
    }

    @SuppressLint("CheckResult")
    private void markReadNotification(List<NotificationBean> notificationList) {
        List<String> unreadIDList = new ArrayList<>();
        for (int i = 0; i < notificationList.size(); i++) {
            NotificationBean bean = notificationList.get(i);
//            if (!bean.isIsRead()) {
//                unreadIDList.add(bean.getNotificationID());
//            }
        }

        Logger.t(TAG).d("markReadNotification unreadIDList size: " + unreadIDList.size());
        if (unreadIDList.size() != 0) {
            String[] strings = unreadIDList.toArray(new String[0]);
            MarkReadBody body = new MarkReadBody(strings);

//            ApiClient.createApiService().markReadNotification(body)
//                    .subscribeOn(Schedulers.io())
//                    .compose(bindToLifecycle())
//                    .subscribe(response -> {
//                        boolean result = response.result;
//                        Logger.t(TAG).d("markReadNotification result: " + result);
//                    }, throwable -> Logger.t(TAG).d("markReadNotification throwable: " + throwable.getMessage()));
        }
    }

    private void initDriverList(List<DriverInfoBean> driverInfos) {
        nameList.clear();
        for (DriverInfoBean infoBean : driverInfos) {
            String name = infoBean.getName();
            nameList.add(name);
        }
        driverAdapter.setNewData(nameList);
    }

    private void filterNotification(List<Boolean> typeList, List<String> driverList) {
        Logger.t(TAG).d("filterNotification: " + typeList + " " + driverList);
        if (typeList == null || typeList.size() == 0 || !typeList.contains(true)) {
            filterNotificationByName(driverList);
            return;
        }

        if (driverList == null || driverList.size() == 0) {
            filterNotificationByStatus(typeList);
            return;
        }

        List<NotificationBean> tempList = new ArrayList<>();

        boolean status = typeList.get(0);
        boolean geo = typeList.get(1);
        boolean behavior = typeList.get(2);
        boolean hit = typeList.get(3);

        for (NotificationBean bean : mNotificationList) {
//            String timelineType = bean.getNotificationType();
//            String driverName = bean.getDriverName();
//            NotificationBean.EventBean eventBean = bean.getEvent();

//            if (status && "IgnitionStatus".equals(timelineType)) {
//                if (driverList.contains(driverName)) {
//                    tempList.add(bean);
//                }
//            } else if (eventBean != null) {
//                int typeForInteger = VideoEventType.getEventTypeForInteger(eventBean.getEventType());
//
//                if (behavior && typeForInteger > TYPE_HIGHLIGHT) {
//                    if (driverList.contains(driverName)) {
//                        tempList.add(bean);
//                    }
//                } else if (hit &&
//                        (typeForInteger == TYPE_PARKING_HIT || typeForInteger == TYPE_PARKING_HEAVY_HIT
//                                || typeForInteger == TYPE_DRIVING_HIT || typeForInteger == TYPE_DRIVING_HEAVY_HIT)) {
//                    if (driverList.contains(driverName)) {
//                        tempList.add(bean);
//                    }
//                }
//            } else if (geo && "GeoFence".equals(timelineType)) {
//                if (driverList.contains(driverName)) {
//                    tempList.add(bean);
//                }
//            }
        }

        mAlertsAdapter.setNotificationList(tempList);
    }

    private void filterNotificationByStatus(List<Boolean> statusList) {
        if (statusList == null || statusList.size() == 0 || !statusList.contains(true)) {
            mAlertsAdapter.setNotificationList(mNotificationList);
            return;
        }

        boolean status = statusList.get(0);
        boolean geo = statusList.get(1);
        boolean behavior = statusList.get(2);
        boolean hit = statusList.get(3);

        List<NotificationBean> tempList = new ArrayList<>();
        for (NotificationBean bean : mNotificationList) {
//            String timelineType = bean.getNotificationType();
//            NotificationBean.EventBean eventBean = bean.getEvent();
//            if (status && "IgnitionStatus".equals(timelineType)) {
//                tempList.add(bean);
//            } else if (eventBean != null) {
//                int typeForInteger = VideoEventType.getEventTypeForInteger(eventBean.getEventType());
//                if (behavior && typeForInteger > TYPE_HIGHLIGHT) {
//                    tempList.add(bean);
//                } else if (hit &&
//                        (typeForInteger == TYPE_PARKING_HIT || typeForInteger == TYPE_PARKING_HEAVY_HIT
//                                || typeForInteger == TYPE_DRIVING_HIT || typeForInteger == TYPE_DRIVING_HEAVY_HIT)) {
//                    tempList.add(bean);
//                }
//            } else if (geo && "GeoFence".equals(timelineType)) {
//                tempList.add(bean);
//            }
        }
        mAlertsAdapter.setNotificationList(tempList);
    }

    private void filterNotificationByName(List<String> nameList) {
        if (nameList == null || nameList.size() == 0) {
            mAlertsAdapter.setNotificationList(mNotificationList);
            return;
        }

        List<NotificationBean> tempList = new ArrayList<>();
        for (NotificationBean bean : mNotificationList) {
//            String driverName = bean.getDriverName();
//            if (nameList.contains(driverName)) {
//                tempList.add(bean);
//            }
        }
        mAlertsAdapter.setNotificationList(tempList);
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

}
