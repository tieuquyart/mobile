package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.R;
import com.mk.autosecure.ui.activity.DevicesActivity;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.message.bean.ExboardBean;
import com.orhanobut.logger.Logger;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class ExboardActivity extends AppCompatActivity {

    private final static String TAG = ExboardActivity.class.getSimpleName();
    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;
    @BindView(R.id.tv_textPort)
    TextView tv_textPort;
    @BindView(R.id.tv_textFW_Version)
    TextView tv_textFW_Version;
    private EvCamera mCamera;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, ExboardActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_exboard);
        ButterKnife.bind(this);

        setToolbar();
        initView();
    }

    private void setToolbar() {
        ((Toolbar) (findViewById(R.id.toolbar))).setNavigationOnClickListener(v -> finish());
    }

    private void initView() {
        tvToolbarTitle.setText("Cài đặt ExBoard");
        mCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            ExboardBean response = mCamera.getStatusExboard();
            Logger.t(TAG).d("get Response: " + response);

            if (response != null) {
                tv_textPort.setText(response.getPortUSB() != null ? response.getPortUSB() : "null");
                tv_textFW_Version.setText(response.getVersionEX() != null ? response.getVersionEX() : "null");
            } else {
                tv_textPort.setText("null");
                tv_textFW_Version.setText("null");
            }
        } else {
            tv_textPort.setText("null");
            tv_textFW_Version.setText("null");
        }
    }



    @OnClick(R.id.ll_set_Exboard)
    public void onExboard() {
        if (mCamera != null && mCamera instanceof EvCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);

            ExboardBean curExboard = ((EvCamera) mCamera).getStatusExboard();
            int index = 0;

            String[] displayItems = new String[]{
                    "Cmd_getversion", "Cmd_IRcut_on", "Cmd_IRcut_off", "Cmd_Battery_voltage",
                    "Cmd_debug"
            };

            String[] valueItems = new String[]{
                    "{\"mode\":1}",
                    "{\"mode\":2}",
                    "{\"mode\":3}",
                    "{\"mode\":4}",
                    "{\"mode\":5}",
            };

            for (int i = 0; i < valueItems.length; i++) {
//                if (curExboard.mode.equals(valueItems[i])) {
//                    index = i;
//                }
            }

            builder.setSingleChoiceItems(displayItems, index, (dialog, which) -> {
                ((EvCamera) mCamera).setStatusExboard(valueItems[which]);
                dialog.dismiss();
            });

            builder.show();

        } else {
            Logger.t(TAG).d("ERR: onExboard " );
        }
    }


}
