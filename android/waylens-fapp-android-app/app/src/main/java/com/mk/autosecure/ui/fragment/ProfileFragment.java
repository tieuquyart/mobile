package com.mk.autosecure.ui.fragment;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSION_LOCATION_REQUESTCODE;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.SERVICE_GPS_INFO;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.SERVICE_WIFI_INFO;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_INOUT;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SETTING_CFG;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SET_DRIVER_INFO;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_TCVN01;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_TCVN02;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_TCVN03;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_TCVN04;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_TCVN05;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Service;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Handler;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupMenu;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.ContextCompat;
import androidx.core.content.PermissionChecker;
import androidx.viewpager.widget.ViewPager;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.google.android.material.tabs.TabLayout;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.CircleTransform;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DataCleanManager;
import com.mk.autosecure.libs.utils.DialogUtils;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.AlbumActivity;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.ProfileActivity;
import com.mk.autosecure.ui.activity.SettingActivity;
import com.mk.autosecure.ui.activity.SetupActivity;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.mk.autosecure.ui.activity.settings.AdasCfgActivity;
import com.mk.autosecure.ui.activity.settings.AssetActivity;
import com.mk.autosecure.ui.activity.settings.CalibActivity;
import com.mk.autosecure.ui.activity.settings.CheckSimDataActivity;
import com.mk.autosecure.ui.activity.settings.DataUsageActivity;
import com.mk.autosecure.ui.activity.settings.DirectTestActivity;
import com.mk.autosecure.ui.activity.settings.FeedbackActivity;
import com.mk.autosecure.ui.activity.settings.GeoFenceActivity;
import com.mk.autosecure.ui.activity.settings.LoginWithFaceActivity;
import com.mk.autosecure.ui.activity.settings.NetworkTestActivity;
import com.mk.autosecure.ui.activity.settings.PersonnelActivity;
import com.mk.autosecure.ui.activity.settings.ReportLogActivity;
import com.mk.autosecure.ui.activity.settings.SetupFleetActivity;
import com.mk.autosecure.ui.activity.settings.SupportActivity;
import com.mk.autosecure.ui.activity.settings.TCVNActivity;
import com.mk.autosecure.ui.activity.settings.VersionCheckActivity;
import com.mk.autosecure.ui.adapter.MyFragmentPagerAdapter;
import com.mk.autosecure.viewmodels.fragment.ProfileFragmentViewModel;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.event.TCVNEvent;
import com.mkgroup.camera.message.bean.CustomMK;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.orhanobut.logger.Logger;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */

@SuppressLint({"CheckResult", "NonConstantResourceId", "NewApi", "UseCompatLoadingForDrawables"})
@RequiresFragmentViewModel(ProfileFragmentViewModel.ViewModel.class)
public class ProfileFragment extends BaseLazyLoadFragment<ProfileFragmentViewModel.ViewModel> {

    private final static String TAG = ProfileFragment.class.getSimpleName();

    private CameraWrapper mCamera;

    private EvCamera evCamera;

    private AppCompatDialog progressDialog;

    private List<ImageView> imageViews = new ArrayList<>();


    private List<TextView> textViews = new ArrayList<>();

    private List<TextView> textViewCounts = new ArrayList<>();

    private List<VehicleInfoBean> vehicleList = new ArrayList<>();
    private List<DriverInfoBean> driverList = new ArrayList<>();
    private List<FleetCameraBean> deviceList = new ArrayList<>();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.va_profile)
    ViewAnimator vaProfile;

    @BindView(R.id.iv_avatar)
    ImageView iv_avatar;

    @BindView(R.id.iv_avatar_fleet)
    ImageView ivAvatarFleet;

    @BindView(R.id.tv_nickname)
    TextView tv_nickname;

    @BindView(R.id.tv_nickname_fleet)
    TextView tvNicknameFleet;

    @BindView(R.id.tv_nickname_driver)
    TextView tvNicknameDriver;

    @BindView(R.id.tv_data_usage)
    TextView tvDataUsage;

    @BindView(R.id.ll_tcvn)
    LinearLayout llTCVN;

    @BindView(R.id.ll_cfg_mk)
    LinearLayout llCfgMK;

    @BindView(R.id.ll_login_withFace)
    LinearLayout llLoginWithFace;

    @BindView(R.id.ll_connect_wifi)
    LinearLayout llConnectWifi;

    @BindView(R.id.tvConnectWifiCamera)
    TextView tvConnectWifiCamera;

    @BindView(R.id.ll_calib_camera)
    LinearLayout llCalibCamera;

    @BindView(R.id.ll_continue_tour)
    LinearLayout llContinueTour;

//    @BindView(R.id.ll_continue_tour_fleet)
//    LinearLayout llContinueTourFleet;

    @BindView(R.id.ll_continue_tour_manager)
    LinearLayout llContinueTourManager;

    @BindView(R.id.ll_wifi_trouble)
    LinearLayout llWifiTrouble;

    @BindView(R.id.ll_wifi_trouble_fleet)
    LinearLayout llWifiTroubleFleet;

    @BindView(R.id.ll_wifi_trouble_manager)
    LinearLayout llWifiTroubleManager;

    @BindArray(R.array.web_url_list)
    String[] webServer;

    @BindView(R.id.tab_layout)
    TabLayout tabLayout;

    @BindView(R.id.pageContent)
    ViewPager pageContent;


    @OnClick({R.id.ll_profile, R.id.ll_profile_fleet, R.id.ll_profile_driver})
    public void profile() {
        if (HornApplication.getComponent().currentUser().exists()) {
            ProfileActivity.launch(getActivity());
        } else {
            LoginActivity.launch(getActivity());
        }
    }

    @OnClick({R.id.ll_settings, R.id.ll_settings_fleet})
    public void setting() {
        SettingActivity.launch(getActivity());
    }

    @OnClick({R.id.ll_add_camera})
    void addCamera() {
        SetupActivity.launch(getActivity(), false);
    }

    @OnClick({R.id.ll_support})
    public void support() {
        SupportActivity.launch(getActivity());
    }

    @SuppressLint("CheckResult")
    @OnClick({R.id.ll_shop, R.id.ll_shop_fleet})
    public void shop() {
//        String BASE_URL = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServer[webServer.length - 1]);
//        Uri uri = Uri.parse(BASE_URL + "/shop/360?from=android");
//        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
//        startActivity(intent);
        Logger.e("click onShop");
    }

    private void showLoadingDialog() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(getActivity());
        }
        progressDialog.show();
    }

    private void hideLoadingDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            try {
                progressDialog.hide();
                progressDialog.dismiss();
                progressDialog = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }
    }

    @Override
    public void onDestroy() {
        if (progressDialog != null && progressDialog.isShowing()) {
            try {
                progressDialog.hide();
                progressDialog.dismiss();
                progressDialog = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }
        super.onDestroy();
    }

    @OnClick({R.id.ll_adas_settings})
    public void adas_settings() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);

        if (currentCamera == null) {
            Toast.makeText(getActivity(), R.string.setting_request, Toast.LENGTH_LONG).show();
            return;
        }

        Logger.t(TAG).i("goAdasSettings isAdasCfgAvailable = " + currentCamera.isAdasCfgAvailable());

        if (!currentCamera.isAdasCfgAvailable()) {
            Toast.makeText(getActivity(), R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
            return;
        }

        AdasCfgActivity.launch(getActivity());
    }

    @OnClick({R.id.ll_continue_tour, R.id.ll_continue_tour_fleet, R.id.ll_continue_tour_manager})
    void continueTour() {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.pop_continue_guide, null);
        PopupWindow popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                true);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.iv_close_pop).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.btn_next_guide).setOnClickListener(v -> popupWindow.dismiss());
        view.findViewById(R.id.btn_continue_guide).setOnClickListener(v -> {
            popupWindow.dismiss();
            LocalLiveActivity.launchForGuide(getContext());
        });
        view.findViewById(R.id.tv_never_guide).setOnClickListener(v -> {
            llContinueTourManager.setVisibility(View.GONE);
            llContinueTour.setVisibility(View.GONE);
            popupWindow.dismiss();
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, false);
        });
        popupWindow.showAsDropDown(toolbar);
    }

    @OnClick({R.id.ll_wifi_trouble, R.id.ll_wifi_trouble_fleet, R.id.ll_wifi_trouble_manager})
    void wifiTrouble() {
        DialogHelper.showWifiTroubleDialog(getContext(), this::checkLocationPermission);
    }

    @OnClick(R.id.ll_start_tour)
    void onStartTour() {
        //这里进入要进行全部流程
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, true);
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_DIRECT, true);
        LocalLiveActivity.launchForGuide(getContext());
    }

    @OnClick(R.id.ll_network)
    void onNetworkTest() {
        NetworkTestActivity.launch(getActivity(), false);
    }

    @OnClick(R.id.ll_power_cord)
    void onDirectTest() {
        DirectTestActivity.launch(getActivity(), false);
    }

    @OnClick(R.id.ll_calib_camera)
    public void goCalibCamera() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);

        if (currentCamera == null) {
            Toast.makeText(getContext(), R.string.setting_request, Toast.LENGTH_LONG).show();
            return;
        }

        Logger.t(TAG).i("isCalibCameraAvailable hardwareName = " + currentCamera.getHardwareName()
                + " apiVersion = " + currentCamera.getApiVersion());

        if (!currentCamera.isCalibCameraAvailable()) {
            Toast.makeText(getContext(), R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
            return;
        }

        CalibActivity.launch(getActivity(), false);
    }

    @OnClick(R.id.ll_report_issue)
    void onReportIssue() {
        FeedbackActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_about)
    void onAboutVersion() {
        VersionCheckActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_clean_cache)
    void onCleanCache() {
        DialogHelper.showCleanCacheDialog(mActivitySoft.get(), () -> {
            DataCleanManager.clearAllCache(mActivitySoft.get());
            Toast.makeText(getContext(), R.string.cache_cleaned, Toast.LENGTH_SHORT).show();
        });
    }

    @OnClick(R.id.ll_data_usage)
    void onDataUsage() {
        DataUsageActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_personnel)
    void onPersonnel() {
        PersonnelActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_vehicle)
    void onVehicle() {
        AssetActivity.launch(getActivity(), 0);
    }

    @OnClick(R.id.ll_driver)
    void onDriver() {
        AssetActivity.launch(getActivity(), 1);
    }

    @OnClick(R.id.ll_device)
    void onDevice() {
        AssetActivity.launch(getActivity(), 2);
    }

    @OnClick(R.id.ll_geo_fencing)
    void onGeoFencing() {
//        Toast.makeText(getContext(), "功能正在开发中...", Toast.LENGTH_SHORT).show();
        GeoFenceActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_setup_camera)
    void onSetupCamera() {
        SetupFleetActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_album)
    void onAlbum() {
        AlbumActivity.launch(getActivity());

//        if (mCamera != null){
//            evCamera.getMOC();
//
//            RxBus.getDefault().toObservable(TCVNEvent.class)
//                    .compose(bindToLifecycle())
//                    .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
//                    .observeOn(AndroidSchedulers.mainThread())
//                    .subscribe(event -> {
//                        Toast.makeText(getActivity(),event.getMOC(),Toast.LENGTH_SHORT).show();
//                    }, throwable -> {
//                        Toast.makeText(getActivity(),throwable.getMessage(),Toast.LENGTH_SHORT).show();
//                        new ServerErrorHandler(TAG);
//                    });
//        }
    }

//    @OnClick({R.id.ll_connect_wifi, R.id.tvConnectWifiCamera})
//    void onConnectWifi() {
//        Toast.makeText(getContext(), "功能正在开发中...", Toast.LENGTH_SHORT).show();
//        if (mCamera != null) {
//            VideosActivity.launch(getActivity(), mCamera.getSerialNumber(), false);
//            evCamera.configMOC(true);
//
//            RxBus.getDefault().toObservable(TCVNEvent.class)
//                    .compose(bindToLifecycle())
//                    .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
//                    .observeOn(AndroidSchedulers.mainThread())
//                    .subscribe(event -> {
//                        Toast.makeText(getActivity(),event.getMOC(),Toast.LENGTH_SHORT).show();
//                    }, throwable -> {
//                        Toast.makeText(getActivity(),throwable.getMessage(),Toast.LENGTH_SHORT).show();
//                        new ServerErrorHandler(TAG);
//                    });
//        }
//    }

    @OnClick(R.id.tvConnectWifiCamera)
    public void onConnectWifiCamera() {
        if (mCamera != null) {
            VideosActivity.launch(getActivity(), mCamera.getSerialNumber(), false);
        } else {
            Intent callSettingWifiIntent = new Intent(Settings.ACTION_WIFI_SETTINGS);
            getContext().startActivity(callSettingWifiIntent);
        }
    }

    @OnClick(R.id.ll_tcvn)
    void onTCVN() {

//        if (mCamera != null) {
//            evCamera.configMOC(false);
//
//            RxBus.getDefault().toObservable(TCVNEvent.class)
//                    .compose(bindToLifecycle())
//                    .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
//                    .observeOn(AndroidSchedulers.mainThread())
//                    .subscribe(event -> {
//                        Toast.makeText(getActivity(),event.getMOC(),Toast.LENGTH_SHORT).show();
//                    }, throwable -> {
//                        Toast.makeText(getActivity(),throwable.getMessage(),Toast.LENGTH_SHORT).show();
//                        new ServerErrorHandler(TAG);
//                    });
//        }
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);

        if (currentCamera == null) {
            Toast.makeText(getActivity(), R.string.setting_request, Toast.LENGTH_SHORT).show();
            return;
        }

        Logger.t(TAG).i("goAdasSettings isAdasCfgAvailable = " + currentCamera.isAdasCfgAvailable());

        if (!currentCamera.isAdasCfgAvailable()) {
            Toast.makeText(getActivity(), R.string.network_fw_prompt, Toast.LENGTH_SHORT).show();
            return;
        }
        //
        PopupMenu popupMenu = new PopupMenu(getActivity(), llTCVN, Gravity.RIGHT);
        popupMenu.inflate(R.menu.menu_type_tcvn);

        Menu menu = popupMenu.getMenu();
        // com.android.internal.view.menu.MenuBuilder
        Log.i(TAG, "Menu class: " + menu.getClass().getName());

        // Register Menu Item Click event.
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                return menuItemClicked(item);
            }
        });

        // Show the PopupMenu.
        popupMenu.show();
    }

    @OnClick(R.id.ll_cfg_mk)
    public void toCameraCfg() {
        PopupMenu popupMenu = new PopupMenu(getActivity(), llCfgMK, Gravity.RIGHT);
        popupMenu.inflate(R.menu.menu_type_cfgmk);

        Menu menu = popupMenu.getMenu();
        // com.android.internal.view.menu.MenuBuilder
        Log.i(TAG, "Menu class: " + menu.getClass().getName());

        // Register Menu Item Click event.
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                return menuItemClicked(item);
            }
        });

        // Show the PopupMenu.
        popupMenu.show();
    }

    @OnClick(R.id.ll_login_withFace)
    public void loginWithFace() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            if (!mCamera.isCalibCameraAvailable()) {
                Toast.makeText(getActivity(), R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
                return;
            }
            if (mCamera.getRecordState() != VdtCamera.STATE_RECORD_STOPPED) {
                mCamera.stopRecording();
            }

            LoginWithFaceActivity.launch(getActivity(), false);
        } else {
            Toast.makeText(getActivity(), R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * handle event click menu TCVN, config camera
     */
    @SuppressLint({"CheckResult", "NonConstantResourceId"})
    private boolean menuItemClicked(MenuItem item) {
        CustomMK customMK;
        switch (item.getItemId()) {
            case R.id.menuItem_basic:
                showLoadingDialog();
                customMK = new CustomMK("msg01");
                evCamera.setAdasCfgInfoWithMK(customMK, CMD_MK_TCVN01);

                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(tcvn01Event -> {
                            Logger.t(TAG).i("initListener adasCfgInfo = " + tcvn01Event.getModel01().getSn());
                            hideLoadingDialog();
                            TCVNActivity.launch(getActivity(), tcvn01Event.getModel01());
                        }, new ServerErrorHandler(TAG));

                break;
            case R.id.menuItem_time_work_dr:
                showLoadingDialog();
                customMK = new CustomMK("msg02");
                evCamera.setAdasCfgInfoWithMK(customMK, CMD_MK_TCVN02);

                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(tcvnEvent -> {
                            Logger.t(TAG).i("initListener adasCfgInfo = " + tcvnEvent.getModel02().getDrv_name());
                            hideLoadingDialog();
                            TCVNActivity.launch(getActivity(), tcvnEvent.getModel02());
                        }, new ServerErrorHandler(TAG));
                break;
            case R.id.menuItem_prk_stop_time:
                showLoadingDialog();
                customMK = new CustomMK("msg03");
                evCamera.setAdasCfgInfoWithMK(customMK, CMD_MK_TCVN03);

                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(tcvnEvent -> {
                            Logger.t(TAG).i("initListener adasCfgInfo = " + tcvnEvent.getModel03().getTime());
                            hideLoadingDialog();
                            TCVNActivity.launch(getActivity(), tcvnEvent.getModel03());
                        }, new ServerErrorHandler(TAG));
                break;
            case R.id.menuItem_journey_car:
                showLoadingDialog();
                customMK = new CustomMK("msg04");
                evCamera.setAdasCfgInfoWithMK(customMK, CMD_MK_TCVN04);

                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(tcvnEvent -> {
                            Logger.t(TAG).i("initListener adasCfgInfo = " + tcvnEvent.getModel04().getCur_time());
                            hideLoadingDialog();
                            TCVNActivity.launch(getActivity(), tcvnEvent.getModel04());
                        }, new ServerErrorHandler(TAG));
                break;
            case R.id.menuItem_spd_real_time:
                showLoadingDialog();
                customMK = new CustomMK("msg05");
                evCamera.setAdasCfgInfoWithMK(customMK, CMD_MK_TCVN05);

                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(tcvnEvent -> {
                            Logger.t(TAG).i("initListener adasCfgInfo = " + tcvnEvent.getModel05().getSpeed_record_time());
                            hideLoadingDialog();
                            TCVNActivity.launch(getActivity(), tcvnEvent.getModel05());
                        }, new ServerErrorHandler(TAG));
                break;
            case R.id.menuItem_set_drv_info:
                TCVNActivity.launch(getActivity(), CMD_MK_SET_DRIVER_INFO);
                break;
            case R.id.menuItem_setting_cfg:
                TCVNActivity.launch(getActivity(), CMD_MK_SETTING_CFG);
                break;
            case R.id.menuItem_login_cmr:
                TCVNActivity.launch(getActivity(), CMD_MK_INOUT);
                break;
            case R.id.menuItem_getLogFile:
                ReportLogActivity.launch(getActivity());
                break;
            case R.id.menuItem_checkSimData:
                showLoadingDialog();
                evCamera.checkCarrier();
                RxBus.getDefault().toObservable(TCVNEvent.class)
                        .compose(bindToLifecycle())
                        .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
                        .timeout(30, TimeUnit.SECONDS)
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribeOn(Schedulers.io())
                        .subscribe(event -> {
                            Logger.t(TAG).i("initListener checkCarrier= " + event.getCarrierBean().getValue());
                            hideLoadingDialog();
                            CheckSimDataActivity.launch(getActivity(), event.getCarrierBean());
                        }, throwable -> {
                            hideLoadingDialog();
                            CheckSimDataActivity.launch(getActivity());
                            Toast.makeText(getActivity(), "check Carrier lỗi", Toast.LENGTH_SHORT).show();
                            new ServerErrorHandler(TAG);
                        });
                break;
            default:
                Toast.makeText(getActivity(), (String) item.getTitle(), Toast.LENGTH_SHORT).show();
                break;
        }
        return true;
    }

    private SoftReference<Activity> mActivitySoft;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivitySoft = new SoftReference<>(activity);
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_profile;
    }

    @SuppressLint("SetTextI18n")
    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);


        checkFleet();
        initEvent();
        String[] titles = new String[]{getString(R.string.vehicles), getString(R.string.cameras), getString(R.string.driver)};
        int[] tabIcon = {R.drawable.ic_manage_vehicle, R.drawable.ic_manage_device, R.drawable.ic_manage_driver};
        MyFragmentPagerAdapter pagerAdapter = new MyFragmentPagerAdapter(getChildFragmentManager());
        for (int i = 0; i < titles.length; i++) {
            pagerAdapter.addFragment(AssetFragment.newInstance(2, i));
            tabLayout.addTab(tabLayout.newTab());
        }

        tabLayout.setupWithViewPager(pageContent, false);
        pageContent.setAdapter(pagerAdapter);
        pageContent.addOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                setColorWithPosition(position);

            }
        });

        for (int i = 0; i < titles.length; i++) {
            TabLayout.Tab tab = tabLayout.getTabAt(i);
            if (tab != null) {
                View view = getLayoutInflater().inflate(R.layout.layout_custom_img_tab, null);
                ImageView icon = view.findViewById(R.id.icon);
                imageViews.add(icon);
                TextView tvTab = view.findViewById(R.id.tvTabTitle);
                tvTab.setText(titles[i]);
                textViews.add(tvTab);

                icon.setImageResource(tabIcon[i]);
                icon.setColorFilter(ContextCompat.getColor(getContext(), i == 0 ? R.color.colorControlPanel : R.color.dark_gray), PorterDuff.Mode.SRC_IN);
                tvTab.setTextColor(getContext().getColor(i == 0 ? R.color.colorControlPanel : R.color.dark_gray));
                tab.setCustomView(view);

            }
        }

    }

    private void setColorWithPosition(int position) {
        switch (position) {
            case 0:
                imageViews.get(position).setColorFilter(ContextCompat.getColor(getContext(), R.color.colorControlPanel), PorterDuff.Mode.SRC_IN);
                imageViews.get(1).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);
                imageViews.get(2).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);

                //
                textViews.get(position).setTextColor(getContext().getColor(R.color.colorControlPanel));
                textViews.get(1).setTextColor(getContext().getColor(R.color.dark_gray));
                textViews.get(2).setTextColor(getContext().getColor(R.color.dark_gray));
                break;
            case 1:
                imageViews.get(position).setColorFilter(ContextCompat.getColor(getContext(), R.color.colorControlPanel), PorterDuff.Mode.SRC_IN);
                imageViews.get(0).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);
                imageViews.get(2).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);

                //
                textViews.get(position).setTextColor(getContext().getColor(R.color.colorControlPanel));
                textViews.get(0).setTextColor(getContext().getColor(R.color.dark_gray));
                textViews.get(2).setTextColor(getContext().getColor(R.color.dark_gray));
                break;
            case 2:
                imageViews.get(position).setColorFilter(ContextCompat.getColor(getContext(), R.color.colorControlPanel), PorterDuff.Mode.SRC_IN);
                imageViews.get(1).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);
                imageViews.get(0).setColorFilter(ContextCompat.getColor(getContext(), R.color.dark_gray), PorterDuff.Mode.SRC_IN);

                //
                textViews.get(position).setTextColor(getContext().getColor(R.color.colorControlPanel));
                textViews.get(1).setTextColor(getContext().getColor(R.color.dark_gray));
                textViews.get(0).setTextColor(getContext().getColor(R.color.dark_gray));
                break;
        }
    }

    private void checkFleet() {
        if (Constants.isFleet()) {
            CurrentUser currentUser = viewModel().getCurrentUser();
            tvToolbarTitle.setText(currentUser != null ? currentUser.getUserLogin().getFleetName() : getString(R.string.asset_management));

            vaProfile.setDisplayedChild(2);
        }
    }

    private void initEvent() {

        viewModel.getCurrentUser().userLoginObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updateUserLoginInfo, new ServerErrorHandler(TAG));

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));

        viewModel.getFleetInfo().vehicleObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVehicleList, new ServerErrorHandler(TAG));

        viewModel.getFleetInfo().deviceObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDeviceList, new ServerErrorHandler(TAG));

        viewModel.getFleetInfo().driverObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDriverList, new ServerErrorHandler(TAG));

    }


    private void onDeviceList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeans = listOptional.getIncludeNull();
//        Logger.t(TAG).d("deviceList: " + cameraBeans.size());
        deviceList.clear();
        deviceList.addAll(cameraBeans);
        reloadCount();
    }

    private void onDriverList(Optional<List<DriverInfoBean>> listOptional) {
        List<DriverInfoBean> driverInfoBeans = listOptional.getIncludeNull();
//        Logger.t(TAG).d("driverList: " + driverInfoBeans.size());
        driverList.clear();
        driverList.addAll(driverInfoBeans);
        reloadCount();
    }

    private void onVehicleList(Optional<List<VehicleInfoBean>> listOptional) {
        List<VehicleInfoBean> vehicleInfoBeans = listOptional.getIncludeNull();
//        Logger.t(TAG).d("vehicleList: " + vehicleInfoBeans.size());
        vehicleList.clear();
        vehicleList.addAll(vehicleInfoBeans);
        reloadCount();
    }

    private void reloadCount() {
        if (textViewCounts.size() != 0) {
            for (int i = 0; i < textViewCounts.size(); i++) {
                TextView tvCount = textViewCounts.get(i);
                if (i == 0) {
                    tvCount.setVisibility(vehicleList.size() != 0 ? View.VISIBLE : View.GONE);
                    tvCount.setText("" + vehicleList.size());
                } else if (i == 1) {
                    tvCount.setVisibility(deviceList.size() != 0 ? View.VISIBLE : View.GONE);
                    tvCount.setText("" + deviceList.size());
                } else {
                    tvCount.setVisibility(driverList.size() != 0 ? View.VISIBLE : View.GONE);
                    tvCount.setText("" + driverList.size());
                }
            }
        }
    }

    private void onCurrentCamera(Optional<CameraWrapper> vdtCameraOptional) {
        mCamera = vdtCameraOptional.getIncludeNull();
        evCamera = (EvCamera) mCamera;
        Logger.t(TAG).d("onCurrentCamera: " + mCamera);
        llTCVN.setVisibility(mCamera == null ? View.GONE : View.VISIBLE);
        llCfgMK.setVisibility(mCamera == null ? View.GONE : View.VISIBLE);
        llLoginWithFace.setVisibility(View.GONE);
        llConnectWifi.setVisibility(mCamera == null ? View.GONE : View.VISIBLE);
        llCalibCamera.setVisibility(mCamera == null ? View.GONE : View.VISIBLE);
        if (mCamera == null) {
            tvConnectWifiCamera.setText(getString(R.string.click_to_setting));
            tvConnectWifiCamera.setBackground(getContext().getDrawable(R.drawable.bg_gray_radius12));
            tvConnectWifiCamera.setTextColor(getContext().getColor(R.color.colorNaviText));
        } else {
            tvConnectWifiCamera.setTextColor(getContext().getColor(R.color.color_txt_success));
            tvConnectWifiCamera.setText(String.format(getString(R.string.click_to_connect), mCamera.getSerialNumber()));
            tvConnectWifiCamera.setBackground(getContext().getDrawable(R.drawable.bg_green_radius12));
        }
    }

    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
        initView();
    }

    @Override
    protected void onFragmentFirstVisible() {
    }

    private void updateUserInfo(Optional<User> userOptional) {
        User user = userOptional.getIncludeNull();
        Logger.t(TAG).d("updateUserInfo: " + user);

        if (user == null) {
            Logger.t(TAG).e("user == null");
            tv_nickname.setText(getResources().getString(R.string.log_in));
            iv_avatar.setImageDrawable(getResources().getDrawable(R.drawable.setting_user));
            return;
        }

        Glide.with(getContext())
                .load(user.avatar())
                .centerCrop()
                .transform(new CircleTransform(getActivity()))
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .placeholder(R.drawable.setting_user)
                .crossFade()
                .into(iv_avatar);

        tv_nickname.setText(!TextUtils.isEmpty(user.displayName()) ? user.displayName() : user.name());
    }

    private void updateUserLoginInfo(Optional<UserLogin> userOptional) {
        UserLogin user = userOptional.getIncludeNull();
        Logger.t(TAG).d("updateUserInfo: " + user);

        if (user == null) {
            Logger.t(TAG).e("user == null");
            tvNicknameDriver.setText(getResources().getString(R.string.log_in));

            tvNicknameFleet.setText(getResources().getString(R.string.log_in));
            ivAvatarFleet.setImageDrawable(getResources().getDrawable(R.drawable.icon_driver));
            return;
        }

        tvNicknameDriver.setText(!TextUtils.isEmpty(user.getUserName()) ? user.getUserName() : user.getRealName());

        Glide.with(getContext())
                .load(user.getAvatar())
                .centerCrop()
                .transform(new CircleTransform(getActivity()))
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .placeholder(R.drawable.icon_driver)
                .crossFade()
                .into(ivAvatarFleet);

        tvNicknameFleet.setText(!TextUtils.isEmpty(user.getUserName()) ? user.getUserName() : user.getRealName());
    }

    private void initView() {
        boolean setup = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, !Constants.isFleet());
        if (setup) {
            llContinueTour.setVisibility(View.VISIBLE);
//            llContinueTourFleet.setVisibility(View.VISIBLE);
            llContinueTourManager.setVisibility(View.VISIBLE);
        } else {
            llContinueTour.setVisibility(View.GONE);
//            llContinueTourFleet.setVisibility(View.GONE);
            llContinueTourManager.setVisibility(View.GONE);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            boolean permission = PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_COARSE_LOCATION) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_FINE_LOCATION) == PermissionChecker.PERMISSION_GRANTED;
            if (permission) {
                boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(getContext());
                if (gpsServiceEnable) {
                    llWifiTrouble.setVisibility(View.GONE);
                    llWifiTroubleFleet.setVisibility(View.GONE);
                    llWifiTroubleManager.setVisibility(View.GONE);
                } else {
                    llWifiTrouble.setVisibility(View.VISIBLE);
                    llWifiTroubleFleet.setVisibility(View.VISIBLE);
                    llWifiTroubleManager.setVisibility(View.VISIBLE);
                }
            } else {
                llWifiTrouble.setVisibility(View.VISIBLE);
                llWifiTroubleFleet.setVisibility(View.VISIBLE);
                llWifiTroubleManager.setVisibility(View.VISIBLE);
            }
        } else {
            llWifiTrouble.setVisibility(View.GONE);
            llWifiTroubleFleet.setVisibility(View.GONE);
            llWifiTroubleManager.setVisibility(View.GONE);
        }
    }

    private void checkLocationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_COARSE_LOCATION) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_FINE_LOCATION) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_LOCATION_REQUESTCODE);
            } else {
                checkGpsService();
            }
        }
    }

    private void checkGpsService() {
        boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(getContext());
        if (gpsServiceEnable) {
            checkWifiEnable(true);
        } else {
            Intent gpsOptionsIntent = new Intent(
                    Settings.ACTION_LOCATION_SOURCE_SETTINGS);
            startActivityForResult(gpsOptionsIntent, SERVICE_GPS_INFO);
        }
    }

    private void checkWifiEnable(boolean showPanel) {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            WifiManager wifiManager = (WifiManager) mActivitySoft.get().getApplicationContext().getSystemService(Service.WIFI_SERVICE);
            if (wifiManager != null) {
                int wifiState = wifiManager.getWifiState();
                if (wifiState == WifiManager.WIFI_STATE_ENABLED) {
                    WifiDirectConnection.getInstance().discoverPeers();
                } else {
                    if (showPanel) {
                        Intent panelIntent = new Intent(Settings.Panel.ACTION_WIFI);
                        startActivityForResult(panelIntent, SERVICE_WIFI_INFO);
                    } else {
                        Toast.makeText(getContext(), getResources().getString(R.string.wifi_enable), Toast.LENGTH_LONG).show();
                    }
                }
            }
        } else {
            WifiDirectConnection.getInstance().discoverPeers();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode);
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
                        DialogHelper.showPermissionDialog(getContext(),
                                () -> PermissionUtil.startAppSetting(this),
                                () -> Toast.makeText(getContext(), getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show());
                    } else {
                        Toast.makeText(getContext(), getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_COARSE_LOCATION) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(mActivitySoft.get(), Manifest.permission.ACCESS_FINE_LOCATION) == PermissionChecker.PERMISSION_GRANTED) {
                checkGpsService();
            } else {
                Toast.makeText(getContext(), getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == SERVICE_GPS_INFO) {
            boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(getContext());
            if (gpsServiceEnable) {
                checkWifiEnable(true);
            } else {
                Toast.makeText(getContext(), getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == SERVICE_WIFI_INFO) {
            checkWifiEnable(false);
        }
    }
}
