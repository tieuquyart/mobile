package com.mk.autosecure.libs.operators;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

/**
 * Created by DoanVT on 2017/11/10.
 * Email: doanvt-hn@mk.com.vn
 */

public class Operators {
    private Operators() {}

    public static @NonNull <T> ApiErrorOperator<T> apiError(final @NonNull Gson gson) {
        return new ApiErrorOperator<>(gson);
    }
}
