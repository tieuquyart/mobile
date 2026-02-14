package com.mk.autosecure.libs.utils;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by DoanVT on 2017/7/25.
 */

public final class BundleUtils {
    private BundleUtils() {}

    public static Bundle maybeGetBundle(final @Nullable Bundle state, final @NonNull String key) {
        if (state == null) {
            return null;
        }

        return state.getBundle(key);
    }
}
