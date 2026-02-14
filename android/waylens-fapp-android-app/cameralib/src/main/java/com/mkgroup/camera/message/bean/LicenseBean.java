package com.mkgroup.camera.message.bean;

import com.google.gson.stream.JsonReader;

import java.util.List;

public class LicenseBean {
    private String macWlan0;
    private List<Algorithm> info_Algorithm;

    // Constructor
    public LicenseBean(String macWlan0, List<Algorithm> info_Algorithm) {
        this.macWlan0 = macWlan0;
        this.info_Algorithm = info_Algorithm;
    }

    // Getter và Setter
    public String getMacWlan0() {
        return macWlan0;
    }

    public void setMacWlan0(String macWlan0) {
        this.macWlan0 = macWlan0;
    }

    public List<Algorithm> getInfo_Algorithm() {
        return info_Algorithm;
    }

    public void setInfo_Algorithm(List<Algorithm> info_Algorithm) {
        this.info_Algorithm = info_Algorithm;
    }


    // Class con để ánh xạ mảng "info_Algorithm"
    public static class Algorithm {
        private String name;
        private int id;
        private String prop;
        private String value;
        private String errorAlgorithm;

        // Constructor
        public Algorithm(String name, int id, String prop, String value, String errorAlgorithm) {
            this.name = name;
            this.id = id;
            this.prop = prop;
            this.value = value;
            this.errorAlgorithm = errorAlgorithm;
        }

        // Getter và Setter
        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getProp() {
            return prop;
        }

        public void setProp(String prop) {
            this.prop = prop;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }

        public String getErrorAlgorithm() {
            return errorAlgorithm;
        }

        public void setErrorAlgorithm(String errorAlgorithm) {
            this.errorAlgorithm = errorAlgorithm;
        }
    }
}
