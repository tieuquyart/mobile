package com.mk.autosecure.libs.utils;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.LoginActivity;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.response.Response;

import com.mk.autosecure.R;

import java.io.IOException;
import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.util.concurrent.TimeoutException;

import javax.net.ssl.SSLHandshakeException;

import retrofit2.HttpException;


/**
 * Created by DoanVT on 2017/12/12.
 * Email: doanvt-hn@mk.com.vn
 */

public class NetworkErrorHelper {

    private final static String TAG = NetworkErrorHelper.class.getSimpleName();

    public static void handleExpireToken(Context activity, Response response){
        if (activity == null){
            return;
        }
        String msg = "";
        if(response.getCode().equals("980")){
            msg = response.getMessage();
            CurrentUser currentUser = HornApplication.getComponent().currentUser();
            if(currentUser.exists()){
                currentUser.logout();
            }
            LoginActivity.launchClearTask(activity);
        }else{
            msg = response.getMessage();
        }
        if (!TextUtils.isEmpty(msg)) {
            Toast.makeText(activity, msg, Toast.LENGTH_SHORT).show();
        }
    }

    public static void handleExpireToken(Activity activity, Response response){
        if (activity == null){
            return;
        }
        String msg = "";
        if(response.getCode().equals("980")){
            msg = response.getMessage();
            CurrentUser currentUser = HornApplication.getComponent().currentUser();
            if(currentUser.exists()){
                currentUser.logout();
            }
            LoginActivity.launchClearTask(activity);
        }else{
            msg = response.getMessage();
        }
        if (!TextUtils.isEmpty(msg)) {
            Toast.makeText(activity, msg, Toast.LENGTH_SHORT).show();
        }
    }

    public static void handleCommonError(Context context, Throwable throwable) {
        Logger.t(TAG).e("handleCommonError: " + throwable.getMessage());

        if (context == null) {
            return;
        }

        Resources resources = context.getResources();
        String msg;

        if (throwable instanceof ConnectException) {
            msg = resources.getString(R.string.error_network_unavailable);
        } else if (throwable instanceof SocketTimeoutException) {
            msg = resources.getString(R.string.error_network_timeout);
        } else if (throwable instanceof TimeoutException) {
            msg = resources.getString(R.string.error_network_timeout);
        } else if (throwable instanceof SSLHandshakeException) {
            msg = resources.getString(R.string.error_network_unavailable);
        } else if (throwable instanceof HttpException) {
            msg = resources.getString(R.string.error_network_unknown);
        } else if (throwable instanceof IOException) {
            msg = resources.getString(R.string.error_network_unknown);
        } else {
            msg = throwable.getMessage();
        }

        if (!TextUtils.isEmpty(msg)) {
            Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
        }
    }
}
