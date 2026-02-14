package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.dms.DmsAcknowledge;
import com.mkgroup.camera.data.dms.DmsCommand;
import com.mkgroup.camera.data.dms.DmsRequest;
import com.mkgroup.camera.data.dms.DmsResponse;
import com.mkgroup.camera.model.dms.Result;

public class AddFaceRequest extends DmsRequest<Result> {

    private final String TAG = AddFaceRequest.class.getSimpleName();

    private String faceId;
    private String name;

    public AddFaceRequest(String faceId, String name, DmsResponse.Listener<Result> listener, DmsResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.faceId = faceId;
        this.name = name;
    }

    @Override
    protected DmsCommand createDmsCommand() {
        mDmsCommand = DmsCommand.Factory.addFaceWithID(faceId, name);
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
