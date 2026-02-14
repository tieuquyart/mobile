package com.mk.autosecure.eid;

import android.content.SharedPreferences;

abstract class BasePreference {
    SharedPreferences preferences;
    SharedPreferences.Editor editor;

    public void save(String key, boolean val) {
        editor.putBoolean(key, val).apply();
    }

    void save(String key, String val) {
        editor.putString(key, val).apply();
    }

    void save(String key, int val) {
        editor.putInt(key, val).apply();
    }

    void save(String key, long val) {
        editor.putLong(key, val).apply();
    }

    boolean loadBoolean(String key) {
        return preferences.getBoolean(key, false);
    }

    String loadString(String key) {
        return preferences.getString(key, "vi");
    }

    int loadInt(String key) {
        return preferences.getInt(key, 0);
    }

    long loadLong(String key) {
        return preferences.getLong(key, 0);
    }
}
