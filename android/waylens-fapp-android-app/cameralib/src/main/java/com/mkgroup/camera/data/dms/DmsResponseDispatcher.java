package com.mkgroup.camera.data.dms;

import java.util.concurrent.ConcurrentHashMap;

public class DmsResponseDispatcher extends Thread {

    private static final String TAG = DmsResponseDispatcher.class.getSimpleName();

    private final ConcurrentHashMap<Long, DmsRequest<?>> mDmsRequestQueue;
    private final ConcurrentHashMap<Integer, DmsMessageHandler<?>> mMessageHandlers;
    private final ISocket mISocket;
    private final IResponseDelivery mDelivery;
    private volatile boolean mQuit = false;

    public DmsResponseDispatcher(ConcurrentHashMap<Long, DmsRequest<?>> dmsRequestQueue, ConcurrentHashMap<Integer, DmsMessageHandler<?>> messageHandlers, ISocket iSocket, IResponseDelivery delivery) {
        super("DmsResponseDispatcher");
        mDmsRequestQueue = dmsRequestQueue;
        mMessageHandlers = messageHandlers;
        mISocket = iSocket;
        mDelivery = delivery;
    }

    @Override
    public void run() {
        while (true) {
            if (mQuit) {
                return;
            }
            DmsAcknowledge dmsAcknowledge;
            try {
                dmsAcknowledge = mISocket.retrieveAcknowledge();
            } catch (Exception e) {
                if (mQuit) {
                    return;
                }
                continue;
            }
            DmsRequest<?> dmsRequest;
            if (dmsAcknowledge.isMessageAck()) {
                if ((dmsRequest = mMessageHandlers.get(dmsAcknowledge.getMsgCode())) == null) {
                    continue;
                }
            } else {
                dmsRequest = mDmsRequestQueue.get(dmsAcknowledge.getUser1());
                if (dmsRequest == null || dmsRequest.getDmsCommand().getCommandCode() != dmsAcknowledge.getMsgCode()) {
                    continue;
                }
            }

            dmsRequest.addMarker("com.waylens.camera.library.dms-complete");

            if (dmsAcknowledge.notModified && dmsRequest.hasHadResponseDelivered()) {
                dmsRequest.finish("not-modified", true);
                continue;
            }

            DmsResponse<?> dmsResponse = dmsRequest.parseDmsResponse(dmsAcknowledge);
            dmsRequest.addMarker("com.waylens.camera.libray.dms-fromBinary-complete");

            dmsRequest.markDelivered();
            mDelivery.postResponse(dmsRequest, dmsResponse);
        }
    }

    void quit() {
        mQuit = true;
        interrupt();
    }
}
