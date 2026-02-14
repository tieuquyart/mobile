package com.mk.autosecure.rest_fleet;

import android.annotation.TargetApi;
import android.os.Build;
import android.text.TextUtils;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.CookieUtil;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.MoreBaseUrlInterceptor;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.R;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

public class ApiClient {

    private static final String TAG = ApiClient.class.getSimpleName();

    private static volatile FleetApiClient mApiServiceInstance = null;

    private static volatile FleetApiClient mApiServiceInstance_cellular = null;

    private static final int TIME_OUT_MILLI_SEC = 30000;

    private static AppComponent mComponent = HornApplication.getComponent();

    private final static String USER_AGENT = String.format(Locale.ENGLISH, StringUtils.USER_AGENT_FORMAT, "FleetApp",
            BuildConfig.VERSION_NAME, BuildConfig.VERSION_CODE,
            Build.MANUFACTURER + " " + Build.MODEL, "Android " + Build.VERSION.RELEASE);

    private ApiClient() {

    }

    public static FleetApiClient createApiService() {
        Logger.t(TAG).d("createApiService isNetworkLimited: " + NetworkUtils.isNetworkLimited());
        if (NetworkUtils.isNetworkLimited()) {
            return createHornApiServiceCellular();
        } else {
            return createHornApiService();
        }
    }

    private static FleetApiClient createHornApiService() {
        if (mApiServiceInstance == null) {
            synchronized (ApiClient.class) {
                if (mApiServiceInstance == null) {
                    String[] serverList = HornApplication.getContext().getResources().getStringArray(R.array.host_server_list_fleet);
                    String BASE_URL = PreferenceUtils.getString(PreferenceUtils.FLEET_SERVER_URL, serverList[serverList.length - 1]);
                    Retrofit.Builder builder = new Retrofit.Builder()
                            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                            .addConverterFactory(GsonConverterFactory.create())
                            .baseUrl(BASE_URL);

                    Logger.t(TAG).e("base url = %s", BASE_URL);
                    OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();

                    HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
                    logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

                    clientBuilder.addInterceptor(logInterceptor);

                    //拦截消息通知的url，修改baseUrl
                    clientBuilder.addInterceptor(new MoreBaseUrlInterceptor());

                    clientBuilder.addInterceptor(headerInterceptor)
                            .readTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .writeTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .connectTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS);

                    builder.client(clientBuilder.build());
                    mApiServiceInstance = builder.build().create(FleetApiClient.class);
                }
            }
        }
        return mApiServiceInstance;
    }

    @TargetApi(21)
    private static FleetApiClient createHornApiServiceCellular() {
        if (mApiServiceInstance_cellular == null) {
            synchronized (ApiClient.class) {
                if (mApiServiceInstance_cellular == null) {
                    String[] serverList = HornApplication.getContext().getResources().getStringArray(R.array.host_server_list_fleet);
                    String BASE_URL = PreferenceUtils.getString(PreferenceUtils.FLEET_SERVER_URL, serverList[serverList.length - 1]);
                    Retrofit.Builder builder = new Retrofit.Builder()
                            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                            .addConverterFactory(GsonConverterFactory.create())
                            .baseUrl(BASE_URL);

                    Logger.t(TAG).e("base url = %s", BASE_URL);
                    OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();

                    HttpLoggingInterceptor logInterceptor = new HttpLoggingInterceptor();
                    logInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

                    clientBuilder.addInterceptor(logInterceptor);

                    //拦截消息通知的url，修改baseUrl
                    clientBuilder.addInterceptor(new MoreBaseUrlInterceptor());

                    clientBuilder.addInterceptor(headerInterceptor)
                            .readTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .writeTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS)
                            .connectTimeout(TIME_OUT_MILLI_SEC, TimeUnit.MILLISECONDS);

                    if (ApiService.getCellularNetwork() != null) {
                        Logger.t(TAG).e("cellular network != null");
                        clientBuilder.socketFactory(ApiService.getCellularNetwork().getSocketFactory());
                        clientBuilder.dns(hostname -> {
//                            Logger.t(TAG).e("lookup : %s", hostname);
                            return Arrays.asList(ApiService.getCellularNetwork().getAllByName(hostname));
                        });
                    } else {
                        Logger.t(TAG).e("cellular network == null");
                        return createHornApiService();
                    }

                    builder.client(clientBuilder.build());
                    mApiServiceInstance_cellular = builder.build().create(FleetApiClient.class);
                }
            }
        }
        return mApiServiceInstance_cellular;
    }

    private static final Interceptor headerInterceptor = chain -> {
        Request request = chain.request();

        Request.Builder newReqBuilder = request.newBuilder()
                .addHeader("User-Agent", USER_AGENT)
                .addHeader("Content-Type", "application/json; charset=utf-8");
        try {
            String token = mComponent.currentUser().getAccessToken();
//            Logger.t(TAG).d("token = " + token);
            if (!TextUtils.isEmpty(token)) {
                newReqBuilder.addHeader("Authorization", "Bearer " + token);
            }
        } catch (Exception e) {
            Logger.t(TAG).e("get exception = " + e.getMessage());
        }
        Response response = chain.proceed(newReqBuilder.build());
        List<String> values = response.headers().values("Set-Cookie");
        if (values.size() != 0) {
            CookieUtil.setCookie(values);
        }
        return response;
    };
}
