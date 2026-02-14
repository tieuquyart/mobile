package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;
import android.util.Pair;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class CombineLatestPairTransformer<S, T> implements ObservableTransformer<S, Pair<S, T>> {
    @NonNull
    private final Observable<T> second;

    public CombineLatestPairTransformer(final @NonNull Observable<T> second) {
        this.second = second;
    }

    @Override
    @NonNull
    public ObservableSource<Pair<S, T>> apply(final @NonNull Observable<S> upstream) {
        return Observable.combineLatest(upstream, second, Pair::new);
    }
}
