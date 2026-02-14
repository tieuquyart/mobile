package com.mkgroup.camera.glide_adapter;

import android.content.Context;

import com.bumptech.glide.Glide;
import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.module.GlideModule;
import com.mkgroup.camera.network_adapter.OkHttpUrlLoader;
import com.mkgroup.camera.preference.PreferenceUtils;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;

/**
 * Created by doanvt on 2016/6/18.
 */
public class DefaultGlideModule implements GlideModule {

    private final static String TAG = DefaultGlideModule.class.getSimpleName();

    @Override
    public void applyOptions(Context context, GlideBuilder builder) {
    }

    @Override
    public void registerComponents(Context context, Glide glide) {
        final OkHttpClient.Builder builder = new OkHttpClient.Builder();

        builder.connectTimeout(15, TimeUnit.SECONDS);
        builder.readTimeout(15, TimeUnit.SECONDS);
        builder.writeTimeout(15, TimeUnit.SECONDS);

        HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
        logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

        builder.addInterceptor(logInterceptor);

        String cookie1 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_1, "");
        String cookie2 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_2, "");
        String cookie3 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_3, "");

        builder.addInterceptor(chain -> {
            Request request = chain.request();
            Request.Builder newBuilder = request.newBuilder();
            newBuilder.addHeader("Cookie", cookie1);
            newBuilder.addHeader("Cookie", cookie2);
            newBuilder.addHeader("Cookie", cookie3);
            return chain.proceed(newBuilder.build());
        });

        glide.register(String.class, InputStream.class, new OkHttpUrlLoader.Factory(builder.build()));
    }
}
