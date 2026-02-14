package com.mk.autosecure.libs.utils;

import android.os.Looper;

/**
 * Created by DoanVT on 2017/8/9.
 */

public final class ThreadUtils {
    private ThreadUtils() {}

    public static boolean isMainThread() {
        return Looper.getMainLooper().getThread() == Thread.currentThread();
    }
}
