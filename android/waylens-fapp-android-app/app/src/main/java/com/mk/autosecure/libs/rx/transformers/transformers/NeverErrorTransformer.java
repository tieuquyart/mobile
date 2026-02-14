package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;
import io.reactivex.functions.Consumer;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class NeverErrorTransformer<T> implements ObservableTransformer<T, T> {
    private final @Nullable
    Consumer<Throwable> errorAction;

    protected NeverErrorTransformer() {
        this.errorAction = null;
    }

    protected NeverErrorTransformer(final @Nullable Consumer<Throwable> errorAction) {
        this.errorAction = errorAction;
    }

    @Override
    @NonNull
    public ObservableSource<T> apply(final @NonNull Observable<T> upstream) {
        return upstream
                .doOnError(e -> {
                    if (errorAction != null) {
                        errorAction.accept(e);
                    }
                })
                .onErrorResumeNext(Observable.empty());
    }
}
