package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.R;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.message.bean.MacBean;
import com.mkgroup.camera.message.bean.SradarBean;
import com.orhanobut.logger.Logger;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class SradarActivity extends AppCompatActivity {

    private final static String TAG = SradarActivity.class.getSimpleName();
    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;
    @BindView(R.id.tv_textSRadar)
    TextView tv_textSRadar;
    @BindView(R.id.tv_Detection_Type)
    TextView tv_Detection_Type;
    private EvCamera mCamera;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SradarActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sradar);
        ButterKnife.bind(this);

        setToolbar();
        initView();
    }

    private void setToolbar() {
        ((Toolbar) (findViewById(R.id.toolbar))).setNavigationOnClickListener(v -> finish());
    }

    private void initView() {
        tvToolbarTitle.setText("Cài đặt Sradar");
        mCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            SradarBean response = mCamera.getStatusSradar();
            Logger.t(TAG).d("get Response: " + response.getDetectionType());
//            Logger.t(TAG).d("getMAC macBean: " + response);
            tv_textSRadar.setText(response.getstatusConnect());
            tv_Detection_Type.setText(response.getDetectionType());
        }
    }


}
