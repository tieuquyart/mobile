package com.mkgroup.camera.message.bean;

import java.util.List;

public class RecordConfigListBean {

    private List<ConfigListBean> recordConfigList;

    public List<ConfigListBean> getRecordConfigList() {
        return recordConfigList;
    }

    public void setRecordConfigList(List<ConfigListBean> recordConfigList) {
        this.recordConfigList = recordConfigList;
    }

    public static class ConfigListBean {
        /**
         * name : 1952x1952
         * bitrate : 20000000
         */

        private String name;
        private int bitrate;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getBitrate() {
            return bitrate;
        }

        public void setBitrate(int bitrate) {
            this.bitrate = bitrate;
        }

        @Override
        public String toString() {
            return "ConfigListBean{" +
                    "name='" + name + '\'' +
                    ", bitrate=" + bitrate +
                    '}';
        }
    }
}
