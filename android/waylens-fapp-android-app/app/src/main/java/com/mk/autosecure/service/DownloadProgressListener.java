package com.mk.autosecure.service;

public interface DownloadProgressListener {
    void update(long bytesRead, long contentLength, boolean done);
}
