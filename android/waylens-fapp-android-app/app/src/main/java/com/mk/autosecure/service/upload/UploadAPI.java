package com.mk.autosecure.service.upload;

import android.net.Network;

import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.service.job.UploadDataResponse;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import io.reactivex.Observable;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class UploadAPI {
    private static final String TAG = UploadAPI.class.getSimpleName();
    private static final int DEFAULT_TIMEOUT = 15;
    private Retrofit mRetrofit;

    public UploadAPI(String baseUrl, final String date, final String authorization) {
        this(baseUrl, date, authorization, DEFAULT_TIMEOUT);
    }

    public UploadAPI(String baseUrl, final String date, final String authorization, int timeOut) {
        TrustManager[] trustManager = new TrustManager[]{
                new X509TrustManager() {
                    @Override
                    public void checkClientTrusted(X509Certificate[] chain, String authType) {

                    }

                    @Override
                    public void checkServerTrusted(X509Certificate[] chain, String authType) {
                    }

                    @Override
                    public X509Certificate[] getAcceptedIssuers() {
                        return new X509Certificate[0];
                    }
                }
        };
        try {
            SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustManager, new SecureRandom());
            SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder()
                    .retryOnConnectionFailure(true)
                    .addInterceptor(chain -> {
                        Request request = chain.request();
                        Request newReq = request.newBuilder()
                                .addHeader("Date", date)
                                .addHeader("Authorization", authorization)
                                .build();

                        return chain.proceed(newReq);
                    })
                    .sslSocketFactory(sslSocketFactory)
                    .hostnameVerifier((hostname, sslSession) -> true);

            if (timeOut > 0) {
                clientBuilder.connectTimeout(timeOut, TimeUnit.SECONDS);
            }
            clientBuilder.readTimeout(0, TimeUnit.SECONDS);
            clientBuilder.writeTimeout(0, TimeUnit.SECONDS);
            clientBuilder.connectTimeout(0, TimeUnit.SECONDS);

            Network cellularNetwork = ApiService.getCellularNetwork();
            if (cellularNetwork != null && NetworkUtils.isNetworkLimited()) {
                Logger.t(TAG).d("cellular network != null");
                clientBuilder.socketFactory(cellularNetwork.getSocketFactory());
                clientBuilder.dns(hostname -> Arrays.asList(cellularNetwork.getAllByName(hostname)));
            }

//            HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
//            logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
//            clientBuilder.addInterceptor(logInterceptor);

            OkHttpClient client = clientBuilder.build();

            mRetrofit = new Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create())
                    .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                    .build();

            Logger.t(TAG).e("uploadBaseUrl: " + baseUrl);


        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (KeyManagementException e) {
            e.printStackTrace();
        }
    }

    public Response<UploadDataResponse> uploadAvatarSync(RequestBody requestBody, String userId, String sha1) {
        try {
            Call<UploadDataResponse> uploadAvatarCall = mRetrofit.create(IUploadService.class)
                    .uploadAvatar(userId, sha1, requestBody);
            return uploadAvatarCall.execute();
        } catch (IOException e) {
            Logger.t(TAG).d("error " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public UploadDataResponse uploadAvatarSyncOld(RequestBody requestBody, String userId, String sha1) {
        try {
            Call<UploadDataResponse> uploadAvatarCall = mRetrofit.create(IUploadService.class)
                    .uploadAvatar(userId, sha1, requestBody);
            return uploadAvatarCall.execute().body();
        } catch (IOException e) {
            Logger.t(TAG).d("error " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public Observable<UploadDataResponse> uploadMp4Sync(RequestBody requestBody, String userID, long momentId, String sha1, long resolution, long duration) {
        return mRetrofit.create(IUploadService.class)
                .uploadMp4(userID, momentId, sha1, "private", resolution, duration, requestBody);
    }
}
