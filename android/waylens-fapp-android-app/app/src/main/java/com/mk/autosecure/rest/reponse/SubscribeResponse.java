package com.mk.autosecure.rest.reponse;

/**
 * Created by doanvt on 2018/7/20.
 * Email：doanvt-hn@mk.com.vn
 */

public class SubscribeResponse {

    /**
     * sn : test
     * iccid : 89011702272014339680
     * status : in_service
     * subscriptionEnded : 1546731534292
     * currentRatePlanSubscription : {"ratePlanID":1,"ratePlanName":"Prepaid 3 months with 3G/month","ratePlanDescription":"{\"termInDays\": \"180\", \"includedData\": \"3G/month\"}","atntBillingDate":1531944000000,"subscriptionStarted":1531179534292,"subscriptionEnded":1546731534292}
     * currentSubCycle : {"month":"201807","cycleEnded":1537200000000,"ctdDataUsageInKB":1259781,"basePlanQuotaInKB":2097152,"totalAddonsInKB":2097152,"totalQuotaInKB":4194304,"remainingDataInKB":2934523}
     */

    private String sn;
    private String iccid;
    private String status;
    private long subscriptionEnded;
    private CurrentRatePlanSubscriptionBean currentRatePlanSubscription;
    private CurrentSubCycleBean currentSubCycle;

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getSubscriptionEnded() {
        return subscriptionEnded;
    }

    public void setSubscriptionEnded(long subscriptionEnded) {
        this.subscriptionEnded = subscriptionEnded;
    }

    public CurrentRatePlanSubscriptionBean getCurrentRatePlanSubscription() {
        return currentRatePlanSubscription;
    }

    public void setCurrentRatePlanSubscription(CurrentRatePlanSubscriptionBean currentRatePlanSubscription) {
        this.currentRatePlanSubscription = currentRatePlanSubscription;
    }

    public CurrentSubCycleBean getCurrentSubCycle() {
        return currentSubCycle;
    }

    public void setCurrentSubCycle(CurrentSubCycleBean currentSubCycle) {
        this.currentSubCycle = currentSubCycle;
    }

    public static class CurrentRatePlanSubscriptionBean {
        /**
         * ratePlanID : 1
         * ratePlanName : Prepaid 3 months with 3G/month
         * ratePlanDescription : {"termInDays": "180", "includedData": "3G/month"}
         * atntBillingDate : 1531944000000
         * subscriptionStarted : 1531179534292
         * subscriptionEnded : 1546731534292
         */

        private int ratePlanID;
        private String ratePlanName;
        private String ratePlanDescription;
        private long atntBillingDate;
        private long subscriptionStarted;
        private long subscriptionEnded;

        public int getRatePlanID() {
            return ratePlanID;
        }

        public void setRatePlanID(int ratePlanID) {
            this.ratePlanID = ratePlanID;
        }

        public String getRatePlanName() {
            return ratePlanName;
        }

        public void setRatePlanName(String ratePlanName) {
            this.ratePlanName = ratePlanName;
        }

        public String getRatePlanDescription() {
            return ratePlanDescription;
        }

        public void setRatePlanDescription(String ratePlanDescription) {
            this.ratePlanDescription = ratePlanDescription;
        }

        public long getAtntBillingDate() {
            return atntBillingDate;
        }

        public void setAtntBillingDate(long atntBillingDate) {
            this.atntBillingDate = atntBillingDate;
        }

        public long getSubscriptionStarted() {
            return subscriptionStarted;
        }

        public void setSubscriptionStarted(long subscriptionStarted) {
            this.subscriptionStarted = subscriptionStarted;
        }

        public long getSubscriptionEnded() {
            return subscriptionEnded;
        }

        public void setSubscriptionEnded(long subscriptionEnded) {
            this.subscriptionEnded = subscriptionEnded;
        }

        @Override
        public String toString() {
            return "CurrentRatePlanSubscriptionBean{" +
                    "ratePlanID=" + ratePlanID +
                    ", ratePlanName='" + ratePlanName + '\'' +
                    ", ratePlanDescription='" + ratePlanDescription + '\'' +
                    ", atntBillingDate=" + atntBillingDate +
                    ", subscriptionStarted=" + subscriptionStarted +
                    ", subscriptionEnded=" + subscriptionEnded +
                    '}';
        }
    }

    public static class CurrentSubCycleBean {
        /**
         * month : 201807
         * cycleEnded : 1537200000000
         * ctdDataUsageInKB : 1259781
         * basePlanQuotaInKB : 2097152
         * totalAddonsInKB : 2097152
         * totalQuotaInKB : 4194304
         * remainingDataInKB : 2934523
         */

        private String month;
        private long cycleEnded;
        private int ctdDataUsageInKB;
        private int basePlanQuotaInKB;
        private int totalAddonsInKB;
        private int totalQuotaInKB;
        private int remainingDataInKB;

        public String getMonth() {
            return month;
        }

        public void setMonth(String month) {
            this.month = month;
        }

        public long getCycleEnded() {
            return cycleEnded;
        }

        public void setCycleEnded(long cycleEnded) {
            this.cycleEnded = cycleEnded;
        }

        public int getCtdDataUsageInKB() {
            return ctdDataUsageInKB;
        }

        public void setCtdDataUsageInKB(int ctdDataUsageInKB) {
            this.ctdDataUsageInKB = ctdDataUsageInKB;
        }

        public int getBasePlanQuotaInKB() {
            return basePlanQuotaInKB;
        }

        public void setBasePlanQuotaInKB(int basePlanQuotaInKB) {
            this.basePlanQuotaInKB = basePlanQuotaInKB;
        }

        public int getTotalAddonsInKB() {
            return totalAddonsInKB;
        }

        public void setTotalAddonsInKB(int totalAddonsInKB) {
            this.totalAddonsInKB = totalAddonsInKB;
        }

        public int getTotalQuotaInKB() {
            return totalQuotaInKB;
        }

        public void setTotalQuotaInKB(int totalQuotaInKB) {
            this.totalQuotaInKB = totalQuotaInKB;
        }

        public int getRemainingDataInKB() {
            return remainingDataInKB;
        }

        public void setRemainingDataInKB(int remainingDataInKB) {
            this.remainingDataInKB = remainingDataInKB;
        }

        @Override
        public String toString() {
            return "CurrentSubCycleBean{" +
                    "month='" + month + '\'' +
                    ", cycleEnded=" + cycleEnded +
                    ", ctdDataUsageInKB=" + ctdDataUsageInKB +
                    ", basePlanQuotaInKB=" + basePlanQuotaInKB +
                    ", totalAddonsInKB=" + totalAddonsInKB +
                    ", totalQuotaInKB=" + totalQuotaInKB +
                    ", remainingDataInKB=" + remainingDataInKB +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "SubscribeResponse{" +
                "sn='" + sn + '\'' +
                ", iccid='" + iccid + '\'' +
                ", status='" + status + '\'' +
                ", subscriptionEnded=" + subscriptionEnded +
                ", currentRatePlanSubscription=" + currentRatePlanSubscription +
                ", currentSubCycle=" + currentSubCycle +
                '}';
    }
}
