package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.dms.DmsAcknowledge;
import com.mkgroup.camera.data.dms.DmsCommand;
import com.mkgroup.camera.data.dms.DmsRequest;
import com.mkgroup.camera.data.dms.DmsResponse;
import com.mkgroup.camera.model.dms.FaceList;

public class GetListFacesRequest extends DmsRequest<FaceList> {

    private final static String TAG = GetListFacesRequest.class.getSimpleName();

    public GetListFacesRequest(int method, DmsResponse.Listener<FaceList> listener, DmsResponse.ErrorListener errorListener) {
        super(method, listener, errorListener);
    }

    @Override
    protected DmsCommand createDmsCommand() {
        mDmsCommand = DmsCommand.Factory.getListFaceIds();
        return mDmsCommand;
    }

    @Override
    protected DmsResponse<?> parseDmsResponse(DmsAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            return null;
        }

        FaceList faceList = new FaceList();
        try {
            faceList.reserved = response.readUInt32();
            faceList.num_ids = response.readUInt32();
            for (int i = 0; i < faceList.num_ids; i++) {
                FaceList.FaceItem faceItem = new FaceList.FaceItem();
                faceItem.faceID = response.readUInt64();
                faceItem.name = response.readString();
//                faceItem.person_id = response.readUInt32(); // just for eyesight v6
                faceList.mClipList.add(faceItem);
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("parseDmsResponse exception: " + ex.getMessage());
        }

        return DmsResponse.success(faceList);
    }
}
