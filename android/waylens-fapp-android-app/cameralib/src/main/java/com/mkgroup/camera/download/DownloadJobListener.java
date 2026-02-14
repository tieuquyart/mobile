package com.mkgroup.camera.download;

/**
 * Created by DoanVT on 2017/12/23.
 * Email: doanvt-hn@mk.com.vn
 */

public interface DownloadJobListener {

    void onComplete(String key);

    void onError(String key);
}
