package com.mkgroup.camera.data.vdb;


import com.mkgroup.camera.data.SnipeError;

/**
 * Created by doanvt on 2016/6/28.
 */
public interface RetryPolicy {
    int getCurrentTimeout();

    int getCurrentRetryCount();

    void retry(SnipeError error) throws SnipeError;
}
