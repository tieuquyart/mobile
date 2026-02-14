package com.mkgroup.camera.data.dms;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

public class DmsRequestQueue {

    private final static String TAG = DmsRequestQueue.class.getSimpleName();

    private final static int MAX_PENDING_REQUEST_COUNT = 2;
    private final static int MAX_PENDING_THUMBNAIL_REQUEST_COUNT = 1;

    private final ConcurrentHashMap<Long, DmsRequest<?>> mCurrentDmsRequests = new ConcurrentHashMap<>();

    private final ConcurrentHashMap<Integer, DmsMessageHandler<?>> mMessageHandlers = new ConcurrentHashMap<>();

    private final PriorityBlockingQueue<DmsRequest<?>> mRequestQueue = new PriorityBlockingQueue<>();

    private final PriorityBlockingQueue<DmsRequest<?>> mWaitingQueue = new PriorityBlockingQueue<>();

    private AtomicInteger mPendingRequestCount = new AtomicInteger();

    private volatile DmsRequest<?> mFinalDmsRequest;

    private final ISocket mISocket;
    private final IResponseDelivery mDelivery;

    private DmsDispatcher mDmsDispatcher;
    private DmsResponseDispatcher mDmsResponseDispatcher;

    public DmsRequestQueue(ISocket iSocket) {
        this(iSocket, new DmsExecutorDelivery(new Handler(Looper.getMainLooper())));
    }

    private DmsRequestQueue(ISocket iSocket, IResponseDelivery delivery) {
        this.mISocket = iSocket;
        this.mDelivery = delivery;
    }

    public void start() {
        stop();

        mDmsDispatcher = new DmsDispatcher(mRequestQueue, mISocket, mDelivery);
        mDmsDispatcher.start();

        mDmsResponseDispatcher = new DmsResponseDispatcher(mCurrentDmsRequests, mMessageHandlers, mISocket, mDelivery);
        mDmsResponseDispatcher.start();
    }

    public void stop() {
        if (mDmsDispatcher != null) {
            mDmsDispatcher.quit();
            mDmsDispatcher = null;
        }
        if (mDmsResponseDispatcher != null) {
            mDmsResponseDispatcher.quit();
            mDmsResponseDispatcher = null;
        }
    }

    public <T> void registerMessageHandler(DmsMessageHandler<T> messageHandler) {
        messageHandler.setRequestQueue(this);
        mMessageHandlers.put(messageHandler.getMessageCode(), messageHandler);
    }

    public DmsMessageHandler<?> unregisterMessageHandler(int msgCode) {
        return mMessageHandlers.remove(msgCode);
    }

    public <T> DmsRequest<T> add(DmsRequest<T> dmsRequest) {
        dmsRequest.setRequestQueue(this);
        dmsRequest.addMarker("add-to-queue");

        if (mCurrentDmsRequests.size() > MAX_PENDING_REQUEST_COUNT) {
            if (dmsRequest.isIgnorable()) {
                if (mPendingRequestCount.get() >= MAX_PENDING_THUMBNAIL_REQUEST_COUNT) {
                    mFinalDmsRequest = dmsRequest;
                } else {
                    mPendingRequestCount.incrementAndGet();
                    mWaitingQueue.offer(dmsRequest);
                }
            } else {
                mWaitingQueue.offer(dmsRequest);
            }
        } else {
            if (dmsRequest.isIgnorable()) {
                if (mPendingRequestCount.get() >= MAX_PENDING_REQUEST_COUNT) {
                    mFinalDmsRequest = dmsRequest;
                } else {
                    mCurrentDmsRequests.put(dmsRequest.getSequence(), dmsRequest);
                    mPendingRequestCount.incrementAndGet();
                    mRequestQueue.offer(dmsRequest);
                }
            } else {
                mCurrentDmsRequests.put(dmsRequest.getSequence(), dmsRequest);
                mRequestQueue.offer(dmsRequest);
            }
        }
        return dmsRequest;
    }

    <T> void finish(DmsRequest<T> dmsRequest) {
        if (dmsRequest.isIgnorable()) {
            mPendingRequestCount.decrementAndGet();
        }
        mCurrentDmsRequests.remove(dmsRequest.getSequence());

        if (mCurrentDmsRequests.size() >= MAX_PENDING_REQUEST_COUNT) {
            return;
        }

        if (mPendingRequestCount.get() < MAX_PENDING_THUMBNAIL_REQUEST_COUNT && mFinalDmsRequest != null) {
            mPendingRequestCount.incrementAndGet();
            DmsRequest tempDmsRequest = mFinalDmsRequest;
            mWaitingQueue.offer(tempDmsRequest);
            mFinalDmsRequest = null;
        }

        if (mRequestQueue.size() < MAX_PENDING_REQUEST_COUNT && mWaitingQueue.size() > 0) {
            DmsRequest waitRequest = mWaitingQueue.poll();
            mCurrentDmsRequests.put(waitRequest.getSequence(), waitRequest);
            mRequestQueue.offer(waitRequest);
        }
    }

    public void cancelAll() {
        for (DmsRequest<?> request : mCurrentDmsRequests.values()) {
            request.cancel();
        }
    }

    public void cancelAll(final Object tag) {
        if (tag == null) {
            throw new IllegalArgumentException("Cannot cancelAll with a null tag");
        }

        cancelAll(request -> {
            if (request.getTag() == null) {
                return false;
            }
            return request.getTag().equals(tag);
        });
    }

    public void cancelAll(RequestFilter filter) {
        for (DmsRequest<?> request : mCurrentDmsRequests.values()) {
            if (filter.apply(request)) {
                request.cancel();
            }
        }
    }

    public interface RequestFilter {
        boolean apply(DmsRequest<?> request);
    }
}
