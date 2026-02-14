package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class IncrementalCountTransformer<T> implements ObservableTransformer<T, Integer> {
    final int firstPage;

    public IncrementalCountTransformer() {
        firstPage = 1;
    }

    public IncrementalCountTransformer(final int firstPage) {
        this.firstPage = firstPage;
    }

    @Override
    public ObservableSource<Integer> apply(final @NonNull Observable<T> upstream) {
        return upstream.scan(firstPage - 1, (accum, __) -> accum + 1).skip(1);
    }
}
