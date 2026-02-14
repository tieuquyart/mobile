package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class IgnoreValuesTransformer<S> implements ObservableTransformer<S, Void> {

    @Override
    @NonNull
    public ObservableSource<Void> apply(final @NonNull Observable<S> upstream) {
        return upstream.map(__ -> null);
    }
}
