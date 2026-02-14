package com.mkgroup.camera.toolbox;

import android.os.Bundle;

import com.jakewharton.disklrucache.DiskLruCache;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.rawdata.ObdData;
import com.mkgroup.camera.model.rawdata.RawDataBlock;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;
import com.mkgroup.camera.model.rawdata.GpsData;
import com.mkgroup.camera.model.rawdata.IioData;
import com.mkgroup.camera.model.rawdata.RawDataItem;

import java.io.IOException;
import java.io.OutputStream;


/**
 * Created by doanvt on 2015/9/11.
 */
public class RawDataBlockRequest extends VdbRequest<RawDataBlock> {
    private static final String TAG = RawDataBlockRequest.class.getSimpleName();
    private final Clip.ID mCid;
    private final int mDataType;
    private final long mClipTimeMs;
    private final int mDuration;

    public static final String PARAM_CLIP_TIME = "clip.time.ms";
    public static final String PARAM_CLIP_LENGTH = "clip.length.ms";
    public static final String PARAM_DATA_TYPE = "raw.data.type";

    public RawDataBlockRequest(Clip.ID cid, Bundle params, VdbResponse.Listener<RawDataBlock> listener,
                               VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.mCid = cid;
        this.mDataType = params.getInt(PARAM_DATA_TYPE, RawDataItem.DATA_TYPE_NONE);
        mClipTimeMs = params.getLong(PARAM_CLIP_TIME, 0);
        mDuration = params.getInt(PARAM_CLIP_LENGTH, 0);
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdGetRawDataBlock(mCid, true, mDataType, mClipTimeMs, mDuration);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<RawDataBlock> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse failed: " + retCode);
            return null;
        }
        int bufSize = response.mReceiveBuffer.length - response.getMsgIndex();
        byte[] cacheBuf = new byte[bufSize];
        System.arraycopy(response.mReceiveBuffer, response.getMsgIndex(), cacheBuf, 0, bufSize);
        DiskLruCache rawDataCache = VdtCameraManager.getManager().getRawDataDiskLruCache();
        com.jakewharton.disklrucache.DiskLruCache.Editor editor = null;
        try {
            if (rawDataCache != null) {
                String key = VdtCameraManager.constructKeyForDiskCache(mCid, mDataType);
                editor = rawDataCache.edit(key);
                if (editor != null) {
                    OutputStream outputStream = editor.newOutputStream(0);
                    outputStream.write(cacheBuf);
                    outputStream.flush();
                    outputStream.close();
                    editor.commit();
                }
            }
        } catch (IOException e) {
            try {
                if (editor != null) {
                    editor.abort();
                }
            } catch (IOException e1) {
                Logger.t(TAG).d(e1.getMessage());
            }
        }

        int clipType = response.readi32();
        int clipId = response.readi32();
        Clip.ID cid = new Clip.ID(clipType, clipId, null);
        RawDataBlock.RawDataBlockHeader header = new RawDataBlock.RawDataBlockHeader(cid);
        header.mClipDate = response.readi32();
        header.mDataType = response.readi16();
        header.mDataOptions = response.readi16();
        header.mRequestedTimeMs = response.readi64();
        header.mNumItems = response.readi32();
        header.mDataSize = response.readi32();

        RawDataBlock block = new RawDataBlock(header);

        int numItems = block.header.mNumItems;
        block.timeOffsetMs = new int[numItems];
        block.dataSize = new int[numItems];

        for (int i = 0; i < numItems; i++) {
            block.timeOffsetMs[i] = response.readi32();
            block.dataSize[i] = response.readi32();
        }


        for (int i = 0; i < numItems; i++) {
            RawDataItem item = new RawDataItem(header.mDataType, block.timeOffsetMs[i] + header.mRequestedTimeMs);

            byte[] data = response.readByteArray(block.dataSize[i]);
            item.originData = data;
            if (header.mDataType == RawDataItem.DATA_TYPE_OBD) {
                item.data = ObdData.fromBinary(data);
            } else if (header.mDataType == RawDataItem.DATA_TYPE_IIO) {
                item.data = IioData.fromBinary(data);
            } else if (header.mDataType == RawDataItem.DATA_TYPE_GPS) {
                item.data = GpsData.fromBinary(data);
            }

            block.addRawDataItem(item);
        }


        return VdbResponse.success(block);
    }
}
