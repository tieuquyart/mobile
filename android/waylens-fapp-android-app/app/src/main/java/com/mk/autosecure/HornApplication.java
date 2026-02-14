package com.mk.autosecure;

import static com.mk.autosecure.libs.utils.Constants.KEY_SHOW_UPDATE;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_FAILURE;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_START;
import static com.mkgroup.camera.event.SettingChangeEvent.ACTION_SUCCESS;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.multidex.MultiDexApplication;

import com.alibaba.android.arouter.launcher.ARouter;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;
import com.hjq.toast.ToastUtils;
import com.mk.autosecure.eid.UserPreference;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.AppLastVersionBean;
import com.mk.autosecure.ui.DialogHelper;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.AndroidLogAdapter;
import com.orhanobut.logger.DiskLogAdapter;
import com.orhanobut.logger.FormatStrategy;
import com.orhanobut.logger.Logger;
import com.orhanobut.logger.PrettyFormatStrategy;
import com.tencent.mmkv.MMKV;
import com.mkgroup.camera.connectivity.CameraConnectivityManager;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.event.SettingChangeEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.log.CustomCsvFormatStrategy;

import java.util.concurrent.TimeUnit;

import cn.jpush.android.api.JPushInterface;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;


/**
 * Created by DoanVT on 2017/7/24.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
public class HornApplication extends MultiDexApplication implements OnMapsSdkInitializedCallback {

    private static final String TAG = "HornApplication";
    private static Context mAppContext = null;
    private static AppComponent mComponent;

    private static Disposable pollMsgStatusSub;
    private static String settingResult;

    private static int mActivityCount = 0;

    private WifiDirectConnection directConnection;

    private CameraConnectivityManager connectivityManager;

    private Activity activeActivity;

    @Override
    @CallSuper
    public void onCreate() {
        super.onCreate();

        if (BuildConfig.DEBUG) {
            ARouter.openLog();
            ARouter.openDebug();
        }
        ARouter.init(this);
        initKV();
        initToast();
        JPushInterface.setDebugMode(true);
        JPushInterface.init(this);
        UserPreference.init(this);
        mAppContext = getApplicationContext();
        mComponent = DaggerAppComponent.builder()
                .applicationModule(new ApplicationModule(this))
                .build();

        initLogger();
        registerActivityLifecycleCallbacks(lifecycleCallbacks);
        MapsInitializer.initialize(getApplicationContext(), MapsInitializer.Renderer.LATEST, this);
    }

    private void initKV() {
        MMKV.initialize(this);
    }

    private void initToast() {
        ToastUtils.init(this);
    }

    private void initLogger() {
        FormatStrategy formatStrategy = PrettyFormatStrategy
                .newBuilder()
                .showThreadInfo(false)
                .methodCount(1)
                .tag(TAG)
                .build();

        Logger.addLogAdapter(new AndroidLogAdapter(formatStrategy));

        FormatStrategy diskFormatStrategy = CustomCsvFormatStrategy
                .newBuilder()
                .build();

        Logger.addLogAdapter(new DiskLogAdapter(diskFormatStrategy));
    }

    public Activity getActiveActivity() {
        return activeActivity;
    }

    public boolean isInUnitTests() {
        return false;
    }

    public static void checkSettingUpdated() {
        pollMsgStatusSub = Observable.interval(0, 1000, TimeUnit.MILLISECONDS)
                .take(60)
                .observeOn(Schedulers.io())
                .subscribe(aLong -> {
                    String string = settingResult;
                    Logger.t(TAG).d("query push notification：" + aLong + "--" + string);
                    if (aLong == 59) {
                        queryUpdated(true, string);
                    } else {
                        queryUpdated(false, string);
                    }
                });
    }

    private static void queryUpdated(boolean end, String string) {
        switch (string) {
            case ACTION_START:
                if (end) {
                    RxBus.getDefault().post(new SettingChangeEvent(ACTION_FAILURE, false));
                    settingResult = ACTION_FAILURE;
                    unsubscribeMsgStatus();
                }
                break;
            case ACTION_FAILURE:
                RxBus.getDefault().post(new SettingChangeEvent(ACTION_FAILURE, false));
                settingResult = ACTION_FAILURE;
                unsubscribeMsgStatus();
                break;
            case ACTION_SUCCESS:
                RxBus.getDefault().post(new SettingChangeEvent(ACTION_SUCCESS, true));
                settingResult = ACTION_SUCCESS;
                unsubscribeMsgStatus();
                break;
        }
    }

    private static void unsubscribeMsgStatus() {
        if (pollMsgStatusSub != null && !pollMsgStatusSub.isDisposed()) {
            pollMsgStatusSub.dispose();
            pollMsgStatusSub = null;
        }
    }

    public static String getSettingResult() {
        return settingResult;
    }

    public static void setSettingResult(String result) {
        settingResult = result;
    }

    public static Context getContext() {
        return mAppContext;
    }

    public static AppComponent getComponent() {
        return mComponent;
    }

    public static boolean isForeground() {
        return mActivityCount > 0;
    }

    ActivityLifecycleCallbacks lifecycleCallbacks = new ActivityLifecycleCallbacks() {
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            Logger.t(TAG).d("onActivityCreated");
        }

        @Override
        public void onActivityStarted(Activity activity) {
            mActivityCount++;
            Logger.t(TAG).d("onActivityStarted: " + mActivityCount);

            if (directConnection == null) {
                directConnection = WifiDirectConnection.getInstance();
                directConnection.registerP2PReceiver();
            }
            if (connectivityManager == null) {
                connectivityManager = CameraConnectivityManager.getManager();
                connectivityManager.startSearchCamera();
            }
        }

        @Override
        public void onActivityResumed(Activity activity) {
            Logger.t(TAG).d("onActivityResumed");
            activeActivity = activity;
        }

        @Override
        public void onActivityPaused(Activity activity) {
            activeActivity = null;
            Logger.t(TAG).d("onActivityPaused");
        }

        @Override
        public void onActivityStopped(Activity activity) {
            mActivityCount--;
            Logger.t(TAG).d("onActivityStopped: " + mActivityCount);

            if (!isForeground() && directConnection != null) {
                directConnection.unregisterP2PReceiver();
                directConnection = null;
            }
            if (!isForeground() && connectivityManager != null) {
                connectivityManager.stopSearchCamera();
                connectivityManager = null;
            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
            Logger.t(TAG).d("onActivitySaveInstanceState");
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            Logger.t(TAG).d("onActivityDestroyed");
            Runtime.getRuntime().gc();
        }
    };

    @Override
    public void onMapsSdkInitialized(@NonNull MapsInitializer.Renderer renderer) {
        switch (renderer) {
            case LATEST:
                Logger.t(TAG).d("MapsDemo", "The latest version of the renderer is used.");
                break;
            case LEGACY:
                Logger.t(TAG).d("MapsDemo", "The legacy version of the renderer is used.");
                break;
        }
    }
}
