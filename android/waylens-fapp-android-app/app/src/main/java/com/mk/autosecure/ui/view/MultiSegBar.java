package com.mk.autosecure.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.model.Clip;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.bean.TimelineBean;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by DoanVT on 2017/9/8.
 * Email: doanvt-hn@mk.com.vn
 */

public class MultiSegBar extends View {
    private final static String TAG = MultiSegBar.class.getSimpleName();

    private List<Paint> paintList = new ArrayList<>();

    private List<ClipSegment> mClipSegList;
    private List<Line> mLineList;

    private float width;
    private float height;

    private float mCorner = ViewUtils.dp2px(1.5f);

    public MultiSegBar(Context context) {
        this(context, null);
    }

    public MultiSegBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MultiSegBar(Context context, AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    public MultiSegBar(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        List<Integer> colorList = VideoEventType.getEventTypeColorList(context);
        paintList.clear();

        for (int i = 0; i < colorList.size(); i++) {
            Paint paint = new Paint();
            paint.setColor(colorList.get(i));
            paint.setStrokeWidth(getMeasuredWidth());
            paint.setAntiAlias(true);
            paintList.add(paint);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (mClipSegList == null) {
            return;
        }
        generateLineList();

        //draw background
        canvas.drawRoundRect(0, 0, width, height, width / 2, width / 2, paintList.get(0));

        for (int i = 0; i < paintList.size(); i++) {
            for (Line line : mLineList) {
                if (line.cat == i) {
                    line.paint.setStrokeWidth(width);
                    //canvas.drawLine(width / 2, line.startY, width / 2, line.endY, line.paint);
                    canvas.drawRoundRect(0, line.startY, width, line.endY, width / 2, width / 2, line.paint);
                }
            }
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        width = w;
        height = h;
    }

    private void generateLineList() {
//        Logger.t(MultiSegBar.class.getSimpleName()).d("generate line list");

        mLineList = new ArrayList<>();
        float offset = 0;

        long totalClipTimeMs = 0;
        for (ClipSegment segment : mClipSegList) {
            totalClipTimeMs += segment.getLength();
        }

        float scale = height / totalClipTimeMs;

        for (int i = 0; i < mClipSegList.size(); i++) {
            ClipSegment seg = mClipSegList.get(i);
            if (seg.startSeg) {
                Line line = new Line();
                line.startY = offset;
                long length = 0;
                if (seg.data instanceof Clip) {
                    Clip clip = ((Clip) seg.data);
                    for (int k = i; k < mClipSegList.size(); k++) {
//                        Logger.t(MultiSegBar.class.getSimpleName()).d("diff = " + (mClipSegList.get(k).startTime - clip.getStartTimeMsAbs()));
                        if (mClipSegList.get(k).startTime >= clip.getStartTimeMsAbs()) {
                            length += mClipSegList.get(k).getLength();
                        } else {
                            break;
                        }
                    }
                } else if (seg.data instanceof ClipBean) {
                    ClipBean clipBean = (ClipBean) seg.data;
                    for (int k = i; k < mClipSegList.size(); k++) {
                        if (mClipSegList.get(k).startTime >= clipBean.getStartTimeMs()) {
                            length += mClipSegList.get(k).getLength();
                        } else {
                            break;
                        }
                    }
                } else if (seg.data instanceof EventBean) {
                    EventBean eventBean = (EventBean) seg.data;
                    for (int k = i; k < mClipSegList.size(); k++) {
                        if (mClipSegList.get(k).startTime >= eventBean.getStartTime()) {
                            length += mClipSegList.get(k).getLength();
                        } else {
                            break;
                        }
                    }
                } else if (seg.data instanceof TimelineBean) {
                    TimelineBean bean = (TimelineBean) seg.data;
                    for (int k = i; k < mClipSegList.size(); k++) {
                        if (mClipSegList.get(k).startTime >= bean.getTimelineTime()) {
                            length += mClipSegList.get(k).getLength();
                        } else {
                            break;
                        }
                    }
                } else if (seg.data instanceof NotificationBean) {

                    Logger.t(TAG).e("doanvt: MulltiSegbar config 21/09/2022");
                    NotificationBean bean = (NotificationBean) seg.data;
                    for (int k = i; k < mClipSegList.size(); k++) {
                        if (mClipSegList.get(k).startTime >= 100) {
                            length += mClipSegList.get(k).getLength();
                        } else {
                            break;
                        }
                    }
                }
                line.endY = line.startY + scale * length;

                offset = line.startY + scale * seg.getLength();
                if (seg.types >= 0 && seg.types < paintList.size()) {
                    line.paint = paintList.get(seg.types);
                    line.cat = seg.types;
                } else {
                    line.paint = paintList.get(0);
                    line.cat = 0;
                }
//                Logger.t(MultiSegBar.class.getSimpleName()).d("Type = " + seg.types);
//                Logger.t(MultiSegBar.class.getSimpleName()).d("ratio = " + seg.ratio);
//                Logger.t(MultiSegBar.class.getSimpleName()).d("line type = " + line.cat);
//                Logger.t(MultiSegBar.class.getSimpleName()).d("line length = " + (line.endY - line.startY));
//                Logger.t(MultiSegBar.class.getSimpleName()).d("duration = " + seg.duration);
                mLineList.add(line);
            } else {
                offset += scale * seg.getLength();
            }
        }
    }

    public void setSegList(List<ClipSegment> segList) {
        mClipSegList = segList;
        postInvalidate();
    }

    public static class Line {
        float startY;
        float endY;
        Paint paint;
        int cat;
    }
}
