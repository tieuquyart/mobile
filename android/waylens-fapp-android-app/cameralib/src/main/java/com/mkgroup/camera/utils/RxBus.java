package com.mkgroup.camera.utils;

import com.jakewharton.rxrelay2.PublishRelay;
import com.jakewharton.rxrelay2.Relay;

import io.reactivex.Observable;


/**
 * Created by doanvt on 2016/8/30.
 */
public class RxBus {

    private final Relay<Object> mBus;

    private RxBus() {
        mBus = PublishRelay.create().toSerialized();
    }

    public static RxBus getDefault() {
        return Holder.BUS;
    }

    public void post(Object o) {
        mBus.accept(o);
    }

    public <T> Observable<T> toObservable(Class<T> eventType) {
        return mBus.ofType(eventType);
    }

    public Observable<Object> toObservable() {
        return mBus;
    }

    public boolean hasObservers() {
        return mBus.hasObservers();
    }

    private static class Holder {
        private static final RxBus BUS = new RxBus();
    }

}