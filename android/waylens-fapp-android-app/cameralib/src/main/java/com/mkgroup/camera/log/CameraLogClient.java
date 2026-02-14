package com.mkgroup.camera.log;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.WaylensCamera;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.FileUtils;

import org.apache.mina.core.RuntimeIoException;
import org.apache.mina.core.future.ConnectFuture;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.logging.LoggingFilter;
import org.apache.mina.handler.stream.StreamIoHandler;
import org.apache.mina.transport.socket.nio.NioSocketConnector;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;

import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/12/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class CameraLogClient {
    public static final String TAG = CameraLogClient.class.getSimpleName();

    private final CameraWrapper mCamera;

    private final int port;


    private int retries = 3;

    private final Object mWorkFence = new Object();

    private BehaviorSubject<CopyLogStatus> mStatus;

    private int result = COPY_STATUS_CLEAR;

    private static final long CONNECT_TIMEOUT = 15 * 1000L;

    public CameraLogClient(CameraWrapper camera, int port) {
        mCamera = camera;
        this.port = port;
    }

    public boolean run(BehaviorSubject<CopyLogStatus> status, int port) throws InterruptedException {
        mStatus = status;

        final NioSocketConnector connector = new NioSocketConnector();
        connector.setConnectTimeoutMillis(CONNECT_TIMEOUT);

        connector.getFilterChain().addLast("logger", new LoggingFilter());
        connector.setHandler(new StreamIoHandler() {
            @Override
            protected void processStreamIo(IoSession session, InputStream in, OutputStream out) {
                Worker worker = new Worker(session, in, out, port);
                worker.start();
            }
        });
        IoSession session = null;

        while (retries-- > 0) {
            try {
                Logger.t(TAG).v("start to connect to to " + mCamera.getAddress() + ":" + port);
                ConnectFuture future = connector.connect(new InetSocketAddress(mCamera.getAddress(), port));
                future.awaitUninterruptibly();
                session = future.getSession();
                Logger.t(TAG).v("start to transfer log");
                break;
            } catch (RuntimeIoException e) {
                Logger.t(TAG).v("Failed to connect. ");
                Thread.sleep(5000);
            }
        }
        synchronized (mWorkFence) {
            mWorkFence.wait();
        }
        return result == COPY_STATUS_FINISH;
    }

    public static final int COPY_STATUS_ERROR = -1;
    public static final int COPY_STATUS_DOWNLOADING = 0;
    public static final int COPY_STATUS_FINISH = 1;
    public static final int COPY_STATUS_CLEAR = 2;

    public static class CopyLogStatus {
        public int status;
        public Object info;

        public CopyLogStatus(int status) {
            this(status, null);
        }

        public CopyLogStatus(int status, Object obj) {
            this.status = status;
            this.info = obj;
        }

    }

    class Worker extends Thread {

        private final InputStream in;
        private final OutputStream out;
        private final IoSession session;

        private final int port;

        public Worker(IoSession session, InputStream in, OutputStream out, int port) {
            this.in = in;
            this.out = out;
            this.session = session;
            this.port = port;
        }

        @Override
        public void run() {
            //
            FileOutputStream fileOutputStream = null;
            try {
                Logger.t(TAG).d("process stream info");

                File cameraLogsFile = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), this.port == VdtCamera.COPY_LOG_PORT ? "cameraLogs.txt" : "cameraDebugLogs.txt");
                if (cameraLogsFile.exists()) {
                    cameraLogsFile.delete();
                }

                byte[] sizeBytes = new byte[4];
//                long responseLength = 0;
                int totalSize = 0;
                int sizeBytesLength = in.read(sizeBytes);

                Logger.t(TAG).d("size bytes length size = " + sizeBytesLength);

                if (sizeBytesLength == 4) {
                    totalSize = ((int) sizeBytes[0] & 0xFF) + (((int) sizeBytes[1] & 0xFF) << 8) + (((int) sizeBytes[2] & 0xFF) << 16) + (((int) sizeBytes[3] & 0xFF) << 24);
                }
//                if (sizeBytesLength == -1) {
//                    totalSize = ((int) sizeBytes[0] & 0xFF) + (((int) sizeBytes[1] & 0xFF) << 8) + (((int) sizeBytes[2] & 0xFF) << 16) + (((int) sizeBytes[3] & 0xFF) << 24);
//                }

                fileOutputStream = new FileOutputStream(cameraLogsFile, true);
                int len = 0;
                Logger.t(TAG).d("read data start");
                int remaining = totalSize;

                byte[] buffer = new byte[in.available() + 20 * 1024];
                while ((remaining > 0) && ((len = in.read(buffer, 0, Math.min(remaining, buffer.length))) != -1)) {
                    fileOutputStream.write(buffer, 0, len);
                    remaining -= len;
//                    responseLength += len;
                    buffer = new byte[in.available() + 20 * 1024];
                }

                Logger.t(TAG).d("size bytes length size = " + sizeBytesLength + "totalSize: " +totalSize);

                fileOutputStream.flush();
                if (mStatus != null) {
                    mStatus.onNext(new CopyLogStatus(COPY_STATUS_FINISH));
                }
                result = COPY_STATUS_FINISH;
            } catch (IOException e) {
                if (mStatus != null) {
                    mStatus.onNext(new CopyLogStatus(COPY_STATUS_ERROR));
                }
                result = COPY_STATUS_ERROR;
                Logger.t(TAG).d("exception = " + e.getMessage());
            } finally {
                try {
                    in.close();
                    if (fileOutputStream != null) {
                        fileOutputStream.close();
                    }
                } catch (IOException ex) {
//                    Logger.d("ex");
                    Logger.t(TAG).d("exception = " + ex.getMessage());
                }
                session.closeNow();
                synchronized (mWorkFence) {
                    mWorkFence.notifyAll();
                }
            }
        }
    }
}
