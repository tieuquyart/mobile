package com.mkgroup.camera.model;


/**
 * Created by doanvt on 2016/5/5.
 */
public class SpaceInfo {
    public long total;
    public long used;
    public long marked;
    public long clip;

    public long getLoopedSpace() {
        return (clip - marked) + (total - used);
    }

    @Override
    public String toString() {
        return "SpaceInfo{" +
                "total=" + total +
                ", used=" + used +
                ", marked=" + marked +
                ", clip=" + clip +
                '}';
    }
}
