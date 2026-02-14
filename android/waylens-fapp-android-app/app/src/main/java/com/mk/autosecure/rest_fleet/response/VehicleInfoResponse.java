package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;

import java.util.List;

public class VehicleInfoResponse extends Response {

    private DataVehicle data;

    public DataVehicle getData() {
        return data;
    }

    public void setData(DataVehicle data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "VehicleInfoResponse{" +
                "data=" + data +
                '}';
    }

    public class DataVehicle{
        private int current;
        private boolean hitCount;
        private int pages;
        private List<VehicleInfoBean> records;
        private boolean searchCount;
        private int size;
        private int total;

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

        public int getPages() {
            return pages;
        }

        public void setPages(int pages) {
            this.pages = pages;
        }

        public List<VehicleInfoBean> getRecords() {
            return records;
        }

        public void setRecords(List<VehicleInfoBean> records) {
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

        public int getTotal() {
            return total;
        }

        public void setTotal(int total) {
            this.total = total;
        }

        @Override
        public String toString() {
            return "DataVehicle{" +
                    "current=" + current +
                    ", hitCount=" + hitCount +
                    ", pages=" + pages +
                    ", records=" + records +
                    ", searchCount=" + searchCount +
                    ", size=" + size +
                    ", total=" + total +
                    '}';
        }
    }
}
