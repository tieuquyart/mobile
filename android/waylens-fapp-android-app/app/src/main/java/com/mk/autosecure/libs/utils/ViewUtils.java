package com.mk.autosecure.libs.utils;


import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;

import androidx.annotation.NonNull;

import com.mk.autosecure.HornApplication;

/**
 * Created by DoanVT on 2017/8/4.
 */

public class ViewUtils {

    public static final int FULL_SCREEN_FLAG = View.SYSTEM_UI_FLAG_FULLSCREEN
            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION;

    public static int getScreenWidth(Activity activity) {
        DisplayMetrics dm = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.widthPixels;
    }

    public static int getScreenHeight(Activity activity) {
        DisplayMetrics dm = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.heightPixels;
    }

    public static DisplayMetrics getDisplayMetrics(Activity activity) {
        DisplayMetrics dm = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm;
    }

    public static float getDensity() {
        return HornApplication.getContext().getResources().getDisplayMetrics().density;
    }


    public static float dp2px(float dp) {
        return getDensity() * dp;
    }


    public static float sp2px(Context context, int sp) {
        float scale = context.getResources().getDisplayMetrics().scaledDensity;
        return scale * sp;
    }

    public static int dp2px(int dp) {
        Resources resources = HornApplication.getContext().getResources();
        DisplayMetrics displayMetrics = resources.getDisplayMetrics();
        return (int) (TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, displayMetrics) + 0.5f);
    }

    public static boolean isNavBarOnBottom(@NonNull Context context) {
        final Resources res = context.getResources();
        final Configuration cfg = context.getResources().getConfiguration();
        final DisplayMetrics dm = res.getDisplayMetrics();
        boolean canMove = (dm.widthPixels != dm.heightPixels &&
                cfg.smallestScreenWidthDp < 600);
        return (!canMove || dm.widthPixels < dm.heightPixels);
    }

    public final static float[] BUTTON_PRESSED = new float[]{
            2.0f, 0, 0, 0, 2,
            0, 2.0f, 0, 0, 2,
            0, 0, 2.0f, 0, 2,
            0, 0, 0, 5, 0};

    public final static float[] BUTTON_RELEASED = new float[]{
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 0, 1, 0};

}
