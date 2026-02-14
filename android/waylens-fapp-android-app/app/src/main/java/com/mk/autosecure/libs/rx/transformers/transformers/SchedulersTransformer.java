package com.mk.autosecure.libs.rx.transformers.transformers;

import androidx.annotation.NonNull;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2018/11/13.
 * Email：doanvt-hn@mk.com.vn
 */

public final class SchedulersTransformer<T> implements ObservableTransformer<T, T> {

    @Override
    @NonNull
    public ObservableSource<T> apply(final @NonNull Observable<T> upstream) {
        return upstream
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

}
