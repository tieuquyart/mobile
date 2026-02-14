package com.mk.autosecure.libs.rx.transformers.transformers;


import androidx.annotation.NonNull;

import io.reactivex.Notification;
import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class CompletedTransformer<T> implements ObservableTransformer<Notification<T>, Void> {

    @Override
    public @NonNull ObservableSource<Void> apply(final @NonNull Observable<Notification<T>> upstream) {
        return upstream
                .filter(Notification::isOnComplete)
                .map(__ -> null);
    }
}

