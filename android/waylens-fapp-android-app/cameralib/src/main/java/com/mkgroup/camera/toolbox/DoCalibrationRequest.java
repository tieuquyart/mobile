package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.dms.DmsAcknowledge;
import com.mkgroup.camera.data.dms.DmsCommand;
import com.mkgroup.camera.data.dms.DmsRequest;
import com.mkgroup.camera.data.dms.DmsResponse;
import com.mkgroup.camera.model.dms.Result;

public class DoCalibrationRequest extends DmsRequest<Result> {

    private final static String TAG = DoCalibrationRequest.class.getSimpleName();

    private int x;
    private int y;
    private int z;

    public DoCalibrationRequest(int x, int y, int z, DmsResponse.Listener<Result> listener, DmsResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.x = x;
        this.y = y;
        this.z = z;
    }

    @Override
    protected DmsCommand createDmsCommand() {
        mDmsCommand = DmsCommand.Factory.doCalibWithX(x, y, z);
        return mDmsCommand;
    }

    @Override
    protected DmsResponse<?> parseDmsResponse(DmsAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse: " + retCode);
            return null;
        }

        Result result = new Result();
        result.result = true;

        return DmsResponse.success(result);
    }
}
