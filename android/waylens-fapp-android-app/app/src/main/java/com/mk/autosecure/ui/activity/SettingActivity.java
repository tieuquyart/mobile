package com.mk.autosecure.ui.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.FeedbackActivity;
import com.mk.autosecure.ui.adapter.DeviceAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DataCleanManager;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.ui.activity.settings.AlertSettingsActivity;
import com.mk.autosecure.ui.activity.settings.VersionCheckActivity;
import com.mk.autosecure.viewmodels.SettingViewModel;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/8/23.
 * Email: doanvt-hn@mk.com.vn
 */

@RequiresActivityViewModel(SettingViewModel.ViewModel.class)
public class SettingActivity extends BaseActivity<SettingViewModel.ViewModel> {

    public static final String TAG = SettingActivity.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.va_setting)
    ViewAnimator vaSetting;

    //horn
    @BindView(R.id.rv_cameras)
    RecyclerView rv_cameras;

    @BindView(R.id.rl_add_camera)
    RelativeLayout rlAddCamera;

    @BindView(R.id.ll_firmware_test)
    LinearLayout llFirmwareTest;

    @BindView(R.id.tv_beta)
    TextView tvBeta;

    //fleet
    //null view

    @OnClick({R.id.rl_add_camera})
    public void onAddCameraClicked() {
        SetupActivity.launch(this, false);
    }

    @OnClick({R.id.ll_about, R.id.ll_about_fleet})
    public void onAboutClicked() {
        VersionCheckActivity.launch(this);
    }

    @OnClick({R.id.ll_clean_cache, R.id.ll_clean_cache_fleet})
    public void onCleanCacheClicked() {
        DialogHelper.showCleanCacheDialog(this, () -> {
            DataCleanManager.clearAllCache(SettingActivity.this);
            Toast.makeText(SettingActivity.this, R.string.cache_cleaned, Toast.LENGTH_SHORT).show();
        });
    }

    @OnClick(R.id.ll_firmware_test)
    public void joinBeta() {
        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
        if (aBoolean) {
            //当前是beta模式
            DialogHelper.showBetaTesterDialog(this,
                    R.string.support_leave_title,
                    R.string.support_leave_content,
                    R.string.support_beta_leave,
                    () -> {
                        tvBeta.setText(R.string.support_beta_tester_no);
                        PreferenceUtils.putBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
                    });
        } else {
            DialogHelper.showBetaTesterDialog(this,
                    R.string.support_join_title,
                    R.string.support_join_content,
                    R.string.support_beta_join,
                    () -> {
                        tvBeta.setText(R.string.support_beta_tester_yes);
                        PreferenceUtils.putBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, true);
                    });
        }
    }

    @OnClick(R.id.ll_alert_settings)
    public void onAlertSettings() {
        AlertSettingsActivity.launch(this);
    }

    @OnClick(R.id.ll_report_issue_fleet)
    public void onReport() {
        FeedbackActivity.launch(this);
    }

    @OnClick(R.id.ll_es_network_fleet)
    public void onEsNetwork() {
        ARouter.getInstance()
                .build("/ui/activity/settings/NetworkTestActivity")
                .withString("skipSelect", "SecureES")
                .navigation(this);
    }

    private DeviceAdapter mAdapter;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SettingActivity.class);
        activity.startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setting);
        ButterKnife.bind(this);
        setupToolbar();

        initView();
        initEvent();
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        if (Constants.isFleet()) {
            viewModel.getCurrentUser().fleetDevicesObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(listOptional -> {
                        List<FleetCameraBean> camerasBeans = listOptional.get();
                        if (mAdapter != null) {
                            mAdapter.setFleetCameraList(camerasBeans);
                            mAdapter.setLocalCameraList(filterFleetCameras(camerasBeans));
                        }
                    }, new ServerErrorHandler(TAG));

            viewModel.getCurrentUser().userLoginObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(userOptional -> {
                        UserLogin userLogin = userOptional.getIncludeNull();
                        if (userLogin != null) {
                            viewModel.inputs.refreshFleetCamera();
                        }
                    }, new ServerErrorHandler(TAG));
        } else {
            viewModel.getCurrentUser().devicesObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(listOptional -> {
                        ArrayList<CameraBean> cameraBeans = listOptional.get();
                        if (mAdapter != null) {
                            mAdapter.setCameraList(cameraBeans);
                            mAdapter.setLocalCameraList(filterCameras(cameraBeans));
                        }
                    }, new ServerErrorHandler(TAG));

            viewModel.getCurrentUser().observable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(userOptional -> {
                        User user = userOptional.getIncludeNull();
                        if (user != null) {
                            viewModel.inputs.refreshCamera();
                        }
                    }, new ServerErrorHandler(TAG));
        }

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleError, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(SettingChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSettingChangeEvent, new ServerErrorHandler(TAG));
    }

    private void initView() {
        if (Constants.isFleet()) {
            vaSetting.setDisplayedChild(1);
        } else {
            boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
            tvBeta.setText(aBoolean ? R.string.support_beta_tester_yes : R.string.support_beta_tester_no);

            mAdapter = new DeviceAdapter(this);
            rv_cameras.setAdapter(mAdapter);
            rv_cameras.setNestedScrollingEnabled(false);
            rv_cameras.setLayoutManager(new LinearLayoutManager(this));
            mAdapter.setListener(new DeviceAdapter.onDeviceClickListener() {
                @Override
                public void onConnectedClick(String serialNum) {
                    DevicesActivity.launch(SettingActivity.this, serialNum);
                }

                @Override
                public void onDeviceClicked(CameraBean cameraBean) {
                    DevicesActivity.launch(SettingActivity.this, cameraBean);
                }

                @Override
                public void onFleetDeviceClicked(FleetCameraBean fleetCamera) {
                    DevicesActivity.launch(SettingActivity.this, fleetCamera);
                }
            });
        }
    }

    private void handleError(Throwable throwable) {
        Logger.t(TAG).e("handleError: " + throwable.getMessage());
//        NetworkErrorHelper.handleCommonError(this, throwable);
    }

    private void onSettingChangeEvent(SettingChangeEvent event) {
        Logger.t(TAG).d("onSettingChangeEvent: " + event.getAction() + "--" + event.isUpdated());
        if (SettingChangeEvent.ACTION_FAILURE.equals(event.getAction())) {
            Toast.makeText(this, R.string.setting_request_fail, Toast.LENGTH_SHORT).show();
        }
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        Logger.t(TAG).e("onCameraConnectionEvent: " + event.getWhat());
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("devices: " + viewModel.getCurrentUser().getDevices());
                if (mAdapter != null) {
                    mAdapter.setLocalCameraList(filterCameras(viewModel.getCurrentUser().getDevices()));
                }
                break;
            default:
                break;
        }
    }

    private List<CameraWrapper> filterCameras(List<CameraBean> cameras) {
        List<CameraWrapper> vdtCameraList = VdtCameraManager.getManager().getConnectedCameras();
        List<CameraWrapper> tempCameraList = new ArrayList<>();
        tempCameraList.addAll(vdtCameraList);
        Logger.t(TAG).d("tempCameraList: " + tempCameraList.size());
        Logger.t(TAG).d("cameras: " + cameras.size());
        Iterator<CameraWrapper> each = tempCameraList.iterator();
        while (each.hasNext()) {
            CameraWrapper wrapper = each.next();
            Logger.t(TAG).d("sn: %s", wrapper.getSerialNumber());
            for (CameraBean cameraBean : cameras) {
                if (cameraBean.sn.equals(wrapper.getSerialNumber())) {
                    Logger.t(TAG).e("same camera");
                    tempCameraList.remove(wrapper);
//                    each.remove();
                    break;
                }
            }
        }
        return tempCameraList;
    }

    private List<CameraWrapper> filterFleetCameras(List<FleetCameraBean> cameras) {
        List<CameraWrapper> vdtCameraList = VdtCameraManager.getManager().getConnectedCameras();
        List<CameraWrapper> tempCameraList = new ArrayList<>();
        tempCameraList.addAll(vdtCameraList);
        Logger.t(TAG).d("tempCameraList: " + tempCameraList.size());
        Logger.t(TAG).d("cameras: " + cameras.size());
        Iterator<CameraWrapper> each = tempCameraList.iterator();
        while (each.hasNext()) {
            CameraWrapper vdtCamera = each.next();
            Logger.t(TAG).d("sn: %s", vdtCamera.getSerialNumber());
            for (FleetCameraBean cameraBean : cameras) {
                if (cameraBean.getSn().equals(vdtCamera.getSerialNumber())) {
                    Logger.t(TAG).e("same camera");
                    tempCameraList.remove(vdtCamera);
//                    each.remove();
                    break;
                }
            }
        }
        return tempCameraList;
    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }
}
