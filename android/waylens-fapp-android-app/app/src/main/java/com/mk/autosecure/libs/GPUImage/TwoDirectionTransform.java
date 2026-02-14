package com.mk.autosecure.libs.GPUImage;

import android.content.Context;
import android.graphics.Bitmap;

import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;

import java.lang.ref.WeakReference;

import jp.co.cyberagent.android.gpuimage.GPUImage;

/**
 * Created by DoanVT on 2017/11/30.
 * Email: doanvt-hn@mk.com.vn
 */

public class TwoDirectionTransform extends BitmapTransformation {

    private WeakReference<Context> contextReference;

    private boolean mLensNormal;

    public TwoDirectionTransform(Context context, boolean lensNormal) {
        super(context);
        this.contextReference = new WeakReference<>(context);
        this.mLensNormal = lensNormal;
    }

    private Bitmap remap(BitmapPool pool, Bitmap source) {
//        Logger.t("Transform").d("source = " + source);
        if (source == null || contextReference == null) {
            return null;
        }
        Context context = contextReference.get();
        if (context == null) {
            return null;
        }
        long t1 = System.currentTimeMillis();
//        Logger.t("Transform pos 1:").d("time = " + t1);
        GPUImage gpuImage = new GPUImage(context);
        //gpuImage.setImage(source);
        gpuImage.setFilter(new TwoDirectionFilter(mLensNormal));
//        Logger.t("Transform pos 2:").d("init = " + (System.currentTimeMillis() - t1));
        gpuImage.setImage(source);
        Bitmap bitmap = gpuImage.getBitmapWithFilterApplied();
//        Logger.t("Transform pos 3:").d("get Bitmap = " + (System.currentTimeMillis() - t1));
        return bitmap;
    }

    @Override
    protected Bitmap transform(BitmapPool pool, Bitmap toTransform, int outWidth, int outHeight) {
        return remap(pool, toTransform);
    }

    @Override
    public String getId() {
        return getClass().getName();
    }
}
