package com.mk.autosecure.ui.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PathMeasure;
import android.util.AttributeSet;
import android.view.View;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;

/**
 * Created by DoanVT on 2018/1/23.
 * Email: doanvt-hn@mk.com.vn
 */

public class BoundaryProgressBar extends View {

    private Paint mPaintBackground;
    private Paint mPaintProgress;

    private int mWidth;
    private int mHeight;

    private int bgColor = Color.argb(0, 0, 0, 0);
    private int progressColor = Color.rgb(141, 141, 141);

    private Path allPath = new Path();
    private Path progressPath = new Path();
    private float strokeWidth = ViewUtils.dp2px(8);

    private PathMeasure pathMeasure = new PathMeasure();

    private float progress = 0f;

    public BoundaryProgressBar(Context context) {
        this(context, null);
    }

    public BoundaryProgressBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public BoundaryProgressBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }


    private void init(AttributeSet attrs) {
        TypedArray typedArray = getContext().obtainStyledAttributes(attrs, R.styleable.BoundaryProgressBar);
        if (typedArray != null) {
            progress = typedArray.getColor(R.styleable.BoundaryProgressBar_progressValue, 0);
            progressColor = typedArray.getColor(R.styleable.BoundaryProgressBar_progressColor, progressColor);
            bgColor = typedArray.getColor(R.styleable.BoundaryProgressBar_barBackgroundColor, bgColor);
            strokeWidth = typedArray.getDimension(R.styleable.BoundaryProgressBar_strokeWidth, strokeWidth);
            typedArray.recycle();
        }
        initPaint();
    }

    public float getProgress() {
        return progress;
    }

    public void setProgress(float progress) {
        this.progress = progress;
        invalidate();
    }

    private void initPaint() {
        mPaintBackground = new Paint();
        mPaintProgress = new Paint();
        mPaintProgress.setAntiAlias(true);
        mPaintProgress.setStyle(Paint.Style.STROKE);
        mPaintProgress.setStrokeWidth(strokeWidth);
        mPaintProgress.setColor(progressColor);
    }


    private void drawBackground(Canvas canvas, Paint paint) {
        paint.setAntiAlias(true);
        canvas.drawColor(bgColor);
    }

    private void drawProgress(Canvas canvas, Paint paint) {
        progressPath.reset();
        pathMeasure.getSegment(0, 2 * (mHeight + mWidth) * progress / 100.0f, progressPath, true);
        canvas.drawPath(progressPath, paint);
    }


    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        drawBackground(canvas, mPaintBackground);
        drawProgress(canvas, mPaintProgress);
        canvas.save();//android 6.0及以上需要先save()
        canvas.restore();
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (mHeight != h || mWidth != w) {
            mHeight = h;
            mWidth = w;
            allPath.reset();
            allPath.moveTo(0, 0);
            allPath.lineTo(mWidth, 0);
            allPath.lineTo(mWidth, mHeight);
            allPath.lineTo(0, mHeight);
            allPath.close();
            pathMeasure.setPath(allPath, true);
        }
    }
}
