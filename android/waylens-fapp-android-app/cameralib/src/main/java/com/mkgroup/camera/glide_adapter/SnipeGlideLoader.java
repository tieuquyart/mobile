package com.mkgroup.camera.glide_adapter;

import android.content.Context;

import com.bumptech.glide.load.data.DataFetcher;
import com.bumptech.glide.load.model.GenericLoaderFactory;
import com.bumptech.glide.load.model.ModelLoader;
import com.bumptech.glide.load.model.ModelLoaderFactory;
import com.bumptech.glide.load.model.stream.StreamModelLoader;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;

import java.io.InputStream;

/**
 * Created by doanvt on 2016/6/18.
 */
public class SnipeGlideLoader implements StreamModelLoader<ClipPos> {

    private final static String TAG = SnipeGlideLoader.class.getSimpleName();

    public static class Factory implements ModelLoaderFactory<ClipPos, InputStream> {

        private volatile static VdbRequestQueue internalQueue;

        private VdbRequestQueue requestQueue;

        private static VdbRequestQueue getInternalQueue() {
            if (internalQueue == null) {
                synchronized (Factory.class) {
                    if (internalQueue == null) {
                        VdtCameraManager manager = VdtCameraManager.getManager();
                        if (manager.isConnected()) {
                            CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
                            if (camera == null) {
                                internalQueue = null;
                            } else {
                                internalQueue = camera.getRequestQueue();
                            }
                        }
                    }
                }
            }
            return internalQueue;
        }

        public Factory() {
            this(getInternalQueue());
        }

        public Factory(VdbRequestQueue requestQueue) {
            this.requestQueue = requestQueue;
        }

        @Override
        public ModelLoader<ClipPos, InputStream> build(Context context, GenericLoaderFactory factories) {
            return new SnipeGlideLoader(requestQueue, false);
        }

        @Override
        public void teardown() {

        }
    }

    private final VdbRequestQueue mVdbRequestQueue;
    private final boolean mIsIgnorable;

    public SnipeGlideLoader(VdbRequestQueue requestQueue, boolean isIgnorable) {
        this.mVdbRequestQueue = requestQueue;
        this.mIsIgnorable = isIgnorable;
    }

    @Override
    public DataFetcher<InputStream> getResourceFetcher(ClipPos model, int width, int height) {
        return new SnipeStreamFetcher(mVdbRequestQueue, model, mIsIgnorable);
    }
}
