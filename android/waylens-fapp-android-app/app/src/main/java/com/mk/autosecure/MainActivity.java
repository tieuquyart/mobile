package com.mk.autosecure;

import static com.mk.autosecure.libs.utils.Constants.KEY_SHOW_UPDATE;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSIONS_REQUESTCODE;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.PermissionChecker;

import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.AppLastVersionBean;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.Logger;

import io.reactivex.schedulers.Schedulers;

/**
 * modified by DoanVT 08/10/2022
 */

public class MainActivity extends AppCompatActivity {
    public static final String TAG = MainActivity.class.getSimpleName();

    public static final String KEY_HAS_TRANS = "KEY_HAS_TRANS";
    public static final String KEY_NOTI_ID = "notificationId";
    public static String notificationID = "";

    private boolean mNeedDelay = true;
    private boolean isFirstUse;
    private AppComponent component;
    private Handler handler;

    private boolean mShowMessage = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Logger.t(TAG).e("isTaskRoot: " + isTaskRoot());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PermissionChecker.PERMISSION_GRANTED) {

                requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, PERMISSIONS_REQUESTCODE);


            }else{
                if (!isTaskRoot()) {
                    Intent intent = getIntent();
                    if (intent != null) {
                        String action = intent.getAction();
                        Logger.t(TAG).d("action: " + action);
                        boolean hasCategory = intent.hasCategory("android.intent.category.LAUNCHER");
                        Logger.t(TAG).d("hasCategory: " + hasCategory);
                        if (hasCategory && Intent.ACTION_MAIN.equals(action)) {
                            finish();
                            return;
                        }
                    }
                }

                init();
            }
        } else {
            if (!isTaskRoot()) {
                Intent intent = getIntent();
                if (intent != null) {
                    String action = intent.getAction();
                    Logger.t(TAG).d("action: " + action);
                    boolean hasCategory = intent.hasCategory(Intent.CATEGORY_LAUNCHER);
                    Logger.t(TAG).d("hasCategory: " + hasCategory);
                    if (hasCategory && Intent.ACTION_MAIN.equals(action)) {
                        finish();
                        return;
                    }
                }
            }

            init();
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSIONS_REQUESTCODE) {
            if (grantResults.length > 0 &&
                    grantResults[0] == PermissionChecker.PERMISSION_GRANTED) {

                if (!isTaskRoot()) {
                    Intent intent = getIntent();
                    if (intent != null) {
                        String action = intent.getAction();
                        Logger.t(TAG).d("action: " + action);
                        boolean hasCategory = intent.hasCategory(Intent.CATEGORY_LAUNCHER);
                        Logger.t(TAG).d("hasCategory: " + hasCategory);
                        if (hasCategory && Intent.ACTION_MAIN.equals(action)) {
                            finish();
                            return;
                        }
                    }
                }

                init();
            }else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
                if (PermissionChecker.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PermissionChecker.PERMISSION_GRANTED) {
                    requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, PERMISSIONS_REQUESTCODE);
                }
            }
        }
    }

    /**
     * init component
     * first_use
     * handler
     */
    protected void init() {
        handler = new Handler();
        initViews();
        component = HornApplication.getComponent();
        isFirstUse = PreferenceUtils.getBoolean(PreferenceUtils.KEY_FIRST_USE, true);
        if (isFirstUse) {
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_FIRST_USE, false);
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    /**
     * initView, setContentView, visible logo with Fleet, setColor status bar
     */
    @SuppressLint("ObsoleteSdkInt")
    private void initViews() {
        setContentView(R.layout.activity_main);

        ImageView ivLogo = findViewById(R.id.icon_logo);
        ImageView ivLogoFleet = findViewById(R.id.icon_logo_fleet);

        if (Constants.isFleet()) {
            ivLogoFleet.setVisibility(View.VISIBLE);
        } else {
            ivLogo.setVisibility(View.VISIBLE);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(getResources().getColor(R.color.colorPrimaryDark));
        }
        if (mNeedDelay) {
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    redirectTo();
                }
            }, 2000);
        } else {
            redirectTo();
        }
    }

    private boolean hasBigChange() {
        int newVersionCode;

        try {
            PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(), 0);
            newVersionCode = pi.versionCode;
            return newVersionCode % 10 == 0;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * check have Transaction
     */
    private boolean haveTransaction(Intent intent) {
        boolean hasTrans = false;

        if (intent != null) hasTrans = intent.getBooleanExtra(KEY_HAS_TRANS, false);

        return hasTrans;
    }

    /**
     * redirect to LocalLiveActivity
     */
    private void redirectTo() {
        PreferenceUtils.putBoolean(KEY_SHOW_UPDATE, false);
        if (Constants.isFleet()) {

            Bundle b = getIntent().getExtras();
            if (b != null) {
                String someData = b.getString("notificationId");
                Logger.t(TAG).d("onMessagePush: " + someData);
                if (!TextUtils.isEmpty(someData)) {
                    LocalLiveActivity.notificationID = someData;
                    Constants.has_push_notification = true;
                } else {
                    Constants.has_push_notification = false;
                }
            } else {
            }
            Logger.t(TAG).d("HaveTransaction: " + Constants.has_push_notification);
            LocalLiveActivity.launchOrShow(this);
            finish();
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        handler.removeCallbacksAndMessages(null);
    }
}
