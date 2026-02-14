package com.mk.autosecure.ui.view;

import android.os.Handler;
import android.os.Message;

import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;

import io.reactivex.functions.Action;

/**
 * Created by DoanVT on 2017/9/21.
 */

public class ControlPanelHandler extends Handler {
    private WeakReference<Action> mRef;
    public static final int FADE_OUT = 0x01;

    public ControlPanelHandler(Action action) {
        super();
        mRef = new WeakReference<>(action);
    }

    @Override
    public void handleMessage(Message msg) {
        Action action = mRef.get();
        if (action == null) {
            return;
        }
        Logger.t(ControlPanelHandler.class.getSimpleName()).d("handle message");
        switch (msg.what) {
            case FADE_OUT:
                try {
                    action.run();
                } catch (Exception e) {
                    Logger.t(ControlPanelHandler.class.getSimpleName()).d("component is be GCed!");
                }
                break;
            default:
                break;
        }
    }
}