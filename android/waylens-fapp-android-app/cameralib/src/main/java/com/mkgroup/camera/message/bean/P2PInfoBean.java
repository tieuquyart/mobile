package com.mkgroup.camera.message.bean;

import java.util.List;

public class P2PInfoBean {

    /**
     * enabled : false
     * pairedDevices : [{"name":"mix_cc","mac":"ee:d0:9f:53:b8:ef "}]
     */

    private boolean enabled;
    private List<PairedDevicesBean> pairedDevices;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public List<PairedDevicesBean> getPairedDevices() {
        return pairedDevices;
    }

    public void setPairedDevices(List<PairedDevicesBean> pairedDevices) {
        this.pairedDevices = pairedDevices;
    }

    public static class PairedDevicesBean {
        /**
         * name : mix_cc
         * mac : ee:d0:9f:53:b8:ef
         */

        private String name;
        private String mac;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getMac() {
            return mac;
        }

        public void setMac(String mac) {
            this.mac = mac;
        }
    }
}
