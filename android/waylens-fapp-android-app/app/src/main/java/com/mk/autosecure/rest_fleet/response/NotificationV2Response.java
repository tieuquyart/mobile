package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.NotificationBean;

import java.io.Serializable;
import java.util.ArrayList;

public class NotificationV2Response extends Response {

    private ObNoti data;

    public ObNoti getData() {
        return data;
    }

    public void setData(ObNoti data) {
        this.data = data;
    }


    public static class ObNoti implements Serializable {
        private ArrayList<NotificationBean> content;
        private int number;
        private int size;
        private int totalPages;

        public ArrayList<NotificationBean> getContent() {
            return content;
        }

        public void setContent(ArrayList<NotificationBean> content) {
            this.content = content;
        }

        public int getNumber() {
            return number;
        }

        public void setNumber(int number) {
            this.number = number;
        }

        public int getSize() {
            return size;
        }

        public void setSize(int size) {
            this.size = size;
        }

        public int getTotalPages() {
            return totalPages;
        }

        public void setTotalPages(int totalPages) {
            this.totalPages = totalPages;
        }

        @Override
        public String toString() {
            return "ObNoti{" +
                    "content=" + content +
                    ", number=" + number +
                    ", size=" + size +
                    ", totalPages=" + totalPages +
                    '}';
        }
    }
}
