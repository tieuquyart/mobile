package com.mkgroup.camera.message.bean;

public class RecordModeBean {

    /**
     * autoRecord : true
     * autoDelete : true
     */

    private boolean autoRecord;
    private boolean autoDelete;

    public boolean isAutoRecord() {
        return autoRecord;
    }

    public void setAutoRecord(boolean autoRecord) {
        this.autoRecord = autoRecord;
    }

    public boolean isAutoDelete() {
        return autoDelete;
    }

    public void setAutoDelete(boolean autoDelete) {
        this.autoDelete = autoDelete;
    }
}
