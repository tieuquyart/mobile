package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.dms.DmsAcknowledge;
import com.mkgroup.camera.data.dms.DmsCommand;
import com.mkgroup.camera.data.dms.DmsRequest;
import com.mkgroup.camera.data.dms.DmsResponse;
import com.mkgroup.camera.model.dms.Result;

public class RemoveFaceRequest extends DmsRequest<Result> {

    private final static String TAG = RemoveFaceRequest.class.getSimpleName();

    private String faceId;
    private long flag;

    public RemoveFaceRequest(String faceId, long flag, DmsResponse.Listener<Result> listener, DmsResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.faceId = faceId;
        this.flag = flag;
    }

    @Override
    protected DmsCommand createDmsCommand() {
        if (flag == 0) {
            mDmsCommand = DmsCommand.Factory.removeFaceWithID(faceId);
        } else {
            mDmsCommand = DmsCommand.Factory.removeAllFaces();
        }
        return mDmsCommand;
    }

    @Override
    protected DmsResponse<?> parseDmsResponse(DmsAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseDmsResponse: " + retCode);
            return null;
        }

        Result result = new Result();
        result.result = true;

        return DmsResponse.success(result);
    }
}
