package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.utils.LongUtil;
import com.orhanobut.logger.Logger;

import java.nio.charset.StandardCharsets;

public class DmsCommand {

    private final static String TAG = DmsCommand.class.getSimpleName();

    private final static int DMS_CMD_SIZE = 160;
    private byte[] mCmdBuffer = new byte[DMS_CMD_SIZE];

    private int mSendIndex = 0;
    private int mCommandCode;

    private final static int DMS_FACEID_NAME_SIZE = 32;

    private DmsCommand() {

    }

    private void writeCmdCode(int code, long tag) {
        writeCmdCode(code, 0, tag, 0, 0);
    }

    private void writeCmdCode(int code, int flags, long tag, long user1, long user2) {
        mSendIndex = 0;
        writeUInt16(code);
        writeUInt16(flags);
        writeUInt32(tag);
        writeUInt32(user1);
        writeUInt32(user2);
    }

    public byte[] getCmdBuffer() {
        return mCmdBuffer;
    }

//    public short getUInt8(short s) {
//        return (short) (s & 0x00ff);
//    }
//
//    public int getUInt16(int i) {
//        return i & 0x0000ffff;
//    }
//
//    public long getUInt32(long l) {
//        return l;
//    }

//    private void writeInt16(int value) {
//        mCmdBuffer[mSendIndex] = (byte) (value);
//        mSendIndex++;
//        mCmdBuffer[mSendIndex] = (byte) (value >> 8);
//        mSendIndex++;
//    }

    private void writeUInt16(int value) {
        mCmdBuffer[mSendIndex] = (byte) (value);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 8);
        mSendIndex++;
    }

    private void writeInt32(int value) {
        mCmdBuffer[mSendIndex] = (byte) (value);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 8);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 16);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 24);
        mSendIndex++;
    }

    private void writeUInt32(long value) {
        mCmdBuffer[mSendIndex] = (byte) (value);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 8);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 16);
        mSendIndex++;
        mCmdBuffer[mSendIndex] = (byte) (value >> 24);
        mSendIndex++;
    }

    private void writeInt64(long value) {
        writeInt32((int) value);
        writeInt32((int) (value >> 32));
    }

    public void writeUInt64(String value) {
        long unsignedLong = LongUtil.parseUnsignedLong(value);
        int upper = (int) (unsignedLong >>> 32);
        int lower = (int) unsignedLong;
        writeInt32(lower);
        writeInt32(upper);
    }

//    private void writeString(String value) {
//        if (value == null) {
//            return;
//        }
//        int length = value.length();
//        // 4 + length + 0 + aligned_to_4
//        int align = 0;
//        if ((length + 1) % 4 != 0) {
//            align = 4 - (length + 1) % 4;
//        }
//        // check buffer length
//        if (mSendIndex + 4 + length + 1 + align > DMS_CMD_SIZE) {
//            Logger.t(TAG).w("dms_id is too long: " + length);
//            return;
//        }
//        writeInt32(length + 1);
//        for (int i = 0; i < length; i++) {
//            mCmdBuffer[mSendIndex] = (byte) value.charAt(i);
//            mSendIndex++;
//        }
//        for (int i = 0; i <= align; i++) {
//            mCmdBuffer[mSendIndex] = 0;
//            mSendIndex++;
//        }
//    }

    public void writeString(String value) {
        if (value == null) {
            return;
        }
        byte[] valueBytes = value.getBytes(StandardCharsets.UTF_8);
        int length = valueBytes.length;
        // check buffer length
        if (length > DMS_FACEID_NAME_SIZE && mSendIndex + length > DMS_CMD_SIZE) {
            Logger.t(TAG).w("dms_id is too long: " + length);
            return;
        }
        int align = 0;
        if (length <= DMS_FACEID_NAME_SIZE) {
            align = DMS_FACEID_NAME_SIZE - length;
        }
        for (byte valueByte : valueBytes) {
            mCmdBuffer[mSendIndex] = valueByte;
            mSendIndex++;
        }
        if (align != 0) {
            for (int i = 0; i < align; i++) {
                mCmdBuffer[mSendIndex] = 0;
                mSendIndex++;
            }
        }
    }

    public int getCommandCode() {
        return mCommandCode;
    }

    public void setSequence(long sequence) {
        mCmdBuffer[8] = (byte) (sequence);
        mCmdBuffer[9] = (byte) (sequence >> 8);
        mCmdBuffer[10] = (byte) (sequence >> 16);
        mCmdBuffer[11] = (byte) (sequence >> 24);
    }

    private static class Builder {
        DmsCommand mDmsCommand;

        private Builder() {
            this.mDmsCommand = new DmsCommand();
        }

        private Builder writeCmdCode(int code, long tag) {
            mDmsCommand.writeCmdCode(code, tag);
            mDmsCommand.mCommandCode = code;
            return this;
        }

        private Builder writeCmdCode(int code, int flags, long tag, long user1, long user2) {
            mDmsCommand.writeCmdCode(code, flags, tag, user1, user2);
            mDmsCommand.mCommandCode = code;
            return this;
        }

        private Builder writeUInt32(long value) {
            mDmsCommand.writeUInt32(value);
            return this;
        }

        private Builder writeInt64(long value) {
            mDmsCommand.writeInt64(value);
            return this;
        }

        public Builder writeUInt64(String value) {
            mDmsCommand.writeUInt64(value);
            return this;
        }

        private Builder writeString(String value) {
            mDmsCommand.writeString(value);
            return this;
        }

        private Builder writeFloat(float value) {
            mDmsCommand.writeInt32(Float.floatToIntBits(value));
            return this;
        }

        private DmsCommand build() {
            return mDmsCommand;
        }
    }

    public static class Factory {

        final static int DMS_CMD_NONE = 0;
        final static int DMS_CMD_GetVersionInfo = 1;
        final static int DMS_CMD_ListFaceIds = 2;
        final static int DMS_CMD_RemoveFaceId = 3;

        final static int RS_CMD_START = 100;
        final static int RS_CMD_CaptureImage = RS_CMD_START + 0;
        final static int RS_CMD_AddFaceId = RS_CMD_START + 1;

        final static int ES_CMD_START = 200;
        final static int ES_CMD_StartUserEnrollment = ES_CMD_START + 1;
        final static int ES_CMD_EstimateCameraPose = ES_CMD_START + 2;
        final static int ES_CMD_GetDumpYFlag = ES_CMD_START + 3;
        final static int ES_CMD_SetDumpYFlag = ES_CMD_START + 4;

        final static int ES_MSG_START = 400;
        final static int ES_MSG_UserEnrollment = ES_MSG_START + 0;

        public static DmsCommand getVersionInfo() {
            return new Builder()
                    .writeCmdCode(DMS_CMD_GetVersionInfo, 0)
                    .build();
        }

        public static DmsCommand getListFaceIds() {
            return new Builder()
                    .writeCmdCode(DMS_CMD_ListFaceIds, 0)
                    .build();
        }

        public static DmsCommand removeFaceWithID(String faceID) {
            return new Builder()
                    .writeCmdCode(DMS_CMD_RemoveFaceId, 0)
                    .writeUInt64(faceID)
                    .writeUInt32(0)
                    .build();
        }

        public static DmsCommand removeAllFaces() {
            return new Builder()
                    .writeCmdCode(DMS_CMD_RemoveFaceId, 1)
                    .writeUInt32(0)
                    .writeUInt32(0)
                    .writeUInt32(1)
                    .build();
        }

        public static DmsCommand addFaceWithID(String faceID, String name) {
            return new Builder()
                    .writeCmdCode(ES_CMD_StartUserEnrollment, 0)
                    .writeUInt64(faceID)
                    .writeString(name)
                    .build();
        }

        public static DmsCommand doCalibWithX(float x, float y, float z) {
            return new Builder()
                    .writeCmdCode(ES_CMD_EstimateCameraPose, 0)
                    .writeFloat(x)
                    .writeFloat(y)
                    .writeFloat(z)
                    .build();
        }
    }
}
