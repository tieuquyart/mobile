package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class WaitUntilTransformer<T, R> implements ObservableTransformer<T, T> {
    @NonNull
    private final Observable<R> until;

    public WaitUntilTransformer(final @NonNull Observable<R> until) {
        this.until = until;
    }

    @Override
    public ObservableSource<T> apply(final @NonNull Observable<T> upstream) {
        return until.take(1).flatMap(__ -> upstream);
    }
}
