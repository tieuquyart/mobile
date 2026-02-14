package com.mkgroup.camera.data.vdb;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * VdbRequestQueue
 * Created by doanvt on 2015/8/17.
 */
public class VdbRequestQueue {

    private static final String TAG = VdbRequestQueue.class.getSimpleName();

    private static final int MAX_PENDING_REQUEST_COUNT = 2;
    private static final int MAX_PENDING_THUMBNAIL_REQUEST_COUNT = 1;

    //private final Set<VdbRequest<?>> mCurrentVdbRequests = new HashSet<VdbRequest<?>>();
    private final ConcurrentHashMap<Integer, VdbRequest<?>> mCurrentVdbRequests = new ConcurrentHashMap<>();

    private final ConcurrentHashMap<Integer, VdbMessageHandler<?>> mMessageHandlers = new ConcurrentHashMap<>();

    private final PriorityBlockingQueue<VdbRequest<?>> mRequestQueue = new PriorityBlockingQueue<>();

    private final PriorityBlockingQueue<VdbRequest<?>> mWaitingQueue = new PriorityBlockingQueue<>();

    private AtomicInteger mPendingResponseCount = new AtomicInteger();

    private volatile VdbRequest<?> mFinalVdbRequest;

    private final VdbSocket mVdbSocket;
    private final ResponseDelivery mDelivery;

    private VdbDispatcher mVdbDispatcher;
    private VdbResponseDispatcher mVdbResponseDispatcher;

    public VdbRequestQueue(VdbSocket vdbSocket) {
        this(vdbSocket, new ExecutorDelivery(new Handler(Looper.getMainLooper())));
    }

    private VdbRequestQueue(VdbSocket vdbSocket, ResponseDelivery delivery) {
        this.mVdbSocket = vdbSocket;
        this.mDelivery = delivery;
    }

    public void start() {
        stop();

        mVdbDispatcher = new VdbDispatcher(mRequestQueue, mVdbSocket, mDelivery);
        mVdbDispatcher.start();

        mVdbResponseDispatcher = new VdbResponseDispatcher(mCurrentVdbRequests, mMessageHandlers, mVdbSocket, mDelivery);
        mVdbResponseDispatcher.start();
    }

    public void stop() {
        if (mVdbDispatcher != null) {
            mVdbDispatcher.quit();
            mVdbDispatcher = null;
        }
        if (mVdbResponseDispatcher != null) {
            mVdbResponseDispatcher.quit();
            mVdbResponseDispatcher = null;
        }
    }

    public <T> void registerMessageHandler(VdbMessageHandler<T> messageHandler) {
        messageHandler.setRequestQueue(this);
        mMessageHandlers.put(messageHandler.getMessageCode(), messageHandler);
    }

    public VdbMessageHandler<?> unregisterMessageHandler(int msgCode) {
        return mMessageHandlers.remove(msgCode);
    }

    public <T> VdbRequest<T> add(VdbRequest<T> vdbRequest) {
        vdbRequest.setRequestQueue(this);
        vdbRequest.addMarker("add-to-queue");

        if (mCurrentVdbRequests.size() >= MAX_PENDING_REQUEST_COUNT) {
            if (vdbRequest.isIgnorable()) {
                if (mPendingResponseCount.get() >= MAX_PENDING_THUMBNAIL_REQUEST_COUNT) {
                    mFinalVdbRequest = vdbRequest;
                } else {
                    mPendingResponseCount.incrementAndGet();
                    mWaitingQueue.offer(vdbRequest);
                }
            } else {
                mWaitingQueue.offer(vdbRequest);
            }
        } else {
            if (vdbRequest.isIgnorable()) {
                if (mPendingResponseCount.get() >= MAX_PENDING_REQUEST_COUNT) {
                    mFinalVdbRequest = vdbRequest;
                } else {
                    mCurrentVdbRequests.put(vdbRequest.getSequence(), vdbRequest);
                    mPendingResponseCount.incrementAndGet();
                    mRequestQueue.offer(vdbRequest);
                }
            } else {
                mCurrentVdbRequests.put(vdbRequest.getSequence(), vdbRequest);
                mRequestQueue.offer(vdbRequest);
            }
        }
        return vdbRequest;
    }

    <T> void finish(VdbRequest<T> vdbRequest) {
        if (vdbRequest.isIgnorable()) {
            mPendingResponseCount.decrementAndGet();
        }
        mCurrentVdbRequests.remove(vdbRequest.getSequence());

        if (mCurrentVdbRequests.size() >= MAX_PENDING_REQUEST_COUNT) {
            return;
        }

        if (mPendingResponseCount.get() < MAX_PENDING_THUMBNAIL_REQUEST_COUNT
                && mFinalVdbRequest != null) {
            mPendingResponseCount.incrementAndGet();
            VdbRequest tempVdbRequest = mFinalVdbRequest;
            mWaitingQueue.offer(tempVdbRequest);
            mFinalVdbRequest = null;
        }

        if (mRequestQueue.size() < MAX_PENDING_REQUEST_COUNT && mWaitingQueue.size() > 0) {
            VdbRequest waitRequest = mWaitingQueue.poll();
            mCurrentVdbRequests.put(waitRequest.getSequence(), waitRequest);
            mRequestQueue.offer(waitRequest);
        }
    }

    public void cancelAll() {
        for (VdbRequest<?> request : mCurrentVdbRequests.values()) {
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

    private void cancelAll(RequestFilter filter) {
        for (VdbRequest<?> request : mCurrentVdbRequests.values()) {
            if (filter.apply(request)) {
                request.cancel();
            }
        }
    }

    public interface RequestFilter {
        boolean apply(VdbRequest<?> request);
    }
}
