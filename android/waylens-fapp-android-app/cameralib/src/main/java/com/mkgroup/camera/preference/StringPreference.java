package com.mkgroup.camera.preference;

import android.content.SharedPreferences;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by DoanVT on 2017/8/9.
 */


public final class StringPreference implements StringPreferenceType {

    private final static String TAG = StringPreference.class.getSimpleName();
    private final SharedPreferences mSharedPreferences;
    private final String key;
    private final String defaultValue;

    public StringPreference(final @NonNull SharedPreferences sharedPreferences, final @NonNull String key) {
        this(sharedPreferences, key, null);
        handleTransition();
    }

    public StringPreference(final @NonNull SharedPreferences sharedPreferences, final @NonNull String key,
                            final @Nullable String defaultValue) {
        this.mSharedPreferences = sharedPreferences;
        this.key = key;
        this.defaultValue = defaultValue;
    }

    @Override
    public String get() {
        final String encryptValue = mSharedPreferences.getString(encryptPreference(key), null);
        return encryptValue == null ? defaultValue : decryptPreference(encryptValue);
//        return sharedPreferences.getString(key, defaultValue);
    }

    @Override
    public boolean isSet() {
        return mSharedPreferences.contains(encryptPreference(key));
//        return mSharedPreferences.contains(key);
    }

    @Override
    public void set(final @NonNull String value) {
        mSharedPreferences.edit().putString(encryptPreference(key), encryptPreference(value)).apply();
//        mSharedPreferences.edit().putString(key, value).apply();
    }

    @Override
    public void delete() {
        mSharedPreferences.edit().remove(encryptPreference(key)).apply();
//        mSharedPreferences.edit().remove(key).apply();
    }

    /**
     * encrypt function
     *
     * @return cipherText base64
     */
    private String encryptPreference(String plainText) {
        return EncryptUtil.getInstance().encrypt(plainText);
    }

    /**
     * decrypt function
     *
     * @return plainText
     */
    private String decryptPreference(String cipherText) {
        return EncryptUtil.getInstance().decrypt(cipherText);
    }

    /**
     * 处理加密过渡
     */
    private void handleTransition() {
        boolean encrypt = PreferenceUtils.getBoolean(PreferenceUtils.ENCRYPT_SP, true);
//        Logger.t(TAG).e("encrypt: " + encrypt);
        if (encrypt) {
            Map<String, ?> oldMap = mSharedPreferences.getAll();
            Map<String, String> newMap = new HashMap<>();
            for (Map.Entry<String, ?> entry : oldMap.entrySet()) {
//                Logger.t(TAG).i("key:" + entry.getKey() + ", value:" + entry.getValue());
                newMap.put(encryptPreference(entry.getKey()), encryptPreference(entry.getValue().toString()));
            }
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            editor.clear().apply();
            for (Map.Entry<String, String> entry : newMap.entrySet()) {
                editor.putString(entry.getKey(), entry.getValue());
            }
            editor.commit();

            PreferenceUtils.putBoolean(PreferenceUtils.ENCRYPT_SP, false);
        }
    }

}
