package com.mkgroup.camera.preference;

/**
 * Created by DoanVT on 2017/8/9.
 */

public interface StringPreferenceType {
    /**
     * Get the current value of the preference.
     */
    String get();

    /**
     * Returns whether a value has been explicitly set for the preference.
     */
    boolean isSet();

    /**
     * Set the preference to a value.
     */
    void set(String value);

    /**
     * Delete the currently stored preference.
     */
    void delete();
}