package com.mk.autosecure.ui.activity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Service;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.PermissionChecker;
import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;

import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.fragment.DirectSetupFragment;
import com.mk.autosecure.ui.fragment.FirstSetupFragment;
import com.mk.autosecure.ui.fragment.LensSetupFragment;
import com.mk.autosecure.ui.fragment.SecondSetupFragment;
import com.mk.autosecure.ui.fragment.ThirdSetupFragment;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_CAMERA_SETUP;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSION_LOCATION_REQUESTCODE;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.SERVICE_GPS_INFO;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.SERVICE_WIFI_INFO;

/**
 * Created by DoanVT on 2017/8/24.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
@RequiresActivityViewModel(SetupActivityViewModel.ViewModel.class)
public class SetupActivity extends BaseActivity<SetupActivityViewModel.ViewModel> {

    private final static String TAG = SetupActivity.class.getSimpleName();

    private final static String KEY_INSTALLER = "Installer";

    @BindView(R.id.vp_setup)
    CustomViewPager vp_Setup;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.rl_loading)
    RelativeLayout rlLoading;

    //加载各个步骤fragment
    private MyFragmentStatePagerAdapter mSetupAdapter;

    private boolean showDirectSetup = false;

    private String sn;

    private boolean isInstaller = false;

    public static void launch(Activity activity, boolean guide) {
        Intent intent = new Intent(activity, SetupActivity.class);
        if (guide) {
            activity.startActivityForResult(intent, GUIDE_CAMERA_SETUP);
        } else {
            activity.startActivity(intent);
        }

        //activity.overridePendingTransition(R.anim.slide_in_right, R.anim.stay_still);
    }

    public static void launchForFleet(Activity activity, String sn) {
        Intent intent = new Intent(activity, SetupActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivityForResult(intent, GUIDE_CAMERA_SETUP);
    }

    public static void launchForInstaller(Activity activity, boolean install) {
        Intent intent = new Intent(activity, SetupActivity.class);
        intent.putExtra(KEY_INSTALLER, install);
        activity.startActivityForResult(intent, GUIDE_CAMERA_SETUP);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup);
        ButterKnife.bind(this);

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        isInstaller = getIntent().getBooleanExtra(KEY_INSTALLER, false);
        showDirectSetup = PreferenceUtils.getBoolean(PreferenceUtils.KEY_WIFI_DIRECT_SETUP, true);
        if (showDirectSetup) {
            checkLocationPermission();
        } else {
            initViews();
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
            initViews();
        }
    }

    private void checkGpsService() {
        boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(this);
        if (gpsServiceEnable) {
            initViews();
        } else {
            Intent gpsOptionsIntent = new Intent(
                    Settings.ACTION_LOCATION_SOURCE_SETTINGS);
//            gpsOptionsIntent.putExtra("extra_prefs_show_button_bar", true);
            startActivityForResult(gpsOptionsIntent, SERVICE_GPS_INFO);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        viewModel.outputs
                .nextStep()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> {
                    Logger.t(TAG).d("nextStep: " + integer);
                    int index = showDirectSetup ? integer : (vp_Setup.getCurrentItem() + 1);

                    if ((index == 4 || index == 3) && vp_Setup.getCurrentItem() == 0) {
                        return;
                    }

                    if (index < mSetupAdapter.getCount()) {
                        vp_Setup.setCurrentItem(index);
                    } else {
                        vp_Setup.setCurrentItem(mSetupAdapter.getCount() - 1);
                    }

                    if (index == mSetupAdapter.getCount() - 1) {
                        ((ThirdSetupFragment) mSetupAdapter.getItem(mSetupAdapter.getCount() - 1)).onSelected();
                    }
                }, new ServerErrorHandler());

        viewModel.outputs
                .showLoading()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> rlLoading.setVisibility(integer), new ServerErrorHandler());

//        directConnection = new WifiDirectConnection(this);
//        directConnection.registerP2PReceiver();
    }

    @Override
    protected void onPause() {
        super.onPause();

//        if (directConnection != null) {
//            directConnection.unregisterP2PReceiver();
//        }
    }

    @SuppressLint("CheckResult")
    private void initViews() {
        setupToolbar();
        checkWifiEnable(true);

        mSetupAdapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());
        List<Fragment> fragments = getPagerFragments();
        List<Integer> pageTitleList = getFragmentTitlesRes();
        for (int i = 0; i < fragments.size(); i++) {
            mSetupAdapter.addFragment(fragments.get(i), getString(pageTitleList.get(i)));
        }
        vp_Setup.setAdapter(mSetupAdapter);
//        vp_Setup.setOffscreenPageLimit(4);
        vp_Setup.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            @Override
            public void onPageSelected(int position) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {
            }
        });
    }

    private void checkWifiEnable(boolean showPanel) {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Service.WIFI_SERVICE);
            if (wifiManager != null) {
                int wifiState = wifiManager.getWifiState();
                if (wifiState != WifiManager.WIFI_STATE_ENABLED) {
                    if (showPanel) {
                        Intent panelIntent = new Intent(Settings.Panel.ACTION_WIFI);
                        startActivityForResult(panelIntent, SERVICE_WIFI_INFO);
                    } else {
                        Toast.makeText(this, R.string.wifi_enable, Toast.LENGTH_LONG).show();
                    }
                }
            }
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> goBack());
    }

    public List<Fragment> getPagerFragments() {
        List<Fragment> fragments = new ArrayList<>();
        fragments.add(FirstSetupFragment.newInstance(viewModel));

        if (showDirectSetup) fragments.add(DirectSetupFragment.newInstance(viewModel, sn));

        fragments.add(SecondSetupFragment.newInstance(viewModel)); // use wifi direct instead

        if (!isInstaller) fragments.add(LensSetupFragment.newInstance(viewModel));

        fragments.add(ThirdSetupFragment.newInstance(viewModel));
        return fragments;
    }

    public List<Integer> getFragmentTitlesRes() {
        List<Integer> titles = new ArrayList<>();
        titles.add(R.string.setup_continue);

        if (showDirectSetup) titles.add(R.string.setup_continue);

        titles.add(R.string.setup_continue);
        titles.add(R.string.setup_continue);
        titles.add(R.string.setup_continue);
        return titles;
    }

    @Override
    public void goBack() {
        int cur = vp_Setup.getCurrentItem();
        if (cur > 0) {
            if (showDirectSetup) {
                //work round back press
                CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                if (currentCamera != null) {
                    boolean needDewarp = currentCamera.getNeedDewarp();
                    if (needDewarp) {
                        boolean supportUpsidedown = currentCamera.getSupportUpsidedown();
                        if (supportUpsidedown) {
                            if (cur == 4) {
                                vp_Setup.setCurrentItem(cur - 1);
                            } else {
                                vp_Setup.setCurrentItem(0);
                            }
                        } else {
                            vp_Setup.setCurrentItem(0);
                        }
                    } else {
                        vp_Setup.setCurrentItem(0);
                    }
                } else {
                    vp_Setup.setCurrentItem(0);
                }
            } else {
                vp_Setup.setCurrentItem(cur - 1);
            }
        } else {
            super.goBack();
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
                                () -> PermissionUtil.startAppSetting(SetupActivity.this),
                                this::finish);
                    } else {
                        finish();
                    }
                }
                Toast.makeText(this, getResources().getString(R.string.location_must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PermissionChecker.PERMISSION_GRANTED) {
                checkGpsService();
            } else {
                finish();
                Toast.makeText(this, R.string.must_allow, Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == SERVICE_GPS_INFO) {
            boolean gpsServiceEnable = PermissionUtil.isGpsServiceEnable(this);
            if (gpsServiceEnable) {
                initViews();
            } else {
                finish();
                Toast.makeText(this, R.string.must_allow, Toast.LENGTH_LONG).show();
            }
        } else if (requestCode == SERVICE_WIFI_INFO) {
            checkWifiEnable(false);
        }
    }
}
