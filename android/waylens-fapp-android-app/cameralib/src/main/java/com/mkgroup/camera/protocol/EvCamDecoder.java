package com.mkgroup.camera.protocol;

import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.CumulativeProtocolDecoder;
import org.apache.mina.filter.codec.ProtocolDecoderOutput;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EvCamDecoder extends CumulativeProtocolDecoder implements EvCamProtocolConsts {

    private static final String TAG = EvCamDecoder.class.getSimpleName();

    @Override
    protected boolean doDecode(IoSession ioSession, IoBuffer ioBuffer, ProtocolDecoderOutput protocolDecoderOutput) throws Exception {
//        Logger.t(TAG).d("doDecode: " + ioBuffer.remaining());
        if (ioBuffer.remaining() >= 64) {

            byte[] sizeBytes = new byte[64];
            ioBuffer.mark();
            ioBuffer.get(sizeBytes);

            String tempHeader = new String(sizeBytes);
            if (tempHeader.startsWith(KEY_PROTOCOL)) {

                int text_length = parseKeyLength(tempHeader, KEY_TEXT_LENGTH, mTextPattern);
//                int binary_length = parseKeyLength(tempHeader, KEY_BINARY_LENGTH, mBinaryPattern);
                int header_length = parseHeaderLength(sizeBytes);

                ioBuffer.reset();

                if (ioBuffer.remaining() >= text_length + header_length) {
                    sizeBytes = new byte[header_length];
                    ioBuffer.get(sizeBytes);

                    sizeBytes = new byte[text_length];
                    ioBuffer.get(sizeBytes);

                    protocolDecoderOutput.write(sizeBytes);
                    return true;
                } else {
                    return false;
                }
            } else {
                ioBuffer.reset();
                return false;
            }
        }
        return false;
    }

    private int parseKeyLength(String tempHeader, String key, Pattern pattern) {
        if (tempHeader.contains(key)) {
            Matcher matcher = pattern.matcher(tempHeader);
            if (matcher.find() && matcher.groupCount() == 1) {
                return Integer.parseInt(matcher.group(1));
            }
        }
        return 0;
    }

    private int parseHeaderLength(byte[] sizeBytes) {
        int pos = 0;
        for (int i = 0; i < sizeBytes.length - 3; i++) {
            if (sizeBytes[i] == '\r' && sizeBytes[i + 1] == '\n'
                    && sizeBytes[i + 2] == '\r' && sizeBytes[i + 3] == '\n') {
                pos = i + 3;
                break;
            }
        }
        return pos + 1;
    }

    @Override
    public void dispose(IoSession session) throws Exception {
    }

    @Override
    public void finishDecode(IoSession session, ProtocolDecoderOutput out) throws Exception {
    }

    private final Pattern mTextPattern = Pattern.compile("TextLength: (\\d+)", Pattern.CASE_INSENSITIVE
            | Pattern.MULTILINE);

    private final Pattern mBinaryPattern = Pattern.compile("BinaryLength: (\\d+)", Pattern.CASE_INSENSITIVE
            | Pattern.MULTILINE);
}

