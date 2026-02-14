package com.mkgroup.camera.utils;

import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.util.Patterns;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */

public final class StringUtils {
    private final static String TAG = StringUtils.class.getSimpleName();

    private static final Pattern PASSWORD = Pattern.compile("^(?![A-Za-z]+$)(?!\\d+$)\\S{8,64}$");

    private static final Pattern VERIFICATION_CODE = Pattern.compile("^\\d{6}$");

    public static final int USER_NAME_MAX_LENGTH = 32;

    public static final int CAMERA_NAME_MAX_LENGTH = 20;

    /**
     * AppVersion(App name, App version Name, App version code), Phone model, OS version
     */

    public static String USER_AGENT_FORMAT = "%s/%s/%d;%s;%s;";


    private StringUtils() {
    }

    public static boolean isVerificationCode(final @Nullable String str) {
        return !TextUtils.isEmpty(str) && VERIFICATION_CODE.matcher(str).matches();
    }

    public static boolean isEmail(final @NonNull CharSequence str) {
        return Patterns.EMAIL_ADDRESS.matcher(str).matches();
    }

    public static boolean isEmpty(final @Nullable String str) {
        return str == null || str.trim().length() == 0;
    }

    public static boolean isPresent(final @Nullable String str) {
        return !isEmpty(str);
    }

    public static boolean isPwdValid(final @Nullable String str) {
        return !TextUtils.isEmpty(str) && PASSWORD.matcher(str).matches();
    }

    /**
     * Returns a string wrapped in parentheses.
     */
    public static @NonNull
    String wrapInParentheses(final @NonNull String str) {
        return "(" + str + ")";
    }


//    public static String getFormattedTime(Context context, long date) {
//        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd KK:mm:ss a", Locale.getDefault());
//        SimpleDateFormat withoutYearFormat;
//        SimpleDateFormat withoutDayFormat;
//        if (DateFormat.is24HourFormat(context)) {
//            withoutYearFormat = new SimpleDateFormat("MM-dd HH:mm:ss", Locale.getDefault());
//            withoutDayFormat = new SimpleDateFormat("HH:mm:ss", Locale.getDefault());
//        } else {
//            withoutYearFormat = new SimpleDateFormat("MM-dd KK:mm:ss a", Locale.getDefault());
//            withoutDayFormat = new SimpleDateFormat("KK:mm:ss a", Locale.getDefault());
//        }
//
//        long currentTime = System.currentTimeMillis();
//
//        Calendar calendar = Calendar.getInstance();
//        calendar.setTimeInMillis(date);
//        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
//        int clipDateYear = calendar.get(Calendar.YEAR);
//
//        calendar.setTimeInMillis(currentTime);
//        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
//        int currentDateYear = calendar.get(Calendar.YEAR);
//
//        String dateString = format.format(date);
//
//        if (clipDateYear == currentDateYear) {
//            if ((currentDateDay - clipDateDay) < 1) {
//                dateString = context.getString(R.string.today) + "\n" + withoutDayFormat.format(date);
//            } else if ((currentDateDay - clipDateDay) < 2) {
//                dateString = context.getString(R.string.yesterday) + "\n" + withoutDayFormat.format(date);
//            } else {
//                dateString = withoutYearFormat.format(date);
//            }
//        }
//        return dateString;
//    }


    public static String getHostName(String urlString) {
        String head = "";
        int index = urlString.indexOf("://");
        if (index != -1) {
            head = urlString.substring(0, index + 3);
            urlString = urlString.substring(index + 3);
        }
        index = urlString.indexOf("/");
        if (index != -1) {
            urlString = urlString.substring(0, index + 1);
        }
        return head + urlString;
    }


    public static String getHostNameWithoutPrefix(String urlString) {
        int index = urlString.indexOf("://");
        if (index != -1) {
            urlString = urlString.substring(index + 3);
        }
        index = urlString.indexOf("/");
        if (index != -1) {
            urlString = urlString.substring(0, index);
        }
        return urlString;
    }


    public static String getFileName(String urlString) {
        int index = urlString.lastIndexOf("/");
        if (index != -1) {
            urlString = urlString.substring(index);
        }

        return "" + urlString;
    }

    public static String getDataSize(long var0) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator('.');
        DecimalFormat var2 = new DecimalFormat("###.00", symbols);

        return var0 < 1024L ? var0 + "bytes" : (var0 < 1048576L ? var2.format((double) ((float) var0 / 1024.0F))
                + "KB" : (var0 < 1073741824L ? var2.format((double) ((float) var0 / 1024.0F / 1024.0F))
                + "MB" : (var0 < 0L ? var2.format((double) ((float) var0 / 1024.0F / 1024.0F / 1024.0F))
                + "GB" : "error")));
    }

    public static String getRaceTime(long time) {
        BigDecimal tmp = new BigDecimal((float) time / 1000f);
        return String.valueOf(tmp.setScale(2, BigDecimal.ROUND_HALF_UP).floatValue()) + "s";

    }

    public static String getSpaceString(long space) {
        float spaceInM = ((float) space) / (1000 * 1000);

        String spaceStr;
        if (spaceInM > 1000) {
            BigDecimal tmp = new BigDecimal(spaceInM / 1000);
            spaceStr = String.valueOf(tmp.setScale(1, BigDecimal.ROUND_HALF_UP).floatValue()) + " GB";
        } else {
            BigDecimal tmp = new BigDecimal(spaceInM);
            spaceStr = String.valueOf(tmp.setScale(1, BigDecimal.ROUND_HALF_UP).floatValue()) + " MB";
        }
        return spaceStr;
    }

    public static String getSpaceNumber(long space) {
        float spaceInM = ((float) space) / (1000 * 1000);

        String spaceStr;
        if (spaceInM > 1000) {
            BigDecimal tmp = new BigDecimal(spaceInM / 1000);
            spaceStr = String.valueOf(tmp.setScale(1, BigDecimal.ROUND_HALF_UP).floatValue());
        } else {
            BigDecimal tmp = new BigDecimal(spaceInM);
            spaceStr = String.valueOf(tmp.setScale(1, BigDecimal.ROUND_HALF_UP).floatValue());
        }
        return spaceStr;
    }


    public static String getSpaceUnit(long space) {
        float spaceInM = ((float) space) / (1000 * 1000);

        String spaceStr;
        if (spaceInM > 1000) {
            spaceStr = "GB";
        } else {
            spaceStr = "MB";
        }
        return spaceStr;
    }

    // unit of length is kilometer
    public static String formatLength(double length) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator('.');
        NumberFormat formatter = new DecimalFormat("#0.0", symbols);
        formatter.setRoundingMode(RoundingMode.HALF_UP);
        if (true/*SettingHelper.isMetricUnit()*/) {
            return formatter.format(length) + " kilometer" + (length > 1 ? "s" : "");
        } else {
            return formatter.format(length / 1.609344) + " mile" + (length > 1 ? "s" : "");
        }
    }


    public static InputFilter[] DisableSpecialCharacters(int length) {
        InputFilter filter = new InputFilter() {
            @Override
            public CharSequence filter(CharSequence source, int start, int end,
                                       Spanned dest, int dstart, int dend) {
                for (int i = start; i < end; i++) {
                    if (source.charAt(i) == '\n') {
                        return "";
                    }
                }
                return null;
            }
        };
        InputFilter[] filterArray = new InputFilter[2];
        filterArray[0] = filter;

        filterArray[1] = new InputFilter.LengthFilter(length);
        return filterArray;
    }

    /**
     * 过滤相机返回字符
     *
     * @param raw
     * @return
     */
    public static String[] filterString(String raw) {
        raw = raw.replace("[", "");
        raw = raw.replace("]", "");
        String[] split = raw.split(",");
        String[] filter = new String[split.length];
        for (int i = 0; i < split.length; i++) {
            filter[i] = split[i].replace("\"", "").trim();
        }
        return filter;
    }

    public static String filterArray(String raw) {
        raw = raw.replace("[", "");
        raw = raw.replace("]", "");
        String[] split = raw.split(",");
        List<Integer> filter = new ArrayList<>();
        for (int i = 0; i < split.length; i++) {
            filter.add(Integer.valueOf(split[i].replace("\"", "").trim()));
        }
        return filter.toString();
    }

    public static String formatDuration(int second) {
        int hour = second / 3600;
        int minute = (second % 3600) / 60;
        second = second % 60;

        StringBuilder builder = new StringBuilder();

        if (hour > 0) {
            builder.append(hour).append("h");
        }
        if (minute > 0) {
            builder.append(minute).append("m");
        }
        if (second > 0) {
            builder.append(second).append("s");
        }
        return builder.toString();
    }

    public static int compareToApiVersion(String deviceVersion, String targetVersion) {
        if (TextUtils.isEmpty(deviceVersion)) {
            return -1;
        }

        int device = transVersion(deviceVersion);
        int target = transVersion(targetVersion);
        if (device != target) {
            return device - target;
        } else {
            return 0;
        }
    }

    private static int transVersion(String version) {
        int main = 0, sub = 0;
        int i_main = version.indexOf('.', 0);
        if (i_main >= 0) {
            String t = version.substring(0, i_main);
            main = Integer.parseInt(t);
            i_main++;
            int i_sub = version.indexOf('.', i_main);
            if (i_sub >= 0) {
                t = version.substring(i_main, i_sub);
                sub = Integer.parseInt(t);
            }
        }
        return makeVersion(main, sub);
    }

    private static int makeVersion(int main, int sub) {
        return (main << 16) | sub;
    }
}