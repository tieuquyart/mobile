package com.mkgroup.camera.rest;

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
import android.text.format.Formatter;

import com.mkgroup.camera.WaylensCamera;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.direct.WifiDirectConnection;

import static android.net.NetworkCapabilities.NET_CAPABILITY_INTERNET;
import static android.net.NetworkCapabilities.TRANSPORT_CELLULAR;
import static android.net.NetworkCapabilities.TRANSPORT_WIFI;


/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */
public class NetworkService {
    private static final String TAG = NetworkService.class.getSimpleName();

    private static final int TIME_OUT_MILLI_SEC = 30000;

    public final static String WAYLENS_BASE_URL = "https://agent.waylens.com/";

    private static Network CELLULAR_NETWORK = null;

    private static SimpleNetworkCallback callback;

    private NetworkService() {

    }

    @TargetApi(21)
    public static void requestByMobileData() {
        ConnectivityManager connectivityManager = (ConnectivityManager) WaylensCamera.getInstance().getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager == null) {
            return;
        }
        NetworkRequest.Builder builder = new NetworkRequest.Builder();
        builder.addCapability(NET_CAPABILITY_INTERNET);

        builder.addTransportType(TRANSPORT_CELLULAR);
        NetworkRequest request = builder.build();
        Logger.t(TAG).d("sdk request TRANSPORT_CELLULAR");

        //这里不要改成registerNetworkCallback, 否则监听不到
        connectivityManager.requestNetwork(request, new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                super.onAvailable(network);
                try {
                    NetworkService.CELLULAR_NETWORK = network;
                    //cancel the formal cellular
                    Logger.t(TAG).e("sdk request TRANSPORT_CELLULAR success: " + network);

                    //验证回调network是否可用
/*                  URL url = new URL("http://www.baidu.com/s?wd=123");
                    HttpURLConnection connection = (HttpURLConnection)network.openConnection(url);
                    connection.connect();
                    InputStream is = connection.getInputStream();
                    IoBuffer buff = IoBuffer.allocate(10240).setAutoExpand(true);
                    byte[] buf = new byte[1024];
                    int length = is.read(buf);
                    while ( length > 0 ) {
                        buff.put(buf);
                        length = is.read(buf);
                    }
                    Logger.t(TAG).d("response =  %s ", new String(buff.array()));
*/
                } catch (Exception e) {
                    Logger.t(TAG).e("sdk request TRANSPORT_CELLULAR success exception");
                }
            }
        });
    }

    @TargetApi(21)
    public static void bindNetworkToWiFi() {
        Logger.t(TAG).d("bindNetworkToWiFi");
        registerNetworkMonitor(WaylensCamera.getInstance().getApplicationContext());
    }

    public static void unbindNetworkToWiFi() {
        ConnectivityManager cm = (ConnectivityManager) WaylensCamera.getInstance().getApplicationContext()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm == null) return;

        WifiManager wifiManager = (WifiManager) WaylensCamera.getInstance().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
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

            ConnectivityManager cm = (ConnectivityManager) WaylensCamera.getInstance().getApplicationContext()
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm == null) return;

            String ssid = null;
            int ipAddress = 0;
            WifiManager wifiManager = (WifiManager) WaylensCamera.getInstance().getApplicationContext()
                    .getSystemService(Context.WIFI_SERVICE);
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
        return CELLULAR_NETWORK;
    }

//    private static final Interceptor headerInterceptor = chain -> {
//        Request request = chain.request();
//        Request.Builder newReqBuilder = request.newBuilder()
//                .addHeader("User-Agent", USER_AGENT);
//        try {
//            String token = mComponent.currentUser().getAccessToken();
//            //Logger.t(TAG).d("token = " + token);
//            if (!TextUtils.isEmpty(token)) {
//                newReqBuilder.addHeader("X-Auth-Token", token);
//            }
//        } catch (Exception e) {
//            Logger.t(TAG).e("get exception = " + e.getMessage());
//        }
//        Response response = chain.proceed(newReqBuilder.build());
//        List<String> values = response.headers().values("Set-Cookie");
//        if (values.size() != 0) {
//            CookieUtil.setCookie(values);
//        }
//        return response;
//    };
}
