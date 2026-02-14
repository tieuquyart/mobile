package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.ACCELERATOR;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.DRIVING_HIT;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.FORWARD_COLLISION;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.HARD_ACCEL;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.HARD_BRAKE;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.NotiId;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.OVER_SPEED;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.PARKING_HIT;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.SHARP_TURN;
import static com.mk.autosecure.ui.activity.settings.NotificationInfoActivity.notificationId;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.FleetVideoActivity;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.adapter.NotiManageAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.viewmodels.NotificationViewModel;
import com.orhanobut.logger.Logger;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Optional;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;

@SuppressLint({"CheckResult", "NewApi", "NonConstantResourceId", "SimpleDateFormat"})
@RequiresActivityViewModel(NotificationViewModel.ViewModel.class)
public class NotiManageActivity extends BaseActivity<NotificationViewModel.ViewModel> {
    public static final String TAG = NotiManageActivity.class.getSimpleName();
    public static final String KEY_HAS_TRANS = "KEY_HAS_TRANS";
    public static final String LOAD_LIST_NOTI = "load_list_noti";
    private NotiManageAdapter adapter;
    public static String notificationID = "";

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.recycleView)
    RecyclerView recyclerView;

    @BindView(R.id.rl_loading)
    RelativeLayout rlLoading;

    @BindView(R.id.spCategory)
    Spinner spCategory;

    @BindView(R.id.llSwipeRefresh)
    SwipeRefreshLayout llSwipeRefresh;

    protected HornApplication hornApplication;

    public boolean isOpenNoti = false;

    private String category = "";

    private int currentIndex, totalPage;

    private boolean isLoading;

    ArrayList<NotificationBean> notificationBeanArrayList = new ArrayList<>();

    boolean isLoadMore = false;

    public static void launch(Activity activity, String notiId) {
        NotiManageActivity.notificationID = notiId;
        Intent intent = new Intent(activity, NotiManageActivity.class);
//        intent.putExtra(NotiId, notiId);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, NotiManageActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_noti_manager);
        hornApplication = (HornApplication) this.getApplicationContext();
        ButterKnife.bind(this);

        initToolbar(0);

        initEvent();


        llSwipeRefresh.setOnRefreshListener(() -> {
            isLoadMore = false;
            viewModel.queryNotiPage(category);
        });

        adapter = new NotiManageAdapter(this);
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter.setListener(bean -> {
            Logger.t(TAG).d("onclickBeanNoti: " + bean.getCategory());

            if (!bean.getMarkRead()) runOnUiThread(() -> viewModel.markRead(bean.getId()));
            if (bean.getCategory().equals(DRIVING_HIT) ||
                    bean.getCategory().equals(HARD_ACCEL) ||
                    bean.getCategory().equals(HARD_BRAKE) ||
                    bean.getCategory().equals(SHARP_TURN) ||
                    bean.getCategory().equals(OVER_SPEED) ||
                    bean.getCategory().equals(FORWARD_COLLISION) ||
                    bean.getCategory().equals(PARKING_HIT) ||
                    bean.getCategory().equals(ACCELERATOR) || (!StringUtils.isEmpty(bean.getClipId()) && !StringUtils.isEmpty(bean.getUrl()))) {
                ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                        .withString(FleetVideoActivity.VIDEO_URL, bean.getUrl())
                        .withString(FleetVideoActivity.EVENT_TYPE, bean.getEventType())
                        .withString(FleetVideoActivity.START_TIME, bean.getCreateTime())
                        .withDouble(FleetVideoActivity.DURATION, bean.getClipDuration())
                        .withString(IntentKey.FLEET_DRIVER_NAME, bean.getDriverName())
                        .withString(IntentKey.FLEET_PLATE_NUMBER, bean.getPlateNo())
                        .withDouble(IntentKey.GPS_LAT, bean.getGpsLatitude())
                        .withDouble(IntentKey.GPS_LONG, bean.getGpsLongitude())
                        .withString(IntentKey.FLEET_CAMERA_ROTATE, "upsidedown")
                        .withString(IntentKey.SERIAL_NUMBER, bean.getCameraSn())
                        .withBoolean(FleetVideoActivity.LOCAL_VIDEO, false)
                        .navigation();

            } else {
                NotificationInfoActivity.launch(NotiManageActivity.this, bean);
            }
        });
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
                Logger.t(TAG).d("doanvt -- currentIndex: " + currentIndex + " total: " + totalPage + "isLoad" + isLoading);
                if (!isLoading && totalItemCount <= lastVisibleItemPOs + 1) {
                    if (currentIndex < totalPage) {
                        isLoadMore = true;
                        currentIndex += 1;
                        viewModel.getMoreNotiPage(category, currentIndex);
                    }
                }
            }
        });

        LocalBroadcastManager.getInstance(this).registerReceiver(receiver, new IntentFilter(LOAD_LIST_NOTI));

        if (Constants.has_push_notification) {
            NotificationInfoActivity.notificationId = notificationID;
            NotificationInfoActivity.launch(this);
        } else {
            viewModel.queryNotiPage("");
            initSpinner();
        }
    }

    private void initSpinner(){
        String[] categorys = new String[]{getStringFromCategory("ALL"),
                getStringFromCategory("ACCOUNT"),
                getStringFromCategory("PAYMENT"),
                getStringFromCategory("DRVN"),
                getStringFromCategory("DMS"),
                getStringFromCategory("ACCELERATOR"),
                getStringFromCategory("HEADWAY_MONITORING"),
                getStringFromCategory("IGNITION")};

        ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(this, R.layout.item_custom_spinner, categorys);
        spCategory.setAdapter(dropdownAdapter);
        spCategory.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                isLoadMore = false;
                category = VideoEventType.textToCategory(NotiManageActivity.this, categorys[i]).equals("ALL") ? "" : VideoEventType.textToCategory(NotiManageActivity.this, categorys[i]);
                Logger.t(TAG).e("Check Log spCategory");
                viewModel.queryNotiPage(category);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
                adapter.refreshData();
            }
        });
    }

    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            isLoadMore = false;
            Logger.t(TAG).e("Check Log broadcast");
            viewModel.queryNotiPage(category);
            initSpinner();
        }
    };

    private String getStringFromCategory(String category) {
        return VideoEventType.dealCategory(this, category);
    }


    private void initToolbar(int unreadTotal) {
        toolbar.setNavigationOnClickListener(view -> {
            if (isOpenNoti) {
                Intent i = new Intent(this, LocalLiveActivity.class);
                startActivity(i);
            }
            finish();
        });
        tvToolbarTitle.setText(getString(R.string.noti_listTitle));
    }

    private void initEvent() {
        viewModel.listNotification()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleListNotification, new ServerErrorHandler(TAG));

        viewModel.countUnread()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleUnreadCount, new ServerErrorHandler(TAG));

        viewModel.currentIndex()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> currentIndex = integer.get(), new ServerErrorHandler(TAG));

        viewModel.totalPage()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> totalPage = integer.get(), new ServerErrorHandler(TAG));

        viewModel.outputs
                .showLoading()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> {
                    Logger.t(TAG).d(integer == View.VISIBLE ? "visible" : "gone");
                    if (integer == View.VISIBLE) {
                        enterLoadStatus();
                        isLoading = true;
                    } else {
                        isLoading = false;
                        new Handler().postDelayed(() -> exitLoadStatus(),500);
                    }
                }, new ServerErrorHandler());
        viewModel.outputs.error()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleErrorResponse, new ServerErrorHandler(TAG));
    }

    private void handleErrorResponse(Response response) {
        NetworkErrorHelper.handleExpireToken(this, response);
    }

    private void handleUnreadCount(Optional<Integer> optional) {
        int total = optional.get();
        initToolbar(total);
    }

    private void handleListNotification(ArrayList<NotificationBean> list) {
        Logger.t(TAG).d("size list noti: " + list.size());
        if (adapter != null && list.size() != 0) {
            if (isLoadMore){
                notificationBeanArrayList.addAll(list);

            }else{
                notificationBeanArrayList = list;
            }
            Collections.sort(notificationBeanArrayList, (o1, o2) -> compare(o2.getCreateTime(), o1.getCreateTime()));
            adapter.setListNotification(notificationBeanArrayList);
        } else {
            Toast.makeText(this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
        }
    }

    public int compare(String lhs, String rhs) {
        String first = lhs.replace("T", " ");
        String se = rhs.replace("T", " ");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        try {
            return dateFormat.parse(first).compareTo(dateFormat.parse(se));
        } catch (ParseException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    private void enterLoadStatus() {
        llSwipeRefresh.setRefreshing(true);
//        recyclerView.setVisibility(View.GONE);
    }

    private void exitLoadStatus() {
        llSwipeRefresh.setRefreshing(false);
//        recyclerView.setVisibility(View.VISIBLE);
    }


    @Override
    protected void onDestroy() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(receiver);
        super.onDestroy();
    }
}