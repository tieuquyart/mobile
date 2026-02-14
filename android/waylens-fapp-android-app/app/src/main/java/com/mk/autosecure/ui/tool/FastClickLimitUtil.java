package com.mk.autosecure.ui.tool;

/**
 * Created by cloud on 2021/2/7.
 */
public class FastClickLimitUtil {

    private static long lastClickTime;
    private final static int SPACE_TIME = 500;

    public synchronized static boolean isFastClick() {
        long currentTimeMillis = System.currentTimeMillis();
        boolean isClick;
        isClick = currentTimeMillis - lastClickTime <= SPACE_TIME;
        if (isClick) {
            return true;
        } else {
            lastClickTime = currentTimeMillis;
            return false;
        }
    }
}
