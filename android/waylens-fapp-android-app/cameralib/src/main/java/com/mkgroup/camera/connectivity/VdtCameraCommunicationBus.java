package com.mkgroup.camera.connectivity;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkRequest;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.text.TextUtils;
import android.text.format.Formatter;
import android.util.Log;

import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.command.EvCamCommand;
import com.mkgroup.camera.command.EvCameraCmdConsts;
import com.mkgroup.camera.command.VdtCameraCmdConsts;
import com.mkgroup.camera.command.VdtCommand;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.message.VdtMessage;
import com.mkgroup.camera.rest.ServerErrorHandler;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.protocol.VdtCodecFactory;

import org.apache.mina.core.future.ConnectFuture;
import org.apache.mina.core.future.WriteFuture;
import org.apache.mina.core.service.IoConnector;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.service.IoService;
import org.apache.mina.core.service.IoServiceListener;
import org.apache.mina.core.session.IdleStatus;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.keepalive.KeepAliveFilter;
import org.apache.mina.filter.keepalive.KeepAliveMessageFactory;
import org.apache.mina.filter.keepalive.KeepAliveRequestTimeoutHandler;
import org.apache.mina.filter.logging.LoggingFilter;
import org.apache.mina.transport.socket.nio.NioSocketConnector;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.net.InetSocketAddress;
import java.util.Optional;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;

import static android.net.NetworkCapabilities.TRANSPORT_WIFI;

/**
 * Created by doanvt on 2016/6/1.
 */
public class VdtCameraCommunicationBus implements VdtCameraCmdConsts, EvCameraCmdConsts {

    private static final String TAG = VdtCameraCommunicationBus.class.getSimpleName();

    //创建socket连接对象
    private IoConnector mConnector = null;
    private IoSession mSession = null;
    //创建服务器地址对象
    private final InetSocketAddress mAddress;
    private final boolean isVdtCamera;

    private final ConnectionChangeListener mConnectionListener;
    private final CameraMessageHandler mCameraMessageHandler;

    private final Context mContext;

    private volatile int mIpAddress;
    private volatile int mConnectRetryCount = 0;

    private ConnectivityManager manager;
    private WifiManager wifiManager;
    private ConnectivityManager.NetworkCallback callback;

    private PublishSubject<Optional> connectSubject = PublishSubject.create();

    public VdtCameraCommunicationBus(InetSocketAddress address, ConnectionChangeListener connectionListener, CameraMessageHandler messageHandler) {
        this.mAddress = address;
        this.mConnectionListener = connectionListener;
        this.mCameraMessageHandler = messageHandler;
        this.mContext = WaylensCamera.getInstance().getApplicationContext();
        this.isVdtCamera = address.getPort() == VDT_CAM_PORT;
    }

    public void start() {
        Observable.create((ObservableOnSubscribe<Void>) emitter -> initMinaConnection())
                .subscribeOn(Schedulers.io())
                .subscribe();

        connectSubject
                .observeOn(Schedulers.io())
                .subscribe(optional -> connectionError(), new ServerErrorHandler(TAG));

        manager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        wifiManager = (WifiManager) mContext.getApplicationContext()
                .getSystemService(Context.WIFI_SERVICE);

        try {
            if (manager != null && wifiManager != null) {
                callback = new ConnectionCallback();
                manager.registerNetworkCallback(new NetworkRequest.Builder()
                        .addTransportType(TRANSPORT_WIFI).build(), callback);
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("registerNetworkCallback error: " + ex.getMessage());
        }
    }

    private void initMinaConnection() {
        Logger.t(TAG).d("initMinaConnection: " + VdtCameraCommunicationBus.this + " " + mAddress);

        mConnector = new NioSocketConnector();

        //设置链接超时时间
        mConnector.setConnectTimeoutMillis(2000);
        //添加过滤器
        mConnector.getFilterChain().addLast("logger", new LoggingFilter());
        mConnector.getFilterChain().addLast("codec", new ProtocolCodecFilter(new VdtCodecFactory(isVdtCamera)));

        mConnector.setHandler(new MinaClientHandler());
        //设置默认连接地址
        mConnector.setDefaultRemoteAddress(mAddress);
        //监听客户端是否断线
        mConnector.addListener(new MinaIoServiceListener());

        KeepAliveMessageFactory factory = new KeepAliveMessageFactory() {
            @Override
            public boolean isRequest(IoSession ioSession, Object o) {
//                Logger.t(TAG).d("isRequest: " + o.toString());
                return false;
            }

            @Override
            public boolean isResponse(IoSession ioSession, Object o) {
                // 不再拦截心跳，继续调用messageReceived()
//                VdtMessage message = (VdtMessage) o;
//                Logger.t(TAG).d("heart beat isResponse: " + message.messageType);
//                Logger.t(TAG).d("receive heart beart response");
                return false;
//                return message.domain == CMD_DOMAIN_CAM &&
//                        (message.messageType == CMD_NETWORK_GET_WLAN_MODE || message.messageType == CMD_CAM_IS_API_SUPPORTED);
            }

            @Override
            public Object getRequest(IoSession ioSession) {
                boolean foreground = WaylensCamera.isForeground();
                Logger.t(TAG).d("isForeground: " + foreground);
                if (isVdtCamera) {
                    return foreground ?
                            new VdtCommand(DOMAIN.CMD_DOMAIN_CAM, VdtCameraCmdConsts.CAM.CMD_NETWORK_GET_WLAN_MODE, "", "")
                            : new VdtCommand(DOMAIN.CMD_DOMAIN_CAM, VdtCameraCmdConsts.CAM.CMD_CAM_IS_API_SUPPORTED, "", "");
                } else {
                    return foreground ?
                            new EvCamCommand(CAT.CMD_CAT_DEVICE, DEV.CMD_DEV_keepAliveForApp, "")
                            : null;
                }
            }

            @Override
            public Object getResponse(IoSession ioSession, Object o) {
                return null;
            }
        };
        KeepAliveFilter kaf = new KeepAliveFilter(factory, IdleStatus.READER_IDLE, KeepAliveRequestTimeoutHandler.LOG);
        kaf.setForwardEvent(true);
        kaf.setRequestInterval(9);
        kaf.setRequestTimeout(10);

        //设置心跳包
        mConnector.getFilterChain().addLast("heart", kaf);

        startMinaConnection();
    }

    private void startMinaConnection() {
        try {
            ConnectFuture future = mConnector.connect();
            Logger.t(TAG).d("startMinaConnection: " + VdtCameraCommunicationBus.this);
            future.awaitUninterruptibly(2000);
            mSession = future.getSession();
            Logger.t(TAG).d("mSession: " + mSession);
            if (mSession != null && mSession.isConnected()) {
                mConnectionListener.onConnected();
                mConnectRetryCount = 0;
            } else {
                Logger.t(TAG).e("connect failed");
                releaseConnection();
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("connect failed: " + ex.getMessage());
            releaseConnection();
        }
    }

    public void sendCAMCommand(int cmd, String p1, String p2) {
        VdtCommand command = new VdtCommand(DOMAIN.CMD_DOMAIN_CAM, cmd, p1, p2);
        sendCommand(command);
    }

    public void sendRECCommand(int cmd, String p1, String p2) {
        VdtCommand command = new VdtCommand(DOMAIN.CMD_DOMAIN_REC, cmd, p1, p2);
        sendCommand(command);
    }

    private void sendCommand(VdtCommand command) {
        if (mSession != null) {
            mSession.write(command);
        }
    }

    public String sendEvCamCommand(String category, String cmd, String param) {
        EvCamCommand command = new EvCamCommand(category, cmd, param);
        Log.d("sendEvCamCommand","sendEvCamCommand: " + command.toString());
        if (mSession != null) {

            Log.d("mSession","mSession: " + command.toString());

            WriteFuture data =   mSession.write(command);

        }
        return category;
    }

    public void sendEvCamFile(File file) {
//        Logger.t(TAG).d("sendEvCamFile: " + file);
        if (mSession != null) {
            mSession.write(file);
        }
    }

    private synchronized void connectionError() {
        Logger.t(TAG).d("mConnectRetryCount: " + mConnectRetryCount);
        try {
            Thread.sleep(2000);

            if (mConnectRetryCount++ < 3) {
                startMinaConnection();
            } else {
                releaseConnection();
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("reconnect failed: " + ex.getMessage());
        }
    }

    public void releaseConnection() {
        try {
            if (mConnector != null) {
                mConnector.dispose();
            }
            if (mSession != null) {
                mSession.closeOnFlush();
            }
            if (connectSubject != null) {
                connectSubject.onComplete();
            }
            if (manager != null) {
                manager.unregisterNetworkCallback(callback);
            }

            Logger.t(TAG).d("socket is closed: " + mAddress);
            mConnectionListener.onDisconnected();
        } catch (Exception e) {
            Logger.t(TAG).e("releaseConnection error: " + e.getMessage());
            mConnectionListener.onDisconnected();
        }
    }

    public class ConnectionCallback extends ConnectivityManager.NetworkCallback {
        @Override
        public void onAvailable(Network network) {
            Logger.t(TAG).e("onAvailable: " + network.toString());
            super.onAvailable(network);

            int ipAddress = 0;
            String ssid = null;

            if (wifiManager != null) {
                //android q getConnectionInfo() need permission ACCESS_FINE_LOCATION
                WifiInfo wifiInfo = wifiManager.getConnectionInfo();
                if (wifiInfo != null) {
                    ipAddress = wifiInfo.getIpAddress();
                    ssid = wifiInfo.getSSID();
                }
            }

            if (!TextUtils.isEmpty(ssid)
                    && (ssid.startsWith("\"DIRECT-Waylens-") || ssid.startsWith("\"Waylens-"))) {
                WifiDirectConnection.getInstance().switchFeature(false);
            }

            Logger.t(TAG).e("onAvailable ssid: " + ssid
                    + " ipAddress: " + Formatter.formatIpAddress(ipAddress)
                    + " mIpAddress: " + Formatter.formatIpAddress(mIpAddress));

            if (mIpAddress == 0) {
                mIpAddress = ipAddress;
            } else if (mIpAddress != ipAddress || mConnectRetryCount >= 3) {
                releaseConnection();
            }
        }

        @Override
        public void onLost(Network network) {
            Logger.t(TAG).e("onLost: " + network.toString());
            super.onLost(network);
            WifiDirectConnection.getInstance().switchFeature(true);
        }
    }

    public class MinaClientHandler extends IoHandlerAdapter {

        @Override
        public void messageReceived(IoSession session, Object message) throws Exception {
            super.messageReceived(session, message);
            if (message instanceof VdtMessage) {
                VdtMessage vdtMessage = (VdtMessage) message;
                Logger.t(TAG).d("message received: " + vdtMessage.toString());
                mCameraMessageHandler.handleMessage(vdtMessage.domain, vdtMessage.messageType, vdtMessage.parameter1, vdtMessage.parameter2);
            } else {
                String json = new String((byte[]) message);
                Logger.t(TAG).d("messageReceived: " + json);
                parseJson(json);
            }
        }

        private void parseJson(String json) {
            try {
                JSONObject object = new JSONObject(json);
                String category = object.getString("category");

                if ("debug".equals(category)) {
                    String info = object.getString("info");
                    mCameraMessageHandler.handleEvCamMessage(category, info, "");
                } else {
                    String msg = object.getString("msg");
                    Object body = object.get("body");
                    mCameraMessageHandler.handleEvCamMessage(category, msg, body.toString());
                }
            } catch (JSONException e) {
                Logger.t(TAG).e("parseMessage exception: " + e.getMessage());
            }
        }
    }

    public class MinaIoServiceListener implements IoServiceListener {

        @Override
        public void serviceActivated(IoService service) throws Exception {
            Logger.t(TAG).d("serviceActivated: " + mAddress);
        }

        @Override
        public void serviceIdle(IoService service, IdleStatus idleStatus) throws Exception {
            Logger.t(TAG).d("serviceIdle");
        }

        @Override
        public void serviceDeactivated(IoService service) throws Exception {
            Logger.t(TAG).d("serviceDeactivated: " + mAddress);
        }

        @Override
        public void sessionCreated(IoSession session) throws Exception {
            Logger.t(TAG).d("sessionCreated: " + mAddress);
        }

        @Override
        public void sessionClosed(IoSession session) throws Exception {
            Logger.t(TAG).d("sessionClosed");
        }

        @Override
        public void sessionDestroyed(IoSession session) throws Exception {
            Logger.t(TAG).d("sessionDestroyed: " + mAddress);
            connectSubject.onNext(Optional.empty());
        }
    }

    public interface ConnectionChangeListener {
        void onConnected();

        void onConnectionFailed();

        void onDisconnected();
    }

    public interface CameraMessageHandler {
        void handleMessage(int domain, int code, String p1, String p2);

        void handleEvCamMessage(String category, String msg, String body);
    }
}
