package com.mk.autosecure.network_adapter.exo_adapter;

import java.net.HttpURLConnection;
import java.net.Proxy;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLStreamHandler;
import java.net.URLStreamHandlerFactory;
import okhttp3.OkHttpClient;
import okhttp3.internal.URLFilter;
import okhttp3.internal.huc.OkHttpURLConnection;
import okhttp3.internal.huc.OkHttpsURLConnection;

/**
 * Created by DoanVT on 2017/10/30.
 * Email: doanvt-hn@mk.com.vn
 */


public final class OkUrlConnectionFactory implements URLStreamHandlerFactory, Cloneable {
    private OkHttpClient client;
    private URLFilter urlFilter;


    public OkUrlConnectionFactory(OkHttpClient client) {
        this.client = client;
    }

    public OkHttpClient client() {
        return client;
    }

    public OkUrlConnectionFactory setClient(OkHttpClient client) {
        this.client = client;
        return this;
    }

    void setUrlFilter(URLFilter filter) {
        urlFilter = filter;
    }

    /**
     * Returns a copy of this stream handler factory that includes a shallow copy of the internal
     * {@linkplain OkHttpClient HTTP client}.
     */
    @Override public OkUrlConnectionFactory clone() {
        return new OkUrlConnectionFactory(client);
    }

    public HttpURLConnection open(URL url) {
        return open(url, client.proxy());
    }

    HttpURLConnection open(URL url, Proxy proxy) {
        String protocol = url.getProtocol();
        OkHttpClient copy = client.newBuilder()
                .proxy(proxy)
                .build();

        if (protocol.equals("http")) return new OkHttpURLConnection(url, copy, urlFilter);
        if (protocol.equals("https")) return new OkHttpsURLConnection(url, copy, urlFilter);
        throw new IllegalArgumentException("Unexpected protocol: " + protocol);
    }

    /**
     * Creates a URLStreamHandler as a {@link java.net.URL#setURLStreamHandlerFactory}.
     *
     * <p>This code configures OkHttp to handle all HTTP and HTTPS connections
     * created with {@link java.net.URL#openConnection()}: <pre>   {@code
     *
     *   OkHttpClient okHttpClient = new OkHttpClient();
     *   URL.setURLStreamHandlerFactory(new OkUrlFactory(okHttpClient));
     * }</pre>
     */
    @Override public URLStreamHandler createURLStreamHandler(final String protocol) {
        if (!protocol.equals("http") && !protocol.equals("https")) return null;

        return new URLStreamHandler() {
            @Override protected URLConnection openConnection(URL url) {
                return open(url);
            }

            @Override protected URLConnection openConnection(URL url, Proxy proxy) {
                return open(url, proxy);
            }

            @Override protected int getDefaultPort() {
                if (protocol.equals("http")) return 80;
                if (protocol.equals("https")) return 443;
                throw new AssertionError();
            }
        };
    }
}