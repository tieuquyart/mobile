package com.mk.autosecure.model;

import java.io.Serializable;

/**
 * Created by doanvt on 2022/11/02.
 */
public class LogTimeDrivingBean implements Serializable {
    private String driverName;
    private String timeStart;
    private String timeFinish;
    private double timeDriving;

    public LogTimeDrivingBean(String driverName,String timeStart, String timeFinish, double timeDriving) {
        this.driverName = driverName;
        this.timeStart = timeStart;
        this.timeFinish = timeFinish;
        this.timeDriving = timeDriving;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getTimeStart() {
        return timeStart;
    }

    public void setTimeStart(String timeStart) {
        this.timeStart = timeStart;
    }

    public String getTimeFinish() {
        return timeFinish;
    }

    public void setTimeFinish(String timeFinish) {
        this.timeFinish = timeFinish;
    }

    public double getTimeDriving() {
        return timeDriving;
    }

    public void setTimeDriving(double timeDriving) {
        this.timeDriving = timeDriving;
    }
}
