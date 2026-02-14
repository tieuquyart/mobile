package com.mk.autosecure.ui.activity;


import static android.view.MotionEvent.ACTION_DOWN;
import static android.view.MotionEvent.ACTION_UP;
import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;
import static com.mk.autosecure.ui.activity.CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
import static com.mk.autosecure.ui.activity.CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_PLANE_FIT;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.PermissionChecker;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.IjkPlayerLogUtil;
import com.mk.autosecure.libs.utils.ImageBitmapUtils;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.MediaPlayerWrapper;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.LiveStatusResponse;
import com.mk.autosecure.rest.request.LiveStreamBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.FleetApiClient;
import com.mk.autosecure.rest_fleet.bean.FleetViewRecord;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.mk.autosecure.viewmodels.FleetLiveViewModel;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.DateTime;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;
import com.waylens.vrlib.model.MDPinchConfig;

import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTouch;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;
import io.reactivex.schedulers.Schedulers;
import tv.danmaku.ijk.media.player.IMediaPlayer;


/**
 * Created by DoanVT on 2017/8/2.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint({"CheckResult","NonConstantResourceId","SimpleDateFormat"})
@Route(path = "/ui/activity/FleetLiveActivity")
@RequiresActivityViewModel(FleetLiveViewModel.ViewModel.class)
public class FleetLiveActivity extends BaseActivity<FleetLiveViewModel.ViewModel> implements OnMapReadyCallback {

    private static final String TAG = FleetLiveActivity.class.getSimpleName();

    public static final int PERMISSION_AUDIO_REQUESTCODE = 11;

    private String serialNumber;

    private String rotate;

    private boolean needDewarp = true;

    private boolean isIsOnline = false;

    private double rsrp;

    private MediaPlayerWrapper mMediaPlayerWrapper;

    private boolean isForeground = true;

    private ControlPanelHandler mHandler;

    private FleetApiClient mApiClient;

    private Disposable pollLiveStatusSub = new CompositeDisposable();

    private Disposable pollLiveBPSSub = new CompositeDisposable();

    private Disposable pollLiveTimeSub = new CompositeDisposable();

    private int mXRadio;
    private int mYRadio;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.iv_curStatus)
    ImageView iv_curStatus;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.tv_hours)
    TextView tvHours;

    @BindView(R.id.tv_events)
    TextView tvEvents;

    @BindView(R.id.tv_miles)
    TextView tvMiles;

    @BindView(R.id.tvSpeed)
    TextView tvSpeed;

    @BindView(R.id.llSpeedReal)
    RelativeLayout llSpeedReal;

    @BindView(R.id.iv_camera_status)
    ImageView ivCameraStatus;

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.include_fleet_live)
    RelativeLayout includeFleetLive;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.progress)
    ProgressBar progressBar;

    @BindView(R.id.tv_liveStatus)
    TextView tv_liveStatus;

    @BindView(R.id.ib_startPlay)
    ImageButton ibStartPlay;

    @BindView(R.id.tv_offline_tips)
    TextView tv_offline_tips;

    @BindView(R.id.ll_videoSrc)
    LinearLayout ll_videoSrc;

    @BindView(R.id.iv_videoSrc)
    ImageView iv_videoSrc;

    @BindView(R.id.tv_videoSrc)
    TextView tv_videoSrc;

    @BindView(R.id.rl_videoProgress)
    RelativeLayout rl_videoProgress;

    @BindView(R.id.tv_playProgress)
    TextView tvVideoProgress;

    @BindView(R.id.tv_duration)
    TextView tvVideoDuration;

    @BindView(R.id.sb_video)
    SeekBar sbVideo;

    @BindView(R.id.rl_control_portrait)
    RelativeLayout rlControlPortrait;

    @BindView(R.id.rl_control_landscape)
    RelativeLayout rlControlLandscape;

    @BindView(R.id.ib_projection_port)
    ImageButton ib_projection_port;

    @BindView(R.id.ib_projection_land)
    ImageButton ib_projection_land;

    @BindView(R.id.ib_stopPlay_port)
    ImageButton ib_stopPlay_port;

    @BindView(R.id.ib_stopPlay_land)
    ImageButton ib_stopPlay_land;

    @BindView(R.id.tv_bps_port)
    TextView tv_bps_port;

    @BindView(R.id.tv_bps_land)
    TextView tv_bps_land;

    @BindView(R.id.tvStartTime)
    TextView tvStartTime;

    FleetViewRecord fleetViewRecord;

    GoogleMap mMap;
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

    double gpsLat, gpsLng;

    @OnClick({R.id.ib_fullScreen_port, R.id.ib_fullScreen_land})
    public void onBtnFullscreenClicked() {
        if (!isFullScreen()) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            showControlPanel();
        } else {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    @OnClick(R.id.ib_startPlay)
    public void startPlay() {
        if (mMediaPlayerWrapper != null) {
            if (!mMediaPlayerWrapper.getPlayer().isPlaying()) {
                if (viewModel.isLiveOrNot) {
                    Logger.t(TAG).e("status: " + mMediaPlayerWrapper.getStatus());
                    if (progressBar.getVisibility() != View.VISIBLE) {
                        busy();
                        togglePlayState(false);
                        startLive();
                    }
                } else {
                    Logger.t(TAG).e("isStop");
                    if (progressBar.getVisibility() != View.VISIBLE) {
                        togglePlayState(false);
                        mMediaPlayerWrapper.resume();
                    }
                }
            }
        }
    }

    @OnClick({R.id.ib_stopPlay_port, R.id.ib_stopPlay_land})
    public void stopPlay() {
        if (mMediaPlayerWrapper != null) {
            if (mMediaPlayerWrapper.getPlayer().isPlaying()) {
                Logger.t(TAG).d("isPlaying");
                cancelBusy();
                togglePlayState(true);
                mMediaPlayerWrapper.pause();

                if (viewModel.isLiveOrNot) {
                    Logger.t(TAG).d("isLiveOrNot");
                    stopLive();
                }
            } else if (viewModel.isLiveOrNot) {
                Logger.t(TAG).e("status: " + mMediaPlayerWrapper.getStatus());
                if (progressBar.getVisibility() == View.VISIBLE) {
                    cancelBusy();
                    togglePlayState(true);
                    stopLive();
                }
            } else {
                Logger.t(TAG).e("isStop");
                if (progressBar.getVisibility() == View.VISIBLE) {
                    cancelBusy();
                    togglePlayState(true);
                    mMediaPlayerWrapper.pause();
                }
            }
        }
    }

    @OnClick(R.id.gl_live)
    public void onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked");
        if (ibStartPlay.getVisibility() == View.VISIBLE) {
            return;
        }

        if (rlControlPortrait.getVisibility() != View.VISIBLE
                && rlControlLandscape.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else {
            hideControlPanel();
        }
    }

    @OnClick({R.id.ib_projection_port, R.id.ib_projection_land})
    public void onProjectionSwitch() {
        int projectionMode = mLiveLibrary.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode);
        int switchMode = -1;

        if (projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS
                || projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
            mLiveLibrary.setPinchEnabled(true);
            switchMode = projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS ?
                    PROJECTION_MODE_DOME230_UPPER : PROJECTION_MODE_DOME_UPPER_DOWN;

            ib_projection_land.setBackgroundResource(R.drawable.bg_front_back_selector);
            ib_projection_port.setBackgroundResource(R.drawable.bg_front_back_selector);

        } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER
                || projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
            mLiveLibrary.setPinchEnabled(false);
            switchMode = projectionMode == PROJECTION_MODE_DOME230_UPPER ?
                    CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;

            ib_projection_land.setBackgroundResource(R.drawable.bg_panorama_selector);
            ib_projection_port.setBackgroundResource(R.drawable.bg_panorama_selector);
        }

        if (switchMode != -1) {
            mLiveLibrary.switchProjectionMode(FleetLiveActivity.this, switchMode);
        }
    }

    @SuppressLint("CheckResult")
    @OnClick(R.id.iv_call_phone)
    public void callPhone() {
        Logger.t(TAG).d("callPhone: " + serialNumber);

        FleetCameraBean fleetCameraBean = viewModel.getFleetInfo().queryDevice(serialNumber);
        if (fleetCameraBean != null) {

//            DriverInfoBean driverInfoBean = viewModel.getFleetInfo().queryDriver(Integer.getInteger(fleetCameraBean.get()));
//            if (driverInfoBean != null) {

            String phoneNumber = fleetCameraBean.getPhone();
            Logger.t(TAG).d("phoneNumber: " + phoneNumber);

            if (TextUtils.isEmpty(phoneNumber)) {
                Toast.makeText(this, "No Phone Number", Toast.LENGTH_SHORT).show();
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
//        }
    }

//    @OnTouch({R.id.btn_talkback, R.id.btn_talkback_4k})
//    public boolean onTalkback(MotionEvent event) {
//        //check audio permission
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PermissionChecker.PERMISSION_GRANTED) {
//                requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, PERMISSION_AUDIO_REQUESTCODE);
//            } else {
//                onAudioControl(event);
//            }
//        } else {
//            onAudioControl(event);
//        }
//        return true;
//    }

    private void onAudioControl(MotionEvent event) {
        int action = event.getAction();
        if (action == ACTION_DOWN) {
            viewModel.isAudioPush = true;
            mMediaPlayerWrapper.setVolume(0f);
            Logger.t(TAG).d("onAudioControl startAudio");
            viewModel.inputs.startAudio();
        } else if (action == ACTION_UP) {
            viewModel.isAudioPush = false;
            mMediaPlayerWrapper.setVolume(1f);
            Logger.t(TAG).d("onAudioControl endAudio");
            viewModel.inputs.endAudio(false);
        }
    }

    private boolean isFullScreen() {
        int orientation = this.getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    private MDVRLibrary mLiveLibrary;

    @SuppressLint("SetTextI18n")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fleet_live);
        ButterKnife.bind(this);

        setupToolbar();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        assert mapFragment != null;
        mapFragment.getMapAsync(this);

        Action mControlPanelAction = () -> {
            if (FleetLiveActivity.this.isFullScreen()) {
                FleetLiveActivity.this.hideControlPanel();
                FleetLiveActivity.this.setImmersiveMode(true);
            }
        };

        mHandler = new ControlPanelHandler(mControlPanelAction);

        setupSeekbar();

        serialNumber = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        String driverName = getIntent().getStringExtra(IntentKey.FLEET_DRIVER_NAME);
        String plateNumber = getIntent().getStringExtra(IntentKey.FLEET_PLATE_NUMBER);
        String cameraStatus = getIntent().getStringExtra(IntentKey.FLEET_CAMERA_STATUS);
        isIsOnline = getIntent().getBooleanExtra(IntentKey.FLEET_ONLINE, false);
        rsrp = getIntent().getDoubleExtra(IntentKey.FLEET_RSRP, 0.0);
        rotate = getIntent().getStringExtra(IntentKey.FLEET_CAMERA_ROTATE);
        needDewarp = getIntent().getBooleanExtra(IntentKey.FLEET_NEED_DEWARP, true);
        fleetViewRecord = (FleetViewRecord) getIntent().getSerializableExtra(IntentKey.FLEET_RECORD);

        if (fleetViewRecord != null) {
            DecimalFormat decimalFormat = new DecimalFormat("0.00");
            DecimalFormat decimalFormat2 = new DecimalFormat("0.0");
            tvMiles.setText(fleetViewRecord.miles > 0 ? decimalFormat.format((float) fleetViewRecord.miles / 1000) + " km" : decimalFormat2.format((float) fleetViewRecord.miles) + " km"); //1609.3f
            tvHours.setText(fleetViewRecord.hours > 0 ? decimalFormat.format((float) fleetViewRecord.hours) + " h" : decimalFormat2.format((float) fleetViewRecord.hours) + " h");
            tvEvents.setText(String.valueOf(fleetViewRecord.events));
            if (fleetViewRecord.gpsData != null) {
                String speed = fleetViewRecord.gpsData.speed > 0 ? decimalFormat.format((float) fleetViewRecord.gpsData.speed) + " km/h" : decimalFormat2.format((float) fleetViewRecord.gpsData.speed) + " km/h";
                tvSpeed.setText(speed);
                gpsLat = fleetViewRecord.gpsData.coordinate.get(1);
                gpsLng = fleetViewRecord.gpsData.coordinate.get(0);
                tvStartTime.setText(fleetViewRecord.gpsData.time.replace("T", " "));
            } else {
                tvSpeed.setText("0,0 km/h");
                tvSpeed.setVisibility(View.GONE);
                llSpeedReal.setVisibility(View.GONE);
                gpsLat = gpsLng = 0;
            }
        }

        viewModel.setSerialNumber(serialNumber);
        tvDriverName.setText(driverName);
        tvPlateNumber.setText(plateNumber);
        if ("offline".equals(cameraStatus)) {
            ivCameraStatus.setImageResource(R.drawable.icon_offline_mode);
        } else if ("parking".equals(cameraStatus)) {
            ivCameraStatus.setImageResource(R.drawable.ic_parking_map);
        } else {
            ivCameraStatus.setImageResource(R.drawable.ic_driving_map);
        }

        adaptationFor4K();

        mLiveLibrary = createLiveLibrary();

        //初始化网络请求
        if (Constants.isFleet()) {
            mApiClient = ApiClient.createApiService();
        }

        mMediaPlayerWrapper = new MediaPlayerWrapper(true);

        initVideoView();
    }

    private void adaptationFor4K() {
        if (TextUtils.isEmpty(serialNumber)) {
            return;
        }

        boolean startsWith6 = serialNumber.startsWith("6");
        if (startsWith6) {
            mXRadio = 32;
            mYRadio = 27;
        } else {
            mXRadio = 16;
            mYRadio = 9;
        }
        mMediaWindow.setRatio(mXRadio, mYRadio);

        boolean startsWith2 = serialNumber.startsWith("2");
        ib_projection_port.setVisibility(startsWith2 ? View.VISIBLE : View.INVISIBLE);
        ib_projection_land.setVisibility(startsWith2 ? View.VISIBLE : View.INVISIBLE);
    }

    private void initVideoView() {
        FleetCameraBean fleetCamera = viewModel.getCurrentUser().getFleetCamera(serialNumber);
        if (fleetCamera != null) {

//            if (isIsOnline) {
                viewModel.inputs.queryLiveSignal(fleetCamera.getSn(), rsrp);
                ibStartPlay.setVisibility(View.VISIBLE);
                tv_offline_tips.setVisibility(View.GONE);
//            } else {
//                iv_curStatus.setImageResource(R.drawable.icon_offline);
//                iv_videoSrc.setImageResource(R.drawable.icon_offline);
//                ibStartPlay.setVisibility(View.GONE);
//                tv_offline_tips.setVisibility(View.VISIBLE);
//            }
            tv_toolbarTitle.setText(getString(R.string.go_live));
            tv_videoSrc.setText(getString(R.string.go_live));
        }
    }

    private void setupSeekbar() {
        sbVideo.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                int progress = seekBar.getProgress();

                if (mMediaPlayerWrapper != null) {
                    try {
                        mMediaPlayerWrapper.pause();
                        mMediaPlayerWrapper.getPlayer().seekTo(progress);
                        mMediaPlayerWrapper.getPlayer().setOnSeekCompleteListener(IMediaPlayer::start);
                    } catch (Exception ex) {
                        Logger.t(TAG).e("onStopTrackingTouch error = " + ex.getMessage());
                    }
                }
            }
        });
    }

    private void apiError(ErrorEnvelope error) {
        Toast.makeText(this, error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void networkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(this, throwable);
    }

    @SuppressLint("CheckResult")
    private void intervalCheck() {
        Observable.interval(0, 500, TimeUnit.MILLISECONDS)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::checkProgress, throwable -> {
                    //这里在每次播放到最顶端时候 会报错null  原因不明 目前重新拉起
                    Logger.t(TAG).e("checkProgress throwable: " + throwable.getMessage());
                    intervalCheck();
                });
    }

    private void checkProgress(long along) {
        if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer() != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {
            if (!viewModel.isLiveOrNot) {
                long currentPos = mMediaPlayerWrapper.getPlayer().getCurrentPosition();
                long duration = mMediaPlayerWrapper.getPlayer().getDuration();

                if (duration > 0 && isFullScreen()) {
                    tvVideoProgress.setText(DateUtils.formatElapsedTime(currentPos / 1000));
                    tvVideoDuration.setText(DateUtils.formatElapsedTime(duration / 1000));
                    sbVideo.setProgress((int) currentPos);
                    sbVideo.setMax((int) duration);
                }
            }
        }
    }

    private void switchProjection(boolean lensMode) {
        int projectionMode = mLiveLibrary.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode + " lensMode: " + lensMode);

        int switchMode = -1;
        if (needDewarp) {
            if (lensMode) {
                if (projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                    switchMode = CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
                } else if (projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
                    switchMode = PROJECTION_MODE_DOME230_UPPER;
                }
            } else {
                if (projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS) {
                    switchMode = CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
                } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER) {
                    switchMode = PROJECTION_MODE_DOME_UPPER_DOWN;
                }
            }
        } else {
            switchMode = PROJECTION_MODE_PLANE_FIT;
        }

        if (switchMode != -1) {
            mLiveLibrary.switchProjectionMode(FleetLiveActivity.this, switchMode);
        }
    }

    @SuppressLint("CheckResult")
    private void stopLive() {
        Logger.t(TAG).d("stopLive");
        unsubscribeLiveStatus();
        unsubscribeBPS();
        unsubscribeLiveTime();

        Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                    if (mMediaPlayerWrapper != null) {
                        mMediaPlayerWrapper.destroy();
                        mMediaPlayerWrapper = null;
                    }
                    emitter.onNext(Optional.empty());
                })
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(aVoid -> {
                    mMediaPlayerWrapper = new MediaPlayerWrapper(true);
//                    stopLiveStream();
                }, new ServerErrorHandler(TAG));
    }

    private void stopLiveStream() {
        LiveStreamBody streamBody = new LiveStreamBody();
        streamBody.action = "stop";
        if (mApiClient != null) {
//            mApiClient.controlStream(serialNumber, streamBody)
//                    .subscribeOn(Schedulers.io())
//                    .subscribe();
        }
    }

    private void onStopLiveResponse(LiveStatusResponse response) {
        Logger.t(TAG).d("onStopLiveResponse：%s", ToStringUtils.getString(response));
    }

    @SuppressLint("CheckResult")
    private void startLive() {
        if (mApiClient != null) {
            mApiClient.startLive(serialNumber, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::onStartLiveResponse, this::handleLiveError);
        }
    }

    private void handleLiveError(Throwable throwable) {
        Logger.t(TAG).d("handleLiveError:" + throwable.getMessage());
        NetworkErrorHelper.handleCommonError(this, throwable);
        cancelStartLive();
    }

    private void cancelStartLive() {
        cancelBusy();
        togglePlayState(true);
        unsubscribeLiveStatus();
    }

    private void onStartLiveResponse(LiveStatusResponse response) {
        Logger.t(TAG).d("onStartLiveResponse：%s", ToStringUtils.getString(response));
        startQueryLiveStatus();
    }

    private void startQueryLiveStatus() {
        pollLiveStatusSub = Observable.interval(0, 1500, TimeUnit.MILLISECONDS)
                .take(120)
                .subscribeOn(Schedulers.io())
                .doOnDispose(() -> {
                    tv_liveStatus.setVisibility(View.GONE);
                    tv_liveStatus.setText("");
                })
                .compose(bindToLifecycle())
                .subscribe(aLong -> {
                    if (aLong == 119) {
                        queryLiveStatus(true);
                    } else {
                        queryLiveStatus(false);
                    }
                }, new ServerErrorHandler(TAG));
    }

    private void queryLiveStatus(boolean end) {
        Observable<LiveStatusResponse> liveStatus;
        liveStatus = mApiClient.getLiveStatus(serialNumber, HornApplication.getComponent().currentUser().getAccessToken());
        liveStatus
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doOnError(throwable -> {
                    cancelBusy();
                    togglePlayState(true);

                    unsubscribeLiveStatus();
                })
                .doFinally(() -> {
                    Logger.t(TAG).d("queryLiveStatus: " + end);
                    if (pollLiveStatusSub != null && pollLiveStatusSub.isDisposed()) {
                        tv_liveStatus.setVisibility(View.GONE);
                        tv_liveStatus.setText("");
                    }

                    if (end) {
                        cancelBusy();
                        togglePlayState(true);

                        unsubscribeLiveStatus();

                        tv_liveStatus.setVisibility(View.GONE);
                        tv_liveStatus.setText("");
                        Toast.makeText(FleetLiveActivity.this, R.string.play_error, Toast.LENGTH_SHORT).show();
                    }
                })
                .subscribe(new BaseObserver<LiveStatusResponse>() {
                    @Override
                    protected void onHandleSuccess(LiveStatusResponse data) {
                        onLiveStatus(data);
                    }
                });
    }

    private void onLiveStatus(LiveStatusResponse response) {
        Logger.t(TAG).d("onLiveStatus: %s", response.data.status.toString());
        switch (response.data.status) {
            case LiveStatusResponse.WAIT_PUBLISH_STATE:
                tv_liveStatus.setVisibility(View.VISIBLE);
                tv_liveStatus.setText(R.string.live_status_publish);
                break;
            case LiveStatusResponse.WAIT_AWAKE_STATE:
                tv_liveStatus.setVisibility(View.VISIBLE);
                tv_liveStatus.setText(R.string.live_status_awake);
                break;
            case LiveStatusResponse.OFFLINE_STATE:
                tv_liveStatus.setVisibility(View.VISIBLE);
                tv_liveStatus.setText(R.string.live_status_offline);
                break;
            case LiveStatusResponse.LIVE_STATE:
                unsubscribeLiveStatus();
                tv_liveStatus.setVisibility(View.GONE);
                tv_liveStatus.setText("");
                viewModel.isLiveOrNot(true);

                boolean lensMode = TextUtils.isEmpty(rotate) || LENS_NORMAL.equals(rotate);
                switchProjection(lensMode);

                retryOpen(response.data.playUrl, false);
                break;
            default:
                break;
        }
    }

    private void startUpdateLiveTime() {
        pollLiveTimeSub = Observable.interval(0, 1, TimeUnit.SECONDS)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .subscribe(aLong -> {
                    long time = System.currentTimeMillis();
                    viewModel.inputs.updateLiveTime(time);
                }, new ServerErrorHandler());
    }

    private void startQueryLiveBPS() {
        tv_bps_port.setVisibility(View.VISIBLE);
        tv_bps_land.setVisibility(View.VISIBLE);
        pollLiveBPSSub = Observable.interval(0, 3, TimeUnit.SECONDS)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .subscribe(aLong -> {
                    if (Constants.isFleet()) {
                        viewModel.inputs.queryLiveBPS(serialNumber);
                    }
                }, new ServerErrorHandler(TAG));
    }

    private void onLiveBPS(int bps) {
        // TODO: 2019-09-04 bps 单位 fleet or 360
        bps = bps / 8000;
        tv_bps_port.setText(String.format(Locale.getDefault(), "%dk/s", bps));
        tv_bps_land.setText(String.format(Locale.getDefault(), "%dk/s", bps));
    }

    private void onLiveSignal(float rsrp) {
        int resource;
        if (rsrp < -112) {
            resource = R.drawable.icon_4gsignal_1;
        } else if (rsrp < -105) {
            resource = R.drawable.icon_4gsignal_1;
        } else if (rsrp < -96) {
            resource = R.drawable.icon_4gsignal_2;
        } else if (rsrp < -88) {
            resource = R.drawable.icon_4gsignal_3;
        } else {
            resource = R.drawable.icon_4gsignal_4;
        }
        iv_curStatus.setImageDrawable(getResources().getDrawable(resource));
        iv_videoSrc.setImageDrawable(getResources().getDrawable(resource));
    }

    private void initLivePlayer() {
        mMediaPlayerWrapper.init();

        mMediaPlayerWrapper.setPreparedListener(mp -> {
            Logger.t(TAG).d("onPrepared: " + viewModel.isLiveOrNot);
            cancelBusy();
            togglePlayState(false);
            if (!isForeground) {
                mp.pause();
            }
            if (viewModel.isLiveOrNot) {

                intervalCheck();
                startQueryLiveBPS();
                startUpdateLiveTime();
            }
            if (getLiveLibrary() != null) {
                getLiveLibrary().notifyPlayerChanged();
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnErrorListener((mp, what, extra) -> {
            Logger.t(TAG).e("onError what: " + what + " extra: " + extra);
            cancelBusy();
            togglePlayState(true);
            stopLive();
            String error = String.format(Locale.getDefault(), "Play error: " + extra);
            Toast.makeText(FleetLiveActivity.this, error, Toast.LENGTH_SHORT).show();
            return true;
        });

        mMediaPlayerWrapper.getPlayer().setOnInfoListener((iMediaPlayer, what, extra) -> {
            switch (what) {
                case IMediaPlayer.MEDIA_INFO_BUFFERING_START:
                    busy();
                    break;
                case IMediaPlayer.MEDIA_INFO_BUFFERING_END:
                    cancelBusy();
                    break;
                case IMediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH:

                    break;
                case IMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
                    cancelBusy();
                    break;
                default:
                    break;
            }
            return false;
        });

        mMediaPlayerWrapper.getPlayer().setOnVideoSizeChangedListener((mp, width, height, sar_num, sar_den) ->
                getLiveLibrary().onTextureResize(width, height));

        mMediaPlayerWrapper.getPlayer().setOnCompletionListener(iMediaPlayer ->
                onVideoCompletion(iMediaPlayer.getDuration()));
    }

    private void onVideoCompletion(long duration) {
        Logger.t(TAG).e("onVideoCompletion");
        if (viewModel.isLiveOrNot) {
            //直播最多两分钟会断掉，属于正常回调
            cancelBusy();
            togglePlayState(true);
            stopLive();
//            String error = String.format(Locale.getDefault(), "Play over");
//            Toast.makeText(LiveViewActivity.this, error, Toast.LENGTH_SHORT).show();
            return;
        }
        if (isFullScreen()) {
            return;
        }
    }

    @SuppressLint("CheckResult")
    private void retryOpen(String url, boolean cookie) {
        if (!TextUtils.isEmpty(url)) {
            Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                        if (mMediaPlayerWrapper != null) {
                            mMediaPlayerWrapper.destroy();
                            mMediaPlayerWrapper = null;
                        }
                        emitter.onNext(Optional.empty());
                    })
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(aVoid -> {
                        mMediaPlayerWrapper = new MediaPlayerWrapper(!cookie);
                        initLivePlayer();
                        if (cookie) {
                            mMediaPlayerWrapper.openRemoteFileWithCookie(url);
                        } else {
                            mMediaPlayerWrapper.openRemoteFile(url);
                        }
                        mMediaPlayerWrapper.prepare();
                    }, new ServerErrorHandler(TAG));
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.stop();
        }
//        if (mCameraBean != null) {
//            viewModel.stopStreaming();
//        }
        this.viewModel.stopHeartbeat();
    }

    public void setImmersiveMode(boolean immersiveMode) {
        if (immersiveMode) {
            getWindow().getDecorView().setSystemUiVisibility(FULL_SCREEN_FLAG);
        } else {
            getWindow().getDecorView().setSystemUiVisibility(0);
        }
    }


    public MDVRLibrary getLiveLibrary() {
        return mLiveLibrary;
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        initEvents();
        mLiveLibrary.onResume(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.resume();
        }
    }

    @SuppressLint("CheckResult")
    private void initEvents() {
        viewModel.outputs.liveSignal()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLiveSignal, new ServerErrorHandler(TAG));

        viewModel.outputs.liveBPS()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLiveBPS, new ServerErrorHandler(TAG));

        viewModel.errors.apiError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::apiError, new ServerErrorHandler(TAG));

        viewModel.errors.networkError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::networkError, new ServerErrorHandler(TAG));
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        checkAudioControl();

        mLiveLibrary.onPause(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.pause();
        }
        if (viewModel.isLiveOrNot) {
//            stopLiveStream();
        }
    }

    private void checkAudioControl() {
        if (viewModel.isAudioPush) {
            viewModel.isAudioPush = false;
            mMediaPlayerWrapper.setVolume(1f);
            viewModel.inputs.endAudio(false);
        }
    }

    @Override
    protected void onDestroy() {
        IjkPlayerLogUtil.logIJKMEDIA();

        super.onDestroy();
        if (mLiveLibrary != null) {
            mLiveLibrary.onDestroy();
        }

        destroyWrapper();
    }

    private void destroyWrapper() {
        // for ANR in hotspot mode
        new Thread(() -> {
            if (mMediaPlayerWrapper != null) {
                mMediaPlayerWrapper.destroy();
                mMediaPlayerWrapper = null;
            }
        }).start();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_AUDIO_REQUESTCODE) {
            if (grantResults.length > 0 && grantResults[0] == PermissionChecker.PERMISSION_GRANTED) {
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(this,
                                () -> {
                                    PermissionUtil.startAppSetting(FleetLiveActivity.this);
                                },
                                () -> {
                                });
                    } else {
                        Toast.makeText(this, getResources().getString(R.string.audio_must_allow), Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mLiveLibrary.onOrientationChanged(this);

        if (isFullScreen()) {
            toolbar.setVisibility(View.GONE);
            includeFleetLive.setVisibility(View.GONE);
            rlControlPortrait.setVisibility(View.GONE);
            ll_videoSrc.setVisibility(View.VISIBLE);
            rlControlLandscape.setVisibility(View.VISIBLE);

            Display defaultDisplay = getWindowManager().getDefaultDisplay();
            int totalWidth = defaultDisplay.getWidth();
            int totalHeight = defaultDisplay.getHeight();
            if (totalWidth * mYRadio > totalHeight * mXRadio) {
                mMediaWindow.post(() -> {
                    int width = mMediaWindow.getWidth();
                    int shadowWidth = (width - totalHeight * mXRadio / mYRadio) / 2;

                    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                            totalHeight * mXRadio / mYRadio, totalHeight);
                    layoutParams.setMargins(shadowWidth, 0, shadowWidth, 0);
                    mMediaWindow.setLayoutParams(layoutParams);
                });
            }
        } else {
            toolbar.setVisibility(View.VISIBLE);
            includeFleetLive.setVisibility(View.VISIBLE);
            rlControlPortrait.setVisibility(View.VISIBLE);
            ll_videoSrc.setVisibility(View.GONE);
            rlControlLandscape.setVisibility(View.GONE);

            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            mMediaWindow.setLayoutParams(params);
        }

        if (isFullScreen() && !viewModel.isLiveOrNot) {
            rl_videoProgress.setVisibility(View.VISIBLE);
        } else {
            rl_videoProgress.setVisibility(View.INVISIBLE);
        }

        setImmersiveMode(isFullScreen());
    }

    public void cancelBusy() {
        progressBar.setVisibility(View.GONE);
    }

    public void busy() {
        progressBar.setVisibility(View.VISIBLE);
    }

    private void togglePlayState(boolean toPlay) {
        if (toPlay) {
            ibStartPlay.setVisibility(View.VISIBLE);
            ib_stopPlay_port.setVisibility(View.GONE);
            ib_stopPlay_land.setVisibility(View.INVISIBLE);
            rlControlPortrait.setVisibility(View.GONE);
        } else {
            ibStartPlay.setVisibility(View.GONE);
            ib_stopPlay_port.setVisibility(View.VISIBLE);
            ib_stopPlay_land.setVisibility(View.VISIBLE);
        }
    }

    protected MDVRLibrary createLiveLibrary() {
        int projectionMode;

        if (needDewarp) {
            boolean lensMode = TextUtils.isEmpty(rotate) || LENS_NORMAL.equals(rotate);
            Logger.t(TAG).d("lensMode: " + lensMode);
            projectionMode = lensMode ?
                    CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
        } else {
            projectionMode = PROJECTION_MODE_PLANE_FIT;
        }

        Logger.t(TAG).d("projectionMode: " + projectionMode);

        return MDVRLibrary.with(this)
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asVideo(surface -> {
                    Logger.t(TAG).d("onSurfaceReady: " + surface);
                    if (mMediaPlayerWrapper != null) {
                        mMediaPlayerWrapper.setSurface(surface);
                    }
                })
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + mode;
                    Toast.makeText(FleetLiveActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(projectionMode)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) findViewById(R.id.gl_live));
    }

    private void hideControlPanel() {
        Logger.t(TAG).d("hide ControlPanel");
        if (isFullScreen()) {
            ll_videoSrc.setVisibility(View.GONE);
            rlControlLandscape.setVisibility(View.GONE);
        } else {
            rlControlPortrait.setVisibility(View.GONE);
        }
    }

    private void showControlPanel() {
        Logger.t(TAG).d("show ControlPanel");
        if (isFullScreen()) {
            ll_videoSrc.setVisibility(View.VISIBLE);
            rlControlLandscape.setVisibility(View.VISIBLE);
        } else {
            rlControlPortrait.setVisibility(View.VISIBLE);
        }

        mHandler.removeMessages(ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(ControlPanelHandler.FADE_OUT), 5000);
    }

    public void setupToolbar() {
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> finish());
        }
    }

    private void unsubscribeBPS() {
        tv_bps_port.setVisibility(View.GONE);
        tv_bps_land.setVisibility(View.GONE);
        tv_bps_port.setText("");
        tv_bps_land.setText("");

        if (pollLiveBPSSub != null && !pollLiveBPSSub.isDisposed()) {
            pollLiveBPSSub.dispose();
        }
    }

    private void unsubscribeLiveTime() {
        if (pollLiveTimeSub != null && !pollLiveTimeSub.isDisposed()) {
            pollLiveTimeSub.dispose();
        }
    }

    private void unsubscribeLiveStatus() {
        tv_liveStatus.setVisibility(View.GONE);
        tv_liveStatus.setText("");

        if (pollLiveStatusSub != null && !pollLiveStatusSub.isDisposed()) {
            pollLiveStatusSub.dispose();
        }
    }

    @Override
    public void onMapReady(@NonNull GoogleMap googleMap) {

        mMap = googleMap;
        mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        mMap.getUiSettings().setZoomControlsEnabled(true);
        mMap.getUiSettings().setZoomGesturesEnabled(true);
        mMap.getUiSettings().setCompassEnabled(true);

        LatLng latLng = new LatLng(gpsLat, gpsLng);
        mMap.addMarker(new MarkerOptions()
                .anchor(0.5f, 0.5f)
                .zIndex(2.0f)
                .snippet(fleetViewRecord.driverName)
                .icon(ImageBitmapUtils.vectorToBitmap(VideoEventType.getModeIconResourceVector(fleetViewRecord.mode), this))
                .title(fleetViewRecord.plateNo)
                .position(MapTransformUtil.gps84_To_Gcj02(latLng)));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
        mMap.animateCamera(CameraUpdateFactory.zoomTo(17));
    }
}