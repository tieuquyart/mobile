package com.mkgroup.camera.direct;

import java.util.List;

/**
 * Created by doanvt on 2019/3/14.
 * Email：doanvt-hn@mk.com.vn
 */
public class PairedDevices {

    private List<DevicesBean> Devices;

    private List<DevicesBean> pairedDevices;

    public List<DevicesBean> getDevices() {
        if (Devices != null) {
            return Devices;
        } else if (pairedDevices != null) {
            return pairedDevices;
        } else {
            return null;
        }
    }

    public void setPairedDevices(List<DevicesBean> pairedDevices) {
        this.pairedDevices = pairedDevices;
    }

    public void setDevices(List<DevicesBean> Devices) {
        this.Devices = Devices;
    }

    public static class DevicesBean {
        /**
         * name : [Phone] Galaxy S9
         * mac : 8e:45:00:b0:62:47
         */

        private String name;
        private String mac;
        private boolean isCurrent;

        public boolean isCurrent() {
            return isCurrent;
        }

        public void setCurrent(boolean current) {
            isCurrent = current;
        }

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
