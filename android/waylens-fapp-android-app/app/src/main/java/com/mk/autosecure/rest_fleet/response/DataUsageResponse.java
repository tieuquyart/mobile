package com.mk.autosecure.rest_fleet.response;

import java.util.List;

public class DataUsageResponse {

    /**
     * iccid : 89860318740211144091
     * cycleUsage : [{"cycle":"2019-09","dataUsageInKB":3489426}]
     */

    private String iccid;
    private List<CycleUsageBean> cycleUsage;

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
    }

    public List<CycleUsageBean> getCycleUsage() {
        return cycleUsage;
    }

    public void setCycleUsage(List<CycleUsageBean> cycleUsage) {
        this.cycleUsage = cycleUsage;
    }

    public static class CycleUsageBean {
        /**
         * cycle : 2019-09
         * dataUsageInKB : 3489426
         */

        private String cycle;
        private int dataUsageInKB;

        public String getCycle() {
            return cycle;
        }

        public void setCycle(String cycle) {
            this.cycle = cycle;
        }

        public int getDataUsageInKB() {
            return dataUsageInKB;
        }

        public void setDataUsageInKB(int dataUsageInKB) {
            this.dataUsageInKB = dataUsageInKB;
        }
    }

}
