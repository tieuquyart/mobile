package com.mk.autosecure.model;

import java.io.Serializable;

/**
 * Created by doanvt on 2022/11/02.
 */
public class LogTimeStopBean implements Serializable {
    private String timeStart;
    private String timeFinish;
    private double timeStop;

    public LogTimeStopBean(String timeStart, String timeFinish, double timeStop) {
        this.timeStart = timeStart;
        this.timeFinish = timeFinish;
        this.timeStop = timeStop;
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

    public double getTimeStop() {
        return timeStop;
    }
}
