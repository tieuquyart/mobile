package com.mk.autosecure.service.upload;

/**
 * Created by doanvt on 2016/9/9.
 */
public interface UploadProgressListener {
    void update(long bytesWritten, long contentLength, boolean done);
}
