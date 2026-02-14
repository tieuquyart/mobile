package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import com.mk.autosecure.libs.utils.ThreadUtils;

import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2022/11/02.
 */
public final class ObserveForUITransformer<T> implements ObservableTransformer<T, T> {

    @Override
    public @NonNull ObservableSource<T> apply(final @NonNull Observable<T> upstream) {
        return upstream.flatMap(value -> {
            if (ThreadUtils.isMainThread()) {
                return Observable.just(value).observeOn(Schedulers.trampoline());
            } else {
                return Observable.just(value).observeOn(AndroidSchedulers.mainThread());
            }
        });
    }

}
