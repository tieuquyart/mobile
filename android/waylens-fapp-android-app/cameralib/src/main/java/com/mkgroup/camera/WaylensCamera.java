package com.mkgroup.camera;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;

import com.orhanobut.logger.AndroidLogAdapter;
import com.orhanobut.logger.DiskLogAdapter;
import com.orhanobut.logger.FormatStrategy;
import com.orhanobut.logger.Logger;
import com.orhanobut.logger.PrettyFormatStrategy;
import com.mkgroup.camera.db.DaoMaster;
import com.mkgroup.camera.db.DaoSession;
import com.mkgroup.camera.db.MySQLiteOpenHelper;
import com.mkgroup.camera.db.VideoItemDao;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.NetworkService;
import com.mkgroup.camera.utils.CustomCsvFormatStrategy;
import com.mkgroup.camera.utils.PackageUtils;

import io.reactivex.plugins.RxJavaPlugins;

/**
 * Created by cloud on 2020/11/15.
 */
public class WaylensCamera {

    private final static String TAG = WaylensCamera.class.getSimpleName();

    private static final Object object = new Object();
    private final Context mContext;
    private static volatile WaylensCamera instance;
    private DaoMaster mDaoMaster;
    private DaoSession mDaoSession;
    private static int mActivityCount = 0;
//    private WifiDirectConnection directConnection;

    public Context getApplicationContext() {
        return mContext;
    }

    private WaylensCamera(Context applicationContext) {
        this.mContext = applicationContext;
        RxJavaPlugins.setErrorHandler(throwable -> Logger.t(TAG).d("errorHandler: " + throwable.getMessage()));

        initLogger(applicationContext);
        PreferenceUtils.initialize(mContext);
        initGreenDao();
        requestMobileData();
        // 监听前后台
        ((Application) mContext).registerActivityLifecycleCallbacks(lifecycleCallbacks);

        boolean firstInstall = PackageUtils.isFirstInstall(mContext);
        Logger.t(TAG).e("firstInstall: " + firstInstall);
        if (firstInstall) {
            PreferenceUtils.putBoolean(PreferenceUtils.SYNC_VIDEO_DB, false);
            PreferenceUtils.putBoolean(PreferenceUtils.ENCRYPT_SP, false);

            //创建表
            VideoItemDao.createTable(mDaoMaster.getDatabase(), true);
        }
    }

    public void requestMobileData() {
//        Logger.t(TAG).d("requestMobileData");
        new Handler().post(() -> {
            try {
                NetworkService.requestByMobileData();
//                ApiService.bindNetworkToWiFi(HornApplication.this);
            } catch (Exception ex) {
                Logger.t(TAG).d("requestMobileData error: " + ex.getMessage());
            }
        });
    }

    private void initGreenDao() {
        MySQLiteOpenHelper helper = new MySQLiteOpenHelper(mContext, "camera.db", null);
        SQLiteDatabase database = helper.getWritableDatabase();
        mDaoMaster = new DaoMaster(database);
        mDaoSession = mDaoMaster.newSession();
    }

    public DaoSession getDaoSession() {
        return mDaoSession;
    }

    private void initLogger(Context context) {
        FormatStrategy formatStrategy = PrettyFormatStrategy
                .newBuilder()
                .showThreadInfo(false)
                .methodCount(1)
                .tag(TAG)
                .build();

        Logger.addLogAdapter(new AndroidLogAdapter(formatStrategy));

        FormatStrategy diskFormatStrategy = CustomCsvFormatStrategy
                .newBuilder()
                .build(context);

        Logger.addLogAdapter(new DiskLogAdapter(diskFormatStrategy));
    }

    public static WaylensCamera getInstance() {
        synchronized (WaylensCamera.class) {
            return instance;
        }
    }

    public static WaylensCamera initializeWithDefaults(Context context) {
        if (context.getApplicationContext() != null) {
            context = context.getApplicationContext();
        }

        if (instance == null) {
            synchronized (WaylensCamera.class) {
                if (instance == null) {
                    instance = new WaylensCamera(context);
                }
            }
        }

        return instance;
    }

    public static boolean isForeground() {
        return mActivityCount > 0;
    }

    Application.ActivityLifecycleCallbacks lifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
//            Logger.t(TAG).d("onActivityCreated");
        }

        @Override
        public void onActivityStarted(Activity activity) {
            mActivityCount++;
//            Logger.t(TAG).d("onActivityStarted: " + mActivityCount);

//            if (directConnection == null) {
//                directConnection = WifiDirectConnection.getInstance();
//                directConnection.registerP2PReceiver();
//            }
        }

        @Override
        public void onActivityResumed(Activity activity) {
//            Logger.t(TAG).d("onActivityResumed");
        }

        @Override
        public void onActivityPaused(Activity activity) {
//            Logger.t(TAG).d("onActivityPaused");
        }

        @Override
        public void onActivityStopped(Activity activity) {
            mActivityCount--;
//            Logger.t(TAG).d("onActivityStopped: " + mActivityCount);

//            if (!isForeground() && directConnection != null) {
//                directConnection.unregisterP2PReceiver();
//                directConnection = null;
//            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
//            Logger.t(TAG).d("onActivitySaveInstanceState");
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
//            Logger.t(TAG).d("onActivityDestroyed");
        }
    };
}
