package com.mk.autosecure.libs.operators;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.rest.error.ApiException;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.error.ResponseException;

import java.io.IOException;

import io.reactivex.ObservableOperator;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/11/10.
 * Email: doanvt-hn@mk.com.vn
 */

public final class ApiErrorOperator<T> implements ObservableOperator<T, Response<T>> {
    private final Gson gson;

    public ApiErrorOperator(final @NonNull Gson gson) {
        this.gson = gson;
    }

    @Override
    public Observer<? super Response<T>> apply(Observer<? super T> observer) throws Exception {
        return new Observer<retrofit2.Response<T>>() {
            @Override
            public void onSubscribe(Disposable d) {
                observer.onSubscribe(d);
            }

            @Override
            public void onNext(retrofit2.Response<T> tResponse) {
                if (!tResponse.isSuccessful()) {
                    try {
                        final ErrorEnvelope envelope = gson.fromJson(tResponse.errorBody().string(), ErrorEnvelope.class);
                        observer.onError(new ApiException(envelope, tResponse));
                    } catch (final @NonNull IOException e) {
                        observer.onError(new ResponseException(tResponse));
                    }
                } else {
                    observer.onNext(tResponse.body());
                    observer.onComplete();
                }
            }

            @Override
            public void onError(Throwable e) {
                observer.onError(e);
            }

            @Override
            public void onComplete() {
                observer.onComplete();
            }
        };
    }
}
