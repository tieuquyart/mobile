package com.mk.autosecure.service;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;

/**
 * Created by doanvt on 17/3/20.
 */

public class DownloadSupport {
    public static final String TAG = DownloadSupport.class.getSimpleName();

    private OkHttpClient okHttpClient;

    private static DownloadSupport mInstance = null;

    public static DownloadSupport getInstance() {
        if (mInstance == null) {
            synchronized (DownloadSupport.class) {
                if (mInstance == null) {
                    mInstance = new DownloadSupport();
                }
            }
        }
        return mInstance;
    }

    private DownloadSupport() {
        okHttpClient = new OkHttpClient().newBuilder().build();
    }

    public OkHttpClient getHttpClient() {
        return okHttpClient;
    }

    public Call newCall(String url) {
        Request request = new Request.Builder().url(url).build();
        return okHttpClient.newCall(request);
    }
}
