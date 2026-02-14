package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.data.dms.DmsAcknowledge;
import com.mkgroup.camera.data.dms.DmsCommand;
import com.mkgroup.camera.data.dms.DmsRequest;
import com.mkgroup.camera.data.dms.DmsResponse;
import com.mkgroup.camera.model.dms.VersionInfo;

public class GetVersionInfoRequest extends DmsRequest<VersionInfo> {

    public GetVersionInfoRequest(int method, DmsResponse.Listener<VersionInfo> listener, DmsResponse.ErrorListener errorListener) {
        super(method, listener, errorListener);
    }

    @Override
    protected DmsCommand createDmsCommand() {
        mDmsCommand = DmsCommand.Factory.getVersionInfo();
        return mDmsCommand;
    }

    @Override
    protected DmsResponse<?> parseDmsResponse(DmsAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            return null;
        }

        VersionInfo versionInfo = new VersionInfo();

        versionInfo.major = response.readUInt16();
        versionInfo.minor = response.readUInt16();
        versionInfo.vendor = response.readUInt32();

        return DmsResponse.success(versionInfo);
    }

}
