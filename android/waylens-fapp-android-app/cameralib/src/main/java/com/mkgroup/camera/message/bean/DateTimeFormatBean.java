package com.mkgroup.camera.message.bean;

public class DateTimeFormatBean {

    /**
     * dateFormat : %02m/%02d/%04Y
     * timeFormat : %02H:%02M:%02S
     */

    private String dateFormat;
    private String timeFormat;

    public String getDateFormat() {
        return dateFormat;
    }

    public void setDateFormat(String dateFormat) {
        this.dateFormat = dateFormat;
    }

    public String getTimeFormat() {
        return timeFormat;
    }

    public void setTimeFormat(String timeFormat) {
        this.timeFormat = timeFormat;
    }
}
