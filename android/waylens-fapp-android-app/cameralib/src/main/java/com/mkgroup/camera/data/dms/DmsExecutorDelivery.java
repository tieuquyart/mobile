package com.mkgroup.camera.data.dms;

import android.os.Handler;


import com.mkgroup.camera.data.SnipeError;

import java.util.concurrent.Executor;

public class DmsExecutorDelivery implements IResponseDelivery {

    private final Executor mExecutor;

    DmsExecutorDelivery(final Handler handler) {
        mExecutor = handler::post;
    }

    @Override
    public void postResponse(DmsRequest<?> dmsRequest, DmsResponse<?> dmsResponse) {
        postResponse(dmsRequest, dmsResponse, null);
    }

    @Override
    public void postResponse(DmsRequest<?> dmsRequest, DmsResponse<?> dmsResponse, Runnable runnable) {
        dmsRequest.markDelivered();
        dmsRequest.addMarker("com.waylens.camera.library.post-response");

        mExecutor.execute(new DeliveryRunnable(dmsRequest, dmsResponse, runnable));
    }

    @Override
    public void postError(DmsRequest<?> dmsRequest, SnipeError error) {
        postResponse(dmsRequest, null, null);
    }

    private static class DeliveryRunnable implements Runnable {

        private final DmsRequest mRequest;
        private final DmsResponse mResponse;
        private final Runnable mRunnable;

        public DeliveryRunnable(DmsRequest dmsRequest, DmsResponse<?> dmsResponse, Runnable runnable) {
            this.mRequest = dmsRequest;
            this.mResponse = dmsResponse;
            this.mRunnable = runnable;
        }

        @Override
        public void run() {
            if (mRequest.isCanceled()) {
                mRequest.finish("canceled-at-delivery", true);
                return;
            } else {
                mRequest.finish("finish-at-delivery", false);
            }

            if (mResponse != null && mResponse.isSuccess()) {
                mRequest.deliveryResponse(mResponse.result);
            } else {
                mRequest.deliveryError(new SnipeError());
            }
        }
    }
}
