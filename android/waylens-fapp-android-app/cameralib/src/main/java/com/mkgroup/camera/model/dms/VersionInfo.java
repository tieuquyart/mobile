package com.mkgroup.camera.model.dms;

public class VersionInfo {

    public int major;
    public int minor;
    public long vendor;

    @Override
    public String toString() {
        return "VersionInfo{" +
                "major=" + major +
                ", minor=" + minor +
                ", vendor=" + vendor +
                '}';
    }
}
