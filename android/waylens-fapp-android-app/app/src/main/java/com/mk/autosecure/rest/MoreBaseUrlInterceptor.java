package com.mk.autosecure.rest;

import android.os.Build;

import com.mkgroup.camera.preference.PreferenceUtils;

import java.io.IOException;
import java.util.List;

import okhttp3.HttpUrl;
import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

/**
 * Created by doanvt on 2018/7/25.
 * Email：doanvt-hn@mk.com.vn
 */

public class MoreBaseUrlInterceptor implements Interceptor {

    private final static String TAG = MoreBaseUrlInterceptor.class.getSimpleName();

    private static String USER_AGENT = "Android " + Build.VERSION.SDK + ";" + Build.BRAND + Build.MODEL;

    @Override
    public Response intercept(Chain chain) throws IOException {

        //获取原始的originalRequest
        Request originalRequest = chain.request();
        //获取老的url
        HttpUrl oldUrl = originalRequest.url();
        //获取originalRequest的创建者builder
        Request.Builder builder = originalRequest.newBuilder();
        //获取头信息的集合
        List<String> baseUrlList = originalRequest.headers("baseUrl");

        if (baseUrlList != null && baseUrlList.size() > 0) {
            //删除原有配置中的值
            builder.removeHeader("baseUrl");
            //获取头信息中配置的value
            String url = baseUrlList.get(0);
            HttpUrl baseUrl = null;
//            if ("secure360".equals(url)) {
//                String[] serverList = HornApplication.getContext().getResources().getStringArray(R.array.server_list);
//                String string = PreferenceUtils.getString(PreferenceUtils.SERVER_URL, serverList[serverList.length - 1]);
//                baseUrl = HttpUrl.parse(string);
//            } else
            if ("waylens".equals(url)) {
                baseUrl = HttpUrl.parse(ApiService.WAYLENS_BASE_URL);
            } else {
                return chain.proceed(originalRequest);
            }

            //重建新的HttpUrl，需要重新设置的url部分
            HttpUrl newHttpUrl = oldUrl.newBuilder()
                    .scheme(baseUrl.scheme())//http协议如：http或者https
                    .host(baseUrl.host())//主机地址
                    .port(baseUrl.port())//端口
                    .build();

            //获取处理后的新newRequest
            Request newRequest = builder.url(newHttpUrl)
                    .addHeader("X-Auth-Token", PreferenceUtils.getString(PreferenceUtils.WAYLENS_TOKEN, ""))
                    .addHeader("User-Agent", USER_AGENT)
                    .build();

            return chain.proceed(newRequest);
        }
        return chain.proceed(originalRequest);
    }

}
