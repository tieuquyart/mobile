package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.adapter.HostManageAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.HostsChangeEvent;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LocalLiveActivity;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

import static com.mkgroup.camera.CameraConstants.WIFI_MODE_P2P;

public class WifiModeActivity extends RxAppCompatActivity {

    private final static String TAG = WifiModeActivity.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.rg_wifi_mode)
    RadioGroup rgWifiMode;

    @BindView(R.id.rb_ap_mode)
    RadioButton rbApMode;

    @BindView(R.id.rb_client_mode)
    RadioButton rbClientMode;

    @BindView(R.id.rb_p2p_mode)
    RadioButton rbP2pMode;

    @BindView(R.id.tv_empty_host)
    TextView tvEmptyHost;

    @BindView(R.id.rv_hosts)
    RecyclerView rvHosts;

    @OnClick(R.id.btn_add_host)
    public void addHost() {
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_add_host, null);

        EditText etSsid = view.findViewById(R.id.et_ssid);
        EditText etPassword = view.findViewById(R.id.et_password);

        new MaterialDialog
                .Builder(this)
                .customView(view, false)
                .positiveText("add")
                .negativeText("cancel")
                .negativeColorRes(R.color.colorNaviText)
                .onPositive((dialog, which) -> {
                    String ssid = etSsid.getText().toString().trim();
                    String password = etPassword.getText().toString().trim();

                    Logger.t(TAG).d("add host: " + ssid + " " + password);

                    if (mCamera != null) {
                        mCamera.addNetworkHost(ssid, password);
                        Toast.makeText(this, "add success", Toast.LENGTH_SHORT).show();
                    }
                })
                .show();
    }

    private VdtCamera mCamera;

    private List<Integer> checkList;

    private int mCurrentMode = -1;

    private HostManageAdapter mAdapter;

    private List<String> hostList = new ArrayList<>();

    private boolean showDialog = true;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, WifiModeActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wifi_mode);
        ButterKnife.bind(this);

        initView();
        initEvent();
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        RxBus.getDefault()
                .toObservable(HostsChangeEvent.class)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(this::onHostChangeEvent, new ServerErrorHandler(TAG));

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));
    }

    private void onCurrentCamera(Optional<CameraWrapper> cameraOptional) {
        CameraWrapper includeNull = cameraOptional.getIncludeNull();
        Logger.t(TAG).d("onCurrentCamera: " + includeNull);

        if (includeNull != null) {
            mCamera = (VdtCamera) includeNull;
        } else {
            Logger.t(TAG).d("onDisconnectCamera");
            Toast.makeText(this, getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show();
            LocalLiveActivity.launch(this, true);
        }
    }

    private void onHostChangeEvent(HostsChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            List<String> ssidList = event.getSsidList();
            Logger.t(TAG).d("onHostChangeEvent ssidList: " + ssidList.toString()
                    + " hostList: " + hostList.toString());
            if (!hostList.equals(ssidList)) {
                hostList.clear();
                hostList.addAll(ssidList);
                mAdapter.setHostList(ssidList);
            }
        }
    }

    private void initView() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
        tv_toolbarTitle.setText(R.string.wifi_mode);

        checkList = new ArrayList<>();

        checkList.add(rbApMode.getId());
        checkList.add(rbClientMode.getId());

        checkList.add(-1);
        checkList.add(-1);

        checkList.add(rbP2pMode.getId());

        mCamera = (VdtCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            mCurrentMode = mCamera.getWifiMode();
            Logger.t(TAG).d("wifiMode: " + mCurrentMode);
            checkRadioButton();

            int networkHostHum = mCamera.getNetworkHostHum();
            Logger.t(TAG).d("networkHostHum: " + networkHostHum);
            if (networkHostHum != 0) {
                tvEmptyHost.setVisibility(View.GONE);
            }

            mAdapter = new HostManageAdapter(this);
            rvHosts.setAdapter(mAdapter);
            rvHosts.setLayoutManager(new LinearLayoutManager(this));
            mAdapter.setListener(new HostManageAdapter.onHostClickListener() {
                @Override
                public void onRemoveHost(String ssid) {
                    Logger.t(TAG).d("onRemoveHost: " + ssid);
                    if (mCamera != null) {
                        mCamera.setNetworkRmvHost(ssid);
                        Toast.makeText(WifiModeActivity.this, "remove success", Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onConnectHost(String ssid) {
                    Logger.t(TAG).d("onConnectHost: " + ssid);
                    showAlertDialog(1, ssid);
                }
            });

            hostList.addAll(mCamera.getHostList());
            Logger.t(TAG).d("hostList: " + hostList.toString());
            mAdapter.setHostList(hostList);
        }

        rgWifiMode.setOnCheckedChangeListener((group, checkedId) -> {
            if (showDialog) {
                for (int id : checkList) {
                    if (id == checkedId) {
                        int indexOf = checkList.indexOf(id);
                        Logger.t(TAG).d("indexOf: " + indexOf + " mCurrentMode: " + mCurrentMode);
                        if (indexOf == WIFI_MODE_P2P) {
                            checkRadioButton();
                        } else if (mCurrentMode != indexOf) {
                            showAlertDialog(indexOf, null);
                        }
                        break;
                    }
                }
            } else {
                showDialog = true;
            }
        });
    }

    private void showAlertDialog(int indexOf, String ssid) {
        DialogHelper.showSwtichWifiDialog(this, () -> {
            if (mCamera != null) {
                Logger.t(TAG).d("showAlertDialog indexOf: " + indexOf + " ssid: " + ssid);
                if (TextUtils.isEmpty(ssid)) {
                    mCamera.setWifiMode(indexOf);
                } else {
                    mCamera.connectNetworkHost(ssid);
                }
                Logger.t(TAG).d("mCurrentMode: " + mCurrentMode);
                mCurrentMode = indexOf;

                //切断client连接, 跳转主页
                mCamera.releaseConnection();
                LocalLiveActivity.launch(this, true);
            }
        }, () -> {
            if (TextUtils.isEmpty(ssid)) {
                showDialog = false;
                checkRadioButton();
            }
        });
    }

    private void checkRadioButton() {
        try {
            rgWifiMode.check(checkList.get(mCurrentMode));
        } catch (IndexOutOfBoundsException e) {
            Logger.t(TAG).d("ex: " + e);
            rgWifiMode.check(checkList.get(0));
        }
    }
}
