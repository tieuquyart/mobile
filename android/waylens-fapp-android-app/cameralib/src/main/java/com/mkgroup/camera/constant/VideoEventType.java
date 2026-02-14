package com.mkgroup.camera.constant;

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

//    public static String dealEventType(Context context, String eventType) {
//        switch (eventType) {
//            case PARKING_MOTION:
//                return context.getString(R.string.motion);
//            case PARKING_HIT:
//            case DRIVING_HIT:
//                return context.getString(R.string.bump);
//            case PARKING_HEAVY_HIT:
//            case DRIVING_HEAVY_HIT:
//                return context.getString(R.string.impact);
//            case HIGHLIGHT:
//                return context.getString(R.string.video_type_highlight);
//            case HARD_ACCEL:
//                return context.getString(R.string.hard_accel);
//            case HARD_BRAKE:
//                return context.getString(R.string.hard_brake);
//            case SHARP_TURN:
//                return context.getString(R.string.sharp_turn);
//            case HARSH_ACCEL:
//                return context.getString(R.string.harsh_accel);
//            case HARSH_BRAKE:
//                return context.getString(R.string.harsh_brake);
//            case HARSH_TURN:
//                return context.getString(R.string.harsh_turn);
//            case SEVERE_ACCEL:
//                return context.getString(R.string.severe_accel);
//            case SEVERE_BRAKE:
//                return context.getString(R.string.severe_brake);
//            case SEVERE_TURN:
//                return context.getString(R.string.severe_turn);
//            case NO_DRIVER:
//                return context.getString(R.string.type_no_driver);
//            case ASLEEP:
//                return context.getString(R.string.type_asleep);
//            case DROWSY:
//                return context.getString(R.string.type_drowsy);
//            case YAWNING:
//                return context.getString(R.string.type_yawning);
//            case DAYDREAMING:
//                return context.getString(R.string.type_daydreaming);
//            case USING_PHONE:
//                return context.getString(R.string.type_using_phone);
//            case SMOKING:
//                return context.getString(R.string.type_smoking);
//            case NO_SEATBELT:
//                return context.getString(R.string.type_no_seatbelt);
//            case DISTRACTED:
//                return context.getString(R.string.type_distracted);
//            case ATTENTIVE:
//                return context.getString(R.string.type_attentive);
//            case DRINKING:
//                return context.getString(R.string.type_drinking);
//            default:
//                return context.getString(R.string.video_type_buffered);
//        }
//    }

//    public static int getEventColor(String eventType) {
//        switch (eventType) {
//            case PARKING_HIT:
//            case DRIVING_HIT:
//                return R.color.colorSettingHit;
//            case PARKING_HEAVY_HIT:
//            case DRIVING_HEAVY_HIT:
//                return R.color.colorSettingHeavyHit;
//            case PARKING_MOTION:
//                return R.color.colorSettingMotion;
//            case HIGHLIGHT:
//                return R.color.blue;
//            case HARD_ACCEL:
//            case HARD_BRAKE:
//            case SHARP_TURN:
//            case HARSH_ACCEL:
//            case HARSH_BRAKE:
//            case HARSH_TURN:
//            case SEVERE_ACCEL:
//            case SEVERE_BRAKE:
//            case SEVERE_TURN:
//            case NO_DRIVER:
//            case ASLEEP:
//            case DROWSY:
//            case YAWNING:
//            case DAYDREAMING:
//            case USING_PHONE:
//            case SMOKING:
//            case NO_SEATBELT:
//            case DISTRACTED:
//            case ATTENTIVE:
//            case DRINKING:
//                return R.color.colorBehavior;
//            default:
//                return R.color.gray;
//        }
//    }

//    public static int getEventDrawable(String eventType) {
//        switch (eventType) {
//            case PARKING_HIT:
//            case DRIVING_HIT:
//                return R.drawable.view_type_bump;
//            case PARKING_HEAVY_HIT:
//            case DRIVING_HEAVY_HIT:
//                return R.drawable.view_type_impact;
//            case PARKING_MOTION:
//                return R.drawable.view_type_motion;
//            case HIGHLIGHT:
//                return R.drawable.view_type_highlight;
//            case HARD_ACCEL:
//            case HARD_BRAKE:
//            case SHARP_TURN:
//            case HARSH_ACCEL:
//            case HARSH_BRAKE:
//            case HARSH_TURN:
//            case SEVERE_ACCEL:
//            case SEVERE_BRAKE:
//            case SEVERE_TURN:
//            case NO_DRIVER:
//            case ASLEEP:
//            case DROWSY:
//            case YAWNING:
//            case DAYDREAMING:
//            case USING_PHONE:
//            case SMOKING:
//            case NO_SEATBELT:
//            case DISTRACTED:
//            case ATTENTIVE:
//            case DRINKING:
//                return R.drawable.view_type_behavior;
//            default:
//                return R.drawable.view_type_buffered;
//        }
//    }

//    public static int getEventIconResource(String eventType, boolean shadow) {
//        switch (eventType) {
//            case PARKING_HEAVY_HIT:
//            case DRIVING_HEAVY_HIT:
//                if (shadow) {
//                    return R.drawable.icon_event_impact_shadow;
//                } else {
//                    return R.drawable.icon_event_impact;
//                }
//            case PARKING_HIT:
//            case DRIVING_HIT:
//                if (shadow) {
//                    return R.drawable.icon_event_bump_shadow;
//                } else {
//                    return R.drawable.icon_event_bump;
//                }
//            case HARD_ACCEL:
//            case HARSH_ACCEL:
//            case SEVERE_ACCEL:
//                if (shadow) {
//                    return R.drawable.icon_event_hard_accel_shadow;
//                } else {
//                    return R.drawable.icon_event_hard_accel;
//                }
//            case HARD_BRAKE:
//            case HARSH_BRAKE:
//            case SEVERE_BRAKE:
//                if (shadow) {
//                    return R.drawable.icon_event_hard_brake_shadow;
//                } else {
//                    return R.drawable.icon_event_hard_brake;
//                }
//            case SHARP_TURN:
//            case HARSH_TURN:
//            case SEVERE_TURN:
//                if (shadow) {
//                    return R.drawable.icon_event_sharp_turn_shadow;
//                } else {
//                    return R.drawable.icon_event_sharp_turn;
//                }
//            case NO_DRIVER:
//            case ASLEEP:
//            case DROWSY:
//            case YAWNING:
//            case DAYDREAMING:
//            case USING_PHONE:
//            case SMOKING:
//            case NO_SEATBELT:
//            case DISTRACTED:
//            case ATTENTIVE:
//            case DRINKING:
//                return R.drawable.icon_distracted;
//        }
//        return R.drawable.icon_event_sharp_turn;
//    }

//    public static List<String> getStringTypeFilterList(Context context, List<String> filterList) {
//        List<String> typeList = new ArrayList<>();
//        for (String item : filterList) {
//            if (context.getString(R.string.motion).equals(item)) {
//                typeList.add(PARKING_MOTION);
//            } else if (context.getString(R.string.bump).equals(item)) {
//                typeList.add(PARKING_HIT);
//                typeList.add(DRIVING_HIT);
//            } else if (context.getString(R.string.impact).equals(item)) {
//                typeList.add(PARKING_HEAVY_HIT);
//                typeList.add(DRIVING_HEAVY_HIT);
//            } else if (context.getString(R.string.video_type_highlight).equals(item)) {
//                typeList.add(HIGHLIGHT);
//            } else if (context.getString(R.string.video_type_buffered).equals(item)) {
//                typeList.add(STREAMING);
//            } else if (context.getString(R.string.behavior).equals(item)) {
//                typeList.add(HARD_ACCEL);
//                typeList.add(HARD_BRAKE);
//                typeList.add(SHARP_TURN);
//                typeList.add(HARSH_ACCEL);
//                typeList.add(HARSH_BRAKE);
//                typeList.add(HARSH_TURN);
//                typeList.add(SEVERE_ACCEL);
//                typeList.add(SEVERE_BRAKE);
//                typeList.add(SEVERE_TURN);
//            }
//        }
//        return typeList;
//    }

//    public static List<Integer> getIntTypeFilterList(Context context, List<String> filterList) {
//        List<Integer> typeList = new ArrayList<>();
//        for (String item : filterList) {
//            if (context.getString(R.string.motion).equals(item)) {
//                typeList.add(TYPE_PARKING_MOTION);
//            } else if (context.getString(R.string.bump).equals(item)) {
//                typeList.add(TYPE_PARKING_HIT);
//                typeList.add(TYPE_DRIVING_HIT);
//            } else if (context.getString(R.string.impact).equals(item)) {
//                typeList.add(TYPE_PARKING_HEAVY_HIT);
//                typeList.add(TYPE_DRIVING_HEAVY_HIT);
//            } else if (context.getString(R.string.video_type_highlight).equals(item)) {
//                typeList.add(TYPE_HIGHLIGHT);
//            } else if (context.getString(R.string.video_type_buffered).equals(item)) {
//                typeList.add(TYPE_BUFFERED);
//            } else if (context.getString(R.string.behavior).equals(item)) {
//                typeList.add(TYPE_HARD_ACCEL);
//                typeList.add(TYPE_HARD_BRAKE);
//                typeList.add(TYPE_SHARP_TURN);
//                typeList.add(TYPE_HARSH_ACCEL);
//                typeList.add(TYPE_HARSH_BRAKE);
//                typeList.add(TYPE_HARSH_TURN);
//                typeList.add(TYPE_SEVERE_ACCEL);
//                typeList.add(TYPE_SEVERE_BRAKE);
//                typeList.add(TYPE_SEVERE_TURN);
//            }
//        }
//        return typeList;
//    }

//    public static List<Integer> getEventTypeColorList(Context context) {
//        List<Integer> colorList = new ArrayList<>();
//        colorList.add(ContextCompat.getColor(context, R.color.gray));
//        colorList.add(ContextCompat.getColor(context, R.color.colorSettingMotion));
//        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHit));
//        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHeavyHit));
//        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHit));
//        colorList.add(ContextCompat.getColor(context, R.color.colorSettingHeavyHit));
//        colorList.add(ContextCompat.getColor(context, R.color.blue));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        colorList.add(ContextCompat.getColor(context, R.color.colorBehavior));
//        return colorList;
//    }
}
