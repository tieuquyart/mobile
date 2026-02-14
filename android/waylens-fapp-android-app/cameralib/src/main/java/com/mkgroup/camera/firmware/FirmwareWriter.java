package com.mkgroup.camera.firmware;

import com.mkgroup.camera.CameraWrapper;
import com.orhanobut.logger.Logger;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;

import io.reactivex.ObservableEmitter;


/**
 * Created by doanvt on 2016/5/25.
 */
public class FirmwareWriter {

    private final static String TAG = FirmwareWriter.class.getSimpleName();

    private final CameraWrapper mCamera;
    private final File mFile;
    private final ObservableEmitter<? super Integer> mSubscribe;
    private static final int CONNECT_TIMEOUT = 1000 * 30;
    private static final int READ_WRITE_TIMEOUT = 1000 * 60 * 15;

    public FirmwareWriter(File file, CameraWrapper camera, ObservableEmitter<? super Integer> subscriber) {
        this.mCamera = camera;
        this.mFile = file;
        this.mSubscribe = subscriber;
    }

    public void start() {
        Logger.t(TAG).i("start: " + mCamera);
        Socket socket = new Socket();
        SocketAddress socketAddress = new InetSocketAddress(mCamera.getHostString(), 10097);

        try {
            socket.setSoTimeout(READ_WRITE_TIMEOUT);
            socket.connect(socketAddress, CONNECT_TIMEOUT);
            boolean connected = socket.isConnected();
            Logger.t(TAG).d("connected: " + connected);

            FileInputStream inputStream = new FileInputStream(mFile);

            byte[] buffer = new byte[64 * 1024]; // 相机侧也为64KB，不宜过大，容易导致读写异常

            int len = 0;
            int dataSend = 0;
            while ((len = inputStream.read(buffer)) > 0) {
                socket.getOutputStream().write(buffer, 0, len);
                dataSend += len;
                mSubscribe.onNext(dataSend);
//                Logger.t(TAG).e("dataSend : %d", dataSend);
            }

            socket.close();

            Logger.t(TAG).d("start success");
        } catch (IOException e) {
            Logger.t(TAG).e("start error: " + e.getMessage());
            e.printStackTrace();
            mSubscribe.onError(e);
        }
    }

}
