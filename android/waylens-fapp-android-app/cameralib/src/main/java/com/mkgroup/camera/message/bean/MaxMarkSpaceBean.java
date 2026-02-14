package com.mkgroup.camera.message.bean;

import java.util.List;

public class MaxMarkSpaceBean {
    /**
     * max : 16
     * list : [8,12,16]
     */

    private int max;
    private List<Integer> list;

    public MaxMarkSpaceBean(int max) {
        this.max = max;
    }

    public int getMax() {
        return max;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public List<Integer> getList() {
        return list;
    }

    public void setList(List<Integer> list) {
        this.list = list;
    }
}
