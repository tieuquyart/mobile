package com.mk.autosecure.model;

import com.mkgroup.camera.bean.ClipBean;

/**
 * Created by DoanVT on 2017/9/21.
 */

public class ClipBeanPos {
    public long offset;
    private ClipBean clipBean;

    public ClipBean getClipBean() {
        return clipBean;
    }

    public long getOffset() {
        return offset;
    }

    public ClipBeanPos(ClipBean clipBean, long offset) {
        this.clipBean = clipBean;
        this.offset = offset;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ClipBeanPos that = (ClipBeanPos) o;

        if (offset != that.offset) return false;
        return clipBean != null ? clipBean.equals(that.clipBean) : that.clipBean == null;
    }

    @Override
    public int hashCode() {
        int result = (int) (offset ^ (offset >>> 32));
        result = 31 * result + (clipBean != null ? clipBean.hashCode() : 0);
        return result;
    }
}
