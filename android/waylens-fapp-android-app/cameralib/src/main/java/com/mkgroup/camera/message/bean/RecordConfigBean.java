package com.mkgroup.camera.message.bean;

public class RecordConfigBean {

    /**
     * minBitrateFactor : 50
     * maxBitrateFactor : 150
     * recordConfig : 1080p30
     * bitrateFactor : 100
     */

    private transient int minBitrateFactor;
    private transient int maxBitrateFactor;
    private String recordConfig;
    private transient int bitrateFactor;
    private transient int forceCodec;

    public RecordConfigBean(int forceCodec) {
        this.forceCodec = forceCodec;
    }

    public RecordConfigBean(String recordConfig) {
        this.recordConfig = recordConfig;
    }

    public int getMinBitrateFactor() {
        return minBitrateFactor;
    }

    public void setMinBitrateFactor(int minBitrateFactor) {
        this.minBitrateFactor = minBitrateFactor;
    }

    public int getMaxBitrateFactor() {
        return maxBitrateFactor;
    }

    public void setMaxBitrateFactor(int maxBitrateFactor) {
        this.maxBitrateFactor = maxBitrateFactor;
    }

    public String getRecordConfig() {
        return recordConfig;
    }

    public void setRecordConfig(String recordConfig) {
        this.recordConfig = recordConfig;
    }

    public int getBitrateFactor() {
        return bitrateFactor;
    }

    public void setBitrateFactor(int bitrateFactor) {
        this.bitrateFactor = bitrateFactor;
    }

    public int getForceCodec() {
        return forceCodec;
    }

    public void setForceCodec(int forceCodec) {
        this.forceCodec = forceCodec;
    }

    @Override
    public String toString() {
        return "RecordConfigBean{" +
                "minBitrateFactor=" + minBitrateFactor +
                ", maxBitrateFactor=" + maxBitrateFactor +
                ", recordConfig='" + recordConfig + '\'' +
                ", bitrateFactor=" + bitrateFactor +
                ", forceCodec=" + forceCodec +
                '}';
    }
}
