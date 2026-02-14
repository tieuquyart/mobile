package com.mk.autosecure.ui.activity;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.Display;
import android.view.Gravity;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.video.VideoListener;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.ui.activity.settings.NotificationInfoActivity;
import com.mk.autosecure.ui.adapter.CustomInfoWindowAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.network_adapter.exo_adapter.CustomHttpDataSourceFactory;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;
import com.waylens.vrlib.model.MDPinchConfig;

import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;

import static com.mk.autosecure.ui.activity.settings.NotiManageActivity.LOAD_LIST_NOTI;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_PLANE_FIT;

/**
 * Created by DoanVT on 2017/8/2.
 */
@Route(path = "/ui/activity/FleetVideoActivity")
public class FleetVideoActivity extends RxFragmentActivity implements OnMapReadyCallback {

    private static final String TAG = FleetVideoActivity.class.getSimpleName();

    public static final String VIDEO_URL = "video_url";
    public static final String EVENT_TYPE = "event_type";
    public static final String START_TIME = "start_time";
    public static final String DURATION = "duration";
    public static final String LOCAL_VIDEO = "local_video";

    private SimpleExoPlayer simpleExoPlayer;

    private Surface mSurface;

    private boolean isForeground = true;

    private String videoUrl;
    private String eventType;
    private String startTime;
    private double duration;
    private String driverName;
    private String plateNumber;
    private String rotate;
    private boolean needDewarp = true;
    private String sn;
    private boolean localVideo;
    private double gpsLat,gpsLng;

    private ControlPanelHandler mHandler;

    private Disposable mPollProgressSub;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.iv_event_type)
    ImageView ivEventType;

    @BindView(R.id.tv_driver_name)
    TextView tvDriverName;

    @BindView(R.id.tv_event_time)
    TextView tvEventTime;

    @BindView(R.id.tv_plate_number)
    TextView tvPlateNumber;

    @BindView(R.id.include_event_play)
    LinearLayout includeEventPlay;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.ib_startPlay)
    ImageButton ibStartPlay;

    @BindView(R.id.rl_control_panel)
    RelativeLayout rlControlPanel;

    @BindView(R.id.ib_stopPlay)
    ImageButton ibStopPlay;

    @BindView(R.id.sb_video)
    SeekBar sbVideo;

    @BindView(R.id.tv_playProgress)
    TextView tvProgress;

    @BindView(R.id.tv_duration)
    TextView tvDuration;

    @BindView(R.id.ib_projection)
    ImageButton ibProjection;

    @BindView(R.id.ib_fullScreen)
    ImageButton ibFullScreen;

//    @BindView(R.id.tv_video_length)
//    TextView tvVideoLength;

    @BindView(R.id.btn_export_video)
    Button btnExportVideo;

    @BindView(R.id.include_map_view)
    RelativeLayout includeMapView;

    @BindView(R.id.include_export_fleet)
    ConstraintLayout includeExportFleet;


    private GoogleMap mMap;

    private boolean isFullScreen() {
        int orientation = this.getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    @OnClick(R.id.ib_fullScreen)
    public void onBtnFullscreenClicked() {
        if (!isFullScreen()) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            showControlPanel();
        } else {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    @OnClick(R.id.gl_live)
    public void onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked");
        if (ibStartPlay.getVisibility() == View.VISIBLE) {
            return;
        }

        if (rlControlPanel.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else {
            hideControlPanel();
        }
    }

    @OnClick(R.id.ib_startPlay)
    public void startPlay() {
        if (simpleExoPlayer == null) {
            initVideoPlayer(videoUrl);
            pollProgress();
        } else {
            if (!simpleExoPlayer.getPlayWhenReady()) {
                busy();
                togglePlayState(false);
                simpleExoPlayer.setPlayWhenReady(true);
            }
        }
    }

    @OnClick(R.id.ib_stopPlay)
    public void stopPlay() {
        if (simpleExoPlayer != null) {
            if (simpleExoPlayer.getPlayWhenReady()) {
                cancelBusy();
                togglePlayState(true);
                simpleExoPlayer.setPlayWhenReady(false);
            }
        }
    }

    @OnClick(R.id.btn_export_video)
    public void export() {
        btnExportVideo.setVisibility(View.GONE);
        includeExportFleet.setVisibility(View.VISIBLE);
    }

    @OnClick(R.id.ll_save_album)
    public void saveAlbum() {
        Logger.t(TAG).d("saveAlbum");
        cancel();

        ARouter.getInstance().build("/ui/activity/ExportActivity")
                .withInt(ExportActivity.CHOICE, 0)
                .withString(ExportActivity.URL, videoUrl)
                .withString(ExportActivity.CREATE_TIME, startTime)
                .withDouble(DURATION, duration)
                .withString(ExportActivity.ROTATE, rotate)
                .withBoolean(IntentKey.FLEET_NEED_DEWARP, needDewarp)
                .withInt(ExportActivity.TYPE, VideoEventType.getEventTypeForInteger(eventType))
                .withString(ExportActivity.LOCATION, "")
                .navigation();
    }

    @OnClick(R.id.ll_save_library)
    public void saveLibrary() {
        Logger.t(TAG).d("saveLibrary");
        cancel();

        ARouter.getInstance().build("/ui/activity/ExportActivity")
                .withInt(ExportActivity.CHOICE, 1)
                .withString(ExportActivity.URL, videoUrl)
                .withString(ExportActivity.CREATE_TIME, startTime)
                .withDouble(DURATION, duration)
                .withString(ExportActivity.ROTATE, rotate)
                .withBoolean(IntentKey.FLEET_NEED_DEWARP, needDewarp)
                .withInt(ExportActivity.TYPE, VideoEventType.getEventTypeForInteger(eventType))
                .withString(ExportActivity.LOCATION, "")
                .navigation();
    }

    @OnClick(R.id.btn_export_cancel)
    public void cancel() {
        btnExportVideo.setVisibility(View.VISIBLE);
        includeExportFleet.setVisibility(View.GONE);
    }

    private MDVRLibrary mVRLibrary;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_fleet_video);
        ButterKnife.bind(this);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            videoUrl = bundle.getString(VIDEO_URL);
            eventType = bundle.getString(EVENT_TYPE);
            startTime = bundle.getString(START_TIME);
            duration = bundle.getDouble(DURATION);
            driverName = bundle.getString(IntentKey.FLEET_DRIVER_NAME);
            plateNumber = bundle.getString(IntentKey.FLEET_PLATE_NUMBER);
            rotate = bundle.getString(IntentKey.FLEET_CAMERA_ROTATE);
            sn = bundle.getString(IntentKey.SERIAL_NUMBER);
            if (!TextUtils.isEmpty(sn)) needDewarp = sn.startsWith("2");
            localVideo = bundle.getBoolean(LOCAL_VIDEO);
            gpsLat = bundle.getDouble(IntentKey.GPS_LAT,0);
            gpsLng = bundle.getDouble(IntentKey.GPS_LONG,0);
        }

        initView();

        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        assert mapFragment != null;
        mapFragment.getMapAsync(this);

        Action mControlPanelAction = () -> {
            if (FleetVideoActivity.this.isFullScreen()) {
                FleetVideoActivity.this.hideControlPanel();
                FleetVideoActivity.this.setImmersiveMode(true);
            }
        };

        mHandler = new ControlPanelHandler(mControlPanelAction);

        mVRLibrary = createVRLibrary();

        ibProjection.setOnClickListener(v -> {
            int projectionMode = mVRLibrary.getProjectionMode();
            int switchMode = -1;
            Logger.t(TAG).d("projectionMode: " + projectionMode);

            if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS
                    || projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                mVRLibrary.setPinchEnabled(true);

                switchMode = projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS ?
                        PROJECTION_MODE_DOME230_UPPER : PROJECTION_MODE_DOME_UPPER_DOWN;

                ibProjection.setBackgroundResource(R.drawable.btn_front_back_n);

            } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER
                    || projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
                mVRLibrary.setPinchEnabled(false);

                switchMode = projectionMode == PROJECTION_MODE_DOME230_UPPER ?
                        CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;

                ibProjection.setBackgroundResource(R.drawable.btn_panorama_normal_n);
            }

            if (switchMode != -1) {
                mVRLibrary.switchProjectionMode(FleetVideoActivity.this, switchMode);
            }
        });

        sbVideo.setOnSeekBarChangeListener(changeListener);
    }

    private void initView() {
        setupToolbar();
        adaptationFor4K();

        ivEventType.setImageResource(VideoEventType.getEventIconResource(eventType, false));
        tv_toolbarTitle.setText(VideoEventType.dealEventType(this, eventType));
        tvEventTime.setText((!startTime.equals("") && startTime != null) ? startTime.replace("T", " ") : startTime);
        tvDriverName.setText(driverName);
        tvPlateNumber.setText(plateNumber);
//        tvVideoLength.setText(String.format("Video Length %s", DateUtils.formatElapsedTime((long) (duration / 1000))));
    }

    private int mXRadio;
    private int mYRadio;

    private void adaptationFor4K() {
        if (TextUtils.isEmpty(sn)) {
            return;
        }

        if (sn.startsWith("6")) {
            mXRadio = 32;
            mYRadio = 27;
        } else {
            mXRadio = 16;
            mYRadio = 9;
        }
        ibProjection.setVisibility(needDewarp ? View.VISIBLE : View.GONE);
        mMediaWindow.setRatio(mXRadio, mYRadio);
    }

    private String getFormattedTime(long utcTimeMillis) {
//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        SimpleDateFormat format = new SimpleDateFormat("HH:mm MMMM dd", Locale.getDefault());
        format.setTimeZone(timeZone);
        return String.format("|  %s", format.format(utcTimeMillis));
    }

    private void initVideoPlayer(String url) {
        // init VR Library
        busy();

        // 1. Create a default TrackSelector
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);

        // 2. Create the player
        simpleExoPlayer = ExoPlayerFactory.newSimpleInstance(this, trackSelector);

        if (mSurface != null) {
            simpleExoPlayer.setVideoSurface(mSurface);
        }

        simpleExoPlayer.addVideoListener(new VideoListener() {
            @Override
            public void onVideoSizeChanged(int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
                getVRLibrary().onTextureResize(width, height);
            }

            @Override
            public void onRenderedFirstFrame() {
                Logger.t(TAG).d("onRenderedFirstFrame");
                cancelBusy();
                if (!isForeground) {
                    simpleExoPlayer.setPlayWhenReady(false);
                }
                if (getVRLibrary() != null) {
                    getVRLibrary().notifyPlayerChanged();
                }
            }
        });

        simpleExoPlayer.addListener(new Player.EventListener() {
            @Override
            public void onTimelineChanged(Timeline timeline, Object manifest, int reason) {
            }

            @Override
            public void onTracksChanged(TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {
            }

            @Override
            public void onLoadingChanged(boolean isLoading) {
            }

            @Override
            public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
                updateControls(playWhenReady, playbackState);
            }

            @Override
            public void onRepeatModeChanged(int repeatMode) {
            }

            @Override
            public void onShuffleModeEnabledChanged(boolean shuffleModeEnabled) {
            }

            @Override
            public void onPlayerError(ExoPlaybackException error) {
                String errorMessage = error.getMessage();
                Logger.t(TAG).e("onPlayerError: " + errorMessage);
                restorePlayer();

                String errorString;
                if (TextUtils.isEmpty(errorMessage)) {
                    errorString = getString(R.string.fleet_default_error);
                } else {
                    errorString = getString(R.string.play_error);
                }
                Toast.makeText(FleetVideoActivity.this, errorString, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onPositionDiscontinuity(int reason) {
            }

            @Override
            public void onPlaybackParametersChanged(PlaybackParameters playbackParameters) {
            }

            @Override
            public void onSeekProcessed() {
            }
        });

        if (!TextUtils.isEmpty(url)) {
            boolean lensMode = TextUtils.isEmpty(rotate) || LENS_NORMAL.equals(rotate);
            switchVideoProjection(lensMode);

            simpleExoPlayer.prepare(getMediaSource(url));
            simpleExoPlayer.setPlayWhenReady(true);
        }
    }

    private void switchVideoProjection(boolean isLensNormal) {
        int projectionMode = mVRLibrary.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode + " isLensNormal: " + isLensNormal);

        int switchMode = -1;
        if (needDewarp) {
            if (isLensNormal) {
                if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                    switchMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
                } else if (projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
                    switchMode = PROJECTION_MODE_DOME230_UPPER;
                }
            } else {
                if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS) {
                    switchMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
                } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER) {
                    switchMode = PROJECTION_MODE_DOME_UPPER_DOWN;
                }
            }
        } else {
            switchMode = PROJECTION_MODE_PLANE_FIT;
        }

        Logger.t(TAG).d("switchMode: " + switchMode);

        if (switchMode != -1) {
            mVRLibrary.switchProjectionMode(FleetVideoActivity.this, switchMode);
        }
    }


    private void updateControls(boolean playWhenReady, int playbackState) {
        switch (playbackState) {
            case Player.STATE_IDLE:
            case Player.STATE_READY:
                cancelBusy();
                break;
            case Player.STATE_BUFFERING:
                busy();
                break;
            case Player.STATE_ENDED:
                restorePlayer();
                break;
            default:
                break;
        }
    }

    //重置player
    private void restorePlayer() {
        cancelBusy();
        releasePlayer();
        sbVideo.setProgress(0);
        togglePlayState(true);
        tvProgress.setText(DateUtils.formatElapsedTime(0));
    }

    /**
     * @param url
     * @return
     */
    private MediaSource getMediaSource(String url) {
//        Logger.t(TAG).d("url: " + url + " localVideo: " + localVideo);
        DataSource.Factory dataSourceFactory;

        if (localVideo) {
            dataSourceFactory = new DefaultDataSourceFactory(this, "Android");
        } else {
            // Measures bandwidth during playback. Can be null if not required.
            DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
            // Produces DataSource instances through which media data is loaded.
            dataSourceFactory = new CustomHttpDataSourceFactory("Android", bandwidthMeter);
        }

        // This is the MediaSource representing the media to be played.
//        if (mEventBean != null) {
//            return new HlsMediaSource.Factory(dataSourceFactory).createMediaSource(Uri.parse(url));
//        } else {
        return new ExtractorMediaSource.Factory(dataSourceFactory).createMediaSource(Uri.parse(url));
//        }
    }

    private void releasePlayer() {
        unsubscribePoll();

        if (simpleExoPlayer != null) {
            simpleExoPlayer.release();
            simpleExoPlayer = null;
        }
    }

    private void checkProgress(long along) {
        if (simpleExoPlayer != null && simpleExoPlayer.getPlayWhenReady()) {
            togglePlayState(false);
            long currentPos = simpleExoPlayer.getCurrentPosition();
            long duration = simpleExoPlayer.getDuration();
            if (duration > 0) {
                tvProgress.setText(DateUtils.formatElapsedTime(currentPos / 1000));
                tvDuration.setText(DateUtils.formatElapsedTime(duration / 1000));
                sbVideo.setMax((int) (duration));
                sbVideo.setProgress((int) (currentPos));
            }
        }
    }

    private void togglePlayState(boolean toPlay) {
        if (toPlay) {
            ibStartPlay.setVisibility(View.VISIBLE);
            ibStopPlay.setVisibility(View.INVISIBLE);
            rlControlPanel.setVisibility(View.GONE);
        } else {
            ibStartPlay.setVisibility(View.GONE);
            ibStopPlay.setVisibility(View.VISIBLE);
        }
    }

    public void setImmersiveMode(boolean immersiveMode) {
        Logger.t(TAG).d("setImmersiveMode: " + immersiveMode);
        if (immersiveMode) {
            getWindow().getDecorView().setSystemUiVisibility(FULL_SCREEN_FLAG);
        } else {
            getWindow().getDecorView().setSystemUiVisibility(0);
        }
    }

    public MDVRLibrary getVRLibrary() {
        return mVRLibrary;
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        mVRLibrary.onResume(this);
        if (simpleExoPlayer != null) {
            simpleExoPlayer.setPlayWhenReady(true);
        }
        //防止全屏状态下息屏、开屏，布局发生错位
        setImmersiveMode(isFullScreen());
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        mVRLibrary.onPause(this);
        if (simpleExoPlayer != null) {
            simpleExoPlayer.setPlayWhenReady(false);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mVRLibrary != null) {
            mVRLibrary.onDestroy();
        }
        releasePlayer();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mVRLibrary.onOrientationChanged(this);

        if (!isForeground) {
            //防止快速息屏、开屏，布局发生错位
            return;
        }

        if (isFullScreen()) {
            toolbar.setVisibility(View.GONE);
            includeEventPlay.setVisibility(View.GONE);
            ibFullScreen.setBackgroundResource(R.drawable.playbar_screen_narrow_n);

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.gravity = Gravity.BOTTOM;
            rlControlPanel.setLayoutParams(params);

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
            includeEventPlay.setVisibility(View.VISIBLE);
            ibFullScreen.setBackgroundResource(R.drawable.playbar_screen_full);

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.gravity = Gravity.BOTTOM;
            rlControlPanel.setLayoutParams(params);

            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            mMediaWindow.setLayoutParams(layoutParams);
        }
        setImmersiveMode(isFullScreen());
    }

    public void cancelBusy() {
        findViewById(R.id.progress).setVisibility(View.GONE);
    }

    public void busy() {
        findViewById(R.id.progress).setVisibility(View.VISIBLE);
    }

    protected MDVRLibrary createVRLibrary() {
        return MDVRLibrary.with(this)
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asVideo(surface -> {
//                    Logger.t(TAG).d("onSurfaceReady: " + surface);
                    mSurface = surface;
                })
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + String.valueOf(mode);
                    Toast.makeText(FleetVideoActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) findViewById(R.id.gl_live));
    }

    private void hideControlPanel() {
        rlControlPanel.setVisibility(View.GONE);
    }

    private void showControlPanel() {
        Logger.t(TAG).d("show ControlPanel");
        rlControlPanel.setVisibility(View.VISIBLE);
        mHandler.removeMessages(ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(ControlPanelHandler.FADE_OUT), 5000);
    }

    private void setupToolbar() {
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> {
                Intent intent = new Intent(LOAD_LIST_NOTI);
                LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
                finish();
            });
        }
    }

    private void pollProgress() {
        mPollProgressSub = Observable.interval(0, 500, TimeUnit.MILLISECONDS)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::checkProgress, new ServerErrorHandler());
    }

    private void unsubscribePoll() {
        if (mPollProgressSub != null && !mPollProgressSub.isDisposed()) {
            mPollProgressSub.dispose();
        }
    }

    SeekBar.OnSeekBarChangeListener changeListener = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {

        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            if (simpleExoPlayer == null) {
                return;
            }
            simpleExoPlayer.seekTo(seekBar.getProgress());
            simpleExoPlayer.setPlayWhenReady(true);
        }
    };

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
                .snippet(VideoEventType.dealEventType(this,eventType))
                .icon(BitmapDescriptorFactory.fromResource(VideoEventType.getEventIconResource(eventType, true)))
                .title(plateNumber)
                .position(MapTransformUtil.gps84_To_Gcj02(latLng)));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
        mMap.animateCamera(CameraUpdateFactory.zoomTo(17));
    }
}
