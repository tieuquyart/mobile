package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.net.wifi.p2p.WifiP2pDevice;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.ui.adapter.WifiDirectAdapter;
import android.widget.Toast;

import com.mk.autosecure.ui.view.RadarScanView;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.event.DirectConnectionEvent;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2019/3/11.
 * Email：doanvt-hn@mk.com.vn
 */

@SuppressLint({"CheckResult","NonConstantResourceId"})
public class DirectSetupFragment extends RxFragment implements RadarScanView.IScanListener {

    public final static String TAG = DirectSetupFragment.class.getSimpleName();

    private static final int WIFI_SETTING = 0;

    @BindView(R.id.va_direct_setup)
    ViewAnimator va_direct_setup;

    @BindView(R.id.radarScanView)
    RadarScanView radarScanView;

    @BindView(R.id.rv_direct)
    RecyclerView rv_direct;

    @BindView(R.id.pairing_surface)
    SurfaceView pairing_surface;

    @BindView(R.id.ll_firmware)
    LinearLayout ll_firmware;

    @BindView(R.id.enable_surface)
    SurfaceView enable_surface;

    @BindView(R.id.cb_confirm)
    CheckBox cb_confirm;

    @BindView(R.id.btn_connect_direct)
    Button btn_connect_direct;

    @OnClick(R.id.tv_not_found)
    public void notFound() {
        Logger.t(TAG).d("cb_confirm: " + cb_confirm.isChecked());
        if (cb_confirm.isChecked()) {
            va_direct_setup.setDisplayedChild(4);
        } else {
            va_direct_setup.setDisplayedChild(3);
            initPlayer();
        }
    }

    @OnClick(R.id.btn_connect_direct)
    public void connectDirect() {
        va_direct_setup.setDisplayedChild(0);
        countDownScan();
        radarScanView.countDown();
    }

    @OnClick({R.id.tv_connect_normal_enable, R.id.tv_connect_normal_pairing, R.id.btn_connect_normal})
    public void connectNormal() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

    public SetupActivityViewModel.ViewModel parentViewModel;

    private Disposable countDownScanSubscribe;

    private Disposable countDownLinkSubscribe;

    private Disposable scanSubscribe;

    private Disposable pairSubscribe;

    private WifiDirectAdapter directAdapter;

    private List<WifiP2pDevice> wifiP2pDevices = new ArrayList<>();

    private WifiP2pDevice curWifiP2pDevice;

    private MediaPlayer mediaPlayer;

    private SurfaceHolder enableHolder;

    private SurfaceHolder pairHolder;

    private CameraWrapper mCamera;

    private String setupSN;

    public static DirectSetupFragment newInstance(SetupActivityViewModel.ViewModel viewModel, String sn) {
        DirectSetupFragment fragment = new DirectSetupFragment();
        fragment.parentViewModel = viewModel;
        fragment.setupSN = sn;
        Bundle bundle = new Bundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_direct_setup, container, false);
        ButterKnife.bind(this, view);

        initView();
        return view;
    }

    private void initView() {
        List<WifiP2pDevice> devicesList = WifiDirectConnection.getInstance().getWaylensList();
        Logger.t(TAG).d("devicesList: " + devicesList.size());
        if (devicesList.size() == 0) {
            va_direct_setup.setDisplayedChild(0);
        } else {
            va_direct_setup.setDisplayedChild(1);
            initWifiDevice();
        }

        cb_confirm.setOnCheckedChangeListener((buttonView, isChecked) -> btn_connect_direct.setEnabled(isChecked));

        SurfaceHolder enable_surfaceHolder = enable_surface.getHolder();
        enable_surfaceHolder.setKeepScreenOn(true);
        enable_surfaceHolder.addCallback(new EnableSurfaceCallback());

        SurfaceHolder pairing_surfaceHolder = pairing_surface.getHolder();
        pairing_surfaceHolder.setKeepScreenOn(true);
        pairing_surfaceHolder.addCallback(new PairSurfaceCallback());
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        Logger.t(TAG).d("isVisibleToUser: " + isVisibleToUser);
        if (isVisibleToUser) {
            mCamera = VdtCameraManager.getManager().getCurrentCamera();
            Logger.t(TAG).d("mCamera: " + mCamera);
            if (mCamera != null) {
                proceed();
            } else if (va_direct_setup != null) {
                int displayedChild = va_direct_setup.getDisplayedChild();
                if (displayedChild == 0) {
                    countDownScan();
                    radarScanView.countDown();
                }
            }
        } else {
            unSubscribeCountScan();
            unSubscribeScan();
            if (radarScanView != null) {
                radarScanView.unSubscribeCount();
            }
        }
    }

    private void countDownScan() {
        final int time = 10;
        countDownScanSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    List<WifiP2pDevice> devicesList = WifiDirectConnection.getInstance().getWaylensList();
                    Logger.t(TAG).d("onNext: " + aLong + "--" + devicesList.size());
                    if (devicesList.size() != 0) {
                        va_direct_setup.setDisplayedChild(1);
                        initWifiDevice();
                        unSubscribeCountScan();
                    } else {
                        WifiDirectConnection.getInstance().discoverPeers();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    unSubscribeCountScan();
                    toEnableDirect();
                });
    }

    private void toEnableDirect() {
        List<WifiP2pDevice> devicesList = WifiDirectConnection.getInstance().getWaylensList();
        Logger.t(TAG).d("devicesList: " + devicesList.size());
        boolean checked = cb_confirm.isChecked();
        Logger.t(TAG).d("cb_confirm: " + checked);

        if (devicesList.size() == 0) {
            if (checked) {
                va_direct_setup.setDisplayedChild(4);
            } else {
                va_direct_setup.setDisplayedChild(3);
                initPlayer();
            }
        } else {
            va_direct_setup.setDisplayedChild(1);
            initWifiDevice();
        }
    }

    private void initPlayer() {
        //实例化播放内核
        mediaPlayer = new MediaPlayer();

        //设置准备就绪状态监听
        mediaPlayer.setOnPreparedListener(mp -> mediaPlayer.start());

        mediaPlayer.setOnCompletionListener(mp -> mediaPlayer.start());
    }

    private void initWifiDevice() {
        directAdapter = new WifiDirectAdapter(getActivity());
        rv_direct.setAdapter(directAdapter);
        rv_direct.setLayoutManager(new LinearLayoutManager(getActivity()));
        directAdapter.setListener(wifiP2pDevice -> {
            curWifiP2pDevice = wifiP2pDevice;
            Toast.makeText(getActivity(), R.string.connecting, Toast.LENGTH_SHORT).show();
            WifiDirectConnection.getInstance().connectDevice(wifiP2pDevice);
        });

        filterWifiDeviceList();

        final int time = 10;
        scanSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    List<WifiP2pDevice> devicesList = WifiDirectConnection.getInstance().getWaylensList();
                    Logger.t(TAG).d("onNext: " + aLong + "--" + devicesList.size());
                    if (wifiP2pDevices == null || !wifiP2pDevices.containsAll(devicesList)) {
                        wifiP2pDevices = devicesList;
                        filterWifiDeviceList();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    unSubscribeScan();
                });

        RxBus.getDefault().toObservable(DirectConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onConnectionEvent, new ServerErrorHandler());
    }

    private void filterWifiDeviceList() {
        if (wifiP2pDevices != null && wifiP2pDevices.size() > 0) {
            if (!TextUtils.isEmpty(setupSN)) {
                for (WifiP2pDevice device : wifiP2pDevices) {
                    String deviceName = device.deviceName;
                    if (deviceName.substring(8).equals(setupSN.substring(3))) {
                        Logger.t(TAG).d("exist setupSN: " + setupSN);
                    } else {
                        wifiP2pDevices.remove(device);
                    }
                }
            }
            directAdapter.setWifiDeviceListList(wifiP2pDevices);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mediaPlayer != null) {
            mediaPlayer.pause();
        }

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNewCamera, new ServerErrorHandler());
    }

    private void onNewCamera(Optional<CameraWrapper> cameraOptional) {
        mCamera = cameraOptional.getIncludeNull();
        Logger.t(TAG).d("onNewCamera: " + mCamera);
        if (mCamera != null) {
            unSubscribeCountScan();
            unSubscribeScan();
            proceed();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mediaPlayer != null) {
            mediaPlayer.start();
        }
    }

    private void onConnectionEvent(DirectConnectionEvent event) {
        int what = event.getWhat();
        Logger.t(TAG).d("onConnectionEvent: " + event.getWhat());
        switch (what) {
            case DirectConnectionEvent.WIFI_DIRECT_CONNECTED:
                //过滤可能监听到的连接成功后被踢的情况
                new Handler().postDelayed(() -> {
                    mCamera = VdtCameraManager.getManager().getCurrentCamera();
                    Logger.t(TAG).d("mCamera: " + mCamera);
                    if (mCamera != null) {
                        unSubscribePair();
                        proceed();
                    }
                }, 2000);
                break;
            case DirectConnectionEvent.WIFI_DIRECT_DISCONNECTED:
                int displayedChild = va_direct_setup.getDisplayedChild();
                if (displayedChild != 2) {
                    va_direct_setup.setDisplayedChild(2);
                    initPlayer();
                    waitForPair();
                }
                break;
            case DirectConnectionEvent.WIFI_DIRECT_CONNECTING_FAILED:
                Toast.makeText(getContext(), R.string.fleet_default_error, Toast.LENGTH_LONG).show();
                break;
            default:
                break;
        }
    }

    private void proceed() {
        if (mCamera == null) {
            return;
        }

        if (!TextUtils.isEmpty(setupSN)) {
            String serialNumber = mCamera.getSerialNumber();
            if (!setupSN.equals(serialNumber)) {
                Toast.makeText(getContext(), getString(R.string.please_connect_bound_camera), Toast.LENGTH_LONG).show();

                int displayedChild = va_direct_setup.getDisplayedChild();
                if (displayedChild == 0) {
                    countDownScan();
                    radarScanView.countDown();
                }
                return;
            }
        }

        //判断是否需要dewarp
        boolean needDewarp = mCamera.getNeedDewarp();
        Logger.t(TAG).d("needDewarp: " + needDewarp);
        if (needDewarp) {
            //判断是否支持倒装
            boolean supportUpsidedown = mCamera.getSupportUpsidedown();
            Logger.t(TAG).d("proceed camera supportUpsidedown: " + supportUpsidedown);
            if (supportUpsidedown) {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.proceed(3);
                }
            } else {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.proceed(4);
                }
            }
        } else {
            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.proceed(4);
            }
        }
    }

    private void waitForPair() {
        final int time = 6;
        pairSubscribe = Observable.interval(0, 5, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
//                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    //有可能后台连接失败，直接跳转过来的。
                    if (curWifiP2pDevice != null) {
                        WifiDirectConnection.getInstance().connectDevice(curWifiP2pDevice);
                    }
                    Logger.t(TAG).d("onNext: " + aLong);
                    if (aLong == 3) {
                        showNormalWifi();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    unSubscribePair();
                });
    }

    private void showNormalWifi() {
        if (ll_firmware.getVisibility() == View.GONE) {
            ll_firmware.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onScaning() {

    }

    @Override
    public void onScanOver() {

    }

    private void unSubscribeCountScan() {
        if (countDownScanSubscribe != null && !countDownScanSubscribe.isDisposed()) {
            countDownScanSubscribe.dispose();
        }
    }

    private void unSubscribeScan() {
        if (scanSubscribe != null && !scanSubscribe.isDisposed()) {
            scanSubscribe.dispose();
        }
    }

    private void unSubscribePair() {
        curWifiP2pDevice = null;
        if (pairSubscribe != null && !pairSubscribe.isDisposed()) {
            pairSubscribe.dispose();
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        releasePlayer();
    }

    private void releasePlayer() {
        if (mediaPlayer != null) {
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).d("onActivityResult requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == WIFI_SETTING) {
            if (mCamera != null) {
                proceed();
            } else {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.loading(View.VISIBLE);
                }
                countDownLink();
            }
        }
    }

    private void countDownLink() {
        final int time = 10;
        countDownLinkSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time)
                .map(aLong -> time - aLong)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    Logger.t(TAG).d("countDown: " + aLong + " inConnected: " + (mCamera != null));
                    if (mCamera != null) {
                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.loading(View.GONE);
                        }
                        unSubscribeCountLink();
                        proceed();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    if (parentViewModel != null && parentViewModel.inputs != null) {
                        parentViewModel.inputs.loading(View.GONE);
                    }
                    unSubscribeCountLink();
                    Toast.makeText(getContext(), R.string.direct_connect_try_again, Toast.LENGTH_LONG).show();
                });
    }

    private void unSubscribeCountLink() {
        if (countDownLinkSubscribe != null && !countDownLinkSubscribe.isDisposed()) {
            countDownLinkSubscribe.dispose();
        }
    }

    class EnableSurfaceCallback implements SurfaceHolder.Callback {

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
//            Logger.t(TAG).d("surfaceCreated: " + holder);
            enableHolder = holder;

            int displayedChild = va_direct_setup.getDisplayedChild();
            if (displayedChild == 3) {
                //获得播放源访问入口
                AssetFileDescriptor afd = getResources().openRawResourceFd(R.raw.videos); // 注意这里的区别
                //给MediaPlayer设置播放源
                try {
                    mediaPlayer.reset();
                    mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
                    mediaPlayer.setDisplay(enableHolder);
                    //准备播放
                    mediaPlayer.prepareAsync();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            enableHolder = null;
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
        }
    }

    class PairSurfaceCallback implements SurfaceHolder.Callback {

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
//            Logger.t(TAG).d("surfaceCreated: " + holder);
            pairHolder = holder;

            int displayedChild = va_direct_setup.getDisplayedChild();
            if (displayedChild == 2) {
                //获得播放源访问入口
                AssetFileDescriptor afd = getResources().openRawResourceFd(R.raw.videos); // 注意这里的区别
                //给MediaPlayer设置播放源
                try {
                    mediaPlayer.reset();
                    mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
                    mediaPlayer.setDisplay(pairHolder);
                    //准备播放
                    mediaPlayer.prepareAsync();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            pairHolder = null;
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
        }
    }
}
