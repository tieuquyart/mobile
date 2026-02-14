package com.mk.autosecure.libs;

/**
 * Created by DoanVT on 2017/7/25.
 */


import com.trello.rxlifecycle2.android.FragmentEvent;

import io.reactivex.Observable;

/**
 * A type implements this interface when it can describe its lifecycle in terms of attaching, view creation, starting,
 * stopping, destroying, and detaching.
 */
public interface FragmentLifecycleType {

    /**
     * An observable that describes the lifecycle of the object, from ATTACH to DETACH.
     */
    Observable<FragmentEvent> lifecycle();
}
