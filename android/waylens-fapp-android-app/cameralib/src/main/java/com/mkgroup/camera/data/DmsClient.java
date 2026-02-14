package com.mkgroup.camera.data;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.dms.DmsCommand;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.net.Socket;

public class DmsClient {

    private final static String TAG = DmsClient.class.getSimpleName();
    private final static int DMS_CMD_PORT = 1368;
    private final static int CONNECT_TIMEOUT = 30 * 1000;

    private Socket mSocket;
    private InetSocketAddress mSocketAddress;

    public DmsClient(String address) {
        mSocket = new Socket();
        mSocketAddress = new InetSocketAddress(address, DMS_CMD_PORT);
    }

    public void connect() throws IOException {
        mSocket.setReceiveBufferSize(8192);
        mSocket.connect(mSocketAddress, CONNECT_TIMEOUT);
        boolean connected = mSocket.isConnected();
        Logger.t(TAG).d("connected: " + connected);
    }

    public boolean isConnected() {
        return mSocket != null && mSocket.isConnected();
    }

    public void disconnect() throws IOException {
        mSocket.close();
        boolean closed = mSocket.isClosed();
        Logger.t(TAG).d("closed: " + closed);
    }

    public void sendCommand(DmsCommand command) throws IOException {
        sendByteArray(command.getCmdBuffer());
    }

    public byte[] receivedAck() throws IOException {
        byte[] bytes = new byte[160];
        readFully(bytes, 0, bytes.length);
        return bytes;
    }

    public void readFully(byte[] buffer, int pos, int size) throws IOException {
        InputStream input = mSocket.getInputStream();

        while (size > 0) {
            int ret = input.read(buffer, pos, size);
            if (ret < 0) {
                throw new IOException();
            }
            pos += ret;
            size -= ret;
        }
    }

    private void sendByteArray(byte[] data) throws IOException {
        mSocket.getOutputStream().write(data);
    }
}
