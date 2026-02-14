package com.mk.autosecure.eid;

import android.content.Context;


public class UserPreference extends BasePreference {
    private static UserPreference instance;


    private final String KEY_FIREBASE_TOKE = "KEY_FIREBASE_TOKE";
    private final String KEY_APP_VERSION = "KEY_APP_VERSION";
    private final String KEY_LANG = "language";
    private final String KEY_WRONG_PIN_COUNT = "KEY_WRONG_PIN_COUNT";
    private final String KEY_TIME_DISABLE_PINPAD = "KEY_TIME_DISABLE_PINPAD";
    private final String KEY_COUNT_ACT_INCORRECT = "KEY_COUNT_ACT_INCORRECT";
    private final String KEY_CHECKBOX_OTP_BASIC = "KEY_CHECKBOX_OTP_BASIC";
    private final String KEY_CHECKBOX_OTP_ADVANCE = "KEY_CHECKBOX_OTP_ADVANCE";
    private final String KEY_USERS_WILL_REMOVE = "KEY_USERS_WILL_REMOVE";
    private final String COUNT = "COUNT";
    private final String DATA = "DATA";

    private final String LS = "LS";
    public static void init(Context context) {
        instance = new UserPreference(context);
    }

    public static UserPreference getInstance() {
        return instance;
    }

    private UserPreference(Context context) {
        preferences = context.getSharedPreferences("vn.tpb.token.e.h", Context.MODE_PRIVATE);
        editor = preferences.edit();
    }

    public void saveLicense(boolean s) {
        save(LS, s);
    }
    public boolean loadLicense() {
        return loadBoolean(LS);
    }

    public void saveData(String s) {
        save(DATA, s);
    }
    public String loadData() {
        return loadString(DATA);
    }


    public void saveFireBaseToken(String s) {
        save(KEY_FIREBASE_TOKE, s);
    }

    public String loadFireBaseToken() {
        return loadString(KEY_FIREBASE_TOKE);
    }

    public void saveAppVersion(String s) {
        save(KEY_APP_VERSION, s);
    }

    public String loadAppVersion() {
        return loadString(KEY_APP_VERSION);
    }

    public void saveLanguage(String s) {
        save(KEY_LANG, s);
    }

    public String loadLanguage() {
        return loadString(KEY_LANG);
    }

    public void saveCount(int s) {
        save(COUNT, s);
    }
    public int loadCount() {
       return loadInt(COUNT);
    }
    public void saveWrongPinCount(int n) {
        save(KEY_WRONG_PIN_COUNT, n);
    }

    public int loadWrongPinCount() {
        return loadInt(KEY_WRONG_PIN_COUNT);
    }

    public void saveWrongPinTime(long timestamp) {
        save(KEY_TIME_DISABLE_PINPAD, timestamp);
    }

    public long loadWrongPinTime() {
        return loadLong(KEY_TIME_DISABLE_PINPAD);
    }

    public void saveCountActiveIncorrect(int n) {
        save(KEY_COUNT_ACT_INCORRECT, n);
    }

    public int loadCountActiveIncorrect() {
        return loadInt(KEY_COUNT_ACT_INCORRECT);
    }

    public void saveCheckedOtpBasic(boolean checked) {
        save(KEY_CHECKBOX_OTP_BASIC, checked);
    }

    public boolean loadCheckedOtpBasic() {
        return loadBoolean(KEY_CHECKBOX_OTP_BASIC);
    }

    public void saveCheckedOtpAdvance(boolean checked) {
        save(KEY_CHECKBOX_OTP_ADVANCE, checked);
    }

    public boolean loadCheckedOtpAdvance() {
        return loadBoolean(KEY_CHECKBOX_OTP_ADVANCE);
    }


}
