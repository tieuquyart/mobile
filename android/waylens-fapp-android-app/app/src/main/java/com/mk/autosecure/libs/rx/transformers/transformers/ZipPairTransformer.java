package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;
import android.util.Pair;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class ZipPairTransformer<T, R> implements ObservableTransformer<T, Pair<T, R>> {
    @NonNull
    private final Observable<R> second;

    public ZipPairTransformer(final @NonNull Observable<R> second) {
        this.second = second;
    }

    @Override
    @NonNull
    public ObservableSource<Pair<T, R>> apply(final @NonNull Observable<T> upstream) {
        return Observable.zip(upstream, second, Pair::new);
    }
}
