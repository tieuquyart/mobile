package com.mk.autosecure.ui.fragment;

import static android.view.animation.Animation.REVERSE;
import static com.google.android.material.bottomnavigation.LabelVisibilityMode.LABEL_VISIBILITY_LABELED;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mkgroup.camera.model.VdbConsts.STREAM_MAIN;
import static com.mkgroup.camera.model.VdbConsts.STREAM_SUB_1;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.Keyframe;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

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
import com.google.android.exoplayer2.video.VideoListener;
import com.google.android.material.bottomnavigation.BottomNavigationItemView;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.IjkPlayerLogUtil;
import com.mk.autosecure.libs.utils.InfoMsgUtils;
import com.mk.autosecure.libs.utils.MediaPlayerWrapper;
import com.mk.autosecure.libs.utils.ObjectUtils;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipBeanPos;
import com.mk.autosecure.model.ClipBeanPosChangeEvent;
import com.mk.autosecure.model.ClipPosChangeEvent;
import com.mk.autosecure.model.EventBeanPos;
import com.mk.autosecure.model.EventBeanPosChangeEvent;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.VideoType;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.ui.ResizeAnimation;
import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.activity.DevicesActivity;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.adapter.TypeAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.tool.BatteryImageViewResHelper;
import android.widget.Toast;

import com.mk.autosecure.ui.view.BezierEvaluator;
import com.mk.autosecure.ui.view.BottomNavigationViewEx;
import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.mk.autosecure.ui.view.GuideLayout;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.FragmentEvent;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.ICameraWrapper;
import com.mkgroup.camera.InfoMsgQueue;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.download.ExportEvent;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.event.ClipInfoMsgEvent;
import com.mkgroup.camera.event.LensChangeEvent;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.glide_adapter.SnipeGlideLoader;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipActionInfo;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.model.PlaybackUrl;
import com.mkgroup.camera.model.SpaceInfo;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.network_adapter.exo_adapter.CustomHttpDataSourceFactory;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.viewmodels.fragment.CameraViewFragmentViewModel;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;
import com.waylens.vrlib.model.MDPinchConfig;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.io.File;
import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;
import butterknife.OnTouch;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;
import io.reactivex.internal.functions.Functions;
import io.reactivex.schedulers.Schedulers;
import tv.danmaku.ijk.media.player.IMediaPlayer;

@SuppressLint({"CheckResult","NonConstantResourceId"})
@RequiresFragmentViewModel(CameraViewFragmentViewModel.ViewModel.class)
public class CameraViewFragment extends BaseLazyLoadFragment<CameraViewFragmentViewModel.ViewModel> {

    public final static String TAG = CameraViewFragment.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.toolbar_4k)
    Toolbar toolbar4K;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.tv_toolbarTitle_4k)
    TextView tvToolbarTitle4K;

    @BindView(R.id.iv_videoSrc_4k)
    ImageView ivVideoSrc4K;

    @BindView(R.id.ll_view_status)
    LinearLayout llViewStatus;

    @BindView(R.id.iv_curStatus)
    ImageView iv_curStatus;

    @BindView(R.id.tv_curStatus)
    TextView tvCurStatus;

    @BindView(R.id.ll_setting_request)
    LinearLayout ll_setting_request;

//    @BindView(R.id.tv_notRecording)
//    TextView tvNotRecording;

    @BindView(R.id.rl_media)
    RelativeLayout rl_media;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.gl_view)
    GLSurfaceView glSurfaceView;

    @BindView(R.id.gl_videoView)
    GLSurfaceView glVideoSurfaceView;

    @BindView(R.id.gl_cloudView)
    GLSurfaceView glCloudSurfaceView;

    @BindView(R.id.ll_pinch_drag)
    LinearLayout ll_pinch_drag;

    @BindView(R.id.ll_videoSrc)
    LinearLayout ll_videoSrc;

    @BindView(R.id.iv_videoSrc)
    ImageView iv_videoSrc;

    @BindView(R.id.tv_videoSrc)
    TextView tv_videoSrc;

    @BindView(R.id.ib_highlight)
    ImageButton btn_highlight;

    @BindView(R.id.pb_highlight)
    ProgressBar pb_highlight;

    @BindView(R.id.rl_thumbnail_landscape)
    RelativeLayout rl_thumbnail_landscape;

    @BindView(R.id.rl_control_portrait)
    RelativeLayout rl_control_portrait;

    @BindView(R.id.ll_record_land)
    LinearLayout ll_record_land;

    @BindView(R.id.ll_record_port)
    LinearLayout ll_record_port;

    @BindView(R.id.switch_recording_land)
    Switch switch_recording_land;

    @BindView(R.id.switch_recording_port)
    Switch switch_recording_port;

    @BindView(R.id.tv_recording_land)
    TextView tv_recording_land;

    @BindView(R.id.tv_recording_port)
    TextView tv_recording_port;

    @BindView(R.id.btnPlayPause_port)
    ImageButton btnPlayPause_port;

    @BindView(R.id.btnPlayPause_land)
    ImageButton btnPlayPause_land;

    @BindView(R.id.rl_videoProgress)
    RelativeLayout rl_videoProgress;

    @BindView(R.id.sb_video)
    SeekBar sbVideo;

    @BindView(R.id.tv_playProgress)
    TextView tvVideoProgress;

    @BindView(R.id.tv_duration)
    TextView tvVideoDuration;

    @BindView(R.id.btnFullscreen_land)
    ImageButton btnFullscreen_land;

    @BindView(R.id.btnFullscreen_port)
    ImageButton btnFullscreen_port;

    @BindView(R.id.btnProjection_land)
    ImageButton btnProjection_land;

    @BindView(R.id.btnProjection_port)
    ImageButton btnProjection_port;

    @BindView(R.id.iv_guideSwitch)
    ImageView ivGuideSwitch;

    @BindView(R.id.btnStream_land)
    ImageButton btnStreamLand;

    @BindView(R.id.btnStream_port)
    ImageButton btnStreamPort;

    @BindView(R.id.btn_evcam_stream_land)
    Button btnEvCamStreamLand;

    @BindView(R.id.btn_evcam_stream_port)
    Button btnEvCamStreamPort;

    @BindView(R.id.btn_evcam_faceId)
    ImageButton btnEvCamFaceId;

    @BindView(R.id.rl_filter)
    RelativeLayout rlFilter;

    @BindView(R.id.tv_event_num)
    TextView tv_event_num;

    @BindView(R.id.rg_source)
    RadioGroup rg_source;

    @BindView(R.id.rb_sdcard)
    RadioButton rb_sdcard;

    @BindView(R.id.rb_cloud)
    RadioButton rb_cloud;

    @BindView(R.id.rv_type)
    RecyclerView rvType;

    @BindView(R.id.view_export)
    View viewExport;

    @BindView(R.id.iv_export_thumbnail)
    ImageView iv_export_thumbnail;

    @BindView(R.id.va_guide)
    ViewAnimator va_guide;

    @BindView(R.id.view_info)
    View viewInfo;

    @BindView(R.id.iv_info_thumbnail)
    ImageView iv_info_thumbnail;

    @BindView(R.id.include_highlight_success)
    ConstraintLayout includeHighlightSuccess;

    @BindView(R.id.iv_highlight_temp)
    ImageView ivHighlightTemp;

    @BindView(R.id.navi_view_temp)
    BottomNavigationViewEx naviViewTemp;

    @BindView(R.id.rl_preview)
    RelativeLayout rlPreview;

    @BindView(R.id.tv_sliding_tips)
    TextView tvSlidingTips;

    @BindView(R.id.ll_message_remind)
    LinearLayout llMessageRemind;

    @BindView(R.id.ll_message_remind_4k)
    LinearLayout llMessageRemind4K;

    @BindView(R.id.tv_msg_content)
    TextView tvMsgContent;

    @BindView(R.id.tv_msg_content_4k)
    TextView tvMsgContent4K;

    private PreviewFragment mPreviewFragment;

    @OnClick({R.id.tv_toolbarTitle, R.id.iv_close_preview})
    void showCameras() {
        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
        if (mPreviewFragment == null) {
            mPreviewFragment = new PreviewFragment();
            //
            try {
                transaction.add(R.id.frame_preview, mPreviewFragment).commitNow();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
            rlPreview.setVisibility(View.VISIBLE);
        } else {
            if (mPreviewFragment.isVisible()) {
                //
                try {
                    transaction.remove(mPreviewFragment).commitNow();
                } catch (Exception ex) {
                    Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
                }
                rlPreview.setVisibility(View.GONE);
            } else {
                //
                try {
                    transaction.add(R.id.frame_preview, mPreviewFragment).commitNow();
                } catch (Exception ex) {
                    Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
                }
                rlPreview.setVisibility(View.VISIBLE);
            }
        }
    }

    @SuppressLint("SourceLockedOrientationActivity")
    @OnClick({R.id.btnFullscreen_port, R.id.btnFullscreen_land})
    public void onBtnFullscreenClicked() {
        if (!tourGuide) {
            if (!isFullScreen()) {
                mSoftActivity.get().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                showControlPanel();
            } else {
                mSoftActivity.get().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }
        }
    }

    @OnClick(R.id.gl_videoView)
    void onVideoSurfaceClicked() {
        Logger.t(TAG).d("gl_videoView window clicked");
        if (rl_control_portrait.getVisibility() != View.VISIBLE
                && rl_thumbnail_landscape.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else if (isFullScreen()) {
            hideControlPanel();
        }
    }

    @OnClick(R.id.gl_cloudView)
    void onCloudSurfaceClicked() {
        Logger.t(TAG).d("gl_cloudView window clicked");
        if (rl_control_portrait.getVisibility() != View.VISIBLE
                && rl_thumbnail_landscape.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else if (isFullScreen()) {
            hideControlPanel();
        }
    }

    @OnClick(R.id.gl_view)
    void onBitmapSurfaceClicked() {
        Logger.t(TAG).d("gl_view window clicked");
        if (rl_control_portrait.getVisibility() != View.VISIBLE
                && rl_thumbnail_landscape.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else if (isFullScreen()) {
            hideControlPanel();
        }
    }

    @OnCheckedChanged({R.id.switch_recording_port, R.id.switch_recording_land})
    void switchRecording(boolean isChecked) {
        Logger.t(TAG).d("switch_recording = " + isChecked);
        if (mCamera != null) {
            if (tourGuide) {
                if (mCamera.getRecordState() != VdtCamera.STATE_RECORD_STOPPED) {
                    switch_recording_port.setChecked(true);
                    switch_recording_land.setChecked(true);
                } else {
                    switch_recording_port.setChecked(false);
                    switch_recording_land.setChecked(false);
                }
            } else {
                if (isChecked && mCamera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
                    switch_recording_port.setChecked(false);
                    switch_recording_land.setChecked(false);
                    mCamera.startRecording();
                } else if (!isChecked && mCamera.getRecordState() != VdtCamera.STATE_RECORD_STOPPED) {
                    switch_recording_port.setChecked(true);
                    switch_recording_land.setChecked(true);
                    mCamera.stopRecording();
                }
            }
        }
    }

    @OnClick({R.id.btnPlayPause_port, R.id.btnPlayPause_land})
    void onBtnPlayPauseClicked() {
        if (glVideoSurfaceView.isShown() && mMediaPlayerWrapper != null) {
            viewModel.inputs.playOrPause(mMediaPlayerWrapper.getPlayer().isPlaying());
        } else if (glCloudSurfaceView.isShown() && simpleExoPlayer != null) {
            viewModel.inputs.playOrPause(simpleExoPlayer.getPlayWhenReady());
        }
    }

    @OnClick(R.id.ib_highlight)
    void onHighlight() {
        if (mCamera == null) {
            return;
        }
        if (viewModel.isLiveOrNot) {
            mCamera.markLiveVideo();
        } else if (videosFragment != null) {
            videosFragment.doAddBookmark();
        }
    }

    @OnClick(R.id.pb_highlight)
    void onDownloadHighlight() {
        showPopWindow(R.layout.view_clip_cancel, true);
    }

    @OnClick({R.id.btnStream_port, R.id.btnStream_land})
    public void btnStream() {
        if (playbackUrl != null) {
            int stream = playbackUrl.stream;
            boolean needDewarp = mCamera.getNeedDewarp();
//            Logger.t(TAG).d("test stream: " + stream + " needDewarp: " + needDewarp);
            if (needDewarp) {
                if (stream == STREAM_MAIN) {
                    viewModel.inputStreamIndex(1);
                    btnStreamPort.setBackgroundResource(R.drawable.bg_sd_selector);
                    btnStreamLand.setBackgroundResource(R.drawable.bg_sd_selector);
                } else if (stream == STREAM_SUB_1) {
                    viewModel.inputStreamIndex(0);
                    btnStreamPort.setBackgroundResource(R.drawable.bg_hd_selector);
                    btnStreamLand.setBackgroundResource(R.drawable.bg_hd_selector);
                }
            }
            if (mClipPos != null) {
                initVideoPlayer(mClipPos);
            }
        }
    }

    @OnClick({R.id.btn_evcam_stream_port, R.id.btn_evcam_stream_land})
    public void btnEvCamStream() {
        hideNavigation();
        showStreamDialog();
    }

    @OnClick(R.id.btn_evcam_faceId)
    public void switchFaceId() {
        if (videosFragment == null || faceIdFragment == null) {
            return;
        }

        if (videosFragment.isVisible()) {
            //
            try {
                getChildFragmentManager().beginTransaction()
                        .hide(videosFragment)
                        .show(faceIdFragment)
                        .commit();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
            videosFragment.onToLiveClick();
        }

        if (faceIdFragment.isVisible()) {
            //
            try {
                getChildFragmentManager().beginTransaction()
                        .hide(faceIdFragment)
                        .show(videosFragment)
                        .commit();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        }
    }

    @OnClick(R.id.iv_guideSwitch)
    void guideTouch() {
        btnProjection();
        projectionLayout.hide();
        pinchLayout.show();
        ivGuideSwitch.setVisibility(View.GONE);
        ivGuideSwitch.clearAnimation();
    }

    @OnClick({R.id.btnProjection_port, R.id.btnProjection_land})
    void btnProjection() {
        int projectionMode = mVRLibrary.getProjectionMode();
        int switchMode = -1;

        if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS
                || projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
            mVRLibrary.setPinchEnabled(true);
            mVRVideoLibrary.setPinchEnabled(true);
            mVRCloudLibrary.setPinchEnabled(true);

            switchMode = projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS ?
                    PROJECTION_MODE_DOME230_UPPER : PROJECTION_MODE_DOME_UPPER_DOWN;

            btnProjection_port.setBackgroundResource(R.drawable.bg_front_back_selector);
            btnProjection_land.setBackgroundResource(R.drawable.bg_front_back_selector);

            if (tourGuide) {
                ll_pinch_drag.setVisibility(View.VISIBLE);
            }

        } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER
                || projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
            mVRLibrary.setPinchEnabled(false);
            mVRVideoLibrary.setPinchEnabled(false);
            mVRCloudLibrary.setPinchEnabled(false);

            switchMode = projectionMode == PROJECTION_MODE_DOME230_UPPER ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;

            btnProjection_port.setBackgroundResource(R.drawable.bg_panorama_selector);
            btnProjection_land.setBackgroundResource(R.drawable.bg_panorama_selector);

            if (tourGuide) {
                ll_pinch_drag.setVisibility(View.GONE);
            }
        }

        if (switchMode != -1) {
            mVRLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
            mVRVideoLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
            mVRCloudLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
        }
    }

    @OnClick(R.id.ib_record)
    void onRecordClicked() {
        if (mCamera != null) {
            if (mCamera.getRecordState() == VdtCamera.STATE_RECORD_STOPPED) {
                mCamera.startRecording();
            } else {
                mCamera.stopRecording();
            }
        }
    }

    @OnClick(R.id.ib_filter_finish)
    void hideFilter() {
        rlFilter.setVisibility(View.GONE);
        if (videosFragment != null && videosFragment.viewModel() != null) {
            videosFragment.viewModel().filterVisibility(View.VISIBLE);
        }
        if (remoteVideoFragment != null && remoteVideoFragment.viewModel() != null) {
            remoteVideoFragment.viewModel().filterVisibility(View.VISIBLE);
        }
    }

    @OnTouch(R.id.iv_export_thumbnail)
    boolean exportClick(MotionEvent event) {
        float x = event.getRawX();
        float y = event.getY() + ViewUtils.dp2px(80);
//        Logger.t(TAG).d("exportClick: " + x + " " + y);

        if (videosFragment != null) {
            Clip posClip = videosFragment.getCurrentPosClip(x, y);

            if (posClip != null) {
                String videoType = VideoEventType.getEventTypeForString(posClip.getVideoType());
                Logger.t(TAG).d("videoType: " + videoType);

                TextView tv_export_info = va_guide.findViewById(R.id.layout_guide_info).findViewById(R.id.tv_export_info);
                tv_export_info.setTextColor(getResources().getColor(VideoEventType.getEventColor(videoType)));

                int durationMs = posClip.getDurationMs();
                tv_export_info.setText(String.format(Locale.US, "%s · %s",
                        VideoEventType.dealEventType(mSoftActivity.get(), videoType),
                        StringUtils.formatDuration(durationMs / 1000)));
            }
        }

        va_guide.findViewById(R.id.iv_export_tapShadow).clearAnimation();

        va_guide.setDisplayedChild(1);
//        if (tvNotRecording.getVisibility() == View.VISIBLE) {
//            va_guide.findViewById(R.id.tv_info_margin).setVisibility(View.INVISIBLE);
//        }
        viewInfo.setBackground(viewExport.getBackground());
        iv_info_thumbnail.setImageDrawable(iv_export_thumbnail.getDrawable());

        tapShadow = va_guide.findViewById(R.id.iv_info_tapShadow);
        glintView(tapShadow);

        va_guide.findViewById(R.id.tv_skip_info).setOnClickListener(v -> popSkipGuide(GUIDE_STEP.EXPORT_INFO));

        va_guide.findViewById(R.id.layout_guide_info)
                .findViewById(R.id.dialog_view_export).setBackground(viewExport.getBackground());

        va_guide.findViewById(R.id.layout_guide_info).setOnClickListener(v -> {
            tapShadow.clearAnimation();

            va_guide.setDisplayedChild(2);
            va_guide.findViewById(R.id.layout_guide_detail)
                    .findViewById(R.id.tv_skip_guide).setVisibility(View.GONE);
            va_guide.findViewById(R.id.layout_guide_detail)
                    .findViewById(R.id.btn_go_guide).setOnClickListener(v1 -> {

                va_guide.setDisplayedChild(3);
                va_guide.findViewById(R.id.btn_complete).setOnClickListener(v11 -> {
                    va_guide.setVisibility(View.GONE);
                    showNavigation();
                    PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, false);

                    LocalLiveActivity.launch(mSoftActivity.get(), true);
                });
            });
        });
        return true;
    }

    private enum GUIDE_STEP {
        SWITCH_PROJECTION, PINCH_DRAG, TAP_VIEW, EXPORT_INFO
    }

    private SimpleExoPlayer simpleExoPlayer;

    private MediaPlayerWrapper mMediaPlayerWrapper = new MediaPlayerWrapper(false);

    private PlaybackUrl playbackUrl;

    private boolean isForeground = true;

    private MDVRLibrary mVRLibrary;

    private MDVRLibrary mVRVideoLibrary;

    private MDVRLibrary mVRCloudLibrary;

    private InetSocketAddress mjpegAddress;

    private MjpegStream mMjpegStream;

    private ClipPos mClipPos = null;

    private ClipBeanPos mClipBeanPos = null;

    private EventBeanPos mEventBeanPos = null;

    private MD360BitmapTexture.Callback mCallback = null;

    private Surface mCloudSurface = null;

    private ControlPanelHandler mHandler;

    public CameraWrapper mCamera;

    private String sn;

    private VideosFragment videosFragment;

    private FaceIdFragment faceIdFragment;

    private RemoteVideoFragment remoteVideoFragment;

    private PopupWindow mPopWindow;

    private RefreshHandler mRefreshHandler;

    private final static int REFRESH_TAG = 0x007;

    public List<String> filterList = new ArrayList<>();

    private boolean tourGuide;

    private long mStartTimeMs;

    private View tapShadow;

    private Disposable pollExportEvent;

    public static CameraViewFragment newInstance(String sn) {
        CameraViewFragment fragment = new CameraViewFragment();
        Bundle args = new Bundle();
        args.putString(IntentKey.SERIAL_NUMBER, sn);
        fragment.setArguments(args);
        return fragment;
    }

    public static CameraViewFragment newInstance(String sn, boolean tourGuide) {
        CameraViewFragment fragment = new CameraViewFragment();
        Bundle args = new Bundle();
        args.putString(IntentKey.SERIAL_NUMBER, sn);
        args.putBoolean(IntentKey.TOUR_GUIDE, tourGuide);
        fragment.setArguments(args);
        return fragment;
    }

    private SoftReference<Activity> mSoftActivity;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mSoftActivity = new SoftReference<>(activity);
    }

    @Override
    protected void onFragmentPause() {
        stopStream();
        isForeground = false;

        if (mVRLibrary != null) {
            mVRLibrary.onPause(mSoftActivity.get());
        }
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onPause(mSoftActivity.get());
        }
        if (mVRCloudLibrary != null) {
            mVRCloudLibrary.onPause(mSoftActivity.get());
        }

        onBtnPlayPauseClicked();
    }

    @Override
    protected void onFragmentResume() {
//        if (viewModel.isLiveOrNot && mjpegAddress != null) startStream(mjpegAddress);
        isForeground = true;

        if (mVRLibrary != null) {
            mVRLibrary.onResume(mSoftActivity.get());
        }
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onResume(mSoftActivity.get());
        }
        if (mVRCloudLibrary != null) {
            mVRCloudLibrary.onResume(mSoftActivity.get());
        }

        onBtnPlayPauseClicked();

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler());
    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper cameraWrapper = camera.getIncludeNull();
        Logger.t(TAG).d("onCurrentCamera: " + cameraWrapper);
        if (cameraWrapper != null) {
            onNewCamera(cameraWrapper);
        } else {
            onDisconnectCamera();
        }
    }

    private void onNewCamera(CameraWrapper wrapper) {
        Logger.t(TAG).d("got one camera: " + wrapper.getSerialNumber());
        if (!TextUtils.isEmpty(sn) && sn.equals(wrapper.getSerialNumber())) {
            mCamera = wrapper;
            tvToolbarTitle.setText(mCamera.getName());
//            tvToolbarTitle4K.setText(mCamera.getName());
            adaptationFor4K(mCamera.getNeedDewarp(), true);
            checkSomeMsg(wrapper);
            initMsgEvent();
            if (viewModel.isLiveOrNot) {
                refreshPipeline(wrapper);
            }
        } else {
            Logger.t(TAG).e("camera is uncalibrated !!!");
//            onDisconnectCamera();
        }
    }

    @SuppressLint("CheckResult")
    private void initMsgEvent() {
        mCamera.getInfoMsgQueue().asObservable()
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(this::onInfoMsgQueue, new ServerErrorHandler(TAG));
    }

    private void onInfoMsgQueue(InfoMsgQueue imq) {
        InfoMsgQueue.InfoMsg msg = imq.peek();
        if (llMessageRemind.getVisibility() == View.VISIBLE) {
            llMessageRemind.setVisibility(View.GONE);
        }
        if (llMessageRemind4K.getVisibility() == View.VISIBLE) {
            llMessageRemind4K.setVisibility(View.GONE);
        }
        if (msg != null) {
            Logger.t(TAG).d("msg isRead = " + msg.isRead());

            boolean setup = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, !Constants.isFleet());
            Logger.t(TAG).d("setup: " + setup);

            //新手引导过程中、当前页面不可见时不显示弹窗
            LocalLiveActivity activity = (LocalLiveActivity) mSoftActivity.get();
            Fragment parentFragment = getParentFragment();
            if ((activity != null && activity.tourGuide) || setup) {
                //do sth
            } else if (!msg.isRead() && (parentFragment != null && parentFragment.getUserVisibleHint())) {
                showPopBottom(msg);
            }
        }
    }

    private void showPopBottom(InfoMsgQueue.InfoMsg infoMsg) {
        infoMsg.markRead();
        LinearLayout llMessage;
        TextView tvContent;
        ImageButton ibClose;
        ImageButton ibAction;
        if (mCamera != null && !mCamera.getNeedDewarp()) {
            llMessage = llMessageRemind4K;
            tvContent = tvMsgContent4K;
            ibClose = llMessage.findViewById(R.id.ib_msg_close_4k);
            ibAction = llMessage.findViewById(R.id.ib_msg_action_4k);
        } else {
            llMessage = llMessageRemind;
            tvContent = tvMsgContent;
            ibClose = llMessage.findViewById(R.id.ib_msg_close);
            ibAction = llMessage.findViewById(R.id.ib_msg_action);
        }

        if (llMessage.getVisibility() == View.VISIBLE) {
            llMessage.setVisibility(View.GONE);
        }

        llMessage.setBackgroundColor(InfoMsgUtils.getInstance().getColor(mSoftActivity.get(), infoMsg.getType()));
        tvContent.setText(InfoMsgUtils.getInstance().getMessage(mSoftActivity.get(), infoMsg.getType()));

        String action = InfoMsgUtils.getInstance().getAction(mSoftActivity.get(), infoMsg.getType());
        if (TextUtils.isEmpty(action)) {
            ibAction.setVisibility(View.GONE);
        } else {
            ibAction.setVisibility(View.VISIBLE);
            ibAction
                    .setOnClickListener(v -> {
                        if (mCamera != null && mSoftActivity.get() != null) {
                            InfoMsgUtils.getInstance().clickAction(mSoftActivity.get(), mCamera.getSerialNumber(), infoMsg.getType());
                        }
                        llMessage.setVisibility(View.GONE);
                    });
        }

        ibClose.setOnClickListener(v -> llMessage.setVisibility(View.GONE));

        llMessage.setVisibility(View.VISIBLE);
    }

    private void checkSomeMsg(CameraWrapper camera) {
        Observable.create((ObservableOnSubscribe<Optional<SpaceInfo>>) emitter -> {
            try {
                SpaceInfo spaceInfo = SnipeApi.getSpaceInfo();
                Logger.t(TAG).d("spaceInfo: " + spaceInfo);
                emitter.onNext(Optional.ofNullable(spaceInfo));
            } catch (Exception e) {
                e.printStackTrace();
                emitter.onNext(Optional.empty());
            }
        })
                .filter(spaceInfoOptional -> spaceInfoOptional.getIncludeNull() != null)
                .subscribeOn(Schedulers.io())
                .flatMap(spaceInfoOptional -> {
                    SpaceInfo spaceInfo = spaceInfoOptional.get();
                    String spaceNumber = StringUtils.getSpaceNumber(spaceInfo.total);
                    Logger.t(TAG).d("spaceNumber: " + spaceNumber);

                    //16GB sdcard可能出现坏区，小于16，这里写15简单判断下
                    if (Double.parseDouble(spaceNumber) < 15) {
                        camera.getInfoMsgQueue().putMsg(InfoMsgQueue.W_SDCARD_LOW_CAPACITY);
                        return Observable.empty();
                    } else {
                        camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.W_SDCARD_LOW_CAPACITY);

                        if (Constants.isFleet()) {
                            camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_LOG_IN);
                            camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                        } else {
                            CurrentUser currentUser = HornApplication.getComponent().currentUser();
                            Logger.t(TAG).d("currentUser: " + currentUser.getUser());
                            if (currentUser.getUser() == null) {
                                camera.getInfoMsgQueue().putMsg(InfoMsgQueue.I_LOG_IN);
                                return Observable.empty();
                            } else {
                                camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_LOG_IN);

                                ArrayList<CameraBean> devices = currentUser.getDevices();
                                boolean isAdded = false;
                                for (CameraBean item : devices) {
                                    if (item.sn.equals(camera.getSerialNumber())) {
                                        isAdded = true;
                                        break;
                                    }
                                }
                                Logger.t(TAG).d("isAdded: " + isAdded);
                                if (!isAdded) {
                                    camera.getInfoMsgQueue().putMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                                    return Observable.empty();
                                } else {
                                    camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                                }
                            }
                        }
                    }
                    if (camera.getMountVersion() != null && camera.getMountVersion().support_4g) {
                        return ApiService.createApiService().getCurrentSub(camera.getSerialNumber());
                    } else {
                        return Observable.empty();
                    }
                })
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<SubscribeResponse>() {
                    @Override
                    protected void onHandleSuccess(SubscribeResponse data) {
                        onHandleDataPlan(data);
                    }
                });
    }

    private void onHandleDataPlan(SubscribeResponse data) {
        Logger.t(TAG).d("getCurrentSub: " + data.getStatus());
        InfoMsgQueue infoMsgQueue = null;
        if (mCamera != null) {
            infoMsgQueue = mCamera.getInfoMsgQueue();
        }

        if ("in_service".equals(data.getStatus()) || "paid".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        } else if ("none".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.putMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        } else {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        }
    }

    private void onDisconnectCamera() {
        Logger.t(TAG).d("onDisconnectCamera");
        btn_highlight.setVisibility(View.INVISIBLE);
        iv_curStatus.setImageResource(R.drawable.icon_home_offline);
        iv_videoSrc.setImageResource(R.drawable.icon_home_offline);
        ivVideoSrc4K.setImageResource(R.drawable.icon_home_offline);
        mCamera = null;
        stopStream();

        Toast.makeText(mSoftActivity.get(), getResources().getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show();
        LocalLiveActivity.launch(mSoftActivity.get(), true);
    }

    private int mXRadio;
    private int mYRadio;

    @SuppressLint("CheckResult")
    @Override
    protected void onFragmentFirstVisible() {
//        cancelBusy();
        setupToolbar();

        mSoftActivity.get().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        if (getArguments() != null) {
            sn = getArguments().getString(IntentKey.SERIAL_NUMBER);
            tourGuide = getArguments().getBoolean(IntentKey.TOUR_GUIDE, false);
            mStartTimeMs = getArguments().getLong(IntentKey.START_TIME_MS, -1);
        }

        Logger.t(TAG).d("intent sn: " + sn
                + " tourGuide: " + tourGuide
                + " mStartTimeMs: " + mStartTimeMs);

        if (TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCurrentCamera();
        } else {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }
        Logger.t(TAG).d("onCreate mCamera: " + mCamera);

        // init VR Library
        mVRVideoLibrary = createVideoVRLibrary();
        mVRLibrary = createBitmapVRLibrary();
        mVRCloudLibrary = createCloudLibrary();

        initView();
        updateCameraStateUI();

        initPlayControl();

//        intervalCheck();

        initTypeView();

        initNaviView();

        setupSeekbar();

        mRefreshHandler = new RefreshHandler(this);

        if (mCamera != null && mCamera.getClipsManager() != null) {
            mCamera.getClipsManager().clipList()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(clipList -> viewModel.filterClip(clipList, filterList), new ServerErrorHandler(TAG));
        }

        viewModel.getCurrentUser().devicesObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(optional -> {
                    int size = optional.get().size();
                    tvSlidingTips.setVisibility(size <= 1 ? View.INVISIBLE : View.VISIBLE);
                }, new ServerErrorHandler(TAG));

        viewModel.outputs.playerControl()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::controlPlayer, new ServerErrorHandler(TAG));

        viewModel.outputs.videoProgress()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::checkProgress, new ServerErrorHandler(TAG));

        viewModel.outputs.clipPosChanged()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::refreshHighlightButton, new ServerErrorHandler(TAG));

        viewModel.outputs.getThumbnail()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::fetchThumbnail, new ServerErrorHandler(TAG));

        viewModel.outputs.loadClips()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipList, new ServerErrorHandler(TAG));

        viewModel.outputs.loadClipBeans()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipListStat, new ServerErrorHandler(TAG));

        viewModel.outputs.filterVisibility()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onfilterVisibility, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(ClipPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipPosChangeEvent, new ServerErrorHandler());

        RxBus.getDefault().toObservable(ClipBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipBeanPosChangeEvent, new ServerErrorHandler());

        RxBus.getDefault().toObservable(EventBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventBeanPosChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(CameraStateChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraStateChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(ClipInfoMsgEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipInfoMsgEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(SettingChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSettingChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(LensChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLensChangeEvent, new ServerErrorHandler(TAG));

        if (mStartTimeMs != -1) {
            if (videosFragment != null) {
                Menu menu = mCamera.getNeedDewarp() ? toolbar.getMenu() : toolbar4K.getMenu();
                MenuItem item = menu.findItem(R.id.action_setting);
                if (item != null) item.setVisible(false);
                videosFragment.scrollToStartTime(mStartTimeMs);
            }
        }
    }

    private void adaptationFor4K(boolean needDewarp, boolean liveView) {
        Logger.t(TAG).d("adaptationFor4K needDewarp: " + needDewarp + " liveView: " + liveView);
        if (TextUtils.isEmpty(sn)) {
            return;
        }
        Logger.t(TAG).i("adaptationFor4K sn = " + sn);
        if (sn.startsWith("6")) {
            if (liveView) {
                mXRadio = 32;
                mYRadio = 27;
                toolbar.setVisibility(View.GONE);
                toolbar4K.setVisibility(View.VISIBLE);
                llViewStatus.setVisibility(View.GONE);
                btnEvCamStreamPort.setVisibility(View.GONE);
                btnEvCamStreamLand.setVisibility(View.GONE);
                ivVideoSrc4K.setImageResource(R.drawable.icon_live_view);
                tvToolbarTitle4K.setText(R.string.to_live);
            } else {
                String[] descriptions = mClipPos.clip.descriptions;
                Logger.t(TAG).d("descriptions: " + Arrays.toString(descriptions));
                if (descriptions == null || descriptions.length == 0 || TextUtils.isEmpty(descriptions[0])) {
                    mXRadio = 16;
                    mYRadio = 9;
                    viewModel.inputStreamIndex(1); // 默认sd stream
                } else {
                    VideoStreamType mStreamType = viewModel.mStreamType;
                    switch (mStreamType) {
                        case Road:
                        case Incab:
                            mXRadio = 16;
                            mYRadio = 9;
                            break;
                        case Panorama:
                            mXRadio = 32;
                            mYRadio = 27;
                            break;
                        case Driver:
                            mXRadio = 4;
                            mYRadio = 3;
                            break;
                    }
                    // 默认 panorama stream
                    int descriptionIndex = mClipPos.clip.getDescriptionIndex(mStreamType);
                    Logger.t(TAG).d("descriptionIndex: " + descriptionIndex);
                    viewModel.inputStreamIndex(descriptionIndex);
                }
            }
        } else {
            mXRadio = 16;
            mYRadio = 9;
            if (liveView) viewModel.inputStreamIndex(1); // 默认sd stream
            if (!isFullScreen()) {
                toolbar.setVisibility(View.VISIBLE);
                toolbar4K.setVisibility(View.GONE);
                llViewStatus.setVisibility(View.VISIBLE);
            }
        }
        mMediaWindow.setRatio(mXRadio, mYRadio);
        btnProjection_land.setVisibility(needDewarp ? View.VISIBLE : View.GONE);
        btnProjection_port.setVisibility(needDewarp ? View.VISIBLE : View.GONE);
        if (isFullScreen()) {
            adaptationForLandscape();
        }
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_camera_view;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);
    }

    private void initNaviView() {
        naviViewTemp.enableAnimation(false);
        naviViewTemp.setLabelVisibilityMode(LABEL_VISIBILITY_LABELED);
        naviViewTemp.setItemHorizontalTranslationEnabled(false);

        naviViewTemp.setIconSize(48, 32);
        naviViewTemp.setTextSize(10f);
        naviViewTemp.setIconsMarginTop((int) getResources().getDimension(R.dimen.dp_1));
    }

    private void onfilterVisibility(Integer integer) {
        Logger.t(TAG).d("onfilterVisibility: " + integer);
        //always visible
        rlFilter.setVisibility(integer);

        if (videosFragment != null && videosFragment.viewModel() != null) {
            videosFragment.viewModel().filterVisibility(View.GONE);
        }
        if (remoteVideoFragment != null && remoteVideoFragment.viewModel() != null) {
            remoteVideoFragment.viewModel().filterVisibility(View.GONE);
        }
    }

    private void onClipList(List<Clip> clips) {
        int size = clips.size();
        Logger.t(TAG).d("onClipList size: " + size);

        if (rb_sdcard.isChecked()) {
            tv_event_num.setText(String.valueOf(size));
        }
    }

    private void onClipListStat(int size) {
        Logger.t(TAG).d("onClipListStat size: " + size);

        if (rb_cloud.isChecked()) {
            tv_event_num.setText(String.valueOf(size));
        }
    }

    /**
     * 初始化videos filter选项
     */
    private void initTypeView() {

        rg_source.check(R.id.rb_sdcard);

        rg_source.setOnCheckedChangeListener((group, checkedId) -> {
//            Logger.t(TAG).d("onCheckedChanged: " + checkedId);

            if (checkedId == R.id.rb_sdcard) {
                rb_sdcard.setTextColor(getResources().getColor(R.color.colorAccent));
                rb_cloud.setTextColor(getResources().getColor(R.color.white));

                if (rvType.getVisibility() == View.INVISIBLE) {
                    rvType.setVisibility(View.VISIBLE);
                }

                if (remoteVideoFragment != null && videosFragment != null) {
                    //
                    try {
                        getChildFragmentManager().beginTransaction()
                                .hide(remoteVideoFragment)
                                .show(videosFragment)
                                .commit();
                    } catch (Exception ex) {
                        Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
                    }
                }

                if (remoteVideoFragment != null) {
                    remoteVideoFragment.onToLiveClick();
                }
                if (mCamera != null && mCamera.getClipsManager() != null) {
                    viewModel.filterClip(mCamera.getClipsManager().getClipList(), filterList);
                }
                if (videosFragment != null && videosFragment.viewModel() != null) {
                    videosFragment.viewModel().loadClips(filterList, true);
                }

            } else if (checkedId == R.id.rb_cloud) {
                rb_sdcard.setTextColor(getResources().getColor(R.color.white));
                rb_cloud.setTextColor(getResources().getColor(R.color.colorAccent));

                if (Constants.isFleet()) {
                    rvType.setVisibility(View.INVISIBLE);
                }

                if (videosFragment != null && remoteVideoFragment != null) {
                    //
                    try {
                        getChildFragmentManager().beginTransaction()
                                .hide(videosFragment)
                                .show(remoteVideoFragment)
                                .commit();
                    } catch (Exception ex) {
                        Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
                    }
                }

                if (videosFragment != null) {
                    videosFragment.onToLiveClick();
                }
                if (remoteVideoFragment != null) {
                    viewModel.filterClipBean(remoteVideoFragment.clipListStat, filterList);
                    if (remoteVideoFragment.viewModel() != null) {
                        remoteVideoFragment.viewModel().loadClipBean(filterList, true);
                    }
                }
            }
        });

        GridLayoutManager layoutManager = new GridLayoutManager(mSoftActivity.get(), 3);
        rvType.setLayoutManager(layoutManager);

        List<VideoType> dataList = new ArrayList<>();
        dataList.add(new VideoType(R.drawable.bg_type_motion, getString(R.string.video_type_motion)));
        dataList.add(new VideoType(R.drawable.bg_type_bump, getString(R.string.video_type_bump)));
        dataList.add(new VideoType(R.drawable.bg_type_impact, getString(R.string.impact)));

        if (Constants.isFleet()) {
            dataList.add(new VideoType(R.drawable.bg_type_behavior, getString(R.string.behavior)));
        }

        dataList.add(new VideoType(R.drawable.bg_type_highlight, getString(R.string.video_type_highlight)));
        dataList.add(new VideoType(R.drawable.bg_type_buffered, getString(R.string.video_type_buffered)));

        TypeAdapter adapter = new TypeAdapter(mSoftActivity.get(), R.layout.item_video_type, dataList);
        rvType.setAdapter(adapter);

        adapter.setOnItemChildClickListener((adapter1, view, position) -> {
//            CheckBox checkBox = view.findViewById(R.id.cb_type);
//            Logger.t(TAG).d("onItemChildClick: " + position + "--" + checkBox.isChecked());

            List<VideoType> data = adapter.getData();
            filterList.clear();

            for (VideoType item : data) {
                String itemEvent = item.getEvent();
                if (item.isSelected()) {
//                    Logger.t(TAG).d("selected: " + data.indexOf(item));
                    filterList.add(itemEvent);
                } else if (filterList.contains(itemEvent)) {
                    filterList.remove(itemEvent);
                }
            }

            int resource = 0;
            if (filterList.size() == 0) {
                resource = R.drawable.btn_funnel;
            } else if (filterList.size() == 1) {
                String s = filterList.get(0);
                if (s.equals(getString(R.string.video_type_motion))) {
                    resource = R.drawable.icon_type_motion;
                } else if (s.equals(getString(R.string.video_type_bump))) {
                    resource = R.drawable.icon_type_bump;
                } else if (s.equals(getString(R.string.impact))) {
                    resource = R.drawable.icon_type_impact;
                } else if (s.equals(getString(R.string.video_type_highlight))) {
                    resource = R.drawable.icon_type_highlight;
                } else if (s.equals(getString(R.string.video_type_buffered))) {
                    resource = R.drawable.icon_type_buffered;
                } else if (s.equals(getString(R.string.behavior))) {
                    resource = R.drawable.icon_type_behavior;
                }
            } else {
                resource = R.drawable.btn_funnel_multiple;
            }

            if (rb_sdcard.isChecked()) {
                if (mCamera != null && mCamera.getClipsManager() != null) {
                    viewModel.filterClip(mCamera.getClipsManager().getClipList(), filterList);
                }
                if (videosFragment != null && videosFragment.viewModel() != null) {
                    videosFragment.viewModel().loadClips(filterList, true);
                }
            } else if (rb_cloud.isChecked()) {
                viewModel.filterClipBean(remoteVideoFragment.clipListStat, filterList);
                if (remoteVideoFragment != null && remoteVideoFragment.viewModel() != null) {
                    remoteVideoFragment.viewModel().loadClipBean(filterList, true);
                }
            }
            if (videosFragment != null && videosFragment.viewModel() != null) {
                videosFragment.viewModel().filterResource(resource);
            }
            if (remoteVideoFragment != null && remoteVideoFragment.viewModel() != null) {
                remoteVideoFragment.viewModel().filterResource(resource);
            }
        });
    }

    private GuideLayout projectionLayout;
    private GuideLayout pinchLayout;

    private void glintView(View view) {
        AlphaAnimation animation = new AlphaAnimation(1f, 0.3f);
        animation.setDuration(800);
        animation.setInterpolator(new LinearInterpolator());
        animation.setRepeatCount(Integer.MAX_VALUE);
        animation.setRepeatMode(REVERSE);
        view.startAnimation(animation);
    }

    private void initView() {
        if (tourGuide) {
            View projectionView = LayoutInflater.from(mSoftActivity.get()).inflate(R.layout.view_switch_projection, null);
            projectionView.findViewById(R.id.layout_guide_switch)
                    .findViewById(R.id.btn_go_guide).setVisibility(View.GONE);

            ivGuideSwitch.setVisibility(View.VISIBLE);
            glintView(ivGuideSwitch);

            projectionLayout = GuideLayout.Builder
                    .newInstance(mSoftActivity.get())
                    .setTargetView(rl_media)
                    .setCustomGuideView(projectionView)
                    .setDirction(GuideLayout.Direction.BOTTOM)
                    .setShape(GuideLayout.MyShape.RECTANGLE)
                    .setBgColor(getResources().getColor(R.color.colorRed))
                    .setOnclickListener(new GuideLayout.OnClickCallback() {
                        @Override
                        public void onSkipGuideView() {
                            popSkipGuide(GUIDE_STEP.SWITCH_PROJECTION);
                        }

                        @Override
                        public void onNextGuideView() {
                        }
                    })
                    .build();

            projectionLayout.show();

            View pinchView = LayoutInflater.from(mSoftActivity.get()).inflate(R.layout.include_guide_skiporgo, null);

            pinchLayout = GuideLayout.Builder
                    .newInstance(mSoftActivity.get())
                    .setTargetView(rl_media)
                    .setCustomGuideView(pinchView)
                    .setDirction(GuideLayout.Direction.BOTTOM)
                    .setShape(GuideLayout.MyShape.RECTANGLE)
                    .setBgColor(getResources().getColor(R.color.colorRed))
                    .setOnclickListener(new GuideLayout.OnClickCallback() {
                        @Override
                        public void onSkipGuideView() {
                            popSkipGuide(GUIDE_STEP.PINCH_DRAG);
                        }

                        @Override
                        public void onNextGuideView() {
                            pinchLayout.hide();
                            ll_pinch_drag.setVisibility(View.GONE);
                            va_guide.setVisibility(View.VISIBLE);
                            hideNavigation();
                            va_guide.setOnTouchListener((v, event) -> true);

                            tapShadow = va_guide.findViewById(R.id.iv_export_tapShadow);
                            glintView(tapShadow);

//                            if (tvNotRecording.getVisibility() == View.VISIBLE) {
//                                va_guide.findViewById(R.id.tv_export_margin).setVisibility(View.INVISIBLE);
//                            }

                            rootView.findViewById(R.id.btn_go_guide).setVisibility(View.GONE);
                            rootView.findViewById(R.id.tv_skip_guide).setOnClickListener(v -> {
                                popSkipGuide(GUIDE_STEP.TAP_VIEW);
                            });

                            FrameLayout frameLayout = va_guide.findViewById(R.id.fl_export);
                            frameLayout.post(() -> {
                                //用thumbnail中间坐标，获取第一个clip
                                float x = frameLayout.getLeft() + frameLayout.getWidth() / 2;
                                float y = frameLayout.getHeight() / 2 + ViewUtils.dp2px(80);
//                                Logger.t(TAG).d("export Thumbnail: " + x + " " + y);

                                if (videosFragment != null) {
                                    Clip posClip = videosFragment.getCurrentPosClip(x, y);
                                    if (posClip == null) {
                                        return;
                                    }

                                    String type = VideoEventType.getEventTypeForString(posClip.getVideoType());
                                    Logger.t(TAG).d("export Type: " + type);
                                    viewExport.setBackgroundResource(VideoEventType.getEventDrawable(type));

                                    Glide.with(mSoftActivity.get())
                                            .using(new SnipeGlideLoader(VdtCameraManager.getManager().getCurrentVdbRequestQueue(), false))
                                            .load(new ClipPos(posClip))
                                            //.override(256, 256)
                                            .transform(new TwoDirectionTransform(mSoftActivity.get(), posClip.isLensNormal()))
                                            .diskCacheStrategy(DiskCacheStrategy.ALL)
                                            //.crossFade()
                                            .placeholder(R.drawable.bg_single_thumbnail)
                                            .into(iv_export_thumbnail);
                                }
                            });
                        }
                    })
                    .build();
        }

        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();

        videosFragment = VideosFragment.newInstance(TextUtils.isEmpty(sn) ? null : sn);
        transaction.add(R.id.frameLayout, videosFragment);
        transaction.show(videosFragment);

        if (mCamera != null && mCamera.getMountVersion() != null
                && mCamera.getMountVersion().support_4g
                && !Constants.isFleet()) {
            rb_cloud.setVisibility(View.VISIBLE);

            if (Constants.isFleet()) {
                FleetCameraBean fleetCameraBean = viewModel.getCurrentUser().getFleetCamera(mCamera.getSerialNumber());
                remoteVideoFragment = RemoteVideoFragment.newInstance(fleetCameraBean);
            } else {
                CameraBean camera = viewModel.getCurrentUser().getCamera(mCamera.getSerialNumber());
                remoteVideoFragment = RemoteVideoFragment.newInstance(camera);
            }
            transaction.add(R.id.frameLayout, remoteVideoFragment);
            transaction.hide(remoteVideoFragment);
        }

        if (Constants.isFleet() && mCamera != null && mCamera.getHardwareModel() == ICameraWrapper.Model.TW06 && mCamera.isCalibCameraAvailable()) {
            btnEvCamFaceId.setVisibility(View.VISIBLE);

            faceIdFragment = FaceIdFragment.newInstance(sn);
            transaction.add(R.id.frameLayout, faceIdFragment);
            transaction.hide(faceIdFragment);
        }
        //
        try {
            transaction.commit();
        } catch (Exception ex) {
            Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
        }

//        viewPager.setAdapter(mPagerAdapter);
//        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
//            @Override
//            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
//            }
//
//            @Override
//            public void onPageSelected(int position) {
//                Logger.t(TAG).e("onPageSelected: " + position);
//                if (position == 0) {
//                    startStream(mjpegAddress);
//                    if (mMediaPlayerWrapper != null) {
//                        mMediaPlayerWrapper.resume();
//                    }
//                    if (simpleExoPlayer != null) {
//                        simpleExoPlayer.setPlayWhenReady(false);
//                    }
//                } else if (position == 1) {
//                    stopStream();
//                    if (mMediaPlayerWrapper != null) {
//                        mMediaPlayerWrapper.pause();
//                    }
//                    if (simpleExoPlayer != null) {
//                        simpleExoPlayer.setPlayWhenReady(true);
//                    }
//                }
//            }
//
//            @Override
//            public void onPageScrollStateChanged(int state) {
//            }
//        });
//        tabLayout.setupWithViewPager(viewPager);
//        if (fragments.size() <= 1) {
//            tabLayout.setSelectedTabIndicatorHeight(0);
//        }
    }

    private void popSkipGuide(GUIDE_STEP step) {
        View view = LayoutInflater.from(mSoftActivity.get()).inflate(R.layout.pop_skip_guide, null);
        PopupWindow popupWindow = new PopupWindow(view, CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT, true);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.iv_close_pop).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.btn_continue_guide).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.tv_skip_guide).setOnClickListener(v -> {
            popupWindow.dismiss();
            switch (step) {
                case SWITCH_PROJECTION:
                    tourGuide = false;
                    projectionLayout.hide();
                    ivGuideSwitch.setVisibility(View.GONE);
                    ivGuideSwitch.clearAnimation();
                    break;
                case PINCH_DRAG:
                    pinchLayout.hide();
                    ll_pinch_drag.setVisibility(View.GONE);
                    break;
                case TAP_VIEW:
                case EXPORT_INFO:
                    tapShadow.clearAnimation();
                    va_guide.setVisibility(View.GONE);
                    showNavigation();
                    break;
            }
        });

        popupWindow.showAsDropDown(toolbar);
    }

    /**
     * 初始化横竖屏切换，SD/HD切换
     */
    private void initPlayControl() {
        Action mControlPanelAction = () -> {
            if (isFullScreen()) {
                hideControlPanel();
                setImmersiveMode(true);
            }
        };
        mHandler = new ControlPanelHandler(mControlPanelAction);
    }

    private void onLensChangeEvent(LensChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            boolean lensNormal = event.isLensNormal();
            Logger.t(TAG).d("onLensChangeEvent: " + lensNormal);
            if (mVRLibrary != null) {
                switchProjection(mVRLibrary, lensNormal);
            }
        }
    }

    private void onSettingChangeEvent(SettingChangeEvent event) {
        Logger.t(TAG).d("onSettingChangeEvent: " + event.getAction() + "--" + event.isUpdated());
        if (SettingChangeEvent.ACTION_FAILURE.equals(event.getAction())) {
            ll_setting_request.setVisibility(View.VISIBLE);
            new Handler().postDelayed(() -> ll_setting_request.setVisibility(View.GONE), 6000);
        }
    }

    private void onClipInfoMsgEvent(ClipInfoMsgEvent event) {
        //Logger.t(TAG).d("%s", "clipInfoMsgEvent");
        CameraWrapper camera = event.getCamera();
        if (camera != null && mCamera != null && camera.getSerialNumber().equals(mCamera.getSerialNumber())) {
            ClipActionInfo actionInfo = event.getClipActionInfo();

            if (actionInfo.action == ClipActionInfo.CLIP_ACTION_CREATED) {
                Logger.t(TAG).d("%s", "new clip created");
                Clip tempClip = actionInfo.clip;
                if (tempClip != null) {
                    SnipeApi.getSingleClipRx(tempClip.cid, tempClip.videoType, tempClip.getNeedDewarp())
                            .filter(ObjectUtils::isNotNull)
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(newClip -> {
                                if (camera != null && camera.getClipsManager() != null) {
                                    //此时的clip尚未init attitude，默认直播时新生成的clip与相机状态一致
                                    if (actionInfo.isLive) {
                                        newClip.setNeedDewarp(camera.getNeedDewarp());
                                        newClip.setLensNormal(camera.getIsLensNormal());
                                    }
                                    boolean addClip = camera.getClipsManager().addClip(newClip);
                                    Logger.t(TAG).e("addClip: " + addClip + " attitude: " + newClip.isLensNormal()
                                            + " " + newClip.getNeedDewarp());
                                    if (addClip) {
                                        videosFragment.viewModel().loadClips(viewModel.filterList, true);
                                    }
                                }

                                if (actionInfo.isLive) {

                                } else {
                                    viewModel.setDownloadClip(newClip);
                                    showPopWindow(R.layout.view_clip_export, false);

                                    ClipPos curClipPos = new ClipPos(newClip, 0);
                                    ClipPosChangeEvent changeEvent = new ClipPosChangeEvent(curClipPos, TAG);
                                    RxBus.getDefault().post(changeEvent);
                                }
                            });
                }
            } else if (actionInfo.action == ClipActionInfo.CLIP_ACTION_CHANGED && actionInfo.isLive) {
//                Logger.t(TAG).d("%s", "new clip changed");
                //停留在前台时clip每隔5s刷新
                if (isForeground) {
                    if (!mRefreshHandler.hasMessages(REFRESH_TAG)) {
                        Message obtain = Message.obtain();
                        obtain.obj = actionInfo.clip;
                        obtain.what = REFRESH_TAG;
                        mRefreshHandler.sendMessageDelayed(obtain, 5000);
                    }
                }
            }
        }
    }

    private void showPopWindow(int layoutId, boolean cancel) {
        if (mPopWindow != null) {
            mPopWindow.dismiss();
        }

        View view = LayoutInflater.from(mSoftActivity.get()).inflate(layoutId, null);

        mPopWindow = new PopupWindow(view, ViewUtils.dp2px(108), ViewUtils.dp2px(60), false);

        ImageView iv_scene = mPopWindow.getContentView().findViewById(R.id.iv_scene);

        Clip clip = viewModel.getDownloadClip();
        ClipPos clipPos = new ClipPos(clip);

        Glide.with(mSoftActivity.get())
                .using(new SnipeGlideLoader(mCamera.getRequestQueue(), false))
                .load(clipPos)
                .transform(new TwoDirectionTransform(mSoftActivity.get(), clip.isLensNormal()))
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .crossFade()
                .into(iv_scene);

        mPopWindow.getContentView().findViewById(R.id.cl_background).setOnClickListener(v -> {
            mPopWindow.dismiss();

            if (cancel) {
                DownloadManager.getManager().cancelCurrentJob(false);
                exitDownload(false);
            } else {
                enterDownload();
                viewModel.inputs.download(clip, clip.getDurationMs(), 0);
            }
        });
        viewModel.inputs.clipPosChanged(clipPos);
        mPopWindow.showAsDropDown(btn_highlight, -mPopWindow.getWidth() + btn_highlight.getWidth(), -(int) (mPopWindow.getHeight() * (19f / 40)) - btn_highlight.getHeight() / 2, Gravity.NO_GRAVITY);

        new Handler().postDelayed(() -> mPopWindow.dismiss(), 5000);
    }

    private void enterDownload() {
        pb_highlight.setVisibility(View.VISIBLE);
        pb_highlight.setProgress(5);
        btn_highlight.setEnabled(false);

        //暂停播放
        onBtnPlayPauseClicked();

        pollExportEvent = viewModel.exportJobEvent()
                .compose(bindUntilEvent(FragmentEvent.DETACH))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onExportEvent, new ServerErrorHandler());
    }

    private void onExportEvent(Optional<ExportEvent> eventOptional) {
        ExportEvent event = eventOptional.getIncludeNull();
        if (event == null || !event.getSymbol().equals(TAG)) {
            return;
        }
        switch (event.getType()) {
            case ExportEvent.EVENT_TYPE_INIT:
                ClipDownloadInfo.StreamDownloadInfo downloadInfo = event.getJob().getDownloadInfo();
                File videoDir = new File(FileUtils.getVideoExportPath());
                if (videoDir.getUsableSpace() < 2 * downloadInfo.size) {
                    Logger.t(TAG).e("getUsableSpace: " + videoDir.getUsableSpace() + "--" + 2 * downloadInfo.size);
                    Toast.makeText(mSoftActivity.get(), R.string.not_enough_storage, Toast.LENGTH_SHORT).show();
                    exitDownload(false);
                }
                break;
            case ExportEvent.EVENT_TYPE_PROCESS:
                int i = event.getJob().getExportProgress() * 2;
                pb_highlight.setProgress(i < 5 ? 5 : i);
                break;
            case ExportEvent.EVENT_TYPE_END:
                if (event.getJob().isFinished()) {
                    exitDownload(true);
                }
                break;
        }
    }

    private void exitDownload(boolean success) {
        pb_highlight.setVisibility(View.INVISIBLE);
        btn_highlight.setEnabled(true);

        //恢复播放
        onBtnPlayPauseClicked();

        if (success && isForeground) {
            hideNavigation();
            includeHighlightSuccess.setVisibility(View.VISIBLE);
            naviViewTemp.post(this::highlightAnim);
        }

        if (pollExportEvent != null && !pollExportEvent.isDisposed()) {
            pollExportEvent.dispose();
        }
    }

    private void checkProgress(Optional<Void> voidOptional) {
        if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer() != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {

            long currentPos = mMediaPlayerWrapper.getPlayer().getCurrentPosition();
//            Logger.t(TAG).d("ijkPlayer checkProgress: " + viewModel.isLiveOrNot);

            if (!viewModel.isLiveOrNot) {
                refreshProgress(currentPos, false);
                long duration = mMediaPlayerWrapper.getPlayer().getDuration();
                int durationMs = mClipPos.getClip().getDurationMs();

                if (duration > 0 && isFullScreen()) {
                    tvVideoProgress.setText(DateUtils.formatElapsedTime((currentPos
                            + mClipPos.getClipTimeMs()) / 1000));
                    tvVideoDuration.setText(DateUtils.formatElapsedTime(durationMs / 1000));
                    sbVideo.setMax(durationMs);
                    sbVideo.setProgress((int) (currentPos + mClipPos.getClipTimeMs()));
                }
            }
        } else if (simpleExoPlayer != null && simpleExoPlayer.getPlayWhenReady()) {

            long currentPos = simpleExoPlayer.getCurrentPosition();
//            Logger.t(TAG).d("exoPlayer checkProgress: " + viewModel.isLiveOrNot);

            if (!viewModel.isLiveOrNot) {
                refreshProgress(currentPos, true);
                long duration = simpleExoPlayer.getDuration();
                if (duration > 0 && isFullScreen()) {
                    tvVideoProgress.setText(DateUtils.formatElapsedTime(currentPos / 1000));
                    tvVideoDuration.setText(DateUtils.formatElapsedTime(duration / 1000));
                    sbVideo.setMax((int) (duration));
                    sbVideo.setProgress((int) (currentPos));
                }
            }
        }
    }

    private void onCameraStateChangeEvent(CameraStateChangeEvent event) {
        Logger.t(TAG).d("onHandleCameraStateChangeEvent = " + event.getWhat());

        switch (event.getWhat()) {
            case CameraStateChangeEvent.CAMERA_STATE_REC:
                updateCameraStateUI();
                break;
            case CameraStateChangeEvent.CAMERA_STATE_REC_ERROR:
                int error = (Integer) event.getExtra();
                Logger.t(TAG).d("On Rec Error: " + error);
                break;
        }
    }

    private void updateCameraStateUI() {
        int recordState;
        if (mCamera != null) {
            recordState = mCamera.getRecordState();
            int imageRes = BatteryImageViewResHelper.getBatteryViewWhiteRes(mCamera.getBatteryLevel(),
                    mCamera.getBatteryState(), mCamera.getVoltageNow());
//            if (imageRes > 0) {
//                iv_batteryStatus.setBackgroundResource(imageRes);
//                iv_batteryStatus.setVisibility(View.VISIBLE);
//            } else {
//                iv_batteryStatus.setVisibility(View.GONE);
//            }

            Logger.t(TAG).d("%s", "record state = " + recordState);
            switch (recordState) {
                case VdtCamera.STATE_RECORD_STOPPED:
                    if (viewModel.isLiveOrNot) {
                        iv_curStatus.setImageDrawable(null);
                        iv_videoSrc.setImageDrawable(null);
                        ivVideoSrc4K.setImageDrawable(null);
                    }
                    if (!isFullScreen()) {
//                        tvNotRecording.setVisibility(View.VISIBLE);
                    }
                    btn_highlight.setVisibility(View.INVISIBLE);
                    switch_recording_port.setChecked(false);
                    switch_recording_land.setChecked(false);
                    tv_recording_port.setText(R.string.record_idle);
                    tv_recording_land.setText(R.string.record_idle);

                    //btn_record.setVisibility(View.VISIBLE);
                    break;
                case VdtCamera.STATE_RECORD_STOPPING:
//                    scaleView(tvNotRecording, ViewUtils.dp2px(27), 0);
                    break;
                case VdtCamera.STATE_RECORD_STARTING:
//                    scaleView(tvNotRecording, 0, ViewUtils.dp2px(27));
                    break;
                case VdtCamera.STATE_RECORD_RECORDING:
                    if (viewModel.isLiveOrNot) {
                        iv_curStatus.setImageResource(R.drawable.icon_live_view);
                        iv_videoSrc.setImageResource(R.drawable.icon_live_view);
                        ivVideoSrc4K.setImageResource(R.drawable.icon_live_view);
                        btn_highlight.setVisibility(Constants.isFleet() ? View.INVISIBLE : View.VISIBLE);
                    }
//                    tvNotRecording.setVisibility(View.GONE);
                    switch_recording_port.setChecked(true);
                    switch_recording_land.setChecked(true);
                    tv_recording_port.setText(R.string.recording);
                    tv_recording_land.setText(R.string.recording);
                    break;
                default:
                    break;
            }
        }
    }

    /**
     * 设置seekbar
     */
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

                if (glVideoSurfaceView.isShown() && mMediaPlayerWrapper != null) {
                    try {
                        mMediaPlayerWrapper.pause();
                        mMediaPlayerWrapper.getPlayer().seekTo(progress);
                        mMediaPlayerWrapper.getPlayer().setOnSeekCompleteListener(IMediaPlayer::start);
                    } catch (Exception ex) {
                        Logger.t(TAG).e("onStopTrackingTouch error = " + ex.getMessage());
                    }
                }

                if (glCloudSurfaceView.isShown() && simpleExoPlayer != null) {
                    simpleExoPlayer.seekTo(progress);
                    simpleExoPlayer.setPlayWhenReady(true);
                }
            }
        });
    }

    private void onClipPosChangeEvent(ClipPosChangeEvent event) {
        if (event.getPublisher().equals(VideosFragment.class.getSimpleName())) {

            updateUI(event.getIntent(), false);

            if (event.getClipPos() != null) {
                viewModel.isLiveOrNot(false);

                if (event.getIntent() == ClipPosChangeEvent.INTENT_PLAY) {
//                    Logger.t(TAG).d("ClipPosChangeEvent INTENT_PLAY: " + event.getClipPos().getClipTimeMs());
                    mClipPos = event.getClipPos();

                    initVideoPlayer(event.getClipPos());
                } else if (event.getIntent() == ClipPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).d("ClipPosChangeEvent INTENT_SHOW_THUMBNAIL");

                    // TODO: 2019-12-11 fix 快速请求thumbnail卡顿
//                    ClipPos clipPos = event.getClipPos();
//                    viewModel.fetchThumbnail(clipPos);

                    if (mMediaPlayerWrapper != null) {
                        mMediaPlayerWrapper.pause();
                    }
                }
            } else if (event.getIntent() == ClipPosChangeEvent.INTENT_LIVE && mCamera != null) {
                Logger.t(TAG).d("ClipPosChangeEvent INTENT_LIVE");
                viewModel.isLiveOrNot(true);

                if (Constants.isFleet()) {
                    ll_record_port.setVisibility(View.INVISIBLE);
                    ll_record_land.setVisibility(View.INVISIBLE);
                } else {
                    ll_record_port.setVisibility(View.VISIBLE);
                    ll_record_land.setVisibility(View.VISIBLE);
                }
                btnPlayPause_port.setVisibility(View.INVISIBLE);
                btnPlayPause_land.setVisibility(View.INVISIBLE);

                if (mMediaPlayerWrapper != null) {
                    mMediaPlayerWrapper.destroy();
                }
                if (mCamera != null) {
                    adaptationFor4K(mCamera.getNeedDewarp(), true);
                    refreshPipeline(mCamera);
                }
            }
        }
    }

    private void onClipBeanPosChangeEvent(ClipBeanPosChangeEvent event) {
        if (event.getPublisher().equals(RemoteVideoFragment.class.getSimpleName())) {

            updateUI(event.getIntent(), true);

            if (event.getClipBeanPos() != null) {
                viewModel.isLiveOrNot(false);

                if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY) {
                    Logger.t(TAG).d("ClipBeanPosChangeEvent INTENT_PLAY");
                    //获得播放的clipbeanpos
                    mClipBeanPos = event.getClipBeanPos();

                    ClipBean clipBean = mClipBeanPos.getClipBean();
                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(mVRCloudLibrary, lensMode);

                    initCloudPlayer(event.getClipBeanPos().getClipBean().url);
                } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).d("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");

                    ClipBean clipBean = event.getClipBeanPos().getClipBean();
                    viewModel.fetchThumbnail(clipBean.thumbnail);

                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(mVRLibrary, lensMode);

                    if (simpleExoPlayer != null) {
                        simpleExoPlayer.setPlayWhenReady(false);
                    }
                }
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE && mCamera != null) {
                Logger.t(TAG).d("ClipBeanPosChangeEvent INTENT_LIVE");
                viewModel.isLiveOrNot(true);

                if (Constants.isFleet()) {
                    ll_record_port.setVisibility(View.INVISIBLE);
                    ll_record_land.setVisibility(View.INVISIBLE);
                } else {
                    ll_record_port.setVisibility(View.VISIBLE);
                    ll_record_land.setVisibility(View.VISIBLE);
                }
                btnPlayPause_port.setVisibility(View.INVISIBLE);
                btnPlayPause_land.setVisibility(View.INVISIBLE);

                if (simpleExoPlayer != null) {
                    simpleExoPlayer.setPlayWhenReady(false);
                }
                refreshPipeline(mCamera);
            }
        }
    }

    private void onEventBeanPosChangeEvent(EventBeanPosChangeEvent event) {
        if (!event.getPublisher().equals(RemoteVideoFragment.class.getSimpleName())) {
            return;
        }

        updateUI(event.getIntent(), true);

        if (event.getClipBeanPos() != null) {
            viewModel.isLiveOrNot(false);

            if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY) {
                Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_PLAY");

                //获得播放的clipbeanpos
                mEventBeanPos = event.getClipBeanPos();

                EventBean eventBean = mEventBeanPos.getEventBean();
                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(mVRCloudLibrary, lensMode);

                initCloudPlayer(eventBean.getMp4Url());
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");

                EventBean eventBean = event.getClipBeanPos().getEventBean();

                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(mVRLibrary, lensMode);

//                fetchThumbnail(eventBean.thumbnail, false);

                if (simpleExoPlayer != null) {
                    simpleExoPlayer.setPlayWhenReady(false);
                }
            }
        } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE && mCamera != null) {
            Logger.t(TAG).d("ClipBeanPosChangeEvent INTENT_LIVE");
            viewModel.isLiveOrNot(true);

            if (Constants.isFleet()) {
                ll_record_port.setVisibility(View.INVISIBLE);
                ll_record_land.setVisibility(View.INVISIBLE);
            } else {
                ll_record_port.setVisibility(View.VISIBLE);
                ll_record_land.setVisibility(View.VISIBLE);
            }
            btnPlayPause_port.setVisibility(View.INVISIBLE);
            btnPlayPause_land.setVisibility(View.INVISIBLE);

            if (simpleExoPlayer != null) {
                simpleExoPlayer.setPlayWhenReady(false);
            }
            refreshPipeline(mCamera);
        }
    }

    private void switchProjection(MDVRLibrary library, boolean isLensNormal) {
        if (library == null) {
            return;
        }
        int projectionMode = library.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode + " isLensNormal: " + isLensNormal);

        int switchMode = -1;
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

        Logger.t(TAG).d("switchMode: " + switchMode);

        if (switchMode != -1) {
            library.switchProjectionMode(mSoftActivity.get(), switchMode);
        }
    }

    private void switchProjection(MDVRLibrary library, boolean isLensNormal, boolean needDewarp) {
        if (library == null) {
            return;
        }
        int projectionMode = library.getProjectionMode();
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
            switchMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
        }
        Logger.t(TAG).d("switchMode: " + switchMode);

        if (switchMode != -1) {
            library.switchProjectionMode(mSoftActivity.get(), switchMode);
        }
    }

    private void updateUI(int state, boolean isCloud) {
        switch (state) {
            case ClipPosChangeEvent.INTENT_LIVE:
                changeSurfaceView(false, false, isCloud);
                cancelBusy();
                break;
            case ClipPosChangeEvent.INTENT_SHOW_THUMBNAIL:
                changeSurfaceView(true, false, isCloud);
                showPlayButton(isCloud);
                cancelBusy();
                break;
            case ClipPosChangeEvent.INTENT_PLAY:
                changeSurfaceView(false, true, isCloud);
                showPlayButton(isCloud);
                cancelBusy();
                break;
        }
    }

    private void showPlayButton(boolean isCloud) {
        if (!isCloud) {
            iv_curStatus.setImageResource(R.drawable.icon_sdcard);
            tvCurStatus.setText(R.string.sdcard);

            iv_videoSrc.setImageResource(R.drawable.icon_sdcard);
            tv_videoSrc.setText(R.string.sdcard);

            ivVideoSrc4K.setImageResource(R.drawable.icon_sdcard);
            tvToolbarTitle4K.setText(R.string.sdcard);

            btn_highlight.setVisibility(Constants.isFleet() ? View.INVISIBLE : View.VISIBLE);

//            btnStreamPort.setVisibility(View.VISIBLE);
//            btnStreamLand.setVisibility(View.VISIBLE);

        } else {
            iv_curStatus.setImageResource(R.drawable.icon_cloud);
            tvCurStatus.setText(R.string.cloud);

            iv_videoSrc.setImageResource(R.drawable.icon_cloud);
            tv_videoSrc.setText(R.string.cloud);

            ivVideoSrc4K.setImageResource(R.drawable.icon_cloud);
            tvToolbarTitle4K.setText(R.string.cloud);

            btn_highlight.setVisibility(View.INVISIBLE);

            btnStreamPort.setVisibility(View.GONE);
            btnStreamLand.setVisibility(View.GONE);

            btnEvCamStreamPort.setVisibility(View.GONE);
            btnEvCamStreamLand.setVisibility(View.GONE);
        }

        ll_record_port.setVisibility(View.INVISIBLE);
        ll_record_land.setVisibility(View.INVISIBLE);
        btnPlayPause_port.setVisibility(View.VISIBLE);
        btnPlayPause_land.setVisibility(View.VISIBLE);
    }

    private void adaptationForLandscape() {
        //考虑到横屏的toolbar情况
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.setMargins(0, 0, 0, 0);
        includeHighlightSuccess.setLayoutParams(params);

        Display defaultDisplay = mSoftActivity.get().getWindowManager().getDefaultDisplay();
        int totalWidth = defaultDisplay.getWidth();
        int totalHeight = defaultDisplay.getHeight();
        Logger.t(TAG).d("totalWidth: " + totalWidth + " totalHeight: " + totalHeight
                + " mXRadio: " + mXRadio + " mYRadio: " + mYRadio);
        if (totalWidth * mYRadio >= totalHeight * mXRadio) {
            mMediaWindow.post(() -> {
                int mMediaWindowWidth = mMediaWindow.getWidth();
                int mMediaWindowHeight = mMediaWindow.getHeight();
                Logger.t(TAG).i("mMediaWindowWidth: " + mMediaWindowWidth + " mMediaWindowHeight: " + mMediaWindowHeight);
                ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) mMediaWindow.getLayoutParams();
                int marginStart = marginLayoutParams.getMarginStart();
                int marginEnd = marginLayoutParams.getMarginEnd();
                Logger.t(TAG).d("marginStart: " + marginStart + " marginEnd: " + marginEnd);
                // 这里算上margin，因为之前有可能已经设置过LayoutParams的margin
                int width = mMediaWindowWidth + marginStart + marginEnd;
//                    int height = tvNotRecording.getVisibility() == View.VISIBLE ? ViewUtils.dp2px(27) : 0;
                int shadowWidth = (width - totalHeight * mXRadio / mYRadio) / 2;

                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                        totalHeight * mXRadio / mYRadio, totalHeight);
                layoutParams.setMargins(shadowWidth, 0, shadowWidth, 0);
                mMediaWindow.setLayoutParams(layoutParams);
            });
        }
    }

    private void adaptationForPortrait() {
        //考虑到竖屏的toolbar情况
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.setMargins(0, ViewUtils.dp2px(56), 0, 0);
        includeHighlightSuccess.setLayoutParams(params);

        if (videosFragment != null) {
            videosFragment.clearDialog();
        }

        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        layoutParams.setMargins(0, 0, 0, 0);
        mMediaWindow.setLayoutParams(layoutParams);
        mMediaWindow.post(() -> {
            // 横竖屏切换后可能导致view尺寸变小，这里重新设置下
            getVRVideoLibrary().onTextureResize(mMediaWindow.getWidth(), mMediaWindow.getHeight());
        });
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mVRLibrary.onOrientationChanged(mSoftActivity.get());
        mVRVideoLibrary.onOrientationChanged(mSoftActivity.get());
        mVRCloudLibrary.onOrientationChanged(mSoftActivity.get());

        if (isFullScreen()) {
            //横屏播放时不显示not recording
//            tvNotRecording.setVisibility(View.GONE);

            hideNavigation();

            toolbar.setVisibility(View.GONE);
            toolbar4K.setVisibility(View.GONE);
            rl_control_portrait.setVisibility(View.GONE);
//            ll_videoSrc.setVisibility(View.VISIBLE);
            rl_thumbnail_landscape.setVisibility(View.VISIBLE);

            adaptationForLandscape();
        } else {
            //判断是否显示not recording
            updateCameraStateUI();

            showNavigation();

            if (mCamera.getNeedDewarp()) {
                toolbar.setVisibility(View.VISIBLE);
            } else {
                toolbar4K.setVisibility(View.VISIBLE);
            }
            rl_control_portrait.setVisibility(View.VISIBLE);
//            ll_videoSrc.setVisibility(View.GONE);
            rl_thumbnail_landscape.setVisibility(View.GONE);

            adaptationForPortrait();
        }

        if (isFullScreen() && !viewModel.isLiveOrNot) {
            rl_videoProgress.setVisibility(View.VISIBLE);
        } else {
            rl_videoProgress.setVisibility(View.INVISIBLE);
        }
        setImmersiveMode(isFullScreen());
    }

    private void setImmersiveMode(boolean immersiveMode) {
        if (immersiveMode) {
            mSoftActivity.get().getWindow().getDecorView().setSystemUiVisibility(ViewUtils.FULL_SCREEN_FLAG);
        } else {
            mSoftActivity.get().getWindow().getDecorView().setSystemUiVisibility(0);
        }
    }

    private boolean isFullScreen() {
        int orientation = mSoftActivity.get().getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    private void releaseExoPlayer() {
        if (simpleExoPlayer != null) {
            simpleExoPlayer.release();
        }
    }

    private void initCloudPlayer(String url) {
        busy();
        togglePlayState(false);

        stopStream();

        changeSurfaceView(false, true, true);
        releaseExoPlayer();

        // 1. Create a default TrackSelector
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);

        // 2. Create the player
        simpleExoPlayer = ExoPlayerFactory.newSimpleInstance(mSoftActivity.get(), trackSelector);

        Logger.t(TAG).d("setVideoSurface: " + mCloudSurface);
        simpleExoPlayer.setVideoSurface(mCloudSurface);

        simpleExoPlayer.addVideoListener(new VideoListener() {
            @Override
            public void onVideoSizeChanged(int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
//                Logger.t(TAG).d("onVideoSizeChanged: " + width + " " + height);
                getVRCloudLibrary().onTextureResize(width, height);
//                changeVideoSize(width, height, () -> getVRCloudLibrary().onTextureResize(width, height));
            }

            @Override
            public void onRenderedFirstFrame() {
//                Logger.t(TAG).d("onRenderedFirstFrame: " + glCloudSurfaceView.isShown());
//                cancelBusy();
//                if (!isForeground) {
//                    simpleExoPlayer.setPlayWhenReady(false);
//                }
//                if (getVRCloudLibrary() != null) {
//                    getVRCloudLibrary().notifyPlayerChanged();
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
                switch (playbackState) {
                    case Player.STATE_IDLE:
                        break;
                    case Player.STATE_ENDED:
                        onVideoCompletion(simpleExoPlayer.getDuration(), true);
                        break;
                    case Player.STATE_BUFFERING:
                        busy();
                        break;
                    case Player.STATE_READY:
                        cancelBusy();
                        break;
                }
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
                Toast.makeText(mSoftActivity.get(), R.string.play_error, Toast.LENGTH_SHORT).show();
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

        Logger.t(TAG).d("video url = " + url);

        if (!TextUtils.isEmpty(url)) {
            simpleExoPlayer.prepare(getMediaSource(url));
            simpleExoPlayer.setPlayWhenReady(true);
            viewModel.inputs.pollVideoProgress();
        }
    }

    private MediaSource getMediaSource(String url) {
        // Measures bandwidth during playback. Can be null if not required.
        DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        // Produces DataSource instances through which media data is loaded.
        DataSource.Factory dataSourceFactory = new CustomHttpDataSourceFactory("Android", bandwidthMeter);

        // This is the MediaSource representing the media to be played.
        return new ExtractorMediaSource.Factory(dataSourceFactory).createMediaSource(Uri.parse(url));
    }

    private void releaseIjkPlayer() {
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }
    }

    private void changeVideoSize(int videoWidth, int videoHeight, Action action) {
        int divisor = getGreatestCommonDivisor(videoWidth, videoHeight);

        int tempX = videoWidth / divisor;
        int tempY = videoHeight / divisor;

        if (tempX != mXRadio || tempY != mYRadio) {
            Logger.t(TAG).d("changeVideoSize: " + divisor + " " + tempX + " " + tempY);

            mXRadio = tempX;
            mYRadio = tempY;

            mMediaWindow.setRatio(mXRadio, mYRadio);
            mMediaWindow.post(() -> {
                if (action != null) {
                    try {
                        action.run();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        } else {
            if (action != null) {
                try {
                    action.run();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
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

    @SuppressLint("CheckResult")
    private void initVideoPlayer(ClipPos clipPos) {
        busy();
        togglePlayState(false);

        stopStream();

        changeSurfaceView(false, true, false);

        releaseIjkPlayer();

        mMediaPlayerWrapper = new MediaPlayerWrapper(false);

        mMediaPlayerWrapper.init();

        mMediaPlayerWrapper.setPreparedListener(mp -> {
            Logger.t(TAG).d("onPrepared: " + glVideoSurfaceView.isShown());
            cancelBusy();
            viewModel.inputs.pollVideoProgress();

            if (!isForeground) {
                mp.stop();
            }
            if (getVRVideoLibrary() != null) {
                getVRVideoLibrary().notifyPlayerChanged();
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnInfoListener((iMediaPlayer, what, extra) -> {
            switch (what) {
                case IMediaPlayer.MEDIA_INFO_BUFFERING_START:
                    busy();
                    break;
                case IMediaPlayer.MEDIA_INFO_BUFFERING_END:
                case IMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
                    cancelBusy();
                    break;
                default:
                    break;
            }
            return false;
        });

        mMediaPlayerWrapper.getPlayer().setOnErrorListener((mp, what, extra) -> {
            Logger.t(TAG).e("onError what: " + what + " extra: " + extra);
            cancelBusy();
            togglePlayState(true);
            Toast.makeText(mSoftActivity.get(), R.string.play_error, Toast.LENGTH_SHORT).show();
            return true;
        });

        mMediaPlayerWrapper.getPlayer().setOnVideoSizeChangedListener((mp, width, height, sar_num, sar_den) -> {
//            Logger.t(TAG).d("onVideoSizeChanged: " + width + " " + height);
            getVRVideoLibrary().onTextureResize(width, height);
//            changeVideoSize(width, height, () -> getVRVideoLibrary().onTextureResize(width, height));
        });

        mMediaPlayerWrapper.getPlayer().setOnCompletionListener(iMediaPlayer ->
                onVideoCompletion(iMediaPlayer.getDuration(), false));

        if (clipPos != null) {
//            Logger.t(TAG).e("clip info: " + "--Duration: " + clipPos.getDuration()
//                    + "--ID: " + clipPos.getClipId()
//                    + "--ClipTimeMs" + clipPos.getClipTimeMs());
            adaptationFor4K(clipPos.clip.getNeedDewarp(), false);
            switchProjection(mVRVideoLibrary, clipPos.clip.isLensNormal(), clipPos.clip.getNeedDewarp());

            Observable.create((ObservableOnSubscribe<Void>) emitter -> {
                try {
                    int length = clipPos.clip.streams.length;
                    boolean streamOnly = length != 2;
                    Logger.t(TAG).d("mStreamIndex: " + viewModel.mStreamIndex);
                    playbackUrl = SnipeApi.getClipPlaybackUrlWithStream(clipPos.cid,
                            clipPos.getClip().getStartTimeMs(), clipPos.getClipTimeMs(),
                            clipPos.getClip().getDurationMs(), viewModel.mStreamIndex);
                    Logger.t(TAG).d("playback url = " + playbackUrl.url);
                    if (playbackUrl.url != null) {
//                            mPositionAdjuster = new ClipPositionAdjuster(clipPos.getClip().getStartTimeMs(), playbackUrl);
                        mMediaPlayerWrapper.openRemoteFile(playbackUrl.url);
//                        mMediaPlayerWrapper.openRemoteFile("rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov");
                        mMediaPlayerWrapper.prepare();
                    }
                } catch (Exception e) {
                    Logger.t(TAG).e("getClipPlaybackUrlWithStream exception: " + e.getMessage());
                }
            })
                    .subscribeOn(Schedulers.io())
                    .subscribe(Functions.emptyConsumer(), new ServerErrorHandler(TAG));
        }
    }

    private void refreshPipeline(CameraWrapper wrapper) {
        switchProjection(mVRLibrary, wrapper.getIsLensNormal(), wrapper.getNeedDewarp());
        glSurfaceView.setVisibility(View.VISIBLE);
        glVideoSurfaceView.setVisibility(View.GONE);
        glCloudSurfaceView.setVisibility(View.GONE);
        mjpegAddress = new InetSocketAddress(wrapper.getAddress(), 8081);
        loadMJPEG();
    }

    synchronized private void loadMJPEG() {
        try {
            if (mjpegAddress != null && mMjpegStream == null) {
                Logger.t(TAG).d("start stream");

                iv_curStatus.setImageResource(R.drawable.icon_live_view);
                tvCurStatus.setText(R.string.to_live);

                iv_videoSrc.setImageResource(R.drawable.icon_live_view);
                tv_videoSrc.setText(R.string.to_live);

                ivVideoSrc4K.setImageResource(R.drawable.icon_live_view);
                tvToolbarTitle4K.setText(R.string.to_live);

                if (Constants.isFleet()) {
                    ll_record_port.setVisibility(View.INVISIBLE);
                    ll_record_land.setVisibility(View.INVISIBLE);
                } else {
                    ll_record_port.setVisibility(View.VISIBLE);
                    ll_record_land.setVisibility(View.VISIBLE);
                }
                btnPlayPause_land.setVisibility(View.INVISIBLE);
                btnPlayPause_port.setVisibility(View.INVISIBLE);
                btnStreamLand.setVisibility(View.GONE);
                btnStreamPort.setVisibility(View.GONE);
                btnEvCamStreamLand.setVisibility(View.GONE);
                btnEvCamStreamPort.setVisibility(View.GONE);

                updateCameraStateUI();
                startStream(mjpegAddress);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    @BindView(R.id.iv_thumbnail)
    ImageView ivThumbnail;

    private void fetchThumbnail(Optional<Bitmap> bitmapOptional) {
        Bitmap bitmap = bitmapOptional.getIncludeNull();
        if (bitmap == null) {
            return;
        }

        if (ivThumbnail.getVisibility() == View.VISIBLE) {
            ivThumbnail.setImageBitmap(bitmap);
        }

//        getVRLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight());
//        // texture
//        if (mCallback != null) {
//            mCallback.texture(bitmap);
//        }
    }

    private MDVRLibrary createBitmapVRLibrary() {
        int projectionMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;

        if (mCamera != null) {
            boolean needDewarp = mCamera.getNeedDewarp();
            if (needDewarp) {
                boolean upsidedown = mCamera.getSupportUpsidedown();
                Logger.t(TAG).d("supportUpsidedown: " + upsidedown);
                if (upsidedown) {
                    boolean lensNormal = mCamera.getIsLensNormal();
                    Logger.t(TAG).d("lensNormal: " + lensNormal);
                    projectionMode = lensNormal ?
                            CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
                }
            } else {
                projectionMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
            }
        }

        Logger.t(TAG).d("projectionMode: " + (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS));

        return MDVRLibrary.with(mSoftActivity.get())
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asBitmap(callback -> {
//                    Logger.t(TAG).d("load image with max texture size:" + callback.getMaxTextureSize());
                    mCallback = callback;
                })
                .pinchEnabled(false)
                .projectionMode(projectionMode)
                .projectionFactory(new CustomProjectionFactory())
                .build((GLSurfaceView) rootView.findViewById(R.id.gl_view));
    }

    private MDVRLibrary createVideoVRLibrary() {
        return MDVRLibrary.with(mSoftActivity.get())
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
                    Toast.makeText(mSoftActivity.get(), tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) rootView.findViewById(R.id.gl_videoView));
    }

    private MDVRLibrary createCloudLibrary() {
        return MDVRLibrary.with(mSoftActivity.get())
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asVideo(surface -> {
//                    Logger.t(TAG).d("onSurfaceReady: " + surface);
                    if (mCloudSurface != surface) {
                        mCloudSurface = surface;
                        if (simpleExoPlayer != null) {
                            simpleExoPlayer.setVideoSurface(surface);
                        }
                    }
                })
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + mode;
                    Toast.makeText(mSoftActivity.get(), tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) rootView.findViewById(R.id.gl_cloudView));
    }

    public void cancelBusy() {
        rootView.findViewById(R.id.progress).setVisibility(View.GONE);
    }

    public void busy() {
        rootView.findViewById(R.id.progress).setVisibility(View.VISIBLE);
    }

    private void startStream(final InetSocketAddress serverAddr) {
        mMjpegStream = new MjpegStream() {
            @Override
            protected void onBitmapReadyAsync(MjpegDecoder decoder, MjpegStream stream) {
                BitmapBuffer bb = stream.getOutputBitmapBuffer(decoder);
                if (bb != null) {
                    Bitmap bitmap = bb.getBitmap();
//                    Logger.t(TAG).d("%s", "loaded image, size:" + bitmap.getWidth() + "," + bitmap.getHeight());
                    //notify if size changed
                    mSoftActivity.get().runOnUiThread(() -> {
                        try {
                            long time = System.currentTimeMillis() + TimeZone.getDefault().getOffset(new Date().getTime());
                            if (viewModel != null && viewModel.inputs != null) {
                                viewModel.inputs.updateLiveTime(time);
                            }
                            if (bitmap != null) {
                                getVRLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight());
//                                changeVideoSize(bitmap.getWidth(), bitmap.getHeight(),
//                                        () -> getVRLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight()));
                                if (mCallback != null) {
                                    mCallback.texture(bitmap);
                                    cancelBusy();
                                }
                            }
                        } catch (Exception ex) {
                            //Activity may have been destroyed.
                            Logger.t(TAG).d("error = " + ex.getMessage());
                        }
                    });
                }
            }

            @Override
            protected void onEventAsync(MjpegDecoder decoder, MjpegStream stream) {

            }

            @Override
            protected void onIoErrorAsync(MjpegStream stream, int error) {
                mSoftActivity.get().runOnUiThread(() -> {
                    if (mMjpegStream != null) {
                        mMjpegStream.stop();
                        mMjpegStream = null;
                        startStream(serverAddr);
                    }
                });
            }
        };
        mMjpegStream.start(serverAddr);
    }

    private void stopStream() {
        Logger.t(TAG).d("stop stream");
        if (mMjpegStream != null) {
            mMjpegStream.stop();
            mMjpegStream = null;
        }
    }

    private void changeSurfaceView(boolean isThumbnail, boolean isVideo, boolean isCloud) {
        if (isThumbnail) {

            if (ivThumbnail.getVisibility() == View.GONE) {
                ivThumbnail.setVisibility(View.VISIBLE);
            }

            if (glSurfaceView.getVisibility() == View.VISIBLE) {
                glSurfaceView.onPause();
                glSurfaceView.setVisibility(View.GONE);
            }
            if (glVideoSurfaceView.getVisibility() == View.VISIBLE) {
                glVideoSurfaceView.onPause();
                glVideoSurfaceView.setVisibility(View.GONE);
            }
            if (glCloudSurfaceView.getVisibility() == View.VISIBLE) {
                glCloudSurfaceView.onPause();
                glCloudSurfaceView.setVisibility(View.GONE);
            }

            return;
        }

        if (ivThumbnail.getVisibility() == View.VISIBLE) {
            ivThumbnail.setVisibility(View.GONE);
        }

        if (isVideo) {
            //preview时不显示not recording
//            tvNotRecording.setVisibility(View.GONE);

            if (glSurfaceView.getVisibility() == View.VISIBLE) {
                glSurfaceView.onPause();
                glSurfaceView.setVisibility(View.GONE);
            }

            if (isCloud) {
                if (glCloudSurfaceView.getVisibility() != View.VISIBLE) {
                    glCloudSurfaceView.onResume();
                    glCloudSurfaceView.setVisibility(View.VISIBLE);
                }
                if (glVideoSurfaceView.getVisibility() == View.VISIBLE) {
                    glVideoSurfaceView.onPause();
                    glVideoSurfaceView.setVisibility(View.GONE);
                }
            } else {
                if (glVideoSurfaceView.getVisibility() != View.VISIBLE) {
                    glVideoSurfaceView.onResume();
                    glVideoSurfaceView.setVisibility(View.VISIBLE);
                }
                if (glCloudSurfaceView.getVisibility() == View.VISIBLE) {
                    glCloudSurfaceView.onPause();
                    glCloudSurfaceView.setVisibility(View.GONE);
                }
            }
        } else {
            if (glSurfaceView.getVisibility() != View.VISIBLE) {
                glSurfaceView.onResume();
                glSurfaceView.setVisibility(View.VISIBLE);
            }
            if (glVideoSurfaceView.getVisibility() == View.VISIBLE) {
                glVideoSurfaceView.onPause();
                glVideoSurfaceView.setVisibility(View.GONE);
            }
            if (glCloudSurfaceView.getVisibility() == View.VISIBLE) {
                glCloudSurfaceView.onPause();
                glCloudSurfaceView.setVisibility(View.GONE);
            }
        }
    }

    @Override
    public void onDetach() {
        IjkPlayerLogUtil.logIJKMEDIA();
        super.onDetach();

        if (mVRLibrary != null) {
            mVRLibrary.onDestroy();
        }
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onDestroy();
        }
        if (mVRCloudLibrary != null) {
            mVRCloudLibrary.onDestroy();
        }
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }
        if (simpleExoPlayer != null) {
            simpleExoPlayer.release();
        }
        if (mRefreshHandler != null) {
            mRefreshHandler.removeCallbacksAndMessages(null);
        }
    }

    private MDVRLibrary getVRLibrary() {
        return mVRLibrary;
    }

    private MDVRLibrary getVRVideoLibrary() {
        return mVRVideoLibrary;
    }

    private MDVRLibrary getVRCloudLibrary() {
        return mVRCloudLibrary;
    }

    private void hideControlPanel() {
        Logger.t(TAG).d("hide ControlPanel");
//        ll_videoSrc.setVisibility(View.GONE);
        rl_thumbnail_landscape.setVisibility(View.GONE);
    }

    private void showControlPanel() {
        Logger.t(TAG).d("show ControlPanel");
//        ll_videoSrc.setVisibility(View.VISIBLE);
        rl_thumbnail_landscape.setVisibility(View.VISIBLE);

        mHandler.removeMessages(ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(ControlPanelHandler.FADE_OUT), 5000);
    }

    private void controlPlayer(boolean state) {
        Logger.t(TAG).d("controlPlayer: " + state);
        if (glVideoSurfaceView.isShown() && mMediaPlayerWrapper != null) {
            if (state) {
                mMediaPlayerWrapper.pause();
                togglePlayState(true);
            } else {
                mMediaPlayerWrapper.resume();
                togglePlayState(false);
            }
        } else if (glCloudSurfaceView.isShown() && simpleExoPlayer != null) {
            if (state) {
                simpleExoPlayer.setPlayWhenReady(false);
                togglePlayState(true);
            } else {
                simpleExoPlayer.setPlayWhenReady(true);
                togglePlayState(false);
            }
        }
    }

    private void togglePlayState(boolean toPlay) {
        btnPlayPause_port.setBackground(getResources().getDrawable(toPlay ? R.drawable.playbar_play_n : R.drawable.playbar_pause_n));
        btnPlayPause_land.setBackground(getResources().getDrawable(toPlay ? R.drawable.playbar_play_n : R.drawable.playbar_pause_n));
    }

    public void setupToolbar() {
        if (toolbar == null || toolbar4K == null) {
            return;
        }

        if (Constants.isFleet()) {
            toolbar.setNavigationIcon(null);
            toolbar4K.setNavigationIcon(null);
        } else {
            toolbar.setNavigationOnClickListener(v -> showCameras());
            toolbar4K.setNavigationOnClickListener(v -> showCameras());
        }

        if (!Constants.isFleet() || Constants.isManager()) {
            toolbar.inflateMenu(R.menu.camera_setting);
            toolbar4K.inflateMenu(R.menu.camera_setting);

            toolbar.setOnMenuItemClickListener(item -> {
                if (item.getItemId() == R.id.action_setting) {
                    if (mCamera != null) {
                        if (videosFragment != null) {
                            videosFragment.onToLiveClick();
                        }
                        if (remoteVideoFragment != null) {
                            remoteVideoFragment.onToLiveClick();
                        }
                        DevicesActivity.launch(mSoftActivity.get(), mCamera.getSerialNumber());
                    }
                }
                return false;
            });
            toolbar4K.setOnMenuItemClickListener(item -> {
                if (item.getItemId() == R.id.action_setting) {
                    if (mCamera != null) {
                        if (videosFragment != null) {
                            videosFragment.onToLiveClick();
                        }
                        if (remoteVideoFragment != null) {
                            remoteVideoFragment.onToLiveClick();
                        }
                        DevicesActivity.launch(mSoftActivity.get(), mCamera.getSerialNumber());
                    }
                }
                return false;
            });
        }
    }

    /**
     * 传递进度给fragment调整时间，滚动位置
     */
    private void refreshProgress(long currentPos, boolean isCloud) {
        if (!isCloud) {
            ClipPos clipPos = getClipPos();
            if (clipPos == null) {
                return;
            }
            ClipPos curClipPos = new ClipPos(clipPos.getClip(), clipPos.getClipTimeMs() + currentPos);
            ClipPosChangeEvent event = new ClipPosChangeEvent(curClipPos, TAG);
//            Logger.t(TAG).d("refreshProgress sdcard: " + viewModel.isLiveOrNot);
            RxBus.getDefault().post(event);
        } else if (Constants.isFleet()) {
            EventBeanPos eventBeanPos = getEventBeanPos();
            if (eventBeanPos == null) {
                return;
            }
            EventBeanPos curEventBeanPos = new EventBeanPos(eventBeanPos.getEventBean(), currentPos);
            EventBeanPosChangeEvent event = new EventBeanPosChangeEvent(curEventBeanPos, TAG);
            RxBus.getDefault().post(event);
        } else {
            ClipBeanPos clipBeanPos = getClipBeanPos();
            if (clipBeanPos == null) {
                return;
            }
            ClipBeanPos curClipBeanPos = new ClipBeanPos(clipBeanPos.getClipBean(), currentPos);
            ClipBeanPosChangeEvent event = new ClipBeanPosChangeEvent(curClipBeanPos, TAG);
//            Logger.t(TAG).d("refreshProgress cloud: " + viewModel.isLiveOrNot);
            RxBus.getDefault().post(event);
        }
    }

    private void refreshHighlightButton(ClipPos clipPos) {
        if (clipPos != null && viewModel != null && !viewModel.isLiveOrNot) {
            if (clipPos.clip.getVideoType() == Clip.TYPE_BUFFERED) {
                if (mPopWindow != null && mPopWindow.isShowing()) {
                    //防止highlight显示造成重叠
//                    Logger.t(TAG).d("mPopWindow isShowing");
                    return;
                }
                btn_highlight.setVisibility(Constants.isFleet() ? View.INVISIBLE : View.VISIBLE);
            } else {
                btn_highlight.setVisibility(View.INVISIBLE);
            }
            if (clipPos.clip.streams.length > 1) {
                String[] descriptions = clipPos.clip.descriptions;
//                Logger.t(TAG).d("descriptions: " + Arrays.toString(descriptions));
                if (descriptions == null || descriptions.length == 0 || descriptions[0] == null) {
                    btnStreamPort.setVisibility(View.VISIBLE);
                    btnStreamLand.setVisibility(View.VISIBLE);
                    btnEvCamStreamPort.setVisibility(View.GONE);
                    btnEvCamStreamLand.setVisibility(View.GONE);
                } else {
                    btnEvCamStreamPort.setVisibility(View.VISIBLE);
                    btnEvCamStreamLand.setVisibility(View.VISIBLE);
                    btnStreamPort.setVisibility(View.GONE);
                    btnStreamLand.setVisibility(View.GONE);
                }
            } else {
                btnStreamPort.setVisibility(View.GONE);
                btnStreamLand.setVisibility(View.GONE);
                btnEvCamStreamPort.setVisibility(View.GONE);
                btnEvCamStreamLand.setVisibility(View.GONE);
            }
        } else {
            btn_highlight.setVisibility(View.INVISIBLE);
        }
    }

    /**
     * 播放完毕跳转下一个
     */
    private void onVideoCompletion(long duration, boolean isCloud) {
        Logger.t(TAG).d("onVideoCompletion");
        if (isFullScreen()) {
            int durationMs = mClipPos.getClip().getDurationMs();
            sbVideo.setProgress(durationMs);
            tvVideoProgress.setText(DateUtils.formatElapsedTime(durationMs / 1000));
            return;
        }

        if (!isCloud) {
            ClipPos clipPos = getClipPos();
            if (clipPos == null) {
                return;
            }
            ClipPos curClipPos = new ClipPos(clipPos.getClip(), clipPos.getClipTimeMs() + duration);
            ClipPosChangeEvent event = new ClipPosChangeEvent(curClipPos, TAG, ClipPosChangeEvent.INTENT_PLAY_END);
            RxBus.getDefault().post(event);
        } else if (Constants.isFleet()) {
            EventBeanPos eventBeanPos = getEventBeanPos();
            if (eventBeanPos == null) {
                return;
            }
            EventBeanPos curEventBeanPos = new EventBeanPos(eventBeanPos.getEventBean(), duration);
            EventBeanPosChangeEvent event = new EventBeanPosChangeEvent(curEventBeanPos, TAG, EventBeanPosChangeEvent.INTENT_PLAY_END);
            RxBus.getDefault().post(event);
        } else {
            ClipBeanPos clipPos = getClipBeanPos();
            if (clipPos == null) {
                return;
            }
            ClipBeanPos curClipPos = new ClipBeanPos(clipPos.getClipBean(), duration);
            ClipBeanPosChangeEvent event = new ClipBeanPosChangeEvent(curClipPos, TAG, ClipBeanPosChangeEvent.INTENT_PLAY_END);
            RxBus.getDefault().post(event);
        }
    }

    private ClipPos getClipPos() {
        return mClipPos;
    }

    private ClipBeanPos getClipBeanPos() {
        return mClipBeanPos;
    }

    private EventBeanPos getEventBeanPos() {
        return mEventBeanPos;
    }

    public void scaleView(View v, int targetHeight, int startHeight) {
//        Logger.t(TAG).d("scaleView targetHeight = " + targetHeight);
        ResizeAnimation anim = new ResizeAnimation(v, targetHeight, startHeight);
        anim.setDuration(1000);
        anim.setFillAfter(true);
        v.startAnimation(anim);
    }

    static class RefreshHandler extends Handler {

        private final WeakReference<CameraViewFragment> weakReference;

        RefreshHandler(CameraViewFragment fragment) {
            weakReference = new WeakReference<>(fragment);
        }

        @Override
        public void handleMessage(Message msg) {
            CameraViewFragment fragment = weakReference.get();
            if (fragment != null
                    && fragment.mCamera != null && fragment.mCamera.getClipsManager() != null
                    && fragment.videosFragment != null && fragment.videosFragment.viewModel() != null) {
                //在highlight export时不刷新
                if (fragment.pb_highlight.getVisibility() != View.VISIBLE) {
                    fragment.mCamera.getClipsManager().updateClip((Clip) msg.obj, false);
                    fragment.videosFragment.viewModel().loadClips(fragment.filterList, true);
                }
            }
        }
    }

    private void highlightAnim() {
        BottomNavigationItemView albumView = naviViewTemp.getBottomNavigationItemView(2);
        BottomNavigationItemView profileView = naviViewTemp.getBottomNavigationItemView(3);

        int[] startXy = new int[2];
        int[] endXy = new int[2];

        int[] albumXy = new int[2];
        int[] profileXy = new int[2];

        //获取view在屏幕中的位置
        ivHighlightTemp.getLocationOnScreen(startXy);
        albumView.getLocationOnScreen(albumXy);
        profileView.getLocationOnScreen(profileXy);

        endXy[0] = (albumXy[0] + profileXy[0]) / 2;
        endXy[1] = naviViewTemp.getTop();

        ImageView imageView = new ImageView(mSoftActivity.get());
        float px = ViewUtils.dp2px(getResources().getDimensionPixelSize(R.dimen.dp_35) / ViewUtils.getDensity());
        ViewGroup.LayoutParams layoutParams = new ConstraintLayout.LayoutParams((int) px, (int) px);
        imageView.setLayoutParams(layoutParams);
        imageView.setImageResource(R.drawable.btn_highlight_c);

        ViewGroup rootView = (ViewGroup) mSoftActivity.get().getWindow().getDecorView();
        rootView.addView(imageView);
        imageView.setX(startXy[0]);
        imageView.setY(startXy[1]);

        Point startPoint = new Point(startXy[0], startXy[1]);
        //x=left, y=top
        Point endPoint = new Point((int) (endXy[0] - px / 2), endXy[1]);

        int midPointX = (startPoint.x + endPoint.x) / 2;
        int midPointY = startPoint.y / 2;

        Point midPoint = new Point(midPointX, midPointY);
        BezierEvaluator evaluator = new BezierEvaluator(midPoint);

        ValueAnimator animator = ValueAnimator.ofObject(evaluator, startPoint, endPoint);
        animator.addUpdateListener(animation -> {
            Point point = (Point) animation.getAnimatedValue();
            imageView.setX(point.x);
            imageView.setY(point.y);
        });

        animator.setDuration(1000);
        animator.setInterpolator(new AccelerateInterpolator());
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                animation.cancel();
                ViewGroup parent = (ViewGroup) imageView.getParent();
                if (parent != null) {
                    parent.removeView(imageView);
                    showHighlightSuccessDialog();
                    shakeAnim(albumView);
                }
            }
        });

        animator.start();
    }

    private void showHighlightSuccessDialog() {
        View view = LayoutInflater.from(mSoftActivity.get()).inflate(R.layout.pop_highlight_success, null);

        PopupWindow popupWindow = new PopupWindow(view, ConstraintLayout.LayoutParams.MATCH_PARENT,
                ConstraintLayout.LayoutParams.WRAP_CONTENT, false);

        //考虑到toolbar在竖屏下不显示的情况
        if (mCamera.getNeedDewarp()) {
            boolean showToolbar = toolbar.getVisibility() == View.VISIBLE;
            popupWindow.showAtLocation(toolbar, Gravity.NO_GRAVITY, 0, mMediaWindow.getHeight() / 2 + (showToolbar ? toolbar.getHeight() : 0));
        } else {
            popupWindow.showAtLocation(toolbar4K, Gravity.NO_GRAVITY, 0, mMediaWindow.getHeight() / 2);
        }

        new Handler().postDelayed(() -> {
            if (popupWindow.isShowing()) {
                popupWindow.dismiss();
            }
        }, 3000);
    }

    private void shakeAnim(View view) {
        if (view == null) {
            return;
        }

        PropertyValuesHolder scaleXValuesHolder = PropertyValuesHolder.ofKeyframe(
                View.SCALE_X,
                Keyframe.ofFloat(0f, 1.0f),
                Keyframe.ofFloat(0.25f, 0.25f),
                Keyframe.ofFloat(0.5f, 0.5f),
                Keyframe.ofFloat(0.75f, 0.75f),
                Keyframe.ofFloat(1.0f, 1.0f)
        );

        PropertyValuesHolder scaleYValuesHolder = PropertyValuesHolder.ofKeyframe(
                View.SCALE_Y,
                Keyframe.ofFloat(0f, 1.0f),
                Keyframe.ofFloat(0.25f, 0.25f),
                Keyframe.ofFloat(0.5f, 0.5f),
                Keyframe.ofFloat(0.75f, 0.75f),
                Keyframe.ofFloat(1.0f, 1.0f)
        );

        PropertyValuesHolder rotateValueHolder = PropertyValuesHolder.ofKeyframe(
                View.ROTATION,
                Keyframe.ofFloat(0f, 0f),
//                Keyframe.ofFloat(0.1f, -shakeDegrees),
                Keyframe.ofFloat(0.2f, -(float) 25.0),
//                Keyframe.ofFloat(0.3f, -shakeDegrees),
                Keyframe.ofFloat(0.4f, (float) 25.0),
//                Keyframe.ofFloat(0.5f, -shakeDegrees),
                Keyframe.ofFloat(0.6f, -(float) 25.0),
//                Keyframe.ofFloat(0.7f, -shakeDegrees),
                Keyframe.ofFloat(0.8f, (float) 25.0),
//                Keyframe.ofFloat(0.9f, -shakeDegrees),
                Keyframe.ofFloat(1.0f, 0f)
        );

        ObjectAnimator objectAnimator = ObjectAnimator.ofPropertyValuesHolder(view, scaleXValuesHolder, scaleYValuesHolder, rotateValueHolder);
        objectAnimator.setDuration((long) 800);
        objectAnimator.start();

        objectAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                objectAnimator.cancel();
                includeHighlightSuccess.setVisibility(View.GONE);
                showNavigation();
            }
        });
    }

    private void hideNavigation() {
        if (videosFragment != null && videosFragment.isVisible())
            videosFragment.hideNavigation();
        if (remoteVideoFragment != null && remoteVideoFragment.isVisible())
            remoteVideoFragment.hideNavigation();
    }

    private void showNavigation() {
        if (videosFragment != null && videosFragment.isVisible())
            videosFragment.showNavigation();
        if (remoteVideoFragment != null && remoteVideoFragment.isVisible())
            remoteVideoFragment.showNavigation();
    }

    private void showStreamDialog() {
        View view = LayoutInflater.from(mSoftActivity.get()).inflate(R.layout.layout_switch_stream, null);

        PopupWindow popupWindow = new PopupWindow(view, CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.WRAP_CONTENT, false);
        if (isFullScreen()) {
            popupWindow.getContentView().setSystemUiVisibility(ViewUtils.FULL_SCREEN_FLAG);
        } else {
            popupWindow.getContentView().setSystemUiVisibility(0);
        }

        if (mClipPos != null) {
            String[] descriptions = mClipPos.clip.descriptions;
            //Panorama("STREAMING"), Road("FRONT_HD"), Incab("INCABIN_HD"), Driver("DMS");
            Logger.t(TAG).d("descriptions: " + Arrays.toString(descriptions));
            for (String string : descriptions) {
                if ("STREAMING".equals(string)) {
                    view.findViewById(R.id.ll_mode_panorama).setVisibility(View.VISIBLE);
                    ((TextView) view.findViewById(R.id.tv_mode_panorama)).setText(isFullScreen() ?
                            R.string.mode_combined : R.string.mode_combined_view);
                } else if ("FRONT_HD".equals(string)) {
                    view.findViewById(R.id.ll_mode_road).setVisibility(View.VISIBLE);
                    ((TextView) view.findViewById(R.id.tv_mode_road)).setText(isFullScreen() ?
                            R.string.mode_road : R.string.mode_road_facing);
                } else if ("INCABIN_HD".equals(string)) {
                    view.findViewById(R.id.ll_mode_incab).setVisibility(View.VISIBLE);
                    ((TextView) view.findViewById(R.id.tv_mode_incab)).setText(isFullScreen() ?
                            R.string.mode_cabin : R.string.mode_cabin_facing);
                } else if ("DMS".equals(string)) {
                    view.findViewById(R.id.ll_mode_driver).setVisibility(View.VISIBLE);
                    ((TextView) view.findViewById(R.id.tv_mode_driver)).setText(isFullScreen() ?
                            R.string.mode_driver : R.string.mode_driver_facing);
                }
            }
        }

        view.findViewById(R.id.ll_mode_panorama).setOnClickListener(v -> {
            viewModel.inputStreamType(VideoStreamType.Panorama);
            if (mClipPos != null) {
                initVideoPlayer(mClipPos);
            }
            popupWindow.dismiss();
        });

        view.findViewById(R.id.ll_mode_road).setOnClickListener(v -> {
            viewModel.inputStreamType(VideoStreamType.Road);
            if (mClipPos != null) {
                initVideoPlayer(mClipPos);
            }
            popupWindow.dismiss();
        });

        view.findViewById(R.id.ll_mode_incab).setOnClickListener(v -> {
            viewModel.inputStreamType(VideoStreamType.Incab);
            if (mClipPos != null) {
                initVideoPlayer(mClipPos);
            }
            popupWindow.dismiss();
        });

        view.findViewById(R.id.ll_mode_driver).setOnClickListener(v -> {
            viewModel.inputStreamType(VideoStreamType.Driver);
            if (mClipPos != null) {
                initVideoPlayer(mClipPos);
            }
            popupWindow.dismiss();
        });

        view.findViewById(R.id.btn_export_cancel).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                popupWindow.dismiss();
            }
        });

        popupWindow.showAtLocation(toolbar4K, Gravity.BOTTOM, 0, 0);
    }

}
