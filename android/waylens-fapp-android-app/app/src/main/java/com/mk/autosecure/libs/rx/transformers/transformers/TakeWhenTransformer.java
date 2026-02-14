package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;


/**
 * Created by doanvt on 2022/11/02.
 */
public final class TakeWhenTransformer<S, T> implements ObservableTransformer<S, S> {
    @NonNull
    private final Observable<T> when;

    public TakeWhenTransformer(final @NonNull Observable<T> when) {
        this.when = when;
    }

    @Override
    @NonNull
    public ObservableSource<S> apply(final @NonNull Observable<S> upstream) {
        return when.withLatestFrom(upstream, (__, x) -> x);
    }
}
