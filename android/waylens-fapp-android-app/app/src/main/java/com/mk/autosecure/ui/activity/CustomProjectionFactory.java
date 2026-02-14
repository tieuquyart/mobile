package com.mk.autosecure.ui.activity;

import android.graphics.RectF;

import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.common.MDDirection;
import com.waylens.vrlib.strategy.projection.AbsProjectionStrategy;
import com.waylens.vrlib.strategy.projection.IMDProjectionFactory;
import com.waylens.vrlib.strategy.projection.MultiFishEyeProjection;
import com.waylens.vrlib.strategy.projection.TwoDirectionsProjection;

/**
 * Created by DoanVT on 2017/7/25.
 */

public class CustomProjectionFactory implements IMDProjectionFactory {

    public static final int CUSTOM_PROJECTION_FISH_EYE_RADIUS_VERTICAL = 9611;
    public static final int CUSTOM_PROJECTION_DOUBLE_DIRECTIONS = 9612;
    public static final int CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN = 9613;

    @Override
    public AbsProjectionStrategy createStrategy(int mode) {
        switch (mode) {
            case CUSTOM_PROJECTION_FISH_EYE_RADIUS_VERTICAL:
                return new MultiFishEyeProjection(0.745f, MDDirection.VERTICAL);
            case CUSTOM_PROJECTION_DOUBLE_DIRECTIONS:
                return TwoDirectionsProjection.create(MDVRLibrary.PROJECTION_MODE_PLANE_FULL, new RectF(0, 0, 1024, 1024), true);
            case CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN:
                return TwoDirectionsProjection.create(MDVRLibrary.PROJECTION_MODE_PLANE_FULL, new RectF(0, 0, 1024, 1024), false);
            default:
                return null;
        }
    }
}
