package com.mk.autosecure.rest;

import com.orhanobut.logger.Logger;

import java.io.IOException;

import io.reactivex.functions.Consumer;
import retrofit2.HttpException;

/**
 * Created by DoanVT on 2017/9/19.
 * Email: doanvt-hn@mk.com.vn
 */

public class ServerErrorHandler implements Consumer<Throwable> {
    private String tag = "";

    public ServerErrorHandler() {
        this("");
    }

    public ServerErrorHandler(String tag) {
        this.tag = tag;
    }

    @Override
    public void accept(Throwable throwable) throws Exception {
        Logger.t(tag).d("throwable: %s", throwable.getMessage());
        if(throwable.getMessage() == null){
            return;
        }

        if (throwable instanceof HttpException) {
            HttpException ex = (HttpException) throwable;
            try {
                String string = ex.response().errorBody().string();
                Logger.t(tag).e("error: %s" + string);
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            throwable.printStackTrace();
        }
    }
}
