package com.mkgroup.camera.model.rawdata;

import com.mkgroup.camera.utils.ToStringUtils;

/**
 * Created by DoanVT on 2017/8/11.
 */
public class RawDataItem {
    public static final int DATA_TYPE_NONE = 0;
    public static final int DATA_TYPE_GPS = 1;
    public static final int DATA_TYPE_IIO = 2;
    public static final int DATA_TYPE_OBD = 3;
    public static final int DATA_TYPE_WEATHER = 4;
    public static final int DATA_TYPE_DMS0 = ('D' << 24) + ('M' << 16) + ('S' << 8) + '0';
    public static final int DATA_TYPE_DMS1 = ('D' << 24) + ('M' << 16) + ('S' << 8) + '1';


    private final int mType;
    private long mPtsMs;
    public Object data;
    public byte[] originData;

    public RawDataItem(int type, long ptsMs) {
        this.mType = type;
        this.mPtsMs = ptsMs;
    }

    public RawDataItem(RawDataItem other) {
        this.mType = other.mType;
        this.mPtsMs = other.mPtsMs;
        this.data = other.data;
    }


    public int getType() {
        return mType;
    }

    public long getPtsMs() {
        return mPtsMs;
    }

    public void setPtsMs(long pts) {
        mPtsMs = pts;
    }

    @Override
    public String toString() {
        return ToStringUtils.getString(this);
    }
}
