package com.mkgroup.camera.model.rawdata;

import java.io.Serializable;

/**
 * Created by cloud on 2021/4/15.
 */
public class L1Output implements Serializable {

    public int frameNum;
    public int engineState; // INIT, DMS, LED_VALIDATION, CALIBRATION
    public int fuSaViolation; // NONE
    public CameraCalibration cameraCalibration;
    public long isDriverValid;
    public long isFaceValid;
    public DmsRect headRect;

    // TriState Start (UNKNOWN, NO, YES)
    public int isFaceReal;
    public int eyesOnRoad;
    public int headOnRoad;
    public int hasGlasses;
    public int hasMask;
    public int isDayDreaming;
    public int isWearingSeatbelt;
    public int isUsingCellphone;
    public int isSmoking;
    public int isEating;
    public int isDrinking;
    public int isYawning;
    // TriState End

    public NumericInt nYawnCount;
    public int headGesture; // NONE, NODDING, SHAKING
    public int frameState; // PROCESSED, DROPPED
    // WORKING, CAMERA_FAILURE, OVER_EXPOSURE, DARK_IMAGE, BLURRED_IMAGE, UNRECOGNIZED, DAMAGED_LED
    public int cameraStatus;
    public short nLedValidMask;
    public FaceOutput faceCameraCoordinatesSystem;
    public FaceOutput faceVehicleCoordinatesSystem;
    public int drowsiness; // UNAVAILABLE, NOT_DETECTED, DROWSY, ASLEEP
    public int nDrowsinessConfidence;
    public int distraction; // INVALID, NOT_DETECTED, DETECTED, UNRESPONSIVE
    public int nDistractionConfidence;
    public NumericInt blinkDuration;
    public NumericInt blinkRateInt;
    public NumericFloat blinkRateFloat;
    public int eyeMode; // INVALID, FIXATION, SACCADE, SMOOTH_PURSUIT
    public NumericInt fixationLength;
    public AOI aoi;
    public NumericInt personId;
    public int personIdState; // INIT, UNRECOGNIZED, UNSURE, RECOGNIZED, GUEST, ENROLLING, TIMEOUT
    public NumericInt personIdMatches;
    public int expression; // INVALID, NEUTRAL, HAPPY, ANGRY, SAD
    public long isLimitedPerformance;
    public NumericFloat distractionLevel;
    public NumericFloat drowsinessLevel;
    public NumericFloat timeOnRoad;
    public NumericFloat timeOffRoad;
    public NumericFloat cumulativeTimeOffRoad;

    @Override
    public String toString() {
        return "L1Output{" +
                "frameNum=" + frameNum +
                ", engineState=" + engineState +
                ", fuSaViolation=" + fuSaViolation +
                ", cameraCalibration=" + cameraCalibration +
                ", isDriverValid=" + isDriverValid +
                ", isFaceValid=" + isFaceValid +
                ", headRect=" + headRect +
                ", isFaceReal=" + isFaceReal +
                ", eyesOnRoad=" + eyesOnRoad +
                ", headOnRoad=" + headOnRoad +
                ", hasGlasses=" + hasGlasses +
                ", hasMask=" + hasMask +
                ", isDayDreaming=" + isDayDreaming +
                ", isWearingSeatbelt=" + isWearingSeatbelt +
                ", isUsingCellphone=" + isUsingCellphone +
                ", isSmoking=" + isSmoking +
                ", isEating=" + isEating +
                ", isDrinking=" + isDrinking +
                ", isYawning=" + isYawning +
                ", nYawnCount=" + nYawnCount +
                ", headGesture=" + headGesture +
                ", frameState=" + frameState +
                ", cameraStatus=" + cameraStatus +
                ", nLedValidMask=" + nLedValidMask +
                ", faceCameraCoordinatesSystem=" + faceCameraCoordinatesSystem +
                ", faceVehicleCoordinatesSystem=" + faceVehicleCoordinatesSystem +
                ", drowsiness=" + drowsiness +
                ", nDrowsinessConfidence=" + nDrowsinessConfidence +
                ", distraction=" + distraction +
                ", nDistractionConfidence=" + nDistractionConfidence +
                ", blinkDuration=" + blinkDuration +
                ", blinkRateInt=" + blinkRateInt +
                ", blinkRateFloat=" + blinkRateFloat +
                ", eyeMode=" + eyeMode +
                ", fixationLength=" + fixationLength +
                ", aoi=" + aoi +
                ", personId=" + personId +
                ", personIdState=" + personIdState +
                ", personIdMatches=" + personIdMatches +
                ", expression=" + expression +
                ", isLimitedPerformance=" + isLimitedPerformance +
                ", distractionLevel=" + distractionLevel +
                ", drowsinessLevel=" + drowsinessLevel +
                ", timeOnRoad=" + timeOnRoad +
                ", timeOffRoad=" + timeOffRoad +
                ", cumulativeTimeOffRoad=" + cumulativeTimeOffRoad +
                '}';
    }

    public static class Point2dF implements Serializable {
        public float x;
        public float y;
    }

    public static class Point3dF implements Serializable {
        public float x;
        public float y;
        public float z;

        @Override
        public String toString() {
            return "Point3dF{" +
                    "x=" + x +
                    ", y=" + y +
                    ", z=" + z +
                    '}';
        }
    }

    public static class EulerAngles implements Serializable {
        public float yaw;
        public float pitch;
        public float roll;
    }

    public static class NumericInt implements Serializable {
        public long valid;
        public int val;

        @Override
        public String toString() {
            return "NumericInt{" +
                    "valid=" + valid +
                    ", val=" + val +
                    '}';
        }
    }

    public static class NumericFloat implements Serializable {
        public long valid;
        public float val;

        @Override
        public String toString() {
            return "NumericFloat{" +
                    "valid=" + valid +
                    ", val=" + val +
                    '}';
        }
    }

    public static class Coordinates implements Serializable {
        public long valid;
        public Point3dF val;

        @Override
        public String toString() {
            return "Coordinates{" +
                    "valid=" + valid +
                    ", val=" + val +
                    '}';
        }
    }

    public static class Orientation implements Serializable {
        public long valid;
        public EulerAngles value;

        @Override
        public String toString() {
            return "Orientation{" +
                    "valid=" + valid +
                    ", value=" + value +
                    '}';
        }
    }

    public static class AOI implements Serializable {
        public long valid;
        public int val;
        public Point3dF intersectionPoint;

        @Override
        public String toString() {
            return "AOI{" +
                    "valid=" + valid +
                    ", val=" + val +
                    ", intersectionPoint=" + intersectionPoint +
                    '}';
        }
    }

    public static class Head implements Serializable {
        public long valid;
        public Orientation orientation;
        public int orientationConfidence;
        public long positionValid;
        public Point3dF position;
        public int positionConfidence;

        @Override
        public String toString() {
            return "Head{" +
                    "valid=" + valid +
                    ", orientation=" + orientation +
                    ", orientationConfidence=" + orientationConfidence +
                    ", positionValid=" + positionValid +
                    ", position=" + position +
                    ", positionConfidence=" + positionConfidence +
                    '}';
        }
    }

    public static class Gaze implements Serializable {
        public long valid;
        public Point3dF unitVector;
        public float yaw;
        public float pitch;
        public int confidence;
        public long originValid;
        public Point3dF origin;
        public int originConfidence;

        @Override
        public String toString() {
            return "Gaze{" +
                    "valid=" + valid +
                    ", unitVector=" + unitVector +
                    ", yaw=" + yaw +
                    ", pitch=" + pitch +
                    ", confidence=" + confidence +
                    ", originValid=" + originValid +
                    ", origin=" + origin +
                    ", originConfidence=" + originConfidence +
                    '}';
        }
    }

    public static class Eye implements Serializable {
        public long valid;
        public int eyeState; // OPEN, CLOSED
        public Gaze gaze;
        public Coordinates position;
        public NumericFloat opennessPercent;
        public int opennessPercentConfidence;
        public NumericFloat opennessMm;
        public int opennessMmConfidence;
        public NumericFloat pupilDilationRatio;

        @Override
        public String toString() {
            return "Eye{" +
                    "valid=" + valid +
                    ", eyeState=" + eyeState +
                    ", gaze=" + gaze +
                    ", position=" + position +
                    ", opennessPercent=" + opennessPercent +
                    ", opennessPercentConfidence=" + opennessPercentConfidence +
                    ", opennessMm=" + opennessMm +
                    ", opennessMmConfidence=" + opennessMmConfidence +
                    ", pupilDilationRatio=" + pupilDilationRatio +
                    '}';
        }
    }

    public static class FaceOutput implements Serializable {
        public Eye eyeLeft;
        public Eye eyeRight;
        public Head head;
        public Gaze unifiedGaze;

        @Override
        public String toString() {
            return "FaceOutput{" +
                    "eyeLeft=" + eyeLeft +
                    ", eyeRight=" + eyeRight +
                    ", head=" + head +
                    ", unifiedGaze=" + unifiedGaze +
                    '}';
        }
    }

    public static class CameraParameters implements Serializable {
        public Point2dF focalLength;
        public Point2dF principalPoint;
        public float distortCoeffs;
        public EulerAngles cameraRotation;
        public Point3dF cameraLocation;
        public long nMinExposureTime;
        public long nMaxExposureTime;
        public long nMinGain;
        public long nMaxGain;
        public int gainMode; // LINEAR, LOGARITHMIC
        public long nGainStep;
        public byte nControllableLeds;
        public byte nLedRiseFrames;
        public long bSoftwareAutoExposure;
    }

    public static class CameraCalibration implements Serializable {
        public int calibrationStatus; // NA, UNCALIBRATED, CALIBRATED, FAILED_PENDING_RETRY, PERMANENT_ERROR
        public long nDetectedPoints;
        public float fReprojectionErr;

        @Override
        public String toString() {
            return "CameraCalibration{" +
                    "calibrationStatus=" + calibrationStatus +
                    ", nDetectedPoints=" + nDetectedPoints +
                    ", fReprojectionErr=" + fReprojectionErr +
                    '}';
        }
    }

    public static class CameraControl implements Serializable {
        public long nExposureTime;
        public boolean nGain;
        public boolean nLedMask;
        public long bAutoExposure;
    }
}
