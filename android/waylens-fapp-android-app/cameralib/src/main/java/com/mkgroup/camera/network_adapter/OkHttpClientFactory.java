package com.mkgroup.camera.network_adapter;

import android.net.Network;

import com.mkgroup.camera.rest.NetworkService;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Dns;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * Created by DoanVT on 2017/10/26.
 * Email: doanvt-hn@mk.com.vn
 */

public class OkHttpClientFactory {
    private static final String TAG = OkHttpClientFactory.class.getSimpleName();

    public static OkHttpClient getOkHttpClient(boolean inHotspot) {
        OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();
        Network cellular_network = NetworkService.getCellularNetwork();
        Logger.t(TAG).e("cellular_network = %s inHotspot = %b", cellular_network, inHotspot);

        clientBuilder.addInterceptor(new Interceptor() {
            @Override
            public Response intercept(Chain chain) throws IOException {
                Request request = chain.request();
                Response response = chain.proceed(request);
//                Logger.t(TAG).e("response:" + response.body().string());
                return response;
            }
        });

        if (cellular_network != null && inHotspot) {
            Logger.t(TAG).e("cellular network != null");
            clientBuilder.socketFactory(cellular_network.getSocketFactory());
            clientBuilder.connectTimeout(15, TimeUnit.SECONDS);
            clientBuilder.dns(new Dns() {
                @Override
                public List<InetAddress> lookup(String hostname) throws UnknownHostException {
                    Logger.t(TAG).e("lookup : %s", hostname);
                    try {
                        return Arrays.asList(cellular_network.getAllByName(hostname));
                    } catch (UnknownHostException ex) {
                        Logger.t(TAG).e("UnknownHostException = %s", ex.getMessage());
                        NetworkService.requestByMobileData();
                        throw ex;
                    }
                }
            });
        }
        return clientBuilder.build();
    }
}
