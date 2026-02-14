package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.R;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

@Route(path = "/ui/activity/settings/SelectCameraActvity")
public class SelectCameraActvity extends AppCompatActivity {

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.rg_select_camera)
    RadioGroup rgSelectCamera;

    @BindView(R.id.rb_camera_normal)
    RadioButton rbCameraNormal;

    @BindView(R.id.rb_camera_es)
    RadioButton rbCameraEs;

    public static void launch(Activity activity, int requestCode) {
        Intent intent = new Intent(activity, SelectCameraActvity.class);
        activity.startActivityForResult(intent, requestCode);
    }

    @OnClick(R.id.btn_select_next)
    public void selectNext() {
        Intent data = new Intent();
        if (isSecureES) {
            data.putExtra("camera", "SecureES");
        } else {
            data.putExtra("camera", "Secure360");
        }
        setResult(RESULT_OK, data);
        finish();
    }

    private boolean isSecureES = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ARouter.getInstance().inject(this);
        setContentView(R.layout.activity_select_camera);
        ButterKnife.bind(this);

        setupToolbar();
        initView();
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.support_network_test));
        }
    }

    private void initView() {
        rgSelectCamera.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == rbCameraNormal.getId()) {
                isSecureES = false;
            } else if (checkedId == rbCameraEs.getId()) {
                isSecureES = true;
            }

            rbCameraEs.setTextColor(isSecureES ?
                    getResources().getColor(R.color.colorAccent) : getResources().getColor(R.color.colorPrimary));
            rbCameraNormal.setTextColor(isSecureES ?
                    getResources().getColor(R.color.colorPrimary) : getResources().getColor(R.color.colorAccent));
        });
        rgSelectCamera.check(rbCameraNormal.getId());
    }
}