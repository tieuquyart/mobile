package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class FleetViewBean  implements Serializable {
    private String countId;
    private double current;
    private double drivingTotal;
    private boolean hitCount;
    private double maxLimit;
    private boolean optimizeCountSql;
    private List<Order> orders;
    private double pages;
    private double parkingTotal;
    private List<FleetViewRecord> records;
    private boolean searchCount;
    private double size;
    private double total;

    public String getCountId() {
        return countId;
    }

    public void setCountId(String countId) {
        this.countId = countId;
    }

    public double getCurrent() {
        return current;
    }

    public void setCurrent(double current) {
        this.current = current;
    }

    public double getDrivingTotal() {
        return drivingTotal;
    }

    public void setDrivingTotal(double drivingTotal) {
        this.drivingTotal = drivingTotal;
    }

    public boolean isHitCount() {
        return hitCount;
    }

    public void setHitCount(boolean hitCount) {
        this.hitCount = hitCount;
    }

    public double getMaxLimit() {
        return maxLimit;
    }

    public void setMaxLimit(double maxLimit) {
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

    public double getPages() {
        return pages;
    }

    public void setPages(double pages) {
        this.pages = pages;
    }

    public double getParkingTotal() {
        return parkingTotal;
    }

    public void setParkingTotal(double parkingTotal) {
        this.parkingTotal = parkingTotal;
    }

    public List<FleetViewRecord> getRecords() {
        return records;
    }

    public void setRecords(List<FleetViewRecord> records) {
        this.records = records;
    }

    public boolean isSearchCount() {
        return searchCount;
    }

    public void setSearchCount(boolean searchCount) {
        this.searchCount = searchCount;
    }

    public double getSize() {
        return size;
    }

    public void setSize(double size) {
        this.size = size;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public static class Order{
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
}

