package com.mkgroup.camera.protocol;

import android.util.Xml;

import com.mkgroup.camera.message.VdtMessage;

import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.CumulativeProtocolDecoder;
import org.apache.mina.filter.codec.ProtocolDecoderOutput;
import org.xmlpull.v1.XmlPullParser;

import java.io.ByteArrayInputStream;
import java.nio.ByteOrder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by DoanVT on 2017/7/27.
 * Email: doanvt-hn@mk.com.vn
 */
public class VdtDecoder extends CumulativeProtocolDecoder implements VdtProtocolConsts {
    private static final String TAG = VdtDecoder.class.getSimpleName();

    private final static String charset = "UTF-8";

    @Override
    protected boolean doDecode(IoSession ioSession, IoBuffer ioBuffer, ProtocolDecoderOutput protocolDecoderOutput) throws Exception {
        ioBuffer.order(ByteOrder.LITTLE_ENDIAN);
        int length = 0;
        if (ioBuffer.remaining() >= 4) {
            ioBuffer.mark();
            length = ioBuffer.getInt();
            //Logger.t(TAG).d("current length: " + length);
            if (ioBuffer.remaining() >= length - 4) {
                int append = ioBuffer.getInt();

                //Logger.t(TAG).d("enough length: " + length);
                byte[] byteArray = new byte[length];
                ioBuffer.get(byteArray, 0, length - 8);

                XmlPullParser xpp = Xml.newPullParser();
//                Logger.t(TAG).v("receive message: " + new String(byteArray, Charset.forName("UTF-8")));
                xpp.setInput(new ByteArrayInputStream(byteArray), charset);

                int eventType = xpp.getEventType();

                while (true) {
                    switch (eventType) {

                        case XmlPullParser.START_TAG:
                            if (xpp.getName().equals(XML_CMD)) {
                                VdtMessage message = parseCmdTag(xpp);
//                              Logger.t(TAG).d("receive message: " + message.toString());
                                protocolDecoderOutput.write(message);
                            }
                            break;
                        default:
                            break;
                    }
                    if (eventType == XmlPullParser.END_DOCUMENT) {
                        break;
                    }
                    eventType = xpp.next();
                }
                return true;
            } else {
                ioBuffer.reset();
                return false;
            }
        } else {
            return false;
        }

    }

    @Override
    public void dispose(IoSession session) throws Exception {

    }

    @Override
    public void finishDecode(IoSession session, ProtocolDecoderOutput out) throws Exception {
    }


    private VdtMessage parseCmdTag(XmlPullParser xpp) {
        int count = xpp.getAttributeCount();
        if (count >= 1) {
            String act = "";
            String p1 = "";
            String p2 = "";
            if (xpp.getAttributeName(0).equals(XML_ACT)) {
                act = xpp.getAttributeValue(0);
            }
            if (count >= 2) {
                if (xpp.getAttributeName(1).equals(XML_P1)) {
                    p1 = xpp.getAttributeValue(1);
                }
                if (count >= 3) {
                    if (xpp.getAttributeName(2).equals(XML_P2)) {
                        p2 = xpp.getAttributeValue(2);
                    }
                }
            }

            // ECMD0.5
            Matcher matcher = mPattern.matcher(act);
            if (matcher.find() && matcher.groupCount() == 2) {
                int domain = Integer.parseInt(matcher.group(1));
                int cmd = Integer.parseInt(matcher.group(2));

                VdtMessage message = new VdtMessage(domain, cmd, p1, p2);
                return message;
            }
        }
        return null;
    }

    private final Pattern mPattern = Pattern.compile("ECMD(\\d+).(\\d+)", Pattern.CASE_INSENSITIVE
            | Pattern.MULTILINE);

}

