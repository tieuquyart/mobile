package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

import com.google.android.material.tabs.TabLayout;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.WrapContentViewPager;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.event.MountParamChangeEvent;
import com.mkgroup.camera.event.RadarSensitivityChangeEvent;
import com.mkgroup.camera.event.SenseLevelChangeEvent;
import com.mkgroup.camera.message.bean.MountVersion;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.DebugHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.fragment.DrivingSettingFragment;
import com.mk.autosecure.ui.fragment.ParkingSettingFragment;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class SenseActivity extends RxFragmentActivity {

    private final static String TAG = SenseActivity.class.getSimpleName();
    public static final int SENSE_SETTING = 0x03;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.ll_monitoring_setting)
    LinearLayout llMonitorSetting;

    @BindView(R.id.tabs)
    TabLayout tabLayout;

    @BindView(R.id.viewpager)
    WrapContentViewPager viewPager;

    @BindView(R.id.rl_motion)
    RelativeLayout rlMotion;

    @BindView(R.id.ll_motion_tips)
    LinearLayout llMotionTips;

    @BindView(R.id.iv_motion_tips)
    ImageView ivMotionTips;

    @BindView(R.id.seek_motion)
    SeekBar seekMotion;

    @BindView(R.id.rl_impact)
    RelativeLayout rlImpact;

    @BindView(R.id.ll_impact_tips)
    LinearLayout llImpactTips;

    @BindView(R.id.iv_impact_tips)
    ImageView ivImpactTips;

    @BindView(R.id.seek_impact)
    SeekBar seekImpact;

    @BindView(R.id.rl_notification)
    RelativeLayout rlNotification;

    @OnClick(R.id.ll_motion_sensitivity)
    public void motionSense() {
        if (mCamera != null) {
            if (llMotionTips.getVisibility() == View.VISIBLE) {
                rotateHide(ivMotionTips);
                llMotionTips.setVisibility(View.GONE);
            } else {
                rotateShow(ivMotionTips);
                llMotionTips.setVisibility(View.VISIBLE);
            }
        } else if (mCameraBean != null) {
            Toast.makeText(SenseActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.ll_impact_sensitivity)
    public void impactSense() {
        if (mCamera != null) {
            if (llImpactTips.getVisibility() == View.VISIBLE) {
                rotateHide(ivImpactTips);
                llImpactTips.setVisibility(View.GONE);
            } else {
                rotateShow(ivImpactTips);
                llImpactTips.setVisibility(View.VISIBLE);
            }
        } else if (mCameraBean != null) {
            Toast.makeText(SenseActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.rl_notification)
    public void onNotificationClicked() {
        NotificationActivity.launch(this, sn);
    }

    private String sn;

    private CameraWrapper mCamera;

    private CameraBean mCameraBean;

    private MyFragmentStatePagerAdapter mAdapter;

    private TabLayout.OnTabSelectedListener tabSelectedListener = new TabLayout.OnTabSelectedListener() {
        @Override
        public void onTabSelected(TabLayout.Tab tab) {
            View view = tab.getCustomView();
            if (view != null) {
                TextView tvContent = view.findViewById(R.id.tv_content);
                tvContent.setTextColor(getResources().getColor(R.color.colorAccent));
            }
        }

        @Override
        public void onTabUnselected(TabLayout.Tab tab) {
            View view = tab.getCustomView();
            if (view != null) {
                TextView tvContent = view.findViewById(R.id.tv_content);
                tvContent.setTextColor(getResources().getColor(R.color.colorPrimary));
            }
        }

        @Override
        public void onTabReselected(TabLayout.Tab tab) {

        }
    };

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SenseActivity.class);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, SenseActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CameraBean cameraBean) {
        Intent intent = new Intent(activity, SenseActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        activity.startActivityForResult(intent, SENSE_SETTING);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sense);
        ButterKnife.bind(this);
        setToolbar();

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);

        if (mCameraBean == null && !TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }

        if (TextUtils.isEmpty(sn) && mCameraBean != null) {
            sn = mCameraBean.sn;
        }

        if (mCameraBean != null) {
            updateFourGStateUI();
        } else if (mCamera != null) {
            updateCameraStateUI();
        }

        initView();
        initEvent();
    }

    private void updateCameraStateUI() {
        if (mCamera != null) {
            MountVersion mountVersion = mCamera.getMountVersion();
            boolean ownerDevice = HornApplication.getComponent().currentUser().ownerDevice(sn);
            if (mountVersion != null && mountVersion.support_4g && ownerDevice) {
                rlNotification.setVisibility(View.VISIBLE);
            }
        }
    }

    private void updateFourGStateUI() {
        if (mCameraBean != null) {
            rlMotion.setBackgroundResource(R.color.colorUnsetting);
            rlImpact.setBackgroundResource(R.color.colorUnsetting);
            boolean ownerDevice = HornApplication.getComponent().currentUser().ownerDevice(sn);
            if (mCameraBean.is4G != null && mCameraBean.is4G && ownerDevice) {
                rlNotification.setVisibility(View.VISIBLE);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));
    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper cameraWrapper = camera.getIncludeNull();
        Logger.t(TAG).e("onCurrentCamera: " + cameraWrapper);
        if (cameraWrapper != null) {
            if (mCamera != null && mCamera.getSerialNumber().equals(cameraWrapper.getSerialNumber())) {
                mCamera = cameraWrapper;
                onNewCamera(cameraWrapper);
            } else if (mCameraBean != null) {
                onNewCamera(mCameraBean);
            }
        } else if (mCameraBean != null) {
            onNewCamera(mCameraBean);
        } else {
            onDisconnectCamera();
        }
    }

    private void onNewCamera(CameraBean cameraBean) {
        Logger.t(TAG).d("onNewCamera: " + cameraBean.name);
        int monitorMode = "parking".equals(cameraBean.state.mode) ? 0 : 1;
        TabLayout.Tab tab = tabLayout.getTabAt(monitorMode);
        if (tab != null) {
            new Handler().post(tab::select);
        }
        onMonitorModeChangeEvent(monitorMode);

        if (cameraBean.is4G != null && cameraBean.is4G && cameraBean.isOnline) {
            llMonitorSetting.setVisibility(View.VISIBLE);
        }
    }

    private void onNewCamera(CameraWrapper cameraWrapper) {
        Logger.t(TAG).d("onNewCamera: " + cameraWrapper.getName());
        int monitorMode = cameraWrapper.getMonitorMode();
        if (monitorMode != VdtCamera.MONITOR_MODE_UNKNOWN) {
            TabLayout.Tab tab = tabLayout.getTabAt(monitorMode);
            if (tab != null) {
                new Handler().post(tab::select);
            }
        }
        onMonitorModeChangeEvent(monitorMode);

        llMonitorSetting.setVisibility(View.VISIBLE);
    }

    private void onDisconnectCamera() {
        Logger.t(TAG).d("onDisconnectCamera");
        llMonitorSetting.setVisibility(View.GONE);
        if (mCameraBean == null) {
            Toast.makeText(this, getResources().getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show();
            LocalLiveActivity.launch(this, true);
        }
    }

    private void initView() {
        tvToolbarTitle.setText(R.string.sensitivity);

        mAdapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());

        List<Fragment> fragments = getPagerFragments();
        List<Integer> pageTitleList = getFragmentTitlesRes();
        for (int i = 0; i < fragments.size(); i++) {
            mAdapter.addFragment(fragments.get(i), getString(pageTitleList.get(i)));
        }
        viewPager.setAdapter(mAdapter);

        tabLayout.setupWithViewPager(viewPager);

        tabLayout.addOnTabSelectedListener(tabSelectedListener);

        tabLayout.removeAllTabs();
        tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.parking_tab), true);
        tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.driving_tab));

        if (mCamera != null) {
            onImpactSeekTo(mCamera.getMountLevel());

//            String mountParam = mCamera.getMountParam();
//            et_custom_sense.setText(mountParam);

            boolean supportRadar = mCamera.getSupportRadar();
            if (supportRadar) {
                rlMotion.setVisibility(View.VISIBLE);

                seekMotion.setProgress(mCamera.getRadarSensitivity() * 10);

                RxBus.getDefault()
                        .toObservable(RadarSensitivityChangeEvent.class)
                        .compose(bindToLifecycle())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(this::onRadarChangeEvent, new ServerErrorHandler());
            }
        }

        if (DebugHelper.isInDebugMode()) {
//            tv_debug.setVisibility(View.VISIBLE);
//            rb_custom.setVisibility(View.VISIBLE);
//            et_custom_sense.setVisibility(View.VISIBLE);
//            tv_custom_tips.setVisibility(View.VISIBLE);
        }

        seekMotion.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Logger.t(TAG).d("onStopTrackingTouch: " + seekBar.getProgress());
                if (mCamera != null) {
                    float progress = seekBar.getProgress();
                    if (progress != 0) {
                        progress = Math.round(progress / 10);
                    }
                    mCamera.setRadarSensitivity((int) progress);
                }
            }
        });

        seekImpact.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Logger.t(TAG).d("onStopTrackingTouch: " + seekBar.getProgress());
                if (mCamera != null) {
                    float progress = seekBar.getProgress();
                    Logger.t(TAG).d("MountAccelLevels: " + mCamera.getMountLevel());
                    if (progress < 25 && mCamera.getMountLevel() != 2) {
                        seekBar.setProgress(0);
                        mCamera.setMountLevel(2);
                    } else if (progress >= 25 && progress <= 75 && mCamera.getMountLevel() != 1) {
                        seekBar.setProgress(50);
                        mCamera.setMountLevel(1);
                    } else if (progress > 75 && mCamera.getMountLevel() != 0) {
                        seekBar.setProgress(100);
                        mCamera.setMountLevel(0);
                    } else {
                        onImpactSeekTo(mCamera.getMountLevel());
                    }
                }
            }
        });

//        rg_level.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
//            @Override
//            public void onCheckedChanged(RadioGroup group, int checkedId) {
//                if (checkedId == rb_custom.getId()) {
//                    if (mCamera != null) {
//                        mCamera.setMountLevel(-1);
//                        Logger.t(TAG).e("param: " + et_custom_sense.getText().toString().trim());
//                        mCamera.setMountParam(et_custom_sense.getText().toString().trim());
//                    }
//                } else {
//                    for (int id : checkList) {
//                        if (id == checkedId) {
//                            int indexOf = checkList.indexOf(id);
//                            Logger.t(TAG).e("indexOf: " + indexOf);
//                            if (mCamera != null) {
//                                mCamera.setMountLevel(indexOf);
//                                break;
//                            }
//                        }
//                    }
//                }
//            }
//        });
    }

    private void onRadarChangeEvent(RadarSensitivityChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int sensitivity = event.getSensitivity();
            seekMotion.setProgress(sensitivity * 10);
        }
    }

    private void onImpactSeekTo(int index) {
        switch (index) {
            case -1:
                // TODO: 2019/4/1 debug custom
                break;
            case 0:
                seekImpact.setProgress(100);
                break;
            case 1:
                seekImpact.setProgress(50);
                break;
            case 2:
                seekImpact.setProgress(0);
                break;
        }
    }

    private void initEvent() {
        RxBus.getDefault()
                .toObservable(CameraStateChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHandleCameraStateChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(SenseLevelChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountLevelChangeEvent, new ServerErrorHandler());

        RxBus.getDefault().toObservable(MountParamChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountParamChangeEvent, new ServerErrorHandler());
    }

    public void onHandleCameraStateChangeEvent(CameraStateChangeEvent event) {
        Logger.t(TAG).d("%s", "cameraStateChangeEvent = " + ToStringUtils.getString(event));

        switch (event.getWhat()) {
            case CameraStateChangeEvent.CAMERA_STATE_MONITOR_MODE:
                onMonitorModeChangeEvent((Integer) event.getExtra());
                break;
        }
    }

    private void onMonitorModeChangeEvent(int monitorMode) {
        if (monitorMode > VdtCamera.MONITOR_MODE_UNKNOWN) {
            setActiveTab(monitorMode);
        }
    }

    private void setActiveTab(int index) {
        if (index < 0 || index >= tabLayout.getTabCount()) {
            return;
        }
        for (int i = 0; i < tabLayout.getTabCount(); i++) {
            TabLayout.Tab tab = tabLayout.getTabAt(i);
            if (tab == null) {
                return;
            }
            View view = tab.getCustomView();
            if (view == null) {
                return;
            }
            TextView tvTag = view.findViewById(R.id.tv_active_tag);
            tvTag.setVisibility(i == index ? View.VISIBLE : View.INVISIBLE);
        }
    }

    private void onMountLevelChangeEvent(SenseLevelChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
//            int curLevelIndex = event.getCurLevelIndex();
//            Logger.t(TAG).e("curLevelIndex: " + curLevelIndex);
            //这里的回调不是相机主动返回的，不是set后的结果
//            onImpactSeekTo(curLevelIndex);
        }
    }

    private void onMountParamChangeEvent(MountParamChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            String mountParam = event.getMountParam();
            Logger.t(TAG).e("mountParam: " + mountParam);
//            et_custom_sense.setText(mountParam);
        }
    }

    private void setToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> {
            createBundle();
            finish();
        });
    }

    @Override
    public void onBackPressed() {
        createBundle();
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        tabLayout.removeOnTabSelectedListener(tabSelectedListener);
    }

    public List<Fragment> getPagerFragments() {
        List<Fragment> fragments = new ArrayList<>();
        if (mCamera != null && mCamera.getMountVersion() != null) {
            boolean support_4g = mCamera.getMountVersion().support_4g;
            fragments.add(ParkingSettingFragment.newInstance(!support_4g, mCamera.getSerialNumber()));
            fragments.add(DrivingSettingFragment.newInstance(!support_4g, mCamera.getSerialNumber()));
        } else if (mCameraBean != null && mCameraBean.is4G != null) {
            boolean support_4g = mCameraBean.is4G;
            fragments.add(ParkingSettingFragment.newInstance(!support_4g, mCameraBean));
            fragments.add(DrivingSettingFragment.newInstance(!support_4g, mCameraBean));
        }
        return fragments;
    }

    public List<Integer> getFragmentTitlesRes() {
        List<Integer> titles = new ArrayList<>();
        titles.add(R.string.camera_setting_park);
        titles.add(R.string.camera_setting_drive);
        return titles;
    }

    private void rotateHide(ImageView imageView) {
        RotateAnimation animation = new RotateAnimation(180f, 360f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        animation.setDuration(300);
        animation.setFillAfter(true);
        animation.setInterpolator(new LinearInterpolator());
        imageView.startAnimation(animation);
    }

    private void rotateShow(ImageView imageView) {
        RotateAnimation animation = new RotateAnimation(0f, 180f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        animation.setDuration(300);
        animation.setFillAfter(true);
        animation.setInterpolator(new LinearInterpolator());
        imageView.startAnimation(animation);
    }

    private void createBundle() {
        if (mCameraBean != null) {

            ParkingSettingFragment parkingFragment = (ParkingSettingFragment) mAdapter.getItem(0);
            String parkDetection = parkingFragment.getDetection();
            String parkUpload = parkingFragment.getUpload();
            Logger.t(TAG).e("parkDetection: " + parkDetection);
            Logger.t(TAG).e("parkUpload: " + parkUpload);

            DrivingSettingFragment drivingFragment = (DrivingSettingFragment) mAdapter.getItem(1);
            String driveDetection = drivingFragment.getDetection();
            String driveUpload = drivingFragment.getUpload();
            Logger.t(TAG).e("driveDetection: " + driveDetection);
            Logger.t(TAG).e("driveUpload: " + driveUpload);

            Bundle bundle = new Bundle();
            bundle.putString("parkDetection", parkDetection);
            bundle.putString("parkUpload", parkUpload);
            bundle.putString("driveDetection", driveDetection);
            bundle.putString("driveUpload", driveUpload);
            setResult(SENSE_SETTING, getIntent().putExtras(bundle));
        }
    }
}
