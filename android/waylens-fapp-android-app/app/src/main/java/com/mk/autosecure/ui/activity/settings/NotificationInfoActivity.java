package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.FleetVideoActivity.DURATION;
import static com.mk.autosecure.ui.activity.FleetVideoActivity.EVENT_TYPE;
import static com.mk.autosecure.ui.activity.FleetVideoActivity.LOCAL_VIDEO;
import static com.mk.autosecure.ui.activity.FleetVideoActivity.START_TIME;
import static com.mk.autosecure.ui.activity.FleetVideoActivity.VIDEO_URL;
import static com.mk.autosecure.ui.activity.settings.NotiManageActivity.LOAD_LIST_NOTI;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.bumptech.glide.Glide;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.FleetVideoActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.ui.adapter.CustomInfoWindowAdapter;
import com.mk.autosecure.viewmodels.NotificationViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

@SuppressLint("CheckResult")
@RequiresActivityViewModel(NotificationViewModel.ViewModel.class)
public class NotificationInfoActivity extends BaseActivity<NotificationViewModel.ViewModel> implements OnMapReadyCallback {

    public static final String TAG = NotificationInfoActivity.class.getSimpleName();
    public static final String NotiBean = "NotiBean";
    public static final String NotiId = "NotiId";
    public static final String CurrentAC = "currentActivity";
    //define category
    public static final String DMS = "DMS";
    public static final String DRIVER_MANAGEMENT = "DRIVER_MANAGEMENT";
    public static final String DRIVING_HIT = "DRIVING_HIT";
    public static final String HARD_ACCEL = "HARD_ACCEL";
    public static final String HARD_BRAKE = "HARD_BRAKE";
    public static final String SHARP_TURN = "SHARP_TURN";
    public static final String OVER_SPEED = "OVER_SPEED";
    public static final String FORWARD_COLLISION = "FORWARD_COLLISION";
    public static final String MANUAL = "MANUAL";
    public static final String PARKING_HIT = "PARKING_HIT";
    public static final String SYSTEM = "SYSTEM";
    public static final String IGNITION = "IGNITION";
    public static final String DRVN = "DRVN";
    public static final String ACCOUNT = "ACCOUNT";
    public static final String PAYMENT = "PAYMENT";
    public static final String ACCELERATOR = "ACCELERATOR";

    private GoogleMap mMap;

    //topbar

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    //layout

    @BindView(R.id.llCategory)
    LinearLayout llCategory;

    @BindView(R.id.llEventType)
    LinearLayout llEventType;

    @BindView(R.id.llEventTime)
    LinearLayout llEventTime;

    @BindView(R.id.llDriverName)
    LinearLayout llDriverName;

    @BindView(R.id.llFleetName)
    LinearLayout llFleetName;

    @BindView(R.id.llPlateNo)
    LinearLayout llPlateNo;

    @BindView(R.id.llEventLevel)
    LinearLayout llEventLevel;

    @BindView(R.id.llCameraSn)
    LinearLayout llCameraSn;

    @BindView(R.id.llAccountName)
    LinearLayout llAccountName;

    @BindView(R.id.llNote)
    LinearLayout llNote;

    @BindView(R.id.llOrderId)
    LinearLayout llOrderId;

    @BindView(R.id.llSubName)
    LinearLayout llSubName;

    @BindView(R.id.llAmount)
    LinearLayout llAmount;

    @BindView(R.id.llCurrency)
    LinearLayout llCurrency;

    @BindView(R.id.llSpeed)
    LinearLayout llSpeed;

    @BindView(R.id.llImageView)
    LinearLayout llImageView;
    @BindView(R.id.llBtnPlay)
    LinearLayout llBtnPlay;

    @BindView(R.id.llContentNoti)
    LinearLayout llContentNoti;

    //item

    @BindView(R.id.tvCategory)
    TextView tvCategory;

    @BindView(R.id.tvEventType)
    TextView tvEventType;

    @BindView(R.id.tvEventTime)
    TextView tvEventTime;

    @BindView(R.id.tvDriverName)
    TextView tvDriverName;

    @BindView(R.id.tvFleetName)
    TextView tvFleetName;

    @BindView(R.id.tvPlateNo)
    TextView tvPlateNo;

    @BindView(R.id.tvAmount)
    TextView tvAmount;

    @BindView(R.id.tvAccountName)
    TextView tvAccountName;

    @BindView(R.id.tvCurrency)
    TextView tvCurrency;

    @BindView(R.id.tvCameraSn)
    TextView tvCameraSn;

    @BindView(R.id.tvNote)
    TextView tvNote;

    @BindView(R.id.tv_note_title)
    TextView tvNoteType;

    @BindView(R.id.tvOrderId)
    TextView tvOrderId;

    @BindView(R.id.tvSubName)
    TextView tvSubName;

    @BindView(R.id.tvSpeed)
    TextView tvSpeed;

    @BindView(R.id.tvEventLevel)
    TextView tvEventLevel;

    @BindView(R.id.btnPlay)
    Button btnPlayVideo;

    @BindView(R.id.imgUrl)
    ImageView imgUrl;

    @BindView(R.id.rl_loading)
    RelativeLayout rlLoading;

    @BindView(R.id.llMapView)
    LinearLayout llMapView;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, NotificationInfoActivity.class);
//        intent.putExtra(NotiId,notiId);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, NotificationBean bean) {
        NotificationInfoActivity.bean = bean;
        Intent intent = new Intent(activity, NotificationInfoActivity.class);
        activity.startActivity(intent);
    }

    public static String notificationId = "";
    public static NotificationBean bean;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_noti_info);
        ButterKnife.bind(this);

        initToolbar();
        if (Constants.has_push_notification) {
            Constants.has_push_notification = false;
            viewModel.queryNotiInfo(notificationId);
        } else if (bean != null) {
            initView(bean);
        } else {
            Logger.t(TAG).d("response noti: " + bean + "notiId: " + notificationId);
            Toast.makeText(this, "Lỗi dữ liệu", Toast.LENGTH_SHORT).show();
        }

        initEvent();

        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        assert mapFragment != null;
        mapFragment.getMapAsync(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        bean = null;
        Constants.has_push_notification = false;
        notificationId = "";
        super.onDestroy();
    }

    private void enableButtonPlayVideo(boolean enable) {
        llBtnPlay.setVisibility(enable ? View.VISIBLE : View.GONE);
        btnPlayVideo.setEnabled(enable);
    }

    private void initEvent() {
        viewModel.notificationInfo()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNotificationInfo, new ServerErrorHandler(TAG));
        viewModel.outputs
                .showLoading()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> {
                    rlLoading.setVisibility(integer);
                    llContentNoti.setVisibility(integer == View.VISIBLE ? View.GONE : View.VISIBLE);
                }, new ServerErrorHandler());
        viewModel.phoneNoUpdated()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handlerUpdatePhoneNo, new ServerErrorHandler(TAG));
        viewModel.markRead()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleMarkRead, new ServerErrorHandler(TAG));
        viewModel.outputs.error()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleErrorResponse, new ServerErrorHandler(TAG));
    }

    private void handleErrorResponse(Response response) {
        NetworkErrorHelper.handleExpireToken(this, response);
    }

    private void handleMarkRead(Boolean optional) {
        Logger.t(TAG).d(optional ? "onMarkRead: true" : "onMarkRead: false");
    }


    private void handlerUpdatePhoneNo(boolean res) {
        Logger.t(TAG).d("updatePhoneNo: " + res);
        Toast.makeText(this, res ? "Cập nhật số điện thoại thành công" : "Cập nhật số điện thoại lỗi, vui lòng thử lại", Toast.LENGTH_SHORT).show();
    }

    private void handleNotificationInfo(NotificationBean bean) {
        initView(bean);
    }

    /**
     * init view with eventCategory
     */
    @SuppressLint("SetTextI18n")
    private void initView(NotificationBean bean) {
        if (bean != null) {
            if (!bean.getMarkRead()) runOnUiThread(() -> viewModel.markRead(bean.getId()));
            if (!StringUtils.isEmpty(bean.getUrl()) && !StringUtils.isEmpty(bean.getClipId())) {
                enableButtonPlayVideo(true);
            } else {
                enableButtonPlayVideo(false);
            }
            String eventTypeVN = VideoEventType.dealEventType(this, bean.getEventType());
            String categoryVN = VideoEventType.dealCategory(this, bean.getCategory());
            switch (bean.getCategory()) {
                case DMS:
                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    tvFleetName.setText(bean.getFleetName());
                    llDriverName.setVisibility(View.VISIBLE);
                    tvDriverName.setText(bean.getDriverName() + "-" + bean.getDriverId());
                    llPlateNo.setVisibility(View.VISIBLE);
                    tvPlateNo.setText(bean.getPlateNo());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    llSpeed.setVisibility(bean.getGpsSpeed() != null ? View.VISIBLE : View.GONE);
                    tvSpeed.setText(bean.getGpsSpeed().toString());
                    break;
                case DRIVER_MANAGEMENT:
                case MANUAL:
                case IGNITION:
                case DRVN:
                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    tvFleetName.setText(bean.getFleetName());
                    llDriverName.setVisibility(View.VISIBLE);
                    tvDriverName.setText(bean.getDriverName() + "-" + bean.getDriverId());
                    llPlateNo.setVisibility(View.VISIBLE);
                    tvPlateNo.setText(bean.getPlateNo());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    if (bean.getUrl() != null && bean.getClipId() == null) {
                        llImageView.setVisibility(View.VISIBLE);
                        Glide.with(this).load(bean.getUrl()).into(imgUrl);
                    }
                    break;
                case DRIVING_HIT:
                case HARD_ACCEL:
                case HARD_BRAKE:
                case SHARP_TURN:
                case OVER_SPEED:
                case FORWARD_COLLISION:
                case PARKING_HIT:
                case ACCELERATOR:

                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    llEventLevel.setVisibility(View.VISIBLE);
                    tvEventLevel.setText(bean.getEventLevel());
                    tvFleetName.setText(bean.getFleetName());
                    llDriverName.setVisibility(View.VISIBLE);
                    tvDriverName.setText(bean.getDriverName() + "-" + bean.getDriverId());
                    llPlateNo.setVisibility(View.VISIBLE);
                    tvPlateNo.setText(bean.getPlateNo());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    llMapView.setVisibility((bean.getGpsLatitude() != 0 && bean.getGpsLongitude() != 0) ? View.VISIBLE : View.GONE);
                    LatLng latLng = new LatLng(bean.getGpsLatitude(), bean.getGpsLongitude());
                    if (bean.getGpsLongitude() != 0 && bean.getUrl() != null && bean.getClipId() != null) {
                        CustomInfoWindowAdapter adapter = new CustomInfoWindowAdapter(NotificationInfoActivity.this);
                        mMap.setInfoWindowAdapter(adapter);
                        llBtnPlay.setVisibility(View.GONE);
                    } else if (bean.getGpsLongitude() == 0 && bean.getUrl() != null && bean.getClipId() != null) {
                        llBtnPlay.setVisibility(View.VISIBLE);
                    } else {
                        llBtnPlay.setVisibility(View.GONE);
                    }
                    mMap.addMarker(new MarkerOptions()
                            .anchor(0.5f, 0.5f)
                            .zIndex(2.0f)
                            .snippet(eventTypeVN)
                            .icon(BitmapDescriptorFactory.fromResource(VideoEventType.getEventIconResource(bean.getEventType(), true)))
                            .title(categoryVN)
                            .position(MapTransformUtil.gps84_To_Gcj02(latLng)));
                    mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
                    mMap.animateCamera(CameraUpdateFactory.zoomTo(17));
                    mMap.setOnInfoWindowClickListener(new GoogleMap.OnInfoWindowClickListener() {
                        @Override
                        public void onInfoWindowClick(@NonNull Marker marker) {
//                            Toast.makeText(NotificationInfoActivity.this,"onClick", Toast.LENGTH_SHORT).show();
                            playClip();
                        }
                    });
                    break;
                case SYSTEM:
                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    tvFleetName.setText(bean.getFleetName());
                    llDriverName.setVisibility(View.VISIBLE);
                    tvDriverName.setText(bean.getDriverName() + "-" + bean.getDriverId());
                    llPlateNo.setVisibility(View.VISIBLE);
                    tvPlateNo.setText(bean.getPlateNo());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    llCameraSn.setVisibility(View.VISIBLE);
                    tvCameraSn.setText(bean.getCameraSn());
                    break;
                case ACCOUNT:
                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    tvFleetName.setText(bean.getFleetName());
                    llDriverName.setVisibility(View.VISIBLE);
                    tvDriverName.setText(bean.getDriverName() + "-" + bean.getDriverId());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    llNote.setVisibility(View.GONE);
                    tvNote.setText("chưa có");
                    llCameraSn.setVisibility(!TextUtils.isEmpty(bean.getCameraSn()) ? View.VISIBLE : View.GONE);
                    tvCameraSn.setText(bean.getCameraSn());

                    if (bean.getEventType().equals("SIMCARDINFOCHANGED")) {
                        //show alert y/c update SIM number on FMS
//                        DialogUtils
                        if (!bean.isStatusUpdatePhone()) {
                            LayoutInflater factory = LayoutInflater.from(this);
                            final View view = factory.inflate(R.layout.dialog_update_sim_view, null);
                            TextView content = view.findViewById(R.id.contentAlert);
                            EditText etPhone = view.findViewById(R.id.etPhoneNo);
                            Button btnUpdate = view.findViewById(R.id.btnUpdatePhone);

                            etPhone.addTextChangedListener(new TextWatcher() {
                                @Override
                                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                                }

                                @Override
                                public void onTextChanged(CharSequence s, int start, int before, int count) {
                                    String phone = s.toString();
                                    if (StringUtils.isPhoneValid(phone)) {
                                        btnUpdate.setEnabled(true);
                                    } else {
                                        btnUpdate.setEnabled(false);
                                    }
                                }

                                @Override
                                public void afterTextChanged(Editable s) {

                                }
                            });

                            Button btnCancel = view.findViewById(R.id.btnCancel);
                            AlertDialog dialog = new AlertDialog.Builder(this)
                                    .setView(view)
                                    .setCancelable(false).create();

                            btnUpdate.setOnClickListener(v -> {
                                dialog.dismiss();
                                if (!TextUtils.isEmpty(etPhone.getText())) {
                                    // to do something
                                    viewModel.updatePhoneNo(etPhone.getText().toString(), bean.getCameraSn(), bean.getId());
                                } else {
                                    Toast.makeText(NotificationInfoActivity.this, getString(R.string.please_input_phone_no), Toast.LENGTH_SHORT).show();
                                }
                            });
                            btnCancel.setOnClickListener(v -> dialog.dismiss());
                            dialog.show();
                        }
                        tvNoteType.setText(R.string.status_update_phone_title);
                        llNote.setVisibility(View.VISIBLE);
                        tvNote.setText(bean.isStatusUpdatePhone() ? getString(R.string.phone_updated) : getString(R.string.phone_not_update));
                    }
                    break;
                case PAYMENT:
                    tvCategory.setText(categoryVN);
                    tvEventType.setText(eventTypeVN);
                    tvFleetName.setText(bean.getFleetName());
                    llAccountName.setVisibility(!StringUtils.isEmpty(bean.getAccountName()) ? View.VISIBLE : View.GONE);
                    tvAccountName.setText(bean.getAccountName());
                    llOrderId.setVisibility(!StringUtils.isEmpty(bean.getOrderId()) ? View.VISIBLE : View.GONE);
                    tvOrderId.setText(bean.getOrderId());
                    llSubName.setVisibility(!StringUtils.isEmpty(bean.getSubscriptionName()) ? View.VISIBLE : View.GONE);
                    tvSubName.setText(bean.getSubscriptionName());
                    llAmount.setVisibility(bean.getAmount() != 0 ? View.VISIBLE : View.GONE);
                    tvAmount.setText(String.valueOf(bean.getAmount()));
                    llCurrency.setVisibility(!StringUtils.isEmpty(bean.getCurrency()) ? View.VISIBLE : View.GONE);
                    tvCurrency.setText(bean.getCurrency());
                    tvEventTime.setText(convertEventTime(bean.getEventTime()));
                    llNote.setVisibility(bean.getErrorMsg() != null ? View.VISIBLE : View.GONE);
                    tvNote.setText(bean.getErrorMsg() != null ? bean.getErrorMsg() : "");
                    break;
            }
            llDriverName.setVisibility(TextUtils.isEmpty(bean.getDriverName()) ? View.GONE : View.VISIBLE);
        }
    }

    private String convertEventTime(String time) {
        if (!StringUtils.isEmpty(time)) {
            return time.replace("T", " ");
        } else {
            return time;
        }
    }

    private void initToolbar() {
        toolbar.setNavigationOnClickListener(v -> {
            Intent intent = new Intent(LOAD_LIST_NOTI);
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
            Constants.has_push_notification = false;
            finish();
        });
        tvToolbarTitle.setText(getResources().getText(R.string.noti_info));
    }

    @OnClick(R.id.btnPlay)
    public void playClip() {
        onPlayVideo(bean);
    }

    private void onPlayVideo(NotificationBean notificationBean) {
        ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                .withString(VIDEO_URL, notificationBean.getUrl())
                .withString(EVENT_TYPE, notificationBean.getEventType())
                .withString(START_TIME, notificationBean.getCreateTime())
                .withDouble(DURATION, notificationBean.getClipDuration())
                .withString(IntentKey.FLEET_CAMERA_ROTATE, "upsidedown")
                .withString(IntentKey.SERIAL_NUMBER, notificationBean.getCameraSn())
                .withDouble(IntentKey.GPS_LAT, notificationBean.getGpsLatitude())
                .withDouble(IntentKey.GPS_LONG, notificationBean.getGpsLongitude())
                .withBoolean(LOCAL_VIDEO, false)
                .navigation();
    }

    @Override
    public void onMapReady(@NonNull GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        mMap.getUiSettings().setZoomControlsEnabled(true);
        mMap.getUiSettings().setZoomGesturesEnabled(true);
        mMap.getUiSettings().setCompassEnabled(true);
    }

    @Override
    public void back() {
        super.back();
        Intent intent = new Intent(LOAD_LIST_NOTI);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        Constants.has_push_notification = false;
        finish();
    }
}
