package com.mkgroup.camera.log;

/**
 * Created by DoanVT on 2017/12/11.
 * Email: doanvt-hn@mk.com.vn
 */

public interface CmdResponseListener<T> {
    void onResponse(T response);
}
