package com.mkgroup.camera.data.dms;

import android.os.Process;


import com.mkgroup.camera.data.SnipeError;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.PriorityBlockingQueue;

public class DmsDispatcher extends Thread {

    private final static String TAG = DmsDispatcher.class.getSimpleName();
    private final BlockingQueue<DmsRequest<?>> mQueue;
    private final ISocket mISocket;
    private final IResponseDelivery mDelivery;

    private volatile boolean mQuit = false;

    DmsDispatcher(PriorityBlockingQueue<DmsRequest<?>> queue, ISocket iSocket, IResponseDelivery delivery) {
        super("DmsDispatcher");
        this.mQueue = queue;
        this.mISocket = iSocket;
        this.mDelivery = delivery;
    }


    void quit() {
        mQuit = true;
        interrupt();
    }

    @Override
    public void run() {
//        super.run();
        Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
        while (true) {
            DmsRequest<?> dmsRequest;

            try {
                dmsRequest = mQueue.take();
            } catch (InterruptedException e) {
                if (mQuit) {
                    return;
                }
                continue;
            }

            try {
                dmsRequest.addMarker("com.waylens.camera.library.dms-queue-take");

                if (dmsRequest.isCanceled()) {
                    dmsRequest.finish("com.waylens.camera.library.dms-discard-canceled", true);
                    continue;
                }
                mISocket.performRequest(dmsRequest);
            } catch (SnipeError error) {
                error.printStackTrace();
                parseAndDeliverDmsError(dmsRequest, error);
            }
        }
    }

    private void parseAndDeliverDmsError(DmsRequest<?> dmsRequest, SnipeError error) {
        error = dmsRequest.parseDmsError(error);
        mDelivery.postError(dmsRequest, error);
    }
}
