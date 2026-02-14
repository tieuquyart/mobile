package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.rest.error.ErrorEnvelope;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;
import io.reactivex.functions.Consumer;

/**
 * Created by DoanVT on 2017/11/13.
 * Email: doanvt-hn@mk.com.vn
 */

final class NeverApiErrorTransformer<T> implements ObservableTransformer<T, T> {
    private final @Nullable
    Consumer<ErrorEnvelope> errorAction;

    protected NeverApiErrorTransformer() {
        this.errorAction = null;
    }

    protected NeverApiErrorTransformer(final @Nullable Consumer<ErrorEnvelope> errorAction) {
        this.errorAction = errorAction;
    }

    @Override
    public @NonNull ObservableSource<T> apply(final @NonNull Observable<T> upstream) {
        return upstream
                .doOnError(e -> {
                    final ErrorEnvelope env = ErrorEnvelope.fromThrowable(e);
                    if (env != null && errorAction != null) {
                        errorAction.accept(env);
                    }
                })
                .onErrorResumeNext(e -> {
                    if (ErrorEnvelope.fromThrowable(e) == null) {
                        return Observable.error(e);
                    } else {
                        return Observable.empty();
                    }
                });
    }
}
