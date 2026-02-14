package com.mk.autosecure.libs;

import com.trello.rxlifecycle2.android.ActivityEvent;

import io.reactivex.Observable;

/**
 * Created by DoanVT on 2017/7/25.
 */

public interface ActivityLifecycleType {

    /**
     * An observable that describes the lifecycle of the object, from CREATE to DESTROY.
     */
    Observable<ActivityEvent> lifecycle();
}
