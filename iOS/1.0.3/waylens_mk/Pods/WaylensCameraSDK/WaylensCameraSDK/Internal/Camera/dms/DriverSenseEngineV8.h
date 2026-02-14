//! \copyright Cipia Vision Ltd.
//! \file DriverSenseEngine.h

#ifndef H__DRIVER_SENSE_ENGINE_V8__
#define H__DRIVER_SENSE_ENGINE_V8__

//#include <limits>
//#include <memory>
//#include <sstream>

//! Typedef of float32_t as float
using float32_t = float;

//class DriverSense;
//
//#ifdef WIN32
//#define DS_API_C extern "C" __declspec(dllexport)
//#define DS_API_CPP __declspec(dllexport)
//#else
//#if defined __GNUC__ && __GNUC__ >= 4
//#define DS_API_C __attribute__((visibility("default")))
//#define DS_API_CPP __attribute__((visibility("default")))
//#else
//#define DS_API_C
//#define DS_API_CPP
//#endif
//#endif

//! ds (Driver Sense) namespace
namespace ds_v8
{
//! 2D point data structure.
struct Point2dF
{
    float32_t x{0.F}; //!< X axis value
    float32_t y{0.F}; //!< Y axis value
};

//! 3D point data structure.
struct Point3dF
{
    Point3dF() = default; //!< Default constructor
    //! Point3dF constructor
    //! \param[in] x - Sets the value to Point3dF::x
    //! \param[in] y - Sets the value to Point3dF::y
    //! \param[in] z - Sets the value to Point3dF::z
    Point3dF(float32_t x, float32_t y, float32_t z)
        : x(x)
        , y(y)
        , z(z){};
    float32_t x{0.F}; //!< X axis (longitudinal) value in centimeters
    float32_t y{0.F}; //!< Y axis (transverse) value in centimeters
    float32_t z{0.F}; //!< Z axis (vertical) value in centimeters
};

//! Euler angles data structure.
struct EulerAngles
{
    EulerAngles() = default; //!< Default constructor
    //! EulerAngles constructor.
    //! \param[in] yaw - Sets the value to EulerAngles::yaw
    //! \param[in] pitch - Sets the value to EulerAngles::pitch
    //! \param[in] roll - Sets the value to EulerAngles::roll
    EulerAngles(float32_t yaw, float32_t pitch, float32_t roll)
        : yaw(yaw)
        , pitch(pitch)
        , roll(roll){};

    float32_t yaw{0.F};   //!< Euler angle yaw (turning right and left) in degrees. Negative value means turning left
    float32_t pitch{0.F}; //!< Euler angle pitch (turning up and down) in degrees. Negative value means tilt down
    float32_t roll{0.F};  //!< Euler angle roll (tilting to the sides) in degrees. Negative value means rotate counterclockwise
};

//! Rectangle data structure.
struct Rect
{
    float32_t xc{0.F};     //!< X axis value in pixels of the rectangle center within data frame
    float32_t yc{0.F};     //!< Y axis value in pixels of the rectangle center within data frame
    float32_t width{0.F};  //!< Rectangular width in pixels within data frame
    float32_t height{0.F}; //!< Rectangular height in pixels within data frame
    float32_t angle{0.F};  //!< Rectangle rotation positive values is counterclockwise
};

//! Numeric integer structure.
struct NumericInt
{
    bool valid{false}; //!< Is value valid
    int32_t val{0};    //!< Value
};

//! Numeric float32_t structure.
struct NumericFloat
{
    bool valid{false};  //!< Is value valid
    float32_t val{0.F}; //!< Value
};

//! Coordinates structure.
struct Coordinates
{
    bool valid{false}; //!< Is value valid
    Point3dF val;      //!< A 3D point, distance, or vector in centimeters
};

//! Confidence value in the range [0, 100]. 0 - low confidence, 100 - high confidence
using Confidence = uint8_t;

//! Indicates the engine mode. \n
enum class OperationMode : int32_t
{
    INIT,           //!< Initialization mode - before call to start()
    DMS,            //!< DMS operation mode
    LED_VALIDATION, //!< LED validation mode
    CALIBRATION     //!< Calibration mode
};

//! Indicates the camera calibration result. \n
//! This is used when using \ref ds::InputConfig::cameraCalibrationModelPath "cameraCalibrationModelPath".
enum class CalibrationResults : int32_t
{
    NA,                   //! No calibration data provided. Calibration results are not applicable
    UNCALIBRATED,         //! No successful calibration since system start-up
    CALIBRATED,           //! Calibration successful
    FAILED_PENDING_RETRY, //! Calibration failed. Another calibration attempt is pending
    PERMANENT_ERROR       //! Permanent calibration failure; no more retries will be attempted
};

//! Indicates if the frame was processed by the engine or dropped.
enum class FrameState : int32_t
{
    PROCESSED, //!< Frame was processed
    DROPPED    //!< Frame was dropped
};

//! Tri-state enumerator.
enum class TriState : int32_t
{
    UNKNOWN, //!< Value is unknown or cannot be determined
    NO_STATE,      //!< No (false)
    YES_STATE      //!< Yes (true)
};

//! Camera status.
enum class CameraStatus : int32_t
{
    WORKING,        //!< Camera is working
    CAMERA_FAILURE, //!< Camera is outputting black or frozen image
    OVER_EXPOSURE,  //!< Overexposed image with flashes caused by LEDs, occlusion, sun lighting, etc.
    DARK_IMAGE,     //!< LEDs are damaged, or camera is fully occluded
    BLURRED_IMAGE,  //!< Image blurring caused by dirty lens or unfocused or partial occlusion of camera
    UNRECOGNIZED,   //!< Status changes from one failure to another, e.g., flip between OVER_EXPOSURE and BLURRED_IMAGE
    DAMAGED_LED     //!< One or more LED bank are damaged. May be reported only if CameraParameters::nControllableLeds is positive
};

//! The state for user enrollment callback when triggering enrollment
enum class EnrollmentState : int32_t
{
    ENROLLED = 0,     //!< User enrollment was completed successfully
    DB_FULL = 1,      //!< Database is full, user was not enrolled
    USER_INVALID = 2, //!< User is not yet valid for enrollment (not in field of view or head position is not stable)
    ENROLLING = 3,    //!< User is during enrollment, which not done yet
    DB_UPDATED = 4    //!< The internal user database has been updated.
};

//! Driver facial expression
enum class Expression : int32_t
{
    INVALID = -1, //!< Not a recognized expression
    NEUTRAL = 0,  //!< Neutral expression
    HAPPY = 1,    //!< Happy expression
    ANGRY = 2,    //!< Angry expression
    SAD = 3       //!< Sad expression
};

//! Head gestures
enum class HeadGesture : int32_t
{
    NONE,    //!< No gesture detected
    NODDING, //!< Head nodding gesture
    SHAKING  //!< Head shaking gesture
};

//! Eye state
enum class EyeState : int32_t
{
    OPEN,  //!< Eye is open
    CLOSED //!< Eye is closed
};

//! Drowsiness State
enum class DrowsinessState : int32_t
{
    UNAVAILABLE,  //!< User drowsiness state is not available
    NOT_DETECTED, //!< User is not drowsy
    DROWSY,       //!< User is drowsy
    DROWSY_L1,    //!< User is drowsy level 1
    DROWSY_L2,    //!< User is drowsy level 2
    DROWSY_L3,    //!< User is drowsy level 3
    ASLEEP        //!< User is asleep
};

//! Describe the eye state of the user
enum class EyeModeState : int32_t
{
    INVALID,       //!< User's eye mode is not available
    FIXATION,      //!< User's eye mode is fixated
    SACCADE,       //!< User's eye mode is saccade
    SMOOTH_PURSUIT //!< User's eye mode is smooth pursuit
};

//! Distraction State
enum class DistractionState : int32_t
{
    INVALID,      //!< User Distraction state is not available
    NOT_DETECTED, //!< Distraction not detected
    DETECTED,     //!< Distraction detected
    DETECTED_L1,  //!< Distraction level 1 detected
    DETECTED_L2,  //!< Distraction level 2 detected
    DETECTED_L3,  //!< Distraction level 3 detected
    UNRESPONSIVE  //!< Unresponsive state detected
};

//! Person recognition state
enum class IdState
{
    INIT,         //!< Initialization. State was not updated
    UNRECOGNIZED, //!< No ID has been assigned
    UNSURE,       //!< ID is being verified
    RECOGNIZED,   //!< ID assigned
    GUEST,        //!< Person is not in the database
    ENROLLING,    //!< Person is being enrolled
    TIMEOUT       //!< Timeout reached before the system could verify the ID
};

//! Camera gain mode
enum class CameraGainMode : int32_t
{
    LINEAR,     //!< Mode is linear
    LOGARITHMIC //!< Mode is logarithmic
};

//! Functional safety violations
enum class FuSaViolation : int32_t
{
    NONE,      //! No violation detected
    TIMING,    //! A timing violation was detected (recoverable)
    OWNERSHIP, //! Internal buffer ownership violation (non-recoverable)
    BIST       //! Built-in test has failed (non-recoverable)
};

//! 3D orientation data structure
//! Angles are relative to a reference coordinate system.\n
//! Orientation is represented in Euler angles in yaw->roll->pitch intrinsic convention, in degrees
struct Orientation
{
    bool valid{false}; //!< Is data valid
    EulerAngles value; //!< Euler angles
};

//! Area of interest data structure.
struct AOI
{
    bool valid{false};          //!< Is data valid
    int32_t val{-1};            //!< Area of interest identification number
    Point3dF intersectionPoint; //!< Gaze and AOI intersection point in vehicle coordinates system
};

//! Provide head position and pose information.
struct Head
{
    bool valid{false};                      //!< Is data valid
    Orientation orientation;                //!< Head orientation
    Confidence orientationConfidence{100U}; //!< Head pose confidence
    bool positionValid{false};              //!< Is position valid
    Point3dF position;                      //!< Head position in centimeters
    Confidence positionConfidence{100U};    //!< Head position confidence. Valid if Head::positionValid is true
};

//! Provides gaze data
struct Gaze
{
    bool valid{false};                 //!< Is data valid
    Point3dF unitVector;               //!< Gaze unit vector
    float32_t yaw{0.F};                //!< Gaze yaw in degrees
    float32_t pitch{0.F};              //!< Gaze pitch in degrees
    Confidence confidence{100U};       //!< Gaze direction confidence
    bool originValid{false};           //!< Is gaze origin valid
    Point3dF origin;                   //!< Gaze origin 3D position data
    Confidence originConfidence{100U}; //!< Gaze origin confidence. Valid if Gaze::originValid is true
};

//! Provides data for a single eye
struct Eye
{
    bool valid{false};                          //!< Is data valid
    EyeState state{EyeState::OPEN};             //!< Eye State
    Gaze gaze;                                  //!< Eye gaze data
    Coordinates position;                       //!< Center of the eye 3D position
    NumericFloat opennessPercent;               //!< Eye openness in percent
    Confidence opennessPercentConfidence{100U}; //!< Eye openness (percent) confidence. Valid if Eye::valid is true
    NumericFloat opennessMm;                    //!< Eye openness in millimeters
    Confidence opennessMmConfidence{100U};      //!< Eye openness (millimeters) confidence. Valid if Eye::valid is true
    NumericFloat pupilDilationRatio;            //!< Pupil radius divided by iris radius in percent
};

//! Aggregates information about the user's head and eyes.
struct faceOutput
{
    Eye eyeLeft;      //!< Left eye information
    Eye eyeRight;     //!< Right eye information
    Head head;        //!< Head information
    Gaze unifiedGaze; //!< Unified gaze information
};

//! Camera parameters structure
struct CameraParameters
{
    //!@{@name Intrinsic Parameters

    //! Focal length in pixels. X - horizontal; Y - vertical
    Point2dF focalLength;
    //! Camera's principal point in pixels. X - horizontal; Y - vertical
    Point2dF principalPoint;
    //! Camera's distortion coefficients (only radial distortion is considered)
    float32_t distortCoeffs[2] = {0.F, 0.F};
    //!@}

    //!@{@name Camera Pose
    //! [Optional] Rotation and translation of the camera relative to the vehicle coordinate system.
    //! By default, the camera is aligned with the vehicle coordinate system

    //! Camera rotation in vehicle coordinates as Euler angles in yaw->roll->pitch intrinsic convention, in degrees
    EulerAngles cameraRotation;
    //! Camera location in vehicle coordinate system, in centimeters
    Point3dF cameraLocation;
    //!@}

    //!@{@name Camera Control Parameters
    //! [Optional] Configuration of controllable camera parameters.

    //! Minimal exposure time in microseconds
    uint32_t nMinExposureTime{0U};
    //! Maximal exposure time in microseconds
    uint32_t nMaxExposureTime{0U};
    //! Minimal gain
    uint8_t nMinGain{0U};
    //! Maximal gain
    uint8_t nMaxGain{0U};
    //! Recommended gain value
    uint8_t nRecommendedGain{0U};
    //! Gain mode
    CameraGainMode gainMode{CameraGainMode::LINEAR};
    //! Gain step size
    uint32_t nGainStep{0U};
    //! Number of controllabel LEDs banks (0, 1, or 2)
    uint8_t nControllableLeds{0U};
    //! Time in frames from the call to the camera control callback until the LED state is updated
    uint8_t nLedRiseFrames{0U};
    //! Enable software auto exposure
    bool bSoftwareAutoExposure{false};
    //! Multiply autoexposure update by 0.01*this
    uint16_t nAeUpdateGainPrecent{100U};
    //!@}
};

//! Camera calibration output
//! This is used when using \ref ds::InputConfig::cameraCalibrationModelPath "cameraCalibrationModelPath".
struct CameraCalibration
{
    CalibrationResults calibrationStatus{CalibrationResults::NA}; //!< Camera calibration status
    uint32_t nDetectedPoints{0U};                                 //!< Number of detected key-points
    float32_t fReprojectionErr{0.F};                              //!< Re-projection error of camera pose, in pixels
};

//! Camera control output
struct CameraControl
{
    constexpr CameraControl() = default; //!< Default constructor
    //! CameraControl constructor
    //! \param[in] exposureTime - Sets the value to CameraControl::nExposureTime
    //! \param[in] gain - Sets the value to CameraControl::nGain
    //! \param[in] ledMask - Sets the value to CameraControl::nLedMask
    //! \param[in] autoExposure - Sets the value to CameraControl::bAutoExposure
    constexpr CameraControl(const uint32_t exposureTime, const uint8_t gain, const uint8_t ledMask, const bool autoExposure)
        : nExposureTime(exposureTime)
        , nGain(gain)
        , nLedMask(ledMask)
        , bAutoExposure(autoExposure)
    {
    }
    static constexpr uint32_t nGainResolution{16U};           //!< Gain resolution multiply
    static constexpr uint8_t nNoChange{0U};                   //!< Exposure and Gain should not change given that value
    uint32_t nExposureTime{static_cast<uint32_t>(nNoChange)}; //!< Exposure time in microseconds. 0 for no change from current
    uint8_t nGain{nNoChange};                                 //!< Gain value in multiplies of 1/nGainResolution (1/16). 0 for no change from current
    uint8_t nLedMask{0U};                                     //!< Each bit is used for each LED - 0 is off; 1 is on, starting from the LSB
    bool bAutoExposure{false};                                //!< Hardware auto exposure enabled
};

//! L1 output structure.
//! This struct is provided by engine for every frame that is processed.
//! It contains the full status of the driver at a given moment.
struct L1Output
{
    int32_t frameNum{-1};                             //!< Frame number which data refers to
    OperationMode engineState{OperationMode::DMS};    //!< DMS/Camera calibration mod
    FuSaViolation fuSaViolation{FuSaViolation::NONE}; //!< ISO26262 Functional Safety status
    CameraCalibration calibrationResults;             //!< Camera calibration results
    bool isDriverValid{false};                        //!< Is data valid. If false no information is available
    Rect headRect;                                    //!< Head Location in frame (in pixels)
    TriState isFaceReal{TriState::UNKNOWN};           //!< Is the driver real (YES) or fake (NO)
    TriState eyesOnRoad{TriState::UNKNOWN};           //!< Are the driver eyes on the road
    TriState headOnRoad{TriState::UNKNOWN};           //!< Is the driver head pointed at the road
    TriState hasGlasses{TriState::UNKNOWN};           //!< Is driver wearing eyeglasses
    TriState hasMask{TriState::UNKNOWN};              //!< Is driver wearing a mask
    TriState isDayDreaming{TriState::UNKNOWN};        //!< User is daydreaming
    TriState isWearingSeatbelt{TriState::UNKNOWN};    //!< Is the driver wearing a seatbelt correctly
    TriState isUsingCellphone{TriState::UNKNOWN};     //!< Is the driver using cellphone
    TriState isSmoking{TriState::UNKNOWN};            //!< Is the driver smoking
    TriState isEating{TriState::UNKNOWN};             //!< Is the driver eating
    TriState isDrinking{TriState::UNKNOWN};           //!< Is the driver drinking
    TriState isYawning{TriState::UNKNOWN};            //!< Is the driver yawning
    NumericInt nYawnCount;                            //!< Number of yawns in last N minutes.
    HeadGesture headGesture{HeadGesture::NONE};       //!< Driver head gesture
    FrameState frameState{FrameState::DROPPED};       //!< State of frame
    CameraStatus cameraStatus{CameraStatus::WORKING}; //!< Status of camera, checked once in a few minutes; assuming initially that camera works
    uint8_t nLedValidMask{std::numeric_limits<uint8_t>::max()}; //!< Assuming cameraStatus==DAMAGED_LED: Each bit is used for each LED - 0 is invalid;
                                                                //!< 1 is valid, starting from the LSB
    faceOutput faceCameraCoordinatesSystem;                     //!< User's face in camera coordinates
    faceOutput faceVehicleCoordinatesSystem;                    //!< User's face in vehicle coordinates
    DrowsinessState drowsiness{DrowsinessState::UNAVAILABLE};   //!< Driver drowsiness state
    Confidence nDrowsinessConfidence{100U};                     //!< Drowsiness confidence
    DistractionState distraction{DistractionState::INVALID};    //!< Driver distraction state
    Confidence nDistractionConfidence{100U};                    //!< Distraction confidence
    NumericInt blinkDuration;                                   //!< Duration of last blink in frames
    NumericFloat blinkRate;                                     //!< Blink rate in blinks/min
    EyeModeState eyeMode{EyeModeState::INVALID};                //!< Eye mode state
    NumericInt fixationLength;                                  //!< Fixation Length in frames
    AOI aoi;                                                    //!< Area of interest
    NumericInt personId; //!< Driver ID given after enrollment. personID equals 0 means guest i.e., user is not in the database
    ds_v8::IdState personIdState{ds_v8::IdState::INIT}; //!< Driver ID state
    ds_v8::NumericInt personIdMatches;               //!< Number of matches in ID database
    Expression expression{Expression::INVALID};   //!< Driver expression
    bool isLimitedPerformance{false};             //!< Limited Performance mode. System is not in optimal performance operation
    NumericFloat distractionLevel;                //!< Distraction level. Can get values between 0 (fully attentive) to 1 (fully distracted)
    NumericFloat drowsinessLevel;                 //!< Drowsiness level. Can get values between 0 (fully-alert) to 1 (drowsy)
};

} // namespace ds

#endif // H__DRIVER_SENSE_ENGINE__
