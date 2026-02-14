package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.app.Service;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Vibrator;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.rest.ServerErrorHandler;

import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;
import io.reactivex.schedulers.Schedulers;

import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_DIRECT_TEST;

public class DirectTestActivity extends RxActivity {

    private final static String TAG = DirectTestActivity.class.getSimpleName();
    private final static int WIFI_SETTING = 0;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.va_direct)
    ViewAnimator va_direct;

    @BindView(R.id.rg_power_install)
    RadioGroup rg_power_install;

    @BindView(R.id.rb_power_cable)
    RadioButton rb_power_cable;

    @BindView(R.id.rb_direct_wire)
    RadioButton rb_direct_wire;

    @BindView(R.id.btn_power_next)
    Button btn_power_next;

    @BindView(R.id.rg_vehicle_type)
    RadioGroup rg_vehicle_type;

    @BindView(R.id.rb_electric)
    RadioButton rb_electric;

    @BindView(R.id.rb_hybrid)
    RadioButton rb_hybrid;

    @BindView(R.id.rb_traditional)
    RadioButton rb_traditional;

    @BindView(R.id.btn_vehicle_next)
    Button btn_vehicle_next;

    @BindView(R.id.tvPowerMode)
    TextView tvPowerMode;

    @BindView(R.id.tv_test_result)
    TextView tv_test_result;

    @BindView(R.id.iv_step1)
    ImageView iv_step1;
    @BindView(R.id.tv_step1)
    TextView tv_step1;

    @BindView(R.id.iv_step2)
    ImageView iv_step2;
    @BindView(R.id.tv_step2)
    TextView tv_step2;

    @BindView(R.id.tv_connect_tips)
    TextView tv_connect_tips;

    @BindView(R.id.rl_direct_step)
    RelativeLayout rl_direct_step;
    @BindView(R.id.tv_result)
    TextView tv_result;

    @BindView(R.id.iv_power_status)
    ImageView iv_power_status;

    @BindView(R.id.tv_manual_power)
    TextView tv_manual_power;
    @BindView(R.id.btn_done)
    Button btn_done;

    @OnClick(R.id.btn_connect)
    public void connect() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

    @OnClick(R.id.btn_power_next)
    public void powerNext() {
        Logger.t(TAG).d("powerNext: " + rb_power_cable.isChecked() + " " + rb_direct_wire.isChecked());
        if (rb_power_cable.isChecked()) {
            va_direct.setDisplayedChild(3);
        } else if (rb_direct_wire.isChecked()) {
            if (mCamera != null) {
                checkAccAndVirtual(() -> {
                    va_direct.setDisplayedChild(1);
                    checkPowerOn();
                });
            } else {
                va_direct.setDisplayedChild(1);
                checkPowerOn();
            }
        }
    }

    @OnClick(R.id.btn_vehicle_next)
    public void vehicleNext() {
        Logger.t(TAG).d("vehicleNext: " + rg_vehicle_type.getCheckedRadioButtonId());
        if (rb_electric.isChecked() || rb_hybrid.isChecked()) {
            mCamera.setMountAccTrust(false);
            tv_test_result.setText(highlightText(getString(R.string.camera_sensors_finished), getString(R.string.camera_sensors)));
            va_direct.setDisplayedChild(5);
        } else if (rb_traditional.isChecked()) {
            mCamera.setMountAccTrust(true);
            tv_test_result.setText(highlightText(getString(R.string.power_cable_finished), getString(R.string.power_cable)));
            va_direct.setDisplayedChild(5);
        }
    }

    private SpannableString highlightText(String text, String target) {
        SpannableString spannableString = new SpannableString(text);
        Pattern pattern = Pattern.compile(target);
        Matcher matcher = pattern.matcher(text);

        while (matcher.find()) {
            ForegroundColorSpan span = new ForegroundColorSpan(Color.parseColor("#4A4A4A"));
            spannableString.setSpan(span, matcher.start(), matcher.end(),
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        return spannableString;
    }

    @OnClick(R.id.btn_ok)
    public void ok() {
        setResult(RESULT_OK);
        finish();
    }

    @OnClick(R.id.btn_test_done)
    public void testDone() {
//        int mountAccTrust = mCamera.getMountAccTrust();
//        Logger.t(TAG).d("mountAccTrust: " + mountAccTrust);
        setResult(RESULT_OK);
        finish();
    }

    @OnClick(R.id.btn_start)
    public void startTest() {
        //设置成信任
        mCamera.setMountAccTrust(true);

        step = 1;
        resetUI();
        unSubscribePower();
        va_direct.setDisplayedChild(7);
        checkCameraMode();
    }

    private void resetUI() {
        tv_result.setVisibility(View.GONE);
        btn_done.setVisibility(View.GONE);
        tv_connect_tips.setVisibility(View.GONE);
        rl_direct_step.setVisibility(View.VISIBLE);
        tv_manual_power.setVisibility(View.VISIBLE);

        iv_step1.setImageResource(R.drawable.icon_direct_step1_on);
        iv_step2.setImageResource(R.drawable.icon_direct_step2_off);

        tv_step2.setText(R.string.direct_test_step2);
        tv_step1.setTextColor(Color.parseColor("#344254"));
        tv_step2.setTextColor(Color.parseColor("#D6D9DD"));

        iv_power_status.setImageResource(R.drawable.icon_power_on);

        tv_manual_power.setText(R.string.direct_manual_power_off);
    }

    @OnClick(R.id.tv_install)
    public void install() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_INSTALL);
    }

    @OnClick(R.id.tv_try_again)
    public void tryAgain() {
        va_direct.setDisplayedChild(0);
    }

    @OnClick(R.id.tv_fix_later)
    public void fixLater() {
        mCamera.setMountAccTrust(false);
        setResult(RESULT_OK);
        finish();
    }

    @OnClick(R.id.ll_manual)
    public void manual() {
        unSubscribeState();
        unSubscribeCount();
        va_direct.setDisplayedChild(8);
    }

    @OnClick(R.id.btn_done)
    public void done() {
        setResult(RESULT_OK);
        finish();
    }

    private CameraWrapper mCamera;

    private int step = 0;

    private Disposable cameraPowerSubscribe;
    private Disposable cameraStateSubscribe;
    private Disposable countDownSubscribe;

    private Vibrator vibrator;

    private boolean fromGuide = false;

    public static void launch(Activity activity, boolean guide) {
        Intent intent = new Intent(activity, DirectTestActivity.class);
        intent.putExtra("fromGuide", guide);
        if (guide) {
            activity.startActivityForResult(intent, GUIDE_DIRECT_TEST);
        } else {
            activity.startActivity(intent);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_direct_test);
        ButterKnife.bind(this);
        fromGuide = getIntent().getBooleanExtra("fromGuide", false);

        vibrator = (Vibrator) getSystemService(Service.VIBRATOR_SERVICE);

        setupToolbar();
        initView();

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent);
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                va_direct.setDisplayedChild(0);
                break;
            default:
                break;
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener((View v) -> {
            if (btn_done.getVisibility() == View.VISIBLE) {
                setResult(RESULT_OK);
            }
            int displayedChild = va_direct.getDisplayedChild();
            if (displayedChild == 0 || displayedChild == 1
                    || displayedChild == 2
                    || displayedChild == 5
                    || displayedChild == 7) {
                finish();
            } else {
                va_direct.showPrevious();
            }
        });
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.support_power_cord));
        }
    }

    private void initView() {
        if (NetworkUtils.inHotspotMode()) {
            checkVersion();
        } else {
            va_direct.setDisplayedChild(0);
        }

        rg_power_install.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId != -1) {
                btn_power_next.setBackgroundResource(R.color.colorAccent);
            }
        });

        rg_vehicle_type.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId != -1) {
                btn_vehicle_next.setBackgroundResource(R.color.colorAccent);
            }
        });

        btn_done.setText(Constants.isFleet() && Constants.isManager() ? R.string.forget_password_next : R.string.done);
    }

    private void checkVersion() {
        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            boolean powerCordTestAvailable = mCamera.isPowerCordTestAvailable();
            Logger.t(TAG).e("isPowerCordTestAvailable: " + powerCordTestAvailable);
            if (!powerCordTestAvailable) {
                Toast.makeText(this, R.string.update_firmware, Toast.LENGTH_LONG).show();
                finish();
            } else {
                boolean supportUntrustACCWireAvailable = mCamera.isSupportUntrustACCWireAvailable();
                Logger.t(TAG).e("isSupportUntrustACCWireAvailable: " + supportUntrustACCWireAvailable);
                if (!supportUntrustACCWireAvailable) {
                    va_direct.setDisplayedChild(1);
                    checkPowerOn();
                } else {
                    if (fromGuide) {
                        checkAccAndVirtual(() -> va_direct.setDisplayedChild(2));
                    } else {
                        va_direct.setDisplayedChild(2);
                    }
                }
            }
        } else {
            va_direct.setDisplayedChild(0);
        }
    }

    private void checkAccAndVirtual(Action action) {
        int mountAccTrust = mCamera.getMountAccTrust();
        int virtualIgnition = mCamera.getVirtualIgnition();
        Logger.t(TAG).i("checkAccAndVirtual mountAccTrust: " + mountAccTrust + " virtualIgnition: " + virtualIgnition);
        if (mountAccTrust == 0) {
            tvPowerMode.setText(String.format(getString(R.string.the_camera_is_in_virtual_ignition_mode_so_the_power_test_cannot_be_done), "Trust Acc Off"));
            va_direct.setDisplayedChild(4);
        } else if (virtualIgnition == 1) {
            tvPowerMode.setText(String.format(getString(R.string.the_camera_is_in_virtual_ignition_mode_so_the_power_test_cannot_be_done), "Virtual Ignition"));
            va_direct.setDisplayedChild(4);
        } else {
            try {
                action.run();
            } catch (Exception e) {
                Logger.t(TAG).e("checkAccAndVirtual exception = " + e);
            }
        }
    }

    private void checkPowerOn() {
        cameraPowerSubscribe = mCamera.cameraStatus()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updatePowerState,
                        throwable -> Logger.t(TAG).e("throwable: " + throwable.getMessage()),
                        () -> Logger.t(TAG).e("completed"));
    }

    private void updatePowerState(CameraWrapper camera) {
        int powerState = camera.getPowerState();
        Logger.t(TAG).d("power: " + powerState);
        if (powerState == 1) {
            va_direct.setDisplayedChild(6);
        } else {
            va_direct.setDisplayedChild(1);
        }
    }

    private void checkCameraMode() {
        cameraStateSubscribe = RxBus.getDefault()
                .toObservable(CameraStateChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHandleCameraStateChangeEvent, new ServerErrorHandler());
    }

    private void onHandleCameraStateChangeEvent(CameraStateChangeEvent event) {
        Logger.t(TAG).d("%s", "cameraStateChangeEvent = " + ToStringUtils.getString(event));
        switch (event.getWhat()) {
            case CameraStateChangeEvent.CAMERA_STATE_MONITOR_MODE:
                onMonitorModeChangeEvent((Integer) event.getExtra());
                break;
        }
    }

    private void onMonitorModeChangeEvent(Integer extra) {
        if (extra > VdtCamera.MONITOR_MODE_UNKNOWN) {
            updateCameraState(extra);
        }
    }

    private void updateCameraState(Integer extra) {
        Logger.t(TAG).d("camera state: " + extra + "--step: " + step);

        vibrator.vibrate(300);

        switch (extra) {
            case VdtCamera.MONITOR_MODE_PARK:
                if (step == 1) {
                    step = 2;
                    iv_step1.setImageResource(R.drawable.icon_direct_step1_off);
                    iv_step2.setImageResource(R.drawable.icon_direct_step2_on);

                    tv_step1.setTextColor(Color.parseColor("#D6D9DD"));
                    tv_step2.setTextColor(Color.parseColor("#344254"));

                    boolean supportUntrustACCWireAvailable = mCamera.isSupportUntrustACCWireAvailable();
                    Logger.t(TAG).e("isSupportUntrustACCWireAvailable: " + supportUntrustACCWireAvailable);
                    if (!supportUntrustACCWireAvailable) {
                        tv_connect_tips.setTextColor(Color.parseColor("#99A0A9"));
                        tv_connect_tips.setVisibility(View.VISIBLE);
                        countDown();
                    } else {
                        tv_connect_tips.setVisibility(View.GONE);
                    }

                    iv_power_status.setImageResource(R.drawable.icon_power_off);

                    tv_manual_power.setText(R.string.direct_manual_power_on);
                }
                break;

            case VdtCamera.MONITOR_MODE_DRIVE:
                if (step == 2) {
                    unSubscribeState();
                    unSubscribeCount();
                    rl_direct_step.setVisibility(View.GONE);
                    tv_manual_power.setVisibility(View.GONE);
                    tv_result.setVisibility(View.VISIBLE);
                    btn_done.setVisibility(View.VISIBLE);
                    iv_power_status.setImageResource(R.drawable.icon_power_true);
                }
                break;
        }
    }

    private void countDown() {
        final int time = 30;
        countDownSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    Logger.t(TAG).d("onNext: " + aLong);
                    tv_connect_tips.setText(
                            String.format(getString(R.string.direct_lose_connection), aLong));
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    tv_step2.setText(R.string.direct_test_step2_fail);
                    tv_connect_tips.setText(R.string.direct_step_two);
                    tv_connect_tips.setTextColor(Color.parseColor("#EB5A43"));
                });
    }

    private void unSubscribeCount() {
        if (countDownSubscribe != null && !countDownSubscribe.isDisposed()) {
            countDownSubscribe.dispose();
        }
    }

    private void unSubscribeState() {
        if (cameraStateSubscribe != null && !cameraStateSubscribe.isDisposed()) {
            cameraStateSubscribe.dispose();
        }
    }

    private void unSubscribePower() {
        if (cameraPowerSubscribe != null && !cameraPowerSubscribe.isDisposed()) {
            cameraPowerSubscribe.dispose();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == WIFI_SETTING) {
            checkVersion();
        }
    }
}
