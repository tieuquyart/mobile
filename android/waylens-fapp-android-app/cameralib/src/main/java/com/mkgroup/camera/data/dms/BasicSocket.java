package com.mkgroup.camera.data.dms;


import com.mkgroup.camera.data.DmsClient;
import com.mkgroup.camera.data.SnipeError;

import java.io.IOException;

public class BasicSocket implements ISocket {

    private final DmsClient mDmsClient;

    public BasicSocket(DmsClient dmsClient) {
        this.mDmsClient = dmsClient;
    }

    @Override
    public void performRequest(DmsRequest<?> dmsRequest) throws SnipeError {
        try {
            DmsCommand dmsCommand = dmsRequest.createDmsCommand();
            dmsCommand.setSequence(dmsRequest.getSequence());
            mDmsClient.sendCommand(dmsCommand);
        } catch (Exception e) {
            throw new SnipeError();
        }
    }

    @Override
    public DmsAcknowledge retrieveAcknowledge() throws IOException {
        return new DmsAcknowledge(0, mDmsClient);
    }
}
