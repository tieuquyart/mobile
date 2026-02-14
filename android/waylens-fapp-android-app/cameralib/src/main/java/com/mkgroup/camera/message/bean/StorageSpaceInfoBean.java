package com.mkgroup.camera.message.bean;

public class StorageSpaceInfoBean {
    /**
     * totalSpace : 31902400512
     * usedSpace : 31139364864
     * markedClipSpace : 16141778944
     * clipSpace : 29174792192
     * canStartRecord : true
     */

    private long totalSpace;
    private long usedSpace;
    private long markedClipSpace;
    private long clipSpace;
    private boolean canStartRecord;

    public long getTotalSpace() {
        return totalSpace;
    }

    public void setTotalSpace(long totalSpace) {
        this.totalSpace = totalSpace;
    }

    public long getUsedSpace() {
        return usedSpace;
    }

    public void setUsedSpace(long usedSpace) {
        this.usedSpace = usedSpace;
    }

    public long getMarkedClipSpace() {
        return markedClipSpace;
    }

    public void setMarkedClipSpace(long markedClipSpace) {
        this.markedClipSpace = markedClipSpace;
    }

    public long getClipSpace() {
        return clipSpace;
    }

    public void setClipSpace(long clipSpace) {
        this.clipSpace = clipSpace;
    }

    public boolean isCanStartRecord() {
        return canStartRecord;
    }

    public void setCanStartRecord(boolean canStartRecord) {
        this.canStartRecord = canStartRecord;
    }
}
