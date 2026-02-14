package com.mk.autosecure.rest;

import static android.net.NetworkCapabilities.NET_CAPABILITY_INTERNET;
import static android.net.NetworkCapabilities.TRANSPORT_CELLULAR;
import static android.net.NetworkCapabilities.TRANSPORT_WIFI;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.p2p.WifiP2pDevice;
import android.os.Build;
import android.text.TextUtils;
import android.text.format.Formatter;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.CookieUtil;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.libs.utils.StringUtils;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.NetworkService;
import com.mk.autosecure.R;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;


/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */

public class ApiService {
    private static final String TAG = ApiService.class.getSimpleName();
    private static volatile HornApiService mApiServiceInstance = null;

    private static volatile HornApiService mApiServiceInstance_cellular = null;

    private static final int TIME_OUT_MILLI_SEC = 30000;
    private static AppComponent mComponent = HornApplication.getComponent();

//    public final static String WAYLENS_BASE_URL = "http://fms.mk.com.vn:8888/";
//    public final static String WAYLENS_BASE_URL = "http://fms.mkvision.com/";
    public final static String WAYLENS_BASE_URL = "https://agent.waylens.com/";

    public final static String USER_AGENT = String.format(Locale.ENGLISH, StringUtils.USER_AGENT_FORMAT, "Secure360",
            BuildConfig.VERSION_NAME, BuildConfig.VERSION_CODE,
            Build.MANUFACTURER + " " + Build.MODEL, "Android " + Build.VERSION.RELEASE);

    private static SimpleNetworkCallback callback;

    private ApiService() {

    }

    public static HornApiService createApiService() {
        Logger.t(TAG).d("createApiService isNetworkLimited: " + NetworkUtils.isNetworkLimited());
        if (NetworkUtils.isNetworkLimited()) {
            return createHornApiServiceCellular();
        } else {
            return createHornApiService();
        }
    }

    private static HornApiService createHornApiService() {
        if (mApiServiceInstance == null) {
            synchronized (ApiService.class) {
                if (mApiServiceInstance == null) {
                    String[] serverList = HornApplication.getContext().getResources().getStringArray(R.array.host_server_list);
                    String BASE_URL = PreferenceUtils.getString(PreferenceUtils.SERVER_URL, serverList[serverList.length - 1]);
                    Retrofit.Builder builder = new Retrofit.Builder()
                            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                            .addConverterFactory(GsonConverterFactory.create())
                            .baseUrl(BASE_URL);

                    Logger.t(TAG).e("base url = %s", BASE_URL);
                    OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();

                    HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
                    logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

                    clientBuilder.addInterceptor(logInterceptor);

                    //拦截消息通知的url，修改baseUrl
                    clientBuilder.addInterceptor(new MoreBaseUrlInterceptor());

                    clientBuilder.addInterceptor(headerInterceptor)
                            .readTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .writeTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .connectTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS);

                    builder.client(clientBuilder.build());
                    mApiServiceInstance = builder.build().create(HornApiService.class);
                }
            }
        }
        return mApiServiceInstance;
    }

    @TargetApi(21)
    private static HornApiService createHornApiServiceCellular() {
        if (mApiServiceInstance_cellular == null) {
            synchronized (ApiService.class) {
                if (mApiServiceInstance_cellular == null) {
                    String[] serverList = HornApplication.getContext().getResources().getStringArray(R.array.host_server_list);
                    String BASE_URL = PreferenceUtils.getString(PreferenceUtils.SERVER_URL, serverList[serverList.length - 1]);
                    Retrofit.Builder builder = new Retrofit.Builder()
                            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                            .addConverterFactory(GsonConverterFactory.create())
                            .baseUrl(BASE_URL);

                    Logger.t(TAG).e("base url = %s", BASE_URL);
                    OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();

                    HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
                    logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

                    clientBuilder.addInterceptor(logInterceptor);

                    //拦截消息通知的url，修改baseUrl
                    clientBuilder.addInterceptor(new MoreBaseUrlInterceptor());

                    clientBuilder.addInterceptor(headerInterceptor)
                            .readTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .writeTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .connectTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS);

                    if (getCellularNetwork() != null) {
                        Logger.t(TAG).e("cellular network != null");
                        clientBuilder.socketFactory(getCellularNetwork().getSocketFactory());
                        clientBuilder.dns(hostname -> {
//                            Logger.t(TAG).e("lookup : %s", hostname);
                            return Arrays.asList(getCellularNetwork().getAllByName(hostname));
                        });
                    } else {
                        Logger.t(TAG).e("cellular network == null");
                        return createHornApiService();
                    }

                    builder.client(clientBuilder.build());
                    mApiServiceInstance_cellular = builder.build().create(HornApiService.class);
                }
            }
        }
        return mApiServiceInstance_cellular;
    }


    @TargetApi(21)
    public static void requestByMobileData() {
        ConnectivityManager connectivityManager = (ConnectivityManager) HornApplication.getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager == null) {
            return;
        }
        NetworkRequest.Builder builder = new NetworkRequest.Builder();
        builder.addCapability(NET_CAPABILITY_INTERNET);

        builder.addTransportType(TRANSPORT_CELLULAR);
        NetworkRequest request = builder.build();
        Logger.t(TAG).d("request TRANSPORT_CELLULAR");

        //这里不要改成registerNetworkCallback, 否则监听不到
        connectivityManager.requestNetwork(request, new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                super.onAvailable(network);
                try {
                    //cancel the formal cellular
                    mApiServiceInstance_cellular = null;
                    Logger.t(TAG).e("app request TRANSPORT_CELLULAR success: " + network);

                } catch (Exception e) {
                    Logger.t(TAG).e("app request TRANSPORT_CELLULAR success exception");
                }
            }
        });
    }

    @TargetApi(21)
    public static void bindNetworkToWiFi() {
        Logger.t(TAG).d("bindNetworkToWiFi");
        registerNetworkMonitor(HornApplication.getContext());
    }

    public static void unbindNetworkToWiFi() {
        ConnectivityManager cm = (ConnectivityManager) HornApplication.getContext()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm == null) return;

        WifiManager wifiManager = (WifiManager) HornApplication.getContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifiManager != null) {
            int wifiState = wifiManager.getWifiState();
            Logger.t(TAG).d("wifiState enable: " + (wifiState == WifiManager.WIFI_STATE_ENABLED));
        }

        try {
            if (callback != null) {
                cm.unregisterNetworkCallback(callback);
                callback = null;
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("unregisterNetworkCallback exception: " + ex.getMessage());
        }

        boolean result = false;
        try {
            if (Build.VERSION.SDK_INT >= 23) {
                result = cm.bindProcessToNetwork(null);
            } else {
                result = ConnectivityManager.setProcessDefaultNetwork(null);
            }
        } catch (Exception e) {
            Logger.t(TAG).e("unbind wifi network failed: %s", e.getMessage());
        } finally {
            Logger.t(TAG).e("unbindNetworkToWiFi: " + result);
        }
    }

    private static void registerNetworkMonitor(Context context) {
        try {
            ConnectivityManager cm = (ConnectivityManager) context
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm == null) return;
            NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
            boolean isConnected = activeNetwork != null
                    && activeNetwork.isConnected();
            callback = new SimpleNetworkCallback();

            // Caused by: java.lang.IllegalArgumentException: Too many NetworkRequests filed
            cm.registerNetworkCallback(new NetworkRequest.Builder()
                    .addTransportType(TRANSPORT_WIFI).build(), callback);
        } catch (Exception ex) {
            Logger.t(TAG).e("registerNetworkMonitor error: " + ex.getMessage());
        }
    }

    private static class SimpleNetworkCallback extends ConnectivityManager.NetworkCallback {
//        private static final String TAG = "SimpleNetworkCallback";

        @Override
        public void onAvailable(Network network) {
//            Logger.t(TAG).e("Network " + network.toString());
            WifiP2pDevice wifiP2pDevice = WifiDirectConnection.getInstance().getConnectedDevice();
            if (wifiP2pDevice != null) {
                Logger.t(TAG).e("Secure360 is in wifi direct mode, don't bind network.");
                return;
            }

            ConnectivityManager cm = (ConnectivityManager) HornApplication.getContext()
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm == null) return;

            String ssid = null;
            int ipAddress = 0;
            WifiManager wifiManager = (WifiManager) HornApplication.getContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            if (wifiManager != null) {
                //android q getConnectionInfo() need permission ACCESS_FINE_LOCATION
                WifiInfo wifiInfo = wifiManager.getConnectionInfo();
                if (wifiInfo != null) {
                    ssid = wifiInfo.getSSID();
                    ipAddress = wifiInfo.getIpAddress();
                }
            }
            Logger.t(TAG).e("onAvailable ssid: " + ssid
                    + " ipAddress: " + Formatter.formatIpAddress(ipAddress));

            try {
                Logger.t(TAG).d("request wifi network success: " + network);
                if (Build.VERSION.SDK_INT >= 23) {
                    cm.bindProcessToNetwork(network);
                } else {
                    ConnectivityManager.setProcessDefaultNetwork(network);
                }
//                CameraConnectivityManager.getManager().startSearchCamera();
            } catch (Exception e) {
                Logger.t(TAG).e("request wifi network failed: %s", e.getMessage());
            }
        }

        @Override
        public void onCapabilitiesChanged(Network network, NetworkCapabilities networkCapabilities) {
//            Logger.t(TAG).e("NetworkCapabilities = " + networkCapabilities);

            // A capabilities change may indicate the ConnectionType has changed,
            // so forward the new NetworkInformation along to observer.
        }

        @Override
        public void onLinkPropertiesChanged(Network network, LinkProperties linkProperties) {
            // A link property change may indicate the IP address changes.
            // so forward the new NetworkInformation to the observer.
        }

        @Override
        public void onLosing(Network network, int maxMsToLive) {
            Logger.t(TAG).e("Network with handle " + network.toString() + " is about to lose in " + maxMsToLive + "ms");
            // Tell the network is going to lose in MaxMsToLive milliseconds.
            // We may use this signal later.
        }

        @Override
        public void onLost(Network network) {
            Logger.t(TAG).e("Network with handle " + network.toString() + " is disconnected");
            unbindNetworkToWiFi();
        }
    }

    public static Network getCellularNetwork() {
        return NetworkService.getCellularNetwork();
    }

    private static final Interceptor headerInterceptor = chain -> {
        Request request = chain.request();
        Request.Builder newReqBuilder = request.newBuilder()
                .addHeader("User-Agent", USER_AGENT);
        try {
            String token = mComponent.currentUser().getAccessToken();
            //Logger.t(TAG).d("token = " + token);
            if (!TextUtils.isEmpty(token)) {
                newReqBuilder.addHeader("X-Auth-Token", token);
            }
        } catch (Exception e) {
            Logger.t(TAG).e("get exception = " + e.getMessage());
        }
        Response response = chain.proceed(newReqBuilder.build());
        List<String> values = response.headers().values("Set-Cookie");
        if (values.size() != 0) {
            CookieUtil.setCookie(values);
        }
        return response;
    };
}
