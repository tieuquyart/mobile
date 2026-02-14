package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.data.SnipeError;

public class DmsResponse<T> {

    public interface Listener<T> {
        void onResponse(T response);
    }

    public interface ErrorListener {
        void onErrorResponse(SnipeError error);
    }

    public static <T> DmsResponse<T> success(T result) {
        return new DmsResponse<T>(result);
    }

    public final T result;
    public final SnipeError error;

    private DmsResponse(T result) {
        this.result = result;
        this.error = null;
    }

    private DmsResponse(SnipeError error) {
        this.result = null;
        this.error = error;
    }

    public boolean isSuccess() {
        return error == null;
    }
}
