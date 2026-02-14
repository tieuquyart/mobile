package com.mk.autosecure.rest_fleet.bean;

import java.util.List;

public class BillingDataBean {

    /**
     * cycleStartDate : 1571443200000
     * cycleEndDate : 1574121599000
     * status : created
     * charge : 0
     * totalDataVolumeInMB : 0
     * cameras : [{"cameraSN":"2B19FWS2","iccid":"89011703278261099298","dataVolumeInMB":369.768},{"cameraSN":"2B17NKKA","iccid":"89011702272014339664","dataVolumeInMB":0},{"cameraSN":"2B1A7UCM","iccid":"89011703278261118866","dataVolumeInMB":0},{"iccid":"89011703278261129772","dataVolumeInMB":0}]
     */

    private long cycleStartDate;
    private long cycleEndDate;
    private String status;
    private double charge;
    private double totalCharge;
    private double totalDataVolumeInMB;
    private List<CamerasBean> cameras;

    public long getCycleStartDate() {
        return cycleStartDate;
    }

    public void setCycleStartDate(long cycleStartDate) {
        this.cycleStartDate = cycleStartDate;
    }

    public long getCycleEndDate() {
        return cycleEndDate;
    }

    public void setCycleEndDate(long cycleEndDate) {
        this.cycleEndDate = cycleEndDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getCharge() {
        return charge;
    }

    public void setCharge(int charge) {
        this.charge = charge;
    }

    public double getTotalCharge() {
        return totalCharge;
    }

    public void setTotalCharge(int totalCharge) {
        this.totalCharge = totalCharge;
    }

    public double getTotalDataVolumeInMB() {
        return totalDataVolumeInMB;
    }

    public void setTotalDataVolumeInMB(int totalDataVolumeInMB) {
        this.totalDataVolumeInMB = totalDataVolumeInMB;
    }

    public List<CamerasBean> getCameras() {
        return cameras;
    }

    public void setCameras(List<CamerasBean> cameras) {
        this.cameras = cameras;
    }

    public static class CamerasBean {
        /**
         * cameraSN : 2B19FWS2
         * iccid : 89011703278261099298
         * dataVolumeInMB : 369.768
         */

        private String cameraSN;
        private String iccid;
        private double dataVolumeInMB;

        public String getCameraSN() {
            return cameraSN;
        }

        public void setCameraSN(String cameraSN) {
            this.cameraSN = cameraSN;
        }

        public String getIccid() {
            return iccid;
        }

        public void setIccid(String iccid) {
            this.iccid = iccid;
        }

        public double getDataVolumeInMB() {
            return dataVolumeInMB;
        }

        public void setDataVolumeInMB(double dataVolumeInMB) {
            this.dataVolumeInMB = dataVolumeInMB;
        }

        @Override
        public String toString() {
            return "CamerasBean{" +
                    "cameraSN='" + cameraSN + '\'' +
                    ", iccid='" + iccid + '\'' +
                    ", dataVolumeInMB=" + dataVolumeInMB +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "BillingDataBean{" +
                "cycleStartDate=" + cycleStartDate +
                ", cycleEndDate=" + cycleEndDate +
                ", status='" + status + '\'' +
                ", charge=" + charge +
                ", totalCharge=" + totalCharge +
                ", totalDataVolumeInMB=" + totalDataVolumeInMB +
                ", cameras=" + cameras +
                '}';
    }
}
