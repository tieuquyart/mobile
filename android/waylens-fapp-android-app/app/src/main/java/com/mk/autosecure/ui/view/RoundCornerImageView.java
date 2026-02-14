package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.util.AttributeSet;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;

import java.lang.ref.SoftReference;

/**
 * Created by DoanVT on 2018/1/8.
 * Email: doanvt-hn@mk.com.vn
 */


public class RoundCornerImageView extends androidx.appcompat.widget.AppCompatImageView {

    private Paint mPaint;
    private Paint mPaint2;

    private int width, height;

    private SoftReference<Bitmap> bufferBitmapRef;

    private Canvas bufferCanvas;

    private int topLeft, topRight, bottomLeft, bottomRight;

    private float roundHeight = ViewUtils.dp2px(1.5f);
    private float roundWidth = ViewUtils.dp2px(1.5f);

    public RoundCornerImageView(Context context, AttributeSet attrs,
                                int defStyle) {
        super(context, attrs, defStyle);
    }

    public RoundCornerImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public RoundCornerImageView(Context context) {
        super(context);
    }

    private void init() {
        mPaint = new Paint();
        mPaint.setColor(Color.WHITE);
        mPaint.setAntiAlias(true);
        bufferBitmapRef = new SoftReference<>(Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888));
        if (bufferBitmapRef.get() != null) bufferCanvas = new Canvas(bufferBitmapRef.get());
        mPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.DST_OUT));
        mPaint2 = new Paint();
        mPaint2.setXfermode(null);
    }

    public void setCorner(int topLeft, int topRight, int bottomLeft, int bottomRight) {
        this.topLeft = topLeft;
        this.topRight = topRight;
        this.bottomLeft = bottomLeft;
        this.bottomRight = bottomRight;
        invalidate();
    }

    public void clear() {
        bufferCanvas.drawColor(getResources().getColor(R.color.gray));
        invalidate();
    }

    @Override
    public void onDraw(Canvas canvas) {
        super.onDraw(bufferCanvas);
        if (topLeft > 0) {
            drawLeftUp(bufferCanvas);
        }
        if (topRight > 0) {
            drawRightUp(bufferCanvas);
        }
        if (bottomLeft > 0) {
            drawLeftDown(bufferCanvas);
        }
        if (bottomRight > 0) {
            drawRightDown(bufferCanvas);
        }
        if (bufferBitmapRef.get() != null) {
            canvas.drawBitmap(bufferBitmapRef.get(), 0, 0, mPaint2);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        if (w != width || h != height) {
            width = getMeasuredWidth();
            height = getMeasuredHeight();
            bufferBitmapRef = new SoftReference<>(Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888));
            if (bufferBitmapRef.get() != null) {
                bufferCanvas = new Canvas(bufferBitmapRef.get());
            }
        }
    }

    private void drawLeftUp(Canvas canvas) {
        Path path = new Path();
        path.moveTo(0, roundHeight);
        path.lineTo(0, 0);
        path.lineTo(roundWidth, 0);
        //arcTo的第二个参数是以多少度为开始点，第三个参数-90度表示逆时针画弧，正数表示顺时针
        path.arcTo(new RectF(0, 0, roundWidth * 2, roundHeight * 2), -90, -90);
        path.close();
        canvas.drawPath(path, mPaint);
    }

    private void drawLeftDown(Canvas canvas) {
        Path path = new Path();
        path.moveTo(0, getHeight() - roundHeight);
        path.lineTo(0, getHeight());
        path.lineTo(roundWidth, getHeight());
        path.arcTo(new RectF(0, getHeight() - roundHeight * 2, 0 + roundWidth * 2, getHeight()), 90, 90);
        path.close();
        canvas.drawPath(path, mPaint);
    }

    private void drawRightDown(Canvas canvas) {
        Path path = new Path();
        path.moveTo(getWidth() - roundWidth, getHeight());
        path.lineTo(getWidth(), getHeight());
        path.lineTo(getWidth(), getHeight() - roundHeight);
        path.arcTo(new RectF(getWidth() - roundWidth * 2, getHeight() - roundHeight * 2, getWidth(), getHeight()), 0, 90);
        path.close();
        canvas.drawPath(path, mPaint);
    }

    private void drawRightUp(Canvas canvas) {
        Path path = new Path();
        path.moveTo(getWidth(), roundHeight);
        path.lineTo(getWidth(), 0);
        path.lineTo(getWidth() - roundWidth, 0);
        path.arcTo(new RectF(getWidth() - roundWidth * 2, 0, getWidth(), 0 + roundHeight * 2), -90, 90);
        path.close();
        canvas.drawPath(path, mPaint);
    }

}
