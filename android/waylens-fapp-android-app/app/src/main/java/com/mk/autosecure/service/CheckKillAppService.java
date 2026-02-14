package com.mk.autosecure.service;

import static com.mk.autosecure.libs.utils.Constants.KEY_SHOW_UPDATE;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

import androidx.annotation.Nullable;

import com.mkgroup.camera.preference.PreferenceUtils;

public class CheckKillAppService extends Service {
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
    }
}
