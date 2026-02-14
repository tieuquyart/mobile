package com.mkgroup.camera.model.rawdata;

import java.io.Serializable;

/**
 * Created by cloud on 2021/4/15.
 */
public class L2Output implements Serializable {

    /**
     * DETECTION,           //!< <b>Detection of user presence:</b> 0: No user, 1: Valid user found
     * RECOGNITION,         //!< <b>User has been recognized (either existing or new):</b> User's ID
     * FACE_LIVENESS,       //!< <b>Face Liveness:</b> Value is of type \ref TriState
     * DROWSINESS,          //!< <b>User's drowsiness:</b> Value is of type \ref DrowsinessState
     * AOI_CHANGE,          //!< <b>Change in user's area of interest:</b> ID of the AOI
     * DAY_DREAMING,        //!< <b>User is daydreaming:</b> Value is of type \ref TriState
     * DISTRACTION,         //!< <b>User's distraction :</b> Value is of type \ref DistractionState
     * CAMERA_STATE,        //!< <b>Camera status has changed:</b> Value is of type \ref CameraStatus
     * CAMERA_CALIBRATION,  //!< <b>Camera calibration was performed:</b> Value is of type \ref CalibrationResults
     * LIMITED_PERFORMANCE, //!< <b>System performance:</b> 0: performance is okay, 1: performance is limited
     * SEATBELT,            //!< <b>Seatbelt usage:</b> Value is of type \ref TriState
     * PHONE,               //!< <b>Phone usage:</b> Value is of type \ref TriState
     * SMOKING,             //!< <b>User is smoking:</b> Value is of type \ref TriState
     * YAWN,                //!< <b>User is yawning:</b> Number of yawns in time window
     * INVALID              //!< <b>Invalid</b>
     */
    public int l2Event;

    public int eventVal;
    public int prevEventVal;
    public long last;

    @Override
    public String toString() {
        return "L2Output{" +
                "l2Event=" + l2Event +
                ", eventVal=" + eventVal +
                ", prevEventVal=" + prevEventVal +
                ", last=" + last +
                '}';
    }
}
