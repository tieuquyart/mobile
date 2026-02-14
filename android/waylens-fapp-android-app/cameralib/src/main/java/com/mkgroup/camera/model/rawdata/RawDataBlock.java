package com.mkgroup.camera.model.rawdata;

/**
 * Created by DoanVT on 2017/11/29.
 * Email: doanvt-hn@mk.com.vn
 */

import com.mkgroup.camera.model.Clip;

import org.apache.mina.core.buffer.IoBuffer;

import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.List;

public class RawDataBlock {

    public static final byte F_RAW_DATA_GPS = (1 << RawDataItem.DATA_TYPE_GPS);
    public static final byte F_RAW_DATA_ACC = (1 << RawDataItem.DATA_TYPE_IIO);
    public static final byte F_RAW_DATA_ODB = (1 << RawDataItem.DATA_TYPE_OBD);

    public final RawDataBlockHeader header;
    public int[] timeOffsetMs;
    public int[] dataSize;
    public byte[] data;

    private int mItemIndex = 0;

    public static class RawDataBlockHeader {
        public final Clip.ID cid;
        public int mClipDate;
        public int mDataType;
        public int mDataOptions;
        public long mRequestedTimeMs;
        public int mNumItems;
        public int mDataSize;

        public RawDataBlockHeader(Clip.ID cid) {
            this.cid = cid;
        }
    }

    public static class DownloadRawDataBlock {
        public final RawDataBlockHeader header;
        public byte[] ack_data;

        public DownloadRawDataBlock(RawDataBlockHeader header) {
            this.header = header;
        }
    }


    private List<RawDataItem> mRawDataItems = new ArrayList<>();

    public RawDataBlock(RawDataBlockHeader header) {
        this.header = header;
    }

    public List<RawDataItem> getItemList() {
        return mRawDataItems;
    }

    public RawDataItem getRawDataItem(int index) {
        return mRawDataItems.get(index);
    }

    public void addRawDataItem(RawDataItem item) {
        mRawDataItems.add(item);
    }


    public RawDataItem getRawDataItemByTime(long timeMs) {
        int low = 0;
        int high = mRawDataItems.size() - 1;
        int mid, res = -1;
        if (mRawDataItems.get(low).getPtsMs() > timeMs || mRawDataItems.get(high).getPtsMs() < timeMs) {
            return null;
        }
        while (low < high) {
            mid = (low + high) / 2;
            if (mRawDataItems.get(mid).getPtsMs() == timeMs) {
                res = mid;
                break;
            } else if (mRawDataItems.get(mid).getPtsMs() < timeMs) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        RawDataItem updateItem = null;
        if (res != -1) {
            updateItem = new RawDataItem(mRawDataItems.get(res));
        } else {
            updateItem = new RawDataItem(mRawDataItems.get(low));
        }

        if (Math.abs(updateItem.getPtsMs() - timeMs) <= 5000) {
            return updateItem;
        } else {
            return null;
        }
    }

    public byte[] toByteBuffer(long startTime, long endTime) {
        int low = lowIndex(mRawDataItems, startTime);
        int high = highIndex(mRawDataItems, endTime);
        if (low >= 0 && low < mRawDataItems.size() && high >= 0 && high < mRawDataItems.size() && low <= high) {

        } else {
            return null;
        }
        IoBuffer buffer = IoBuffer.allocate(10_000).setAutoExpand(true);

        buffer.order(ByteOrder.LITTLE_ENDIAN);
        buffer.putUnsignedInt(header.cid.type);
        buffer.putUnsignedInt(header.cid.subType);
        buffer.putUnsignedInt(header.mClipDate);

        buffer.putUnsignedShort(header.mDataType);
        buffer.putUnsignedShort(header.mDataOptions);

        buffer.putUnsignedInt(header.mRequestedTimeMs & 0xFFFFFFFFL);
        buffer.putUnsignedInt(header.mRequestedTimeMs >> 32 & 0xFFFFFFFFL);

        buffer.putUnsignedInt(high - low + 1);
        int sizeIndex = buffer.position();
        buffer.putUnsignedInt(0);

        for (int i = low; i <= high; i++) {
            buffer.putUnsignedInt(timeOffsetMs[i]);
            buffer.putUnsignedInt(dataSize[i]);
        }
        for (int i = low; i <= high; i++) {
            buffer.put(mRawDataItems.get(i).originData);
        }

        int endIndex = buffer.position();
        buffer.putUnsignedInt(sizeIndex, endIndex - sizeIndex - 4);
        buffer.flip();

        return buffer.array();
    }


    private static int lowIndex(List<RawDataItem> list, long time) {
        int low = 0;
        int high = list.size()-1;

        if (list.size() > 0 && list.get(low).getPtsMs() > time) {
            return 0;
        }
        if (list.size() > 0 && list.get(high).getPtsMs() < time) {
            return list.size();
        }

        while (low <= high) {
            int mid = (low + high) >>> 1;
            RawDataItem midVal = list.get(mid);

            if (midVal.getPtsMs() < time)
                low = mid + 1;
            else if (midVal.getPtsMs() > time)
                high = mid - 1;
            else
                return mid; // key found
        }

        return low;
    }

    private static int highIndex(List<RawDataItem> list, long time) {
        int low = 0;
        int high = list.size()-1;

        if (list.size() > 0 && list.get(low).getPtsMs() > time) {
            return -1;
        }
        if (list.size() > 0 && list.get(high).getPtsMs() < time) {
            return list.size() - 1;
        }

        while (low <= high) {
            int mid = (low + high) >>> 1;
            RawDataItem midVal = list.get(mid);

            if (midVal.getPtsMs() < time)
                low = mid + 1;
            else if (midVal.getPtsMs() > time)
                high = mid - 1;
            else
                return mid; // key found
        }
        return high;
    }
}
