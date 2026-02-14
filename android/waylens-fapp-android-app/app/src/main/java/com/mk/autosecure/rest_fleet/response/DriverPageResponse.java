package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;

import java.util.List;

public class DriverPageResponse extends Response {

    private DriverPageResponse.Data data;

    public DriverPageResponse.Data getData() {
        return data;
    }

    public void setData(DriverPageResponse.Data data) {
        this.data = data;
    }

    public class Data{
        private int countId;
        private int current;
        private Boolean hitCount;
        private int pages;
        private List<DriverInfoBean> records;
        private Boolean searchCount;
        private int size;
        private int total;

        public int getCountId() {
            return countId;
        }

        public void setCountId(int countId) {
            this.countId = countId;
        }

        public int getCurrent() {
            return current;
        }

        public void setCurrent(int current) {
            this.current = current;
        }

        public Boolean getHitCount() {
            return hitCount;
        }

        public void setHitCount(Boolean hitCount) {
            this.hitCount = hitCount;
        }

        public int getPages() {
            return pages;
        }

        public void setPages(int pages) {
            this.pages = pages;
        }

        public List<DriverInfoBean> getRecords() {
            return records;
        }

        public void setRecords(List<DriverInfoBean> records) {
            this.records = records;
        }

        public Boolean getSearchCount() {
            return searchCount;
        }

        public void setSearchCount(Boolean searchCount) {
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
            return "Data{" +
                    "countId=" + countId +
                    ", current=" + current +
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
