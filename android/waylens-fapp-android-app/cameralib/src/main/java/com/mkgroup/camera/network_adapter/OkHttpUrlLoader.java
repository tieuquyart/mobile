package com.mkgroup.camera.network_adapter;

import android.content.Context;

import com.bumptech.glide.load.data.DataFetcher;
import com.bumptech.glide.load.model.GenericLoaderFactory;
import com.bumptech.glide.load.model.ModelLoader;
import com.bumptech.glide.load.model.ModelLoaderFactory;
import com.bumptech.glide.load.model.stream.StreamModelLoader;
import com.mkgroup.camera.utils.NetworkUtils;
import com.orhanobut.logger.Logger;

import java.io.InputStream;

import okhttp3.OkHttpClient;

/**
 * Created by DoanVT on 2017/10/25.
 * Email: doanvt-hn@mk.com.vn
 */

public class OkHttpUrlLoader implements StreamModelLoader<String> {

    private final static String TAG = OkHttpUrlLoader.class.getSimpleName();

    /**
     * The default factory for {@link OkHttpUrlLoader}s.
     */
    public static class Factory implements ModelLoaderFactory<String, InputStream> {
        private static volatile OkHttpClient internalClient;
        private static volatile OkHttpClient cellularClient;
        private OkHttpClient client;

        private static OkHttpClient getInternalClient() {
            if (internalClient == null) {
                synchronized (Factory.class) {
                    if (internalClient == null) {
                        internalClient = OkHttpClientFactory.getOkHttpClient(false);
                    }
                }
            }
            return internalClient;
        }

        private static OkHttpClient getCellularClient() {
            if (cellularClient == null) {
                synchronized (Factory.class) {
                    if (cellularClient == null) {
                        cellularClient = OkHttpClientFactory.getOkHttpClient(true);
                    }
                }
            }
            return cellularClient;
        }

        //这里写成单例有问题
        public static OkHttpClient getClient() {
            Logger.t(TAG).e("isNetworkLimited = %s", NetworkUtils.isNetworkLimited());
            if (NetworkUtils.isNetworkLimited()) {
                return getCellularClient();
            } else {
                return getInternalClient();
            }
        }

        /**
         * Constructor for a new Factory that runs requests using a static singleton client.
         */
        public Factory() {
            this(getClient());
//            Logger.t(TAG).e("Factory");
        }

        /**
         * Constructor for a new Factory that runs requests using given client.
         */
        public Factory(OkHttpClient client) {
            this.client = client;
        }

        @Override
        public ModelLoader<String, InputStream> build(Context context, GenericLoaderFactory factories) {
            return new OkHttpUrlLoader(client);
        }

        @Override
        public void teardown() {
            // Do nothing, this instance doesn't own the client.
        }
    }

    private final OkHttpClient client;

    public OkHttpUrlLoader() {
        this(Factory.getClient());
//        Logger.t(TAG).e("OkHttpUrlLoader");
    }

    public OkHttpUrlLoader(OkHttpClient client) {
        this.client = client;
    }

    @Override
    public DataFetcher<InputStream> getResourceFetcher(String model, int width, int height) {
        return new OkHttpStreamFetcher(client, model);
    }
}