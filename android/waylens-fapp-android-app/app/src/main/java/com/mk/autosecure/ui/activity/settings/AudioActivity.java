package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.RelativeLayout;
import android.widget.Switch;

import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.event.AudioPromptsChangeEvent;
import com.mkgroup.camera.event.MicrophoneChangeEvent;
import com.mkgroup.camera.event.MountSettingChangeEvent;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;

import org.json.JSONException;
import org.json.JSONObject;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class AudioActivity extends RxActivity {

    private final static String TAG = AudioActivity.class.getSimpleName();

    public static final int AUDIO_SETTING = 0x01;

    @BindView(R.id.switch_microphone)
    Switch switchMicrophone;

    @BindView(R.id.switch_siren)
    Switch switchSiren;

    @BindView(R.id.switch_audioPrompts)
    Switch switchAudioPrompts;

    @BindView(R.id.rl_microphone)
    RelativeLayout rl_microphone;

    @BindView(R.id.rl_audioPrompts)
    RelativeLayout rl_audioPrompts;

    private String sn;

    private CameraWrapper mCamera;

    private CameraBean mCameraBean;

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, AudioActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CameraBean cameraBean) {
        Intent intent = new Intent(activity, AudioActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        activity.startActivityForResult(intent, AUDIO_SETTING);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_audio);
        ButterKnife.bind(this);
        setToolbar();

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
        if (!TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }

        if (mCamera != null && !mCamera.isAudioPromptsAvailable()) {
            rl_audioPrompts.setVisibility(View.GONE);
        }

        if (mCamera != null) {
            MountSetting mountSetting = mCamera.getMountSettings(true);
            switchMicrophone.setChecked(mCamera.isMicEnabled());
            switchAudioPrompts.setChecked(mCamera.isPromptsEnabled());
            switchSiren.setChecked(MountSetting.isOn(mountSetting.siren));
        } else if (mCameraBean != null && mCameraBean.settings != null) {
            switchSiren.setChecked("on".equals(mCameraBean.settings.siren));
            rl_microphone.setBackgroundResource(R.color.colorUnsetting);
            rl_audioPrompts.setBackgroundResource(R.color.colorUnsetting);
            switchMicrophone.setOnClickListener(v -> Toast.makeText(AudioActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show());
            switchAudioPrompts.setOnClickListener(v -> Toast.makeText(AudioActivity.this, R.string.setting_request, Toast.LENGTH_SHORT).show());
        }

        switchMicrophone.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (mCamera != null) {
                    mCamera.setMicEnabled(isChecked);
                } else {
                    switchMicrophone.setChecked(!isChecked);
                }
            }
        });

        switchSiren.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                setCameraMountSetting(MountSetting.KEY_SIREN, isChecked);
            }
        });

        switchAudioPrompts.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (mCamera != null) {
                mCamera.setAudioPromptsEnabled(isChecked);
            } else {
                switchAudioPrompts.setChecked(!isChecked);
            }
        });

        RxBus.getDefault()
                .toObservable(MicrophoneChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMicphoneModeChangeEvent, new ServerErrorHandler());

        RxBus.getDefault()
                .toObservable(AudioPromptsChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAudioPromptsChangeEvent, new ServerErrorHandler());

        RxBus.getDefault()
                .toObservable(MountSettingChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onMountSettingChangeEvent, new ServerErrorHandler());
    }

    private void onMicphoneModeChangeEvent(MicrophoneChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int microMode = event.getMicroMode();
            switchMicrophone.setChecked(microMode == VdtCamera.STATE_MIC_ON);
        }
    }

    private void onAudioPromptsChangeEvent(AudioPromptsChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int promptsMode = event.getPromptsMode();
            switchAudioPrompts.setChecked(promptsMode == VdtCamera.AUDIO_PROMPTS_MODE_ON);
        }
    }

    private void onMountSettingChangeEvent(MountSettingChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            MountSetting mountSetting = event.getMountSetting();
            switchSiren.setChecked(MountSetting.isOn(mountSetting.siren));
        }
    }

    private void setToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> {
            if (mCameraBean != null) {
                Bundle bundle = new Bundle();
                bundle.putString("siren", switchSiren.isChecked() ? "on" : "off");
                setResult(AUDIO_SETTING, AudioActivity.this.getIntent().putExtras(bundle));
            }
            finish();
        });
    }

    private void setCameraMountSetting(String item, boolean enable) {
        try {
            if (mCamera != null) {
                JSONObject setting = new JSONObject();
                setting.put(item, MountSetting.getValueString(enable));
                Logger.t(TAG).d("setting = %s", setting.toString());
                mCamera.setMountSettings(setting.toString());
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {
        if (mCameraBean != null) {
            Bundle bundle = new Bundle();
            bundle.putString("siren", switchSiren.isChecked() ? "on" : "off");
            setResult(AUDIO_SETTING, this.getIntent().putExtras(bundle));
        }
        finish();
    }
}
