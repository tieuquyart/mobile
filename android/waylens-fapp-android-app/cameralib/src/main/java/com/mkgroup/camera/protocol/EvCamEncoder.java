package com.mkgroup.camera.protocol;

import android.text.TextUtils;

import com.mkgroup.camera.command.EvCamCommand;
import com.mkgroup.camera.command.EvCameraCmdConsts;
import com.orhanobut.logger.Logger;

import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.ProtocolEncoder;
import org.apache.mina.filter.codec.ProtocolEncoderOutput;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.Locale;

public class EvCamEncoder implements ProtocolEncoder, EvCamProtocolConsts {

    private static final String TAG = EvCamEncoder.class.getSimpleName();

    @Override
    public void dispose(IoSession session) throws Exception {

    }

    @Override
    public void encode(IoSession session, Object message, ProtocolEncoderOutput out) throws Exception {
        if (message instanceof EvCamCommand) {
            EvCamCommand command = (EvCamCommand) message;

            JSONObject object = new JSONObject();
            object.put("category", command.category);
            object.put("cmd", command.cmd);
            if (!TextUtils.isEmpty(command.param)) {
                object.put("param", new JSONObject(command.param));
            }

            String json = object.toString();
            Logger.t(TAG).d("json: " + json);
            int length = json.length();

            IoBuffer buff = IoBuffer.allocate(length).setAutoExpand(true).setAutoShrink(true);

            CharsetEncoder encoder = Charset.defaultCharset().newEncoder();

            buff.putString(HEADER_PROTOCOL, encoder);
            buff.putString(String.format(Locale.US, HEADER_TEXT_LENGTH, length), encoder);

            if (EvCameraCmdConsts.DEV.CMD_DEV_transferFirmware.equals(command.cmd)) {
                JSONObject temp = new JSONObject(command.param);
                int size = temp.getInt("size");
//                Logger.t(TAG).d("CMD_DEV_transferFirmware size: " + size);
                buff.putString(String.format(Locale.US, HEADER_BINARY_LENGTH, size), encoder);
            }

            buff.putString(LINE_BREAK, encoder);
            buff.putString(json, encoder);

            buff.flip();
            out.write(buff);
            out.flush();
        } else if (message instanceof File) {
            File file = (File) message;
            Logger.t(TAG).d("file: " + file.getAbsolutePath());

            IoBuffer buffer = IoBuffer.allocate((int) file.length()).setAutoExpand(true).setAutoShrink(true);

            FileInputStream inputStream = new FileInputStream(file);
            byte[] sizeBytes = new byte[1024 * 1024];
            int len = 0;

            while ((len = inputStream.read(sizeBytes)) > 0) {
                buffer.put(sizeBytes, 0, len);
            }

            buffer.flip();
            out.write(buffer);
            out.flush();
        }
    }
}
