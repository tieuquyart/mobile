package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Xfermode;
import android.util.AttributeSet;

import com.orhanobut.logger.Logger;


/**
 * Created by DoanVT on 2017/8/19.
 */

public class RoundVideoLayout extends FixedAspectRatioFrameLayout{

    private Paint mPaint;
    private Xfermode mXfermode;

    private Bitmap bufferBitmap;

    private Canvas bufferCanvas;

    private int width, height;

    public RoundVideoLayout(Context context) {
        this(context, null);
    }

    public RoundVideoLayout(Context context, AttributeSet attrs) {
        this(context, null, 0);
    }

    public RoundVideoLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setDither(true);
        mPaint.setFilterBitmap(true);
        mXfermode = new PorterDuffXfermode(PorterDuff.Mode.DST_IN);
        bufferBitmap = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888);
        bufferCanvas = new Canvas(bufferBitmap);
        setWillNotDraw(false);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (getWidth() != width || getHeight() != height) {
            width = getWidth();
            height = getHeight();
            bufferBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
            bufferCanvas = new Canvas(bufferBitmap);
        }

    }

    private Bitmap makeCircle() {
        Bitmap bitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas=new Canvas(bitmap);
        Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.BLUE);
        paint.setStyle(Paint.Style.FILL);
        int radius = Math.min(getWidth(), getHeight()) / 2;
        canvas.drawCircle(getWidth()/2, getHeight()/2, radius, paint);
        return bitmap;
    }



    @Override
    public void onDraw(Canvas canvas) {
        //super.onDraw(canvas);
        super.onDraw(bufferCanvas);


        canvas.drawBitmap(bufferBitmap, 0, 0, mPaint);

        mPaint.reset();
        mPaint.setStyle(Paint.Style.FILL);
        mPaint.setXfermode(mXfermode);

        canvas.drawBitmap(makeCircle(), 0, 0, mPaint);
        Logger.t(RoundVideoLayout.class.getSimpleName()).d("on draw");

        mPaint.setXfermode(null);

    }
}
