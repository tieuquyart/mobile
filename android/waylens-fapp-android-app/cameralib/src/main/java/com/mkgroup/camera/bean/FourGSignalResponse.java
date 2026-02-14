package com.mkgroup.camera.bean;

import java.io.Serializable;

/**
 * Created by doanvt on 2018/7/4.
 * Email：doanvt-hn@mk.com.vn
 */

public class FourGSignalResponse implements Serializable{
    public float RSRP;
    public String Band;
    public int DLEarfcn;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        FourGSignalResponse that = (FourGSignalResponse) o;

        if (Float.compare(that.RSRP, RSRP) != 0) return false;
        if (DLEarfcn != that.DLEarfcn) return false;
        return Band != null ? Band.equals(that.Band) : that.Band == null;
    }

    @Override
    public int hashCode() {
        int result = (RSRP != +0.0f ? Float.floatToIntBits(RSRP) : 0);
        result = 31 * result + (Band != null ? Band.hashCode() : 0);
        result = 31 * result + DLEarfcn;
        return result;
    }

    @Override
    public String toString() {
        return "FourGSignalResponse{" +
                "RSRP=" + RSRP +
                ", Band='" + Band + '\'' +
                ", DLEarfcn=" + DLEarfcn +
                '}';
    }
}
