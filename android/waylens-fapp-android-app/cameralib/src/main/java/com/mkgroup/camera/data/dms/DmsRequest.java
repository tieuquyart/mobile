package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.data.SnipeError;
import com.mkgroup.camera.data.vdb.DefaultRetryPolicy;
import com.mkgroup.camera.data.vdb.RetryPolicy;

import java.util.concurrent.atomic.AtomicLong;

public abstract class DmsRequest<T> implements Comparable<DmsRequest<T>> {

    private final static String TAG = DmsRequest.class.getSimpleName();

    private static AtomicLong mSeguenceGenerator = new AtomicLong(1111);

    protected int mMethod;

    private DmsResponse.Listener<T> mListener;
    private DmsResponse.ErrorListener mErrorListener;

    private Long mSequence;

    private boolean mCanceled = false;
    private boolean mResponseDelivered = false;

    private DmsRequestQueue mDmsRequestQueue;

    protected DmsCommand mDmsCommand;

    private boolean mIsIgnorable;

    private Object mTag;
    private boolean mIsMessageHandler;

    private RetryPolicy mRetryPolicy;

    abstract protected DmsCommand createDmsCommand();

    public DmsRequest(int method, DmsResponse.Listener<T> listener, DmsResponse.ErrorListener errorListener) {
        this.mMethod = method;
        this.mListener = listener;
        this.mErrorListener = errorListener;
        mSequence = mSeguenceGenerator.incrementAndGet();
        setRetryPolicy(new DefaultRetryPolicy());
    }

    private DmsRequest<?> setRetryPolicy(RetryPolicy retryPolicy) {
        this.mRetryPolicy = retryPolicy;
        return this;
    }

    public boolean hasHadResponseDelivered() {
        return mResponseDelivered;
    }

    public void finish(final String tag, boolean shouldClean) {
//        Logger.t(TAG).d("finish: " + tag);
        if (mDmsRequestQueue != null) {
            mDmsRequestQueue.finish(this);
        }
        if (shouldClean && !mIsMessageHandler) {
            clean();
        }
    }

    private void clean() {
        mListener = null;
        mErrorListener = null;
        mDmsCommand = null;
    }

    abstract protected DmsResponse<?> parseDmsResponse(DmsAcknowledge response);

    public void markDelivered() {
        if (!mIsMessageHandler) {
            mResponseDelivered = true;
        }
    }

    protected SnipeError parseDmsError(SnipeError error) {
        return error;
    }

    public DmsCommand getDmsCommand() {
        return mDmsCommand;
    }

    protected void deliveryResponse(T response) {
        if (mListener != null) {
            mListener.onResponse(response);
        }
        if (!mIsMessageHandler) {
            clean();
        }
    }

    public void deliveryError(SnipeError error) {
        if (mErrorListener != null) {
            mErrorListener.onErrorResponse(error);
        }
        if (!mIsMessageHandler) {
            clean();
        }
    }

    public enum Priority {
        LOW,
        NORMAL,
        HIGH,
        IMMEDIATE
    }

    public Priority getPriority() {
        return Priority.NORMAL;
    }

    @Override
    public int compareTo(DmsRequest<T> o) {
        Priority left = this.getPriority();
        Priority right = o.getPriority();

        return left == right ? (int) (this.mSequence - o.mSequence) : right.ordinal() - left.ordinal();
    }

    public DmsRequest<T> setRequestQueue(DmsRequestQueue dmsRequestQueue) {
        mDmsRequestQueue = dmsRequestQueue;
        return this;
    }

    public void addMarker(String s) {
//        Logger.t(TAG).d("addMarker: " + s);
    }

    public boolean isMessageHandler() {
        return mIsMessageHandler;
    }

    public void setIsMessageHandler(boolean isMessageHandler) {
        mIsMessageHandler = isMessageHandler;
    }

    public void setIgnorable(boolean isIgnorable) {
        mIsIgnorable = isIgnorable;
    }

    public boolean isIgnorable() {
        return mIsIgnorable;
    }

    public Long getSequence() {
        return mSequence;
    }

    public DmsRequest<T> setTag(Object tag) {
        mTag = tag;
        return this;
    }

    public Object getTag() {
        return mTag;
    }

    public void cancel() {
        mCanceled = true;
    }

    public boolean isCanceled() {
        return mCanceled;
    }


}
