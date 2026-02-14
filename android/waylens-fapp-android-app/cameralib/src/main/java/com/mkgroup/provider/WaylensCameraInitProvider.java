package com.mkgroup.provider;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ProviderInfo;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mkgroup.camera.WaylensCamera;
import com.orhanobut.logger.Logger;

/**
 * Created by cloud on 2020/11/15.
 */
public class WaylensCameraInitProvider extends ContentProvider {

    private final static String TAG = WaylensCameraInitProvider.class.getSimpleName();

    @Override
    public void attachInfo(Context context, ProviderInfo info) {
        if ("com.waylens.provider.WaylensCameraInitProvider".equals(info.authority)) {
            throw new IllegalStateException("Incorrect provider authority in manifest. Most likely due to a missing applicationId variable in application's build.gradle.");
        } else {
            super.attachInfo(context, info);
        }
    }

    @Override
    public boolean onCreate() {
        if (WaylensCamera.initializeWithDefaults(this.getContext()) != null) {
            Logger.t(TAG).i("WaylensCamera initialization successful");
        } else {
            Logger.t(TAG).i("WaylensCamera initialization unsuccessful");
        }
        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection, @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }
}
