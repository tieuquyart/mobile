package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Color;

import androidx.customview.widget.ViewDragHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;

public class DragViewGroup extends ViewGroup {

    private final static String TAG = DragViewGroup.class.getSimpleName();

    private ViewDragHelper mViewDragHelper;

    private int mCurrentTop = 0;

    private int HEIGHT_TOTAL;

    private final int minDistance = ViewUtils.dp2px(60);
    private final int thumbnailHeight = ViewUtils.dp2px(56);
    //扩大了touch的范围，防止底部按钮无法拖拽
    public static final int TOUCH_MARGIN = ViewUtils.dp2px(15);

    public static final int TOP_BUTTON_SCROLL = -1;
    public static final int NO_BUTTON_SCROLL = 0;
    public static final int BOTTOM_BUTTON_SCROLL = 1;

    public int SCROLL_STYLE = 0;

    private boolean oneSecond = false;

    private View mTopView;
    private View mTopButton;
    private View mBtmButton;
    private View mBtmView;

    private TextView tv_scale_tips;

    private ImageButton ib_top;
    private ImageButton ib_btm;

    public int startPos;
    public int endPos;

    private int initHeight;

    private int isTopScroll = -1;

    private int borderOffset = 0;

    private boolean VERTICAL_MOVE = true;
    private boolean JUMP_MOVE = true;

    public DragViewGroup(Context context) {
        super(context);
        init();
    }

    public DragViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public DragViewGroup(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        //ViewDragHelper静态方法传入ViewDragHelperCallBack创建
        mViewDragHelper = ViewDragHelper.create(this, new ViewDragHelperCallBack());
        mViewDragHelper.setEdgeTrackingEnabled(ViewDragHelper.EDGE_ALL);
        Logger.t(TAG).e("slop: " + mViewDragHelper.getTouchSlop());
    }

    public int isTopScroll() {
        return isTopScroll;
    }

    //实现ViewDragHelper.Callback相关方法
    private class ViewDragHelperCallBack extends ViewDragHelper.Callback {

        @Override
        public boolean tryCaptureView(View child, int pointerId) {
//            Logger.t(TAG).e("tryCaptureView");
            JUMP_MOVE = true;
            if (child == mTopButton) {
                SCROLL_STYLE = TOP_BUTTON_SCROLL;
            } else if (child == mBtmButton) {
                SCROLL_STYLE = BOTTOM_BUTTON_SCROLL;
            } else {
                SCROLL_STYLE = NO_BUTTON_SCROLL;
            }
            return child == mTopButton || child == mBtmButton;
        }

        @Override
        public int clampViewPositionVertical(View child, int top, int dy) {
            Logger.t(TAG).e("clampViewPositionVertical: " + top + "--" + dy);

            if ((child == mTopButton && isBorder(top - dy + TOUCH_MARGIN) && dy < 0)
                    || (child == mBtmButton && isBorder(top - dy + mBtmButton.getMeasuredHeight() - TOUCH_MARGIN) && dy > 0)) {
//                VERTICAL_MOVE = false;
                JUMP_MOVE = false;
                Logger.t(TAG).e("VERTICAL_MOVE = false;");

                View childAt = layoutManager.getChildAt(1);

//                onViewReleased(child, 0, 0);
                return top - dy;
            }

//            int minDis = minDistance;
//            if (child == mTopButton && isBorder(top - dy)) {
//                View childAt = layoutManager.getChildAt(1);
//                minDis = childAt.getTop();
//                return minDis;
//            }
//
//            if (child == mBtmButton && isBorder(child.getBottom() - dy)) {
//                View childAt = layoutManager.getChildAt(layoutManager.getChildCount() - 1);
//                maxDis = childAt.getBottom();
//            }

//            if (oneSecond && ((child == mTopButton && dy > 0) || (child == mBtmButton && dy < 0))) {
//                VERTICAL_MOVE = false;
//                Logger.t(TAG).e("VERTICAL_MOVE = false;");
//                onViewReleased(child, 0, 0);
//                return top - dy;
//            }

            VERTICAL_MOVE = true;
            Logger.t(TAG).e("VERTICAL_MOVE = true");

            //手指触摸移动时回调 top表示要到达的y坐标
            int finalTop = top;
            if (child == mTopButton) {

//                Logger.t(TAG).e("mTopButton");

                finalTop = Math.max(
                        Math.min(top, (HEIGHT_TOTAL - thumbnailHeight) / 2 - TOUCH_MARGIN),
                        minDistance - TOUCH_MARGIN);
                endPos = finalTop + TOUCH_MARGIN;

            } else if (child == mBtmButton) {

//                Logger.t(TAG).e("mBtmButton");

                finalTop = Math.min(
                        Math.max(top, (HEIGHT_TOTAL + thumbnailHeight) / 2 - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN),
                        HEIGHT_TOTAL - minDistance - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN);

                startPos = finalTop + mBtmButton.getMeasuredHeight() - TOUCH_MARGIN;
            }
            updateUI(finalTop, true);
            return finalTop;
        }

        //当捕获视图的位置因拖动或解决而改变时调用。
        @Override
        public void onViewPositionChanged(View changedView, int left, int top, int dx, int dy) {
            Logger.t(TAG).e("onViewPositionChanged: " + dx + "--" + dy);

            if (VERTICAL_MOVE) {
                if (changedView == mTopButton) {
                    mCurrentTop += dy;
                } else if (changedView == mBtmButton) {
                    mCurrentTop -= dy;
                }
                if (JUMP_MOVE) {
                    Logger.t(TAG).e("onScrolled scrollBy: " + dx + "--" + dy);
                    Logger.t(TAG).e("NOW startPos: " + startPos);
                    recyclerView.scrollBy(dx, dy);
                }
                requestLayout();
            }
        }

        @Override
        public int getViewVerticalDragRange(View child) {
//            Logger.t(TAG).e("getViewVerticalDragRange");
            if (mTopButton == child || mBtmButton == child) {
                return child.getHeight();
            }
            return 0;
        }

        //拖动状态改变时调用
        @Override
        public void onViewDragStateChanged(int state) {
            Logger.t(TAG).e("onViewDragStateChanged: " + state);
            super.onViewDragStateChanged(state);
            dragCallback.onViewDragStateChanged(state);
//            if (state == ViewDragHelper.STATE_IDLE) {
//                JUMP_MOVE = false;
//            } else {
//                JUMP_MOVE = true;
//            }
        }

        @Override
        public void onViewReleased(View releasedChild, float xvel, float yvel) {
            //手指抬起释放时回调

            Logger.t(TAG).e("onViewReleased: " + xvel + "--" + yvel + VERTICAL_MOVE);

            if (VERTICAL_MOVE) {

                SCROLL_STYLE = NO_BUTTON_SCROLL;

                int finalTop = releasedChild.getTop();
                int[] resultList = dragCallback.dragResult(zoom, startPos, endPos);
                int result = resultList[0];
                int pow = resultList[1];
                Logger.t(TAG).e("result: " + result);
                if (result == 0) {
                    if (finalTop == (HEIGHT_TOTAL - thumbnailHeight) / 2 - TOUCH_MARGIN || finalTop == (HEIGHT_TOTAL + thumbnailHeight) / 2 - (mBtmButton.getMeasuredHeight() - TOUCH_MARGIN)) {
                        if (pow == 1) {
                            oneSecond = true;
                        } else {
                            oneSecond = false;
                        }
                    } else {
                        oneSecond = false;
                    }
                    JUMP_MOVE = true;
                    updateUI(finalTop, false);

                    mViewDragHelper.settleCapturedViewAt(0, finalTop);
                    invalidate();
                } else {
                    JUMP_MOVE = false;
                    updateUI(0, false);
                    if (result == (HEIGHT_TOTAL - thumbnailHeight) / 2 && pow == 1) {
                        oneSecond = true;
                        if (releasedChild == mTopButton) {
                            mViewDragHelper.settleCapturedViewAt(0, result - TOUCH_MARGIN);
                        } else if (releasedChild == mBtmButton) {
                            mViewDragHelper.settleCapturedViewAt(0, (HEIGHT_TOTAL + thumbnailHeight) / 2 - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN);
                        }
                    } else if (result == ViewUtils.dp2px(70)) {
                        oneSecond = false;
                        if (releasedChild == mTopButton) {
                            mViewDragHelper.settleCapturedViewAt(0, result - TOUCH_MARGIN);
                        } else if (releasedChild == mBtmButton) {
                            mViewDragHelper.settleCapturedViewAt(0, HEIGHT_TOTAL - ViewUtils.dp2px(70) - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN);
                        }
                    } else {
                        oneSecond = false;
                        if (releasedChild == mTopButton) {
                            mViewDragHelper.settleCapturedViewAt(0, result - TOUCH_MARGIN);
                        } else if (releasedChild == mBtmButton) {
                            mViewDragHelper.settleCapturedViewAt(0, HEIGHT_TOTAL - result - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN);
                        }
                    }
//                    Logger.t(TAG).e("11111111");
//                    layoutManager.scrollToPositionWithOffset(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - result);
//                    recyclerView.smoothScrollBy(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - result);
                    invalidate();
                }

//                if (finalTop == minDistance
//                        || finalTop == (HEIGHT_TOTAL - thumbnailHeight) / 2) {
//
//                    JUMP_MOVE = false;
//                    finalTop = mTopView.getMeasuredHeight();
//                } else if (finalTop == (HEIGHT_TOTAL + thumbnailHeight) / 2 - mBtmButton.getMeasuredHeight()
//                        || finalTop == HEIGHT_TOTAL - minDistance - mBtmButton.getMeasuredHeight()) {
//
//                    JUMP_MOVE = false;
//                    finalTop = HEIGHT_TOTAL - mTopView.getMeasuredHeight() - mTopButton.getMeasuredHeight();
//                }

            } else {
                updateUI(0, false);
                invalidate();
            }
        }
    }

    public String zoom = "";

    private void updateUI(int currentTop, boolean pressed) {
        String color;
        if (currentTop == (HEIGHT_TOTAL - thumbnailHeight) / 2 - TOUCH_MARGIN || currentTop == (HEIGHT_TOTAL + thumbnailHeight) / 2 - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN) {
            if (!oneSecond) {
                color = "#CC7ED321";
                zoom = getContext().getString(R.string.zoom_in);
            } else {
                color = "#CC253238";
                zoom = "";
                pressed = false;
            }
        } else if (currentTop == minDistance - TOUCH_MARGIN || currentTop == HEIGHT_TOTAL - minDistance - mBtmButton.getMeasuredHeight() + TOUCH_MARGIN) {
            color = "#CC7ED321";
            zoom = getContext().getString(R.string.zoom_out);
        } else {
            color = "#CC253238";
            zoom = "";
        }
        mTopView.setBackgroundColor(Color.parseColor(color));
        mBtmView.setBackgroundColor(Color.parseColor(color));
        if (!TextUtils.isEmpty(zoom) && pressed) {
            tv_scale_tips.setText(String.format("%s%s", getContext().getString(R.string.release_to), zoom));
        } else {
            tv_scale_tips.setText("");
        }

        ib_top.setPressed(pressed);
        ib_btm.setPressed(pressed);
    }

    //onInterceptTouchEvent方法调用ViewDragHelper.shouldInterceptTouchEvent
    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
//        Logger.t(TAG).e("onInterceptTouchEvent");
        return mViewDragHelper.shouldInterceptTouchEvent(ev);
    }

    //onTouchEvent方法中调用ViewDragHelper.processTouchEvent方法并返回true
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        mViewDragHelper.processTouchEvent(event);
        //缩略图范围内不处理touch事件
        float downY = event.getY();
        if ((downY < mBtmButton.getBottom() && downY > mBtmButton.getTop())
                || (downY > mTopButton.getTop() && downY < mTopButton.getBottom())) {
            Logger.t(TAG).e("onTouchEvent true");
            return true;
        }
        Logger.t(TAG).e("onTouchEvent false");
        return false;
    }

    @Override
    public void computeScroll() {
        if (mViewDragHelper.continueSettling(true)) {
            invalidate();
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int measureWidth = MeasureSpec.getSize(widthMeasureSpec);
        int measureHeight = MeasureSpec.getSize(heightMeasureSpec);
        setMeasuredDimension(measureWidth, measureHeight);

        measureChildren(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        Logger.t(TAG).e("width: " + w + "---height: " + h);
        HEIGHT_TOTAL = h;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {

        mTopView.layout(0, 0,
                mTopView.getMeasuredWidth(),
                mCurrentTop + mTopView.getMeasuredHeight() + TOUCH_MARGIN);

        Logger.t(TAG).e("mTopView: " + mTopView.getMeasuredWidth()
                + "-" + (mCurrentTop + mTopView.getMeasuredHeight()));

        mTopButton.layout(0, mCurrentTop + mTopView.getMeasuredHeight(),
                mTopButton.getMeasuredWidth(),
                mCurrentTop + mTopView.getMeasuredHeight() + mTopButton.getMeasuredHeight());

        Logger.t(TAG).e("mTopButton: " + mTopButton.getMeasuredWidth()
                + "-" + (mCurrentTop + mTopView.getMeasuredHeight() + mTopButton.getMeasuredHeight()));


        //这里getHeight()得到的是添加了15dp的高度
        mBtmView.layout(0, HEIGHT_TOTAL - mTopView.getHeight(),
                mBtmView.getMeasuredWidth(),
                HEIGHT_TOTAL);

        Logger.t(TAG).e("mBtmView: " + (HEIGHT_TOTAL - mTopView.getHeight())
                + "-" + HEIGHT_TOTAL);

        mBtmButton.layout(0, HEIGHT_TOTAL - mTopView.getHeight() - mTopButton.getHeight() + TOUCH_MARGIN,
                mBtmButton.getMeasuredWidth(),
                HEIGHT_TOTAL - mTopView.getHeight() + TOUCH_MARGIN);

        Logger.t(TAG).e("mBtmButton: " + (HEIGHT_TOTAL - mTopView.getHeight() - mTopButton.getHeight())
                + "-" + (HEIGHT_TOTAL - mTopView.getHeight()));

        startPos = mBtmButton.getBottom() - TOUCH_MARGIN;
        endPos = mTopButton.getTop() + TOUCH_MARGIN;

        Logger.t(TAG).e("endPos: " + endPos);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        mTopView = getChildAt(0);
        mTopButton = getChildAt(1);
        mBtmView = getChildAt(2);
        mBtmButton = getChildAt(3);

        tv_scale_tips = (TextView) mTopView.findViewById(R.id.tv_scale_tips);

        ib_top = (ImageButton) mTopButton.findViewById(R.id.ib_top);
        ib_btm = (ImageButton) mBtmButton.findViewById(R.id.ib_btm);
    }

    public interface DragCallback {
        /**
         * 拖拽结果
         *
         * @param zoom
         */
        int[] dragResult(String zoom, int start, int end);

        /**
         * 拖拽状态发生改变
         *
         * @param state
         */
        void onViewDragStateChanged(int state);
    }

    private DragCallback dragCallback;
    private RecyclerView recyclerView;
    private LinearLayoutManager layoutManager;

    public void setDragCallback(DragCallback callback, RecyclerView recyclerView) {
        this.dragCallback = callback;
        this.recyclerView = recyclerView;
        this.layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
    }

    /**
     * 获得缩略图范围内 最高点的坐标（相对于整个布局）
     *
     * @param adjust
     * @return
     */
    public int getTopLine(boolean adjust) {
        if (adjust) {
            return initHeight;
        }
        return endPos;
    }

    /**
     * 获得缩略图范围内 最低点的坐标（相对于整个布局）
     *
     * @param adjust
     * @return
     */
    public int getBottomLine(boolean adjust) {
        if (adjust) {
            return HEIGHT_TOTAL - initHeight;
        }
        Logger.t(TAG).e("GET startPos: " + startPos);
        return startPos;
    }

    /**
     * 适配对应高度
     *
     * @param height
     */
    public void adjustHeight(int height) {
        Logger.t(TAG).e("adjustHeight: " + height);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(getLayoutParams());
        this.initHeight = height;
        params.height = height - TOUCH_MARGIN;
        mTopView.setLayoutParams(params);
        mBtmView.setLayoutParams(params);
        invalidate();//刷新了view
    }

    /**
     * 判断当前位置是否是边界
     *
     * @param curPos
     * @return
     */
    private boolean isBorder(int curPos) {
        View childViewUnder = recyclerView.findChildViewUnder(0, curPos);
        if (childViewUnder == null) {
            Logger.t(TAG).e("childViewUnder == null");
            return true;
        }

        int position = layoutManager.getPosition(childViewUnder);
        Logger.t(TAG).e("position: " + position + "--size: " + (layoutManager.getItemCount() - 1));

        int itemOffset = Math.abs(curPos - childViewUnder.getTop());
        Logger.t(TAG).e("itemOffset: " + itemOffset);

        if (position == 1 && itemOffset == 0) {
            return true;
        }
        if (position == 0 || position == layoutManager.getItemCount() - 1) {
            borderOffset = itemOffset;
            return true;
        }
        return false;
    }

}