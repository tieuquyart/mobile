package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.TrackBean;

import java.util.List;

public class TracksResponse extends Response {

    private List<TrackBean> data;

    public List<TrackBean> getTrack() {
        return data;
    }

    public void setTrack(List<TrackBean> track) {
        this.data = track;
    }

    @Override
    public String toString() {
        return "TracksResponse{" +
                "data=" + data +
                '}';
    }
}
