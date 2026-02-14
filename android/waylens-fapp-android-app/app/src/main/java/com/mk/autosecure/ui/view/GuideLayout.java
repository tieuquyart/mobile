package com.mk.autosecure.ui.view;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.graphics.Shader;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import com.mk.autosecure.R;

import java.lang.ref.WeakReference;

/**
 * Created by doanvt on 2019/1/15.
 * Email：doanvt-hn@mk.com.vn
 */

public class GuideLayout extends RelativeLayout implements ViewTreeObserver.OnGlobalLayoutListener {
    private final String TAG = getClass().getSimpleName();
    private WeakReference<Context> mContextReference;
    private boolean first = true;
    /**
     * targetView前缀。SHOW_GUIDE_PREFIX + targetView.getId()作为保存在SP文件的key。
     */
    private static final String SHOW_GUIDE_PREFIX = "show_guide_on_view_";
    /**
     * GuideView 偏移量
     */
    private int offsetX, offsetY;
    /**
     * targetView 的外切圆半径
     */
    private int radius;
    /**
     * 需要显示提示信息的View
     */
    private View targetView;
    /**
     * 自定义View
     */
    private View customGuideView;
    /**
     * 透明圆形画笔
     */
    private Paint mCirclePaint;
    /**
     * targetView是否已测量
     */
    private boolean isMeasured;
    /**
     * targetView圆心
     */
    private int[] center;
    /**
     * 绘图层叠模式
     */
    private PorterDuffXfermode porterDuffXfermode;
    /**
     * 绘制前景bitmap
     */
    private Bitmap bitmap;
    /**
     * 背景色和透明度，格式 #aarrggbb
     */
    private int backgroundColor;
    /**
     * Canvas,绘制bitmap
     */
    private Canvas temp;
    /**
     * 相对于targetView的位置.在target的那个方向
     */
    private Direction direction;

    /**
     * 形状
     */
    private MyShape myShape;
    /**
     * targetView左上角坐标
     */
    private int[] location;
    private OnClickCallback onclickListener;

    public void restoreState() {
//        Logger.v(TAG, "restoreState");
        offsetX = offsetY = 0;
        radius = 0;
        mCirclePaint = null;
        isMeasured = false;
        center = null;
        porterDuffXfermode = null;
        bitmap = null;
        needDraw = true;
        //        backgroundColor = Color.parseColor("#00000000");
        temp = null;
        //        direction = null;

    }

    public int[] getLocation() {
        return location;
    }

    public void setLocation(int[] location) {
        this.location = location;
    }

    public GuideLayout(Context context) {
        super(context);
        this.mContextReference = new WeakReference<>(context);
        init();
    }

    public int getRadius() {
        return radius;
    }

    public void setRadius(int radius) {
        this.radius = radius;
    }

    public void setDirection(Direction direction) {
        this.direction = direction;
    }

    public void setShape(MyShape shape) {
        this.myShape = shape;
    }

    public void setCustomGuideView(View customGuideView) {
        this.customGuideView = customGuideView;
        if (!first) {
            restoreState();
        }
    }

    public void setBgColor(int background_color) {
        this.backgroundColor = background_color;
    }

    public void setTargetView(View targetView) {
        this.targetView = targetView;
        //        restoreState();
        if (!first) {
            //            guideViewLayout.removeAllViews();
        }
    }

    private void init() {
        setFitsSystemWindows(true);
    }

    private boolean hasShown() {
        if (targetView == null)
            return true;
        Context context = mContextReference.get();
        if (context != null) {
            return context.getSharedPreferences(TAG, Context.MODE_PRIVATE).getBoolean(generateUniqId(targetView), false);
        }
        return true;
    }

    private String generateUniqId(View v) {
        return SHOW_GUIDE_PREFIX + v.getId();
    }

    public int[] getCenter() {
        return center;
    }

    public void setCenter(int[] center) {
        this.center = center;
    }

    public void hide() {
//        Logger.v(TAG, "hide");
        if (customGuideView != null) {
            targetView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            this.removeAllViews();

            Context context = mContextReference.get();
            if (context == null) {
                return;
            }

            ((FrameLayout) ((Activity) context).findViewById(Window.ID_ANDROID_CONTENT)).removeView(this);
            restoreState();
        }
    }

    public void show() {
//        Logger.v(TAG, "show");
        if (hasShown())
            return;

        if (targetView != null) {
            targetView.getViewTreeObserver().addOnGlobalLayoutListener(this);
        }

        this.setBackgroundResource(R.color.transparent);

        Context context = mContextReference.get();
        if (context == null) {
            return;
        }

        ((FrameLayout) ((Activity) context).findViewById(Window.ID_ANDROID_CONTENT)).addView(this);
        first = false;
    }

    /**
     * 添加提示文字，位置在targetView的下边
     * 在屏幕窗口，添加蒙层，蒙层绘制总背景和透明圆形，圆形下边绘制说明文字
     */
    private void createGuideView() {
//        Logger.v(TAG, "createGuideView");

        // Tips布局参数
        LayoutParams guideViewParams;
        guideViewParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);

        if (customGuideView != null) {
            if (direction != null) {
                int width = this.getWidth();
                int height = this.getHeight();

                int left = center[0] - radius;
                int right = center[0] + radius;
                int top = center[1] - radius;
                int bottom = center[1] + radius;
                switch (direction) {
                    case TOP:
                        this.setGravity(Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
                        guideViewParams.setMargins(offsetX, offsetY - height + top, -offsetX, height - top - offsetY);
                        break;
                    case LEFT:
                        this.setGravity(Gravity.END);
                        guideViewParams.setMargins(offsetX - width + left, top + offsetY, width - left - offsetX, -top - offsetY);
                        break;
                    case BOTTOM:
                        guideViewParams.setMargins(0, center[1] + targetView.getHeight() / 2, 0, 0);
                        break;
                    case RIGHT:
                        guideViewParams.setMargins(right + offsetX, top + offsetY, -right - offsetX, -top - offsetY);
                        break;
                    case LEFT_TOP:
                        this.setGravity(Gravity.END | Gravity.BOTTOM);
                        guideViewParams.setMargins(offsetX - width + left, offsetY - height + top, width - left - offsetX, height - top - offsetY);
                        break;
                    case LEFT_BOTTOM:
                        this.setGravity(Gravity.END);
                        guideViewParams.setMargins(offsetX - width + left, bottom + offsetY, width - left - offsetX, -bottom - offsetY);
                        break;
                    case RIGHT_TOP:
                        this.setGravity(Gravity.BOTTOM);
                        guideViewParams.setMargins(right + offsetX, offsetY - height + top, -right - offsetX, height - top - offsetY);
                        break;
                    case RIGHT_BOTTOM:
                        guideViewParams.setMargins(right + offsetX, bottom + offsetY, -right - offsetX, -top - offsetY);
                        break;
                }
            } else {
                guideViewParams = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                guideViewParams.setMargins(offsetX, offsetY, -offsetX, -offsetY);
            }
            this.addView(customGuideView, guideViewParams);
        }
    }

    /**
     * 获得targetView 的宽高，如果未测量，返回｛-1， -1｝
     */
    private int[] getTargetViewSize() {
        int[] location = {-1, -1};
        if (isMeasured) {
            location[0] = targetView.getWidth();
            location[1] = targetView.getHeight();
        }
        return location;
    }

    /**
     * 获得targetView 的半径
     */
    private int getTargetViewRadius() {
        if (isMeasured) {
            int[] size = getTargetViewSize();
            int x = size[0];
            int y = size[1];

            return (int) (Math.sqrt(x * x + y * y) / 2);
        }
        return -1;
    }

    boolean needDraw = true;

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
//        Logger.v(TAG, "onDraw");

        if (!isMeasured)
            return;

        if (targetView == null)
            return;

        //        if (!needDraw) return;

        drawBackground(canvas);

    }

    private void drawBackground(Canvas canvas) {
//        Logger.v(TAG, "drawBackground");
        needDraw = false;
        // 先绘制bitmap，再将bitmap绘制到屏幕
        bitmap = Bitmap.createBitmap(canvas.getWidth(), canvas.getHeight(), Bitmap.Config.ARGB_8888);
        temp = new Canvas(bitmap);

        // 背景画笔
        Paint bgPaint = new Paint();
        if (backgroundColor != 0) {
            //线性渐变
            LinearGradient gradient = new LinearGradient(0, temp.getHeight(), 0, 0,
                    new int[]{Color.rgb(28, 149, 235),
                            Color.argb(230, 15, 36, 71),
                            Color.argb(217, 12, 16, 43)},
                    new float[]{0f, 0.5f, 1f}, Shader.TileMode.CLAMP);
            bgPaint.setShader(gradient);
        } else
            bgPaint.setColor(getResources().getColor(R.color.black));

        // 绘制屏幕背景
        temp.drawRect(0, 0, temp.getWidth(), temp.getHeight(), bgPaint);

        // targetView 的透明圆形画笔
        if (mCirclePaint == null)
            mCirclePaint = new Paint();
        porterDuffXfermode = new PorterDuffXfermode(PorterDuff.Mode.SRC_OUT);// 或者CLEAR
        mCirclePaint.setXfermode(porterDuffXfermode);
        mCirclePaint.setAntiAlias(true);

        if (myShape != null) {
            RectF oval = new RectF();
            switch (myShape) {
                case CIRCLE://圆形
                    int r = Math.min(targetView.getWidth(), targetView.getHeight()) / 2;
                    r = r * 290 / 265;

                    oval.left = center[0] - r;                              //左边
                    oval.top = center[1] - r;                                   //上边
                    oval.right = center[0] + r;                             //右边
                    oval.bottom = center[1] + r;                                //下边
                    temp.drawOval(oval, mCirclePaint);
                    break;
                case RECTANGLE://圆角矩形
                    //RectF对象
                    oval.left = center[0] - targetView.getWidth() / 2;                              //左边
                    oval.top = center[1] - targetView.getHeight() / 2;                                   //上边
                    oval.right = center[0] + targetView.getWidth() / 2;                             //右边
                    oval.bottom = center[1] + targetView.getHeight() / 2;                                //下边
                    temp.drawRect(oval, mCirclePaint);
                    break;
                case LINE://椭圆
                    //RectF对象
                    oval.left = center[0] - 150;                              //左边
                    oval.top = center[1] - 50;                                   //上边
                    oval.right = center[0] + 150;                             //右边
                    oval.bottom = center[1] + 50;                                //下边
                    temp.drawOval(oval, mCirclePaint);                   //绘制椭圆
                    break;
            }
        } else {
            temp.drawCircle(center[0], center[1], radius, mCirclePaint);//绘制圆形
        }

        // 绘制到屏幕
        canvas.drawBitmap(bitmap, 0, 0, bgPaint);
        bitmap.recycle();
    }

    public void setOnclickListener(OnClickCallback onclickListener) {
        this.onclickListener = onclickListener;
    }

    @SuppressLint("ClickableViewAccessibility")
    private void setClickInfo() {
        setOnTouchListener((View v, MotionEvent event) -> {
            float y = event.getY();

            float targetViewY = targetView.getY();
            if (y > (center[1] - targetView.getHeight() / 2) && y < (center[1] + targetView.getHeight() / 2)) {
//                Logger.t(TAG).d("false");
                return false;
            }
//            Logger.t(TAG).d("true");
            return true;
        });

        View skipGuide = customGuideView.findViewById(R.id.tv_skip_guide);
        if (skipGuide != null) {
            skipGuide.setOnClickListener(v -> {
                if (onclickListener != null) {
                    onclickListener.onSkipGuideView();
                }
            });
        }

        View goGuide = customGuideView.findViewById(R.id.btn_go_guide);
        if (goGuide != null) {
            goGuide.setOnClickListener(v -> {
                if (onclickListener != null) {
                    onclickListener.onNextGuideView();
                }
            });
        }
    }

    @Override
    public void onGlobalLayout() {
        if (isMeasured)
            return;
        if (targetView.getHeight() > 0 && targetView.getWidth() > 0) {
            isMeasured = true;
        }

        // 获取targetView的中心坐标
        if (center == null) {
            // 获取左上角坐标
            location = new int[2];
            targetView.getLocationInWindow(location);
            center = new int[2];
//            location[1] = 168;
            int[] temp = new int[2];
            targetView.getLocationOnScreen(temp);

            Context context = mContextReference.get();
            if (context == null) {
                return;
            }

            int contentTop = ((Activity) context).findViewById(Window.ID_ANDROID_CONTENT).getTop();
            location[1] = location[1] - contentTop;

            // 获取中心坐标
            center[0] = location[0] + targetView.getWidth() / 2;
            center[1] = location[1] + targetView.getHeight() / 2;
        }
        // 获取targetView外切圆半径
        if (radius == 0) {
            radius = getTargetViewRadius();
        }
        // 添加GuideView
        createGuideView();
    }

    /**
     * 定义GuideView相对于targetView的方位，共八种。不设置则默认在targetView下方
     */
    public enum Direction {
        LEFT, TOP, RIGHT, BOTTOM,
        LEFT_TOP, LEFT_BOTTOM,
        RIGHT_TOP, RIGHT_BOTTOM
    }

    /**
     * 定义目标控件的形状，共3种。圆形，椭圆，带圆角的矩形（可以设置圆角大小），不设置则默认是圆形
     */
    public enum MyShape {
        CIRCLE, RECTANGLE, LINE
    }

    /**
     * GuideView点击Callback
     */
    public interface OnClickCallback {
        void onSkipGuideView();

        void onNextGuideView();
    }

    public static class Builder {
        GuideLayout guiderView;
        static Builder instance = new Builder();
        WeakReference<Context> mContextReference;

        private Builder() {
        }

        public Builder(Context ctx) {
            mContextReference = new WeakReference<>(ctx);
        }

        public static Builder newInstance(Context ctx) {
            instance.guiderView = new GuideLayout(ctx);
            return instance;
        }

        public Builder setTargetView(View target) {
            guiderView.setTargetView(target);
            return instance;
        }

        public Builder setBgColor(int color) {
            guiderView.setBgColor(color);
            return instance;
        }

        public Builder setDirction(Direction dir) {
            guiderView.setDirection(dir);
            return instance;
        }

        public Builder setShape(MyShape shape) {
            guiderView.setShape(shape);
            return instance;
        }

        public Builder setRadius(int radius) {
            guiderView.setRadius(radius);
            return instance;
        }

        public Builder setCustomGuideView(View view) {
            guiderView.setCustomGuideView(view);
            return instance;
        }

        public GuideLayout build() {
            guiderView.setClickInfo();
            return guiderView;
        }

        public Builder setOnclickListener(final OnClickCallback callback) {
            guiderView.setOnclickListener(callback);
            return instance;
        }

    }

}