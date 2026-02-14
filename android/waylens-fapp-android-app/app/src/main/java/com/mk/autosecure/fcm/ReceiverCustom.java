package com.mk.autosecure.fcm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.orhanobut.logger.Logger;

public class ReceiverCustom extends BroadcastReceiver {
    private String TAG = ReceiverCustom.class.getSimpleName();
    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.t(TAG).d("test receiver " + intent.getData());
    }
}
