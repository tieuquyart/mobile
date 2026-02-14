package com.mkgroup.camera.bean;

import java.io.Serializable;
import java.util.List;

public class LogCameraBean implements Serializable {
    public List<StopBean> stopBeans;
    public List<StartBean> startBeans;
    public List<RecordBean> recordBeans;

    public LogCameraBean(List<StopBean> stopBeans, List<StartBean> startBeans, List<RecordBean> recordBeans) {
        this.stopBeans = stopBeans;
        this.startBeans = startBeans;
        this.recordBeans = recordBeans;
    }

    public List<StopBean> getStopBeans() {
        return stopBeans;
    }

    public void setStopBeans(List<StopBean> stopBeans) {
        this.stopBeans = stopBeans;
    }

    public List<StartBean> getStartBeans() {
        return startBeans;
    }

    public void setStartBeans(List<StartBean> startBeans) {
        this.startBeans = startBeans;
    }

    public List<RecordBean> getRecordBeans() {
        return recordBeans;
    }

    public void setRecordBeans(List<RecordBean> recordBeans) {
        this.recordBeans = recordBeans;
    }

    @Override
    public String toString() {
        return "LogCameraBean{" +
                "stopBeans=" + stopBeans +
                ", startBeans=" + startBeans +
                ", recordBeans=" + recordBeans +
                '}';
    }
}
