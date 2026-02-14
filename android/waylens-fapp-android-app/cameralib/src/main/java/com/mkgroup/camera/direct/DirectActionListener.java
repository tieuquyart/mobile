package com.mkgroup.camera.direct;

import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pInfo;
import android.net.wifi.p2p.WifiP2pManager;

import java.util.Collection;

/**
 * Created by doanvt on 2019/2/15.
 * Email：doanvt-hn@mk.com.vn
 */

public interface DirectActionListener extends WifiP2pManager.ChannelListener {

    void wifiP2pEnabled(boolean enabled);

    void onConnectionInfoAvailable(WifiP2pInfo wifiP2pInfo);

    void onDisconnection();

    void onSelfDeviceAvailable(WifiP2pDevice wifiP2pDevice);

    void onPeersAvailable(Collection<WifiP2pDevice> wifiP2pDeviceList);

}
