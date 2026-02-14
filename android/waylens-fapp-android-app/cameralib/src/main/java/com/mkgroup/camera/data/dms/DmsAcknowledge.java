package com.mkgroup.camera.data.dms;


import com.mkgroup.camera.data.DmsClient;
import com.mkgroup.camera.utils.LongUtil;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbCommand;

import org.apache.mina.core.buffer.IoBuffer;

import java.io.IOException;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

public class DmsAcknowledge {

    private final static String TAG = DmsAcknowledge.class.getSimpleName();

    private final static int DMS_ACK_SIZE = 160;
    private final static int DMS_ACK_MAGIC = 0xFAFBFCFF;

    private final static int DMS_IPC_VERSION_MAJOR = 1;
    private final static int DMS_IPC_VERSION_MINOR = 0;

    private final static int VENDOR_NONE = 0;
    private final static int VENDOR_READSENSE = 1;
    private final static int VENDOR_EYESIGHT = 2;

    private final static int FACEID_NAME_LEN = 32;

    private final int statueCode;
    final boolean notModified;

    private final DmsClient mDmdClient;

    private int mMsgIndex;

    private byte[] mAckBuffer;
    private byte[] mMsgBuffer;

    private long mMsgSeqid;

    private long mUser1;
    private long mUser2;
    private int mCmdCode;
    private int mCmdFlags;
    private long mCmdTag;

    private int mRetCode;

    private static final int MAX_VALID_SIZE = 1024 * 1024 * 10;

    public DmsAcknowledge(int statusCode, DmsClient dmsClient) throws IOException {
        this.statueCode = statusCode;
        this.notModified = false;
        this.mDmdClient = dmsClient;

        mAckBuffer = dmsClient.receivedAck();
        parseAcknowledge();
    }

    public boolean isMessageAck() {
//        return (mMsgCode >= VdbCommand.Factory.MSG_VdbReady) && (mMsgCode <= VdbCommand.Factory.MSG_MarkLiveClipInfo);

        return false;
    }

    private void parseAcknowledge() throws IOException {
        IoBuffer ioBuffer = IoBuffer.wrap(mAckBuffer);
        ioBuffer.order(ByteOrder.LITTLE_ENDIAN);

        if (ioBuffer.getUnsignedInt() != DMS_ACK_MAGIC) {
            // error parse
        }

        mMsgSeqid = ioBuffer.getUnsignedInt();

        mUser1 = ioBuffer.getUnsignedInt();
        mUser2 = ioBuffer.getUnsignedInt();
        mCmdCode = ioBuffer.getUnsignedShort();
        mCmdFlags = ioBuffer.getUnsignedShort();
        mCmdTag = ioBuffer.getUnsignedInt();

        mRetCode = ioBuffer.getInt();
        long extra_size = ioBuffer.getUnsignedInt();

        if (extra_size > 0) {
            int size = (int) (DMS_ACK_SIZE + extra_size);
            if (size > MAX_VALID_SIZE) {
                throw new IOException("Abnormal size: " + size);
            }
            mMsgBuffer = new byte[size];
            System.arraycopy(mAckBuffer, 0, mMsgBuffer, 0, DMS_ACK_SIZE);
            mDmdClient.readFully(mMsgBuffer, DMS_ACK_SIZE, (int) extra_size);
            mAckBuffer = mMsgBuffer;
        }

        mMsgIndex = 32;

//        switch (mCmdCode) {
//            case DMS_CMD_GetVersionInfo:
//
//                break;
//            case DMS_CMD_ListFaceIds:
//                long reserved = ioBuffer.getUnsignedInt();
//                long nums_ids = ioBuffer.getUnsignedInt();
//                if (nums_ids > 0) {
//                    for (int i = 0; i < nums_ids; i++) {
//                        long faceid_lo = ioBuffer.getUnsignedInt();
//                        long faceid_hi = ioBuffer.getUnsignedInt();
//                        byte[] name = new byte[FACEID_NAME_LEN];
//                        ioBuffer.get(name);
//                    }
//                }
//                break;
//            case DMS_CMD_RemoveFaceId:
//                long faceid_lo = ioBuffer.getUnsignedInt();
//                long faceid_hi = ioBuffer.getUnsignedInt();
//                long remove_all = ioBuffer.getUnsignedInt();
//                break;
//            case ES_CMD_StartUserEnrollment:
//                if (mRetCode == 0) {
//                    // success
//                } else {
//                    // error
//                }
//                break;
//            case ES_CMD_EstimateCameraPose:
//                float x = ioBuffer.getFloat();
//                float y = ioBuffer.getFloat();
//                float z = ioBuffer.getFloat();
//                break;
//        }

    }

    public Integer getMsgCode() {
        return mCmdCode;
    }

    public Long getUser1() {
        return mUser1;
    }

    public VdbCommand getDmsCommand() {
        return null;
    }

    public int getRetCode() {
        return mRetCode;
    }

    public short readInt16() {
        int result = (int) mAckBuffer[mMsgIndex] & 0xFF;
        mMsgIndex++;
        result |= ((int) mAckBuffer[mMsgIndex] & 0xFF) << 8;
        mMsgIndex++;
        return (short) result;
    }

    public int readUInt16() {
        int firstByte = (0x000000FF & mAckBuffer[mMsgIndex++]);
        int secondByte = (0x000000FF & mAckBuffer[mMsgIndex++]);

        return (firstByte | secondByte << 8) & 0xFFFF;
    }

    public int readInt32() {
        int result = (int) mAckBuffer[mMsgIndex] & 0xFF;
        mMsgIndex++;
        result |= ((int) mAckBuffer[mMsgIndex] & 0xFF) << 8;
        mMsgIndex++;
        result |= ((int) mAckBuffer[mMsgIndex] & 0xFF) << 16;
        mMsgIndex++;
        result |= ((int) mAckBuffer[mMsgIndex] & 0xFF) << 24;
        mMsgIndex++;
        return result;
    }

    public long readUInt32() {
        int firstByte = (0x000000FF & mAckBuffer[mMsgIndex++]);
        int secondByte = (0x000000FF & mAckBuffer[mMsgIndex++]);
        int thirdByte = (0x000000FF & mAckBuffer[mMsgIndex++]);
        int fourthByte = (0x000000FF & mAckBuffer[mMsgIndex++]);

        return ((long) (firstByte | secondByte << 8 | thirdByte << 16 | fourthByte << 24)) & 0xFFFFFFFFL;
    }

    public long readInt64() {
        int lo = readInt32();
        int hi = readInt32();
        return ((long) hi << 32) | ((long) lo & 0xFFFFFFFFL);
    }

    public String readUInt64() {
        long int64 = readInt64();
        return LongUtil.toUnsignedString(int64);
    }

    public String readString() {
        String result;
        try {
            result = new String(mAckBuffer, mMsgIndex, FACEID_NAME_LEN, StandardCharsets.UTF_8);
        } catch (Exception exception) {
            Logger.t(TAG).e("readString exception = " + exception.getMessage());
            result = "";
        }
        mMsgIndex += FACEID_NAME_LEN;
        return result;
    }

//    private void parseDmsIpcCmdHeader(IoBuffer ioBuffer) {
//        int cmdCode = ioBuffer.getUnsignedShort();
//        int cmdFlags = ioBuffer.getUnsignedShort();
//        long cmdTag = ioBuffer.getUnsignedInt();
//        long user1 = ioBuffer.getUnsignedInt();
//        long user2 = ioBuffer.getUnsignedInt();
//    }
}
