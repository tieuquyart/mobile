package com.mkgroup.camera.data.dms;

public abstract class DmsMessageHandler<T> extends DmsRequest<T> {

    private int mMessageCode;

    public DmsMessageHandler(int method, DmsResponse.Listener<T> listener, DmsResponse.ErrorListener errorListener) {
        super(method, listener, errorListener);
        mMessageCode = method;
        setIsMessageHandler(true);
    }

    int getMessageCode() {
        return mMessageCode;
    }

    @Override
    protected DmsCommand createDmsCommand() {
        return null;
    }
}
