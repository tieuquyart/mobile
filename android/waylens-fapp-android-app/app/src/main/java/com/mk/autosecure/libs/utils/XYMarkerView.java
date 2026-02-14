package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.widget.TextView;

import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.MPPointF;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.EventListBean;

import java.text.DecimalFormat;
import java.util.List;

/**
 * Custom implementation of the MarkerView.
 *
 * @author Philipp Jahoda
 */
//@SuppressLint("ViewConstructor")
public class XYMarkerView extends MarkerView {

    private final static String TAG = XYMarkerView.class.getSimpleName();

    private final TextView tvContent;
    private final DayAxisValueFormatter xAxisValueFormatter;
    private int currentDash;

    private final DecimalFormat format;

    public XYMarkerView(Context context, DayAxisValueFormatter xAxisValueFormatter) {
        super(context, R.layout.custom_marker_view);

        this.xAxisValueFormatter = xAxisValueFormatter;
        tvContent = findViewById(R.id.tvContent);
        format = new DecimalFormat("0.00");
    }

    public void setCurrentDash(int currentDash) {
        this.currentDash = currentDash;
    }

    // runs every time the MarkerView is redrawn, can be used to update the
    // content (user-interface)
    @Override
    public void refreshContent(Entry e, Highlight highlight) {
        Logger.t(TAG).d("refreshContent: " + currentDash + " " + e + " " + highlight);

        String string;
        if (currentDash == 0) {
            string = format.format(e.getY()) + " kilometer";
        } else if (currentDash == 1) {
            string = format.format(e.getY()) + " hours";
        } else {
            string = ((List<EventListBean>) e.getData()).get((int)e.getX()).getEventTotal() + " events";
        }
        tvContent.setText(String.format("%s  |  %s", xAxisValueFormatter.getFormattedMarker(e.getX()), string));

        super.refreshContent(e, highlight);
    }

    @Override
    public MPPointF getOffset() {
        return new MPPointF(-(getWidth() >> 1), -getHeight());
    }
}
