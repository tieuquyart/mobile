package com.mk.autosecure.ui.activity;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSIONS_REQUESTCODE;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME230_UPPER;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_DOME_UPPER_DOWN;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.net.Network;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.PermissionChecker;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.annotation.Route;
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
import com.google.android.material.tabs.TabLayout;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.adapter.StreamTypeAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.mk.autosecure.ui.view.SlideToUnlockView;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.db.VideoItem;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.download.ExportEvent;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.mkgroup.camera.model.PlaybackUrl;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.toolbox.DownloadUrlRequest;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.CookieUtil;
import com.mk.autosecure.libs.utils.MediaPlayerWrapper;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.network_adapter.exo_adapter.CustomHttpDataSourceFactory;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.UserProfile;
import com.mk.autosecure.rest.request.SignInPostBody;
import com.mk.autosecure.service.job.UploadDataEvent;
import com.mk.autosecure.service.job.UploadVideoJob;
import com.mk.autosecure.ui.activity.settings.WebViewActivity;
import com.mk.autosecure.uploadqueue.entities.LocalMoment;
import com.mk.autosecure.viewmodels.ExportActivityViewModel;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.internal.functions.Functions;
import io.reactivex.schedulers.Schedulers;
import tv.danmaku.ijk.media.player.IMediaPlayer;

/**
 * Created by DoanVT on 2018/1/22.
 * Email: doanvt-hn@mk.com.vn
 */

@Route(path = "/ui/activity/ExportActivity")
@RequiresActivityViewModel(ExportActivityViewModel.ViewModel.class)
public class ExportActivity extends BaseActivity<ExportActivityViewModel.ViewModel> implements MDVRLibrary.IDeltaXListener {

    public static final String TAG = ExportActivity.class.getSimpleName();

    public static final String CHOICE = "choice";
    public static final String STREAM = "stream";

    public static final String CLIP = "clip";
    public static final String OFFSET = "offset";

    public static final String URL = "url";
    public static final String CREATE_TIME = "create_time";
    public static final String DURATION = "duration";
    public static final String ROTATE = "rotate";
    public static final String TYPE = "type";
    public static final String LOCATION = "location";
    public static final String NEED_DEWARP = "need_dewarp";
    public static final String STREAM_TYPE = "stream_type";

    private int choice;

    private int mStreamIndex;

    private Clip clip;

    private String url;

    private long createTime;

    private int duration;

    private long offset;

    private String rotate;

    private int type;

    private String location;

    private boolean needDewarp = true;

    private String serialNumber;

    private MDVRLibrary mVRLibrary;

    private boolean isFromSDCard;

    private SimpleExoPlayer simpleExoPlayer;

    private MediaPlayerWrapper mMediaPlayerWrapper = new MediaPlayerWrapper(false);

    private boolean isForeground = true;

    private CameraWrapper mCamera;

    private Disposable pollExportEvent;

    private Disposable pollProgress;

    boolean exporting = false;

    private long timeStamp;

    private boolean hasInit = false;

    private UploadVideoJob uploadVideoJob;

    private int mXRadio;
    private int mYRadio;

    @BindView(R.id.va_export)
    ViewAnimator vaExport;

    @BindView(R.id.ll_exported_album)
    LinearLayout llExportedAlbum;

    @BindView(R.id.rv_stream_album)
    RecyclerView rvStreamAlbum;

    @BindView(R.id.ll_export_screen)
    LinearLayout llExportScreen;

    @BindView(R.id.rl_timestamp)
    RelativeLayout rlTimestamp;

    @BindView(R.id.ll_exported_library)
    LinearLayout llExportedLibrary;

    @BindView(R.id.rv_stream_library)
    RecyclerView rvStreamLibrary;

    @BindView(R.id.tabs)
    TabLayout tabLayout;

    @BindView(R.id.tv_export_progress)
    TextView tv_export_progress;

    @BindView(R.id.switch_timestamp)
    Switch switch_timestamp;

    @BindView(R.id.ll_warning)
    LinearLayout llWarning;

    @BindView(R.id.iv_export_icon)
    ImageView iv_export_icon;

    @BindView(R.id.tv_export)
    TextView tv_export;

    @BindView(R.id.rl_surface)
    RelativeLayout rl_surface;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

//    @BindView(R.id.ll_downloadInfo)
//    LinearLayout ll_downloadInfo;

    @BindView(R.id.gl_view)
    GLSurfaceView gl_view;

    @BindView(R.id.tv_timeStamp)
    TextView tv_timeStamp;

    @BindView(R.id.ll_touch_screen)
    LinearLayout ll_touch_screen;

    @BindView(R.id.top_shadow)
    View topShadow;

    @BindView(R.id.bottom_shadow)
    RelativeLayout bottom_shadow;

    @BindView(R.id.va_control)
    ViewAnimator vaControl;

    @BindView(R.id.cancel_slider)
    SlideToUnlockView cancelSlider;

    @BindView(R.id.btn_done)
    Button btnDone;

    @BindView(R.id.tv_go_album)
    TextView tvGoAlbum;

    @BindView(R.id.btn_retry_share)
    Button btnRetryShare;

    @BindView(R.id.tv_cancel_share)
    TextView tvCancelShare;

    @BindView(R.id.btn_save_album)
    Button btnSaveAlbum;

    @BindView(R.id.btn_export_library)
    Button btnExportLibrary;

    @BindView(R.id.btn_share_waylens)
    Button btnShareWaylens;

    @BindView(R.id.tv_downloadInfo)
    TextView tvDownloadInfo;

//    @BindView(R.id.pb_export)
//    BoundaryProgressBar pbExport;

    @OnClick(R.id.gl_view)
    public void click() {
        boolean needGuide = PreferenceUtils.getBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_TOUCH, true);
        if (needGuide && ll_touch_screen.getVisibility() == View.VISIBLE) {
            ll_touch_screen.setVisibility(View.GONE);
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_TOUCH, false);
        }
    }

    @OnClick(R.id.btn_save_album)
    public void saveAlbum() {
        enterDownload();
        Logger.t(TAG).d("exportMode: " + tabLayout.getSelectedTabPosition());
        viewModel.inputs.exportMode(tabLayout.getSelectedTabPosition() == 1);
        viewModel.inputs.exportStream(mStreamIndex);
        if (TextUtils.isEmpty(url)) {
            viewModel.inputs.download(clip, duration, offset);
        } else {
            viewModel.inputs.download(url, createTime, duration, rotate, type, location, needDewarp);
        }
    }

    @OnClick(R.id.btn_export_library)
    public void onExportClick() {
//        releasePlayer();
        enterDownload();
        Logger.t(TAG).d("exportMode: " + tabLayout.getSelectedTabPosition());
        viewModel.inputs.exportMode(tabLayout.getSelectedTabPosition() == 1);
        viewModel.inputs.exportStream(mStreamIndex);
        viewModel.setTranscode(true);
        if (TextUtils.isEmpty(url)) {
            viewModel.inputs.download(clip, duration, offset);
        } else {
            viewModel.inputs.download(url, createTime, duration, rotate, type, location, needDewarp);
        }
    }

    @OnCheckedChanged(R.id.cb_confirm)
    public void confirm(boolean isChecked) {
        btnShareWaylens.setEnabled(isChecked);
    }

    @OnClick(R.id.tv_agreement)
    public void onAgreementClick() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_AGREEMENT);
    }

    @OnClick(R.id.btn_share_waylens)
    public void share() {
        enterDownload();
        Logger.t(TAG).d("exportMode: " + tabLayout.getSelectedTabPosition());
        viewModel.inputs.exportMode(tabLayout.getSelectedTabPosition() == 1);
        viewModel.inputs.exportStream(mStreamIndex);
        if (TextUtils.isEmpty(url)) {
            viewModel.inputs.download(clip, duration, offset);
        } else {
            viewModel.inputs.download(url, createTime, duration, rotate, type, location, needDewarp);
        }
    }

    private void signInWaylens(VideoItem videoItem) {
        //固定账号
        SignInPostBody signInPostBody = new SignInPostBody(getString(R.string.waylens_account),
                getString(R.string.waylens_password), "", "");

        ApiService.createApiService().signinWaylens(signInPostBody)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(response -> {
                    if (response == null) {
                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                        return;
                    }

                    String userID = response.user.userID;
                    PreferenceUtils.putString(PreferenceUtils.WAYLENS_TOKEN, response.token);

                    UserProfile userProfile = HornApplication.getComponent().currentUser().getProfile();
                    Logger.t(TAG).e("userProfile: " + userProfile);

                    SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyy hh:mm:ss", Locale.US);
                    String date = format.format(System.currentTimeMillis()) + " GMT";

                    String title = String.format("ID:%s\nemail:%s\ntime:%s\nDev:Android/%s",
                            userID,
                            userProfile != null ? userProfile.email : "",
                            date,
                            Build.MANUFACTURER + Build.MODEL);

                    LocalMoment localMoment = new LocalMoment(userID, title, "private",
                            videoItem.getRawVideoPath(), videoItem.getDuration());
                    Logger.t(TAG).e("localMoment: " + localMoment.title);

                    uploadVideoJob = new UploadVideoJob(localMoment);
                    HornApplication.getComponent().backgroundThreadPool().execute(uploadVideoJob);
                }, throwable -> {
                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                });
    }

    public static void launch(Activity activity, int choice, int stream, Clip clip, String sn, int duration, long offset) {
        Intent i = new Intent(activity, ExportActivity.class);
        i.putExtra(CHOICE, choice);
        i.putExtra(STREAM, stream);
        i.putExtra(CLIP, clip);
        i.putExtra(IntentKey.SERIAL_NUMBER, sn);
        i.putExtra(DURATION, duration);
        i.putExtra(OFFSET, offset);
        activity.startActivityForResult(i, 1001);
    }

    public void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_export);
        ButterKnife.bind(this);
        setupToolbar();

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            choice = bundle.getInt(CHOICE);
            mStreamIndex = bundle.getInt(STREAM);

            //sdcard export
            clip = (Clip) bundle.getSerializable(CLIP);
            offset = bundle.getLong(OFFSET);
            serialNumber = bundle.getString(IntentKey.SERIAL_NUMBER);

            url = bundle.getString(URL);
            createTime = bundle.getLong(CREATE_TIME);
            duration = bundle.getInt(DURATION);

            rotate = bundle.getString(ROTATE);
            type = bundle.getInt(TYPE);
            location = bundle.getString(LOCATION);
            if (Constants.isFleet()) {
                needDewarp = bundle.getBoolean(IntentKey.FLEET_NEED_DEWARP, true);
            } else {
                needDewarp = bundle.getBoolean(NEED_DEWARP, true);
            }
            if (!TextUtils.isEmpty(serialNumber)) {
                needDewarp = serialNumber.startsWith("2");
            }
        }

        Logger.t(TAG).d("export url: " + url);
        Logger.t(TAG).d("mStreamIndex: " + mStreamIndex);
        Logger.t(TAG).d("needDewarp: " + needDewarp);

        adaptationFor4K(VideoStreamType.Panorama);

        isFromSDCard = TextUtils.isEmpty(url);
        if (isFromSDCard) {
            mCamera = TextUtils.isEmpty(serialNumber) ?
                    VdtCameraManager.getManager().getCurrentCamera() :
                    VdtCameraManager.getManager().getCamera(serialNumber);

            viewModel.inputs.currentCamera(mCamera);
        } else {
            // 1. Create a default TrackSelector
            BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
            TrackSelection.Factory videoTrackSelectionFactory =
                    new AdaptiveTrackSelection.Factory(bandwidthMeter);
            TrackSelector trackSelector =
                    new DefaultTrackSelector(videoTrackSelectionFactory);

            // 2. Create the player
            simpleExoPlayer = ExoPlayerFactory.newSimpleInstance(this, trackSelector);
        }

        mVRLibrary = createVRLibrary();

        RxBus.getDefault()
                .toObservable(UploadDataEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onUploadVideoEvent, new ServerErrorHandler(TAG));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE}, PERMISSIONS_REQUESTCODE);
            } else {
                initLayout();
            }
        } else {
            initLayout();
        }
    }

    private void adaptationFor4K(VideoStreamType streamType) {
        if (TextUtils.isEmpty(serialNumber)) {
            if (needDewarp) {
                mXRadio = 16;
                mYRadio = 9;
            } else {
                switch (streamType) {
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
            }
        } else {
            if (serialNumber.startsWith("6")) {
                mXRadio = 32;
                mYRadio = 27;
            } else {
                mXRadio = 16;
                mYRadio = 9;
            }
        }
        mMediaWindow.setRatio(mXRadio, mYRadio);
    }

    private void initLayout() {
        initSurfaceView();
        fetchDownloadInfo();
        Logger.t(TAG).d("initLayout: " + choice);
        switch (choice) {
            case 0:
                vaExport.setDisplayedChild(0);
                initSaveToAlbum();
                break;
            case 1:
                vaExport.setDisplayedChild(1);
                initExportToLibrary();
                break;
            case 2:
                vaExport.setDisplayedChild(2);
                break;
        }
    }

    private void initSaveToAlbum() {
        if (!needDewarp) {
            llExportedAlbum.setVisibility(View.VISIBLE);

            GridLayoutManager layoutManager = new GridLayoutManager(this, 3);
            layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    return position == 0 ? 3 : 1;
                }
            });
            rvStreamAlbum.setLayoutManager(layoutManager);

            List<String> stringList = new ArrayList<>();
            if (clip != null) {
                String[] descriptions = clip.descriptions;
                stringList.addAll(Arrays.asList(descriptions));
            } else {
                llExportedAlbum.setVisibility(View.INVISIBLE);
            }

            StreamTypeAdapter typeAdapter = new StreamTypeAdapter(this, stringList, mStreamIndex);
            typeAdapter.setStreamTypeListener(type -> {
                Logger.t(TAG).d("onStreamType: " + type);

                if (clip != null) {
                    String streamType = type.streamType;
                    Logger.t(TAG).d("streamType: " + streamType);
                    adaptationFor4K(type);
                    mStreamIndex = clip.getDescriptionIndex(type);
                    Logger.t(TAG).d("mStreamIndex: " + mStreamIndex);
                    fetchDownloadInfo();
                    initVideoPlayer(clip);
                }
            });
            rvStreamAlbum.setAdapter(typeAdapter);
        }
    }

    private void initExportToLibrary() {
        if (needDewarp) {
            tabLayout.removeAllTabs();
            tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.split_screen_tab));
            tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.full_screen_tab));
            tabLayout.addOnTabSelectedListener(tabSelectedListener);
            //默认 full screen
            TabLayout.Tab firstTab = tabLayout.getTabAt(1);
            if (firstTab != null) {
                firstTab.select();
                tabSelectedListener.onTabSelected(firstTab);
            }
        } else {
            llExportScreen.setVisibility(View.GONE);
            rlTimestamp.setVisibility(View.GONE);
            llExportedLibrary.setVisibility(View.VISIBLE);

            GridLayoutManager layoutManager = new GridLayoutManager(this, 3);
            layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    return position == 0 ? 3 : 1;
                }
            });
            rvStreamLibrary.setLayoutManager(layoutManager);

            List<String> stringList = new ArrayList<>();
            if (clip != null) {
                String[] descriptions = clip.descriptions;
                stringList.addAll(Arrays.asList(descriptions));
            } else {
                llExportedLibrary.setVisibility(View.INVISIBLE);
            }

            StreamTypeAdapter typeAdapter = new StreamTypeAdapter(this, stringList, mStreamIndex);
            typeAdapter.setStreamTypeListener(type -> {
                Logger.t(TAG).d("onStreamType: " + type);

                if (clip != null) {
                    String streamType = type.streamType;
                    Logger.t(TAG).d("streamType: " + streamType);
                    adaptationFor4K(type);
                    mStreamIndex = clip.getDescriptionIndex(type);
                    Logger.t(TAG).d("mStreamIndex: " + mStreamIndex);
                    fetchDownloadInfo();
                    initVideoPlayer(clip);
                }
            });
            rvStreamLibrary.setAdapter(typeAdapter);
        }

        switch_timestamp.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).d("onCheckedChanged: " + isChecked);
            viewModel.inputs.enableTime(isChecked);
            if (isChecked) {
                tv_timeStamp.setVisibility(View.VISIBLE);
            } else {
                tv_timeStamp.setVisibility(View.GONE);
            }
        });
    }

    private void initSurfaceView() {
        if (isFromSDCard) {
            timeStamp = clip.getStartTimeMsAbs() + offset;
            llWarning.setVisibility(View.GONE);
            iv_export_icon.setVisibility(View.INVISIBLE);
            tv_export.setVisibility(View.INVISIBLE);
            initVideoPlayer(clip);
//            Logger.t(TAG).e("getStartTimeMsAbs: " + clip.getStartTimeMsAbs());
//            Logger.t(TAG).e("getOffset: " + clip.getOffset());
//            Logger.t(TAG).e("offset: " + offset);
        } else {
            timeStamp = createTime;
            llWarning.setVisibility(url.contains("http") ? View.VISIBLE : View.GONE);
            iv_export_icon.setVisibility(url.contains("http") ? View.VISIBLE : View.INVISIBLE);
            tv_export.setVisibility(url.contains("http") ? View.VISIBLE : View.INVISIBLE);
            initVideoPlayer(url);
        }
        setTimeStamp(timeStamp);
    }

    private void setTimeStamp(long time) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss", Locale.getDefault());
        tv_timeStamp.setText(String.format(getResources().getString(R.string.export_timestamp), format.format(time)));
    }

    private void onUploadVideoEvent(UploadDataEvent uploadDataEvent) {
        Logger.t(TAG).d("onUploadVideoEvent: " + uploadDataEvent.getWhat());
        switch (uploadDataEvent.getWhat()) {
            case UPLOAD_WHAT_START:
            case UPLOAD_WHAT_PROGRESS:
                int progress = uploadDataEvent.getExtra();
                if (isFromSDCard || url.contains("http")) {
                    progress = (int) (50 + progress * 0.5f);
                }
//                pbExport.setProgress(progress);
                tv_export_progress.setText(getResources().getString(R.string.export_progress, progress + "%"));
                break;
            case UPLOAD_WHAT_FINISHED:
                PreferenceUtils.remove(PreferenceUtils.WAYLENS_TOKEN);
//                pbExport.setProgress(100);
                tv_export_progress.setText(R.string.export_success);
                vaControl.setDisplayedChild(1);
                break;
            case UPLOAD_WHAT_ERROR:
                PreferenceUtils.remove(PreferenceUtils.WAYLENS_TOKEN);
                tv_export_progress.setText(R.string.uploading_failed);
                vaControl.setDisplayedChild(2);
                Toast.makeText(ExportActivity.this, R.string.uploading_failed_tips, Toast.LENGTH_LONG).show();
                break;
            default:
                break;
        }
    }

    @SuppressLint("CheckResult")
    public void fetchDownloadInfo() {
        if (clip == null || mCamera == null) {
            if (!isFromSDCard && url.contains("http")) {
                Observable.create((ObservableOnSubscribe<Long>) subscriber -> {
                    try {
                        HttpURLConnection urlConnection;
                        Network cellularNetwork = ApiService.getCellularNetwork();
                        if (cellularNetwork != null && NetworkUtils.isNetworkLimited()) {
                            urlConnection = (HttpURLConnection) cellularNetwork.openConnection(new URL(url));
                        } else {
                            urlConnection = (HttpURLConnection) new URL(url).openConnection();
                        }
                        urlConnection.setConnectTimeout(15000);
                        urlConnection.setReadTimeout(15000);
                        Map<String, String> cookie = CookieUtil.getCookie();
                        if (!cookie.isEmpty()) {
                            for (Map.Entry<String, String> next : cookie.entrySet()) {
                                urlConnection.addRequestProperty(next.getKey(), next.getValue());
                            }
                        }
                        long length = urlConnection.getContentLength();
                        Logger.t(TAG).d("length: " + length);
                        subscriber.onNext(length);
                    } catch (IOException e) {
                        e.printStackTrace();
                        subscriber.onError(e);
                    }
                })
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(this::setDownloadInfo, new ServerErrorHandler(TAG));
            } else {
                File file = new File(url);
                long length = file.length();
                setDownloadInfo(length);
            }
            return;
        }
        Clip.ID cid = clip.cid;
//        Logger.t(TAG).d("%s", ToStringUtils.getString(cid));
//        int downloadStream = DownloadUrlRequest.DOWNLOAD_OPT_MAIN_STREAM;
        Observable.create((ObservableOnSubscribe<ClipDownloadInfo.StreamDownloadInfo>) subscriber -> {
            try {
                ClipDownloadInfo clipDownloadInfo;
                ClipDownloadInfo.StreamDownloadInfo downloadInfo;

                if (mStreamIndex == Clip.STREAM_MAIN) {
                    clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                            clip.getStartTimeMs() + offset, duration,
                            DownloadUrlRequest.DOWNLOAD_OPT_MAIN_STREAM, mStreamIndex);
                    downloadInfo = clipDownloadInfo.main;
                } else if (mStreamIndex == Clip.STREAM_SUB) {
                    clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                            clip.getStartTimeMs() + offset, duration,
                            DownloadUrlRequest.DOWNLOAD_OPT_SUB_STREAM_1, mStreamIndex);
                    downloadInfo = clipDownloadInfo.sub;
                } else {
                    clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                            clip.getStartTimeMs() + offset, duration,
                            DownloadUrlRequest.DOWNLOAD_OPT_SUB_STREAM_N, mStreamIndex);
                    downloadInfo = clipDownloadInfo.subN;
                }
                subscriber.onNext(downloadInfo);
            } catch (ExecutionException | InterruptedException e) {
                subscriber.onError(e);
            }
        })
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(streamDownloadInfo ->
                        setDownloadInfo(streamDownloadInfo.size), new ServerErrorHandler(TAG));
    }

    private void setDownloadInfo(long length) {
        final DecimalFormat decimalFormat = new DecimalFormat("0.00");

        if (length / 1024 / 1024 == 0) {
            tvDownloadInfo.setText(String.format(getString(R.string.download_info_kb_string),
                    DateUtils.formatElapsedTime(duration / 1000) + "  ",
                    decimalFormat.format((length / 1024))));
        } else {
            tvDownloadInfo.setText(String.format(getString(R.string.download_info_mb_string),
                    DateUtils.formatElapsedTime(duration / 1000) + "  ",
                    decimalFormat.format((length / 1024 / 1024))));
        }
    }

    private void onExportEvent(Optional<ExportEvent> eventOptional) {
        ExportEvent event = eventOptional.getIncludeNull();
        if (event == null || !event.getSymbol().equals(TAG)) {
            return;
        }
        Logger.t(TAG).d("onExportEvent: " + event.getType());
        switch (event.getType()) {
            case ExportEvent.EVENT_TYPE_INIT:
                ClipDownloadInfo.StreamDownloadInfo downloadInfo = event.getJob().getDownloadInfo();
                File videoDir = new File(FileUtils.getVideoExportPath());
                if (videoDir.getUsableSpace() < 2 * downloadInfo.size) {
                    Logger.t(TAG).e("getUsableSpace: " + videoDir.getUsableSpace() + "--" + 2 * downloadInfo.size);
                    Toast.makeText(this, R.string.not_enough_storage, Toast.LENGTH_LONG).show();
                    exitDownload(false);
                }
                break;
            case ExportEvent.EVENT_TYPE_PROCESS:
                int exportProgress = event.getJob().getExportProgress();
                if (choice == 0) {
                    exportProgress = 2 * exportProgress;
                }
//                pbExport.setProgress(exportProgress);
                tv_export_progress.setText(getResources().getString(R.string.export_progress, exportProgress + "%"));
                break;
            case ExportEvent.EVENT_TYPE_END:
                if (event.getJob().isFinished()) {
                    if (choice == 2) {
                        signInWaylens(event.getVideoItem());
                    } else {
//                        pbExport.setProgress(100);
                        tv_export_progress.setText(R.string.export_success);
                        vaControl.setDisplayedChild(1);
                    }
                    //删除按钮
//                    tvBackExport.setVisibility(View.INVISIBLE);
                }
                break;
        }
    }

    private void initVideoPlayer(String url) {
        Logger.t(TAG).d("initVideoPlayer: " + url);
        // init VR Library
        busy();

        simpleExoPlayer.addVideoListener(new VideoListener() {
            @Override
            public void onVideoSizeChanged(int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
                getVRVideoLibrary().onTextureResize(width, height);
            }

            @Override
            public void onRenderedFirstFrame() {
//                Logger.t(TAG).d("onRenderedFirstFrame");
//                cancelBusy();
//
//                if (!isForeground) {
//                    simpleExoPlayer.setPlayWhenReady(false);
//                }
//                if (getVRVideoLibrary() != null) {
//                    getVRVideoLibrary().notifyPlayerChanged();
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
                    case Player.STATE_BUFFERING:
                        busy();
                        break;
                    case Player.STATE_READY:
                        cancelBusy();
                        break;
                    case Player.STATE_ENDED:
                        cancelBusy();
                        unsubscribeProgress();
                        setTimeStamp(timeStamp + simpleExoPlayer.getDuration());
                        break;
                    default:
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
                unsubscribeProgress();
                String errorString = String.format(Locale.getDefault(), "Play error: " + error.getMessage());
                Toast.makeText(ExportActivity.this, errorString, Toast.LENGTH_SHORT).show();
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
            simpleExoPlayer.prepare(getMediaSource(url));
            simpleExoPlayer.setPlayWhenReady(true);
            intervalCheck();
        }
    }

    private MediaSource getMediaSource(String url) {
        DataSource.Factory dataSourceFactory = null;
        if (url.contains("http")) {
            // Measures bandwidth during playback. Can be null if not required.
            DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
            // Produces DataSource instances through which media data is loaded.
            dataSourceFactory = new CustomHttpDataSourceFactory("Android", bandwidthMeter);
        } else {
            dataSourceFactory = new DefaultDataSourceFactory(this, "Android");
        }

        return new ExtractorMediaSource.Factory(dataSourceFactory).createMediaSource(Uri.parse(url));
    }

    private void checkProgress(Long aLong) {
        long currentPosition;
        if (isFromSDCard) {
            if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {
                currentPosition = mMediaPlayerWrapper.getPlayer().getCurrentPosition();
                setTimeStamp(currentPosition + timeStamp);
            }
        } else {
            if (simpleExoPlayer != null && simpleExoPlayer.getPlayWhenReady()) {
                currentPosition = simpleExoPlayer.getCurrentPosition();
                setTimeStamp(currentPosition + timeStamp);
            }
        }
    }

    private void intervalCheck() {
        pollProgress = Observable.interval(500, TimeUnit.MILLISECONDS)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(this::checkProgress, throwable -> {
                    intervalCheck();
                    Logger.t(TAG).e("intervalCheck throwable: " + throwable.getMessage());
                });
    }

    private void initVideoPlayer(Clip clip) {
        // init VR Library
        busy();

        mMediaPlayerWrapper.destroy();
        mMediaPlayerWrapper = new MediaPlayerWrapper(false);

        mMediaPlayerWrapper.init();

        mMediaPlayerWrapper.setPreparedListener(iMediaPlayer -> {
            Logger.t(TAG).d("onPrepared");
            cancelBusy();
            intervalCheck();

            if (!isForeground) {
                iMediaPlayer.stop();
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

        mMediaPlayerWrapper.getPlayer().setOnErrorListener((mp, what, extra) -> {
            String error = String.format(Locale.getDefault(), "Play error what=%d extra=%d", what, extra);
            Logger.t(TAG).e("onError: " + error);
            unsubscribeProgress();
            Toast.makeText(ExportActivity.this, R.string.play_error, Toast.LENGTH_SHORT).show();
            return true;
        });

        mMediaPlayerWrapper.getPlayer().setOnVideoSizeChangedListener((mp, width, height, sar_num, sar_den) ->
                getVRVideoLibrary().onTextureResize(width, height));

        mMediaPlayerWrapper.getPlayer().setOnCompletionListener(iMediaPlayer -> {
            unsubscribeProgress();
            setTimeStamp(iMediaPlayer.getDuration() + timeStamp);
        });

        Logger.t(TAG).d("video url = " + url);
        if (clip != null) {
            Observable.create((ObservableOnSubscribe<Void>) emitter -> {
                try {
                    PlaybackUrl playbackUrl = SnipeApi.getClipPlaybackUrlWithStream(clip.cid,
                            clip.getStartTimeMs(), offset, duration, mStreamIndex);
                    Logger.t(TAG).d("playback url = " + playbackUrl.url);
                    if (playbackUrl.url != null) {
                        mMediaPlayerWrapper.openRemoteFile(playbackUrl.url);
                        mMediaPlayerWrapper.prepare();
                    }
                } catch (Exception e) {
                    Logger.t(TAG).e(e.getMessage());
                }
            }).subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(Functions.emptyConsumer());
        } else if (url != null && !TextUtils.isEmpty(url)) {
            mMediaPlayerWrapper.openRemoteFileWithCookie(url);
            mMediaPlayerWrapper.prepare();
        }
    }

    private void releasePlayer() {
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }
        if (simpleExoPlayer != null) {
            simpleExoPlayer.release();
            simpleExoPlayer = null;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        mVRLibrary.onResume(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.resume();
        }
        if (simpleExoPlayer != null) {
            simpleExoPlayer.setPlayWhenReady(true);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        mVRLibrary.onPause(this);
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.pause();
        }
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
        tabLayout.removeOnTabSelectedListener(tabSelectedListener);
    }


    public void cancelBusy() {
        findViewById(R.id.progress).setVisibility(View.GONE);
    }

    public void busy() {
        findViewById(R.id.progress).setVisibility(View.VISIBLE);
    }

    public void enterDownload() {
        exporting = true;
        btnSaveAlbum.setVisibility(View.INVISIBLE);
        btnExportLibrary.setVisibility(View.INVISIBLE);
        btnShareWaylens.setVisibility(View.INVISIBLE);
        pollExportEvent = viewModel.exportJobEvent()
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onExportEvent, new ServerErrorHandler());

        vaControl.setDisplayedChild(0);
//        tvBackExport.setVisibility(View.INVISIBLE);

        cancelSlider.resetView();
//        pbExport.setProgress(0);
        topShadow.setVisibility(View.VISIBLE);
        bottom_shadow.setVisibility(View.VISIBLE);
        rl_surface.setBackgroundResource(R.color.colorExportShadow);
//        ll_downloadInfo.setBackgroundResource(R.color.colorExportShadow);
        tv_export_progress.setText(getResources().getString(R.string.export_progress, "0%"));
        cancelSlider.setmCallBack(new SlideToUnlockView.CallBack() {
            @Override
            public void onSlide(int distance) {
            }

            @Override
            public void onUnlocked() {
                DownloadManager.getManager().cancelCurrentJob(false);
                if (uploadVideoJob != null) {
                    uploadVideoJob.cancel();
                }
                exitDownload(false);
            }
        });
        btnDone.setOnClickListener(v -> {
            releasePlayer();
            setResult(RESULT_OK);
            finish();
            //exitDownload(true);
        });
        if ((isFromSDCard || url.contains("http")) && (Constants.isFleet() && Constants.isManager())) {
            tvGoAlbum.setVisibility(View.VISIBLE);
        } else {
            tvGoAlbum.setVisibility(View.GONE);
        }
        tvGoAlbum.setOnClickListener(v -> {
            releasePlayer();
            LocalLiveActivity.launchForAlbum(ExportActivity.this);
        });
        btnRetryShare.setOnClickListener(v -> {
            switch (choice) {
                case 0:
                    saveAlbum();
                    break;
                case 1:
                    onExportClick();
                    break;
                case 2:
                    share();
                    break;
            }
        });
        tvCancelShare.setOnClickListener(v -> exitDownload(false));
        pausePlayer();
    }

    public void exitDownload(boolean success) {
        exporting = false;
        if (!success) {
            btnSaveAlbum.setVisibility(View.VISIBLE);
            btnExportLibrary.setVisibility(View.VISIBLE);
            btnShareWaylens.setVisibility(View.VISIBLE);
        }
        Logger.t(TAG).d("%s", "exitDownload");
        if (pollExportEvent != null && !pollExportEvent.isDisposed()) {
            pollExportEvent.dispose();
        }

        topShadow.setVisibility(View.GONE);
        bottom_shadow.setVisibility(View.GONE);
        rl_surface.setBackgroundResource(R.color.colorGrayBackground);
//        ll_downloadInfo.setBackgroundResource(R.color.colorGrayBackground);
        vaControl.setDisplayedChild(0);
//        tvBackExport.setVisibility(View.INVISIBLE);
        cancelSlider.resetView();
//        pbExport.setProgress(0);
        resumePlayer();
    }

    private void pausePlayer() {
        if (isFromSDCard && mMediaPlayerWrapper != null) {
            cancelBusy();
            mMediaPlayerWrapper.destroy();
            unsubscribeProgress();
        } else if (!isFromSDCard && simpleExoPlayer != null) {
            cancelBusy();
            simpleExoPlayer.setPlayWhenReady(false);
        }
    }

    private void resumePlayer() {
        if (isFromSDCard && mMediaPlayerWrapper != null) {
            initVideoPlayer(clip);
        } else if (!isFromSDCard && simpleExoPlayer != null) {
            simpleExoPlayer.setPlayWhenReady(true);
        }
    }

    public MDVRLibrary getVRVideoLibrary() {
        return mVRLibrary;
    }

    protected MDVRLibrary createVRLibrary() {
        int proMode;
        if (clip != null) {
            boolean needDewarp = clip.getNeedDewarp();
            if (needDewarp) {
                boolean lensNormal = clip.isLensNormal();
                Logger.t(TAG).d("lensNormal: " + lensNormal);
                proMode = lensNormal ? CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
            } else {
                proMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
            }
        } else {
            if (needDewarp) {
                boolean lensMode = TextUtils.isEmpty(rotate) || LENS_NORMAL.equals(rotate);
                Logger.t(TAG).d("lensMode: " + lensMode);
                proMode = lensMode ?
                        CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
            } else {
                proMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
            }
        }

        return MDVRLibrary.with(this)
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asVideo(surface -> {
                    hasInit = true;

                    int projectionMode = mVRLibrary.getProjectionMode();
//                    Logger.t(TAG).d("projectionMode: " + projectionMode);

                    if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS) {
                        runOnUiThread(() -> mVRLibrary.switchProjectionMode(ExportActivity.this, PROJECTION_MODE_DOME230_UPPER));
                    }
                    if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                        runOnUiThread(() -> mVRLibrary.switchProjectionMode(ExportActivity.this, PROJECTION_MODE_DOME_UPPER_DOWN));
                    }

                    if (isFromSDCard) {
                        mMediaPlayerWrapper.setSurface(surface);
                    } else {
                        simpleExoPlayer.setVideoSurface(surface);
                    }
                })
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + String.valueOf(mode);
                    Toast.makeText(ExportActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .filterYEnabled(true)
                .deltaXListener(this)
                .projectionMode(proMode)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build((GLSurfaceView) findViewById(R.id.gl_view));
    }

    @Override
    public void goBack() {
        if (!exporting) {
            super.goBack();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSIONS_REQUESTCODE) {
            if (PermissionChecker.checkSelfPermission(this,Manifest.permission.WRITE_EXTERNAL_STORAGE)  == PermissionChecker.PERMISSION_GRANTED &&
                    PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED) {

                initLayout();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE) ||
                            !shouldShowRequestPermissionRationale(Manifest.permission.READ_EXTERNAL_STORAGE);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(this,
                                () -> PermissionUtil.startAppSetting(ExportActivity.this),
                                this::finish);
                    } else {
                        finish();
                    }
                }
                Toast.makeText(this, getResources().getString(R.string.storage_must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED) {
                initLayout();
            } else {
                finish();
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    private TabLayout.OnTabSelectedListener tabSelectedListener = new TabLayout.OnTabSelectedListener() {
        @Override
        public void onTabSelected(TabLayout.Tab tab) {
            View view = tab.getCustomView();
            if (view != null) {
                RelativeLayout rlBackground = view.findViewById(R.id.rl_background);
                rlBackground.setBackground(getDrawable(R.drawable.bg_selected_screen));
                TextView tvContent = view.findViewById(R.id.tv_content);
                tvContent.setTextColor(getResources().getColor(R.color.colorAccent));

                playStyle(tab.getPosition());
            }
        }

        @Override
        public void onTabUnselected(TabLayout.Tab tab) {
            View view = tab.getCustomView();
            if (view != null) {
                RelativeLayout rlBackground = view.findViewById(R.id.rl_background);
                rlBackground.setBackground(getDrawable(R.drawable.bg_unselect_screen));
                TextView tvContent = view.findViewById(R.id.tv_content);
                tvContent.setTextColor(getResources().getColor(R.color.colorPrimary));
            }
        }

        @Override
        public void onTabReselected(TabLayout.Tab tab) {

        }
    };

    private void playStyle(int style) {
        Logger.t(TAG).d("playStyle: " + style);
        if (style == 0) {
            int projectionMode = mVRLibrary.getProjectionMode();
            Logger.t(TAG).d("projectionMode: " + projectionMode);

            if (projectionMode == PROJECTION_MODE_DOME230_UPPER) {
                mVRLibrary.switchProjectionMode(this, CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS);
            } else if (projectionMode == PROJECTION_MODE_DOME_UPPER_DOWN) {
                mVRLibrary.switchProjectionMode(this, CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN);
            }

            if (ll_touch_screen.getVisibility() == View.VISIBLE) {
                ll_touch_screen.setVisibility(View.GONE);
            }
        } else if (style == 1) {
            if (hasInit) {
                int projectionMode = mVRLibrary.getProjectionMode();
                Logger.t(TAG).d("projectionMode: " + projectionMode);

                if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS) {
                    mVRLibrary.switchProjectionMode(this, PROJECTION_MODE_DOME230_UPPER);
                } else if (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN) {
                    mVRLibrary.switchProjectionMode(this, PROJECTION_MODE_DOME_UPPER_DOWN);
                }
            }

            boolean needGuide = PreferenceUtils.getBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_TOUCH, true);
            if (needGuide && ll_touch_screen.getVisibility() == View.GONE) {
                ll_touch_screen.setVisibility(View.VISIBLE);
            }
        }
    }

    private void unsubscribeProgress() {
        if (pollProgress != null && !pollProgress.isDisposed()) {
            pollProgress.dispose();
        }
    }

    @Override
    public void onDeltaX(float deltaX) {
//        Logger.t(TAG).d("onDeltaX: " + deltaX);
        viewModel.inputs.exportAngle((int) deltaX);
    }

    public interface StreamTypeChangeListener {
        void onStreamType(VideoStreamType type);
    }
}