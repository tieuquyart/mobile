package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.activity.DebugMenuActivity;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DebugHelper;

import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * Created by DoanVT on 2017/11/24.
 * Email: doanvt-hn@mk.com.vn
 */

public class VersionCheckActivity extends RxActivity {

    private static final String TAG = VersionCheckActivity.class.getSimpleName();
    private static final int PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE = 0x10;

    private int mClickCount = 10;

    @BindView(R.id.current_version_view)
    TextView mCurrentVersionView;

    @BindView(R.id.debug_menu)
    Button btnDebugMenu;

    @BindView(R.id.camera_server_menu)
    Button btnServerMenu;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @OnClick(R.id.waylens_logo)
    public void onWaylensLogoClicked() {
        mClickCount--;
        if (mClickCount == 0) {
            mClickCount = 10; // 重置标志位
            boolean inDebugMode = DebugHelper.isInDebugMode();
            DebugHelper.setDebugMode(!inDebugMode);
            btnDebugMenu.setVisibility(inDebugMode ? View.GONE : View.VISIBLE);
            if (Constants.isFleet()) {
                btnServerMenu.setVisibility(inDebugMode ? View.GONE : View.VISIBLE);
            }
            //打开debug选项默认开启access_tob_camera, 关闭access_toc_camera
            PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, Constants.isFleet());
            PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, !Constants.isFleet());
        }
    }

    @OnClick(R.id.debug_menu)
    public void onDebugMenuClicked() {
        DebugMenuActivity.launch(this);
    }

    @OnClick(R.id.camera_server_menu)
    public void onServerMenuClicked() {
        CameraServerActivity.launch(this);
    }

    @OnClick(R.id.tv_terms)
    public void onTermsClick() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_TERMS_OF_USE);
    }

    @OnClick(R.id.tv_privacy)
    public void onPrivacyClick() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_PRIVACY);
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, VersionCheckActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        init();
    }

    protected void init() {
        initViews();
    }

    @SuppressLint("SetTextI18n")
    private void initViews() {
        setContentView(R.layout.activity_version);
        ButterKnife.bind(this);
        setupToolbar();
        mCurrentVersionView.setText("v"+ BuildConfig.VERSION_NAME + " - "+
                BuildConfig.VERSION_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode) {
            case PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE:
                break;
            default:
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    private void setupToolbar() {
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            TextView textView = (TextView) toolbar.findViewById(R.id.tv_toolbarTitle);
            if (textView != null) {
                textView.setText(R.string.setting_item_about);
            }
            toolbar.setNavigationOnClickListener(v -> finish());
        }
    }
}
