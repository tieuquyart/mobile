package com.mk.autosecure.ui.activity;


import static android.view.MotionEvent.ACTION_DOWN;
import static android.view.MotionEvent.ACTION_UP;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
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
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.adapter.TypeAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ControlPanelHandler;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.GaussianBlurUtil;
import com.mk.autosecure.libs.utils.IjkPlayerLogUtil;
import com.mk.autosecure.libs.utils.MediaPlayerWrapper;
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
import com.mk.autosecure.ui.fragment.RemoteVideoFragment;
import com.mk.autosecure.viewmodels.LiveViewViewModel;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;
import com.waylens.vrlib.model.MDPinchConfig;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.util.ArrayList;
import java.util.List;
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
@SuppressLint({"CheckResult","NonConstantResourceId","SourceLockedOrientationActivity"})
@RequiresActivityViewModel(LiveViewViewModel.ViewModel.class)
public class LiveViewActivity extends BaseActivity<LiveViewViewModel.ViewModel> {

    private static final String TAG = LiveViewActivity.class.getSimpleName();
    private static final String GO_LIVE = "go_live";
    private static final String CLIP_ID = "clip_id";
    public static final int PERMISSION_AUDIO_REQUESTCODE = 11;

    private ClipBeanPos mClipBeanPos = null;

    private EventBeanPos mEventBeanPos = null;

    private MediaPlayerWrapper mMediaPlayerWrapper;

    private boolean isForeground = true;

    private MD360BitmapTexture.Callback mCallback;

    private ControlPanelHandler mHandler;

    private HornApiService mApiService;

    private FleetApiClient mApiClient;

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private Disposable pollLiveStatusSub = new CompositeDisposable();

    private Disposable pollLiveBPSSub = new CompositeDisposable();

    private Disposable pollLiveTimeSub = new CompositeDisposable();

    private RemoteVideoFragment remoteVideoFragment;

    public List<String> filterList = new ArrayList<>();

    private int mXRadio;
    private int mYRadio;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.iv_curStatus)
    ImageView iv_curStatus;

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

    @BindView(R.id.ll_talkback)
    LinearLayout llTalkback;

    @BindView(R.id.rl_talkback_voice)
    RelativeLayout rlTalkbackVoice;

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
            mBitmapLibrary.switchProjectionMode(LiveViewActivity.this, switchMode);
            mLiveLibrary.switchProjectionMode(LiveViewActivity.this, switchMode);
        }
    }

    @OnClick(R.id.ib_filter_finish)
    public void hideFilter() {
        rlFilter.setVisibility(View.GONE);
        remoteVideoFragment.viewModel().filterVisibility(View.VISIBLE);
    }

    @OnTouch(R.id.btn_talkback)
    public boolean onTalkback(MotionEvent event) {
        //check audio permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, PERMISSION_AUDIO_REQUESTCODE);
            } else {
                onAudioControl(event);
            }
        } else {
            onAudioControl(event);
        }
        return true;
    }

    private void onAudioControl(MotionEvent event) {
        int action = event.getAction();
        if (action == ACTION_DOWN) {
            viewModel.isAudioPush = true;
            if (mMediaPlayerWrapper != null) mMediaPlayerWrapper.setVolume(0f);
            rlTalkbackVoice.setVisibility(View.VISIBLE);
            viewModel.inputs.startAudio();
        } else if (action == ACTION_UP) {
            viewModel.isAudioPush = false;
            if (mMediaPlayerWrapper != null) mMediaPlayerWrapper.setVolume(1f);
            rlTalkbackVoice.setVisibility(View.INVISIBLE);
            viewModel.inputs.endAudio(false);
        }
    }

    private boolean isFullScreen() {
        int orientation = this.getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    public static void launch(Context context, CameraBean camera, boolean live) {
        Intent i = new Intent(context, LiveViewActivity.class);
        i.putExtra(IntentKey.CAMERA_BEAN, camera);
        i.putExtra(GO_LIVE, live);
        context.startActivity(i);
    }

    public static void launch(Context context, CameraBean cameraBean, long clipID) {
        Intent i = new Intent(context, LiveViewActivity.class);
        i.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        i.putExtra(CLIP_ID, clipID);
        context.startActivity(i);
    }

    public static void launch(Context context, FleetCameraBean fleetCamera) {
        Intent i = new Intent(context, LiveViewActivity.class);
        i.putExtra(IntentKey.FLEET_CAMERA, fleetCamera);
        context.startActivity(i);
    }

    private MDVRLibrary mLiveLibrary;
    private MDVRLibrary mBitmapLibrary;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_remote_live);
        ButterKnife.bind(this);

        setupToolbar();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        toolbar.inflateMenu(R.menu.camera_setting);
        toolbar.setOnMenuItemClickListener(item -> {
            switch (item.getItemId()) {
                case R.id.action_setting:
                    if (remoteVideoFragment != null) {
                        remoteVideoFragment.onToLiveClick();
                    }
                    if (Constants.isFleet()) {
                        DevicesActivity.launch(LiveViewActivity.this, mFleetCamera);
                    } else {
                        DevicesActivity.launch(LiveViewActivity.this, mCameraBean);
                    }
                    break;
            }
            return false;
        });

        //竖屏到横屏 延迟3s 隐藏控制栏
        Action mControlPanelAction = () -> {
            if (LiveViewActivity.this.isFullScreen()) {
                LiveViewActivity.this.hideControlPanel();
                LiveViewActivity.this.setImmersiveMode(true);
            }
        };

        mHandler = new ControlPanelHandler(mControlPanelAction);

        setupSeekbar();

        boolean goLive = getIntent().getBooleanExtra(GO_LIVE, false);
        long clipID = getIntent().getLongExtra(CLIP_ID, -1);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
        mFleetCamera = (FleetCameraBean) getIntent().getSerializableExtra(IntentKey.FLEET_CAMERA);

        if (mCameraBean != null) {
            viewModel.setSerialNumber(mCameraBean.sn);
        } else if (mFleetCamera != null) {
            viewModel.setSerialNumber(mFleetCamera.getSn());
        }

        adaptationFor4K();

        mLiveLibrary = createLiveLibrary();
        mBitmapLibrary = createBitmapLibrary();

        //初始化网络请求
        if (Constants.isFleet()) {
            mApiClient = ApiClient.createApiService();
        } else {
            mApiService = ApiService.createApiService();
        }

        mMediaPlayerWrapper = new MediaPlayerWrapper(true);

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
            tv_toolbarTitle.setText(isOnline ? R.string.live_remote : R.string.offline);
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
            tv_toolbarTitle.setText(isOnline ? R.string.live_remote : R.string.offline);
            tv_videoSrc.setText(isOnline ? R.string.live_remote : R.string.offline);
        }*/
    }

    private void initView() {
        initVideoView();

        boolean test = PreferenceUtils.getBoolean(PreferenceUtils.VOICE_CALL_TEST, Constants.isFleet());
        Logger.t(TAG).d("VOICE_CALL_TEST: " + test);
        if (test) {
            llTalkback.setVisibility(View.VISIBLE);
            frameLayout.setVisibility(View.GONE);
        }

        if (Constants.isFleet()) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            remoteVideoFragment = RemoteVideoFragment.newInstance(mFleetCamera);
            //
            try {
                transaction.add(R.id.frameLayout, remoteVideoFragment).commit();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        } else {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
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

        GridLayoutManager layoutManager = new GridLayoutManager(this, 3);
        rvType.setLayoutManager(layoutManager);

        List<VideoType> dataList = new ArrayList<>();
        dataList.add(new VideoType(R.drawable.bg_type_motion, getString(R.string.video_type_motion)));
        dataList.add(new VideoType(R.drawable.bg_type_bump, getString(R.string.video_type_bump)));
        dataList.add(new VideoType(R.drawable.bg_type_impact, getString(R.string.impact)));
        dataList.add(new VideoType(R.drawable.bg_type_highlight, getString(R.string.video_type_highlight)));
        dataList.add(new VideoType(R.drawable.bg_type_buffered, getString(R.string.video_type_buffered)));

        TypeAdapter adapter = new TypeAdapter(this, R.layout.item_video_type, dataList);
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

    private void onSettingChangeEvent(SettingChangeEvent event) {
        Logger.t(TAG).d("onSettingChangeEvent: " + event.getAction() + "--" + event.isUpdated());
        if (SettingChangeEvent.ACTION_FAILURE.equals(event.getAction())) {
            ll_setting_request.setVisibility(View.VISIBLE);
            new Handler().postDelayed(() -> ll_setting_request.setVisibility(View.GONE), 6000);
        }
    }

    private void onCameraList(Optional<ArrayList<CameraBean>> listOptional) {
        ArrayList<CameraBean> cameraBeans = listOptional.get();
        for (CameraBean bean : cameraBeans) {
            if (mCameraBean.sn.equals(bean.sn)) {
                mCameraBean = bean;
//                tv_toolbarTitle.setText(bean.name);
                break;
            }
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
        if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer() != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {
            if (!viewModel.isLiveOrNot) {
                long currentPos = mMediaPlayerWrapper.getPlayer().getCurrentPosition();
                long duration = mMediaPlayerWrapper.getPlayer().getDuration();

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
                    viewModel.isLiveOrNot(false);

                    //获得播放的clipbeanpos
                    mClipBeanPos = event.getClipBeanPos();
                    ClipBean clipBean = mClipBeanPos.getClipBean();
                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(lensMode);
                    retryOpen(clipBean.url, true);
                } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");
                    viewModel.isLiveOrNot(false);

                    ClipBean clipBean = event.getClipBeanPos().getClipBean();
                    boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);
                    switchProjection(lensMode);
                    fetchThumbnail(clipBean.thumbnail, false);
                    mMediaPlayerWrapper.pause();
                }
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
                Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_LIVE");
                viewModel.isLiveOrNot(true);

                Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                    if (mMediaPlayerWrapper != null) {
                        mMediaPlayerWrapper.destroy();
                        mMediaPlayerWrapper = null;
                    }
                    emitter.onNext(Optional.empty());
                })
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(aVoid -> mMediaPlayerWrapper = new MediaPlayerWrapper(true),
                                new ServerErrorHandler(TAG));
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
                viewModel.isLiveOrNot(false);

                //获得播放的clipbeanpos
                mEventBeanPos = event.getClipBeanPos();
                EventBean eventBean = mEventBeanPos.getEventBean();
                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(lensMode);
                retryOpen(eventBean.getMp4Url(), true);
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL) {
//                    Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_SHOW_THUMBNAIL");
                viewModel.isLiveOrNot(false);

                EventBean eventBean = event.getClipBeanPos().getEventBean();
                boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());
                switchProjection(lensMode);
//                fetchThumbnail(eventBean.thumbnail, false);
                mMediaPlayerWrapper.pause();
            }
        } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
            Logger.t(TAG).e("ClipBeanPosChangeEvent INTENT_LIVE");
            viewModel.isLiveOrNot(true);

            Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                if (mMediaPlayerWrapper != null) {
                    mMediaPlayerWrapper.destroy();
                    mMediaPlayerWrapper = null;
                }
                emitter.onNext(Optional.empty());
            })
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(aVoid -> mMediaPlayerWrapper = new MediaPlayerWrapper(true),
                            new ServerErrorHandler(TAG));
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
                tv_toolbarTitle.setText(R.string.cloud);
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
                tv_toolbarTitle.setText(R.string.cloud);
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

                    WindowManager manager = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
                    int width = 0;
                    if (manager != null) {
                        width = manager.getDefaultDisplay().getWidth();
                    }
//                    Logger.t(TAG).d("fetchThumbnail width: " + width);

                    Bitmap bitmap = Glide.with(LiveViewActivity.this)
                            .load(thumbnailUrl)
                            .asBitmap()
                            .diskCacheStrategy(DiskCacheStrategy.ALL)
                            .into(width, width * mYRadio / mXRadio)
                            .get();

                    if (blurOrNot) {
                        GaussianBlurUtil blur = new GaussianBlurUtil(LiveViewActivity.this);
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
            mBitmapLibrary.switchProjectionMode(LiveViewActivity.this, switchMode);
            mLiveLibrary.switchProjectionMode(LiveViewActivity.this, switchMode);
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
                        Logger.t(TAG).d("stop live on liveViewActivity");
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
                Toast.makeText(this, R.string.network_error_data_plan_expired, Toast.LENGTH_SHORT).show();
            } else if ("suspended".equals(status)) {
                Toast.makeText(this, R.string.network_error_data_plan_suspended, Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, R.string.network_error_data_plan_not_subscribed, Toast.LENGTH_SHORT).show();
            }
            cancelStartLive();
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
                        LiveViewActivity.this.queryLiveStatus(true);
                    } else {
                        LiveViewActivity.this.queryLiveStatus(false);
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
                        Toast.makeText(LiveViewActivity.this, R.string.play_error, Toast.LENGTH_SHORT).show();
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
                unsubscribeLiveStatus();
                tv_liveStatus.setVisibility(View.GONE);
                tv_liveStatus.setText("");
                viewModel.isLiveOrNot(true);

                if (mCameraBean != null) {
                    boolean lensMode = TextUtils.isEmpty(mCameraBean.rotate) || LENS_NORMAL.equals(mCameraBean.rotate);
                    switchProjection(lensMode);
                } else if (mFleetCamera != null) {
                    boolean lensMode = TextUtils.isEmpty(mFleetCamera.getRotate()) || LENS_NORMAL.equals(mFleetCamera.getRotate());
                    switchProjection(lensMode);
                }

                retryOpen(response.data.playUrl, false);
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
                startQueryLiveBPS();
                startUpdateLiveTime();
            }
            gl_live.setVisibility(View.VISIBLE);
            gl_thumbnail.setVisibility(View.GONE);
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
            Toast.makeText(LiveViewActivity.this, error, Toast.LENGTH_SHORT).show();
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
        if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer() != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {
            stopLive();
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

    public MDVRLibrary getBitmapLibrary() {
        return mBitmapLibrary;
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        initEvents();
        mLiveLibrary.onResume(this);
        mBitmapLibrary.onResume(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.resume();
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

    @Override
    protected void onPause() {
//        onAudioControl(ibAudioControl);
        super.onPause();
        isForeground = false;
        mLiveLibrary.onPause(this);
        mBitmapLibrary.onPause(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.pause();
        }
    }

    @Override
    protected void onDestroy() {
        IjkPlayerLogUtil.logIJKMEDIA();

        super.onDestroy();
        if (mLiveLibrary != null) {
            mLiveLibrary.onDestroy();
        }
        if (mBitmapLibrary != null) {
            mBitmapLibrary.onDestroy();
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
                                () -> PermissionUtil.startAppSetting(LiveViewActivity.this),
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
        mBitmapLibrary.onOrientationChanged(this);

        if (isFullScreen()) {
            toolbar.setVisibility(View.GONE);
            rl_control_portrait.setVisibility(View.GONE);
            ll_videoSrc.setVisibility(View.VISIBLE);
            rl_thumbnail_landscape.setVisibility(View.VISIBLE);

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
            rl_control_portrait.setVisibility(View.VISIBLE);
            ll_videoSrc.setVisibility(View.GONE);
            rl_thumbnail_landscape.setVisibility(View.GONE);

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
                    Toast.makeText(LiveViewActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .pinchConfig(new MDPinchConfig().setMin(1.0f).setMax(8.0f).setDefaultValue(0.1f))
                .pinchEnabled(false)
                .projectionMode(projectionMode)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) findViewById(R.id.gl_live));
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

        return MDVRLibrary.with(this)
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
                .build((GLSurfaceView) findViewById(R.id.gl_thumbnail));
    }

    private void hideControlPanel() {
        Logger.t(TAG).d("hide ControlPanel");
        ll_videoSrc.setVisibility(View.GONE);
        rl_thumbnail_landscape.setVisibility(View.GONE);
    }

    private void showControlPanel() {
        Logger.t(TAG).d("show ControlPanel");
        ll_videoSrc.setVisibility(View.VISIBLE);
        rl_thumbnail_landscape.setVisibility(View.VISIBLE);

        mHandler.removeMessages(ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(ControlPanelHandler.FADE_OUT), 5000);
    }

    public void setupToolbar() {
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> finish());
        }
    }

//    public List<BaseFragment> getPagerFragments() {
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

    private void unsubscribeLiveStatus() {
        tv_liveStatus.setVisibility(View.GONE);
        tv_liveStatus.setText("");

        if (pollLiveStatusSub != null && !pollLiveStatusSub.isDisposed()) {
            pollLiveStatusSub.dispose();
        }
    }

}