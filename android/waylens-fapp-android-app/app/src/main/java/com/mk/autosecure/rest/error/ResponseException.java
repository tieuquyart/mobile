package com.mk.autosecure.rest.error;

import androidx.annotation.NonNull;

/**
 * Created by DoanVT on 2017/11/10.
 * Email: doanvt-hn@mk.com.vn
 */

public class ResponseException extends RuntimeException {
    private final retrofit2.Response response;

    public ResponseException(final @NonNull retrofit2.Response response) {
        this.response = response;
    }

    public @NonNull retrofit2.Response response() {
        return response;
    }
}
