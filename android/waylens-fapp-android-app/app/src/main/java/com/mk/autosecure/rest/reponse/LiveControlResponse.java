package com.mk.autosecure.rest.reponse;

/**
 * Created by DoanVT on 2017/8/14.
 */

public class LiveControlResponse {
    public boolean result;
    public String url;
    public String playToken;

    @Override
    public String toString() {
        return "LiveControlResponse{" +
                "result=" + result +
                ", url='" + url + '\'' +
                ", playToken='" + playToken + '\'' +
                '}';
    }
}
