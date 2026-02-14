package com.mk.autosecure.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Switch;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.CreateInstallerBody;
import com.mk.autosecure.rest_fleet.response.InstallerResponse;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

import static com.mkgroup.camera.preference.PreferenceUtils.FLEET_SERVER_URL;
import static com.mkgroup.camera.preference.PreferenceUtils.SERVER_URL;

/**
 * Created by DoanVT on 2017/8/9.
 */


public class DebugMenuActivity extends RxActivity {
    public static final String TAG = DebugMenuActivity.class.getSimpleName();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, DebugMenuActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.host_server_group)
    RadioGroup hostServerGroup;

    @BindView(R.id.ll_web_server)
    LinearLayout llWebServer;

    @BindView(R.id.server_debug)
    RadioButton server_debug;

    @BindView(R.id.server_release)
    RadioButton server_release;

    @BindView(R.id.web_server_group)
    RadioGroup webServerGroup;

    @BindView(R.id.switch_accessToB)
    Switch switchAccessToB;

    @BindView(R.id.switch_accessToC)
    Switch switchAccessToC;

    @BindView(R.id.switch_voiceTest)
    Switch switchVoiceTest;

    @BindView(R.id.switch_showAllCamera)
    Switch switchShowAllCamera;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_firebase_token)
    TextView tvFirebaseToken;

    @BindView(R.id.ll_signup_installer)
    LinearLayout llSignupInstaller;

    @BindView(R.id.et_password)
    EditText etPassword;

    @BindView(R.id.et_email)
    EditText etEmail;

    @BindView(R.id.btn_create_installer)
    Button btnCreateInstaller;

    @BindView(R.id.btn_crash)
    Button btnCrash;

    @BindArray(R.array.host_server_list)
    String[] serverList;

    @BindArray(R.array.host_server_list_fleet)
    String[] serverListFleet;

    @BindArray(R.array.web_url_list)
    String[] webServerList;

    @BindView(R.id.direct_switch)
    Switch direct_switch;

    private boolean isChangeForUser = true;

    private int serverIndex = -1;

    private List<RadioButton> buttonList;

    private String[] currentServerList;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();
    }

    private void initViews() {
        setContentView(R.layout.activity_debug_menu);
        ButterKnife.bind(this);
        setupToolbar();

        buttonList = new ArrayList<>();

        if (Constants.isFleet()) {
            llWebServer.setVisibility(View.GONE);
            if (Constants.isManager()) {
                llSignupInstaller.setVisibility(View.VISIBLE);
            }
            currentServerList = serverListFleet;
        } else {
            currentServerList = serverList;
        }
        serverIndex = currentServerList.length - 1;

        createRadionButton(currentServerList);

        String server = PreferenceUtils.getString(Constants.isFleet() ? FLEET_SERVER_URL : SERVER_URL, currentServerList[serverIndex]);
        Logger.t(TAG).d("current server: " + server);
        judgeServer(server);

        String url = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServerList[1]);
        judgeWeb(url);

        hostServerGroup.setOnCheckedChangeListener((radioGroup, i) -> {
            if (isChangeForUser) {
                for (RadioButton button : buttonList) {
                    if (button.getId() == i) {
                        showAlertDialog(buttonList.indexOf(button), true);
                    }
                }
            } else {
                isChangeForUser = true;
            }
        });

        webServerGroup.setOnCheckedChangeListener((group, checkedId) -> {
            if (isChangeForUser) {
                int index = 1;
                switch (group.getCheckedRadioButtonId()) {
                    case R.id.server_debug:
                        index = 0;
                        break;
                    case R.id.server_release:
                        index = 1;
                        break;
                    default:
                        break;
                }
                showAlertDialog(index, false);
            } else {
                isChangeForUser = true;
            }
        });

        direct_switch.setChecked(PreferenceUtils.getBoolean(PreferenceUtils.KEY_WIFI_DIRECT_SETUP, true));

        direct_switch.setOnCheckedChangeListener((buttonView, isChecked) -> PreferenceUtils.putBoolean(PreferenceUtils.KEY_WIFI_DIRECT_SETUP, isChecked));

        switchAccessToB.setChecked(PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, Constants.isFleet()));

        switchAccessToB.setOnCheckedChangeListener((buttonView, isChecked) -> PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, isChecked));

        switchAccessToC.setChecked(PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, !Constants.isFleet()));

        switchAccessToC.setOnCheckedChangeListener((buttonView, isChecked) -> PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, isChecked));

        switchVoiceTest.setChecked(PreferenceUtils.getBoolean(PreferenceUtils.VOICE_CALL_TEST, Constants.isFleet()));

        switchVoiceTest.setOnCheckedChangeListener((buttonView, isChecked) -> PreferenceUtils.putBoolean(PreferenceUtils.VOICE_CALL_TEST, isChecked));

        switchShowAllCamera.setChecked(PreferenceUtils.getBoolean(PreferenceUtils.KEY_SHOW_ALL_CAMERAS, false));

        switchShowAllCamera.setOnCheckedChangeListener((buttonView, isChecked) -> PreferenceUtils.putBoolean(PreferenceUtils.KEY_SHOW_ALL_CAMERAS, isChecked));

        tvFirebaseToken.setText(PreferenceUtils.getString(PreferenceUtils.SEND_FCM_TOKEN_SERVER, ""));

        btnCreateInstaller.setOnClickListener(v -> {
            String password = etPassword.getText().toString().trim();
            String email = etEmail.getText().toString().trim();

            if (TextUtils.isEmpty(password) || TextUtils.isEmpty(email)) {
                Toast.makeText(DebugMenuActivity.this, "Someone is empty!", Toast.LENGTH_SHORT).show();
                return;
            }

            CreateInstallerBody body = new CreateInstallerBody("username", password, email);
            ApiClient.createApiService().createInstaller(body)
                    .subscribeOn(Schedulers.newThread())
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new BaseObserver<InstallerResponse>() {
                        @Override
                        protected void onHandleSuccess(InstallerResponse data) {
                            Logger.t(TAG).d("onHandleSuccess: " + data);
                            Toast.makeText(DebugMenuActivity.this, "Success", Toast.LENGTH_SHORT).show();
                        }
                    });
        });

        btnCrash.setOnClickListener(v -> {
            throw new RuntimeException("debug switch server crash");
        });
    }

    private void showAlertDialog(int index, boolean isHost) {
        DialogHelper.showSwtichServerDialog(this, () -> {
            if (isHost) {
                serverIndex = index;
                PreferenceUtils.putString(Constants.isFleet() ? FLEET_SERVER_URL : SERVER_URL, currentServerList[index]);
            } else {
                PreferenceUtils.putString(PreferenceUtils.WEB_URL, webServerList[index]);
            }
            HornApplication.getComponent().currentUser().logout(); //退出登录
            throw new RuntimeException("debug switch server crash"); //重新实例化apiservice，不然取到的还是切换前的baseUrl
        }, () -> {
            isChangeForUser = false;
            if (isHost) {
                judgeServer(PreferenceUtils.getString(Constants.isFleet() ? FLEET_SERVER_URL : SERVER_URL, currentServerList[serverIndex]));
            } else {
                judgeWeb(PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServerList[1]));
            }
        });
    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    private void judgeServer(String server) {
        if (!TextUtils.isEmpty(server)) {
            for (int i = 0; i < currentServerList.length; i++) {
                String s = currentServerList[i];
                if (s.equals(server)) {
                    serverIndex = i;
                    break;
                }
            }
        }
        buttonList.get(serverIndex).setChecked(true);
    }

    private void createRadionButton(String[] strings) {
        for (String server : strings) {
            RadioButton button = new RadioButton(this);
            button.setText(server);
            buttonList.add(button);
            hostServerGroup.addView(button);
        }
    }

    private void judgeWeb(String url) {
        if (!TextUtils.isEmpty(url)) {
            if (url.equals(webServerList[0])) {
                server_debug.setChecked(true);
            } else if (url.equals(webServerList[1])) {
                server_release.setChecked(true);
            }
        } else {
            server_release.setChecked(true);
        }
    }

}
