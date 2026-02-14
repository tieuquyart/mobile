package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.Region;
import android.util.AttributeSet;
import android.view.View;
import com.mk.autosecure.libs.utils.ViewUtils;

/**
 * Created by DoanVT on 2017/11/3.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipView extends View {

    public static final int BORDERDISTANCE = ViewUtils.dp2px(16);


    public ClipView(Context context) {
        this(context, null);
    }

    public ClipView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ClipView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        int width = this.getWidth();
        int height = this.getHeight();

        int borderlength = width - BORDERDISTANCE * 2;

        canvas.clipRect(0, 0, width, height);

        Path path = new Path();
        path.addCircle(width / 2, height / 2, borderlength / 2, Path.Direction.CW);


        canvas.clipPath(path, Region.Op.DIFFERENCE);
        canvas.drawColor(0xaa000000);


    }

}
