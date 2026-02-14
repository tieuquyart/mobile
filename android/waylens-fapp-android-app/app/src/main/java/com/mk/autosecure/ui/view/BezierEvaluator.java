package com.mk.autosecure.ui.view;

import android.animation.TypeEvaluator;
import android.graphics.Point;

public class BezierEvaluator implements TypeEvaluator<Point> {

    private final static String TAG = BezierEvaluator.class.getSimpleName();

    private Point mMidPoint;

    public BezierEvaluator(Point midPoint) {
        this.mMidPoint = midPoint;
    }

    //二阶贝塞尔曲线公式
    @Override
    public Point evaluate(float t, Point startValue, Point endValue) {
        int x = (int) ((1 - t) * (1 - t) * startValue.x
                + 2 * t * (1 - t) * mMidPoint.x
                + t * t * endValue.x);
        int y = (int) ((1 - t) * (1 - t) * startValue.y
                + 2 * t * (1 - t) * mMidPoint.y
                + t * t * endValue.y);
        return new Point(x, y);
    }
}
