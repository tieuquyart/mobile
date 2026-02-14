package com.mk.autosecure.rest_fleet.response;

import java.util.List;

public class FencesResponse {

    /**
     * fences : [{"fenceID":"43facb1a13","fenceType":"through","enabled":true,"name":"waylens_test_1","center":[31.1886,121.6057],"radius":1000},{"fenceID":"e3c379a40f","fenceType":"through","enabled":true,"name":"waylens_test_2","center":[31.3,121.5154],"radius":2000},{"fenceID":"5834374e9d","fenceType":"through","enabled":true,"name":"waylens_test_3","polygon":[[31.249,121.591],[31.222,121.591],[31.222,121.627],[31.249,121.627],[31.249,121.591]]},{"fenceID":"e5434e7e20","fenceType":"through","enabled":true,"name":"waylens_test_5","polygon":[[31.371,121.2647],[31.371,121.28],[31.3034,121.3164],[31.2908,121.4074],[31.2804,121.4074],[31.2925,121.3086],[31.371,121.2647]]},{"fenceID":"badc0c0deb","fenceType":"through","enabled":true,"name":"waylens_test_4","polygon":[[31.149,121.589],[31.16,121.653],[31.094,121.667],[31.087,121.606],[31.149,121.589]]},{"fenceID":"47cbafab51","fenceType":"designated","enabled":true,"name":"test","center":[31.19108,121.60139],"radius":1000}]
     * hasMore : false
     */

    private boolean hasMore;
    private List<FencesBean> fences;

    public boolean isHasMore() {
        return hasMore;
    }

    public void setHasMore(boolean hasMore) {
        this.hasMore = hasMore;
    }

    public List<FencesBean> getFences() {
        return fences;
    }

    public void setFences(List<FencesBean> fences) {
        this.fences = fences;
    }

    public static class FencesBean {
        /**
         * fenceID : 43facb1a13
         * fenceType : through
         * enabled : true
         * name : waylens_test_1
         * center : [31.1886,121.6057]
         * radius : 1000
         * polygon : [[31.249,121.591],[31.222,121.591],[31.222,121.627],[31.249,121.627],[31.249,121.591]]
         */

        private String fenceID;
        private String fenceType;
        private boolean enabled;
        private String name;
        private int radius;
        private List<Double> center;
        private List<List<Double>> polygon;

        public String getFenceID() {
            return fenceID;
        }

        public void setFenceID(String fenceID) {
            this.fenceID = fenceID;
        }

        public String getFenceType() {
            return fenceType;
        }

        public void setFenceType(String fenceType) {
            this.fenceType = fenceType;
        }

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getRadius() {
            return radius;
        }

        public void setRadius(int radius) {
            this.radius = radius;
        }

        public List<Double> getCenter() {
            return center;
        }

        public void setCenter(List<Double> center) {
            this.center = center;
        }

        public List<List<Double>> getPolygon() {
            return polygon;
        }

        public void setPolygon(List<List<Double>> polygon) {
            this.polygon = polygon;
        }
    }
}
