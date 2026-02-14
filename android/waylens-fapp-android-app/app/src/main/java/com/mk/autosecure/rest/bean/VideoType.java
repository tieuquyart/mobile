package com.mk.autosecure.rest.bean;

import java.io.Serializable;

/**
 * Created by doanvt on 2018/12/26.
 * Email：doanvt-hn@mk.com.vn
 */

public class VideoType implements Serializable {

    public VideoType(int icon, String event) {
        this.icon = icon;
        this.event = event;
    }

    public int icon;

    public String event;

    public boolean selected;

    public int getIcon() {
        return icon;
    }

    public void setIcon(int icon) {
        this.icon = icon;
    }

    public String getEvent() {
        return event;
    }

    public void setEvent(String event) {
        this.event = event;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    @Override
    public String toString() {
        return "VideoType{" +
                "icon=" + icon +
                ", event='" + event + '\'' +
                ", selected=" + selected +
                '}';
    }
}
