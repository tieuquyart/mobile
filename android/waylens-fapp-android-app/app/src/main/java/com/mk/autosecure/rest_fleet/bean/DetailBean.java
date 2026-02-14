package com.mk.autosecure.rest_fleet.bean;

import java.util.List;

public class DetailBean {
    private String countId;
    private int current;
    private boolean hitCount;
    private int maxLimit;
    private boolean optimizeCountSql;
    private List<Order> orders;
    private int page;
    private List<Record> records;
    private boolean searchCount;
    private int size;
    private double total;

    public String getCountId() {
        return countId;
    }

    public void setCountId(String countId) {
        this.countId = countId;
    }

    public int getCurrent() {
        return current;
    }

    public void setCurrent(int current) {
        this.current = current;
    }

    public boolean isHitCount() {
        return hitCount;
    }

    public void setHitCount(boolean hitCount) {
        this.hitCount = hitCount;
    }

    public int getMaxLimit() {
        return maxLimit;
    }

    public void setMaxLimit(int maxLimit) {
        this.maxLimit = maxLimit;
    }

    public boolean isOptimizeCountSql() {
        return optimizeCountSql;
    }

    public void setOptimizeCountSql(boolean optimizeCountSql) {
        this.optimizeCountSql = optimizeCountSql;
    }

    public List<Order> getOrders() {
        return orders;
    }

    public void setOrders(List<Order> orders) {
        this.orders = orders;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public List<Record> getRecords() {
        return records;
    }

    public void setRecords(List<Record> records) {
        this.records = records;
    }

    public boolean isSearchCount() {
        return searchCount;
    }

    public void setSearchCount(boolean searchCount) {
        this.searchCount = searchCount;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    private class Order{
        private boolean asc;
        private String column;

        public boolean isAsc() {
            return asc;
        }

        public void setAsc(boolean asc) {
            this.asc = asc;
        }

        public String getColumn() {
            return column;
        }

        public void setColumn(String column) {
            this.column = column;
        }
    }

    public class Record{
        private String cameraSn;
        private double distanceTotal;
        private int driverId;
        private String driverName;
        private double eventTotal;
        private double hoursTotal;
        private String plateNo;
        private String summaryTime;

        public String getCameraSn() {
            return cameraSn;
        }

        public void setCameraSn(String cameraSn) {
            this.cameraSn = cameraSn;
        }

        public double getDistanceTotal() {
            return distanceTotal;
        }

        public void setDistanceTotal(double distanceTotal) {
            this.distanceTotal = distanceTotal;
        }

        public int getDriverId() {
            return driverId;
        }

        public void setDriverId(int driverId) {
            this.driverId = driverId;
        }

        public String getDriverName() {
            return driverName;
        }

        public void setDriverName(String driverName) {
            this.driverName = driverName;
        }

        public double getEventTotal() {
            return eventTotal;
        }

        public void setEventTotal(double eventTotal) {
            this.eventTotal = eventTotal;
        }

        public double getHoursTotal() {
            return hoursTotal;
        }

        public void setHoursTotal(double hoursTotal) {
            this.hoursTotal = hoursTotal;
        }

        public String getPlateNo() {
            return plateNo;
        }

        public void setPlateNo(String plateNo) {
            this.plateNo = plateNo;
        }

        public String getSummaryTime() {
            return summaryTime;
        }

        public void setSummaryTime(String summaryTime) {
            this.summaryTime = summaryTime;
        }
    }
}
