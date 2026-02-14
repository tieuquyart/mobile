package com.mk.autosecure.libs.utils;

import com.orhanobut.logger.Logger;

import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

/**
 * Created by doanvt on 2019/3/15.
 * Email：doanvt-hn@mk.com.vn
 */
public class MacAddressUtil {

    private final static String TAG = MacAddressUtil.class.getSimpleName();

    private final static String P2P = "p2p0";

    private final static String P2P_WLAN = "p2p-wlan0-0";

    public static List<String> getMacAddress() {
        List<String> addressList = new ArrayList<>();
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface anInterface = interfaces.nextElement();
                byte[] hardwareAddress = anInterface.getHardwareAddress();
                if (hardwareAddress != null) {
                    String displayName = anInterface.getDisplayName();
                    if (P2P.equals(displayName) || P2P_WLAN.equals(displayName)) {
                        addressList.add(Hex.encodeHexString(hardwareAddress));
                    }
                }
            }
        } catch (SocketException ex) {
            Logger.t(TAG).e("ex: " + ex.getMessage());
        }
        return addressList;
    }
}
