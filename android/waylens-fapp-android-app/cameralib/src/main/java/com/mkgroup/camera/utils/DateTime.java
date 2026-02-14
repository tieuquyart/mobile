package com.mkgroup.camera.utils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;


public class DateTime {

    private static final SimpleDateFormat mDateFormat;
    private static final SimpleDateFormat mDayFormat;
    private static final SimpleDateFormat m24HWithSecond;
    private static final SimpleDateFormat m12HWithSecond;

    private static final SimpleDateFormat m12HWithoutSec;
    private static final SimpleDateFormat m24HWithoutSec;

    static {
        mDateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        mDayFormat = new SimpleDateFormat("EEEE", Locale.getDefault());
        m12HWithSecond = new SimpleDateFormat("KK:mm:ss a", Locale.getDefault());
        m24HWithSecond = new SimpleDateFormat("HH:mm:ss", Locale.getDefault());

        m12HWithoutSec = new SimpleDateFormat("KK:mm a");
        m24HWithoutSec = new SimpleDateFormat("HH:mm");
    }

    private static int mTimezone = TimeZone.getDefault().getRawOffset();
    private static Date mDate = new Date();

    public static int getTimezone() {
        return mTimezone;
    }

    public static String getCurrentDate(long timeMillis) {
        mDate.setTime(timeMillis);
        return mDateFormat.format(mDate);
    }

    public static String getCurrentTime(long timeMillis) {
        m24HWithSecond.setTimeZone(TimeZone.getTimeZone("UTC"));
        mDate.setTime(timeMillis);
        return m24HWithSecond.format(mDate);
    }

    public static String getDateString(int date, long startTimeMs) {
        long time = startTimeMs + ((long) date) * 1000 - TimeZone.getDefault().getRawOffset() - TimeZone.getDefault().getDSTSavings();
        mDate.setTime(time);
        return mDateFormat.format(mDate);
    }


    public static String getDateStringInUTC(long timeMillis) {
        Date date = new Date(timeMillis);
        mDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        return mDateFormat.format(date);
    }

    public static String getTimeString(int date, long startTimeMs) {
        long time = startTimeMs + ((long) date) * 1000 - TimeZone.getDefault().getRawOffset() - TimeZone.getDefault().getDSTSavings();
        mDate.setTime(time);
        return m24HWithSecond.format(mDate);
    }

    public static String toString(long date, long startTimeMs) {
        long time = startTimeMs + date;
        mDate.setTime(time - mTimezone);
        return mDateFormat.format(mDate) + " " + m24HWithSecond.format(mDate);
    }

    public static String get12HTimeString(long date, boolean isUTC) {
        if (isUTC) {
            m12HWithSecond.setTimeZone(TimeZone.getTimeZone("UTC"));
        } else {
            m12HWithSecond.setTimeZone(TimeZone.getDefault());
        }
        mDate.setTime(date);
        return m12HWithSecond.format(mDate);
    }

    public static String get24HTimeString(long date, boolean isUTC) {
        if (isUTC) {
            m24HWithSecond.setTimeZone(TimeZone.getTimeZone("UTC"));
        } else {
            m24HWithSecond.setTimeZone(TimeZone.getDefault());
        }
        mDate.setTime(date);
        return m24HWithSecond.format(mDate);
    }

    public static String get12HTimeWithoutSec(long date, boolean isUTC) {
        if (isUTC) {
            m12HWithoutSec.setTimeZone(TimeZone.getTimeZone("UTC"));
        } else {
            m12HWithoutSec.setTimeZone(TimeZone.getDefault());
        }
        mDate.setTime(date);
        return m12HWithoutSec.format(mDate);
    }

    public static String get24HTimeWithoutSec(long date, boolean isUTC) {
        if (isUTC) {
            m24HWithoutSec.setTimeZone(TimeZone.getTimeZone("UTC"));
        } else {
            m24HWithoutSec.setTimeZone(TimeZone.getDefault());
        }
        mDate.setTime(date);
        return m24HWithoutSec.format(mDate);
    }

    public static String get12HTimeWithTZ(TimeZone timeZone, long date) {
        m12HWithoutSec.setTimeZone(timeZone);
        mDate.setTime(date);
        return m12HWithoutSec.format(mDate);
    }

    public static String get24HTimeWithTZ(TimeZone timeZone, long date) {
        m24HWithoutSec.setTimeZone(timeZone);
        mDate.setTime(date);
        return m24HWithoutSec.format(mDate);
    }

    public static String getInDayMinuteString(long date) {
        Date d = new Date();
        d.setTime(date);
        SimpleDateFormat dateFormat = new SimpleDateFormat("hh:mm a", Locale.getDefault());
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        return dateFormat.format(d);
    }

    public static String toString(long date) {
        mDate.setTime(date);
        return mDateFormat.format(mDate) + " " + m24HWithSecond.format(mDate);
    }

    public static Date getTimeDate(long date, long timeMs) {
        long time = timeMs + date;
        mDate.setTime(time - mTimezone);
        return mDate;
    }

    public static String getDayName(int date, long startTimeMs) {
        long time = startTimeMs + ((long) date) * 1000 - TimeZone.getDefault().getRawOffset() - TimeZone.getDefault().getDSTSavings();
        Date tmpDate = new Date();
        tmpDate.setTime(time);
        return mDayFormat.format(tmpDate);
    }

    public static String secondsToString(int seconds) {
        String text;
        if (seconds < 3600)
            text = String.format(Locale.ENGLISH, "%02d:%02d", (seconds % 3600) / 60, seconds % 60);
        else
            text = String.format(Locale.ENGLISH, "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60,
                    (seconds % 60));
        return text;
    }

    public static String toFileName(int date, long startTimeMs) {
        long time = startTimeMs + (long) date * 1000;
        mDate.setTime(time - mTimezone);
        DateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        return format.format(mDate);
    }

    public static long toDateTime(int date, long startTimeMs) {
        long time = startTimeMs + (long) date * 1000;
        return time - mTimezone;
    }

    public static String toFileName(long date) {
        mDate.setTime(date);
        DateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
        return format.format(mDate);
    }
}
