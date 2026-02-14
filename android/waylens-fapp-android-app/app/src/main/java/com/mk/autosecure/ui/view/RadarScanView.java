package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Shader;
import android.graphics.SweepGradient;

import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;

import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2019/3/11.
 * Email：doanvt-hn@mk.com.vn
 */
public class RadarScanView extends View {

    private final static String TAG = RadarScanView.class.getSimpleName();

    private final static int DEFAULT_DIMENSION = 250;

    private final static float[] circleProportion = {6 / 25f, 11 / 25f, 18 / 25f, 24 / 25f};

    private float mCenterX;

    private float mCenterY;

    private float mRadarRadius;

    private Paint mPaintCircle;

    private Paint mPaintLine;

    private Paint mPaintCenter;

    private Paint mPaintText;

    private boolean isDrawText = false;

    private Paint mPaintScan;

    private Matrix matrix = new Matrix(); //旋转需要的矩阵

    private Disposable countDownSubscribe;

    private String timerStr = "30s";

    private Shader mShader;

    private int rotateAngle; //扫描旋转的角度

    private int scanSpeed = 5;

    private IScanListener IScanListener;

    public RadarScanView(Context context) {
        this(context, null);
    }

    public RadarScanView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
        post(runnable);
    }

    private void initView() {
        mPaintCircle = new Paint();
        mPaintCircle.setColor(getResources().getColor(R.color.colorAccent));
        mPaintCircle.setAntiAlias(true);
        mPaintCircle.setStrokeWidth(2);
        mPaintCircle.setStyle(Paint.Style.STROKE);

        mPaintLine = new Paint();
        mPaintLine.setColor(Color.WHITE);
        mPaintLine.setAntiAlias(true);
        mPaintLine.setStrokeWidth(1);
        mPaintLine.setStyle(Paint.Style.STROKE);

        mPaintCenter = new Paint();
        mPaintCenter.setColor(Color.WHITE);
        mPaintCenter.setAntiAlias(true);
        mPaintCenter.setStrokeWidth(2);
        mPaintCenter.setStyle(Paint.Style.FILL);

        mPaintText = new Paint();
        mPaintText.setColor(Color.BLACK);
        mPaintText.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaintText.setTextSize(ViewUtils.dp2px(14));
        mPaintText.setTextAlign(Paint.Align.CENTER);
        mPaintText.setAntiAlias(true);

        mPaintScan = new Paint();
        mPaintScan.setStyle(Paint.Style.FILL_AND_STROKE);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        setMeasuredDimension(measureDimension(widthMeasureSpec), measureDimension(heightMeasureSpec));

        mCenterX = getMeasuredWidth() / 2f;
        mCenterY = getMeasuredHeight() / 2f;
        mRadarRadius = Math.min(getMeasuredWidth(), getMeasuredHeight()) / 2f;
    }

    private int measureDimension(int tempMeasureSpec) {
        int resultDimension;

        int mode = MeasureSpec.getMode(tempMeasureSpec);
        int size = MeasureSpec.getSize(tempMeasureSpec);

        if (mode == MeasureSpec.EXACTLY) {
            resultDimension = size;
        } else {
            resultDimension = DEFAULT_DIMENSION;
            if (mode == MeasureSpec.AT_MOST) {
                resultDimension = Math.max(resultDimension, size);
            }
        }
        return resultDimension;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        drawCircle(canvas);
        drawScan(canvas);
        drawCenter(canvas);
    }

    private void drawCenter(Canvas canvas) {
//        mCenterBitmap = BitmapFactory.decodeResource(getResources(), R.mipmap.waylens360_launcher);
//        float v = mRadarRadius * circleProportion[0];
//        canvas.drawBitmap(mCenterBitmap, null,
//                new Rect((int) (mCenterX - v), (int) (mCenterY - v), (int) (mCenterX + v), (int) (mCenterY + v)), mPaintText);

        canvas.drawLine(mCenterX - mRadarRadius, mCenterY, mCenterX + mRadarRadius, mCenterY, mPaintLine);
        canvas.drawLine(mCenterX, mCenterY - mRadarRadius, mCenterX, mCenterY + mRadarRadius, mPaintLine);

        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[0], mPaintCenter);

        if (isDrawText) {
            canvas.drawText(timerStr, mCenterX, mCenterY + ViewUtils.dp2px(4), mPaintText);
        }

//        countDown();
    }

    public void countDown() {
        final int time = 10;
        isDrawText = true;
        countDownSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time + 1)
                .map(aLong -> time - aLong)
                .doFinally(() -> isDrawText = false)
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    Logger.t(TAG).d("onNext: " + aLong);
                    timerStr = aLong + "s";
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    unSubscribeCount();
                });
    }

    private void drawScan(Canvas canvas) {
        canvas.save();
        mShader = new SweepGradient(mCenterX, mCenterY,
                new int[]{Color.TRANSPARENT, getResources().getColor(R.color.colorAccent)}, null);
        mPaintScan.setShader(mShader);
        canvas.concat(matrix);
        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[3], mPaintScan);
        canvas.restore();
    }

    private void drawCircle(Canvas canvas) {
        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[0], mPaintCircle);
        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[1], mPaintCircle);
        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[2], mPaintCircle);
        canvas.drawCircle(mCenterX, mCenterY, mRadarRadius * circleProportion[3], mPaintCircle);
    }

    private Runnable runnable = new Runnable() {
        @Override
        public void run() {
            rotateAngle = (scanSpeed + rotateAngle) % 360;
            matrix.postRotate(scanSpeed, mCenterX, mCenterY);
            invalidate();
            postDelayed(runnable, 50);
        }
    };

    public void unSubscribeCount() {
        if (countDownSubscribe != null && !countDownSubscribe.isDisposed()) {
            countDownSubscribe.dispose();
        }
    }

    public interface IScanListener {
        void onScaning();

        void onScanOver();
    }

    public void setIScanListener(RadarScanView.IScanListener IScanListener) {
        this.IScanListener = IScanListener;
    }
}
