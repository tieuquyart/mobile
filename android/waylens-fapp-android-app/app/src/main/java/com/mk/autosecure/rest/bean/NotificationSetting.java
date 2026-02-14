package com.mk.autosecure.rest.bean;

/**
 * Created by doanvt on 2018/10/11.
 * Email：doanvt-hn@mk.com.vn
 */

public class NotificationSetting {

    public String PARKING_MOTION;

    public String DRIVING_HIT;
    public String DRIVING_HEAVY_HIT;

    public String PARKING_HIT;
    public String PARKING_HEAVY_HIT;

    @Override
    public String toString() {
        return "NotificationSetting{" +
                "PARKING_MOTION='" + PARKING_MOTION + '\'' +
                ", DRIVING_HIT='" + DRIVING_HIT + '\'' +
                ", DRIVING_HEAVY_HIT='" + DRIVING_HEAVY_HIT + '\'' +
                ", PARKING_HIT='" + PARKING_HIT + '\'' +
                ", PARKING_HEAVY_HIT='" + PARKING_HEAVY_HIT + '\'' +
                '}';
    }
}
