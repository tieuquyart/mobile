package com.mkgroup.camera.model.rawdata;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.model.dms.FaceList;

import java.io.Serializable;

public class DmsData implements Serializable {

    private final static String TAG = DmsData.class.getSimpleName();

    private final static int EYESIGHT_DATA_F_L1_HAS_INTERNAL_DATA = 1;
    private final static int EYESIGHT_DATA_F_L1_HAS_PERSON_ID = 1 << 1;

    private final static int DMS_DATA_LEVEL = 0x00010002;

    //typedef struct eyesight_dms_data_header_s {
    //    uint32_t version;
    //    uint32_t revision;

    //    uint16_t src_width;        // input video size
    //    uint16_t src_height;

    //    uint16_t input_xoff;    // a rectangle in input video
    //    uint16_t input_yoff;

    //    uint16_t input_width;
    //    uint16_t input_height;

    //    uint16_t dms_width;        // after resizing
    //    uint16_t dms_height;

    //    uint32_t flags;
    //    uint32_t isDriverValid;    // for all levels
    //    uint32_t level;            // 0: no data; 1: L1; 2: L2
    //    uint32_t data_size;
    //} eyesight_dms_data_header_t;

    public long version;
    public long revision;

    public int src_width;
    public int src_height;

    public int input_xoff;
    public int input_yoff;

    public int input_width;
    public int input_height;

    public int dms_width;
    public int dms_height;

    public long flags;
    public long isDriverValid;
    public long level;
    public long data_size;

    public final Output output = new Output();

    public L1Output l1Output;

    public L2Output l2Output;

    public L1Internal l1Internal;

    public FaceList.FaceItem person_info;

    public L2Output[] l2Outputs;

    public static DmsData fromBinary(byte[] data) {
        DmsData result = new DmsData();

        ByteStream stream = new ByteStream(data);

        result.version = stream.readUint32();
        result.revision = stream.readUint32();

        result.src_width = stream.readInt16();
        result.src_height = stream.readInt16();

        result.input_xoff = stream.readInt16();
        result.input_yoff = stream.readInt16();

        result.input_width = stream.readInt16();
        result.input_height = stream.readInt16();

        result.dms_width = stream.readInt16();
        result.dms_height = stream.readInt16();

        result.flags = stream.readUint32();
        result.isDriverValid = stream.readUint32();
        result.level = stream.readUint32();
        result.data_size = stream.readUint32(); // 判断data_size

        if (result.version < 4 || result.revision < 1) {
            return result;
        }

        if (result.isDriverValid != 1) {
            return result;
        }

        if (result.data_size == 0 || result.data_size > data.length) {
            return result;
        }

        Logger.t(TAG).d("fromBinary version: " + result.version);

        try {
            if (result.version >= 5) {
                // new struct
                parseNewDmsData(result, stream);
            } else {
                // old struct
                parseOldDmsData(result, stream);
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("fromBinary exception: " + ex.getMessage() + "    " + data);
        }

        return result;
    }

    private static void parseOldDmsData(DmsData result, ByteStream stream) {
        result.output.operationMode = stream.readInt32(); // 1   6
        result.output.calibrationResults = stream.readInt32(); // 0   2
        result.output.isDriverValid = stream.readUint32(); // 1

        if (result.output.operationMode > 2
                || result.output.calibrationResults > 4
                || result.output.isDriverValid != 1) {
            return;
        }

        try {
            result.output.rect.xc = stream.readFloat(); // 661.3778
            result.output.rect.yc = stream.readFloat(); // 623.87897
            result.output.rect.width = stream.readFloat(); // 571.0058
            result.output.rect.height = stream.readFloat(); // 571.0058
            result.output.rect.angle = stream.readFloat(); // 0.059570312
        } catch (Exception e) {
            Logger.t(TAG).e("fromBinary exception: " + e.getMessage());
        }
    }

    private static void parseNewDmsData(DmsData result, ByteStream stream) {
        Logger.t(TAG).i("parseNewDmsData level: " + result.level);
        if (result.level == 1) {
            long l1output_size = stream.readUint32();
            Logger.t(TAG).i("parseNewDmsData l1output_size: " + l1output_size);
            if (l1output_size != 0) {
                result.l1Output = parseL1Output(result, stream);
            }

            if (result.flags == EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
                long person_size = stream.readUint32();
                Logger.t(TAG).i("parseNewDmsData person_size: " + person_size);
                if (person_size != 0) {
                    result.person_info = parseFaceInfo(stream);
                }
            }
        } else if (result.level == 2) {
            long l2output_size = stream.readUint32();
            Logger.t(TAG).i("parseNewDmsData l2output_size: " + l2output_size);
            if (l2output_size != 0) {
                result.l2Output = parseL2Output(stream);
            }
        } else if (result.level == DMS_DATA_LEVEL) {
            // eyesight_l2output_list_t l2output_list
            //	uint32_t num_l2output;
            //	struct L2Output l2output[num_l2output];
            long num_l2output = stream.readUint32();
            Logger.t(TAG).i("parseNewDmsData num_l2output: " + num_l2output);
            if (num_l2output != 0) {
                L2Output[] l2Outputs = new L2Output[(int) num_l2output];
                for (int i = 0; i < num_l2output; i++) {
                    l2Outputs[i] = parseL2Output(stream);
                    Logger.t(TAG).i("parseNewDmsData parseL2Output i: " + i + "  " + l2Outputs[i]);
                }
                result.l2Outputs = l2Outputs;
            }
        }
    }

    private static L1Output parseL1Output(DmsData result, ByteStream stream) {
        L1Output l1Output = new L1Output();

        l1Output.frameNum = stream.readInt32();
        l1Output.engineState = stream.readInt32();
        if (result.version == 8) l1Output.fuSaViolation = stream.readInt32();

        l1Output.cameraCalibration = parseCameraCalibrationStruct(stream);

        l1Output.isDriverValid = stream.readUint32();
        if (result.version >= 9) l1Output.isFaceValid = stream.readUint32();

        l1Output.headRect = parseRectStruct(stream);

        l1Output.isFaceReal = stream.readInt32();
        l1Output.eyesOnRoad = stream.readInt32();
        l1Output.headOnRoad = stream.readInt32();
        l1Output.hasGlasses = stream.readInt32();
        l1Output.hasMask = stream.readInt32();
        l1Output.isDayDreaming = stream.readInt32();
        l1Output.isWearingSeatbelt = stream.readInt32();
        l1Output.isUsingCellphone = stream.readInt32();
        l1Output.isSmoking = stream.readInt32();
        l1Output.isEating = stream.readInt32();
        l1Output.isDrinking = stream.readInt32();
        l1Output.isYawning = stream.readInt32();

        l1Output.nYawnCount = parseNumericIntStruct(stream);

        l1Output.headGesture = stream.readInt32();
        l1Output.frameState = stream.readInt32();
        l1Output.cameraStatus = stream.readInt32();

        if (result.version >= 9) l1Output.nLedValidMask = stream.readUInt8();

        l1Output.faceCameraCoordinatesSystem = parseFaceOutputStruct(stream, result.version);
        l1Output.faceVehicleCoordinatesSystem = parseFaceOutputStruct(stream, result.version);

        l1Output.drowsiness = stream.readInt32();
        if (result.version >= 9) {
            l1Output.nDrowsinessConfidence = stream.readInt16();
        } else {
            l1Output.nDrowsinessConfidence = stream.readUInt8();
        }
        l1Output.distraction = stream.readInt32();
        if (result.version >= 9) {
            l1Output.nDistractionConfidence = stream.readInt16();
        } else {
            l1Output.nDistractionConfidence = stream.readUInt8();
        }

        l1Output.blinkDuration = parseNumericIntStruct(stream);
        if (result.version >= 9) {
            l1Output.blinkRateInt = parseNumericIntStruct(stream);
        } else {
            l1Output.blinkRateFloat = parseNumericFloatStruct(stream);
        }

        l1Output.eyeMode = stream.readInt32();

        l1Output.fixationLength = parseNumericIntStruct(stream);

        l1Output.aoi = parseAOIStruct(stream);

        l1Output.personId = parseNumericIntStruct(stream);

        if (result.version >= 9) {
            l1Output.personIdMatches = parseNumericIntStruct(stream);
        } else {
            l1Output.personIdState = stream.readInt32();
        }
        l1Output.expression = stream.readInt32();
        l1Output.isLimitedPerformance = stream.readUint32();

        // might to be == 7
        if (result.version >= 7) {
            l1Output.distractionLevel = parseNumericFloatStruct(stream);
            l1Output.drowsinessLevel = parseNumericFloatStruct(stream);
        }

        if (result.version >= 9) {
            l1Output.timeOnRoad = parseNumericFloatStruct(stream);
            l1Output.timeOffRoad = parseNumericFloatStruct(stream);
            l1Output.cumulativeTimeOffRoad = parseNumericFloatStruct(stream);
        }

        Logger.t(TAG).i("parseL1Output: " + l1Output);
        return l1Output;
    }

    private static L2Output parseL2Output(ByteStream stream) {
        L2Output l2Output = new L2Output();
        l2Output.l2Event = stream.readInt32();
        l2Output.eventVal = stream.readInt32();
        l2Output.prevEventVal = stream.readInt32();
        l2Output.last = stream.readUint32();
        Logger.t(TAG).i("parseL2Output: " + l2Output);
        return l2Output;
    }

    private static FaceList.FaceItem parseFaceInfo(ByteStream stream) {
        FaceList.FaceItem faceItem = new FaceList.FaceItem();
        faceItem.faceID = stream.readUInt64();
        faceItem.name = stream.readString();
        faceItem.person_id = stream.readUint32();
        return faceItem;
    }

    private static L1Output.CameraCalibration parseCameraCalibrationStruct(ByteStream stream) {
        L1Output.CameraCalibration struct = new L1Output.CameraCalibration();
        struct.calibrationStatus = stream.readInt32();
        struct.nDetectedPoints = stream.readUint32();
        struct.fReprojectionErr = stream.readFloat();
        Logger.t(TAG).i("parseCameraCalibrationStruct: " + struct);
        return struct;
    }

    private static DmsRect parseRectStruct(ByteStream stream) {
        DmsRect rect = new DmsRect();
        rect.xc = stream.readFloat();
        rect.yc = stream.readFloat();
        rect.width = stream.readFloat();
        rect.height = stream.readFloat();
        rect.angle = stream.readFloat();
        Logger.t(TAG).i("parseRectStruct: " + rect);
        return rect;
    }

    private static L1Output.NumericInt parseNumericIntStruct(ByteStream stream) {
        L1Output.NumericInt numericInt = new L1Output.NumericInt();
        numericInt.valid = stream.readUint32();
        numericInt.val = stream.readInt32();
        return numericInt;
    }

    private static L1Output.FaceOutput parseFaceOutputStruct(ByteStream stream, long version) {
        L1Output.FaceOutput faceOutput = new L1Output.FaceOutput();
        faceOutput.eyeLeft = parseEyeStruct(stream, version);
        faceOutput.eyeRight = parseEyeStruct(stream, version);
        faceOutput.head = parseHeadStruct(stream, version);
        faceOutput.unifiedGaze = parseGazeStruct(stream, version);
        return faceOutput;
    }

    private static L1Output.Eye parseEyeStruct(ByteStream stream, long version) {
        L1Output.Eye eye = new L1Output.Eye();
        eye.valid = stream.readUint32();
        eye.eyeState = stream.readInt32();
        eye.gaze = parseGazeStruct(stream, version);
        eye.position = parseCoordinatesStruct(stream);
        eye.opennessPercent = parseNumericFloatStruct(stream);
        if (version >= 9) {
            eye.opennessPercentConfidence = stream.readInt16();
        } else {
            eye.opennessPercentConfidence = stream.readUInt8();
        }
        eye.opennessMm = parseNumericFloatStruct(stream);
        if (version >= 9) {
            eye.opennessMmConfidence = stream.readInt16();
        } else {
            eye.opennessMmConfidence = stream.readUInt8();
        }
        eye.pupilDilationRatio = parseNumericFloatStruct(stream);
        return eye;
    }

    private static L1Output.Head parseHeadStruct(ByteStream stream, long version) {
        L1Output.Head head = new L1Output.Head();
        head.valid = stream.readUint32();
        head.orientation = parseOrientationStruct(stream);
        if (version >= 9) {
            head.orientationConfidence = stream.readInt16();
        } else {
            head.orientationConfidence = stream.readUInt8();
        }
        head.positionValid = stream.readUint32();
        head.position = parsePoint3dFStruct(stream);
        if (version >= 9) {
            head.positionConfidence = stream.readInt16();
        } else {
            head.positionConfidence = stream.readUInt8();
        }
        return head;
    }

    private static L1Output.Gaze parseGazeStruct(ByteStream stream, long version) {
        L1Output.Gaze gaze = new L1Output.Gaze();
        gaze.valid = stream.readUint32();
        gaze.unitVector = parsePoint3dFStruct(stream);
        gaze.yaw = stream.readFloat();
        gaze.pitch = stream.readFloat();
        if (version >= 9) {
            gaze.confidence = stream.readInt16();
        } else {
            gaze.confidence = stream.readUInt8();
        }
        gaze.originValid = stream.readUint32();
        gaze.origin = parsePoint3dFStruct(stream);
        if (version >= 9) {
            gaze.originConfidence = stream.readInt16();
        } else {
            gaze.originConfidence = stream.readUInt8();
        }
        return gaze;
    }

    private static L1Output.Coordinates parseCoordinatesStruct(ByteStream stream) {
        L1Output.Coordinates coordinates = new L1Output.Coordinates();
        coordinates.valid = stream.readUint32();
        coordinates.val = parsePoint3dFStruct(stream);
        return coordinates;
    }

    private static L1Output.Orientation parseOrientationStruct(ByteStream stream) {
        L1Output.Orientation orientation = new L1Output.Orientation();
        orientation.valid = stream.readUint32();
        orientation.value = parseEulerAnglesStruct(stream);
        return orientation;
    }

    private static L1Output.EulerAngles parseEulerAnglesStruct(ByteStream stream) {
        L1Output.EulerAngles eulerAngles = new L1Output.EulerAngles();
        eulerAngles.yaw = stream.readFloat();
        eulerAngles.pitch = stream.readFloat();
        eulerAngles.roll = stream.readFloat();
        return eulerAngles;
    }

    private static L1Output.NumericFloat parseNumericFloatStruct(ByteStream stream) {
        L1Output.NumericFloat numericFloat = new L1Output.NumericFloat();
        numericFloat.valid = stream.readUint32();
        numericFloat.val = stream.readInt32();
        return numericFloat;
    }

    private static L1Output.AOI parseAOIStruct(ByteStream stream) {
        L1Output.AOI aoi = new L1Output.AOI();
        aoi.valid = stream.readUint32();
        aoi.val = stream.readInt32();
        aoi.intersectionPoint = parsePoint3dFStruct(stream);
        return aoi;
    }

    private static L1Output.Point3dF parsePoint3dFStruct(ByteStream stream) {
        L1Output.Point3dF point3dF = new L1Output.Point3dF();
        point3dF.x = stream.readFloat();
        point3dF.y = stream.readFloat();
        point3dF.z = stream.readFloat();
        return point3dF;
    }

    public static class Output implements Serializable {

        public int operationMode;

        public int calibrationResults;

        public long isDriverValid;

        public final DmsRect rect = new DmsRect();

        // ....

        @Override
        public String toString() {
            return "Output{" +
                    "operationMode=" + operationMode +
                    ", calibrationResults=" + calibrationResults +
                    ", isDriverValid=" + isDriverValid +
                    ", rect=" + rect +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "DmsData{" +
                "version=" + version +
                ", revision=" + revision +
                ", src_width=" + src_width +
                ", src_height=" + src_height +
                ", input_xoff=" + input_xoff +
                ", input_yoff=" + input_yoff +
                ", input_width=" + input_width +
                ", input_height=" + input_height +
                ", dms_width=" + dms_width +
                ", dms_height=" + dms_height +
                ", flags=" + flags +
                ", isDriverValid=" + isDriverValid +
                ", level=" + level +
                ", data_size=" + data_size +
                ", output=" + output +
                ", l1Output=" + l1Output +
                ", l2Output=" + l2Output +
                ", l1Internal=" + l1Internal +
                ", person_info=" + person_info +
                '}';
    }
}
