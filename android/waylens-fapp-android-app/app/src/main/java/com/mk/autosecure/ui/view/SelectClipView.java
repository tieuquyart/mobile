package com.mk.autosecure.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;

/**
 * Created by DoanVT on 2017/9/26.
 */

public class SelectClipView extends FrameLayout {
    private static final String TAG = SelectClipView.class.getSimpleName();

    public SelectClipView(Context context) {
        this(context, null);
    }

    public SelectClipView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SelectClipView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {

    }

    public void addSelection(int viewId, LayoutParams params, boolean isSelected, OnClickListener listener) {
        FrameLayout clipContainer = (FrameLayout)findViewById(viewId);
        if (clipContainer == null) {
            clipContainer = new FrameLayout(getContext());
            //bookmarkContainer.setOrientation(LinearLayout.VERTICAL);
            //bookmarkContainer.setAlpha(0.3f);
            clipContainer.setId(viewId);
            addView(clipContainer, params);

            int marginHeight = ViewUtils.dp2px(3);

/*            View topView = new View(getContext());
            FrameLayout.LayoutParams paramsTop = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, marginHeight);
            clipContainer.addView(topView, paramsTop);*/

/*            View middleView = new View(getContext());
            FrameLayout.LayoutParams paramsMiddle = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            paramsMiddle.setMargins(0, marginHeight, 0, marginHeight);
            middleView.setAlpha(0.3f);
            clipContainer.addView(middleView, paramsMiddle);*/

/*            View bottomView = new View(getContext());
            FrameLayout.LayoutParams paramsBottom = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, marginHeight);
            paramsBottom.gravity = Gravity.BOTTOM;
            clipContainer.addView(bottomView, paramsBottom);*/

/*            View leftView = new View(getContext());
            FrameLayout.LayoutParams paramsLeft = new FrameLayout.LayoutParams(marginHeight, ViewGroup.LayoutParams.MATCH_PARENT);
            paramsLeft.gravity = Gravity.START;
            clipContainer.addView(leftView, paramsLeft);*/

/*            View rightView = new View(getContext());
            FrameLayout.LayoutParams paramsRight = new FrameLayout.LayoutParams(marginHeight, ViewGroup.LayoutParams.MATCH_PARENT);
            paramsRight.gravity = Gravity.END;
            clipContainer.addView(rightView, paramsRight);*/

        } else {
            clipContainer.setLayoutParams(params);
        }

        for (int i = 0; i < clipContainer.getChildCount(); i++) {
            View childView = clipContainer.getChildAt(i);
            childView.setBackgroundResource(R.drawable.bg_selected_line);
        }
        clipContainer.setBackgroundResource(R.drawable.bg_selected_line);
    }
}