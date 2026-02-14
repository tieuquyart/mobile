package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mk.autosecure.R;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.message.bean.IvlprBean;
import com.mkgroup.camera.message.bean.LicenseBean;
import com.orhanobut.logger.Logger;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class MacActivity extends AppCompatActivity {

    private final static String TAG = MacActivity.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;
    @BindView(R.id.tv_textMAC)
    TextView tv_textMAC;
    @BindView(R.id.listViewLicenses)
    ListView listViewLicenses;
//    @BindView(R.id.ivlprError)
//    TextView ivlprError;

    private EvCamera mCamera;
    private List<LicenseBean.Algorithm> licenseList;
    private LicenseBean LicenseData;
    private IvlprBean Ivlpr;
    private LicenseAdapter licenseAdapter;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, MacActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mac);
        ButterKnife.bind(this);

        setToolbar();
        initView();
    }

    private void setToolbar() {
        ((Toolbar) (findViewById(R.id.toolbar))).setNavigationOnClickListener(v -> finish());
    }

    private void initView() {
        tvToolbarTitle.setText("Cài đặt MAC");
        tv_textMAC.setText("123456");
        Ivlpr = new IvlprBean();

        mCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera == null) {
            Logger.e(TAG, "Camera is null");
            Toast.makeText(this, "Không thể kết nối đến camera", Toast.LENGTH_SHORT).show();
            return;
        }

        LicenseBean response = mCamera.getMAC();
        if (response == null) {
            Logger.e(TAG, "Response từ getMAC() là null");
            Toast.makeText(this, "Dữ liệu license không khả dụng", Toast.LENGTH_SHORT).show();
            return;
        }
        LicenseData = response;
        licenseList = response.getInfo_Algorithm();
        Ivlpr.setValIvlpr("1231232");
        if (licenseList == null || licenseList.isEmpty()) {
            Logger.e(TAG, "Danh sách license rỗng hoặc null");
            Toast.makeText(this, "Không có license hợp lệ", Toast.LENGTH_SHORT).show();
            licenseList = new ArrayList<>();
        }
        tv_textMAC.setText(response.getMacWlan0());
        licenseAdapter = new LicenseAdapter(this, licenseList);
        listViewLicenses.setAdapter(licenseAdapter);

    }


    @SuppressLint("NonConstantResourceId")
    @OnClick(R.id.btnSave33)
    public void onSaveClicked() {
        mCamera.setMAC(LicenseData);
    }
}
