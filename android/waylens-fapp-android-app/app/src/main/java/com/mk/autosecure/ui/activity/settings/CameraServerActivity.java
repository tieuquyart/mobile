package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.DialogHelper;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;

public class CameraServerActivity extends AppCompatActivity {

    public static final String TAG = CameraServerActivity.class.getSimpleName();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, CameraServerActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.rg_server)
    RadioGroup rgServer;

    @BindView(R.id.tv_otherServer)
    TextView tvOtherServe;

    @BindArray(R.array.camera_server_list)
    String[] serverList;

    @BindArray(R.array.camera_server_list_fleet)
    String[] serverListFleet;

    private CameraWrapper mCamera;

    private int serverIndex = -1;

    private boolean isChangeForUser = true;

    private List<RadioButton> buttonList;

    private String[] currentServerList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_camera_server);
        ButterKnife.bind(this);

        initViews();
    }

    private void initViews() {
        setupToolbar();

        buttonList = new ArrayList<>();

        if (Constants.isFleet()) {
            currentServerList = serverListFleet;
        } else {
            currentServerList = serverList;
        }

        createRadionButton(currentServerList);

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            String cameraServer = mCamera.getCameraServer();
            Logger.t(TAG).d("cameraServer: " + cameraServer);
            setServer(cameraServer);
        }

        rgServer.setOnCheckedChangeListener((group, checkedId) -> {
            if (isChangeForUser) {
                for (RadioButton button : buttonList) {
                    if (button.getId() == checkedId) {
                        showAlertDialog(buttonList.indexOf(button));
                    }
                }
            } else {
                isChangeForUser = true;
            }
        });
    }

    private void showAlertDialog(int index) {
        DialogHelper.showSwitchCameraServerDialog(this, () -> {
            serverIndex = index;
            if (tvOtherServe.getVisibility() == View.VISIBLE) {
                tvOtherServe.setVisibility(View.GONE);
            }
            if (mCamera != null) {
                Logger.t(TAG).d("setCameraServer: " + currentServerList[index]);
                mCamera.setCameraServer(currentServerList[index]);
            }
        }, () -> {
            isChangeForUser = false;
            if (serverIndex == -1) {
                rgServer.clearCheck();
            } else {
                setServer(currentServerList[serverIndex]);
            }
        });
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    private void createRadionButton(String[] strings) {
        for (String server : strings) {
            RadioButton button = new RadioButton(this);
            button.setText(server);
            buttonList.add(button);
            rgServer.addView(button);
        }
    }

    private void setServer(String server) {
        if (!TextUtils.isEmpty(server)) {
            for (int i = 0; i < currentServerList.length; i++) {
                String s = currentServerList[i];
                if (s.equals(server)) {
                    serverIndex = i;
                    break;
                }
            }
        }

        if (serverIndex == -1) {
            tvOtherServe.setVisibility(View.VISIBLE);
            tvOtherServe.setText(server);
        } else {
            tvOtherServe.setVisibility(View.GONE);
            buttonList.get(serverIndex).setChecked(true);
        }
    }

}
