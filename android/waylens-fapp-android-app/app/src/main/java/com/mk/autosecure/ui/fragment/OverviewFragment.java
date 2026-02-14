package com.mk.autosecure.ui.fragment;

import static com.google.android.gms.maps.model.JointType.ROUND;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.alibaba.android.arouter.launcher.ARouter;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CustomCap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MapStyleOptions;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.android.gms.maps.model.RoundCap;
import com.google.maps.android.SphericalUtil;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterItem;
import com.google.maps.android.clustering.ClusterManager;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.ImageBitmapUtils;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClusterMarker;
import com.mk.autosecure.model.ClusterMarkerRender;
import com.mk.autosecure.model.TrackArrow;
import com.mk.autosecure.model.TrackArrowRender;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.SnapToRoadAsyncTask;
import com.mk.autosecure.rest_fleet.bean.CameraEventBean;
import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.rest_fleet.bean.EventDetailBean;
import com.mk.autosecure.rest_fleet.bean.FleetViewBean;
import com.mk.autosecure.rest_fleet.bean.FleetViewRecord;
import com.mk.autosecure.rest_fleet.bean.GpsData;
import com.mk.autosecure.rest_fleet.bean.SignalInfo;
import com.mk.autosecure.rest_fleet.bean.TrackBean;
import com.mk.autosecure.rest_fleet.bean.TripBean;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.bean.VideoUrlBean;
import com.mk.autosecure.rest_fleet.request.BindPushBody;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.MarkerAnimation;
import com.mk.autosecure.ui.activity.FleetVideoActivity;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.ProfileActivity;
import com.mk.autosecure.ui.activity.settings.AccountSettingActivity;
import com.mk.autosecure.ui.activity.settings.ChangePwdActivity;
import com.mk.autosecure.ui.activity.settings.NotiManageActivity;
import com.mk.autosecure.ui.adapter.SummaryAdapter;
import com.mk.autosecure.ui.adapter.TripAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.slidinguppanel.SlidingUpPanelLayout;
import com.mk.autosecure.viewmodels.fragment.PreviewFragmentViewModel;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.preference.SharedPreferenceKey;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;

import java.net.URI;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@SuppressLint({"NonConstantResourceId", "CheckResult", "NewApi"})
@RequiresFragmentViewModel(PreviewFragmentViewModel.ViewModel.class)
public class OverviewFragment extends BaseLazyLoadFragment<PreviewFragmentViewModel.ViewModel>
        implements OnMapReadyCallback,
        ClusterManager.OnClusterClickListener<ClusterMarker>,
        ClusterManager.OnClusterItemClickListener<ClusterMarker> {

    private final static String TAG = OverviewFragment.class.getSimpleName();
    private int blockSizePath = 100;

    private String tripId = "";
    @BindView(R.id.progress_bar)
    ProgressBar progressBar;

    @BindView(R.id.sliding_layout)
    SlidingUpPanelLayout slidingLayout;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.iv_back)
    public ImageView ivBack;

    @BindView(R.id.iv_alert)
    ImageView ivAlert;

    @BindView(R.id.tvUnreadCount)
    TextView tvUnreadCount;

    @BindView(R.id.iv_expand)
    ImageView ivExpand;

    @BindView(R.id.tv_total_num)
    TextView tvTotalNum;

    @BindView(R.id.tv_driving_num)
    TextView tvDrivingNum;

    @BindView(R.id.tv_parking_num)
    TextView tvParkingNum;

    @BindView(R.id.llExpand)
    RelativeLayout llExpand;

    @BindView(R.id.ll_filter)
    LinearLayout llFilter;

    @BindView(R.id.rg_filter_type)
    RadioGroup rgFilterType;

    @BindView(R.id.rb_status)
    RadioButton rbStatus;

    @BindView(R.id.rb_plate_number)
    RadioButton rbPlateNumber;

    @BindView(R.id.rb_mileage_driven)
    RadioButton rbMileageDriven;

    @BindView(R.id.rb_time_driven)
    RadioButton rbTimeDriven;

    @BindView(R.id.rb_event)
    RadioButton rbEvent;

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.tvSpeed)
    TextView tvSpeed;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.llSpeedReal)
    RelativeLayout llSpeedReal;

    @BindView(R.id.tv_miles)
    TextView tvMiles;

    @BindView(R.id.tv_hours)
    TextView tvHours;

    @BindView(R.id.tv_events)
    TextView tvEvents;

    @BindView(R.id.ll_go_detail)
    LinearLayout llGoDetail;

    @BindView(R.id.ll_go_live)
    LinearLayout llGoLive;

    @BindView(R.id.include_detail_live)
    LinearLayout includeDetailLive;

    @BindView(R.id.iv_event_type)
    ImageView ivEventType;

    @BindView(R.id.tv_event_type)
    TextView tvEventType;

    @BindView(R.id.tv_plate_time)
    TextView tvPlateTime;

    @BindView(R.id.tv_event_location)
    TextView tvEventLocation;

    @BindView(R.id.iv_event_play)
    ImageView ivEventPlay;

    @BindView(R.id.include_events)
    LinearLayout includeEvents;

    @BindView(R.id.recycler_view)
    RecyclerView recyclerView;

    @BindView(R.id.pullToRefresh)
    SwipeRefreshLayout pullToRefresh;

    @BindView(R.id.mRecyclerViewTrip)
    RecyclerView mRecyclerViewTrip;

    @BindView(R.id.share_trip)
    ImageView share_trip;

    @BindView(R.id.ll_drag)
    LinearLayout llDrag;

    @BindView(R.id.iv_camera_status)
    ImageView ivCameraStatus;

    @OnClick(R.id.share_trip)
    public void onShareTrip(){
        if (tripId.equals("") || TextUtils.isEmpty(tripId)){
            Toast.makeText(mActivity, "Không lấy được thông tin chuyến đi", Toast.LENGTH_SHORT).show();
            return;
        }
        String url = "http://fms.mkvision.com/#/trippl/" + tripId;
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(intent);
    }

    @OnClick(R.id.iv_back)
    public void back() {
        if (includeDetailLive.getVisibility() == View.VISIBLE) {
            refreshMap();
            ivBack.setVisibility(View.INVISIBLE);
            hideAnimation(includeDetailLive);
            slidingLayout.setPanelState(SlidingUpPanelLayout.PanelState.COLLAPSED);
            ivExpand.setImageResource(R.drawable.icon_expand_arrow);
            llFilter.setVisibility(View.GONE);
        } else {
            FleetViewRecord record = mSummaryMap.get(currentDriverID);
            if (record != null) {
                showDriverTrip(record.plateNo, record.miles,
                        record.hours, record.events, record.cameraSn,
                        record.driverName, "" + record.driverId, record.mode, record.isOnline, record);
            }
        }
    }

    @OnClick(R.id.iv_alert)
    public void toAlerts() {
//        AlertsActivity.launch(getActivity());
        Intent intent = new Intent(getActivity(), NotiManageActivity.class);
        getActivity().startActivity(intent);
    }

    @BindView(R.id.iv_account)
    ImageView ivAccount;

//    @OnClick(R.id.iv_account)
//    public void onClickAccountOption(){
//        PopupMenu popupMenu = new PopupMenu(getActivity(), rootView, Gravity.RIGHT);
//        popupMenu.inflate(R.menu.menu_account_options);
//
//        Menu menu = popupMenu.getMenu();
//        // com.android.internal.view.menu.MenuBuilder
//        Log.i(TAG, "Menu class: " + menu.getClass().getName());
//
//        // Register Menu Item Click event.
//        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
//            @Override
//            public boolean onMenuItemClick(MenuItem item) {
//                return false;
//            }
//        });
//
//        popupMenu.show();
//    }

    private GoogleMap mGoogleMap;

    private SummaryAdapter mSummaryAdapter;

    private final Map<String, FleetViewRecord> mSummaryMap = new HashMap<>();

    private final Map<String, CameraEventBean> mEventMap = new HashMap<>();

    private final Map<String, LatLng> mParkingMarkerMap = new HashMap<>();

    private final List<LatLng> mTrackLatlngList = new ArrayList<>();

    private String currentDriverID = "";

    private final List<FleetViewRecord> mFleetViewBeanRecordList = new ArrayList<>();

    private final List<TripBean> tripBeanList = new ArrayList<>();

    private ClusterManager<TrackArrow> mClusterManager;

    private ClusterManager<ClusterMarker> mMarkerManager;

    private boolean isForeground = false;

    public boolean mShowMessage = false;

    public FleetViewBean fleetViewBean;

    public CameraEventBean cameraEventBean;

    private View rootView;

    private CurrentUser currentUser;

    private UserLogin userLogin;

    private boolean isLoading;

    private double currentIndex, totalPage;

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_overview;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);
        this.rootView = rootView;
        currentUser = HornApplication.getComponent().currentUser();
        queryUnread();
        initView();
        initEvent();
    }

    private Activity mActivity;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
    }

    private PopupWindow popupWindow;

    private void setUpPopupWindow() {
        LayoutInflater inflater = (LayoutInflater)
                getActivity().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = inflater.inflate(R.layout.popup_menu_profile, null);
        TextView userName = view.findViewById(R.id.tv_user_name);
        TextView roleFleet = view.findViewById(R.id.tv_role_fleet);

        userName.setText(!StringUtils.isEmpty(userLogin.getRealName()) ? userLogin.getRealName() : "");
        roleFleet.setText(!StringUtils.isEmpty(userLogin.getRoleNames()[0]) ? userLogin.getRoleNames()[0] : "");

        LinearLayout accountInfo = view.findViewById(R.id.ll_go_account_info);
        LinearLayout changePwd = view.findViewById(R.id.ll_go_change_pwd);
        LinearLayout setting = view.findViewById(R.id.ll_go_setting);
        LinearLayout logout = view.findViewById(R.id.ll_go_logout);

        accountInfo.setOnClickListener(v -> setOnclickViewMenuProfile(v.getId()));
        changePwd.setOnClickListener(v -> setOnclickViewMenuProfile(v.getId()));
        setting.setOnClickListener(v -> setOnclickViewMenuProfile(v.getId()));
        logout.setOnClickListener(v -> setOnclickViewMenuProfile(v.getId()));

        popupWindow = new PopupWindow(view, ViewUtils.dp2px(200), RelativeLayout.LayoutParams.WRAP_CONTENT, true);
    }

    private void setOnclickViewMenuProfile(int id) {
        popupWindow.dismiss();
        switch (id) {
            case R.id.ll_go_account_info:
                if (HornApplication.getComponent().currentUser().exists()) {
                    ProfileActivity.launch(getActivity());
                } else {
                    LoginActivity.launch(getActivity());
                }
                break;
            case R.id.ll_go_change_pwd:
                Logger.t(TAG).d("onChangePwd");
                ChangePwdActivity.launch(getActivity());
                break;
            case R.id.ll_go_setting:
                AccountSettingActivity.launch(getActivity());
                break;
            case R.id.ll_go_logout:
                DialogHelper.showLogoutConfirmDialog(getActivity(),
                        () -> {

                            PreferenceUtils.putString("tokenFailure", SharedPreferenceKey.PUSH_DEVICE);
                            currentUser.logout();
                            LoginActivity.launchClearTask(getActivity());

                            /*BindPushBody body = new BindPushBody("android", "tokenFailure");
                            ApiClient.createApiService().bindPushDevice(body, HornApplication.getComponent().currentUser().getAccessToken())
                                    .subscribeOn(Schedulers.io())
                                    .compose(bindToLifecycle())
                                    .subscribe(boolResponse -> {
                                        Logger.t(TAG).d("bindPushToken res: " + boolResponse);
                                        if(boolResponse.isSuccess()){
//                                            Toast.makeText(getActivity(), "Hủy push token thành công", Toast.LENGTH_SHORT).show();
                                            PreferenceUtils.putString("tokenFailure", SharedPreferenceKey.PUSH_DEVICE);
                                            currentUser.logout();
                                            LoginActivity.launchClearTask(getActivity());
                                        }else{
                                            NetworkErrorHelper.handleExpireToken(getActivity(),boolResponse);
                                        }
                                        }, throwable ->{
//                                            Toast.makeText(getActivity(), "Hủy push token lỗi: " + throwable.getMessage(), Toast.LENGTH_SHORT).show();
                                        currentUser.logout();
                                        LoginActivity.launchClearTask(getActivity());
                                    });*/

                        });
                break;
        }
    }

    private void initView() {
        refreshMapRegularly();
        refreshTrackRegularly();

        UserLogin userLogin = currentUser.getUserLogin();
        if (userLogin.getSubscribed() != null &&  (int)userLogin.getSubscribed() == 1) {
            ivAccount.setImageResource(R.drawable.avatar_v);
        } else {
            ivAccount.setImageResource(R.drawable.avatar_n);
        }

        ivAccount.setOnClickListener(v -> {
            if (popupWindow != null) {
                popupWindow.showAsDropDown(v, -153, 0);
            }
        });

        slidingLayout.addPanelSlideListener(new SlidingUpPanelLayout.PanelSlideListener() {
            @Override
            public void onPanelSlide(View panel, float slideOffset) {
            }

            @Override
            public void onPanelStateChanged(View panel, SlidingUpPanelLayout.PanelState previousState, SlidingUpPanelLayout.PanelState newState, float slideOffset) {
                Logger.t(TAG).d("onPanelStateChanged previousState: " + previousState + " newState: " + newState + " slideOffset: " + slideOffset);

                if (newState == SlidingUpPanelLayout.PanelState.ANCHORED) {
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(recyclerView.getLayoutParams());
                    layoutParams.setMargins(ViewUtils.dp2px(18), 0, ViewUtils.dp2px(18), (int) ((panel.getHeight() - ViewUtils.dp2px(65)) * (1 - slideOffset)));
                    recyclerView.setVisibility(View.VISIBLE);
                    recyclerView.setLayoutParams(layoutParams);
                    ivExpand.setImageResource(R.drawable.icon_collsape_arrow);
                    llFilter.setVisibility(View.VISIBLE);
                } else if (newState == SlidingUpPanelLayout.PanelState.DRAGGING) {
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(recyclerView.getLayoutParams());
                    layoutParams.setMargins(ViewUtils.dp2px(18), 0, ViewUtils.dp2px(18), 0);
                    recyclerView.setLayoutParams(layoutParams);
                    recyclerView.setVisibility(View.GONE);
                    llFilter.setVisibility(View.GONE);
                    ivExpand.setImageResource(R.drawable.icon_expand_arrow);
                } else if (newState == SlidingUpPanelLayout.PanelState.COLLAPSED) {
                    llFilter.setVisibility(View.GONE);
                    recyclerView.setVisibility(View.GONE);
                    ivExpand.setImageResource(R.drawable.icon_expand_arrow);
                }
            }
        });

        rgFilterType.setOnCheckedChangeListener((group, checkedId) -> onCheckedRadio(checkedId));
        rgFilterType.check(rbStatus.getId());

        mSummaryAdapter = new SummaryAdapter(getContext());
        recyclerView.setAdapter(mSummaryAdapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
//        recyclerView.setLayoutManager(new WrapContentLinearLayoutManager(getActivity(),LinearLayoutManager.HORIZONTAL, false));

        pullToRefresh.setOnRefreshListener(() -> refOverView(true));

        final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
            }

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                assert linearLayoutManager != null;
                int totalItemCount = linearLayoutManager.getItemCount();
                int lastVisibleItemPOs = linearLayoutManager.findLastVisibleItemPosition();
                Logger.t(TAG).d("doanvt -- totalItemCount: " + totalItemCount + " lastVisibleItemPos: " + lastVisibleItemPOs);
                if (!isLoading && totalItemCount <= lastVisibleItemPOs + 1) {
                    if (currentIndex < totalPage) {
                        currentIndex += 1;
                        progressBar.setVisibility(View.VISIBLE);
                        viewModel.getMoreFleet((int) currentIndex);
                    }
                }
            }
        });

        mSummaryAdapter.setOperationListener(record -> {
            Logger.t(TAG).d("onClickSummary: " + record.hours);
            showDriverTrip(record.plateNo, record.miles,
                    record.hours, record.events, record.cameraSn,
                    record.driverName, "" + record.driverId, record.mode, record.isOnline, record);
        });
    }

    private void onCheckedRadio(int checkedId) {
        if (checkedId == rbStatus.getId()) {
            setRadioButtonTextColor(0);
        } else if (checkedId == rbPlateNumber.getId()) {
            setRadioButtonTextColor(1);
        } else if (checkedId == rbMileageDriven.getId()) {
            setRadioButtonTextColor(2);
        } else if (checkedId == rbTimeDriven.getId()) {
            setRadioButtonTextColor(3);
        } else if (checkedId == rbEvent.getId()) {
            setRadioButtonTextColor(4);
        }
    }

    private void setRadioButtonTextColor(int index) {
        rbStatus.setTextColor(getResources().getColor(index == 0 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbPlateNumber.setTextColor(getResources().getColor(index == 1 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbMileageDriven.setTextColor(getResources().getColor(index == 2 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbTimeDriven.setTextColor(getResources().getColor(index == 3 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbEvent.setTextColor(getResources().getColor(index == 4 ? R.color.colorBaseFleet : R.color.colorPrimary));
        sortFleetViewBeanList(index);
    }

    private void initEvent() {
        viewModel.outputs.currentIndex()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentIndex, new ServerErrorHandler());

        viewModel.outputs.totalPage()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onTotalPage, new ServerErrorHandler());


        viewModel.outputs.summaryList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSummaryList, new ServerErrorHandler(TAG));

        viewModel.outputs.fleetViewBean()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onFleetView, new ServerErrorHandler(TAG));

        viewModel.outputs.tripList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onTripList, new ServerErrorHandler(TAG));

        viewModel.outputs.trackList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onTrackList, new ServerErrorHandler(TAG));

        viewModel.outputs.eventList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventList, new ServerErrorHandler(TAG));

        viewModel.outputs.eventDetail()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventDetail, new ServerErrorHandler(TAG));

        viewModel.outputs.videoUrlDetail()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVideoUrl, new ServerErrorHandler(TAG));

        viewModel.outputs.unreadNotification()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onUnread, new ServerErrorHandler(TAG));

        viewModel.errors.apiError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onApiError, new ServerErrorHandler(TAG));

        viewModel.errors.networkError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNetworkError, new ServerErrorHandler(TAG));

        viewModel.errors.responseErr()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onExpireToken, new ServerErrorHandler(TAG));

        currentUser.userLoginObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::refreshUserLoginInfo, new ServerErrorHandler(TAG));
    }

    private void refreshUserLoginInfo(Optional<UserLogin> userOptional) {
        userLogin = userOptional.getIncludeNull();
        setUpPopupWindow();
    }

    /**
     * hiển thị có thông báo mới chưa đọc
     */
    @SuppressLint("SetTextI18n")
    private void onUnread(Optional<Integer> optional) {
        Integer unread = optional.get();
        Logger.t(TAG).d("onUnread: " + unread);
        if (unread > 99) {
            tvUnreadCount.setVisibility(View.VISIBLE);
            tvUnreadCount.setText("99+");
        } else if (unread > 0) {
            tvUnreadCount.setVisibility(View.VISIBLE);
            tvUnreadCount.setText(unread.toString());
        } else {
            tvUnreadCount.setVisibility(View.GONE);
        }
    }

    private void onNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(getContext(), throwable);
    }

    private void onApiError(ErrorEnvelope envelope) {
        if (envelope != null) {
            Toast.makeText(getContext(), envelope.getErrorMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    private void onExpireToken(Response response) {
        NetworkErrorHelper.handleExpireToken(mActivity, response);
    }

    /**
     * handler xử lý kết quả get List Trip
     *
     * @param tripMap list trip get from Server
     */
    private void onTripList(Map<List<TripBean>, Boolean> tripMap) {
        Iterator<List<TripBean>> iterator = tripMap.keySet().iterator();
        List<TripBean> tripBeans = iterator.hasNext() ? iterator.next() : null;

        if (tripBeans.size() == 0) {
            share_trip.setVisibility(View.GONE);
            progressBar.setVisibility(View.GONE);
        }else{
            share_trip.setVisibility(View.VISIBLE);
        }

        Boolean aBoolean = tripMap.get(tripBeans);
        boolean isNeedMoveMap = aBoolean != null && aBoolean;

        tripBeanList.clear();
        Logger.t(TAG).d("onTripList: " + tripBeans.size());
        tripBeanList.addAll(tripBeans);
        Activity activity = getActivity();
        if (activity == null) {
            return;
        }
        mRecyclerViewTrip.setLayoutManager(new LinearLayoutManager(activity, LinearLayoutManager.HORIZONTAL, false));
        TripAdapter adapter = new TripAdapter(activity.getBaseContext());
        adapter.setTripList(tripBeanList);
        adapter.setTripBeanOperationListener(bean -> {
            Logger.t(TAG).d("onClick Item Trip");
            progressBar.setVisibility(View.VISIBLE);
            viewModel.queryTrack(bean, isNeedMoveMap);
        });
        mRecyclerViewTrip.setAdapter(adapter);

        isForeground = false;
    }

    /**
     * handle snapToRoadFinish
     */

    private void showMapTrip(List<LatLng> latLngs, TripBean tripBean, boolean isNeedMove) {

        mTrackLatlngList.clear();
        if (latLngs != null && !mTrackLatlngList.containsAll(latLngs)) {
            mTrackLatlngList.addAll(latLngs);
        }
        moveMapCenter(mTrackLatlngList, isNeedMove);

        progressBar.setVisibility(View.GONE);
        mGoogleMap.clear();
        Logger.t(TAG).d("LatLng size: " + mTrackLatlngList.size());

        if (tripBeanList.size() != 0) {
            TripBean lastTripBean = tripBeanList.get(tripBeanList.size() - 1);

            if (!tripBean.getCameraSn().equals(lastTripBean.getCameraSn())) {
                mGoogleMap.addPolyline(new PolylineOptions()
                        .addAll(mTrackLatlngList)
                        .geodesic(true)
                        .color(0xBA999999)
                        .jointType(ROUND)
                        .width(5)
                        .startCap(new CustomCap(BitmapDescriptorFactory.fromResource(R.drawable.icon_path_start_history), 16))
                        .endCap(new RoundCap()));

//                drawArrow(mTrackLatlngList, false);
            } else {
                mGoogleMap.addPolyline(new PolylineOptions()
                        .addAll(mTrackLatlngList)
                        .geodesic(true)
                        .color(0xBA003c78) //4a90e2
                        .jointType(ROUND)
                        .width(5)
                        .startCap(new CustomCap(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_point_start,100 , mActivity), 30))
                        .endCap(new CustomCap(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_point_end,100 , mActivity), 30)));

//                drawArrow(mTrackLatlngList, true);
            }
            //judge offline or online(parking or driving)
            FleetViewRecord record = mSummaryMap.get(currentDriverID);
            if (record != null) {
                MarkerOptions markerOptions = new MarkerOptions();

//                String cameraStatus = record.mode;
//                if ("offline".equals(cameraStatus)) {
//                    markerOptions.icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_offline_marker));
//                } else if ("parking".equals(cameraStatus)) {
//                    markerOptions.icon(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_parking_map, mActivity));
//                } else if ("driving".equals(cameraStatus)) {
//                    markerOptions.icon(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_driving_map, mActivity));
//                }
                markerOptions.title(record.driverName);
                markerOptions.snippet(record.plateNo);
                markerOptions.icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_path_start));
                if (mTrackLatlngList.size() != 0) {
                    Marker marker = mGoogleMap.addMarker(markerOptions
                            .zIndex(3.0f)
                            .anchor(0.5f, 0.5f)
                            .position(mTrackLatlngList.get(mTrackLatlngList.size() - 1)));
                    marker.showInfoWindow();
                    MarkerAnimation markerAnimation = new MarkerAnimation(mTrackLatlngList, marker);
                    markerAnimation.animateMarker(latLngs1 -> {
//                            moveMapCenter(latLngs,true);
                    });
                }
            }
        }
    }

    public interface TripBeanOperationListener {
        void onClickItem(TripBean bean);
    }

    @SuppressLint("DefaultLocale")
    private void onTrackList(Map<TripBean, Boolean> tripMap) {
        Iterator<TripBean> iterator = tripMap.keySet().iterator();
        TripBean tripBean = iterator.hasNext() ? iterator.next() : null;

        if (tripBean == null) {
            progressBar.setVisibility(View.GONE);
            share_trip.setVisibility(View.GONE);
            return;
        }
        tripId = tripBean.getTripId();
        share_trip.setVisibility(View.VISIBLE);

        Boolean aBoolean = tripMap.get(tripBean);
        boolean isNeedMoveMap = aBoolean != null && aBoolean;

        List<TrackBean> trackBeanList = tripBean.getGpsDataList();

        if (trackBeanList.size() == 0) {
            progressBar.setVisibility(View.GONE);
            share_trip.setVisibility(View.GONE);
            Toast.makeText(getContext(), "Không có dữ liệu của chuyến đi", Toast.LENGTH_SHORT).show();
            return;
        }

        share_trip.setVisibility(View.VISIBLE);


        StringBuilder path = new StringBuilder();
        for (TrackBean trackBean : trackBeanList) {
            List<Double> coordinate = trackBean.getCoordinate();
            Double lat = coordinate.get(1);
            Double lng = coordinate.get(0);

            if (lat == 0 || lng == 0) {
                continue;
            }
            path.append(lat).append(",").append(lng).append("|");
        }


        //snapToRoad
        if (path.length() != 0) {
            SnapToRoadAsyncTask snap = new SnapToRoadAsyncTask(latLngs -> showMapTrip(latLngs, tripBean, isNeedMoveMap), path);
            snap.execute();
        }
    }

    /**
     * show image arrow on map
     *
     * @param latLngList tọa độ lấy từ tripBean
     * @param recent     boolean check lastTime
     */
    private void drawArrow(List<LatLng> latLngList, boolean recent) {
        Logger.t(TAG).d("LatLng size: " + latLngList.size());
        for (int i = 0; i < latLngList.size() - 1; i++) {
            LatLng startLL = latLngList.get(i);
            LatLng endLL = latLngList.get(i + 1);
            double heading = SphericalUtil.computeHeading(startLL, endLL);

            mClusterManager.addItem(new TrackArrow(endLL,
                    recent ? R.drawable.icon_track_recent : R.drawable.icon_track_history,
                    (float) heading));
        }
        mClusterManager.cluster();

        if (recent) {
            progressBar.setVisibility(View.GONE);
        }
    }

    /**
     * handler get List Event
     *
     * @param eventBeans list event
     */
    private void onEventList(List<CameraEventBean> eventBeans) {
        Logger.t(TAG).d("onEventList: " + eventBeans.size());

        if (eventBeans.size() == 0
                || includeDetailLive.getVisibility() == View.GONE) {
            progressBar.setVisibility(View.GONE);
            return;
        }

        for (CameraEventBean eventBean : eventBeans) {
            double latitude = eventBean.getGpsLatitude();
            double longitude = eventBean.getGpsLongitude();

            if (latitude == 0 || longitude == 0) {
                continue;
            }

            mEventMap.put(eventBean.getClipID(), eventBean);

            String eventType = eventBean.getEventType();
            mGoogleMap.addMarker(new MarkerOptions()
                    .anchor(0.5f, 0.5f)
                    .zIndex(2.0f)
                    .snippet(eventBean.getClipID())
                    .icon(BitmapDescriptorFactory.fromResource(VideoEventType.getEventIconResource(eventType, true)))
                    .position(MapTransformUtil.gps84_To_Gcj02(new LatLng(latitude, longitude))));
        }
    }

    /**
     * Sắp xếp record with ...
     *
     * @param index with options
     */
    private void sortFleetViewBeanList(int index) {
        if (mFleetViewBeanRecordList.size() == 0) {
            return;
        }

        Collections.sort(mFleetViewBeanRecordList, (o1, o2) -> {
            switch (index) {
                case 0:
                    String o1Status = !TextUtils.isEmpty(o1.mode) ? o1.mode : "null";
                    String o2Status = !TextUtils.isEmpty(o2.mode) ? o2.mode : "null";
                    Logger.t(TAG).e("status: " + o1Status + " ; " + o2Status);
                    if (o1Status.equals(o2Status)) {
                        return (int) (o2.miles - o1.miles);
                    } else if ("driving".equals(o1Status) || "driving".equals(o2Status)) {
                        return "driving".equals(o1Status) ? -1 : 1;
                    } else if ("parking".equals(o1Status) || "parking".equals(o2Status)) {
                        return "parking".equals(o1Status) ? -1 : 1;
                    }
                    break;
                case 2:
                    return (int) (o2.miles - o1.miles);
                case 3:
                    double offsetDuration = o2.hours - o1.hours;
                    return (int) (offsetDuration != 0 ? offsetDuration : o2.miles - o1.miles);
                case 4:
                    int offsetEvent = o2.events - o1.events;
                    return offsetEvent != 0 ? offsetEvent : (int) (o2.miles - o1.miles);
            }
            return 0;
        });

        mSummaryAdapter.setNewData(mFleetViewBeanRecordList);
    }

    private void onFleetView(FleetViewBean bean) {
        if (bean != null) {
            fleetViewBean = bean;
        }
    }

    private void onCurrentIndex(Double index) {
        currentIndex = index;
    }

    private void onTotalPage(Double pages) {
        totalPage = pages;
    }

    /**
     * show Record on map
     *
     * @param summaryMap data List record
     */
    private void onSummaryList(Map<List<FleetViewRecord>, Boolean> summaryMap) {
        Iterator<List<FleetViewRecord>> listIterator = summaryMap.keySet().iterator();
        List<FleetViewRecord> records = listIterator.hasNext() ? listIterator.next() : new ArrayList<>();
        Logger.t(TAG).d("onSummaryList: " + records.size());
        isLoading = false;
        progressBar.setVisibility(View.GONE);
        Boolean aBoolean = summaryMap.get(records);
        boolean isNeedMoveMap = aBoolean != null && aBoolean;

        if (records.size() == 0
                || ivBack.getVisibility() == View.VISIBLE
                || slidingLayout.getPanelState() == SlidingUpPanelLayout.PanelState.HIDDEN) {
            return;
        }

        if (mGoogleMap != null) mGoogleMap.clear();
        if (mClusterManager != null) mClusterManager.clearItems();
        mParkingMarkerMap.clear();

        mFleetViewBeanRecordList.clear();
        mFleetViewBeanRecordList.addAll(records);

        tvTotalNum.setText(String.valueOf(records.size()));

        mSummaryMap.clear();
        onCheckedRadio(rgFilterType.getCheckedRadioButtonId());

        int parkNum = 0, driveNum = 0;
        List<LatLng> latLngList = new ArrayList<>();

        for (FleetViewRecord record : records) {
            mSummaryMap.put("" + record.driverId, record);

            String status = record.mode;
            if ("parking".equals(status)) {
                parkNum++;
            } else if ("driving".equals(status)) {
                driveNum++;
            }

            GpsData gps = record.gpsData;
            if (gps == null) {
                continue;
            }

            double latitude = gps.coordinate.get(1);
            double longitude = gps.coordinate.get(0);

            if (latitude == 0 || longitude == 0) {
                continue;
            }

            LatLng latLng = MapTransformUtil.gps84_To_Gcj02(new LatLng(latitude, longitude));
            latLngList.add(latLng);

            MarkerOptions markerOptions = new MarkerOptions();

            ClusterMarker marker = new ClusterMarker();

            String cameraStatus = record.mode;
            if (!"offline".equals(cameraStatus)) {
                if ("parking".equals(cameraStatus)) {
                    mParkingMarkerMap.put(record.cameraSn, latLng);
                    markerOptions
                            .zIndex(1.0f)
                            .icon(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_parking_map, mActivity));
//                    marker.setResource(R.drawable.icon_parking_map);
                } else if ("driving".equals(cameraStatus)) {
                    markerOptions
                            .zIndex(1.0f)
                            .icon(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_driving_map, mActivity));

//                    marker.setResource(R.drawable.icon_driving_map);
                }
            } else {
                markerOptions.icon(ImageBitmapUtils.vectorToBitmap(R.drawable.icon_offline_marker, mActivity));
//                marker.setResource(R.drawable.icon_offline_marker);
            }

            mGoogleMap.addMarker(markerOptions
                    .anchor(0.5f, 0.5f)
                    .position(latLng)
                    .snippet("" + record.driverId));
            marker.setPosition(latLng);
//            mMarkerManager.addItem(marker);
        }

//        mMarkerManager.cluster();

        tvParkingNum.setText(String.valueOf(parkNum));
        tvDrivingNum.setText(String.valueOf(driveNum));
        moveMapCenter(latLngList, isNeedMoveMap);
    }

    @Override
    protected void onFragmentPause() {
        isForeground = false;
    }

    @Override
    protected void onFragmentResume() {
        Logger.t(TAG).d("onFragmentResume mShowMessage: " + mShowMessage);
        isForeground = true;

        if (includeDetailLive.getVisibility() == View.VISIBLE
                || includeEvents.getVisibility() == View.VISIBLE) {
            Logger.t(TAG).d("no refresh map");
            return;
        }

        refreshMap();
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        llFilter.setVisibility(View.INVISIBLE);
        if (mShowMessage) {
            mShowMessage = false;
            ivAlert.post(this::toAlerts);
        }
    }

    private void refOverView(boolean isNeedMoveMap) {
        pullToRefresh.setRefreshing(false);
        progressBar.setVisibility(View.VISIBLE);
        viewModel.refreshOverview(isNeedMoveMap);
        isLoading = true;
    }

    private void queryUnread() {
        long toTime = System.currentTimeMillis();
        long fromTime = DashboardUtil.getZeroFromTime(4, toTime);
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        String toDate = df.format(new Date(toTime));
        String fromDate = df.format(new Date(fromTime));
        viewModel.inputs.queryUnread(fromDate, toDate);
    }

    private void refreshMapRegularly() {
        Observable.interval(30, 30, TimeUnit.SECONDS)
                .take(Integer.MAX_VALUE)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(aLong -> {
                    if (!isForeground
                            || includeDetailLive.getVisibility() == View.VISIBLE
                            || includeEvents.getVisibility() == View.VISIBLE) {
                        Logger.t(TAG).d("refreshMapRegularly no refresh map");
                        return;
                    }

                    Logger.t(TAG).d("refreshMapRegularly frequency: " + aLong);
                    refOverView(false);

                }, throwable -> Logger.t(TAG).d("refreshMapRegularly throwable: " + throwable.getMessage()));
    }

    private void refreshTrackRegularly() {
        Observable.interval(30, 30, TimeUnit.SECONDS)
                .take(Integer.MAX_VALUE)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(aLong -> {
                    if (!isForeground
                            || includeDetailLive.getVisibility() == View.GONE) {
                        Logger.t(TAG).d("refreshTrackRegularly no refresh trip");
                        return;
                    }

                    Logger.t(TAG).d("refreshTrackRegularly frequency: " + aLong);

                    if (mGoogleMap != null) mGoogleMap.clear();
                    if (mClusterManager != null) mClusterManager.clearItems();

                    mTrackLatlngList.clear();
                    mEventMap.clear();

                    viewModel.inputs.queryTrips(true);
//                    viewModel.inputs.queryEvents();
                }, throwable -> Logger.t(TAG).e("refreshTrackRegularly throwable: " + throwable.getMessage()));
    }

    private void refreshMap() {
        Logger.t(TAG).d("refreshMap");
        currentDriverID = "";
        tvToolbarTitle.setText(R.string.overview);

        refOverView(true);
    }

    private void moveMapCenter(List<LatLng> latLngs, boolean isNeedMove) {
        Logger.t(TAG).d("moveMapCenter: " + latLngs.size());
        if (latLngs.size() == 0 || !isNeedMove) {
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

    @Override
    protected void onFragmentFirstVisible() {
        SupportMapFragment fragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.googleMap);
        if (fragment != null) {
            fragment.getMapAsync(this);
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Logger.t(TAG).d("onMapReady: " + googleMap);
        if (mGoogleMap != null) {
            return;
        }
        mGoogleMap = googleMap;

        try {
            boolean setMapStyle = mGoogleMap.setMapStyle(
                    MapStyleOptions.loadRawResourceStyle(getContext(), R.raw.style_json));
            if (!setMapStyle) {
                Logger.t(TAG).e("Style parsing failed.");
            }
        } catch (Resources.NotFoundException e) {
            Logger.t(TAG).e("Can't find style. Error: " + e);
        }

        mClusterManager = new ClusterManager<>(getContext(), googleMap);
        mClusterManager.setRenderer(new TrackArrowRender(getContext(), googleMap, mClusterManager));
        mClusterManager.setAnimation(false);
        googleMap.setOnCameraIdleListener(mClusterManager);

//        mMarkerManager = new ClusterManager<>(getContext(), googleMap);
//        mMarkerManager.setRenderer(new ClusterMarkerRender(getContext(), googleMap, mMarkerManager));
//        mMarkerManager.setAnimation(true);
        googleMap.setOnCameraIdleListener(mMarkerManager);
        googleMap.setOnMarkerClickListener(mMarkerManager);
//        mMarkerManager.setOnClusterClickListener(this);
//        mMarkerManager.setOnClusterItemClickListener(this);

        initListener();
    }

    private void initListener() {
        mGoogleMap.setOnMarkerClickListener((Marker marker) -> {
            String snippet = marker.getSnippet();
            Logger.t(TAG).d("onMarkerClick: " + snippet);
            if (TextUtils.isEmpty(snippet)) {
                return false;
            }

            if (includeDetailLive.getVisibility() == View.GONE) {
                FleetViewRecord record = mSummaryMap.get(snippet);

                if (record != null) {
                    Logger.t(TAG).d("onMarkerClick: " + snippet + " FleetViewBean: " + record.cameraSn);

                    showDriverTrip(record.plateNo, record.miles,
                            record.hours, record.events, record.cameraSn,
                            record.driverName, "" + record.driverId, record.mode, record.isOnline, record);
                }
            } else {
                CameraEventBean eventBean = mEventMap.get(snippet);
                Logger.t(TAG).d("onMarkerClick: " + snippet + " eventBean: " + eventBean);

                if (eventBean != null) {
                    showEventDetail(eventBean);
                }
            }
            return true;
        });
    }

    private long mLastClickTime = 0;

    /**
     * hiển thị thêm thông tin về Trip, driver. show menu detail-view live
     *
     * @param plateNumber  biển số xe
     * @param miles        quãng đường
     * @param duration     thời gian lái xe
     * @param events       số event
     * @param sn           cameraSn
     * @param driverName   tên tài xế
     * @param driverID     id tài xế
     * @param cameraStatus trạng thái camera lái xe
     * @param isIsOnline   trạng thái hoạt động
     * @param record       FleetViewRecord
     */
    @SuppressLint("SetTextI18n")
    private void showDriverTrip(String plateNumber, double miles, double duration, int events, String sn, String driverName, String driverID, String cameraStatus, boolean isIsOnline, FleetViewRecord record) {
        if (mGoogleMap != null) mGoogleMap.clear();
        if (mClusterManager != null) mClusterManager.clearItems();
        currentDriverID = driverID;

        LatLng latLng = mParkingMarkerMap.get(sn);
        if (latLng != null) {
            mGoogleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .zIndex(3.0f)
                    .anchor(0.5f, 0.5f)
                    .icon(ImageBitmapUtils.vectorToBitmap(R.drawable.ic_parking_map, mActivity)));
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
        }

        mTrackLatlngList.clear();
        mEventMap.clear();

        viewModel.cameraSn = sn;
        progressBar.setVisibility(View.VISIBLE);
        viewModel.inputs.queryTrips(true);
//        viewModel.inputs.queryEvents();

        tvToolbarTitle.setText(!StringUtils.isEmpty(driverName) ? driverName : "Không có tài xế");

        if (includeEvents.getVisibility() == View.VISIBLE) {
            hideAnimation(includeEvents);
        }

        if (includeDetailLive.getVisibility() == View.VISIBLE) {
            hideAnimation(includeDetailLive);
        }

        showAnimation(includeDetailLive);

        ivBack.setVisibility(View.VISIBLE);
        slidingLayout.setPanelState(SlidingUpPanelLayout.PanelState.HIDDEN);

        tvPlateNumber.setText(plateNumber);
        tvDriverName.setText(!StringUtils.isEmpty(record.driverName) ? record.driverName : "Không có tài xế");
        if ("offline".equals(cameraStatus)) {
            ivCameraStatus.setImageResource(R.drawable.icon_offline_mode);
        } else if ("parking".equals(cameraStatus)) {
            ivCameraStatus.setImageResource(R.drawable.ic_parking_map);
        } else {
            ivCameraStatus.setImageResource(R.drawable.ic_driving_map);
        }

        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        DecimalFormat decimalFormat2 = new DecimalFormat("0.0");
        tvMiles.setText(record.miles > 0 ? decimalFormat.format((float) miles / 1000) + " km" : decimalFormat2.format((float) record.miles) + " km"); //1609.3f
        tvHours.setText(record.hours > 0 ? decimalFormat.format((float) record.hours) + " h" : decimalFormat2.format((float) record.hours) + " h");
        tvEvents.setText(String.valueOf(events));

        llSpeedReal.setVisibility(View.GONE);


//        if (record.gpsData != null) {
//            String speed = record.gpsData.speed > 0 ? decimalFormat.format((float) record.gpsData.speed) + " km/h" : decimalFormat2.format((float) record.gpsData.speed) + " km/h";
//            tvSpeed.setText(speed);
//        } else {
//            tvSpeed.setText("0,0 km/h");
//            tvSpeed.setVisibility(View.GONE);
//            llSpeedReal.setVisibility(View.GONE);
//        }c

        llGoDetail.setOnClickListener(v -> {
            if (System.currentTimeMillis() - mLastClickTime > 2000) {
                mLastClickTime = System.currentTimeMillis();

                ARouter.getInstance().build("/ui/activity/TimelineActivity")
                        .withString(IntentKey.FLEET_DRIVER_ID, driverID)
                        .withString(IntentKey.FLEET_CAMERA_SN, record.cameraSn)
                        .withString(IntentKey.FLEET_DRIVER_NAME, driverName)
                        .withString(IntentKey.FLEET_PLATE_NUMBER, plateNumber)
                        .withString(IntentKey.FLEET_BRAND_VEHICLE, record.brand)
                        .withDouble(IntentKey.FLEET_MILES, miles)
                        .withDouble(IntentKey.FLEET_TIME_DRIVING, duration)
                        .withInt(IntentKey.FLEET_EVENT_NUM, events)
                        .withSerializable(IntentKey.FLEET_RECORD, record)
                        .navigation();

            }
        });

        llGoLive.setOnClickListener(v -> {
            if (currentUser.getUserLogin() != null && currentUser.getUserLogin().getSubscribed() != null && (int)currentUser.getUserLogin().getSubscribed() == 0) {
                Toast.makeText(getActivity(), getString(R.string.warning_upgrade_vip), Toast.LENGTH_SHORT).show();
                return;
            }

            if (System.currentTimeMillis() - mLastClickTime > 2000) {
                mLastClickTime = System.currentTimeMillis();

                FleetCameraBean fleetCamera = viewModel.getCurrentUser().getFleetCamera(viewModel.cameraSn);
                Logger.t(TAG).d("fleetCamera: " + fleetCamera);
                SignalInfo signalInfo = record.signalInfo;
                double rsrp = 0.0;
                if (signalInfo != null) {
                    rsrp = signalInfo.rsrp;
                }

                if (fleetCamera != null) {
                    ARouter.getInstance().build("/ui/activity/FleetLiveActivity")
                            .withString(IntentKey.SERIAL_NUMBER, sn)
                            .withString(IntentKey.FLEET_DRIVER_NAME, driverName)
                            .withString(IntentKey.FLEET_PLATE_NUMBER, plateNumber)
                            .withString(IntentKey.FLEET_CAMERA_STATUS, cameraStatus)
                            .withBoolean(IntentKey.FLEET_ONLINE, isIsOnline)
                            .withDouble(IntentKey.FLEET_RSRP, rsrp)
                            .withSerializable(IntentKey.FLEET_RECORD, record)
                            .withString(IntentKey.FLEET_CAMERA_ROTATE, fleetCamera.getRotate())
                            .withBoolean(IntentKey.FLEET_NEED_DEWARP, fleetCamera.getSn().startsWith("2"))
//                            .withString(IntentKey.FLEET_START_DRIVING_TIME,"")
                            .navigation();
                }
            }
        });
    }

    /**
     * hiển thị chi tiết event
     *
     * @param eventBean data event
     */
    private void showEventDetail(CameraEventBean eventBean) {
        cameraEventBean = eventBean;
        if (mGoogleMap != null) mGoogleMap.clear();
        if (mClusterManager != null) mClusterManager.clearItems();

        LatLng latLng = MapTransformUtil.gps84_To_Gcj02(
                new LatLng(eventBean.getGpsLatitude(), eventBean.getGpsLongitude()));

        mGoogleMap.addMarker(new MarkerOptions()
                .position(latLng)
                .anchor(0.5f, 0.5f)
                .icon(BitmapDescriptorFactory.fromResource(VideoEventType.getEventIconResource(eventBean.getEventType(), true))));

        mGoogleMap.animateCamera(CameraUpdateFactory.newLatLng(latLng));

        if (includeEvents.getVisibility() == View.VISIBLE) {
            hideAnimation(includeEvents);
        }

        if (includeDetailLive.getVisibility() == View.VISIBLE) {
            hideAnimation(includeDetailLive);
        }

        showAnimation(includeEvents);

        ivBack.setVisibility(View.VISIBLE);
        slidingLayout.setPanelState(SlidingUpPanelLayout.PanelState.HIDDEN);

        ivEventType.setImageResource(VideoEventType.getEventIconResource(eventBean.getEventType(), false));
        tvEventType.setText(VideoEventType.dealEventType(getContext(), eventBean.getEventType()));
        tvPlateTime.setText(String.format("%s  |  %s",
                eventBean.getPlateNo(), eventBean.getStartTime()));
        tvEventLocation.setText("null");

        viewModel.queryVideoUrl(eventBean);
    }

    /**
     * Xem clip
     *
     * @param beanOptional data video
     */
    private void onVideoUrl(Optional<VideoUrlBean> beanOptional) {
        VideoUrlBean bean = beanOptional.getIncludeNull();
        Logger.t(TAG).d("onVideoUrl: ", bean);
        ivEventPlay.setOnClickListener(v -> {
            if (System.currentTimeMillis() - mLastClickTime > 2000) {
                mLastClickTime = System.currentTimeMillis();

                if (bean == null) {
                    Toast.makeText(getContext(), "video error", Toast.LENGTH_SHORT).show();
                } else {
                    ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                            .withString(FleetVideoActivity.VIDEO_URL, bean.getData())
                            .withString(FleetVideoActivity.EVENT_TYPE, cameraEventBean.getEventType())
                            .withString(FleetVideoActivity.START_TIME, cameraEventBean.getStartTime())
                            .withDouble(FleetVideoActivity.DURATION, cameraEventBean.getDuration())
                            .withString(IntentKey.FLEET_DRIVER_NAME, cameraEventBean.getDriverName())
                            .withString(IntentKey.FLEET_PLATE_NUMBER, cameraEventBean.getPlateNo())
                            .withDouble(IntentKey.GPS_LAT, cameraEventBean.getGpsLatitude())
                            .withDouble(IntentKey.GPS_LONG, cameraEventBean.getGpsLongitude())
                            .withString(IntentKey.FLEET_CAMERA_ROTATE, "upsidedown")
                            .withString(IntentKey.SERIAL_NUMBER, cameraEventBean.getCameraSn())
                            .withBoolean(FleetVideoActivity.LOCAL_VIDEO, false)
                            .navigation();
                }
            }
        });
    }

    /**
     * chi tiết event
     *
     * @param beanOptional EventDetailBean data
     */
    private void onEventDetail(Optional<EventDetailBean> beanOptional) {
        EventDetailBean detailBean = beanOptional.getIncludeNull();

        Logger.t(TAG).d("onEventDetail: " + detailBean);
        ivEventPlay.setOnClickListener(v -> {
            if (System.currentTimeMillis() - mLastClickTime > 2000) {
                mLastClickTime = System.currentTimeMillis();

                if (detailBean == null) {
                    Toast.makeText(getContext(), "event video error", Toast.LENGTH_SHORT).show();
                } else {
                    ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                            .withString(FleetVideoActivity.VIDEO_URL, detailBean.getUrl())
                            .withString(IntentKey.FLEET_DRIVER_NAME, detailBean.getDriver())
                            .withString(IntentKey.FLEET_PLATE_NUMBER, detailBean.getPlateNumber())
                            .withString(IntentKey.FLEET_CAMERA_ROTATE, detailBean.getRotate())
                            .withString(IntentKey.SERIAL_NUMBER, detailBean.getCameraSN())
                            .navigation();
                }
            }
        });
    }

    private String getFormattedTime(long utcTimeMillis) {
        TimeZone timeZone = TimeZone.getDefault();

        SimpleDateFormat format = new SimpleDateFormat("HH:mm MMMM dd", Locale.getDefault());
        format.setTimeZone(timeZone);
        return format.format(utcTimeMillis);
    }

    private void showAnimation(View view) {
        Animation animation = AnimationUtils.loadAnimation(getContext(), R.anim.pop_show);
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                view.clearAnimation();
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }
        });
        view.setVisibility(View.VISIBLE);
        view.startAnimation(animation);
    }

    private void hideAnimation(View view) {
        Animation animation = AnimationUtils.loadAnimation(getContext(), R.anim.pop_hidden);
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                view.clearAnimation();
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }
        });
        view.setVisibility(View.GONE);
        view.startAnimation(animation);
    }

    @Override
    public boolean onClusterClick(Cluster<ClusterMarker> cluster) {
        Logger.t(TAG).d("onClusterClick");
        // Create the builder to collect all essential cluster items for the bounds.
        LatLngBounds.Builder builder = LatLngBounds.builder();
        for (ClusterItem item : cluster.getItems()) {
            builder.include(item.getPosition());
        }
        // Get the LatLngBounds
        final LatLngBounds bounds = builder.build();

        // Animate camera to the bounds
        try {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 100));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    @Override
    public boolean onClusterItemClick(ClusterMarker item) {
        Logger.t(TAG).d("onClusterItemClick");
        return false;
    }

    public interface SummaryOperationListener {
        void onClickSummary(FleetViewRecord record);
    }

    public interface DashFleetOperationListener {
        void onClickDashFleet(DetailBean.Record record);
    }

}
