package com.mk.autosecure.libs.utils;

import com.github.mikephil.charting.charts.BarLineChartBase;
import com.github.mikephil.charting.formatter.ValueFormatter;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

/**
 * Created by philipp on 02/06/16.
 */
public class DayAxisValueFormatter extends ValueFormatter {

    private final static String TAG = DayAxisValueFormatter.class.getSimpleName();

    private final BarLineChartBase<?> chart;

    private TimeZone timeZone;

    private List<Long> dateTimeList;

    public DayAxisValueFormatter(BarLineChartBase<?> chart, TimeZone timeZone, long fromDateTime, long toDateTime) {
        this.chart = chart;
        this.timeZone = timeZone;

        dateTimeList = new ArrayList<>();

        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(fromDateTime);

        do {
            dateTimeList.add(calendar.getTimeInMillis());
            calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + 1);
        } while (calendar.getTimeInMillis() <= toDateTime);
    }

    public void setDateTime(long fromDateTime, long toDateTime) {
        if (dateTimeList == null) {
            dateTimeList = new ArrayList<>();
        }

        dateTimeList.clear();

        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(fromDateTime);

        do {
            dateTimeList.add(calendar.getTimeInMillis());
            calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + 1);
        } while (calendar.getTimeInMillis() <= toDateTime);
    }

    String getFormattedMarker(float value) {
        int index = (int) value;
        if (index >= dateTimeList.size() || index < 0) {
            return "";
        }

        Long time = dateTimeList.get(index);
        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(time);
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        int month = calendar.get(Calendar.MONTH);
        return (++month) + "-" + day;
    }

    @Override
    public String getFormattedValue(float value) {
        int index = (int) value;
        if (index >= dateTimeList.size() || index < 0) {
            return "";
        }

        Long time = dateTimeList.get(index);
        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(time);
        int i = calendar.get(Calendar.DAY_OF_MONTH);
        return String.valueOf(i);
    }
}
