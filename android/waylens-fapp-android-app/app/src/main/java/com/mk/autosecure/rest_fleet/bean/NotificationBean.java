package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;

public class NotificationBean implements Serializable {
    private String id;
    private String category;
    private String eventType;
    private String eventTime;
    private String eventRemark;
    private int fleetId;
    private String fleetName;
    private String createTime;
    private String alert;
    private boolean markRead;
    private String cameraSn;
    private String driverName;
    private String driverId;
    private String plateNo;
    private String clipId;
    private String url;
    private double clipDuration;
    private double gpsLongitude;
    private double gpsLatitude;
    private Object gpsAltitude;
    private int gpsHdop;
    private int gpsVdop;
    private Object gpsHeading;
    private Object gpsSpeed;
    private String gpsTime;
    private String accountName;
    private boolean success;
    private String orderId;
    private String errorMsg;
    private String subscriptionName;
    private int amount;
    private String currency;
    private String eventLevel;
    private boolean statusUpdatePhone;

    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isMarkRead() {
        return markRead;
    }

    public boolean isStatusUpdatePhone() {
        return statusUpdatePhone;
    }

    public void setStatusUpdatePhone(boolean statusUpdatePhone) {
        this.statusUpdatePhone = statusUpdatePhone;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getEventTime() {
        return eventTime;
    }

    public void setEventTime(String eventTime) {
        this.eventTime = eventTime;
    }

    public String getEventRemark() {
        return eventRemark;
    }

    public void setEventRemark(String eventRemark) {
        this.eventRemark = eventRemark;
    }

    public int getFleetId() {
        return fleetId;
    }

    public void setFleetId(int fleetId) {
        this.fleetId = fleetId;
    }

    public String getFleetName() {
        return fleetName;
    }

    public void setFleetName(String fleetName) {
        this.fleetName = fleetName;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getAlert() {
        return alert;
    }

    public void setAlert(String alert) {
        this.alert = alert;
    }

    public boolean getMarkRead() {
        return markRead;
    }

    public void setMarkRead(boolean markRead) {
        this.markRead = markRead;
    }

    public String getCameraSn() {
        return cameraSn;
    }

    public void setCameraSn(String cameraSn) {
        this.cameraSn = cameraSn;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getPlateNo() {
        return plateNo;
    }

    public void setPlateNo(String plateNo) {
        this.plateNo = plateNo;
    }

    public String getClipId() {
        return clipId;
    }

    public void setClipId(String clipId) {
        this.clipId = clipId;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public double getClipDuration() {
        return clipDuration;
    }

    public void setClipDuration(double clipDuration) {
        this.clipDuration = clipDuration;
    }

    public double getGpsLongitude() {
        return gpsLongitude;
    }

    public void setGpsLongitude(double gpsLongitude) {
        this.gpsLongitude = gpsLongitude;
    }

    public double getGpsLatitude() {
        return gpsLatitude;
    }

    public void setGpsLatitude(double gpsLatitude) {
        this.gpsLatitude = gpsLatitude;
    }

    public Object getGpsAltitude() {
        return gpsAltitude;
    }

    public void setGpsAltitude(Object gpsAltitude) {
        this.gpsAltitude = gpsAltitude;
    }

    public int getGpsHdop() {
        return gpsHdop;
    }

    public void setGpsHdop(int gpsHdop) {
        this.gpsHdop = gpsHdop;
    }

    public int getGpsVdop() {
        return gpsVdop;
    }

    public void setGpsVdop(int gpsVdop) {
        this.gpsVdop = gpsVdop;
    }

    public Object getGpsHeading() {
        return gpsHeading;
    }

    public void setGpsHeading(Object gpsHeading) {
        this.gpsHeading = gpsHeading;
    }

    public Object getGpsSpeed() {
        return gpsSpeed;
    }

    public void setGpsSpeed(Object gpsSpeed) {
        this.gpsSpeed = gpsSpeed;
    }

    public String getGpsTime() {
        return gpsTime;
    }

    public void setGpsTime(String gpsTime) {
        this.gpsTime = gpsTime;
    }

    public String getAccountName() {
        return accountName;
    }

    public void setAccountName(String accountName) {
        this.accountName = accountName;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getErrorMsg() {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }

    public String getSubscriptionName() {
        return subscriptionName;
    }

    public void setSubscriptionName(String subscriptionName) {
        this.subscriptionName = subscriptionName;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }


    public String getEventLevel() {
        return eventLevel;
    }

    public void setEventLevel(String eventLevel) {
        this.eventLevel = eventLevel;
    }

    @Override
    public String toString() {
        return "NotificationBean{" +
                "id='" + id + '\'' +
                ", category='" + category + '\'' +
                ", eventType='" + eventType + '\'' +
                ", eventTime='" + eventTime + '\'' +
                ", eventRemark='" + eventRemark + '\'' +
                ", fleetId=" + fleetId +
                ", fleetName='" + fleetName + '\'' +
                ", createTime='" + createTime + '\'' +
                ", alert='" + alert + '\'' +
                ", markRead=" + markRead +
                ", cameraSn='" + cameraSn + '\'' +
                ", driverName='" + driverName + '\'' +
                ", driverId='" + driverId + '\'' +
                ", plateNo='" + plateNo + '\'' +
                ", clipId='" + clipId + '\'' +
                ", url='" + url + '\'' +
                ", clipDuration=" + clipDuration +
                ", gpsLongitude=" + gpsLongitude +
                ", gpsLatitude=" + gpsLatitude +
                ", gpsAltitude=" + gpsAltitude +
                ", gpsHdop=" + gpsHdop +
                ", gpsVdop=" + gpsVdop +
                ", gpsHeading=" + gpsHeading +
                ", gpsSpeed=" + gpsSpeed +
                ", gpsTime='" + gpsTime + '\'' +
                ", accountName='" + accountName + '\'' +
                ", success=" + success +
                ", orderId='" + orderId + '\'' +
                ", errorMsg='" + errorMsg + '\'' +
                ", subscriptionName='" + subscriptionName + '\'' +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                ", eventLevel='" + eventLevel + '\'' +
                ", statusUpdatePhone=" + statusUpdatePhone +
                ", content='" + content + '\'' +
                '}';
    }
}
