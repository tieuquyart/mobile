package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.data.SnipeError;
import com.orhanobut.logger.Logger;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class DmsRequestFuture<T> implements Future<T>, DmsResponse.Listener<T>, DmsResponse.ErrorListener {

    private final static String TAG = DmsRequestFuture.class.getSimpleName();

    private DmsRequest<?> mDmsRequest;
    private boolean mResultReceived = false;
    private T mResult;
    private SnipeError mError;

    public static <E> DmsRequestFuture<E> newFuture() {
        return new DmsRequestFuture<>();
    }

    private DmsRequestFuture() {

    }

    public void setRequest(DmsRequest<?> request) {
        this.mDmsRequest = request;
    }

    @Override
    public synchronized void onResponse(T response) {
        mResultReceived = true;
        mResult = response;
        notifyAll();
    }

    @Override
    public synchronized void onErrorResponse(SnipeError error) {
        Logger.t(TAG).e("onErrorResponse: " + error);
        mError = error;
        notifyAll();
    }

    @Override
    public synchronized boolean cancel(boolean mayInterruptIfRunning) {
        if (mDmsRequest == null) {
            return false;
        }
        if (!isDone()) {
            mDmsRequest.cancel();
            return true;
        } else {
            return false;
        }
    }

    @Override
    public boolean isCancelled() {
        if (mDmsRequest == null) {
            return false;
        }
        return mDmsRequest.isCanceled();
    }

    @Override
    public boolean isDone() {
        return mResultReceived || mError != null || isCancelled();
    }

    @Override
    public T get() throws ExecutionException, InterruptedException {
        try {
            return doGet(null);
        } catch (TimeoutException e) {
            throw new AssertionError(e);
        }
    }

    @Override
    public T get(long timeout, TimeUnit unit) throws ExecutionException, InterruptedException, TimeoutException {
        return doGet(TimeUnit.MILLISECONDS.convert(timeout, unit));
    }

    private synchronized T doGet(Long timeout) throws ExecutionException, InterruptedException, TimeoutException {
        if (mError != null) {
            throw new ExecutionException(mError);
        }

        if (mResultReceived) {
            return mResult;
        }

        if (timeout == null) {
            wait(0);
        } else if (timeout > 0) {
            wait(timeout);
        }

        if (mError != null) {
            throw new ExecutionException(mError);
        }

        if (!mResultReceived) {
            throw new TimeoutException();
        }

        return mResult;
    }
}
