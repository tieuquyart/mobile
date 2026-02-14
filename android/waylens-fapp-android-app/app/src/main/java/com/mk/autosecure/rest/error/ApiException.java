package com.mk.autosecure.rest.error;

/**
 * Created by DoanVT on 2017/11/10.
 * Email: doanvt-hn@mk.com.vn
 */

import androidx.annotation.NonNull;

/**
 * An exception class wrapping an {@link ErrorEnvelope}.
 */
public final class ApiException extends ResponseException {
    private final ErrorEnvelope errorEnvelope;

    public ApiException(final @NonNull ErrorEnvelope errorEnvelope, final @NonNull retrofit2.Response response) {
        super(response);
        this.errorEnvelope = errorEnvelope;
    }

    public @NonNull ErrorEnvelope errorEnvelope() {
        return errorEnvelope;
    }
}
