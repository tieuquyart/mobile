package com.mk.autosecure.libs.utils;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import android.util.Pair;

/**
 * Created by DoanVT on 2017/8/10.
 */

public final class TransitionUtils {
    private TransitionUtils() {}

    /**
     * Explicitly set a transition after starting an activity.
     *
     * @param context The activity that started the new intent.
     * @param transition A pair of animation ids, first is the enter animation, second is the exit animation.
     */
    public static void transition(final @NonNull Context context, final @NonNull Pair<Integer, Integer> transition) {
        if (!(context instanceof Activity)) {
            return;
        }

        final Activity activity = (Activity) context;
        activity.overridePendingTransition(transition.first, transition.second);
    }

}