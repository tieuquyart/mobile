package com.mkgroup.camera.direct;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.NetworkInfo;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pManager;
import android.text.TextUtils;

import com.orhanobut.logger.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by doanvt on 2019/2/15.
 * Email：doanvt-hn@mk.com.vn
 */

public class WifiDirectReceiver extends BroadcastReceiver {

    private static final String TAG = "WifiDirectReceiver";

    private WifiP2pManager mWifiP2pManager;

    private WifiP2pManager.Channel mChannel;

    private DirectActionListener mDirectActionListener;

    public WifiDirectReceiver(WifiP2pManager wifiP2pManager, WifiP2pManager.Channel channel, DirectActionListener directActionListener) {
        mWifiP2pManager = wifiP2pManager;
        mChannel = channel;
        mDirectActionListener = directActionListener;
    }

    //With Android 10, the following broadcast intents were changed from sticky to non-sticky:
    //
    //WIFI_P2P_CONNECTION_CHANGED_ACTION
    //Applications can use requestConnectionInfo(), requestNetworkInfo(), or requestGroupInfo() to retrieve the current connection information.
    //WIFI_P2P_THIS_DEVICE_CHANGED_ACTION
    //Applications can use requestDeviceInfo() to retrieve the current connection information.

    public IntentFilter getIntentFilter() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION);
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION);
        //android Q 不再具有粘性 WIFI_P2P_CONNECTION_CHANGED_ACTION and WIFI_P2P_THIS_DEVICE_CHANGED_ACTION
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION);
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION);
        return intentFilter;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Logger.t(TAG).d("onReceive: " + action);
        if (!TextUtils.isEmpty(action)) {
            switch (action) {
                // 用于指示 Wifi P2P 是否可用
                case WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION: {
                    int state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1);
                    if (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED) {
                        mDirectActionListener.wifiP2pEnabled(true);
                    } else {
                        mDirectActionListener.wifiP2pEnabled(false);
                        List<WifiP2pDevice> wifiP2pDeviceList = new ArrayList<>();
                        mDirectActionListener.onPeersAvailable(wifiP2pDeviceList);
                    }
                    break;
                }
                // 对等节点列表发生了变化
                case WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION: {
                    //这里在android 26及以上需要权限ACCESS_COARSE_LOCATION，所以避过这里通过requestConnectionInfo来判断连接状态
                    mWifiP2pManager.requestPeers(mChannel, peers -> mDirectActionListener.onPeersAvailable(peers.getDeviceList()));
                    break;
                }
                // Wifi P2P 的连接状态发生了改变
                case WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION: {
                    NetworkInfo networkInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO);
                    if (networkInfo != null && networkInfo.isConnected()) {
                        Logger.t(TAG).d("wifi direct connected");
                        mWifiP2pManager.requestConnectionInfo(mChannel, info -> mDirectActionListener.onConnectionInfoAvailable(info));
                    } else {
                        Logger.t(TAG).d("wifi direct disConnected");
                        mDirectActionListener.onDisconnection();
                    }
                    break;
                }
                //本设备的设备信息发生了变化
                case WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION: {
                    mDirectActionListener.onSelfDeviceAvailable(intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE));
                    break;
                }
            }
        }
    }
}
