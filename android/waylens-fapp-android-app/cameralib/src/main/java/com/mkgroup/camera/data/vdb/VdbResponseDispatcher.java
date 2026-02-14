package com.mkgroup.camera.data.vdb;


import com.orhanobut.logger.Logger;

import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by Richard on 12/27/15.
 */
public class VdbResponseDispatcher extends Thread {
    private static final String TAG = VdbResponseDispatcher.class.getSimpleName();

    private final ConcurrentHashMap<Integer, VdbRequest<?>> mVdbRequestQueue;
    private final ConcurrentHashMap<Integer, VdbMessageHandler<?>> mMessageHandlers;
    private final VdbSocket mVdbSocket;
    private final ResponseDelivery mDelivery;
    private volatile boolean mQuit = false;

    VdbResponseDispatcher(ConcurrentHashMap<Integer, VdbRequest<?>> vdbRequestQueue,
                          ConcurrentHashMap<Integer, VdbMessageHandler<?>> messageHandlers,
                          VdbSocket socket, ResponseDelivery delivery) {
        super("VdbResponseDispatcher");
        mVdbRequestQueue = vdbRequestQueue;
        mMessageHandlers = messageHandlers;
        mVdbSocket = socket;
        mDelivery = delivery;
    }

    void quit() {
        mQuit = true;
        interrupt();
    }

    @Override
    public void run() {
        while (true) {
            if (mQuit) {
                return;
            }
            VdbAcknowledge vdbAcknowledge;

            try {
                vdbAcknowledge = mVdbSocket.retrieveAcknowledge();
            } catch (Exception e) {
                if (mQuit) {
                    return;
                }
                continue;
            }

            VdbRequest<?> vdbRequest;

            int msgCode = vdbAcknowledge.getMsgCode();
//            Logger.t(TAG).e("MessageCode: " + msgCode);

            if (vdbAcknowledge.isMessageAck()) {
//                Logger.t(TAG).e("MessageCode: " + vdbAcknowledge.getMsgCode());
                if ((vdbRequest = mMessageHandlers.get(vdbAcknowledge.getMsgCode())) == null) {
//                    Logger.t(TAG).e("MessageCode: " + vdbAcknowledge.getMsgCode());
                    continue;
                }
            } else {
                vdbRequest = mVdbRequestQueue.get(vdbAcknowledge.getUser1());
                if (vdbRequest == null || vdbRequest.getVdbCommand().getCommandCode() != vdbAcknowledge.getMsgCode()) {
                    Logger.t(TAG).e(String.format(Locale.getDefault(), "Fatal Error:msgCode[%d], " + "cmdCode[%d], seq[%d]",
                            vdbAcknowledge.getMsgCode(), vdbAcknowledge.getUser1(), vdbAcknowledge.getUser1()));
                    continue;
                }
            }

            vdbRequest.addMarker("com.waylens.hachi.library.vdb-complete");

            if (vdbAcknowledge.notModified && vdbRequest.hasHadResponseDelivered()) {
                vdbRequest.finish("not-modified", true);
                continue;
            }

            VdbResponse<?> vdbResponse = vdbRequest.parseVdbResponse(vdbAcknowledge);
            vdbRequest.addMarker("com.waylens.hachi.library.vdb-fromBinary-complete");

            vdbRequest.markDelivered();
            mDelivery.postResponse(vdbRequest, vdbResponse);
        }
    }
}
