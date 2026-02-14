package com.mk.autosecure.ui.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.github.florent37.viewanimator.AnimationListener;
import com.github.florent37.viewanimator.ViewAnimator;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;


/**
 * Created by DoanVT on 2018/1/24.
 * Email: doanvt-hn@mk.com.vn
 */

public class SlideToUnlockView extends RelativeLayout {

    private static final String TAG="CustomSlideToUnlockView";
    private static final long DEAFULT_DURATIN_LONG = 200;//左弹回,动画时长
    private static final long DEAFULT_DURATIN_SHORT = 100;//右弹,动画时长
    private static final boolean LOG = true;//打印开关
    private static int  DISTANCE_LIMIT = 600;//滑动阈值
    private static float  THRESHOLD = 0.65F;//滑动阈值比例:默认是0.5,即滑动超过父容器宽度的一半再松手就会触发
    protected Context mContext;
    private TextView tv_slide;//滑块
    private TextView tv_hint;//提示文本
    private RelativeLayout rl_slide;//滑动view
    private RelativeLayout rl_root;//父容器
    private boolean mIsUnLocked;//已经滑到最右边,将不再响应touch事件
    private CallBack mCallBack;//回调
    private int slideImageViewWidth;//滑块宽度
    private int  slideImageViewResId;//滑块资源
    private int  slideImageViewResIdAfter;//滑动到右边时,滑块资源id
    private int  viewBackgroundResId;//root 背景
    private String textHint;//文本
    private int textSize;//单位是sp,只拿数值
    private int textColorResId;//颜色,@color

    public SlideToUnlockView(Context mContext) {
        this(mContext, null);
    }

    public SlideToUnlockView(Context mContext, AttributeSet attrs) {
        this(mContext, attrs, 0);
    }

    public SlideToUnlockView(Context mContext, AttributeSet attrs, int defStyleAttr) {
        super(mContext, attrs, defStyleAttr);
        this.mContext = mContext;
        TypedArray mTypedArray = mContext.obtainStyledAttributes(attrs, R.styleable.SlideToUnlockView);
        init(mTypedArray);
        initView();
    }

    private void init(TypedArray mTypedArray) {

        slideImageViewWidth= (int) mTypedArray.getDimension(R.styleable.SlideToUnlockView_slideImageViewWidth, ViewUtils.dp2px(50));
        slideImageViewResId= mTypedArray.getResourceId(R.styleable.SlideToUnlockView_slideImageViewResId, -1);
        slideImageViewResIdAfter= mTypedArray.getResourceId(R.styleable.SlideToUnlockView_slideImageViewResIdAfter, -1);
        viewBackgroundResId= mTypedArray.getResourceId(R.styleable.SlideToUnlockView_viewBackgroundResId, -1);
        textHint=mTypedArray.getString(R.styleable.SlideToUnlockView_textHint);
        textSize=mTypedArray.getInteger(R.styleable.SlideToUnlockView_textSize, 7);
        textColorResId= mTypedArray.getColor(R.styleable.SlideToUnlockView_textColorResId, getResources().getColor(android.R.color.white));
        THRESHOLD=mTypedArray.getFloat(R.styleable.SlideToUnlockView_slideThreshold, 0.65f);

        mTypedArray.recycle();
    }

    private int mActionDownX, mLastX, mSlidedDistance;


    @SuppressLint({"all", "ClickableViewAccessibility"})
    protected void initView() {

        LayoutInflater.from(mContext).inflate(R.layout.layout_view_slide_to_unlock, this, true);

        rl_root = (RelativeLayout) findViewById(R.id.rl_root);
        rl_slide = (RelativeLayout) findViewById(R.id.rl_slide);
        tv_slide = (TextView) findViewById(R.id.iv_slide);
        tv_hint = (TextView) findViewById(R.id.tv_hint);

        if(viewBackgroundResId>0){
            rl_slide.setBackgroundResource(viewBackgroundResId);
        }

        rl_slide.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                DISTANCE_LIMIT= (int) (SlideToUnlockView.this.getWidth() * THRESHOLD);//默认阈值是控件宽度的一半

                switch (event.getAction()) {

                    case MotionEvent.ACTION_DOWN://按下时记录纵坐标

                        if(mIsUnLocked){//滑块已经在最右边则不处理touch
                            return false;
                        }
                        mLastX = (int) event.getRawX();//最后一个action时x值
                        mActionDownX = (int) event.getRawX();//按下的瞬间x
                        logI(TAG, mLastX + "X,=============================ACTION_DOWN");
                        break;

                    case MotionEvent.ACTION_MOVE://上滑才处理,如果用户一开始就下滑,则过掉不处理

                        logI(TAG, "=============================ACTION_MOVE");
                        logI(TAG, "event.getRawX()============================="+event.getRawX());

                        int dX = (int) event.getRawX() - mLastX;
                        logI(TAG, "dX============================="+dX);

                        mSlidedDistance = (int) event.getRawX() - mActionDownX;
                        logI(TAG, "mSlidedDistance============================="+ mSlidedDistance);

                        final MarginLayoutParams params = (MarginLayoutParams) v.getLayoutParams();
                        int left = params.leftMargin;
                        int top = params.topMargin;
                        int right = params.rightMargin;
                        int bottom = params.bottomMargin;

                        logI(TAG, "left:"+left+",top:"+top+",right:"+right+",bottom"+bottom);

                        int leftNew = left + dX;
                        int rightNew =right - dX;

                        if (mSlidedDistance > 0) {//直接通过margin实现滑动
                            params.setMargins(leftNew, top, rightNew, bottom);
                            logI(TAG, leftNew + "=============================MOVE");
                            v.setLayoutParams(params);
                            resetTextViewAlpha(mSlidedDistance);

                            //回调
                            if(mCallBack!=null){
                                mCallBack.onSlide(mSlidedDistance);
                            }
                            mLastX = (int) event.getRawX();
                        } else {
                            return true;
                        }
                        break;
                    case MotionEvent.ACTION_UP:
//                        logI(TAG, "MotionEvent.ACTION_UP,之前移动的偏移值：" + v.getTranslationY());
                        if (Math.abs(mSlidedDistance) > DISTANCE_LIMIT) {
                            scrollToRight(v);//右边
                        } else {
                            scrollToLeft(v);//左边
                        }
                        break;
                    case MotionEvent.ACTION_CANCEL:
                        break;
                }
                return true;
            }
        });
    }


    private void logI(String tag,String content){
        if(LOG){
            //Logger.t(TAG).i("%s",content);
        }
    }

    private void resetTextViewAlpha(int distance) {

        if(Math.abs(distance)>=Math.abs(DISTANCE_LIMIT)){
            tv_hint.setAlpha(0.0f);
        }
        else{
            tv_hint.setAlpha(1.0f-Math.abs(distance)*1.0f/Math.abs(DISTANCE_LIMIT));
        }
    }

    private void scrollToLeft(final View v) {

        final MarginLayoutParams params1 = (MarginLayoutParams) v.getLayoutParams();
        logI(TAG, "scrollToLeft,ViewHelper.getTranslationX(v)：" + v.getTranslationX());
        logI(TAG, "scrollToLeft，params1.leftMargin：" + params1.leftMargin);
        logI(TAG, "scrollToLeft， params1.rightMargin：" + params1.rightMargin);

        ViewAnimator
                .animate( rl_slide)
                .translationX(v.getTranslationX(), -params1.leftMargin)
                .interpolator(new AccelerateInterpolator())
                .duration(DEAFULT_DURATIN_LONG)
                .onStop(new AnimationListener.Stop() {
                    @Override
                    public void onStop() {
                        MarginLayoutParams para = (MarginLayoutParams) v.getLayoutParams();
//                        logI(TAG, "scrollToLeft动画结束para.leftMargin：" + para.leftMargin);
//                        logI(TAG, "scrollToLeft动画结束para.rightMargin：" + para.rightMargin);
//                        logI(TAG, "scrollToLeft动画结束,ViewHelper.getTranslationX(v):" + v.getTranslationX());
                        mSlidedDistance = 0;
                        tv_hint.setAlpha(1.0f);
                        mIsUnLocked=false;
                        if(mCallBack!=null){
                            mCallBack.onSlide(mSlidedDistance);
                        }
                    }
                })
                .start();
    }

    private void scrollToRight(final View v) {
        final MarginLayoutParams params1 = (MarginLayoutParams) v.getLayoutParams();
        logI(TAG, "scrollToRight,ViewHelper.getTranslationX(v)：" + v.getTranslationX());
        logI(TAG, "scrollToRight，params1.leftMargin：" + params1.leftMargin);
        logI(TAG, "scrollToRight， params1.rightMargin：" + params1.rightMargin);

        //移动到最右端  移动的距离是 父容器宽度-leftMargin
        ViewAnimator
                .animate( rl_slide)
                //.translationX(ViewHelper.getTranslationX(v), ViewHelper.getTranslationX(v)+100)
                //.translationX()
                .translationX(params1.leftMargin, ( rl_slide.getWidth() - params1.leftMargin - tv_slide.getWidth()))
                .interpolator(new AccelerateInterpolator())
                .duration(DEAFULT_DURATIN_SHORT)
                .onStop(new AnimationListener.Stop() {
                    @Override
                    public void onStop() {
                        MarginLayoutParams para = (MarginLayoutParams) v.getLayoutParams();
//                        logI(TAG, "scrollToRight动画结束para.leftMargin：" + para.leftMargin);
//                        logI(TAG, "scrollToRight动画结束para.rightMargin：" + para.rightMargin);
//                        logI(TAG, "scrollToRight动画结束,ViewHelper.getTranslationX(v):" + v.getTranslationX());
                        mSlidedDistance = 0;
                        tv_hint.setAlpha(0.0f);
                        mIsUnLocked=true;

                        if(mCallBack!=null){
                            mCallBack.onUnlocked();
                        }
                    }
                })
                .start();
    }

    public void resetView(){
        mIsUnLocked=false;
        scrollToLeft(rl_slide);
    }

    public interface CallBack{
        void onSlide(int distance);//右滑距离回调
        void onUnlocked();//滑动到了右边,事件回调
    }

    public CallBack getmCallBack() {
        return mCallBack;
    }

    public void setmCallBack(CallBack mCallBack) {
        this.mCallBack = mCallBack;
    }
}