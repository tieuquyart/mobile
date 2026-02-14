package com.mk.autosecure.rest;

import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;

import java.io.IOException;
import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.util.concurrent.TimeoutException;

import javax.net.ssl.SSLHandshakeException;

import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import retrofit2.HttpException;
import retrofit2.Response;

/*
 * Created by doanvtchen on 2018/1/14.
 */

public abstract class BaseObserver<T> implements Observer<T> {

    private static final String TAG = BaseObserver.class.getSimpleName();

    //所有X-Auth-token相关的错误：如token过期，错误，被废除等，返回的错误都是
    private final static int ERROR_TOKEN = 23;
    private final static int FLEET_ERROR_TOKEN = 3999;

    //所有跟权限检查相关的错误：如user没有相机的操作权限等， 返回的错误都是
    private final static int ERROR_AUTHORIZE = 24;
    private final static int FLEET_ERROR_AUTHORIZE = 4101;

    private Context mContext;
    private Disposable d;

    protected BaseObserver() {
        mContext = HornApplication.getContext();
    }

    @Override
    public void onSubscribe(Disposable d) {
//        Logger.t(TAG).d("onSubscribe");
        this.d = d;
    }

    @Override
    public void onNext(T data) {
//        Logger.t(TAG).d("onNext: " + data.toString());
        if (data instanceof Response) {
            Response response = ((Response) data);
            boolean successful = response.isSuccessful();
            int code = response.code();
            Object body = response.body();

            Logger.t(TAG).d("successful: " + successful);
//            Logger.t(TAG).d("code: " + code);
//            Logger.t(TAG).d("body: " + body);

            if (successful) {
                onHandleSuccess(data);
            } else {
                try {
                    String string = response.errorBody().string();
                    Logger.t(TAG).e("errorBody: " + string);
                    ErrorEnvelope errorEnvelope = new Gson().fromJson(string, ErrorEnvelope.class);
                    handleApiError(errorEnvelope.code, errorEnvelope.getErrorMessage());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        } else {
            onHandleSuccess(data);
        }
    }

    @Override
    public void onError(Throwable throwable) {
        Logger.t(TAG).d("onError: " + throwable.getMessage());
        unSubscribe();

        int errorCode = -1;
        Resources resources = mContext.getResources();
        String msg = "";

        if (throwable instanceof HttpException) {
            HttpException ex = (HttpException) throwable;
            try {
                String string = ex.response().errorBody().string();
                Logger.t(TAG).d("error: %s", string);
                ErrorEnvelope response = new Gson().fromJson(string, ErrorEnvelope.class);
                errorCode = response.code;
                msg = response.getErrorMessage();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                msg = TextUtils.isEmpty(msg) ? resources.getString(R.string.error_network_unknown) : msg;
            }
        } else if (throwable instanceof SocketTimeoutException) {
            msg = resources.getString(R.string.error_network_timeout);
        } else if (throwable instanceof TimeoutException) {
            msg = resources.getString(R.string.error_network_timeout);
        } else if (throwable instanceof SSLHandshakeException) {
            msg = resources.getString(R.string.error_network_unavailable);
        } else if (throwable instanceof ConnectException) {
            msg = resources.getString(R.string.error_network_unavailable);
        } else {
            msg = resources.getString(R.string.error_network_unknown);
        }
        handleApiError(errorCode, msg);
    }

    private void handleApiError(int code, String msg) {
        Logger.t(TAG).d("handleApiError: " + code + "---" + msg);
        CurrentUser currentUser = HornApplication.getComponent().currentUser();
        switch (code) {
            case -1:
                if (Constants.isFleet()/* && !Constants.isDriver()*/) {
                    Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
                }
                break;
            case ERROR_AUTHORIZE:
            case FLEET_ERROR_AUTHORIZE:
                break;
            case ERROR_TOKEN:
                if (currentUser.exists() && !Constants.isFleet()) {
                    currentUser.logout();
                    LocalLiveActivity.launch(mContext, true);
                }
                break;
            case FLEET_ERROR_TOKEN:
                if (currentUser.exists() && Constants.isFleet()) {
                    currentUser.logout();
                    LocalLiveActivity.launch(mContext, true);
                }
                break;
            default:
                Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
                break;
        }
    }

    @Override
    public void onComplete() {
//        Logger.t(TAG).d("onComplete");
        unSubscribe();
    }

    private void unSubscribe() {
//        Logger.t(TAG).d("unSubscribe");
        //如果处于订阅状态，则取消订阅
        if (d != null && !d.isDisposed()) {
            d.dispose();
        }
    }

    protected abstract void onHandleSuccess(T data);

//    protected abstract void onHandleError();

}
