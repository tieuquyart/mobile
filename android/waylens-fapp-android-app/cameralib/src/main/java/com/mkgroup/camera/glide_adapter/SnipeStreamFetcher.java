package com.mkgroup.camera.glide_adapter;

import com.bumptech.glide.Priority;
import com.bumptech.glide.load.data.DataFetcher;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.utils.DigitUtils;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;

import java.io.InputStream;

/**
 * Created by doanvt on 2016/6/18.
 * Email: doanvt-hn@mk.com.vn
 */
public class SnipeStreamFetcher implements DataFetcher<InputStream> {

    private static final String TAG = SnipeStreamFetcher.class.getSimpleName();

    private static final SnipeRequestFactory DEFAULT_REQUEST_FACTORY = GlideVdbRequest::new;

    private final VdbRequestQueue mVdbRequestQueue;
    private final SnipeRequestFactory requestFactory;
    private final ClipPos mClipPos;

    private VdbRequestFuture<InputStream> requestFuture;

    private final boolean mIsIgnorable;

    SnipeStreamFetcher(VdbRequestQueue requestQueue, ClipPos url, boolean isIgnorable) {
        this(requestQueue, url, null, isIgnorable);
    }

    private SnipeStreamFetcher(VdbRequestQueue requestQueue, ClipPos url,
                               VdbRequestFuture<InputStream> requestFuture, boolean isIgnorable) {
        this(requestQueue, url, requestFuture, DEFAULT_REQUEST_FACTORY, isIgnorable);
    }

    private SnipeStreamFetcher(VdbRequestQueue requestQueue, ClipPos url,
                               VdbRequestFuture<InputStream> requestFuture,
                               SnipeRequestFactory requestFactory,
                               boolean isIgnorable) {
        this.mVdbRequestQueue = requestQueue;
        this.requestFactory = requestFactory;
        this.mClipPos = url;

        this.mIsIgnorable = isIgnorable;

        this.requestFuture = requestFuture;
        if (requestFuture == null) {
            this.requestFuture = VdbRequestFuture.newFuture();
        }
    }

    @Override
    public InputStream loadData(Priority priority) throws Exception {
        //这里是后台线程，异步创建请求
        VdbRequest<InputStream> request = requestFactory.create(
                mClipPos, requestFuture, mIsIgnorable);

        request.setTag(this);

        requestFuture.setRequest(mVdbRequestQueue.add(request));
//        Logger.t(TAG).d("loading = " + getId());

        return requestFuture.get();
    }

    @Override
    public void cleanup() {

    }

    @Override
    public String getId() {
        String clipId = String.valueOf(mClipPos.cid.hashCode());
        //Log.e("test", String.format("====== clipId[%s],clipTime[%d], w[%d], h[%d], scale[%d]",
        //        clipId, clipPos.getClipTimeMs(), maxWidth, maxHeight, scaleType.ordinal()));
//        return DigitUtils.md5(clipId
//                + "#T" + clipPos.getClipTimeMs()
//                + "#W" + maxWidth
//                + "#H" + maxHeight
//                + "#S" + scaleType.ordinal());
        return DigitUtils.md5(clipId + "#T" + mClipPos.getClipTimeMs());
    }

    @Override
    public void cancel() {
        if (mVdbRequestQueue != null) {
            mVdbRequestQueue.cancelAll(this);
        }
    }
}


