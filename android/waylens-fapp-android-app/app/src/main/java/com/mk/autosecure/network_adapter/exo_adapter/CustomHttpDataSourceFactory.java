package com.mk.autosecure.network_adapter.exo_adapter;

import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.HttpDataSource;
import com.google.android.exoplayer2.upstream.TransferListener;

/**
 * Created by DoanVT on 2017/10/30.
 * Email: doanvt-hn@mk.com.vn
 */

public final class CustomHttpDataSourceFactory extends HttpDataSource.BaseFactory {

    private final String userAgent;
    private final TransferListener listener;
    private final int connectTimeoutMillis;
    private final int readTimeoutMillis;
    private final boolean allowCrossProtocolRedirects;

    /**
     * Constructs a DefaultHttpDataSourceFactory. Sets {@link
     * CustomHttpDataSourceFactory #DEFAULT_CONNECT_TIMEOUT_MILLIS} as the connection timeout, {@link
     * CustomHttpDataSourceFactory #DEFAULT_READ_TIMEOUT_MILLIS} as the read timeout and disables
     * cross-protocol redirects.
     *
     * @param userAgent The User-Agent string that should be used.
     */
    public CustomHttpDataSourceFactory(String userAgent) {
        this(userAgent, null);
    }

    /**
     * Constructs a CustomHttpDataSourceFactory. Sets {@link
     * CustomHttpDataSource #DEFAULT_CONNECT_TIMEOUT_MILLIS} as the connection timeout, {@link
     * CustomHttpDataSource #DEFAULT_READ_TIMEOUT_MILLIS} as the read timeout and disables
     * cross-protocol redirects.
     *
     * @param userAgent The User-Agent string that should be used.
     * @param listener An optional listener.
     * @see #CustomHttpDataSourceFactory (String, TransferListener, int, int, boolean)
     */
    public CustomHttpDataSourceFactory(
            String userAgent, TransferListener listener) {
        this(userAgent, listener, DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS,
                DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS, false);
    }

    /**
     * @param userAgent The User-Agent string that should be used.
     * @param listener An optional listener.
     * @param connectTimeoutMillis The connection timeout that should be used when requesting remote
     *     data, in milliseconds. A timeout of zero is interpreted as an infinite timeout.
     * @param readTimeoutMillis The read timeout that should be used when requesting remote data, in
     *     milliseconds. A timeout of zero is interpreted as an infinite timeout.
     * @param allowCrossProtocolRedirects Whether cross-protocol redirects (i.e. redirects from HTTP
     *     to HTTPS and vice versa) are enabled.
     */
    public CustomHttpDataSourceFactory(String userAgent,
                                       TransferListener listener, int connectTimeoutMillis,
                                       int readTimeoutMillis, boolean allowCrossProtocolRedirects) {
        this.userAgent = userAgent;
        this.listener = listener;
        this.connectTimeoutMillis = connectTimeoutMillis;
        this.readTimeoutMillis = readTimeoutMillis;
        this.allowCrossProtocolRedirects = allowCrossProtocolRedirects;
    }

    @Override
    protected CustomHttpDataSource createDataSourceInternal(
            HttpDataSource.RequestProperties defaultRequestProperties) {
        return new CustomHttpDataSource(userAgent, null, listener, connectTimeoutMillis,
                readTimeoutMillis, allowCrossProtocolRedirects, defaultRequestProperties);
    }

}
