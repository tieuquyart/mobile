package com.mk.autosecure.ui.activity;

import static com.google.android.material.bottomnavigation.LabelVisibilityMode.LABEL_VISIBILITY_LABELED;
import static com.mkgroup.camera.CameraConstants.STATE_STORAGE_READY;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.PermissionChecker;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessaging;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.FirmwareUpgradeHelper;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.request.BindPushBody;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.DirectTestActivity;
import com.mk.autosecure.ui.activity.settings.NetworkTestActivity;
import com.mk.autosecure.ui.activity.settings.NotiManageActivity;
import com.mk.autosecure.ui.activity.settings.NotiTabManagerActivity;
import com.mk.autosecure.ui.activity.settings.SpaceInfoActivity;
import com.mk.autosecure.ui.adapter.MyFragmentPagerAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.fragment.AlbumFragment;
import com.mk.autosecure.ui.fragment.AlertsFragment;
import com.mk.autosecure.ui.fragment.DashBoardFragment;
import com.mk.autosecure.ui.fragment.OverviewFragment;
import com.mk.autosecure.ui.fragment.ProfileFragment;
import com.mk.autosecure.ui.fragment.TimelineFragment;
import com.mk.autosecure.ui.view.BottomNavigationViewEx;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.mk.autosecure.viewmodels.LocalLiveViewModel;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.event.AlertChangeEvent;
import com.mkgroup.camera.event.AppMismatchEvent;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.event.MessageChangeEvent;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.firmware.FirmwareDownloader;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.preference.SharedPreferenceKey;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableSource;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;
import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * Created by DoanVT on 2017/8/18.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
@RequiresActivityViewModel(LocalLiveViewModel.ViewModel.class)
public class LocalLiveActivity extends BaseActivity<LocalLiveViewModel.ViewModel> {

    private static final String TAG = LocalLiveActivity.class.getSimpleName();


    public static final String KEY_HAS_TRANS = "KEY_HAS_TRANS";
    public static final String KEY_NOTI_ID = "notificationId";
    public static String notificationID = "";

    public static final String CLEARTOP = "cleartop";

    public static final String TO_ALBUM = "to_album";

    public static final String TO_MESSAGE = "to_message";

    public static final int PERMISSIONS_REQUESTCODE = 11;
    //    private static final int REQUEST_CODE_WRITE_SETTINGS = 12;
    public static final int PERMISSION_LOCATION_REQUESTCODE = 13;
    public static final int SERVICE_GPS_INFO = 14;
    public static final int SERVICE_WIFI_INFO = 15;

    public static final int GUIDE_SELECT_CAMERA = 1006;
    public static final int GUIDE_CAMERA_SETUP = 1001;
    public static final int GUIDE_DIRECT_TEST = 1002;
    public static final int GUIDE_SDCARD_FORMAT = 1003;
    public static final int GUIDE_SUBSCRIBE = 1004;
    public static final int GUIDE_NETWORK_TEST = 1005;
    public static final int GUIDE_ES_NETWORK_TEST = 1007;

    private enum GUIDE_STEP {
        SETUP_SKIP, TAP_MENU_SKIP, TAP_PREVIEW_SKIP
    }

    private MyFragmentPagerAdapter mNaviAdapter;

    private AlertsFragment mAlertsFragment;

    private TimelineFragment mTimelineFragment;

    private OverviewFragment mOverviewFragment;

    public static void launchOrShow(Context context) {
//        launch(context, false);
        Intent intent = new Intent(context, LocalLiveActivity.class);
//        intent.putExtra(KEY_HAS_TRANS, haveTrans);
        context.startActivity(intent);
    }

    public static void launchForGuide(Context context) {
        Intent intent = new Intent(context, LocalLiveActivity.class);
        intent.putExtra(IntentKey.TOUR_GUIDE, !Constants.isFleet());
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity(intent);
    }

    private boolean mClearTop = false;

    private boolean showAlbum = false;

    private boolean showMessage = false;

    public static void launch(Context context, boolean clearTop) {
        Intent intent = new Intent(context, LocalLiveActivity.class);
        intent.putExtra(CLEARTOP, clearTop);
        if (clearTop) {
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        }
        context.startActivity(intent);
    }

    public static void launchForAlbum(Context context) {
        Intent intent = new Intent(context, LocalLiveActivity.class);
        intent.putExtra(CLEARTOP, true);
        intent.putExtra(TO_ALBUM, true);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity(intent);
    }

    @BindView(R.id.vp_navi)
    CustomViewPager vp_navi;

    @BindView(R.id.navi_view)
    BottomNavigationViewEx navi_view;

    @BindView(R.id.va_guide)
    ViewAnimator va_guide;

    @BindView(R.id.ll_waitFor)
    LinearLayout llWaitFor;

    public boolean tourGuide;

    private boolean isForeground = true;

    @OnClick({R.id.btn_skip_welcome, R.id.btn_skip_connect, R.id.btn_skip_direct,
            R.id.btn_skip_sdcard_insert, R.id.btn_skip_sdcard_format,
            R.id.btn_skip_simcard, R.id.btn_skip_subscribe, R.id.btn_skip_network})
    public void exitGuide() {
        popSkipGuide(GUIDE_STEP.SETUP_SKIP);
    }

    @OnClick(R.id.btn_getStarted)
    public void startedWelcome() {
        checkSetup();
    }

    private void checkSetup() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        if (camera != null) {
            boolean flag = (viewModel.getCurrentUser() != null
                    && viewModel.getCurrentUser().ownerDevice(camera.getSerialNumber()))
                    || Constants.isFleet();
            if (flag) {
                guideDirectTest();
            } else {
                guideSetupCamera();
            }
        } else {
            guideSetupCamera();
        }
    }

    @OnClick(R.id.btn_connect)
    public void connect() {
        SetupActivity.launch(this, true);
    }

    @OnClick(R.id.btn_direct)
    public void direct() {
        DirectTestActivity.launch(this, true);
    }

    private void checkSdcardStatus() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        if (camera != null) {
            int storageState = camera.getStorageState();
            Logger.t(TAG).d("checkSdcardStatus: " + storageState);

            if (storageState == STATE_STORAGE_READY) {
                checkSdcardFormat();
            } else {
                guideSDcardInsert();
            }
        } else {
            guideSetupCamera();
        }
    }

    @OnClick(R.id.btn_sdcard_insert)
    public void insertSD() {
        checkSdcardStatus();
    }

    private void checkSdcardFormat() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        if (camera != null) {
            boolean formatStorage = camera.isShouldFormatStorage();
            Logger.t(TAG).d("checkSdcardFormat: " + formatStorage);

            if (!formatStorage) {
                checkSimCard();
            } else {
                guideSDcardFormat();
            }
        } else {
            guideSetupCamera();
        }
    }

    @OnClick(R.id.btn_sdcard_format)
    public void formatSD() {
        SpaceInfoActivity.launch(this, true);
    }

    private void checkSimCard() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();

        if (camera != null) {
            Logger.t(TAG).d("mountVersion: " + camera.getMountVersion());

            if (camera.getMountVersion() != null && camera.getMountVersion().support_4g) {
                String lteStatus = camera.getLteStatus();
                Logger.t(TAG).d("lteStatus: " + lteStatus);

                JSONObject jsonObject;
                try {
                    jsonObject = new JSONObject(camera.getLteStatus());
                    String sim = jsonObject.getString("sim");

                    if ("READY".equals(sim)) {
                        checkSubscribe();
                    } else {
                        guideSimcard();
                    }
                } catch (JSONException e) {
                    Logger.t(TAG).e("checkSimCard error: " + e.getMessage());
                    guideSimcard();
                }
            } else {
                decideGuideShow();
            }
        } else {
            guideSetupCamera();
        }
    }

    @OnClick(R.id.btn_simcard)
    public void simCard() {
        checkSimCard();
    }

    private void checkSubscribe() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        if (camera != null) {
            if (Constants.isFleet()) {
                checkNetwork();
            } else {
                llWaitFor.setVisibility(View.VISIBLE);

                ApiService.createApiService().getCurrentSub(camera.getSerialNumber())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> llWaitFor.setVisibility(View.GONE))
                        .subscribe(response -> {
                            String status = response.getStatus();
                            Logger.t(TAG).d("getCurrentSub: " + status);

                            if ("in_service".equals(status) || "paid".equals(status)) {
                                checkNetwork();
                            } else {
                                guideDataPlan();
                            }
                        }, throwable -> {
                            NetworkErrorHelper.handleCommonError(this, throwable);
                            guideDataPlan();
                        });
            }
        } else {
            guideSetupCamera();
        }
    }

    @OnClick(R.id.btn_subscribe)
    public void subscribe() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        if (camera != null) {
            WebPlanActivity.launch(this, camera.getSerialNumber(), true);
        } else {
            guideSetupCamera();
        }
    }
    /**
     * Kiểm tra kết nối mạng
     * */
    private void checkNetwork() {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();

        if (camera != null) {
            String lteStatus = camera.getLteStatus();
            boolean checkSignal = checkSignal(lteStatus);
            boolean checkServer = checkServer(lteStatus);
            Logger.t(TAG).d("checkSignal: " + checkSignal);
            Logger.t(TAG).d("checkServer: " + checkServer);

            if (checkSignal && checkServer) {
                decideGuideShow();
            } else {
                guideNetworkTest();
            }
        } else {
            guideSetupCamera();
        }
    }
    /**
     * Kiểm tra tín hiệu LTE
     * @param lteStatus object trạng thái LTE
     * */
    private boolean checkSignal(String lteStatus) {
        try {
            JSONObject jsonObject = new JSONObject(lteStatus);
            String cereg = jsonObject.getString("cereg");

            if (TextUtils.isEmpty(cereg)) {
                return false;
            } else {
                int i = cereg.indexOf(",");

                if (i == -1) {
                    return false;
                } else {
                    cereg = cereg.substring(i + 1);
                    Logger.t(TAG).d("cereg: " + cereg);

                    if ("3".equals(cereg)) {
                        return false;
                    } else if ("5".equals(cereg)) {
                        return true;
                    }

                    if ("1".equals(cereg)) {
                        String ip = jsonObject.getString("ip");
                        Logger.t(TAG).d("ip: " + ip);
                        String[] split = ip.split(",");
                        if (split.length > 2 && !TextUtils.isEmpty(split[0])
                                && !TextUtils.isEmpty(split[1]) && !TextUtils.isEmpty(split[2])) {
                            return true;
                        } else {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
            }
        } catch (JSONException e) {
            Logger.t(TAG).d("checkSignal error: " + e.getMessage());
            return false;
        }
    }
    /**
     * kiểm tra kết nối tới server
     * @param lteStatus object trạng thái LTE
     * */
    private boolean checkServer(String lteStatus) {
        try {
            JSONObject jsonObject = new JSONObject(lteStatus);
            String connected = jsonObject.getString("connected");
            String ping8888 = jsonObject.getString("ping8888");
            Logger.t(TAG).d("connected: " + connected + "--ping8888: " + ping8888);
            if ("yes".equals(connected) && "yes".equals(ping8888)) {
                return true;
            } else if ("no".equals(connected) && "no".equals(ping8888)) {
                return false;
            } else {
                return false;
            }
        } catch (JSONException e) {
            Logger.t(TAG).d("checkServer error: " + e.getMessage());
            return false;
        }
    }

    @OnClick(R.id.btn_network)
    public void network() {
        NetworkTestActivity.launch(this, true);
    }

    private void decideGuideShow() {
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, false);

        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, true);
        Logger.t(TAG).d("decideGuideShow: " + aBoolean);
        if (aBoolean) {
            guidePreview();
        } else {
            guideSetupComplete();
        }
    }

    @OnClick(R.id.btn_complete)
    public void setupComplete() {
        tourGuide = false;
        va_guide.setVisibility(View.GONE);
        navi_view.setVisibility(View.VISIBLE);
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, false);
    }

    private void popSkipGuide(GUIDE_STEP step) {
        //show dialog alert exit
        View view = LayoutInflater.from(this).inflate(R.layout.pop_skip_guide, null);
        PopupWindow popupWindow = new PopupWindow(view, CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT, true);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.iv_close_pop).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.btn_continue_guide).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.tv_skip_guide).setOnClickListener(v -> {
            //重置新手引导状态
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, true);
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, true);
            popupWindow.dismiss();
            switch (step) {
                case SETUP_SKIP:
                case TAP_PREVIEW_SKIP:
                    tourGuide = false;
                    va_guide.setVisibility(View.GONE);
                    navi_view.setVisibility(View.VISIBLE);
                    break;
            }
            viewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.None);
        });

        popupWindow.showAsDropDown(navi_view);
    }

    @SuppressLint("CheckResult")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // set content view
        setContentView(R.layout.activity_camera);
        ButterKnife.bind(this);

        if (savedInstanceState != null) {
            tourGuide = savedInstanceState.getBoolean(IntentKey.TOUR_GUIDE, false);
            mClearTop = savedInstanceState.getBoolean(CLEARTOP, false);
            showAlbum = savedInstanceState.getBoolean(TO_ALBUM, false);
            showMessage = savedInstanceState.getBoolean(TO_MESSAGE, false);
        } else {
            tourGuide = getIntent().getBooleanExtra(IntentKey.TOUR_GUIDE, false);
            mClearTop = getIntent().getBooleanExtra(CLEARTOP, false);
            showAlbum = getIntent().getBooleanExtra(TO_ALBUM, false);
            showMessage = getIntent().getBooleanExtra(TO_MESSAGE, false);
        }

        initView();

        checkLocationPermission();

        checkContinueGuide();

        checkFleetVerify();

        checkNewFirmware();

        checkRestricted();

        getSmallestWidth();


        if (Constants.isFleet()) {
            //检查用户名下如果存在相机，判断此时是否打开了通知权限
            List<FleetCameraBean> fleetDevices = viewModel.getCurrentUser().getFleetDevices();
            if (fleetDevices != null && fleetDevices.size() > 0) {
                PermissionUtil.isNotificationEnable(this);
            }
        } else {
            //检查用户名下如果存在4g相机，判断此时是否打开了通知权限
            ArrayList<CameraBean> devices = viewModel.getCurrentUser().getDevices();
            for (CameraBean camerabean : devices) {
                if (camerabean != null && camerabean.is4G != null && camerabean.is4G) {
                    PermissionUtil.isNotificationEnable(this);
                    break;
                }
            }
        }

        initTourGuide(tourGuide);

        //每次刷新推送token
        viewModel.refreshToken();

        viewModel.outputs.unreadMsgNum()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::addBadgeAt, new ServerErrorHandler(TAG));

        viewModel.outputs.showCameraIndex()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::showCameraAt, new ServerErrorHandler(TAG));

        viewModel.outputs.showPreviewIndex()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::showPreviewAt, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(SettingChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSettingChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(AlertChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAlertChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(MessageChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMessageChangeEvent, new ServerErrorHandler(TAG));
    }

    /**
     * bind tokenPush(registrationId) với tài khoản fleet
     * */
    private void bindPushToken() {

        FirebaseMessaging.getInstance().getToken().addOnSuccessListener(token -> {
            Logger.t(TAG).d("bindPushDeviceFCM: " + token);
            if (!TextUtils.isEmpty(token) && !token.equals(PreferenceUtils.getString(SharedPreferenceKey.PUSH_DEVICE, ""))) {
                Logger.t(TAG).d("bindPushDevice: " + token);
                BindPushBody body = new BindPushBody("android", token);
                ApiClient.createApiService().bindPushDevice(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(boolResponse -> {
                            Logger.t(TAG).d("bindPushToken res: " + boolResponse);
                            PreferenceUtils.putString(token,SharedPreferenceKey.PUSH_DEVICE);
                        }, throwable ->
                                Toast.makeText(LocalLiveActivity.this, "Bind push token - " + token + " lỗi: " + throwable.getMessage(), Toast.LENGTH_SHORT).show());
            }
        });

//        String registrationID = JPushInterface.getRegistrationID(this);
    }
    /**
     * Xử lý khi có event connect tới camera
     * */
    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_CONNECTED");
                break;
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                CameraWrapper camera = event.getVdtCamera();
                CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                if (appPopup != null && appPopup.isShowing()
                        && camera != null && currentCamera != null
                        && camera.getPort() == currentCamera.getPort()) {
                    appPopup.dismiss();
                }
                break;
            default:
                break;
        }
    }

    private PopupWindow appPopup;

    private void onAppMismatchEvent(AppMismatchEvent event) {
        if (event == null) {
            return;
        }
        AppMismatchEvent.App eventApp = event.getApp();
        Logger.t(TAG).d("onAppMismatchEvent: " + eventApp);
        showAppMismatchPop(eventApp);
    }

    private void showAppMismatchPop(AppMismatchEvent.App eventApp) {
        if (appPopup != null && appPopup.isShowing()) {
            return;
        }

        String content = null;
        String action = null;
        String appPackageName = null;
        switch (eventApp) {
            case Secure360:
                content = getString(R.string.waylens_secure360_mismatch);
                action = getString(R.string.go_waylens_fleet);
                appPackageName = "com.waylens.fleet";
                break;
            case Fleet:
                content = getString(R.string.waylens_fleet_mismatch);
                action = getString(R.string.go_waylens_secure360);
                appPackageName = "com.mk.autosecure";
                break;
        }

        View view = LayoutInflater.from(LocalLiveActivity.this).inflate(R.layout.pop_app_mismatch, null);
        appPopup = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                false);
        appPopup.setOutsideTouchable(false);

        TextView textView = view.findViewById(R.id.tv_mismatch_tips);
        textView.setText(content);

        Button button = view.findViewById(R.id.btn_go_app);
        button.setText(action);

        String finalAppPackageName = appPackageName;
        button.setOnClickListener(v -> {
//            appPopup.dismiss();
            PackageManager packageManager = getPackageManager();
            Intent intent = packageManager.getLaunchIntentForPackage(finalAppPackageName);
            if (intent != null) {
                startActivity(intent);
            } else {
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + finalAppPackageName)));
                } catch (android.content.ActivityNotFoundException anfe) {
                    Logger.t(TAG).e("Intent to google play exception: " + anfe.getMessage());
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + finalAppPackageName)));
                }
            }
        });
        navi_view.post(() -> appPopup.showAsDropDown(navi_view));
    }

    /**
     * 检查用户是否重置密码
     */
    @SuppressLint("CheckResult")
    private void checkFleetVerify() {
        if (Constants.isFleet() && !Constants.isAdmin() /*&& !Constants.isDriver()*/) {
            Observable.timer(1000, TimeUnit.MILLISECONDS)
                    .flatMap((Function<Long, ObservableSource<Optional<PopupWindow>>>) aLong -> Observable
                            .create((ObservableEmitter<Optional<PopupWindow>> emitter) -> {
                                UserLogin userLogin = viewModel.getCurrentUser().getUserLogin();
                                if (userLogin == null) {
                                    emitter.onNext(Optional.empty());
                                    return;
                                }

                                View view = LayoutInflater.from(LocalLiveActivity.this).inflate(R.layout.pop_reset_password, null);
                                PopupWindow popupWindow = new PopupWindow(view,
                                        CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                        CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                        false);
                                popupWindow.setOutsideTouchable(false);

                                view.findViewById(R.id.btn_reset_password).setOnClickListener(v -> {
                                    popupWindow.dismiss();
                                    ForgetPwdActivity.launch(LocalLiveActivity.this, userLogin.getRealName());
                                    finish();
                                });
                                emitter.onNext(Optional.ofNullable(popupWindow));
                            }))
                    .delay(500, TimeUnit.MILLISECONDS)
                    .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(popupWindow -> popupWindow.get().showAsDropDown(navi_view));
        }
    }

    private void initView() {

        mNaviAdapter = new MyFragmentPagerAdapter(getSupportFragmentManager());

        if (Constants.isFleet()) {
            if (!Constants.isLogin()) {
                LoginActivity.launch(this);
            } else {
                bindPushToken();
                navi_view.inflateMenu(R.menu.menu_navigation_manager);
                navi_view.enableAnimation(false);
                navi_view.setLabelVisibilityMode(LABEL_VISIBILITY_LABELED);
                navi_view.setItemHorizontalTranslationEnabled(false);

                navi_view.setIconSize(24, 24);
                navi_view.setTextSize(10f);
                navi_view.setIconsMarginTop((int) getResources().getDimension(R.dimen.dp_10));
                navi_view.setItemIconTintList(getResources().getColorStateList(R.color.selector_btm_navi_fleet));
                navi_view.setItemTextColor(getResources().getColorStateList(R.color.selector_btm_navi_fleet));


                mOverviewFragment = new OverviewFragment();
                mNaviAdapter.addFragment(mOverviewFragment);

                mNaviAdapter.addFragment(new DashBoardFragment());

                mNaviAdapter.addFragment(new ProfileFragment());
            }

        } else {
            navi_view.inflateMenu(R.menu.menu_navigation);
            navi_view.enableAnimation(false);
            navi_view.setLabelVisibilityMode(LABEL_VISIBILITY_LABELED);
            navi_view.setItemHorizontalTranslationEnabled(false);

            navi_view.setIconSize(48, 32);
            navi_view.setTextSize(10f);
            navi_view.setIconsMarginTop((int) getResources().getDimension(R.dimen.dp_1));
        }


        if (Constants.isFleet()) {
//            if (!Constants.isLogin()) {
//                mNaviAdapter.addFragment(InstallationFragment.newInstance());
//
//                mTimelineFragment = new TimelineFragment();
//                mNaviAdapter.addFragment(mTimelineFragment);
//
//                mNaviAdapter.addFragment(MaintenanceFragment.newInstance());
//            } else {
//                mOverviewFragment = new OverviewFragment();
//                mNaviAdapter.addFragment(mOverviewFragment);
//
//                mNaviAdapter.addFragment(new DashBoardFragment());
//
//                mNaviAdapter.addFragment(new ProfileFragment());
//            }
        } else {
            mTimelineFragment = new TimelineFragment();
            mNaviAdapter.addFragment(mTimelineFragment);

            mAlertsFragment = new AlertsFragment();
            mNaviAdapter.addFragment(mAlertsFragment);

            mNaviAdapter.addFragment(new AlbumFragment());

            mNaviAdapter.addFragment(new ProfileFragment());
        }

        vp_navi.setAdapter(mNaviAdapter);
        vp_navi.setOffscreenPageLimit(3);
        navi_view.setupWithViewPager(vp_navi);
        navi_view.setOnNavigationItemSelectedListener(menuItem -> true);

        viewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.None);

        if (showAlbum) {
            if (Constants.isFleet()) {
                navi_view.setCurrentItem(2);
                AlbumActivity.launch(this);
            } else {
                navi_view.setCurrentItem(2);
            }
        }

        LocalBroadcastManager.getInstance(LocalLiveActivity.this).registerReceiver(receiver, new IntentFilter(Constants.KEY_PUSH_CHANNEL));

        if (Constants.has_push_notification) {
//            NotiManageActivity.notificationID = notificationID;
            NotiManageActivity.launch(this, notificationID);
//            Intent intent1 = new Intent(this, NotiTabManagerActivity.class);
//            startActivity(intent1);
        }
    }

    //notiPush

    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            startActivity(intent.setClass(LocalLiveActivity.this, LocalLiveActivity.class));
        }
    };

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (Constants.has_push_notification) {
//            NotiManageActivity.notificationID = notificationID;
//            notificationID = "";
            NotiManageActivity.launch(this, notificationID);
//            Intent intent1 = new Intent(this, NotiTabManagerActivity.class);
//            startActivity(intent1);
        }
    }

    private boolean haveTransaction(Intent intent) {
        boolean hasTrans = false;

        if (intent != null) hasTrans = intent.getBooleanExtra(KEY_HAS_TRANS, false);

        return hasTrans;
    }

    //end

    private Badge badge;

    private void addBadgeAt(int number) {
        Logger.t(TAG).d("addBadgeAt: " + number);
        if (number < 0 || (Constants.isFleet() /*&& Constants.isDriver()*/)) {
            return;
        }

        if (badge != null) {
            badge.hide(true);
            badge = null;
        }
        // add badge
        badge = new QBadgeView(this)
                .setBadgeNumber(number)
                .setGravityOffset(13, 2, true)
                .bindTarget(navi_view.getBottomNavigationItemView(Constants.isFleet() ? 0 : 1));
    }

    private void showCameraAt(int index) {
        navi_view.setCurrentItem(0);
    }

    private void showPreviewAt(int index) {
        navi_view.setCurrentItem(1);
    }

    private void checkRestricted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            ActivityManager manager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
            if (manager != null) {
                boolean restricted = manager.isBackgroundRestricted();
                Logger.t(TAG).d("checkRestricted: " + restricted);
            }
        }
    }

    private void getSmallestWidth() {
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        int heightPixels = dm.heightPixels;
        int widthPixels = dm.widthPixels;
        float density = dm.density;
        float heightDP = heightPixels / density;
        float widthDP = widthPixels / density;
        float smallestWidthDP = Math.min(widthDP, heightDP);
        Logger.t(TAG).e("smallestWidthDP: " + smallestWidthDP);
    }

    /**
     * 检查是否弹出新手引导框
     */
    @SuppressLint("CheckResult")
    private void checkContinueGuide() {
        Observable.create((ObservableEmitter<Optional<PopupWindow>> emitter) -> {
                    boolean setup = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, false);
                    Logger.t(TAG).d("setup: " + setup + " tourGuide: " + tourGuide + " mClearTop: " + mClearTop);
                    if (setup && !tourGuide && !mClearTop) {
                        View view = LayoutInflater.from(LocalLiveActivity.this).inflate(R.layout.pop_continue_guide, null);
                        PopupWindow popupWindow = new PopupWindow(view,
                                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                true);
                        popupWindow.setOutsideTouchable(false);

                        view.findViewById(R.id.iv_close_pop).setOnClickListener(v -> popupWindow.dismiss());
                        view.findViewById(R.id.btn_next_guide).setOnClickListener(v -> popupWindow.dismiss());
                        view.findViewById(R.id.btn_continue_guide).setOnClickListener(v -> {
                            popupWindow.dismiss();
                            LocalLiveActivity.launchForGuide(LocalLiveActivity.this);
                        });
                        view.findViewById(R.id.tv_never_guide).setOnClickListener(v -> {
                            popupWindow.dismiss();
                            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, false);
                        });

                        emitter.onNext(Optional.ofNullable(popupWindow));
                    }
                    emitter.onNext(Optional.empty());
                })
                .delay(500, TimeUnit.MILLISECONDS)
                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(popupWindow -> popupWindow.get().showAsDropDown(navi_view));
    }

    private void initTourGuide(boolean show) {
        Logger.t(TAG).d("initTourGuide: " + show);
        va_guide.setVisibility(show ? View.VISIBLE : View.GONE);
        navi_view.setVisibility(show ? View.GONE : View.VISIBLE);
        va_guide.setOnTouchListener((v, event) -> show);
    }

    public void showOrHideNavigation(int visibility) {
        navi_view.setVisibility(visibility);
    }

    private void onSettingChangeEvent(SettingChangeEvent event) {
        Logger.t(TAG).d("onSettingChangeEvent: " + event.getAction() + "--" + event.isUpdated());
        if (SettingChangeEvent.ACTION_FAILURE.equals(event.getAction())) {
            Toast.makeText(this, R.string.setting_request_fail, Toast.LENGTH_SHORT).show();
        }
    }

    private void onAlertChangeEvent(AlertChangeEvent event) {
        Logger.t(TAG).d("onAlertChangeEvent: " + event.getType() + "--" + event.getAction());
        CurrentUser currentUser = viewModel.getCurrentUser();
        Logger.t(TAG).d("currentUser: " + currentUser.exists());
        if (currentUser.exists()) {
            if (event.getType() == AlertChangeEvent.TYPE_RECEIVE_NOTIFICATION) {
                viewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.New);
                if (mAlertsFragment != null) {
                    mAlertsFragment.loadAlert(true);
                }
            }
        } else {
            addBadgeAt(0);
        }
    }

    private void onMessageChangeEvent(MessageChangeEvent event) {
        Logger.t(TAG).d("onMessageChangeEvent: " + event.getType() + "--" + event.getAction());
        CurrentUser currentUser = viewModel.getCurrentUser();
        Logger.t(TAG).d("currentUser: " + currentUser.exists());
        if (currentUser.exists()) {
            if (event.getType() == MessageChangeEvent.TYPE_RECEIVE_MESSAGE) {
                if (mAlertsFragment != null) {
                    mAlertsFragment.loadMessage(true);
                }
            }
        }
    }

    private void checkLocationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PermissionChecker.PERMISSION_GRANTED || PermissionChecker.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.POST_NOTIFICATIONS}, PERMISSION_LOCATION_REQUESTCODE);
            } else {
                WifiDirectConnection.getInstance().discoverPeers();
            }
        } else {
            WifiDirectConnection.getInstance().discoverPeers();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        viewModel.refreshCamera(false);

        RxBus.getDefault().toObservable(AppMismatchEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAppMismatchEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent, new ServerErrorHandler(TAG));

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));
    }

    private void onCurrentCamera(Optional<CameraWrapper> optional) {
        CameraWrapper cameraWrapper = optional.getIncludeNull();
        Logger.t(TAG).d("onCurrentCamera: " + cameraWrapper);
        if (cameraWrapper != null) {
            boolean mIsShowCamera = cameraWrapper.mIsShowCamera;
            Logger.t(TAG).d("mIsShowCamera: " + mIsShowCamera);
            if (!mIsShowCamera) {
                showAppMismatchPop(Constants.isFleet() ? AppMismatchEvent.App.Fleet : AppMismatchEvent.App.Secure360);
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBoolean(IntentKey.TOUR_GUIDE, tourGuide);
        outState.putBoolean(CLEARTOP, mClearTop);
        outState.putBoolean(TO_ALBUM, showAlbum);
        outState.putBoolean(TO_MESSAGE, showMessage);
    }

    @Override
    protected void onDestroy() {
        if (appPopup != null && appPopup.isShowing()) {
            appPopup.dismiss();
            appPopup = null;
        }

        LocalBroadcastManager.getInstance(this).unregisterReceiver(receiver);
        super.onDestroy();
    }

    @SuppressLint("CheckResult")
    private void checkNewFirmware() {
        CameraItem cameraItem = null;
        try {
            cameraItem = LocalCameraDaoManager.getInstance().getLatestConnectedCamera();
        } catch (Exception ex) {
            Logger.t(TAG).d("error = " + ex.getMessage());
        }
        Logger.t(TAG).d("checkNewFirmware: " + cameraItem);
        if (cameraItem != null && !Constants.isFleet()) {
            final CameraItem finalCameraItem = cameraItem;

            ApiService.createApiService().getFirmware()
                    .delay(500, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.io())
                    .compose(bindUntilEvent(ActivityEvent.PAUSE))
                    .map(firmwares -> Optional.ofNullable(FirmwareUpgradeHelper.getNewerFirmware(firmwares, finalCameraItem)))
                    .subscribe(firmwareOptional -> handleFirmware(finalCameraItem, firmwareOptional.getIncludeNull()), new ServerErrorHandler(TAG));
        }
    }

    /**
     * check updateFirmware
     * @param cameraItem info camera
     * @param firmware thông tin firmware
     * */
    private void handleFirmware(CameraItem cameraItem, Firmware firmware) {
        if (firmware == null) {
            return;
        }

        FirmwareUpgradeHelper.FirmwareVersion versionFromServer = new FirmwareUpgradeHelper.FirmwareVersion(firmware.version, firmware.BSPVersion);
        FirmwareUpgradeHelper.FirmwareVersion versionInCamera = new FirmwareUpgradeHelper.FirmwareVersion(cameraItem.getApiVersion(), cameraItem.getBspVersion());
        Logger.t(TAG).d("latest version: " + versionFromServer);
        Logger.t(TAG).d("version of camera: " + versionInCamera);
        Logger.t(TAG).d("check version isGreaterThan: " + versionFromServer.isGreaterThan(versionInCamera));

        if (versionFromServer.isGreaterThan(versionInCamera)) {
            FirmwareDownloader.DownloadInfo downloadInfo = VdtCameraManager.getManager().getFirmwareManager().checkFirmware(firmware.url, firmware.md5);
            if (downloadInfo != null && downloadInfo.getUrl().equals(firmware.url) && downloadInfo.getIsComplete()) {
                Logger.t(TAG).d("firmware is complete");
                return;
            }
            if (VdtCameraManager.getManager().getFirmwareManager().getHasShownUpgradeDialog()) {
                return;
            } else {
                VdtCameraManager.getManager().getFirmwareManager().setHasShownUpgradeDialog(true);
            }
            runOnUiThread(() -> {
                if (isForeground) {
                    DialogHelper.showDownloadFirmwareConfirmDialog(LocalLiveActivity.this,
                            cameraItem.getSerialNumber(), firmware);
                }
            });
        }
    }

    @Override
    protected void goBack() {
        super.goBack();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_LOCATION_REQUESTCODE) {
            if (grantResults.length > 0
                    && grantResults[0] == PermissionChecker.PERMISSION_GRANTED
                    && grantResults[1] == PermissionChecker.PERMISSION_GRANTED) {

                Logger.t(TAG).d("onRequestPermissionsResult true");
                WifiDirectConnection.getInstance().discoverPeers();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_COARSE_LOCATION)
                            || !shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
//                        DialogHelper.showPermissionDialog(this,
//                                () -> PermissionUtil.startAppSetting(LocalLiveActivity.this),
//                                () -> {
//                                });
                    } else {
                        Toast.makeText(this, getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == GUIDE_CAMERA_SETUP) {
            checkSetup();
        } else if (requestCode == GUIDE_DIRECT_TEST) {
            if (resultCode == RESULT_OK) {
                PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_DIRECT, false);
                checkSdcardStatus();
            }
        } else if (requestCode == GUIDE_SDCARD_FORMAT) {
            checkSdcardFormat();
        } else if (requestCode == GUIDE_SUBSCRIBE) {
            checkSubscribe();
        } else if (requestCode == GUIDE_NETWORK_TEST) {
            checkNetwork();
        }
    }

    private void guideSetupCamera() {
        va_guide.setDisplayedChild(1);
    }

    private void guideDirectTest() {
        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_DIRECT, true);
        if (aBoolean) {
            va_guide.setDisplayedChild(2);
        } else {
            checkSdcardStatus();
        }
    }

    private void guideSDcardInsert() {
        va_guide.setDisplayedChild(3);
    }

    private void guideSDcardFormat() {
        va_guide.setDisplayedChild(4);
    }

    private void guideSimcard() {
        va_guide.setDisplayedChild(5);
    }

    private void guideDataPlan() {
        va_guide.setDisplayedChild(6);
    }

    private void guideNetworkTest() {
        va_guide.setDisplayedChild(7);
    }

    private void guideSetupComplete() {
        va_guide.setDisplayedChild(8);
    }

    private void guidePreview() {
        va_guide.setVisibility(View.GONE);

        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();

        if (camera != null && mTimelineFragment != null) {
            mTimelineFragment.showGuideCamera(camera);
        }
    }

    private long mExitTime = 0;

    @Override
    public void back() {
        if(mOverviewFragment.ivBack.getVisibility() == View.VISIBLE){
            mOverviewFragment.back();
        }else if (System.currentTimeMillis() - mExitTime > 2000) {
            Toast.makeText(this, getString(R.string.double_click_exit), Toast.LENGTH_SHORT).show();
            mExitTime = System.currentTimeMillis();
        } else {
            super.back();
        }
    }
}
