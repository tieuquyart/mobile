package com.mk.autosecure.ui.activity;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.text.format.DateUtils;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
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
import com.mk.autosecure.HornApplication;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.mk.autosecure.ui.view.RoundCornerImageView;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.Alert;
import com.mkgroup.camera.bean.CameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.network_adapter.exo_adapter.CustomHttpDataSourceFactory;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;
import com.waylens.vrlib.model.MDPinchConfig;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;
import static com.mk.autosecure.ui.activity.CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
import static com.mk.autosecure.ui.activity.CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_PLANE_FIT;


/**
 * Created by DoanVT on 2017/8/2.
 */
public class VideoPlayerActivity extends RxActivity {

    private static final String TAG = VideoPlayerActivity.class.getSimpleName();
    private static final String ALERT = "alert";

    private static final String VIDEO_URL = "video_url";
    private static final String EVENT_TYPE = "event_type";
    private static final String START_TIME = "start_time";
    private static final String CAMERA_NAME = "camera_name";
    private static final String ROTATE = "rotate";
    private static final String NEED_DEWARP = "need_dewarp";
    private static final String LOCAL_VIDEO = "local_video";

    private SimpleExoPlayer simpleExoPlayer;

    private boolean isForeground = true;

    private Alert mAlert;

    private String videoUrl;
    private String eventType;
    private long startTime;
    private String cameraName;
    private String rotate;
    private boolean needDewarp = true;
    private boolean localVideo;
    private int mXRadio = 16;
    private int mYRadio = 9;

    private ControlPanelHandler mHandler;

    private Disposable mPollProgressSub;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.ll_alert)
    LinearLayout llAlert;

    @BindView(R.id.view_type)
    View viewType;

    @BindView(R.id.tv_time)
    TextView tvTime;

    @BindView(R.id.tv_name)
    TextView tvName;

    @BindView(R.id.btnFullscreen)
    ImageButton mBtnFullscreen;

    @BindView(R.id.control_panel)
    RelativeLayout mControlPanel;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.tv_playProgress)
    TextView tv_playProgress;

    @BindView(R.id.tv_duration)
    TextView tv_videoDuration;

    @BindView(R.id.sb_video)
    SeekBar seekBar;

    @BindView(R.id.btn_playPause)
    ImageButton btn_playPause;

    @BindView(R.id.btn_projection)
    ImageButton btn_projection;

    @BindView(R.id.rl_uploading)
    RelativeLayout rlUploading;

    @BindView(R.id.iv_alert_thumbnail)
    RoundCornerImageView ivAlertThumbnail;

    @BindView(R.id.tv_alerts_uploading)
    TextView tvAlertsUploading;

    @BindView(R.id.ll_watch_detail)
    LinearLayout llWatchDetail;

    @BindView(R.id.tv_next_step)
    TextView tvNextStep;

    private boolean isFullScreen() {
        int orientation = this.getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    @OnClick(R.id.btnFullscreen)
    public void onBtnFullscreenClicked() {
        if (!isFullScreen()) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            showControlPanel();
        } else {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    @OnClick(R.id.gl_view)
    public void onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked");
        if (mControlPanel.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else {
            hideControlPanel();
        }
    }

    @OnClick(R.id.btn_playPause)
    public void onBtnPlayClicked() {
        if (simpleExoPlayer == null) {
            if (mAlert != null) {
                initVideoPlayer(mAlert.url);
            } else {
                initVideoPlayer(videoUrl);
            }
        } else {
            if (simpleExoPlayer.getPlayWhenReady()) {
                simpleExoPlayer.setPlayWhenReady(false);
                togglePlayState(true);
            } else {
                simpleExoPlayer.setPlayWhenReady(true);
                togglePlayState(false);
            }
        }
    }

    @OnClick(R.id.ll_watch_detail)
    public void watchDetail() {
        if (mAlert != null) {
            CameraBean cameraBean = HornApplication.getComponent().currentUser().getCamera(mAlert.sn);
            Logger.t(TAG).d("cameraBean: " + cameraBean);
            if (cameraBean != null) {
                CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                Logger.t(TAG).d("currentCamera: " + currentCamera);
                if (currentCamera != null) {
                    if (currentCamera.getSerialNumber().equals(cameraBean.sn)) {
                        if (mAlert.status.equals("finish")) {
                            VideosActivity.launch(this, cameraBean.sn, mAlert.alertTime);
                        } else {
                            LiveViewActivity.launch(this, cameraBean, true);
                            finish();
                        }
                    } else {
                        intentToLiveview(cameraBean);
                    }
                } else {
                    intentToLiveview(cameraBean);
                }
            }
        }
    }

    private void intentToLiveview(CameraBean cameraBean) {
        if (mAlert.status.equals("finish")) {
            LiveViewActivity.launch(this, cameraBean, mAlert.mediaFileID);
        } else {
            LiveViewActivity.launch(this, cameraBean, true);
            finish();
        }
    }

    public static void launch(Context context, Alert alert) {
        Intent i = new Intent(context, VideoPlayerActivity.class);
        i.putExtra(ALERT, alert);
        context.startActivity(i);
    }

    public static void launch(Context context, String videoUrl, String eventType, long startTime,
                              String cameraName, String rotate, boolean needDewarp, boolean localVideo) {
        Intent intent = new Intent(context, VideoPlayerActivity.class);
        intent.putExtra(VIDEO_URL, videoUrl);
        intent.putExtra(EVENT_TYPE, eventType);
        intent.putExtra(START_TIME, startTime);
        intent.putExtra(CAMERA_NAME, cameraName);
        intent.putExtra(ROTATE, rotate);
        intent.putExtra(NEED_DEWARP, needDewarp);
        intent.putExtra(LOCAL_VIDEO, localVideo);
        context.startActivity(intent);
    }

    private MDVRLibrary mVRLibrary;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_video_player);
        ButterKnife.bind(this);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            mAlert = (Alert) bundle.getSerializable(ALERT);

            videoUrl = bundle.getString(VIDEO_URL);
            eventType = bundle.getString(EVENT_TYPE);
            startTime = bundle.getLong(START_TIME);
            cameraName = bundle.getString(CAMERA_NAME);
            rotate = bundle.getString(ROTATE);
            needDewarp = bundle.getBoolean(NEED_DEWARP, true);
            localVideo = bundle.getBoolean(LOCAL_VIDEO);
        }

        initView();

        Action mControlPanelAction = () -> {
            if (VideoPlayerActivity.this.isFullScreen()) {
                VideoPlayerActivity.this.hideControlPanel();
                VideoPlayerActivity.this.setImmersiveMode(true);
            }
        };

        // 1. Create a default TrackSelector
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);

        // 2. Create the player
        simpleExoPlayer = ExoPlayerFactory.newSimpleInstance(this, trackSelector);

        mHandler = new ControlPanelHandler(mControlPanelAction);

        mVRLibrary = createVRLibrary();

        if (needDewarp) {
            btn_projection.setOnClickListener(v -> {
                int projectionMode = mVRLibrary.getProjectionMode();
                int switchMode = -1;

                if (projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS
                        || projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                    mVRLibrary.setPinchEnabled(true);

                    switchMode = projectionMode == CUSTOM_PROJECTION_DOUBLE_DIRECTIONS ?
                            PROJECTION_MODE_DOME230_UPPER : PROJECTION_MODE_DOME_UPPER_DOWN;

                    btn_projection.setBackgroundResource(R.drawable.btn_front_back_n);

                } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER
                        || projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
                    mVRLibrary.setPinchEnabled(false);

                    switchMode = projectionMode == PROJECTION_MODE_DOME230_UPPER ?
                            CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;

                    btn_projection.setBackgroundResource(R.drawable.btn_panorama_normal_n);
                }

                if (switchMode != -1) {
                    mVRLibrary.switchProjectionMode(VideoPlayerActivity.this, switchMode);
                }
            });
        } else {
            btn_projection.setVisibility(View.INVISIBLE);
        }

        if (mAlert != null) {
            if (mAlert.status.equals("finish")) {
                llWatchDetail.setVisibility(View.VISIBLE);
                initVideoPlayer(mAlert.url);
                tvNextStep.setText(R.string.watch_detail);
            } else {
                mControlPanel.setVisibility(View.INVISIBLE);
                rlUploading.setVisibility(View.VISIBLE);
                boolean lensMode = TextUtils.isEmpty(mAlert.rotate) || LENS_NORMAL.equals(mAlert.rotate);

                Glide.with(this)
                        .load(mAlert.thumbnail)
                        .transform(new TwoDirectionTransform(this, lensMode))
                        .diskCacheStrategy(DiskCacheStrategy.ALL)
                        .placeholder(R.drawable.bg_single_thumbnail)
                        .error(R.drawable.bg_single_thumbnail)
                        .into(ivAlertThumbnail);

                long sub = System.currentTimeMillis() - mAlert.alertTime;
                //超过两分钟就不再显示uploading的状态
                if (sub <= 60 * 2 * 1000) {
                    tvAlertsUploading.setVisibility(View.VISIBLE);
                    llWatchDetail.setVisibility(View.VISIBLE);
                } else {
                    tvAlertsUploading.setVisibility(View.INVISIBLE);
                    llWatchDetail.setVisibility(View.GONE);
                }

                tvNextStep.setText(R.string.go_live);
            }
        } else {
            initVideoPlayer(videoUrl);
        }
        pollProgress();

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
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
        });
    }

    private void initView() {
        setupToolbar();

        if (mAlert != null) {
            llAlert.setVisibility(View.VISIBLE);
            viewType.setBackgroundResource(VideoEventType.getEventColor(mAlert.alertType));
            tvTime.setText(getFormattedTime(mAlert.alertTime));
            tvName.setText(mAlert.cameraName);
        } else if (!localVideo) {
            llAlert.setVisibility(View.VISIBLE);
            viewType.setBackgroundResource(VideoEventType.getEventColor(eventType));
            tvTime.setText(getFormattedTime(startTime));
            tvName.setText(cameraName);
        }
    }

    private String getFormattedTime(long date) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd KK:mm a", Locale.getDefault());
        SimpleDateFormat withoutYearFormat;
        SimpleDateFormat withoutDayFormat;
        if (DateFormat.is24HourFormat(this)) {
            withoutYearFormat = new SimpleDateFormat("HH:mm MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        } else {
            withoutYearFormat = new SimpleDateFormat("KK:mm a MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("KK:mm a", Locale.getDefault());
        }

        long currentTime = System.currentTimeMillis();

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(date);
        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int clipDateYear = calendar.get(Calendar.YEAR);

        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        String dateString = format.format(date);

        if (clipDateYear == currentDateYear) {
            if ((currentDateDay - clipDateDay) < 1) {
                dateString = withoutDayFormat.format(date);
            } else if ((currentDateDay - clipDateDay) < 2) {
                dateString = withoutDayFormat.format(date) + " " + getString(R.string.yesterday);
            } else {
                dateString = withoutYearFormat.format(date);
            }
        }
        return dateString;
    }

    private void changeVideoSize(int videoWidth, int videoHeight) {
        int divisor = getGreatestCommonDivisor(videoWidth, videoHeight);

        int tempX = videoWidth / divisor;
        int tempY = videoHeight / divisor;

        Logger.t(TAG).d("changeVideoSize: " + divisor + " " + tempX + " " + tempY);

        if (tempX != mXRadio || tempY != mYRadio) {
            mXRadio = tempX;
            mYRadio = tempY;

            mMediaWindow.setRatio(mXRadio, mYRadio);
            mMediaWindow.post(() -> getVRLibrary().onTextureResize(videoWidth, videoHeight));
        } else {
            getVRLibrary().onTextureResize(videoWidth, videoHeight);
        }
    }

    private int getGreatestCommonDivisor(int videoWidth, int videoHeight) {
        int max = Math.max(videoWidth, videoHeight);
        int min = Math.min(videoWidth, videoHeight);

        while (max % min != 0) {
            int temp = max % min;
            max = min;
            min = temp;
        }
        return min;
    }

    private void initVideoPlayer(String url) {
        // init VR Library
        busy();

        simpleExoPlayer.addVideoListener(new VideoListener() {
            @Override
            public void onVideoSizeChanged(int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
                Logger.t(TAG).d("onVideoSizeChanged: " + width + " " + height);
                changeVideoSize(width, height);
            }

            @Override
            public void onRenderedFirstFrame() {
//                Logger.t(TAG).d("onRenderedFirstFrame");
//                cancelBusy();
//                if (!isForeground) {
//                    simpleExoPlayer.setPlayWhenReady(false);
//                }
//                if (getVRLibrary() != null) {
//                    getVRLibrary().notifyPlayerChanged();
//                }
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
                Logger.t(TAG).e("onPlayerError: " + error.getMessage());
                cancelBusy();
                togglePlayState(true);
                if (simpleExoPlayer != null) {
                    simpleExoPlayer.setPlayWhenReady(false);
                }
                String errorString = String.format(Locale.getDefault(), "Play error: " + error.getMessage());
                Toast.makeText(VideoPlayerActivity.this, errorString, Toast.LENGTH_SHORT).show();
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

//        Logger.t(TAG).d("video url = " + url);
        if (!TextUtils.isEmpty(url)) {
            if (mAlert != null) {
                boolean lensMode = TextUtils.isEmpty(mAlert.rotate) || LENS_NORMAL.equals(mAlert.rotate);
                Logger.t(TAG).e("lensMode: " + lensMode);
                switchVideoProjection(lensMode);
            } else {
                boolean lensMode = TextUtils.isEmpty(rotate) || LENS_NORMAL.equals(rotate);
                switchVideoProjection(lensMode);
            }

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

        Logger.t(TAG).d("switchMode: " + switchMode);

        if (switchMode != -1) {
            mVRLibrary.switchProjectionMode(VideoPlayerActivity.this, switchMode);
        }
    }


    private void updateControls(boolean playWhenReady, int playbackState) {
        switch (playbackState) {
            case Player.STATE_IDLE:
            case Player.STATE_ENDED:
                cancelBusy();
                break;
            case Player.STATE_BUFFERING:
                busy();
                break;
            case Player.STATE_READY:
                cancelBusy();
                break;
            default:
                break;
        }
    }

    /**
     * @param url
     * @return
     */
    private MediaSource getMediaSource(String url) {
        Logger.t(TAG).d("url: " + url + " localVideo: " + localVideo);
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
                tv_playProgress.setText(DateUtils.formatElapsedTime(currentPos / 1000));
                tv_videoDuration.setText(DateUtils.formatElapsedTime(duration / 1000));
                seekBar.setMax((int) (duration));
                seekBar.setProgress((int) (currentPos));
            }
        }
    }

    private void togglePlayState(boolean toPlay) {
        btn_playPause.setBackground(getResources().getDrawable(toPlay ? R.drawable.playbar_play_n : R.drawable.playbar_pause_n));
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
            llAlert.setVisibility(View.GONE);
            mBtnFullscreen.setBackgroundResource(R.drawable.playbar_screen_narrow_n);

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(64));
            params.gravity = Gravity.BOTTOM;
            mControlPanel.setLayoutParams(params);

            Display defaultDisplay = getWindowManager().getDefaultDisplay();
            int totalWidth = defaultDisplay.getWidth();
            int totalHeight = defaultDisplay.getHeight();
            if (totalWidth * mYRadio > totalHeight * mXRadio) {
                mMediaWindow.post(() -> {
                    int width = mMediaWindow.getWidth();
                    int shadowWidth = (width - totalHeight * mXRadio / mYRadio) / 2;

                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                            totalHeight * mXRadio / mYRadio, totalHeight);
                    layoutParams.setMargins(shadowWidth, 0, shadowWidth, 0);
                    mMediaWindow.setLayoutParams(layoutParams);
                });
            }
        } else {
            toolbar.setVisibility(View.VISIBLE);
            if (mAlert != null || !localVideo) llAlert.setVisibility(View.VISIBLE);
            mBtnFullscreen.setBackgroundResource(R.drawable.playbar_screen_full);

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(64));
            params.gravity = Gravity.BOTTOM;
            mControlPanel.setLayoutParams(params);

            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
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
                    if (simpleExoPlayer != null) {
                        simpleExoPlayer.setVideoSurface(surface);
                    }
                })
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + String.valueOf(mode);
                    Toast.makeText(VideoPlayerActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) findViewById(R.id.gl_view));
    }

    private void hideControlPanel() {
        mControlPanel.setVisibility(View.GONE);
    }

    private void showControlPanel() {
        if (mControlPanel == null) {
            return;
        }
        Logger.t(TAG).d("show ControlPanel");
        mControlPanel.setVisibility(View.VISIBLE);
        mHandler.removeMessages(ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(ControlPanelHandler.FADE_OUT), 5000);
    }

    private void setupToolbar() {
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> VideoPlayerActivity.this.finish());
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
}
