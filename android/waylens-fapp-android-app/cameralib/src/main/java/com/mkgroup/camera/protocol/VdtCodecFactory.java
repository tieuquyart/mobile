package com.mkgroup.camera.protocol;

import org.apache.mina.core.session.IoSession;
import org.apache.mina.filter.codec.ProtocolCodecFactory;
import org.apache.mina.filter.codec.ProtocolDecoder;
import org.apache.mina.filter.codec.ProtocolEncoder;

/**
 * Created by DoanVT on 2017/7/27.
 */

public class VdtCodecFactory implements ProtocolCodecFactory {

    private final boolean isVdtCamera;

    public VdtCodecFactory(boolean isVdtCamera) {
        this.isVdtCamera = isVdtCamera;
    }

    @Override
    public ProtocolDecoder getDecoder(IoSession session) throws Exception {
        return isVdtCamera ? new VdtDecoder() : new EvCamDecoder();
    }

    @Override
    public ProtocolEncoder getEncoder(IoSession session) throws Exception {
        return isVdtCamera ? new VdtEncoder() : new EvCamEncoder();
    }

}