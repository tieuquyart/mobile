package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.model.rawdata.ObdData;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbMessageHandler;
import com.mkgroup.camera.data.vdb.VdbResponse;
import com.mkgroup.camera.model.rawdata.DmsData;
import com.mkgroup.camera.model.rawdata.GpsData;
import com.mkgroup.camera.model.rawdata.IioData;
import com.mkgroup.camera.model.rawdata.RawDataItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by DoanVT on 2017/8/11.
 */
public class RawDataMsgHandler extends VdbMessageHandler<List<RawDataItem>> {
    public static String TAG = RawDataMsgHandler.class.getSimpleName();

    public RawDataMsgHandler(VdbResponse.Listener<List<RawDataItem>> listener,
                             VdbResponse.ErrorListener errorListener) {
        super(VdbCommand.Factory.MSG_RawData, listener, errorListener);
        rawDataItemList = new ArrayList<RawDataItem>(5);
//        Logger.t(TAG).d("rawDataList size = " + rawDataItemList.size());
        for (int i = 0; i < 5; i++) {
            rawDataItemList.add(null);
        }
//        Logger.t(TAG).d("rawDataList size = " + rawDataItemList.size());

    }

    public static int OBD_DATA = 0;
    public static int IIO_DATA = 1;
    public static int GPS_DATA = 2;
    public static int DMS0_DATA = 3;
    public static int DMS1_DATA = 4;

    private List<RawDataItem> rawDataItemList;
    int[] unchangedCount = new int[]{-1, -1, -1, -1, -1};
    int periodReached = 0;


    @Override
    protected VdbResponse<List<RawDataItem>> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("MSG_RawData parseVdbResponse: " + retCode);
            return null;
        }
//        Logger.t(TAG).d("parseVdbResponse");
        int dataType = response.readi32();
        byte[] data = response.readByteArray();
        List<RawDataItem> rawDataItemListTmp = new ArrayList<RawDataItem>();
        RawDataItem rawDataItem = new RawDataItem(dataType, 0);
        for (int i = 0; i < unchangedCount.length; i++) {
            if (unchangedCount[i] >= 0)
                unchangedCount[i]++;
        }
        switch (dataType) {
            case RawDataItem.DATA_TYPE_OBD:
                unchangedCount[OBD_DATA] = 0;
                rawDataItem.data = ObdData.fromBinary(data);
                if (rawDataItemList.get(OBD_DATA) != null) {
                    periodReached = 1;
                }
                rawDataItemList.set(OBD_DATA, rawDataItem);
                break;
            case RawDataItem.DATA_TYPE_IIO:
                unchangedCount[IIO_DATA] = 0;
                rawDataItem.data = IioData.fromBinary(data);
                if (rawDataItemList.get(IIO_DATA) != null) {
                    periodReached = 1;
                }
                rawDataItemList.set(IIO_DATA, rawDataItem);
                break;
            case RawDataItem.DATA_TYPE_GPS:
                unchangedCount[GPS_DATA] = 0;
                rawDataItem.data = GpsData.fromBinary(data);
                if (rawDataItemList.get(GPS_DATA) != null) {
                    periodReached = 1;
                }
                rawDataItemList.set(GPS_DATA, rawDataItem);
                break;
            case RawDataItem.DATA_TYPE_DMS0:
//                Logger.t(TAG).d("DATA_TYPE_DMS0");
                break;
            case RawDataItem.DATA_TYPE_DMS1:
//                Logger.t(TAG).d("DATA_TYPE_DMS1");
                unchangedCount[DMS1_DATA] = 0;
                try {
                    rawDataItem.data = DmsData.fromBinary(data);
                } catch (Exception ex) {
                    Logger.t(TAG).e("DmsData fromBinary error = " + ex.getMessage() + " , size = " + data.length);
                    return null;
                }
                if (rawDataItemList.get(DMS1_DATA) != null) {
                    periodReached = 1;
                }
                rawDataItemList.set(DMS1_DATA, rawDataItem);
                break;
            default:
                return null;
        }

        if (dataType != RawDataItem.DATA_TYPE_DMS1) {
            for (int i = 0; i < unchangedCount.length; i++) {
                if (unchangedCount[i] > 300) {
                    rawDataItemList.set(i, null);
                    unchangedCount[i] = -1;
                }
            }
        }

        if (periodReached != 0) {
            for (int i = 0; i < rawDataItemList.size(); i++) {
                if (rawDataItemList.get(i) != null)
                    rawDataItemListTmp.add(rawDataItemList.get(i));
            }
            periodReached = 0;
//            Logger.t(TAG).d("should show off");
        } else {
            Logger.t(TAG).d(unchangedCount[0] + "   " + unchangedCount[1]
                    + "    " + unchangedCount[2] + "    " + unchangedCount[3] + "    " + unchangedCount[4]);
            return null;
        }

        return VdbResponse.success(rawDataItemListTmp);
    }
}
