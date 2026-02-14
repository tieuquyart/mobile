package com.mk.autosecure.ui.view;

import android.content.Context;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.MotionEvent;

/**
 * Created by DoanVT on 2017/12/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class CustomRecyclerView extends RecyclerView{

    private boolean enableTouch = false;

    public CustomRecyclerView(Context context) {
        this(context, null);
    }

    public CustomRecyclerView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        return enableTouch && super.onTouchEvent(e);
    }


}
