package com.mkgroup.camera.bean;

public class StopBean {
    String status;
    String dateTime;
    String latitude;
    String longitude;
    String timeOver;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getTimeOver() {
        return timeOver;
    }

    public void setTimeOver(String timeOver) {
        this.timeOver = timeOver;
    }

//    @Override
//    public boolean equals(Object o) {
//        if (this == o) return true;
//        if (!(o instanceof StopBean)) return false;
//        StopBean stopBean = (StopBean) o;
//        return Objects.equals(getStatus(), stopBean.getStatus()) && Objects.equals(getDateTime(), stopBean.getDateTime()) && Objects.equals(getLatitude(), stopBean.getLatitude()) && Objects.equals(getLongitude(), stopBean.getLongitude()) && Objects.equals(getTimeOver(), stopBean.getTimeOver());
//    }
//
//    @Override
//    public int hashCode() {
//        return Objects.hash(getStatus(), getDateTime(), getLatitude(), getLongitude(), getTimeOver());
//    }

    @Override
    public String toString() {
        return "StopBean{" +
                "status='" + status + '\'' +
                ", dateTime='" + dateTime + '\'' +
                ", latitude='" + latitude + '\'' +
                ", longitude='" + longitude + '\'' +
                ", timeOver='" + timeOver + '\'' +
                '}';
    }
}
