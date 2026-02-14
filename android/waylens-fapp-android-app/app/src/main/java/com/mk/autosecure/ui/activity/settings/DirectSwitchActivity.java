package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSION_LOCATION_REQUESTCODE;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.SERVICE_GPS_INFO;

import android.Manifest;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Intent;
import android.net.wifi.p2p.WifiP2pDevice;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.PermissionChecker;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.adapter.DirectTrustedAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.direct.PairedDevices;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.event.P2PEnableChangeEvent;
import com.mkgroup.camera.event.PairedListEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LocalLiveActivity;

import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

public class DirectSwitchActivity extends RxActivity {

    private final static String TAG = DirectSwitchActivity.class.getSimpleName();

    private static final int WIFI_SETTING = 0;

    enum DISCONNECT {
        WIFI_DIRECT, NORMAL_WIFI
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, DirectSwitchActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.va_direct)
    ViewAnimator va_direct;

    @BindView(R.id.rl_loading)
    RelativeLayout rl_loading;

    @BindView(R.id.direct_switch)
    Switch direct_switch;

    @BindView(R.id.tv_manage_trust)
    TextView tv_manage_trust;

    @BindView(R.id.rv_trusted)
    RecyclerView rv_trusted;

    @BindView(R.id.tv_trust_tips)
    TextView tv_trust_tips;

    @BindView(R.id.iv_disconnect)
    ImageView iv_disconnect;

    @BindView(R.id.tv_not_connect)
    TextView tv_not_connect;

    @BindView(R.id.tv_password)
    TextView tv_password;

    @OnClick(R.id.btn_done)
    public void done() {
        LocalLiveActivity.launch(this, true);
    }

    @OnClick(R.id.btn_copy)
    public void btnCopy() {
        //复制到剪贴板
        ClipboardManager clipboardManager = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        String trim = tv_password.getText().toString().trim();
        int index = trim.indexOf(":");
        //跳过空格
        Logger.t(TAG).d("clipBoard: " + trim.substring(index + 2));
        ClipData clipData = ClipData.newPlainText("password", trim.substring(index + 2));
        if (clipboardManager != null) {
            clipboardManager.setPrimaryClip(clipData);
            Toast.makeText(this, R.string.copy_clipboard, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.btn_wifi_setting)
    public void wifiSetting() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

//    private VdtCamera mVdtCamera;

    private CameraWrapper mCurrentCamera;

    private DirectTrustedAdapter trustedAdapter;

    private List<PairedDevices.DevicesBean> devicesBeans;

    private Disposable countDownSubscribe;

    private boolean isChangeForUser = true;

    private boolean p2pEnable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_direct_switch);
        ButterKnife.bind(this);
        setToolbar();

//        mVdtCamera = (VdtCamera) VdtCameraManager.getManager().getCurrentCamera();
        mCurrentCamera = VdtCameraManager.getManager().getCurrentCamera();
        initView();
        initEvent();
    }

    private void initEvent() {
        Disposable subscribe = RxBus.getDefault().toObservable(P2PEnableChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onP2pEnableEvent, new ServerErrorHandler(TAG));

        Disposable subscribe1 = RxBus.getDefault().toObservable(PairedListEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onPairedListEvent, new ServerErrorHandler(TAG));
    }

    private void onPairedListEvent(PairedListEvent event) {
        if (event != null && event.getCamera().equals(mCurrentCamera)) {
            devicesBeans = event.getDevices().getDevices();
            Logger.t(TAG).d("devicesBeans: " + devicesBeans);
            trustedAdapter.setWifiDeviceListList(devicesBeans);
        }
    }

    private void onP2pEnableEvent(P2PEnableChangeEvent event) {
        if (event != null && event.getCamera().equals(mCurrentCamera)) {
            boolean eventEnable = event.isEnable();
            boolean isChecked = direct_switch.isChecked();
            Logger.t(TAG).e("eventEnable: " + eventEnable + "--" + isChecked);
            if (eventEnable != isChecked) {
                isChangeForUser = false;
                hideOrShow(eventEnable);
            }
        }
    }

    private void hideOrShow(boolean isShowTrust) {
        direct_switch.setChecked(isShowTrust);
        tv_manage_trust.setVisibility(isShowTrust ? View.VISIBLE : View.GONE);
        rv_trusted.setVisibility(isShowTrust ? View.VISIBLE : View.GONE);
        tv_trust_tips.setVisibility(isShowTrust ? View.VISIBLE : View.GONE);
    }

    private void initView() {
        tv_toolbarTitle.setText(R.string.wifi_direct);

        if (mCurrentCamera != null) {
            p2pEnable = mCurrentCamera.getP2pEnable();
            Logger.t(TAG).d("p2pEnable: " + p2pEnable);
            hideOrShow(p2pEnable);
        }

        direct_switch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).d("isChangeForUser: " + isChangeForUser);
            p2pEnable = isChecked;
            if (isChangeForUser) {
                if (p2pEnable) {
                    checkLocationPermission();
                } else {
                    initPopWindow(false);
                }
            } else {
                isChangeForUser = true;
            }
        });

        trustedAdapter = new DirectTrustedAdapter(this);
        rv_trusted.setAdapter(trustedAdapter);
        rv_trusted.setLayoutManager(new LinearLayoutManager(this));
        trustedAdapter.setListener(this::onRemoveTrusted);

        if (mCurrentCamera != null) {
            devicesBeans = mCurrentCamera.getPairedDevices().getDevices();
            trustedAdapter.setWifiDeviceListList(devicesBeans);
        }
    }

    private void checkLocationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_LOCATION_REQUESTCODE);
            } else {
                checkGpsService();
            }
        } else {
            initPopWindow(p2pEnable);
        }
    }

    private void checkGpsService() {
        boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(this);
        if (gpsServiceEnable) {
            initPopWindow(p2pEnable);
        } else {
            Intent gpsOptionsIntent = new Intent(
                    android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
            startActivityForResult(gpsOptionsIntent, SERVICE_GPS_INFO);
        }
    }

    private void initPopWindow(boolean isChecked) {
        View view = LayoutInflater.from(this).inflate(R.layout.pop_switch_direct, null);
        PopupWindow popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                true);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.btn_not_now).setOnClickListener((View v) -> {
            popupWindow.dismiss();
            isChangeForUser = false;
            direct_switch.setChecked(!isChecked);
        });
        view.findViewById(R.id.btn_switch).setOnClickListener(v -> {
            popupWindow.dismiss();

            if (isChecked) {
                WifiDirectConnection.getInstance().setTempConnectSN(mCurrentCamera.getSerialNumber());
                mCurrentCamera.setP2pEnable(true);
                startSearchDirect();
            } else {
                mCurrentCamera.setP2pEnable(false);
                va_direct.setDisplayedChild(2);
                initGuideWifi(DISCONNECT.NORMAL_WIFI);
            }
        });

        tv_toolbarTitle.post(() -> popupWindow.showAsDropDown(tv_toolbarTitle));
    }

    private void initGuideWifi(DISCONNECT style) {
        switch (style) {
            case WIFI_DIRECT:
                iv_disconnect.setImageResource(R.drawable.icon_direct_off);
                tv_not_connect.setText(R.string.direct_not_connect);
                break;
            case NORMAL_WIFI:
                tv_not_connect.setText(R.string.wifi_not_connect);
                iv_disconnect.setImageResource(R.drawable.icon_direct_off);
                break;
        }
        tv_password.setText(String.format(Locale.US, getString(R.string.password_), mCurrentCamera.getPassword()));
    }

    private void startSearchDirect() {
        rl_loading.setVisibility(View.VISIBLE);

        new Handler().postDelayed(() -> WifiDirectConnection.getInstance().discoverPeers(), 3000);

        countDown();
    }

    private void countDown() {
        final int time = 30;
        countDownSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    WifiP2pDevice wifiP2pDevice = WifiDirectConnection.getInstance().getConnectedDevice();
                    Logger.t(TAG).d("onNext: " + aLong + "--" + wifiP2pDevice);
                    if (wifiP2pDevice != null) {
                        rl_loading.setVisibility(View.GONE);
                        va_direct.setDisplayedChild(1);
                        unSubscribeCount();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    unSubscribeCount();
                    toConnectNormal();
                });
    }

    private void toConnectNormal() {
        rl_loading.setVisibility(View.GONE);
        va_direct.setDisplayedChild(2);
        initGuideWifi(DISCONNECT.WIFI_DIRECT);
    }

    private void unSubscribeCount() {
        WifiDirectConnection.getInstance().setTempConnectSN("");
        if (countDownSubscribe != null && !countDownSubscribe.isDisposed()) {
            countDownSubscribe.dispose();
        }
    }

    private void setToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    private void onRemoveTrusted(PairedDevices.DevicesBean bean) {
        devicesBeans.remove(bean);
        trustedAdapter.setWifiDeviceListList(devicesBeans);
        mCurrentCamera.removePaired(bean.getMac());
        Toast.makeText(this, R.string.video_action_delete, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == WIFI_SETTING) {
            LocalLiveActivity.launch(this, true);
        } else if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PermissionChecker.PERMISSION_GRANTED) {
                checkGpsService();
            } else {
                isChangeForUser = false;
                direct_switch.setChecked(!p2pEnable);
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == SERVICE_GPS_INFO) {
            boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(this);
            if (gpsServiceEnable) {
                initPopWindow(p2pEnable);
            } else {
                isChangeForUser = false;
                direct_switch.setChecked(!p2pEnable);
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSION_LOCATION_REQUESTCODE) {
            if (grantResults.length > 0
                    && grantResults[0] == PermissionChecker.PERMISSION_GRANTED
                    && grantResults[1] == PermissionChecker.PERMISSION_GRANTED) {

                Logger.t(TAG).d("onRequestPermissionsResult true");
                checkGpsService();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_COARSE_LOCATION)
                            || !shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(this,
                                () -> PermissionUtil.startAppSetting(DirectSwitchActivity.this),
                                () -> {
                                    isChangeForUser = false;
                                    direct_switch.setChecked(!p2pEnable);
                                    Toast.makeText(this, getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show();
                                });
                    } else {
                        isChangeForUser = false;
                        direct_switch.setChecked(!p2pEnable);
                        Toast.makeText(this, getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }
}
