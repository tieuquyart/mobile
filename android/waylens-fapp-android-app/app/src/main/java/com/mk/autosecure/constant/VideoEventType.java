package com.mk.autosecure.constant;

import android.content.Context;
import android.text.TextUtils;

import androidx.core.content.ContextCompat;

import com.mk.autosecure.R;
import com.orhanobut.logger.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by doanvt on 2022/11/02.
 */

public class VideoEventType {
    //video event type
    public static final int TYPE_BUFFERED = 0x00;
    public static final int TYPE_PARKING_MOTION = 0x01;
    public static final int TYPE_PARKING_HIT = 0x02;
    public static final int TYPE_PARKING_HEAVY_HIT = 0x03;
    public static final int TYPE_DRIVING_HIT = 0x04;
    public static final int TYPE_DRIVING_HEAVY_HIT = 0x05;
    public static final int TYPE_HIGHLIGHT = 0x06;

    public static final int TYPE_HARD_ACCEL = 0x07;
    public static final int TYPE_HARD_BRAKE = 0x08;
    public static final int TYPE_SHARP_TURN = 0x09;

    public static final int TYPE_HARSH_ACCEL = 0x0A;
    public static final int TYPE_HARSH_BRAKE = 0x0B;
    public static final int TYPE_HARSH_TURN = 0x0C;

    public static final int TYPE_SEVERE_ACCEL = 0x0D;
    public static final int TYPE_SEVERE_BRAKE = 0x0E;
    public static final int TYPE_SEVERE_TURN = 0x0F;

    //Buffered
    public final static String STREAMING = "STREAMING";

    //Motion
    public final static String PARKING_MOTION = "PARKING_MOTION";

    //Bump
    public final static String PARKING_HIT = "PARKING_HIT";
    public final static String DRIVING_HIT = "DRIVING_HIT";

    //Impact
    public static final String PARKING_HEAVY_HIT = "PARKING_HEAVY_HIT";
    public static final String DRIVING_HEAVY_HIT = "DRIVING_HEAVY_HIT";

    //Highlight
    public final static String HIGHLIGHT = "HIGHLIGHT";

    //Behavior
    public static final String HARD_ACCEL = "HARD_ACCEL";
    public static final String HARD_BRAKE = "HARD_BRAKE";
    public static final String SHARP_TURN = "SHARP_TURN";

    public static final String HARSH_ACCEL = "HARSH_ACCEL";
    public static final String HARSH_BRAKE = "HARSH_BRAKE";
    public static final String HARSH_TURN = "HARSH_TURN";

    public static final String SEVERE_ACCEL = "SEVERE_ACCEL";
    public static final String SEVERE_BRAKE = "SEVERE_BRAKE";
    public static final String SEVERE_TURN = "SEVERE_TURN";
    public static final String OVER_SPEED_WARNING = "OVER_SPEED_WARNING";
    public static final String FORWARD_COLLISION_WARNING = "FORWARD_COLLISION_WARNING";
    public static final String MANUAL = "MANUAL";
    public static final String SUCCESS = "SUCCESS";
    public static final String FAILURE = "FAILURE";
    public static final String POWER_LOST = "POWER_LOST";
    public static final String HEADWAY_MONITORING_WARNING = "HEADWAY_MONITORING_WARNING";
    public static final String HEADWAY_MONITORING_EMERGENCY = "HEADWAY_MONITORING_EMERGENCY";

    public static final String ACCOUNT_LOCK  = "ACCOUNT_LOCK";
    public static final String ACCOUNT_UNLOCK  = "ACCOUNT_UNLOCK";
    public static final String SIMCARDINFOCHANGED  = "SIMCARDINFOCHANGED";
    public static final String CAMERATILTED_CHECKORIENTATION = "CAMERATILTED_CHECKORIENTATION";

    //DMS
    public static final String NO_DRIVER = "NO_DRIVER";
    public static final String DROWSY = "DROWSINESS";
    public static final String DRINKING = "DRINKING";
    public static final String SMOKING = "SMOKING";
    public static final String PHONE_CALLING = "PHONE_CALLING";
    public static final String USING_PHONE = "USING_PHONE";
    public static final String ASLEEP = "ASLEEP";
    public static final String DAYDREAMING = "DAYDREAMING";
    public static final String YAWNING = "YAWN";
    public static final String DISTRACTED = "DISTRACTED";
    public static final String ATTENTIVE = "ATTENTIVE";
    public static final String NO_SEATBELT = "NO_SEATBELT";
    public static final String UPLOAD_FAIL = "UPLOAD_FAIL";
    public static final String GET_SERVICE_STATUS_FAIL = "GET_SERVICE_STATUS_FAIL";

    public static final String DMS = "DMS";
    public static final String DRVN = "DRVN";
    public static final String ACCELERATOR = "ACCELERATOR";
    public static final String DRIVER_MANAGEMENT = "DRIVER_MANAGEMENT";
    public static final String HEADWAY_MONITORING = "HEADWAY_MONITORING";
    public static final String IGNITION = "IGNITION";
    public static final String ACCOUNT ="ACCOUNT";
    public static final String FORWARD_COLLISION ="FORWARD_COLLISION";
    public static final String PAYMENT ="PAYMENT";
    public static final String SYSTEM = "SYSTEM";
    public static final String ALL = "ALL";

    public static int getEventTypeForInteger(String eventType) {
        switch (eventType) {
            case DRIVING_HIT:
                return TYPE_DRIVING_HIT;
            case DRIVING_HEAVY_HIT:
                return TYPE_DRIVING_HEAVY_HIT;
            case PARKING_MOTION:
                return TYPE_PARKING_MOTION;
            case PARKING_HIT:
                return TYPE_PARKING_HIT;
            case PARKING_HEAVY_HIT:
                return TYPE_PARKING_HEAVY_HIT;
            case HIGHLIGHT:
                return TYPE_HIGHLIGHT;
            case HARD_ACCEL:
                return TYPE_HARD_ACCEL;
            case HARD_BRAKE:
                return TYPE_HARD_BRAKE;
            case SHARP_TURN:
                return TYPE_SHARP_TURN;
            case HARSH_ACCEL:
                return TYPE_HARSH_ACCEL;
            case HARSH_BRAKE:
                return TYPE_HARSH_BRAKE;
            case HARSH_TURN:
                return TYPE_HARSH_TURN;
            case SEVERE_ACCEL:
                return TYPE_SEVERE_ACCEL;
            case SEVERE_BRAKE:
                return TYPE_SEVERE_BRAKE;
            case SEVERE_TURN:
                return TYPE_SEVERE_TURN;
            default:
                return TYPE_BUFFERED;
        }
    }

    public static String getEventTypeForString(int eventType) {
        switch (eventType) {
            case TYPE_PARKING_MOTION:
                return PARKING_MOTION;
            case TYPE_PARKING_HIT:
                return PARKING_HIT;
            case TYPE_DRIVING_HIT:
                return DRIVING_HIT;
            case TYPE_PARKING_HEAVY_HIT:
                return PARKING_HEAVY_HIT;
            case TYPE_DRIVING_HEAVY_HIT:
                return DRIVING_HEAVY_HIT;
            case TYPE_HARD_ACCEL:
                return HARD_ACCEL;
            case TYPE_HARD_BRAKE:
                return HARD_BRAKE;
            case TYPE_SHARP_TURN:
                return SHARP_TURN;
            case TYPE_HARSH_ACCEL:
                return HARSH_ACCEL;
            case TYPE_HARSH_BRAKE:
                return HARSH_BRAKE;
            case TYPE_HARSH_TURN:
                return HARSH_TURN;
            case TYPE_SEVERE_ACCEL:
                return SEVERE_ACCEL;
            case TYPE_SEVERE_BRAKE:
                return SEVERE_BRAKE;
            case TYPE_SEVERE_TURN:
                return SEVERE_TURN;
            default:
                return STREAMING;
        }
    }

    public static String dealEventType(Context context, String eventType) {

        if (TextUtils.isEmpty(eventType) || eventType.equals("")){
            return "NULL";
        }

        switch (eventType) {
            case PARKING_MOTION:
                return context.getString(R.string.motion);
            case PARKING_HIT:
            case DRIVING_HIT:
                return context.getString(R.string.bump);
            case PARKING_HEAVY_HIT:
            case DRIVING_HEAVY_HIT:
                return context.getString(R.string.impact);
            case HIGHLIGHT:
                return context.getString(R.string.video_type_highlight);
            case HARD_ACCEL:
                return context.getString(R.string.hard_accel);
            case HARD_BRAKE:
                return context.getString(R.string.hard_brake);
            case SHARP_TURN:
                return context.getString(R.string.sharp_turn);
            case HARSH_ACCEL:
                return context.getString(R.string.harsh_accel);
            case HARSH_BRAKE:
                return context.getString(R.string.harsh_brake);
            case HARSH_TURN:
                return context.getString(R.string.harsh_turn);
            case SEVERE_ACCEL:
                return context.getString(R.string.severe_accel);
            case SEVERE_BRAKE:
                return context.getString(R.string.severe_brake);
            case SEVERE_TURN:
                return context.getString(R.string.severe_turn);
            case OVER_SPEED_WARNING:
            case FORWARD_COLLISION_WARNING:
                return context.getString(R.string.over_speed_warning);
            case NO_DRIVER:
                return context.getString(R.string.type_no_driver);
            case ASLEEP:
                return context.getString(R.string.type_asleep);
            case DROWSY:
                return context.getString(R.string.type_drowsy);
            case YAWNING:
                return context.getString(R.string.type_yawning);
            case DAYDREAMING:
                return context.getString(R.string.type_daydreaming);
            case USING_PHONE:
                return context.getString(R.string.type_using_phone);
            case SMOKING:
                return context.getString(R.string.type_smoking);
            case NO_SEATBELT:
                return context.getString(R.string.type_no_seatbelt);
            case DISTRACTED:
                return context.getString(R.string.type_distracted);
            case ATTENTIVE:
                return context.getString(R.string.type_attentive);
            case DRINKING:
                return context.getString(R.string.type_drinking);
            case UPLOAD_FAIL:
                return context.getString(R.string.upload_fail);
            case GET_SERVICE_STATUS_FAIL:
                return context.getString(R.string.get_service_status_fail);
            case MANUAL:
                return context.getString(R.string.manual);
            case SUCCESS:
                return context.getString(R.string.success);
            case FAILURE:
                return context.getString(R.string.failure);
            case POWER_LOST:
                return context.getString(R.string.power_lost);
            case HEADWAY_MONITORING_WARNING:
                return context.getString(R.string.login);
            case HEADWAY_MONITORING_EMERGENCY:
                return context.getString(R.string.logout);
            case ACCOUNT_LOCK:
                return context.getString(R.string.account_lock);
            case ACCOUNT_UNLOCK:
                return context.getString(R.string.account_unlock);
            case SIMCARDINFOCHANGED:
                return context.getString(R.string.simcardinfochanged);
            case CAMERATILTED_CHECKORIENTATION:
                return context.getString(R.string.cameratiled_check);
            case "DRIVING":
                return context.getString(R.string.driving);

            case "PARKING":
                return context.getString(R.string.parking);
            default:
                return eventType;
        }
    }


    public static String dealCategory(Context context, String category){
        switch (category){
            case DRIVER_MANAGEMENT:
            case HEADWAY_MONITORING:
                return context.getString(R.string.driver_managemant);
            case ACCELERATOR:
                return context.getString(R.string.accelerator);
            case MANUAL:
                return context.getString(R.string.manual);
            case PARKING_HIT:
                return context.getString(R.string.parking_hit);
            case SYSTEM:
                return context.getString(R.string.system);
            case IGNITION:
                return context.getString(R.string.ignition);
            case DRVN:
                return context.getString(R.string.drvn);
            case PAYMENT:
                return context.getString(R.string.payment);
            case ACCOUNT:
                return context.getString(R.string.account);
            case FORWARD_COLLISION:
                return context.getString(R.string.over_speed_warning);
            case "ALL":
                return "Tất cả";
            default:
                return category;
        }
    }


    public static String textToCategory(Context context, String text){
        if (context.getString(R.string.driver_managemant).trim().equals(text.trim())){
            return DRIVER_MANAGEMENT;
        }else if(context.getString(R.string.accelerator).trim().equals(text.trim())){
            return ACCELERATOR;
        }else if(context.getString(R.string.manual).trim().equals(text.trim())){
            return MANUAL;
        }else if(context.getString(R.string.parking_hit).trim().equals(text.trim())){
            return PARKING_HIT;
        }else if(context.getString(R.string.system).trim().equals(text.trim())){
            return SYSTEM;
        }else if(context.getString(R.string.ignition).trim().equals(text.trim())){
            return IGNITION;
        }else if(context.getString(R.string.drvn).trim().equals(text.trim())){
            return DRVN;
        }else if(context.getString(R.string.payment).trim().equals(text.trim())){
            return PAYMENT;
        }else if(context.getString(R.string.account).trim().equals(text.trim())){
            return ACCOUNT;
        }else if(context.getString(R.string.over_speed_warning).trim().equals(text.trim())){
            return FORWARD_COLLISION;
        }else if("Tất cả".trim().equals(text.trim())){
            return ALL;
        }else {
            return text;
        }
    }

    public static int getEventColor(String eventType) {
        if (TextUtils.isEmpty(eventType)) {
            return R.color.gray;
        }
        switch (eventType) {
            case PARKING_HIT:
            case DRIVING_HIT:
                return R.color.colorSettingHit;
            case PARKING_HEAVY_HIT:
            case DRIVING_HEAVY_HIT:
                return R.color.colorSettingHeavyHit;
            case PARKING_MOTION:
                return R.color.colorSettingMotion;
            case HIGHLIGHT:
                return R.color.blue;
            case HARD_ACCEL:
            case HARD_BRAKE:
            case SHARP_TURN:
            case HARSH_ACCEL:
            case HARSH_BRAKE:
            case HARSH_TURN:
            case SEVERE_ACCEL:
            case SEVERE_BRAKE:
            case SEVERE_TURN:
            case NO_DRIVER:
            case ASLEEP:
            case DROWSY:
            case YAWNING:
            case DAYDREAMING:
            case USING_PHONE:
            case SMOKING:
            case NO_SEATBELT:
            case DISTRACTED:
            case ATTENTIVE:
            case DRINKING:
                return R.color.colorBehavior;
            default:
                return R.color.gray;
        }
    }

    public static int getEventDrawable(String eventType) {
        switch (eventType) {
            case PARKING_HIT:
            case DRIVING_HIT:
                return R.drawable.view_type_bump;
            case PARKING_HEAVY_HIT:
            case DRIVING_HEAVY_HIT:
                return R.drawable.view_type_impact;
            case PARKING_MOTION:
                return R.drawable.view_type_motion;
            case HIGHLIGHT:
                return R.drawable.view_type_highlight;
            case HARD_ACCEL:
            case HARD_BRAKE:
            case SHARP_TURN:
            case HARSH_ACCEL:
            case HARSH_BRAKE:
            case HARSH_TURN:
            case SEVERE_ACCEL:
            case SEVERE_BRAKE:
            case SEVERE_TURN:
            case NO_DRIVER:
            case ASLEEP:
            case DROWSY:
            case YAWNING:
            case DAYDREAMING:
            case USING_PHONE:
            case SMOKING:
            case NO_SEATBELT:
            case DISTRACTED:
            case ATTENTIVE:
            case DRINKING:
                return R.drawable.view_type_behavior;
            default:
                return R.drawable.view_type_buffered;
        }
    }

    public static int getModeIconResourceVector(String mode){
        switch (mode){
            case "parking":
                return R.drawable.ic_parking_map;
            case "driving":
                return R.drawable.ic_driving_map;
            case "offline":
                return R.drawable.icon_offline_mode;
        }
        return R.drawable.ic_parking_map;
    }

    public static int getModeIconResource(String mode){
        switch (mode){
            case "parking":
                return R.drawable.icon_parking_map;
            case "driving":
                return R.drawable.icon_driving_map;
            case "offline":
                return R.drawable.icon_offline_mode;
        }
        return R.drawable.icon_parking_map;
    }

    public static int getEventIconResource(String eventType, boolean shadow) {

        Logger.t("getEventIconResource").d("EventType: "+eventType);
        switch (eventType) {
            case PARKING_HEAVY_HIT:
            case DRIVING_HEAVY_HIT:
                if (shadow) {
                    return R.drawable.icon_event_impact_shadow;
                } else {
                    return R.drawable.icon_event_impact;
                }
            case PARKING_HIT:
            case DRIVING_HIT:
                if (shadow) {
                    return R.drawable.icon_event_bump_shadow;
                } else {
                    return R.drawable.icon_event_bump;
                }
            case HARD_ACCEL:
            case HARSH_ACCEL:
            case SEVERE_ACCEL:
            case FORWARD_COLLISION_WARNING:
                if (shadow) {
                    return R.drawable.icon_event_hard_accel_shadow;
                } else {
                    return R.drawable.icon_event_hard_accel;
                }
            case HARD_BRAKE:
            case HARSH_BRAKE:
            case SEVERE_BRAKE:
                if (shadow) {
                    return R.drawable.icon_event_hard_brake_shadow;
                } else {
                    return R.drawable.icon_event_hard_brake;
                }
            case SHARP_TURN:
            case HARSH_TURN:
            case SEVERE_TURN:
                if (shadow) {
                    return R.drawable.icon_event_sharp_turn_shadow;
                } else {
                    return R.drawable.icon_event_sharp_turn;
                }
            case NO_DRIVER:
            case ASLEEP:
            case DROWSY:
            case YAWNING:
            case DAYDREAMING:
            case USING_PHONE:
            case SMOKING:
            case NO_SEATBELT:
            case DISTRACTED:
            case ATTENTIVE:
            case DRINKING:
                return R.drawable.icon_distracted;
        }
        return R.drawable.view_type_buffered;
    }

    public static List<String> getStringTypeFilterList(Context context, List<String> filterList) {
        List<String> typeList = new ArrayList<>();
        for (String item : filterList) {
            if (context.getString(R.string.motion).equals(item)) {
                typeList.add(PARKING_MOTION);
            } else if (context.getString(R.string.bump).equals(item)) {
                typeList.add(PARKING_HIT);
                typeList.add(DRIVING_HIT);
            } else if (context.getString(R.string.impact).equals(item)) {
                typeList.add(PARKING_HEAVY_HIT);
                typeList.add(DRIVING_HEAVY_HIT);
            } else if (context.getString(R.string.video_type_highlight).equals(item)) {
                typeList.add(HIGHLIGHT);
            } else if (context.getString(R.string.video_type_buffered).equals(item)) {
                typeList.add(STREAMING);
            } else if (context.getString(R.string.behavior).equals(item)) {
                typeList.add(HARD_ACCEL);
                typeList.add(HARD_BRAKE);
                typeList.add(SHARP_TURN);
                typeList.add(HARSH_ACCEL);
                typeList.add(HARSH_BRAKE);
                typeList.add(HARSH_TURN);
                typeList.add(SEVERE_ACCEL);
                typeList.add(SEVERE_BRAKE);
                typeList.add(SEVERE_TURN);
            }
        }
        return typeList;
    }

    public static List<Integer> getIntTypeFilterList(Context context, List<String> filterList) {
        List<Integer> typeList = new ArrayList<>();
        for (String item : filterList) {
            if (context.getString(R.string.motion).equals(item)) {
                typeList.add(TYPE_PARKING_MOTION);
            } else if (context.getString(R.string.bump).equals(item)) {
                typeList.add(TYPE_PARKING_HIT);
                typeList.add(TYPE_DRIVING_HIT);
            } else if (context.getString(R.string.impact).equals(item)) {
                typeList.add(TYPE_PARKING_HEAVY_HIT);
                typeList.add(TYPE_DRIVING_HEAVY_HIT);
            } else if (context.getString(R.string.video_type_highlight).equals(item)) {
                typeList.add(TYPE_HIGHLIGHT);
            } else if (context.getString(R.string.video_type_buffered).equals(item)) {
                typeList.add(TYPE_BUFFERED);
            } else if (context.getString(R.string.behavior).equals(item)) {
                typeList.add(TYPE_HARD_ACCEL);
                typeList.add(TYPE_HARD_BRAKE);
                typeList.add(TYPE_SHARP_TURN);
                typeList.add(TYPE_HARSH_ACCEL);
                typeList.add(TYPE_HARSH_BRAKE);
                typeList.add(TYPE_HARSH_TURN);
                typeList.add(TYPE_SEVERE_ACCEL);
                typeList.add(TYPE_SEVERE_BRAKE);
                typeList.add(TYPE_SEVERE_TURN);
            }
        }
        return typeList;
    }

    public static List<Integer> getEventTypeColorList(Context context) {
        List<Integer> colorList = new ArrayList<>();
        colorList.add(ContextCompat.getColor(context, R.color.gray));
        colorList.add(ContextCompat.getColor(context, R.color.colorSettingMotion));
        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHit));
        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHeavyHit));
        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHit));
        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHeavyHit));
        colorList.add(ContextCompat.getColor(context, R.color.blue));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
        return colorList;
    }
}
