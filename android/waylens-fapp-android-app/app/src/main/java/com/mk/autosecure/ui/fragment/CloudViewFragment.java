package com.mk.autosecure.ui.fragment;

import static android.view.MotionEvent.ACTION_DOWN;
import static android.view.MotionEvent.ACTION_UP;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.Display;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.PermissionChecker;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.activity.DevicesActivity;
import com.mk.autosecure.ui.adapter.TypeAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.InfoMsgQueue;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.CookieUtil;
import com.mk.autosecure.libs.utils.GaussianBlurUtil;
import com.mk.autosecure.libs.utils.IjkPlayerLogUtil;
import com.mk.autosecure.libs.utils.InfoMsgUtils;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.model.ClipBeanPos;
import com.mk.autosecure.model.ClipBeanPosChangeEvent;
import com.mk.autosecure.model.EventBeanPos;
import com.mk.autosecure.model.EventBeanPosChangeEvent;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.HornApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.VideoType;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.LiveStatusResponse;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest.request.LiveStreamBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.FleetApiClient;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.fragment.CloudViewFragmentViewModel;
import com.waylens.player.player.IjkPlayerImpl;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
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

@RequiresFragmentViewModel(CloudViewFragmentViewModel.ViewModel.class)
public class CloudViewFragment extends BaseLazyLoadFragment<CloudViewFragmentViewModel.ViewModel> {

    public final static String TAG = CloudViewFragment.class.getSimpleName();

    private static final String GO_LIVE = "go_live";
    private static final String CLIP_ID = "clip_id";
    private static final int PERMISSION_AUDIO_REQUESTCODE = 11;

    private ClipBeanPos mClipBeanPos = null;

    private EventBeanPos mEventBeanPos = null;

    private IjkPlayerImpl mIjkPlayerWrapper;

    private boolean isForeground = true;

    private MD360BitmapTexture.Callback mCallback;

    private ControlPanelHandler mHandler;

    private HornApiService mApiService;

    private FleetApiClient mApiClient;

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private boolean goLive;

    private long clipID;

    private Disposable pollLiveStatusSub = new CompositeDisposable();

    private Disposable pollLiveBPSSub = new CompositeDisposable();

    private Disposable pollLiveTimeSub = new CompositeDisposable();

    private RemoteVideoFragment remoteVideoFragment;

    public List<String> filterList = new ArrayList<>();

    private InfoMsgQueue infoMsgQueue;

    private boolean needDewarp = true;

    private int mXRadio;
    private int mYRadio;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.iv_curStatus)
    ImageView iv_curStatus;

    @BindView(R.id.tv_curStatus)
    TextView tvCurStatus;

    @BindView(R.id.ll_setting_request)
    LinearLayout ll_setting_request;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.gl_live)
    GLSurfaceView gl_live;

    @BindView(R.id.gl_thumbnail)
    GLSurfaceView gl_thumbnail;

    @BindView(R.id.progress)
    ProgressBar progressBar;

    @BindView(R.id.tv_liveStatus)
    TextView tv_liveStatus;

    @BindView(R.id.ib_startPlay)
    ImageButton ib_startPlay;

    @BindView(R.id.view_shadow)
    View view_shadow;

    @BindView(R.id.tv_offline_tips)
    TextView tv_offline_tips;

    @BindView(R.id.ll_videoSrc)
    LinearLayout ll_videoSrc;

    @BindView(R.id.iv_videoSrc)
    ImageView iv_videoSrc;

    @BindView(R.id.tv_videoSrc)
    TextView tv_videoSrc;

    @BindView(R.id.ib_fullScreen_port)
    ImageButton ib_fullScreen_port;

    @BindView(R.id.ib_fullScreen_land)
    ImageButton ib_fullScreen_land;

    @BindView(R.id.rl_videoProgress)
    RelativeLayout rl_videoProgress;

    @BindView(R.id.tv_playProgress)
    TextView tvVideoProgress;

    @BindView(R.id.tv_duration)
    TextView tvVideoDuration;

    @BindView(R.id.sb_video)
    SeekBar sbVideo;

    @BindView(R.id.rl_control_portrait)
    RelativeLayout rl_control_portrait;

    @BindView(R.id.rl_thumbnail_landscape)
    RelativeLayout rl_thumbnail_landscape;

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

    @BindView(R.id.rl_filter)
    RelativeLayout rlFilter;

    @BindView(R.id.tv_event_num)
    TextView tv_event_num;

    @BindView(R.id.rg_source)
    RadioGroup rg_source;

    @BindView(R.id.rb_cloud)
    RadioButton rb_cloud;

    @BindView(R.id.rv_type)
    RecyclerView rvType;

    @BindView(R.id.frameLayout)
    FrameLayout frameLayout;

    @BindView(R.id.ib_talkback)
    ImageButton ibTalkback;

    @BindView(R.id.ll_talkback)
    LinearLayout llTalkback;

    @BindView(R.id.rl_preview)
    RelativeLayout rlPreview;

    @BindView(R.id.tv_sliding_tips)
    TextView tvSlidingTips;

    @BindView(R.id.ll_message_remind)
    LinearLayout llMessageRemind;

    @BindView(R.id.tv_msg_content)
    TextView tvMsgContent;

    private PreviewFragment mPreviewFragment;

    @OnClick({R.id.tv_toolbarTitle, R.id.iv_close_preview})
    public void showCameras() {
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
    @OnClick({R.id.ib_fullScreen_port, R.id.ib_fullScreen_land})
    public void onBtnFullscreenClicked() {
        if (!isFullScreen()) {
            mSoftActivity.get().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            showControlPanel();
        } else {
            mSoftActivity.get().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    @OnClick(R.id.ib_startPlay)
    public void startPlay() {
        if (mIjkPlayerWrapper != null && !mIjkPlayerWrapper.isPlaying()) {
            if (viewModel != null && viewModel.isLiveOrNot) {
//                Logger.t(TAG).d("ijkplayer state: " + mIjkPlayerWrapper.getCurrentState());
                if (progressBar.getVisibility() != View.VISIBLE) {
                    busy();
                    togglePlayState(false);
                    startLive();
                }
            } else {
                if (progressBar.getVisibility() != View.VISIBLE) {
                    togglePlayState(false);
                    mIjkPlayerWrapper.resume();
                }
            }
        }
    }

    @OnClick({R.id.ib_stopPlay_port, R.id.ib_stopPlay_land})
    public void stopPlay() {
        if (mIjkPlayerWrapper != null) {
            if (mIjkPlayerWrapper.isPlaying()) {
                Logger.t(TAG).d("isPlaying");
                cancelBusy();
                togglePlayState(true);
                mIjkPlayerWrapper.pause();

                if (viewModel != null && viewModel.isLiveOrNot) {
                    Logger.t(TAG).d("isLiveOrNot");
                    stopLive();
                }
            } else if (viewModel != null && viewModel.isLiveOrNot) {
//                Logger.t(TAG).d("ijkplayer state: " + mIjkPlayerWrapper.getCurrentState());
                if (progressBar.getVisibility() == View.VISIBLE) {
                    cancelBusy();
                    togglePlayState(true);
                    stopLive();
                } else {
                    Logger.t(TAG).e("isStop");
                    if (progressBar.getVisibility() == View.VISIBLE) {
                        cancelBusy();
                        togglePlayState(true);
                        mIjkPlayerWrapper.pause();
                    }
                }
            }
        }
    }

    @OnClick(R.id.gl_live)
    public void onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked");
        if (rl_control_portrait.getVisibility() != View.VISIBLE
                && rl_thumbnail_landscape.getVisibility() != View.VISIBLE) {
            showControlPanel();
        } else if (isFullScreen()) {
            hideControlPanel();
        }
    }

    @OnClick({R.id.ib_projection_port, R.id.ib_projection_land})
    public void onProjectionSwitch() {
        int projectionMode = mLiveLibrary.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode);
        int switchMode = -1;

        if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS
                || projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
            mLiveLibrary.setPinchEnabled(true);
            switchMode = projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS ?
                    PROJECTION_MODE_DOME230_UPPER : PROJECTION_MODE_DOME_UPPER_DOWN;

            ib_projection_land.setBackgroundResource(R.drawable.bg_front_back_selector);
            ib_projection_port.setBackgroundResource(R.drawable.bg_front_back_selector);

        } else if (projectionMode == PROJECTION_MODE_DOME230_UPPER
                || projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
            mLiveLibrary.setPinchEnabled(false);
            switchMode = projectionMode == PROJECTION_MODE_DOME230_UPPER ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;

            ib_projection_land.setBackgroundResource(R.drawable.bg_panorama_selector);
            ib_projection_port.setBackgroundResource(R.drawable.bg_panorama_selector);
        }

        if (switchMode != -1) {
            mBitmapLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
            mLiveLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
        }
    }

    @OnClick(R.id.ib_filter_finish)
    public void hideFilter() {
        rlFilter.setVisibility(View.GONE);
        remoteVideoFragment.viewModel().filterVisibility(View.VISIBLE);
    }

    @OnTouch(R.id.ib_talkback)
    public boolean onTalkback(MotionEvent event) {
        //check audio permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(mSoftActivity.get(), Manifest.permission.RECORD_AUDIO) != PermissionChecker.PERMISSION_GRANTED) {
                ibTalkback.setEnabled(false);
                requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, PERMISSION_AUDIO_REQUESTCODE);
            } else {
                onAudioControl(event);
            }
        } else {
            onAudioControl(event);
        }
        return false;
    }

    private void onAudioControl(MotionEvent event) {
        int action = event.getAction();
        if (action == ACTION_DOWN) {
            viewModel.isAudioPush = true;
            if (mIjkPlayerWrapper != null) mIjkPlayerWrapper.setVolume(0f, 0f);
            llTalkback.setVisibility(View.VISIBLE);
            viewModel.inputs.startAudio();
        } else if (action == ACTION_UP) {
            viewModel.isAudioPush = false;
            if (mIjkPlayerWrapper != null) mIjkPlayerWrapper.setVolume(1f, 1f);
            llTalkback.setVisibility(View.GONE);
            viewModel.inputs.endAudio(false);
        }
    }

    private boolean isFullScreen() {
        int orientation = mSoftActivity.get().getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    private MDVRLibrary mLiveLibrary;
    private MDVRLibrary mBitmapLibrary;

    public static CloudViewFragment newInstance(CameraBean cameraBean) {
        CloudViewFragment fragment = new CloudViewFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(IntentKey.CAMERA_BEAN, cameraBean);
        fragment.setArguments(bundle);
        return fragment;
    }

    public static CloudViewFragment newInstance(FleetCameraBean fleetCameraBean) {
        CloudViewFragment fragment = new CloudViewFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(IntentKey.FLEET_CAMERA, fleetCameraBean);
        fragment.setArguments(bundle);
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
        isForeground = false;
        checkAudioControl();

        mLiveLibrary.onPause(mSoftActivity.get());
        mBitmapLibrary.onPause(mSoftActivity.get());

        if (mIjkPlayerWrapper != null) {
            Logger.t(TAG).e("DEBUG onFragmentPause: " + mIjkPlayerWrapper.isPlaying());
        } else {
            Logger.t(TAG).e("DEBUG onFragmentPause: ");
        }
        if (mIjkPlayerWrapper != null && mIjkPlayerWrapper.isPlaying()) {
            stopLive();
        }
    }

    private void checkAudioControl() {
        if (viewModel != null && viewModel.isAudioPush) {
            viewModel.isAudioPush = false;
            if (mIjkPlayerWrapper != null) mIjkPlayerWrapper.setVolume(1f, 1f);
            llTalkback.setVisibility(View.GONE);
            viewModel.inputs.endAudio(false);
        }
    }

    @Override
    public void onDetach() {
        IjkPlayerLogUtil.logIJKMEDIA();
        super.onDetach();

        if (mLiveLibrary != null) {
            mLiveLibrary.onDestroy();
        }

        if (mBitmapLibrary != null) {
            mBitmapLibrary.onDestroy();
        }

//        destroyWrapper();
    }

//    private void destroyWrapper() {
//        // for ANR in hotspot mode
//        new Thread(() -> {
//            if (mIjkPlayerWrapper != null) {
//                Logger.t(TAG).e("DEBUG destroyWrapper: " + mIjkPlayerWrapper.mMediaPlayer);
////                mIjkPlayerWrapper.release();
//                Looper.prepare();
//                new Handler().postDelayed(new Runnable() {
//                    @Override
//                    public void run() {
//                        Logger.t(TAG).e("DEBUG destroyWrapper postDelayed: " + mIjkPlayerWrapper.mMediaPlayer);
//                    }
//                }, 1000);
//                Looper.loop();
//            }
//        }).start();
//    }

    @Override
    protected void onFragmentResume() {
        isForeground = true;
        initEvents();
        mLiveLibrary.onResume(mSoftActivity.get());
        mBitmapLibrary.onResume(mSoftActivity.get());
        if (mIjkPlayerWrapper != null) {
            mIjkPlayerWrapper.resume();
        }
    }

    @Override
    protected void onFragmentFirstVisible() {
        mSoftActivity.get().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        //竖屏到横屏 延迟3s 隐藏控制栏
        Action mControlPanelAction = () -> {
            if (isFullScreen()) {
                hideControlPanel();
                setImmersiveMode(true);
            }
        };

        mHandler = new ControlPanelHandler(mControlPanelAction);

        goLive = getArguments().getBoolean(GO_LIVE, false);
        clipID = getArguments().getLong(CLIP_ID, -1);
        mCameraBean = (CameraBean) getArguments().getSerializable(IntentKey.CAMERA_BEAN);
        mFleetCamera = (FleetCameraBean) getArguments().getSerializable(IntentKey.FLEET_CAMERA);

        if (mCameraBean != null) {
            tvToolbarTitle.setText(mCameraBean.name);
            viewModel.setSerialNumber(mCameraBean.sn);
            infoMsgQueue = new InfoMsgQueue();
            needDewarp = mCameraBean.sn.startsWith("2");
        } else if (mFleetCamera != null) {
            String cameraSN = mFleetCamera.getSn();
            tvToolbarTitle.setText(cameraSN);
            viewModel.setSerialNumber(cameraSN);
            needDewarp = cameraSN.startsWith("2");
        }

        adaptationFor4K();

        mIjkPlayerWrapper = new IjkPlayerImpl();

        mLiveLibrary = createLiveLibrary();
        mBitmapLibrary = createBitmapLibrary();

        //初始化网络请求
        if (Constants.isFleet()) {
            mApiClient = ApiClient.createApiService();
        } else {
            mApiService = ApiService.createApiService();
        }

        initView();

        intervalCheck();

        if (goLive) {
            startPlay();
        }

        if (clipID != -1) {
            if (remoteVideoFragment != null) {
                Menu menu = toolbar.getMenu();
                MenuItem item = menu.findItem(R.id.action_setting);
                if (item != null) item.setVisible(false);
                remoteVideoFragment.scrollToClipID(clipID);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_AUDIO_REQUESTCODE) {
            if (grantResults.length > 0 && grantResults[0] == PermissionChecker.PERMISSION_GRANTED) {
                ibTalkback.setEnabled(true);
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        ibTalkback.setEnabled(false);
                        DialogHelper.showPermissionDialog(mSoftActivity.get(),
                                () -> {
                                    ibTalkback.setEnabled(true);
                                    PermissionUtil.startAppSetting(mSoftActivity.get());
                                },
                                () -> {
                                    ibTalkback.setEnabled(true);
                                });
                    } else {
                        ibTalkback.setEnabled(true);
                        Toast.makeText(mSoftActivity.get(), getResources().getString(R.string.audio_must_allow), Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mLiveLibrary.onOrientationChanged(mSoftActivity.get());
        mBitmapLibrary.onOrientationChanged(mSoftActivity.get());

        if (isFullScreen()) {
            if (remoteVideoFragment != null) remoteVideoFragment.hideNavigation();

            toolbar.setVisibility(View.GONE);
            rl_control_portrait.setVisibility(View.GONE);
//            ll_videoSrc.setVisibility(View.VISIBLE);
            rl_thumbnail_landscape.setVisibility(View.VISIBLE);

            Display defaultDisplay = mSoftActivity.get().getWindowManager().getDefaultDisplay();
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
            if (remoteVideoFragment != null) remoteVideoFragment.showNavigation();

            toolbar.setVisibility(View.VISIBLE);
            rl_control_portrait.setVisibility(View.VISIBLE);
//            ll_videoSrc.setVisibility(View.GONE);
            rl_thumbnail_landscape.setVisibility(View.GONE);

            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            mMediaWindow.setLayoutParams(params);
        }

        if (isFullScreen() && viewModel != null && !viewModel.isLiveOrNot) {
            rl_videoProgress.setVisibility(View.VISIBLE);
        } else {
            rl_videoProgress.setVisibility(View.INVISIBLE);
        }

        setImmersiveMode(isFullScreen());
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_cloud_view;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);
        setupToolbar();
        setupSeekbar();
    }

    private void onfilterVisibility(Integer integer) {
        Logger.t(TAG).d("onfilterVisibility: " + integer);
        rlFilter.setVisibility(integer);
    }

    private void onClipListStat(int size) {
        Logger.t(TAG).d("onClipListStat size: " + size);

        tv_event_num.setText(String.valueOf(size));
    }

    private void initVideoView() {
        if (mCameraBean != null) {
            Boolean isOnline = mCameraBean.isOnline;
            if (isOnline) {
                viewModel.inputs.queryLiveSignal(mCameraBean.sn);
                ib_startPlay.setVisibility(View.VISIBLE);
                view_shadow.setVisibility(View.GONE);
                tv_offline_tips.setVisibility(View.GONE);
            } else {
                iv_curStatus.setImageResource(R.drawable.icon_offline);
                iv_videoSrc.setImageResource(R.drawable.icon_offline);
                ib_startPlay.setVisibility(View.GONE);
                view_shadow.setVisibility(View.VISIBLE);
                tv_offline_tips.setVisibility(View.VISIBLE);
            }
            tvCurStatus.setText(isOnline ? R.string.live_remote : R.string.offline);
            tv_videoSrc.setText(isOnline ? R.string.live_remote : R.string.offline);
            fetchThumbnail(mCameraBean.thumbnailUrl, true);
        }/* else if (mFleetCamera != null && mFleetCamera.getOnlineStatus() != null) {
            boolean isOnline = mFleetCamera.getOnlineStatus().isIsOnline();
            if (isOnline) {
                viewModel.inputs.queryLiveSignal(mFleetCamera.getCameraSN());
                ib_startPlay.setVisibility(View.VISIBLE);
                view_shadow.setVisibility(View.GONE);
                tv_offline_tips.setVisibility(View.GONE);
            } else {
                iv_curStatus.setImageResource(R.drawable.icon_offline);
                iv_videoSrc.setImageResource(R.drawable.icon_offline);
                ib_startPlay.setVisibility(View.GONE);
                view_shadow.setVisibility(View.VISIBLE);
                tv_offline_tips.setVisibility(View.VISIBLE);
            }
            tvCurStatus.setText(isOnline ? R.string.live_remote : R.string.offline);
            tv_videoSrc.setText(isOnline ? R.string.live_remote : R.string.offline);
        }*/
    }

    private void initView() {
        initVideoView();

        if (Constants.isFleet()) {
            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            remoteVideoFragment = RemoteVideoFragment.newInstance(mFleetCamera);
            //
            try {
                transaction.add(R.id.frameLayout, remoteVideoFragment).commit();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        } else {
            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            remoteVideoFragment = RemoteVideoFragment.newInstance(mCameraBean);
            //
            try {
                transaction.add(R.id.frameLayout, remoteVideoFragment).commit();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        }

//        viewModel.filterClipBean(remoteVideoFragment.clipListStat, filterList);

        if (Constants.isFleet()) {
            rvType.setVisibility(View.INVISIBLE);
        }

        GridLayoutManager layoutManager = new GridLayoutManager(mSoftActivity.get(), 3);
        rvType.setLayoutManager(layoutManager);

        List<VideoType> dataList = new ArrayList<>();
        dataList.add(new VideoType(R.drawable.bg_type_motion, getString(R.string.video_type_motion)));
        dataList.add(new VideoType(R.drawable.bg_type_bump, getString(R.string.video_type_bump)));
        dataList.add(new VideoType(R.drawable.bg_type_impact, getString(R.string.impact)));
        dataList.add(new VideoType(R.drawable.bg_type_highlight, getString(R.string.video_type_highlight)));
        dataList.add(new VideoType(R.drawable.bg_type_buffered, getString(R.string.video_type_buffered)));

        TypeAdapter adapter = new TypeAdapter(mSoftActivity.get(), R.layout.item_video_type, dataList);
        rvType.setAdapter(adapter);

        adapter.setOnItemChildClickListener((adapter1, view, position) -> {
            CheckBox checkBox = view.findViewById(R.id.cb_type);
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
                }
            } else {
                resource = R.drawable.btn_funnel_multiple;
            }

            viewModel.filterClipBean(remoteVideoFragment.clipListStat, filterList);
            remoteVideoFragment.viewModel().loadClipBean(filterList, true);
            remoteVideoFragment.viewModel().filterResource(resource);

        });
    }

    private void adaptationFor4K() {
        String serialNumber = viewModel.getSerialNumber();
        if (TextUtils.isEmpty(serialNumber)) {
            return;
        }

        if (serialNumber.startsWith("6")) {
            mXRadio = 32;
            mYRadio = 27;
        } else {
            mXRadio = 16;
            mYRadio = 9;
        }
        mMediaWindow.setRatio(mXRadio, mYRadio);
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

                if (mIjkPlayerWrapper != null) {
                    mIjkPlayerWrapper.seek(progress);
                }
            }
        });
    }

    private void apiError(ErrorEnvelope error) {
        Toast.makeText(mSoftActivity.get(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void networkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(mSoftActivity.get(), throwable);
    }

    private void onSettingChangeEvent(SettingChangeEvent event) {
        Logger.t(TAG).d("onSettingChangeEvent: " + event.getAction() + "--" + event.isUpdated());
        if (SettingChangeEvent.ACTION_FAILURE.equals(event.getAction())) {
            ll_setting_request.setVisibility(View.VISIBLE);
            new Handler().postDelayed(() -> ll_setting_request.setVisibility(View.GONE), 6000);
        }
    }

    private void onCameraList(Optional<ArrayList<CameraBean>> listOptional) {
        ArrayList<CameraBean> cameraBeans = listOptional.get();
        int size = cameraBeans.size();
        tvSlidingTips.setVisibility(size <= 1 ? View.INVISIBLE : View.VISIBLE);

        for (CameraBean bean : cameraBeans) {
            if (mCameraBean.sn.equals(bean.sn)) {
                mCameraBean = bean;
                checkSomeMsg(bean);
                initMsgEvent();
                break;
            }
        }
    }

    private void initMsgEvent() {
        if (infoMsgQueue != null) {
            infoMsgQueue.asObservable()
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::onInfoMsgQueue, new ServerErrorHandler(TAG));
        }
    }

    private void onInfoMsgQueue(InfoMsgQueue imq) {
        InfoMsgQueue.InfoMsg msg = imq.peek();
        if (llMessageRemind.getVisibility() == View.VISIBLE) {
            llMessageRemind.setVisibility(View.GONE);
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
        if (llMessageRemind.getVisibility() == View.VISIBLE) {
            llMessageRemind.setVisibility(View.GONE);
        }

        llMessageRemind.setBackgroundColor(InfoMsgUtils.getInstance().getColor(mSoftActivity.get(), infoMsg.getType()));
        tvMsgContent.setText(InfoMsgUtils.getInstance().getMessage(mSoftActivity.get(), infoMsg.getType()));

        String action = InfoMsgUtils.getInstance().getAction(mSoftActivity.get(), infoMsg.getType());
        ImageButton ibMsgAction = llMessageRemind.findViewById(R.id.ib_msg_action);
        if (TextUtils.isEmpty(action)) {
            ibMsgAction.setVisibility(View.GONE);
        } else {
            ibMsgAction.setVisibility(View.VISIBLE);
            ibMsgAction
                    .setOnClickListener(v -> {
                        if (mCameraBean != null && mSoftActivity.get() != null) {
                            InfoMsgUtils.getInstance().clickAction(mSoftActivity.get(), mCameraBean.sn, infoMsg.getType());
                        }
                        llMessageRemind.setVisibility(View.GONE);
                    });
        }

        llMessageRemind.findViewById(R.id.ib_msg_close)
                .setOnClickListener(v -> llMessageRemind.setVisibility(View.GONE));

        llMessageRemind.setVisibility(View.VISIBLE);
    }

    private void checkSomeMsg(CameraBean cameraBean) {
        Boolean is4G = cameraBean.is4G;
        if (is4G) {
            ApiService.createApiService().getCurrentSub(cameraBean.sn)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<SubscribeResponse>() {
                        @Override
                        protected void onHandleSuccess(SubscribeResponse data) {
                            onHandleDataPlan(data);
                        }
                    });
        }
    }

    private void onHandleDataPlan(SubscribeResponse data) {
        Logger.t(TAG).d("getCurrentSub: " + data.getStatus());
        InfoMsgQueue infoMsgQueue = null;
        if (mCameraBean != null) {
            infoMsgQueue = this.infoMsgQueue;
        }

        if ("in_service".equals(data.getStatus()) || "paid".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        } else if ("none".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.putMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        } else {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        }
    }

    private void onFleetCameraList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeans = listOptional.get();
        for (FleetCameraBean bean : cameraBeans) {
            if (mFleetCamera.getSn().equals(bean.getSn())) {
                mFleetCamera = bean;
                break;
            }
        }
    }

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
        if (mIjkPlayerWrapper != null && mIjkPlayerWrapper.isPlaying()) {
            if (viewModel != null && !viewModel.isLiveOrNot) {
                long currentPos = mIjkPlayerWrapper.getCurrentPosition();
                long duration = mIjkPlayerWrapper.getDuration();
                Logger.t(TAG).d("checkProgress currentPos: " + currentPos + " duration: " + duration);
                refreshProgress(currentPos);

                if (duration > 0 && isFullScreen()) {
                    tvVideoProgress.setText(DateUtils.formatElapsedTime(currentPos / 1000));
                    tvVideoDuration.setText(DateUtils.formatElapsedTime(duration / 1000));
                    sbVideo.setProgress((int) currentPos);
                    sbVideo.setMax((int) duration);
                }
            }
        }
    }

    private void refreshProgress(long currentPos) {
        if (Constants.isFleet()) {
            EventBeanPos eventBeanPos = getEventBeanPos();
            if (eventBeanPos == null) {
                return;
            }
            EventBeanPos cuEventBeanPos = new EventBeanPos(eventBeanPos.getEventBean(), currentPos);
            EventBeanPosChangeEvent event = new EventBeanPosChangeEvent(cuEventBeanPos, TAG);
            RxBus.getDefault().post(event);
        } else {
            ClipBeanPos clipBeanPos = getClipBeanPos();
            if (clipBeanPos == null) {
                return;
            }
            ClipBeanPos curClipBeanPos = new ClipBeanPos(clipBeanPos.getClipBean(), currentPos);
            ClipBeanPosChangeEvent event = new ClipBeanPosChangeEvent(curClipBeanPos, TAG);
            RxBus.getDefault().post(event);
        }
    }

    @SuppressLint("CheckResult")
    private void onClipBeanPosChangeEvent(ClipBeanPosChangeEvent event) {
        if (event.getPublisher().equals(RemoteVideoFragment.class.getSimpleName())) {

            updateUI(event.getIntent());
            if (event.getClipBeanPos() != null) {
                if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY) {
                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_PLAY");
                    if (viewModel != null && viewModel.isLiveOrNot) {
                        Logger.t(TAG).d("stopLive");
                        ibTalkback.setVisibility(View.GONE);

                        unsubscribeLiveStatus();
                        unsubscribeBPS();
                        unsubscribeLiveTime();

                        viewModel.isLiveOrNot(false);
                    }

                    //获得播放的clipbeanpos
                    mClipBeanPos = event.getClipBeanPos();
                    ClipBean clipBean = mClipBeanPos.getClipBean();
                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(lensMode);
                    retryOpen(clipBean.url, false);
                } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");
                    if (viewModel != null && viewModel.isLiveOrNot) {
                        Logger.t(TAG).d("stopLive");
                        ibTalkback.setVisibility(View.GONE);

                        unsubscribeLiveStatus();
                        unsubscribeBPS();
                        unsubscribeLiveTime();

                        viewModel.isLiveOrNot(false);
                    }

                    ClipBean clipBean = event.getClipBeanPos().getClipBean();
                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(lensMode);
                    fetchThumbnail(clipBean.thumbnail, false);
                    if (mIjkPlayerWrapper != null) {
                        mIjkPlayerWrapper.pause();
                    }
                }
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
                Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_LIVE");
                if (viewModel != null) viewModel.isLiveOrNot(true);

                Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                    if (mIjkPlayerWrapper != null) {
                        Logger.t(TAG).e("DEBUG onClipBeanPosChangeEvent INTENT_LIVE");
                        mIjkPlayerWrapper.release();
                    }
                })
                        .subscribeOn(Schedulers.newThread())
                        .compose(bindToLifecycle())
                        .subscribe();
            }
        }
    }

    private void onEventBeanPosChangeEvent(EventBeanPosChangeEvent event) {
        if (!event.getPublisher().equals(RemoteVideoFragment.class.getSimpleName())) {
            return;
        }

        updateUI(event.getIntent());
        if (event.getClipBeanPos() != null) {
            if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY) {
                Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_PLAY");
                if (viewModel != null && viewModel.isLiveOrNot) {
                    Logger.t(TAG).d("stopLive");
                    ibTalkback.setVisibility(View.GONE);

                    unsubscribeLiveStatus();
                    unsubscribeBPS();
                    unsubscribeLiveTime();

                    viewModel.isLiveOrNot(false);
                }

                //获得播放的clipbeanpos
                mEventBeanPos = event.getClipBeanPos();
                EventBean eventBean = mEventBeanPos.getEventBean();
                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(lensMode);
                retryOpen(eventBean.getMp4Url(), false);
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");
                if (viewModel != null && viewModel.isLiveOrNot) {
                    Logger.t(TAG).d("stopLive");
                    ibTalkback.setVisibility(View.GONE);

                    unsubscribeLiveStatus();
                    unsubscribeBPS();
                    unsubscribeLiveTime();

                    viewModel.isLiveOrNot(false);
                }

                EventBean eventBean = event.getClipBeanPos().getEventBean();
                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(lensMode);
//                fetchThumbnail(eventBean.thumbnail, false);
                if (mIjkPlayerWrapper != null) {
                    mIjkPlayerWrapper.pause();
                }
            }
        } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
            Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_LIVE");
            if (viewModel != null) viewModel.isLiveOrNot(true);

            Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                if (mIjkPlayerWrapper != null) {
                    Logger.t(TAG).e("DEBUG onEventBeanPosChangeEvent INTENT_LIVE");
                    mIjkPlayerWrapper.release();
                }
            })
                    .subscribeOn(Schedulers.newThread())
                    .compose(bindToLifecycle())
                    .subscribe();
        }
    }

    private void updateUI(int state) {
        switch (state) {
            case ClipBeanPosChangeEvent.INTENT_LIVE:
                gl_thumbnail.setVisibility(View.VISIBLE);
                gl_live.setVisibility(View.GONE);

                togglePlayState(true);
                initVideoView();
                cancelBusy();

                tv_bps_port.setVisibility(View.GONE);
                tv_bps_land.setVisibility(View.GONE);
                tv_liveStatus.setVisibility(View.VISIBLE);
                break;
            case ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL:
                gl_thumbnail.setVisibility(View.VISIBLE);
                gl_live.setVisibility(View.GONE);

                togglePlayState(true);
                cancelBusy();

                view_shadow.setVisibility(View.GONE);
                tv_offline_tips.setVisibility(View.GONE);

                iv_curStatus.setImageResource(R.drawable.icon_cloud);
                iv_videoSrc.setImageResource(R.drawable.icon_cloud);
                tvCurStatus.setText(R.string.cloud);
                tv_videoSrc.setText(R.string.cloud);

                tv_bps_port.setVisibility(View.GONE);
                tv_bps_land.setVisibility(View.GONE);
                tv_liveStatus.setVisibility(View.GONE);
                break;
            case ClipBeanPosChangeEvent.INTENT_PLAY:
                gl_live.setVisibility(View.VISIBLE);
                gl_thumbnail.setVisibility(View.GONE);

                togglePlayState(false);
                busy();

                view_shadow.setVisibility(View.GONE);
                tv_offline_tips.setVisibility(View.GONE);

                iv_curStatus.setImageResource(R.drawable.icon_cloud);
                iv_videoSrc.setImageResource(R.drawable.icon_cloud);
                tvCurStatus.setText(R.string.cloud);
                tv_videoSrc.setText(R.string.cloud);

                tv_bps_port.setVisibility(View.GONE);
                tv_bps_land.setVisibility(View.GONE);
                tv_liveStatus.setVisibility(View.GONE);
                break;
        }
    }

    @SuppressLint("CheckResult")
    private void fetchThumbnail(String thumbnailUrl, boolean blurOrNot) {
        Observable.create((ObservableOnSubscribe<Optional<Bitmap>>) emitter -> {
            try {
//                Logger.t(TAG).d("fetchThumbnail: " + thumbnailUrl);
                if (!TextUtils.isEmpty(thumbnailUrl)) {

                    WindowManager manager = (WindowManager) mSoftActivity.get().getSystemService(Context.WINDOW_SERVICE);
                    int width = 0;
                    if (manager != null) {
                        width = manager.getDefaultDisplay().getWidth();
                    }
//                    Logger.t(TAG).d("fetchThumbnail width: " + width);

                    Bitmap bitmap = Glide.with(mSoftActivity.get())
                            .load(thumbnailUrl)
                            .asBitmap()
                            .diskCacheStrategy(DiskCacheStrategy.ALL)
                            .into(width, width * mYRadio / mXRadio)
                            .get();

                    if (blurOrNot) {
                        GaussianBlurUtil blur = new GaussianBlurUtil(mSoftActivity.get());
                        Bitmap gaussianBlur = blur.gaussianBlur(20, bitmap);
                        emitter.onNext(Optional.ofNullable(gaussianBlur));
                    } else {
                        emitter.onNext(Optional.ofNullable(bitmap));
                    }
                } else {
                    emitter.onNext(Optional.empty());
                }
            } catch (Exception e) {
                Logger.t(TAG).e("fetchThumbnail error: " + e.getMessage());
                emitter.onNext(Optional.empty());
            }
        })
                .filter(bitmapOptional -> bitmapOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(bitmapOptional -> {
                    Bitmap bitmap = bitmapOptional.get();

                    getBitmapLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight());
                    // texture
                    if (mCallback != null) {
                        mCallback.texture(bitmap);
                    }
                }, new ServerErrorHandler(TAG));
    }

    private void switchProjection(boolean lensMode) {
        int projectionMode = mLiveLibrary.getProjectionMode();
        Logger.t(TAG).d("projectionMode: " + projectionMode + " lensMode: " + lensMode);

        int switchMode = -1;
        if (lensMode) {
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

        if (switchMode != -1) {
            mBitmapLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
            mLiveLibrary.switchProjectionMode(mSoftActivity.get(), switchMode);
        }
    }

    private ClipBeanPos getClipBeanPos() {
        return mClipBeanPos;
    }

    private EventBeanPos getEventBeanPos() {
        return mEventBeanPos;
    }

    @SuppressLint("CheckResult")
    private void stopLive() {
        Logger.t(TAG).d("stopLive");
        ibTalkback.setVisibility(View.GONE);

        unsubscribeLiveStatus();
        unsubscribeBPS();
        unsubscribeLiveTime();

        Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
            Logger.t(TAG).d("DEBUG stopLive into: " + mIjkPlayerWrapper);
            if (mIjkPlayerWrapper != null) {
                Logger.t(TAG).e("DEBUG stopLive");
                mIjkPlayerWrapper.stop();
            }
            emitter.onNext(Optional.empty());
        })
                .subscribeOn(Schedulers.newThread())
                .compose(bindToLifecycle())
                .subscribe(aVoid -> {
                    LiveStreamBody streamBody = new LiveStreamBody();
                    streamBody.action = "stop";

                    if (mApiService != null) {
                        mApiService.controlStream(mCameraBean.sn, streamBody)
                                .compose(Transformers.switchSchedulers())
                                .compose(bindToLifecycle())
                                .subscribe(new BaseObserver<LiveStatusResponse>() {
                                    @Override
                                    protected void onHandleSuccess(LiveStatusResponse data) {
                                        onStopLiveResponse(data);
                                    }
                                });
                    } else if (mApiClient != null) {
                        Logger.t(TAG).d("stop live on CloudViewFrag");
//                        mApiClient.controlStream(mFleetCamera.getSn(), streamBody)
//                                .compose(Transformers.switchSchedulers())
//                                .compose(bindToLifecycle())
//                                .subscribe(new BaseObserver<LiveStatusResponse>() {
//                                    @Override
//                                    protected void onHandleSuccess(LiveStatusResponse data) {
//                                        onStopLiveResponse(data);
//                                    }
//                                });
                    }
                }, new ServerErrorHandler(TAG));
    }

    private void onStopLiveResponse(LiveStatusResponse response) {
        Logger.t(TAG).d("onStopLiveResponse：%s", ToStringUtils.getString(response));
    }

    @SuppressLint("CheckResult")
    private void startLive() {
        if (mApiService != null) {
            mApiService.getCurrentSub(mCameraBean.sn)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::handleCurrentSub, this::handleLiveError);
        } else if (mApiClient != null) {
            LiveStreamBody streamBody = new LiveStreamBody();
            streamBody.action = "start";
            mApiClient.startLive(mFleetCamera.getSn(), HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::onStartLiveResponse, this::handleLiveError);
        }
    }

    @SuppressLint("CheckResult")
    private void handleCurrentSub(SubscribeResponse response) {
        String status = response.getStatus();
        Logger.t(TAG).d("getCurrentSub: " + status);

        if ("in_service".equals(status) || "paid".equals(status)) {
            LiveStreamBody streamBody = new LiveStreamBody();
            streamBody.action = "start";
            mApiService.controlStream(mCameraBean.sn, streamBody)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(this::onStartLiveResponse, this::handleLiveError);
        } else {
            if ("expired".equals(status)) {
                Toast.makeText(mSoftActivity.get(), R.string.network_error_data_plan_expired, Toast.LENGTH_SHORT).show();
            } else if ("suspended".equals(status)) {
                Toast.makeText(mSoftActivity.get(), R.string.network_error_data_plan_suspended, Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(mSoftActivity.get(), R.string.network_error_data_plan_not_subscribed, Toast.LENGTH_SHORT).show();
            }
            cancelStartLive();
        }
    }

    private void handleLiveError(Throwable throwable) {
        Logger.t(TAG).d("handleLiveError:" + throwable.getMessage());
        NetworkErrorHelper.handleCommonError(mSoftActivity.get(), throwable);
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
        pollLiveStatusSub = Observable.interval(0, 500, TimeUnit.MILLISECONDS)
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
        if (Constants.isFleet()) {
            liveStatus = mApiClient.getLiveStatus(mFleetCamera.getSn(), HornApplication.getComponent().currentUser().getAccessToken());
        } else {
            liveStatus = mApiService.getLiveStatus(mCameraBean.sn);
        }
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
                        Toast.makeText(mSoftActivity.get(), R.string.play_error, Toast.LENGTH_SHORT).show();
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
        Logger.t(TAG).d("onLiveStatus: %s", response.toString());
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
                Logger.t(TAG).e("DEBUG LIVE_STATE");
                if (unsubscribeLiveStatus()) {
                    Logger.t(TAG).e("DEBUG unsubscribeLiveStatus 已经释放");
                    return;
                }

                tv_liveStatus.setVisibility(View.GONE);
                tv_liveStatus.setText("");
                if (viewModel != null) viewModel.isLiveOrNot(true);

                if (mCameraBean != null) {
                    boolean lensMode = TextUtils.isEmpty(mCameraBean.rotate) || LENS_NORMAL.equals(mCameraBean.rotate);
                    switchProjection(lensMode);
                } else if (mFleetCamera != null) {
                    boolean lensMode = TextUtils.isEmpty(mFleetCamera.getRotate()) || LENS_NORMAL.equals(mFleetCamera.getRotate());
                    switchProjection(lensMode);
                }

                retryOpen(response.data.playUrl, true);
                break;
            default:
                break;
        }
    }

//    private void onLiveError(Throwable e) {
//        Logger.t(TAG).d("onLiveError：%s", e.getMessage());
//        cancelBusy();
//        togglePlayState(true);
//        unsubscribeLiveStatus();
//
//        NetworkErrorHelper.handleCommonError(this, e);
//    }

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
                        viewModel.inputs.queryLiveBPS(mFleetCamera.getSn());
                    } else {
                        viewModel.inputs.queryLiveBPS(mCameraBean.sn);
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
        if (isAdded()) {
            iv_curStatus.setImageDrawable(getResources().getDrawable(resource));
            iv_videoSrc.setImageDrawable(getResources().getDrawable(resource));
        }
    }

    private void initLivePlayer() {
        mIjkPlayerWrapper.setOnPreparedListener(mp -> {
            Logger.t(TAG).d("onPrepared: " + mp);
            cancelBusy();
            togglePlayState(false);
            if (!isForeground) {
                mp.pause();
            }
            if (viewModel != null && viewModel.isLiveOrNot) {
                //双向语音可用
                if (mCameraBean != null && mCameraBean.state != null) {
                    String firmware = mCameraBean.state.firmware;
                    if (validFirmwareVersion(firmware)) {
                        ibTalkback.setVisibility(View.VISIBLE);
                    }
                }

                startQueryLiveBPS();
                startUpdateLiveTime();
            }
            gl_live.setVisibility(View.VISIBLE);
            gl_thumbnail.setVisibility(View.GONE);
            if (getLiveLibrary() != null) {
                getLiveLibrary().notifyPlayerChanged();
            }
        });

        mIjkPlayerWrapper.setOnErrorListener((mp, what, extra) -> {
            Logger.t(TAG).e("onError what: " + what + " extra: " + extra);
            cancelBusy();
            togglePlayState(true);
            stopLive();
            String error = String.format(Locale.getDefault(), "Play error: " + extra);
            Toast.makeText(mSoftActivity.get(), error, Toast.LENGTH_SHORT).show();
            return true;
        });

        mIjkPlayerWrapper.setOnInfoListener((iMediaPlayer, what, extra) -> {
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

        mIjkPlayerWrapper.setOnVideoSizeChangedListener((mp, width, height, sar_num, sar_den) ->
                getLiveLibrary().onTextureResize(width, height));

        mIjkPlayerWrapper.setOnCompletionListener(iMediaPlayer ->
                onVideoCompletion(iMediaPlayer.getDuration()));
    }

    private void onVideoCompletion(long duration) {
        Logger.t(TAG).e("onVideoCompletion: " + duration);
        if (viewModel != null && viewModel.isLiveOrNot) {
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
        if (Constants.isFleet()) {
            EventBeanPos eventBeanPos = getEventBeanPos();
            if (eventBeanPos == null) {
                return;
            }
            EventBeanPos curEventPos = new EventBeanPos(eventBeanPos.getEventBean(), duration);
            EventBeanPosChangeEvent event = new EventBeanPosChangeEvent(curEventPos, TAG, EventBeanPosChangeEvent.INTENT_PLAY_END);
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

    @SuppressLint("CheckResult")
    private void retryOpen(String url, boolean isLiveState) {
        if (!TextUtils.isEmpty(url)) {
            Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                if (mIjkPlayerWrapper != null) {
                    // just for main thread
                    initLivePlayer();
                    if (isLiveState) {
                        mIjkPlayerWrapper.setVideoUrl(url, null);
                    } else {
                        Map<String, String> cookie = CookieUtil.getCookie();
                        mIjkPlayerWrapper.setVideoUrl(url, cookie);
                    }
                }
            })
                    .subscribeOn(AndroidSchedulers.mainThread())
                    .compose(bindToLifecycle())
                    .subscribe();
        }
    }

    public void setImmersiveMode(boolean immersiveMode) {
        if (immersiveMode) {
            mSoftActivity.get().getWindow().getDecorView().setSystemUiVisibility(FULL_SCREEN_FLAG);
        } else {
            mSoftActivity.get().getWindow().getDecorView().setSystemUiVisibility(0);
        }
    }

    @SuppressLint("CheckResult")
    private void initEvents() {
        viewModel.getCurrentUser()
                .devicesObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraList, new ServerErrorHandler(TAG));

        viewModel.getCurrentUser()
                .fleetDevicesObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onFleetCameraList, new ServerErrorHandler(TAG));

        viewModel.outputs.liveSignal()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLiveSignal, new ServerErrorHandler(TAG));

        viewModel.outputs.liveBPS()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLiveBPS, new ServerErrorHandler(TAG));

        viewModel.outputs.loadClipBeans()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipListStat, new ServerErrorHandler(TAG));

        viewModel.outputs.filterVisibility()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onfilterVisibility, new ServerErrorHandler(TAG));

        viewModel.errors.apiError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::apiError, new ServerErrorHandler(TAG));

        viewModel.errors.networkError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::networkError, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(ClipBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipBeanPosChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(EventBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventBeanPosChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(SettingChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSettingChangeEvent, new ServerErrorHandler(TAG));
    }

    public MDVRLibrary getLiveLibrary() {
        return mLiveLibrary;
    }

    public MDVRLibrary getBitmapLibrary() {
        return mBitmapLibrary;
    }

    public void cancelBusy() {
        progressBar.setVisibility(View.GONE);
    }

    public void busy() {
        progressBar.setVisibility(View.VISIBLE);
    }

    private void togglePlayState(boolean toPlay) {
        if (toPlay) {
            ib_startPlay.setVisibility(View.VISIBLE);
            ib_stopPlay_port.setVisibility(View.GONE);
            ib_stopPlay_land.setVisibility(View.INVISIBLE);
        } else {
            ib_startPlay.setVisibility(View.GONE);
            ib_stopPlay_port.setVisibility(View.VISIBLE);
            ib_stopPlay_land.setVisibility(View.VISIBLE);
        }
    }

    protected MDVRLibrary createLiveLibrary() {
        int projectionMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;

        if (mCameraBean != null) {
            boolean lensMode = TextUtils.isEmpty(mCameraBean.rotate) || LENS_NORMAL.equals(mCameraBean.rotate);
            Logger.t(TAG).d("lensMode: " + lensMode);
            projectionMode = lensMode ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
        } else if (mFleetCamera != null) {
            boolean lensMode = TextUtils.isEmpty(mFleetCamera.getRotate()) || LENS_NORMAL.equals(mFleetCamera.getRotate());
            Logger.t(TAG).d("lensMode: " + lensMode);
            projectionMode = lensMode ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
        }

        Logger.t(TAG).d("projectionMode: " + (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS));

        return mIjkPlayerWrapper.init(getView().findViewById(R.id.gl_live), mSoftActivity.get());
//        return MDVRLibrary.with(mSoftActivity.get())
//                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
//                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
//                .asVideo(surface -> {
//                    Logger.t(TAG).d("onSurfaceReady: " + surface);
//                    if (mIjkPlayerWrapper != null) {
//                        mIjkPlayerWrapper.setSurface(surface);
//                    }
//                })
//                .ifNotSupport(mode -> {
//                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
//                            ? "onNotSupport:MOTION" : "onNotSupport:" + mode;
//                    Toast.makeText(mSoftActivity.get(), tip, Toast.LENGTH_SHORT).show();
//                })
//                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
//                .pinchEnabled(false)
//                .projectionMode(projectionMode)
//                .projectionFactory(new CustomProjectionFactory())
//                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
//                .build((GLSurfaceView) getView().findViewById(R.id.gl_live));
    }

    protected MDVRLibrary createBitmapLibrary() {
        int projectionMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;

        if (mCameraBean != null) {
            boolean lensMode = TextUtils.isEmpty(mCameraBean.rotate) || LENS_NORMAL.equals(mCameraBean.rotate);
            Logger.t(TAG).d("lensMode: " + lensMode);
            projectionMode = lensMode ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
        } else if (mFleetCamera != null) {
            boolean lensMode = TextUtils.isEmpty(mFleetCamera.getRotate()) || LENS_NORMAL.equals(mFleetCamera.getRotate());
            Logger.t(TAG).d("lensMode: " + lensMode);
            projectionMode = lensMode ?
                    CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
        }

        Logger.t(TAG).d("projectionMode: " + (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS));

        return MDVRLibrary.with(mSoftActivity.get())
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asBitmap(callback -> {
//                    Logger.t(TAG).d("load image with max texture size:" + callback.getMaxTextureSize());
                    mCallback = callback;
                    if (mCameraBean != null) {
                        boolean lensMode = TextUtils.isEmpty(mCameraBean.rotate) || LENS_NORMAL.equals(mCameraBean.rotate);
                        Logger.t(TAG).d("lensMode: " + lensMode);
                        fetchThumbnail(mCameraBean.thumbnailUrl, true);
                    } else if (mFleetCamera != null) {
                        boolean lensMode = TextUtils.isEmpty(mFleetCamera.getRotate()) || LENS_NORMAL.equals(mFleetCamera.getRotate());
                        Logger.t(TAG).d("lensMode: " + lensMode);
//                        fetchThumbnail(mFleetCamera.thumbnailUrl, true);
                    }
                })
                .projectionMode(projectionMode)
                .projectionFactory(new CustomProjectionFactory())
                .build((GLSurfaceView) getView().findViewById(R.id.gl_thumbnail));
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

    public void setupToolbar() {
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> showCameras());

            toolbar.inflateMenu(R.menu.camera_setting);
            toolbar.setOnMenuItemClickListener(item -> {
                switch (item.getItemId()) {
                    case R.id.action_setting:
                        if (remoteVideoFragment != null) {
                            remoteVideoFragment.onToLiveClick();
                        }
                        if (Constants.isFleet()) {
                            DevicesActivity.launch(mSoftActivity.get(), mFleetCamera);
                        } else {
                            DevicesActivity.launch(mSoftActivity.get(), mCameraBean);
                        }
                        break;
                }
                return false;
            });
        }
    }

//    public List<BaseFragment> initPagerFragments() {
//        List<BaseFragment> fragments = new ArrayList<>();
//        fragments.add(RemoteVideoFragment.newInstance(mCameraBean));
//        return fragments;
//    }
//
//    public List<Integer> getFragmentTitlesRes() {
//        List<Integer> titles = new ArrayList<>();
//        titles.add(R.string.video_cloud);
//        return titles;
//    }

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

    private boolean unsubscribeLiveStatus() {
        tv_liveStatus.setVisibility(View.GONE);
        tv_liveStatus.setText("");

        boolean unSubscribe = false;
        if (pollLiveStatusSub != null) {
            unSubscribe = pollLiveStatusSub.isDisposed();
            Logger.t(TAG).e("DEBUG unsubscribeLiveStatus: " + pollLiveStatusSub.isDisposed());
        } else {
            Logger.t(TAG).e("DEBUG unsubscribeLiveStatus: " + "null");
        }
        if (pollLiveStatusSub != null && !pollLiveStatusSub.isDisposed()) {
            pollLiveStatusSub.dispose();
        }
        return unSubscribe;
    }

    private boolean validFirmwareVersion(String firmware) {
        if (TextUtils.isEmpty(firmware)) {
            return false;
        }

        int main = 0, sub = 0;

        int i_main = firmware.indexOf(".");
        if (i_main >= 0) {
            main = Integer.parseInt(firmware.substring(0, i_main));
            i_main++;

            int i_sub = firmware.indexOf(".", i_main);
            if (i_sub >= 0) {
                sub = Integer.parseInt(firmware.substring(i_main, i_sub));
            }
        }

        //voice call minimum version 1.15.x
        if (main > 0) {
            return main > 1 || sub >= 15;
        }

        return false;
    }
}
