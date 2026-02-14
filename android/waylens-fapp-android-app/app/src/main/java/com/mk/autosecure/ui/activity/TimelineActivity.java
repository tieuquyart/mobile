package com.mk.autosecure.ui.activity;

import static com.mkgroup.camera.constant.VideoEventType.TYPE_DRIVING_HEAVY_HIT;
import static com.mkgroup.camera.constant.VideoEventType.TYPE_DRIVING_HIT;
import static com.mkgroup.camera.constant.VideoEventType.TYPE_HIGHLIGHT;
import static com.mkgroup.camera.constant.VideoEventType.TYPE_PARKING_HEAVY_HIT;
import static com.mkgroup.camera.constant.VideoEventType.TYPE_PARKING_HIT;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CalendarView;
import android.widget.DatePicker;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.bean.FleetViewBean;
import com.mk.autosecure.rest_fleet.bean.FleetViewRecord;
import com.mk.autosecure.rest_fleet.bean.SignalInfo;
import com.mk.autosecure.ui.adapter.TypeFilterAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.CameraEventBean;
import com.mk.autosecure.rest_fleet.bean.TimelineBean;
import com.mk.autosecure.rest_fleet.bean.TripBean;
import com.mk.autosecure.ui.adapter.SectionAdapter;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;

@SuppressLint({"SimpleDateFormat", "CheckResult"})
@Route(path = "/ui/activity/TimelineActivity")
public class TimelineActivity extends RxAppCompatActivity implements DatePickerDialog.OnDateSetListener {

    private final static String TAG = TimelineActivity.class.getSimpleName();

    private long fromUtcDateTime, utcDateTime, fromUtcDateTimeRp, toUtcDateTimeRp, minUtcDateTime, maxUtcDateTime;

//    public static void launch(Activity activity, FleetViewRecord fleetViewRecord){
//        Intent intent = new Intent(activity,TimelineActivity.class);
//        intent.putExtra(IntentKey.FLEET_RECORD,fleetViewRecord);
//        activity.startActivity(intent);
//    }

    private long mLastClickTime = 0;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolBarTitle;

    @BindView(R.id.refresh_timeline_layout)
    SwipeRefreshLayout refreshLayout;


    @BindView(R.id.tv_date_picker)
    TextView tvDatePicker;

    @BindView(R.id.driverName)
    TextView tvDriverName;

    @BindView(R.id.tvPlateNo)
    TextView tvPlateNo;

    @BindView(R.id.tv_hours)
    TextView tvHours;

    @BindView(R.id.tv_events)
    TextView tvEvents;

    @BindView(R.id.tv_miles)
    TextView tvMiles;

    @OnClick(R.id.llContactCall)
    public void makeCallPhoneNo() {

        String phoneNumber = fleetViewRecord.phoneNo;
        Logger.t(TAG).d("phoneNumber: " + phoneNumber);

        if (TextUtils.isEmpty(phoneNumber)) {
            Toast.makeText(this, "Không tìm thấy số điện thoại", Toast.LENGTH_SHORT).show();
            return;
        }

        Observable
                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                    View view = LayoutInflater.from(this).inflate(R.layout.pop_call_phone, null);
                    PopupWindow popupWindow = new PopupWindow(view,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            false);
                    popupWindow.setOutsideTouchable(false);

                    TextView textView = view.findViewById(R.id.tv_phone_number);
                    textView.setText(phoneNumber);

                    view.findViewById(R.id.btn_call_phone).setOnClickListener(v -> {
                        popupWindow.dismiss();

                        Intent intent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + phoneNumber));
                        startActivity(intent);
                    });

                    view.findViewById(R.id.btn_cancel_call).setOnClickListener(v -> popupWindow.dismiss());

                    emitter.onNext(Optional.ofNullable(popupWindow));
                })
                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(windowOptional -> windowOptional.get().showAsDropDown(toolbar));

    }

    @OnClick(R.id.llGoLive)
    public void gotoLive() {
        if (currentUser.getUserLogin() != null && currentUser.getUserLogin().getSubscribed() != null && (int)currentUser.getUserLogin().getSubscribed() == 0) {
            Toast.makeText(this, getString(R.string.warning_upgrade_vip), Toast.LENGTH_SHORT).show();
            return;
        }
        if (System.currentTimeMillis() - mLastClickTime > 2000) {
            mLastClickTime = System.currentTimeMillis();

            FleetCameraBean fleetCamera = currentUser.getFleetCamera(cameraSn);
            Logger.t(TAG).d("fleetCamera: " + fleetCamera);
            SignalInfo signalInfo = fleetViewRecord.signalInfo;
            double rsrp = 0.0;
            if (signalInfo != null) {
                rsrp = signalInfo.rsrp;
            }

            if (fleetCamera != null) {
                ARouter.getInstance().build("/ui/activity/FleetLiveActivity")
                        .withString(IntentKey.SERIAL_NUMBER, fleetViewRecord.cameraSn)
                        .withString(IntentKey.FLEET_DRIVER_NAME, fleetViewRecord.driverName)
                        .withString(IntentKey.FLEET_PLATE_NUMBER, fleetViewRecord.plateNo)
                        .withString(IntentKey.FLEET_CAMERA_STATUS, fleetViewRecord.mode)
                        .withBoolean(IntentKey.FLEET_ONLINE, fleetViewRecord.isOnline)
                        .withDouble(IntentKey.FLEET_RSRP, rsrp)
                        .withSerializable(IntentKey.FLEET_RECORD, fleetViewRecord)
                        .withString(IntentKey.FLEET_CAMERA_ROTATE, fleetCamera.getRotate())
                        .withBoolean(IntentKey.FLEET_NEED_DEWARP, fleetCamera.getSn().startsWith("2"))
                        .navigation();
            }
        }
    }


    private TimeZone mTimeZone = TimeZone.getDefault();

    private String phoneNo;

    private double miles;

    private double hours;

    private int events;

    private String driverName;

    private String driverId;

    private FleetViewRecord fleetViewRecord;

    @OnClick(R.id.ll_date_picker)
    public void datePicker() {
        Calendar date = DashboardUtil.getCalendar(mTimeZone, utcDateTime);

        DatePickerDialog dialog = new DatePickerDialog(this, TimelineActivity.this, date.get(Calendar.YEAR), date.get(Calendar.MONTH), date.get(Calendar.DAY_OF_MONTH));

        dialog.show();
    }

    @Override
    public void onDateSet(DatePicker datePicker, int year, int month, int day) {
        searchDate = String.format("%s-%s-%s", year, (month + 1) < 10 ? ("0" + (month + 1)) : month + 1, day < 10 ? "0" + day : day);
        tvDatePicker.setText(searchDate);
        requestTrip(cameraSn, searchDate, currentUser.getAccessToken());
    }

    @OnClick(R.id.iv_back_detail)
    public void back() {
        finish();
    }

    @BindView(R.id.mRecyclerView)
    RecyclerView mRecyclerView;

    CalendarView calendarView;

    private List<View> mPopupViews = new ArrayList<>();

    private SectionAdapter mSectionAdapter;

    private List<TimelineBean> mTimelineList = new ArrayList<>();

    private List<TripBean> mTripList = new ArrayList<>();

    private TypeFilterAdapter typeAdapter;

    private List<Long> timeMillsRangeList = new ArrayList<>();

    private java.util.Calendar calendar = java.util.Calendar.getInstance();
    private String searchDate = "";
    private String cameraSn = "";

    private CurrentUser currentUser;
    private SimpleDateFormat dateFormat;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_time_line);
        ButterKnife.bind(this);

        cameraSn = getIntent().getStringExtra(IntentKey.FLEET_CAMERA_SN);
        String fromTime = getIntent().getStringExtra(IntentKey.FLEET_FROM_TIME);

        utcDateTime = System.currentTimeMillis();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        dateFormat.setTimeZone(mTimeZone);

        if (fromTime == "" || fromTime == null) {
            searchDate = dateFormat.format(utcDateTime);
        } else {
            searchDate = fromTime;
        }
        tvDatePicker.setText(searchDate);
        initView();
    }

    private void initView() {
        driverName = getIntent().getStringExtra(IntentKey.FLEET_DRIVER_NAME);
        hours = getIntent().getDoubleExtra(IntentKey.FLEET_TIME_DRIVING, 0.0);
        miles = getIntent().getDoubleExtra(IntentKey.FLEET_MILES, 0.0);
        events = getIntent().getIntExtra(IntentKey.FLEET_EVENT_NUM, 0);
        driverId = getIntent().getStringExtra(IntentKey.FLEET_DRIVER_ID);
        tvToolBarTitle.setText(R.string.detail_title);

        fleetViewRecord = (FleetViewRecord) getIntent().getSerializableExtra(IntentKey.FLEET_RECORD);

        tvDriverName.setText(!StringUtils.isEmpty(fleetViewRecord.driverName) ? fleetViewRecord.driverName : "Không có tài xế");

        tvPlateNo.setText(fleetViewRecord.plateNo);

        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        DecimalFormat decimalFormat2 = new DecimalFormat("0.0");
        tvMiles.setText(fleetViewRecord.miles > 0 ? decimalFormat.format((float) fleetViewRecord.miles / 1000) + " km" : decimalFormat2.format((float) fleetViewRecord.miles) + " km"); //1609.3f
        tvHours.setText(fleetViewRecord.hours > 0 ? decimalFormat.format((float) fleetViewRecord.hours) + " h" : decimalFormat2.format((float) fleetViewRecord.hours) + " h");
        tvEvents.setText(String.valueOf(fleetViewRecord.events));

        currentUser = HornApplication.getComponent().currentUser();

        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            searchDate = new SimpleDateFormat("yyyy-MM-dd").format(calendar.getTime());
            tvDatePicker.setText(searchDate);
            calendarView.setDate(calendar.getTimeInMillis());

            requestTrip(cameraSn, searchDate, currentUser.getAccessToken());
        });

        //init time filter
        View timeView = LayoutInflater.from(this).inflate(R.layout.layout_time_filter, null);
        calendarView = timeView.findViewById(R.id.calendarView);

        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mRecyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, ViewUtils.dp2px(16));
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

        mSectionAdapter = new SectionAdapter(this);
        mRecyclerView.setAdapter(mSectionAdapter);

        mSectionAdapter.setVehicleInfo(fleetViewRecord.driverName, fleetViewRecord.plateNo, fleetViewRecord.brand, fleetViewRecord.type);

        requestTrip(cameraSn, searchDate, currentUser.getAccessToken());
    }

    /**
     * lấy thông tin Trip theo cameraSn
     *
     * @param cameraSn   current cameraSn
     * @param searchDate thời gian tìm kiếm thông tin
     * @param token      token login của user
     */
    private void requestTrip(String cameraSn, String searchDate, String token) {
        refreshLayout.setRefreshing(true);
        mTripList.clear();

        ApiClient.createApiService().getTrips(cameraSn, searchDate, token)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(tripsResponse -> {
                    if (tripsResponse.isSuccess()) {
                        mTripList = tripsResponse.getTrips();
                        Logger.t(TAG).d("trips size: " + mTripList.size());
//                       for (TripBean tripBean : mTripList) {
//                           queryEvents(tripBean);
//                       }
                        mSectionAdapter.setTripList(mTripList);
                        //update text
                    } else {
                        NetworkErrorHelper.handleExpireToken(this, tripsResponse);
                        mSectionAdapter.setTripList(new ArrayList<>());
                    }
                }, throwable -> {
                    Logger.t(TAG).e("getTrips throwable: " + throwable.getMessage());
                    mSectionAdapter.setTripList(new ArrayList<>());
                    NetworkErrorHelper.handleCommonError(this, throwable);
                });
    }

    /**
     * lấy thông tin event của trip
     *
     * @param tripBean thông rin chuyến đi
     */
    @SuppressLint("CheckResult")
    private void queryEvents(TripBean tripBean) {

        ApiClient.createApiService().getAllEventsForOneTrip(tripBean.getTripId(), currentUser.getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(response -> {
                    List<CameraEventBean> events = response.getEvents();

                }, throwable -> {
                    Logger.t(TAG).e("getEventsList throwable: " + throwable.getMessage());
                    NetworkErrorHelper.handleCommonError(this, throwable);
                });
    }


    private void filterTimeline(List<Boolean> typeList, List<Long> rangeList) {
        Logger.t(TAG).d("filterTimeline: " + typeList + " " + rangeList);
        if (typeList == null || typeList.size() == 0 || !typeList.contains(true)) {
            filterTimelineByTime(rangeList);
            return;
        }

        if (rangeList == null || rangeList.size() == 0) {
            return;
        }

        long minTimeMills = rangeList.get(0);
        long maxTimeMills = rangeList.get(rangeList.size() - 1);

        List<TimelineBean> tempList = new ArrayList<>();

        boolean status = typeList.get(0);
        boolean geo = typeList.get(1);
        boolean behavior = typeList.get(2);
        boolean hit = typeList.get(3);

        for (TimelineBean bean : mTimelineList) {
            String timelineType = bean.getTimelineType();
            TimelineBean.EventBean eventBean = bean.getEvent();
            long timelineTime = bean.getTimelineTime();

            if (status && "IgnitionStatus".equals(timelineType)) {
                if (timelineTime >= minTimeMills && timelineTime <= maxTimeMills) {
                    tempList.add(bean);
                }
            } else if (eventBean != null) {
                int typeForInteger = VideoEventType.getEventTypeForInteger(eventBean.getEventType());

                if (behavior && typeForInteger > TYPE_HIGHLIGHT) {
                    if (timelineTime >= minTimeMills && timelineTime <= maxTimeMills) {
                        tempList.add(bean);
                    }
                } else if (hit &&
                        (typeForInteger == TYPE_PARKING_HIT || typeForInteger == TYPE_PARKING_HEAVY_HIT
                                || typeForInteger == TYPE_DRIVING_HIT || typeForInteger == TYPE_DRIVING_HEAVY_HIT)) {
                    if (timelineTime >= minTimeMills && timelineTime <= maxTimeMills) {
                        tempList.add(bean);
                    }
                }
            } else if (geo && "GeoFence".equals(timelineType)) {
                if (timelineTime >= minTimeMills && timelineTime <= maxTimeMills) {
                    tempList.add(bean);
                }
            }
        }

        mSectionAdapter.setTimelineList(tempList);
    }

    private void filterTimelineByTime(List<Long> rangeList) {
        if (rangeList == null || rangeList.size() == 0) {
            mSectionAdapter.setTimelineList(mTimelineList);
            return;
        }

        long minTimeMills = rangeList.get(0);
        long maxTimeMills = rangeList.get(rangeList.size() - 1);

        List<TimelineBean> tempList = new ArrayList<>();
        for (TimelineBean bean : mTimelineList) {
            long timelineTime = bean.getTimelineTime();
            if (timelineTime >= minTimeMills && timelineTime <= maxTimeMills) {
                tempList.add(bean);
            }
        }
        mSectionAdapter.setTimelineList(tempList);
    }

    public interface TimelineOperationListener {
        void onClickItem(int id, CameraEventBean bean);
    }
}
