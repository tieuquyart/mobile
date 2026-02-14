package com.mkgroup.camera.log;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Created by DoanVT on 2017/12/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class CmdRequestFuture<T> implements Future<T>, CmdResponseListener<T> {

    private boolean mResultReceived = false;
    private T mResult;
    private boolean mIsCancelled = false;

    public static <E> CmdRequestFuture<E> newFuture() {
        return new CmdRequestFuture<E>();
    }

    private CmdRequestFuture() {

    }

    @Override
    public synchronized boolean cancel(boolean mayInterruptIfRunning) {
        return false;
    }

    @Override
    public boolean isCancelled() {
        return mIsCancelled;
    }

    @Override
    public boolean isDone() {
        return mResultReceived || isCancelled();
    }

    @Override
    public T get() throws InterruptedException, ExecutionException {
        try {
            return doGet(null);
        } catch (TimeoutException e) {
            throw new AssertionError(e);
        }

    }

    @Override
    public T get(long timeout, TimeUnit unit) throws InterruptedException, ExecutionException, TimeoutException {
        return doGet(TimeUnit.MILLISECONDS.convert(timeout, unit));
    }

    private synchronized T doGet(Long timeoutMs) throws ExecutionException, InterruptedException, TimeoutException {

        if (mResultReceived) {
            return mResult;
        }

        if (timeoutMs == null) {
            wait(0);
        } else if (timeoutMs > 0) {
            wait(timeoutMs);
        }

        if (!mResultReceived) {
            throw new TimeoutException();
        }

        return mResult;
    }

    @Override
    public synchronized void onResponse(T response) {
        mResultReceived = true;
        mResult = response;
        notifyAll();
    }
}
