package com.mk.autosecure.libs.utils;

import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

/**
 * Created by doanvt on 2022/11/02.
 */
public class DashboardUtil {

    private final static String TAG = DashboardUtil.class.getSimpleName();

    //获得起始日期的零点UTC时间，限定dashboard展示14天, overview go detail展示7天
    public static long getZeroFromTime(int day, long toUtcTimeMillis) {
//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(toUtcTimeMillis);

        calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) - (--day));
        long fromUtcTimeInMillis = calendar.getTimeInMillis();

        boolean inDaylightTime = timeZone.inDaylightTime(new Date(fromUtcTimeInMillis));
//        Logger.t(TAG).d("inDaylightTime: " + inDaylightTime + " fromUtcTimeInMillis: " + fromUtcTimeInMillis);
        long dayTimeMills = 24 * 60 * 60 * 1000;

        if (inDaylightTime) {
            boolean frontDaylightTime = timeZone.inDaylightTime(new Date(fromUtcTimeInMillis - dayTimeMills));
            boolean behindDaylightTime = timeZone.inDaylightTime(new Date(fromUtcTimeInMillis + dayTimeMills));
//            Logger.t(TAG).d("frontDaylightTime: " + frontDaylightTime + " behindDaylightTime: " + behindDaylightTime);
            if (!frontDaylightTime & behindDaylightTime) {
                dayTimeMills = dayTimeMills - timeZone.getDSTSavings();
            }
            if (!behindDaylightTime && frontDaylightTime) {
                dayTimeMills = dayTimeMills + timeZone.getDSTSavings();
            }
        }

        long fleetOffset = timeZone.getOffset(fromUtcTimeInMillis);
        long fleetTimeMills = fromUtcTimeInMillis + fleetOffset;

        return fleetTimeMills - fleetTimeMills % dayTimeMills - fleetOffset;
    }

    public static long getEndTime(int day, long fromUtcTimeMillis) {
//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(fromUtcTimeMillis);

        //这里的天数设置会自动计算夏令时，冬令时
        calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + day);
        long toUtcTimeInMillis = calendar.getTimeInMillis();

        return toUtcTimeInMillis - 1;
    }

    public static Calendar getCalendar(TimeZone timeZone, long timeMills) {
        Calendar calendar = Calendar.getInstance(timeZone);
        calendar.setTimeInMillis(timeMills);
        return calendar;
    }

    public static String getBarLabel(TimeZone timeZone, long fromUtcDateTime, long toUtcDateTime) {
        Calendar from = getCalendar(timeZone, fromUtcDateTime);
        int fromYear = from.get(Calendar.YEAR);
        int fromMonth = from.get(Calendar.MONTH);
        Calendar to = getCalendar(timeZone, toUtcDateTime);
        int toYear = to.get(Calendar.YEAR);
        int toMonth = to.get(Calendar.MONTH);

        if (fromMonth != 0 && toMonth != 0){
            return fromMonth == toMonth ?
                    toYear + "-" + (++toMonth) : fromYear + "-" + (++fromMonth) + " | " + toYear + "-" + (++toMonth);
        }else{
            return "";
        }

    }

}
