//! \copyright Cipia Vision Ltd.
//! \file DriverSenseEngine.h

#ifndef H__DRIVER_SENSE_ENGINE__
#define H__DRIVER_SENSE_ENGINE__

#include <limits>
#include <memory>
#include <sstream>

//! Typedef of float32_t as float
using float32_t = float;

class DriverSense;

#ifdef WIN32
#define DS_API_C extern "C" __declspec(dllexport)
#define DS_API_CPP __declspec(dllexport)
#else
#if defined __GNUC__ && __GNUC__ >= 4
#define DS_API_C __attribute__((visibility("default")))
#define DS_API_CPP __attribute__((visibility("default")))
#else
#define DS_API_C
#define DS_API_CPP
#endif
#endif

//! ds (Driver Sense) namespace
namespace ds
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
struct Coordinates2d
{
    bool valid{false}; //!< Is value valid
    Point2dF val;      //!< A 2D point, image coordinates
};

//! Coordinates structure.
struct Coordinates
{
    bool valid{false}; //!< Is value valid
    Point3dF val;      //!< A 3D point, distance, or vector in centimeters
};

//! Confidence value in the range [0, 100], or -1 for invalid. 0 - low confidence, 100 - high confidence
using Confidence = int16_t;

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
    NO,      //!< No (false)
    YES      //!< Yes (true)
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

//! The state for user ID callback
enum class IdResult : int32_t
{
    INVALID,                 //!< Initial value. The field should be ignored
    FAILURE,                 //!< Unknown error
    DB_FULL,                 //!< Database is full. No option to enroll a new user
    USER_DATA_FULL,          //!< User data is full. No option to add information
    DB_UPDATED,              //!< Database was updated
    ALREADY_ENROLLED,        //!< User is already in the database
    NOT_RECOGNIZED,          //!< User is not in the database
    RECOGNIZED,              //!< User recognized successfully
    USER_ENROLLED,           //!< User was successfully added to the database
    ABORTED,                 //!< The triggered process was aborted
    STATE_CHANGE,            //!< Internal state change. Placeholder - not in use
    TRIGGER_FAILED,          //!< Manual trigger failed
    TRIGGER,                 //!< Manual trigger accepted
    FORCE_RERECOGNITION,     //!< ID reset was triggered
    CONSTRAINTS_CHANGE,      //!< Constraint status was changed. See ds::ConstraintStatus for details
    TIMEOUT,                 //!< Process has reached timeout
    LIMITED_DECISION,        //!< Inconclusive recognition process
    DRIVER_LOST,             //!< Module reset due to driver change. Placeholder - not in use
    DB_MIGRATION_START,      //!< Database migration process started. Main process is on hold.
    DB_MIGRATION_END,        //!< Database migration process ended.
    USER_MIGRATION_FAILED,   //!< User migration process failed.
    USER_MIGRATION_SUCCEEDED //!< User migration process succeeded.
};

//! The status for user ID constraints
enum class ConstraintStatus : int32_t
{
    INVALID,             //!< Initial value. The field should be ignored
    CONSTRAINTS_NONE,    //!< There is no active constraint
    FACE_NOT_DETECTED,   //!< No face was detected
    TOO_MANY_FACES,      //!< More than one face was detected. Placeholder - not functional
    MULTIPLE_ID_MATCHES, //!< More than one match found in the database
    NOT_A_REAL_FACE,     //!< Face spoofing detected
    FACE_OUT_OF_FOV,     //!< Face is partially outside the field of view
    EYES_NOT_VALID,      //!< At least one eye not detected
    CLOSED_EYES,         //!< At least one eye detected as closed
    MOUTH_OPEN,          //!< Open mouth detected
    OUTSIDE_POSE_LIMITS, //!< Head-pose is out of the range defined in ds::InputConfig::idConstraintsConfig
    MASK_DETECTED,       //!< Facial mask detected
    GLASSES_DETECTED,    //!< Eyeglasses detected
    FACE_TOO_SMALL,      //!< Face size is below the minimum required value
    CAMERA_FAILURE       //!< Camera failure detected
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
    UNAVAILABLE = -1,          //!< User drowsiness state is not available
    NOT_DETECTED = 0,          //!< User is not drowsy
    DROWSY = 1,                //!< User is drowsy
    DROWSY_L1 = 2,             //!< User is drowsy level 1
    DROWSY_L2 = 3,             //!< User is drowsy level 2
    DROWSY_L3 = 4,             //!< User is drowsy level 3
    ASLEEP = 5,                //!< User is asleep
    MICROSLEEP = 6,            //!< User is in micro-sleep
    MAX_DROWSINESS_LEVELS = 4, //!< Maximal number of drowsiness levels
};

//! Describe the eye state of the user
enum class EyeModeState : int32_t
{
    INVALID,  //!< User's eye mode is not available
    FIXATION, //!< User's eye mode is fixated
    SACCADE   //!< User's eye mode is saccade
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
enum class IdResultType : int32_t
{
    RECOGNITION,
    ENROLLMENT,
    DB_UPDATE
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
    bool valid{false};                    //!< Is data valid
    Orientation orientation;              //!< Head orientation
    Confidence orientationConfidence{-1}; //!< Head pose confidence
    bool positionValid{false};            //!< Is position valid
    Point3dF position;                    //!< Head position in centimeters
    Confidence positionConfidence{-1};    //!< Head position confidence. Valid if Head::positionValid is true
};

//! Provides gaze data
struct Gaze
{
    bool valid{false};               //!< Is data valid
    Point3dF unitVector;             //!< Gaze unit vector
    float32_t yaw{0.F};              //!< Gaze yaw in degrees
    float32_t pitch{0.F};            //!< Gaze pitch in degrees
    Confidence confidence{-1};       //!< Gaze direction confidence
    bool originValid{false};         //!< Is gaze origin valid
    Point3dF origin;                 //!< Gaze origin 3D position data
    Confidence originConfidence{-1}; //!< Gaze origin confidence. Valid if Gaze::originValid is true
};

//! Provides data for a single eye
struct Eye
{
    bool valid{false};                        //!< Is data valid
    EyeState state{EyeState::OPEN};           //!< Eye State
    Gaze gaze;                                //!< Eye gaze data
    Coordinates position;                     //!< Center of the eye 3D position
    NumericFloat opennessPercent;             //!< Eye openness in percent
    Confidence opennessPercentConfidence{-1}; //!< Eye openness (percent) confidence. Valid if Eye::valid is true
    NumericFloat opennessMm;                  //!< Eye openness in millimeters
    Confidence opennessMmConfidence{-1};      //!< Eye openness (millimeters) confidence. Valid if Eye::valid is true
    NumericFloat pupilDilationRatio;          //!< Pupil radius divided by iris radius in percent
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

//! ID output
struct IdOutput
{
    IdResultType type{IdResultType::RECOGNITION}; //!< Current ID state (TODO: exceptions)
    IdResult result{IdResult::INVALID};           //!< Main output information
    //! Constraint related information. Relevant only when result is on IdResult::CONSTRAINTS_CHANGE
    ConstraintStatus constraintsStatus{ConstraintStatus::INVALID};
    int32_t userId{-1}; //!< Current user ID
};

//! L1 output structure.
//! This struct is provided by engine for every frame that is processed.
//! It contains the full status of the driver at a given moment.
struct L1Output
{
    int32_t nFrameNum{-1};                            //!< Frame number which data refers to
    OperationMode engineState{OperationMode::DMS};    //!< DMS/Camera calibration mod
    FuSaViolation fuSaViolation{FuSaViolation::NONE}; //!< ISO26262 Functional Safety status
    CameraCalibration calibrationResults;             //!< Camera calibration results
    bool isDriverValid{false};                        //!< Is a driver present
    bool isFaceValid{false};                          //!< Is data valid. If false no driver information is available
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
    HeadGesture headGesture{HeadGesture::NONE};       //!< [Placeholder] Driver head gesture
    FrameState frameState{FrameState::DROPPED};       //!< State of frame
    CameraStatus cameraStatus{CameraStatus::WORKING}; //!< Status of camera, checked once in a few minutes; assuming initially that camera works
    uint8_t nLedValidMask{std::numeric_limits<uint8_t>::max()}; //!< Assuming cameraStatus==DAMAGED_LED: Each bit is used for each LED - 0 is invalid;
                                                                //!< 1 is valid, starting from the LSB
    faceOutput faceCameraCoordinatesSystem;                     //!< User's face in camera coordinates
    faceOutput faceVehicleCoordinatesSystem;                    //!< User's face in vehicle coordinates
    DrowsinessState drowsiness{DrowsinessState::UNAVAILABLE};   //!< Driver drowsiness state
    Confidence nDrowsinessConfidence{-1};                       //!< [Placeholder] Drowsiness confidence
    DistractionState distraction{DistractionState::INVALID};    //!< Driver distraction state
    Confidence nDistractionConfidence{-1};                      //!< [Placeholder] Distraction confidence
    NumericInt lastBlinkDuration;                               //!< Duration of last blink in frames
    NumericInt blinkRate;                                       //!< Blink rate in blinks/min
    EyeModeState eyeMode{EyeModeState::INVALID};                //!< Eye mode state
    NumericInt fixationLength;                                  //!< Fixation Length in frames
    AOI aoi;                                                    //!< Area of interest
    NumericInt personId;                        //!< Driver ID given after enrollment. personID equals 0 means guest i.e., user is not in the database
    ds::NumericInt personIdMatches;             //!< Number of matches in ID database
    Expression expression{Expression::INVALID}; //!< Driver expression
    bool isLimitedPerformance{false};           //!< Limited Performance mode. System is not in optimal performance operation
    NumericFloat distractionLevel;              //!< Distraction level. Can get values between 0 (fully attentive) to 1 (fully distracted)
    NumericFloat drowsinessLevel;               //!< Drowsiness level. Can get values between 0 (fully-alert) to 1 (drowsy)
    NumericFloat timeOnRoad;                    //!< Time that the user is continuously looking at the road. (in seconds)
    NumericFloat timeOffRoad;                   //!< Time that the user is continuously looking away from the road. (in seconds)
    NumericFloat cumulativeTimeOffRoad;         //!< Time that the user is looking away from the road over a time-window. (in seconds)
};

//! Discrete events that the engine can report
enum class l2Event : int32_t
{
    DETECTION,           //!< Detection of user presence. Value is the number of detected faces
    RECOGNITION,         //!< User ID has changed. Value is the new ID
    FACE_LIVENESS,       //!< Face Liveness. Value is of type \ref TriState
    DROWSINESS,          //!< User's drowsiness. Value is of type \ref DrowsinessState
    AOI_CHANGE,          //!< Change in user's area of interest. Value is the ID of the AOI, -1 for no-AOI, -2 for unknown
    DISTRACTION,         //!< User's distraction . Value is of type \ref DistractionState
    CAMERA_STATE,        //!< Camera status has changed. Value is of type \ref CameraStatus
    CAMERA_CALIBRATION,  //!< Camera calibration was performed. Value is of type \ref CalibrationResults
    LIMITED_PERFORMANCE, //!< System performance. Value is one of: 0 - performance is okay, 1 - performance is limited
    SEATBELT,            //!< Seatbelt usage. Value is of type \ref TriState
    PHONE,               //!< Phone usage. Value is of type \ref TriState
    SMOKING,             //!< User is smoking. Value is of type \ref TriState
    YAWN,                //!< User is yawning. Value is the number of yawns in time window
    EATING,              //!< User is eating. Value is of type \ref TriState
    DRINKING,            //!< User is drinking. Value is of type \ref TriState
    INVALID              //!< Initial value. Value should not be used
};

//! L2 output structure
//!
//! This struct is provided by engine when an event is detected. \n
//! Multiple events may be detected in a single frame, and they will be reported as separate events. \n
//! The meaning of \b eventVal depends on the event; see \ref l2Event.
struct L2Output
{
    l2Event event{l2Event::INVALID}; //!< L2 event name
    int32_t eventVal{-1};            //!< L2 event value
    int32_t prevEventVal{-1};        //!< Previous L2 event value
    bool last{false};                //!< Indicates this is the last L2 event for the current frame
};

//! Frame releasing callback function type
//!
//! This function will be called by the engine and is mandatory for registration.
//! Once called the frame referenced by \b frameNumber can be released.
//! \param[in] buffer                           Data frame
//! \param[in] frameNumber                      Frame number
//! \return                                     None
using ReleaseFrameCallback = void (*)(uint8_t *buffer, int32_t frameNumber);

//! L1 output callback function type
//!
//! This function will be called by the engine if was registered as part of CallbackFunctions. \n
//! L1 Callback is provided for every frame. The L1 callback provide a full status of the driver provided in the l1output parameter.
//! \param[in] l1output                         L1 output
//! \param[in] frameNumber                      Frame number of L1 output
//! \return                                     None
using L1Callback = void (*)(L1Output &l1output, int32_t frameNumber);

//! L2 output callback function type
//!
//! This function will be called by the engine if was registered as part of CallbackFunctions. \n
//! This function is called when a change has been detected. Several calls can be triggered one after
//! the other, each for a different single notification.
//! See the event list at \ref l2Event.
//! \param[in] l2output                         L2 output
//! \param[in] frameNumber                      Frame number of L2 output
//! \return                                     None
using L2Callback = void (*)(L2Output &l2output, int32_t frameNumber);

//! ID callback function type
//!
//! This function will be called by the engine for every update in recognition and enrollment
//! process.
//! \param[in] idOutput                         Output information of type \ref ds::IdOutput
//! \param[in] frameNumber                      Frame number
//! \return                                     None
using IdCallback = void (*)(const IdOutput &idOutput, int32_t frameNumber);

//! Camera control callback function type
//!
//! If it was registered as part of CallbackFunctions, this function will be called by the engine
//! on every change in the required camera parameters. Must be provided if nControllableLeds > 0U,
//! or software auto exposure is wanted. Pay attention that bAutoExposure cannot be ignored, even
//! if only LED validation is wanted.
//! \param[in] cameraControlOutput              Camera control parameters
//! \param[in] frameNumber                      Frame number of camera control output
//! \return                                     None
using CameraControlCallback = void (*)(const CameraControl &cameraControlOutput, int32_t frameNumber);

//! A struct that encapsulate the different callback functions
struct CallbackFunctions
{
    L1Callback l1Callback{nullptr};                       //!< Function of type \ref L1Callback
    L2Callback l2Callback{nullptr};                       //!< Function of type \ref L2Callback
    ReleaseFrameCallback releaseFrameCallback{nullptr};   //!< Function of type \ref ReleaseFrameCallback
    IdCallback idCallback{nullptr};                       //!< Function of type \ref IdCallback
    CameraControlCallback cameraControlCallback{nullptr}; //!< Function of type \ref CameraControlCallback
};

//! ID constraint
struct IdConstraint
{
    bool bEnabled;     //!< Constraint active
    int32_t nPriority; //!< Priority over other constraints
    int32_t nTimeout;  //!< Number of frames to keep trying
};

//! ID Constraints configuration
struct IdConstraintsConfig
{
    IdConstraintsConfig()
    {
        maxYaw.valid = true;
        maxYaw.val = 65;
        minYaw.valid = true;
        minYaw.val = -65;
        maxPitch.valid = true;
        maxPitch.val = 40;
        minPitch.valid = true;
        minPitch.val = -40;
    }

    IdConstraint notRealFace{true, 10, 1};         //!< Face is not real
    IdConstraint faceNotDetected{true, 30, 1};     //!< Face was not detected
    IdConstraint tooManyFaces{false, 40, 1};       //!< Too many faces were detected
    IdConstraint cameraFailure{true, 50, 1};       //!< Camera error
    IdConstraint faceOutOfFov{true, 80, 1};        //!< Face is close to the frame edges
    IdConstraint openMouth{true, 60, 30};          //!< Mouth is open
    IdConstraint eyesNotValid{true, 70, 30};       //!< Eyes are invalid
    IdConstraint outsidePoseLimits{true, 90, 1};   //!< Head pose outside of limits
    IdConstraint closedEyes{true, 100, 30};        //!< Eyes are closed
    IdConstraint multipleIdMatches{false, 110, 1}; //!< Multiple face ID matches found
    IdConstraint maskDetected{true, 120, 1};       //!< Mask detected
    IdConstraint glassesDetected{false, 130, 1};   //!< Glasses detected
    IdConstraint faceTooSmall{true, 140, 1};       //!< Face is too small
    NumericInt maxYaw;                             //!< Max yaw angle
    NumericInt minYaw;                             //!< Min yaw angle
    NumericInt maxPitch;                           //!< Max pitch angle
    NumericInt minPitch;                           //!< Max pitch angle
};

//! Engine configuration structure
struct InputConfig
{
    CameraParameters cameraParameters;               //!< Camera parameters
    uint16_t nWidth{0U};                             //!< Frame width in pixels
    uint16_t nHeight{0U};                            //!< Frame height in pixels
    uint16_t nFps{30U};                              //!< Number of frames per second
    const char *modelsDir{"./models/"};              //!< Path to the folder where models binary files are
    const char *cameraCalibrationModelPath{nullptr}; //!< Path to the camera calibration data
    uint32_t nLicenseSz{0U};                         //!< If exist, size of license file
    uint8_t *license{nullptr};                       //!< If exist, content of license file
    uint32_t nCertificateSz{0U};                     //!< If exist, size of certificate file
    uint8_t *certificate{nullptr};                   //!< If exist, content of certificate file
    uint32_t cpuAffinityMask{0U};                    //!< CPU affinity mask, each bit represents an available core (applicable for Linux only)
    uint16_t nMaxNumOfIds{20U};                      //!< Maximum number of IDs in database
    bool enableEnrollment{false};                    //!< Enable user enrollment
    bool enableFaceId{true};                         //!< Enable face ID
    bool enableSeatbelt{true};                       //!< Enable seatbelt detection
    bool enableSmoking{false};                       //!< Enable smoking detection
    bool enablePhone{false};                         //!< Enable phone detection
    bool enableExpressions{true};                    //!< Enable expression recognition
    bool enableDistraction{true};                    //!< Enable distraction detection
    bool enableDrowsiness{true};                     //!< Enable drowsiness detection
    bool enableAttributes{true};                     //!< Enable face attributes
    bool enableEatingDrinking{false};                //!< Enable eating & drinking detection
    bool enableDriverPresence{false};                //!< Enable driver present detection
    bool isLeftHandWheel{true};                      //!< Is driver sitting on left side of the vehicle
    CallbackFunctions callbackFunctions;             //!< Register callback functions
    IdConstraintsConfig idConstraintsConfig;         //!< Face ID constraints configuration
};

//! Direction of vehicle gear status
enum class GearDirection : int32_t
{
    FORWARD, //!< Gear is in "Drive"
    NEUTRAL, //!< Gear is in "Neutral"
    REVERSE, //!< Gear is in "Reverse"
    PARKING  //!< Gear is in "Parking"
};

//! Turn signal indication
enum class TurnSignal : int32_t
{
    LEFT, //!< Left turn signal
    NONE, //!< No turn signal
    RIGHT //!< Right turn signal
};

//! Real-time vehicle telemetry information
struct VehicleInfo
{
    bool valid{false};                               //!< Indicated speed & direction information is valid
    uint16_t speed{0U};                              //!< Vehicle speed in KM/H
    GearDirection direction{GearDirection::FORWARD}; //!< Vehicle moving direction
    TurnSignal turnSignal{TurnSignal::NONE};         //!< Turn indicator state

    NumericFloat vehicleYawRate;     //!< Vehicle yaw rate in degrees/second. Zero means forward direction.
                                     //!< Positive angle means the vehicle is turning counterclockwise
    NumericFloat steeringWheelAngle; //!< Steering wheel angle in degrees. Zero means forward direction.
                                     //!< Positive angle means the steering wheel is turning clockwise
};

//! Database functions error codes
enum class IdDatabaseErrorCodes : int32_t
{
    OK,                         //!< Database loading succeeded
    OK_MIGRATION_NEEDED,        //!< Database loading succeeded but a migration to a newer version is in process
    INVALID_HEADER,             //!< Invalid database header
    INCOMPATIBLE_MAJOR_VERSION, //!< Incompatible database major version
    INCOMPATIBLE_MINOR_VERSION, //!< Incompatible database minor version
    INVALID_CHECKSUM,           //!< Invalid database checksum
    FAILURE,                    //!< Unknown error
};

//! Main DriverSense class
class DriverSenseEngine
{
public:
    //! DriverSenseEngine constructor
    //! If the initialized fails (missing license file for ex.) an std::runtime_error is thrown
    //! \param[in]    sInputConfig              Configuration data.
    //! \return                                 A DriverSenseEngine class.
    explicit DS_API_CPP DriverSenseEngine(const InputConfig &sInputConfig);

    //! DriverSenseEngine destructor
    DS_API_CPP ~DriverSenseEngine();

    //! Set a configuration parameter at runtime. \n
    //! For details about available parameters see \ref setparam
    //! \param[in]    param                     Parameter name to be modified.
    //! \param[in]    value                     Value for field (int32_t).
    //! \return                                 True if success, false if fail.
    DS_API_CPP bool setParam(const char *const param, const int32_t value);

    //! Set a configuration parameter at runtime. \n
    //! For details about available parameters see \ref setparam
    //! \param[in]    param                     Parameter name to be modified.
    //! \param[in]    value                     Value for field (float32_t).
    //! \return                                 True if success, false if fail.
    DS_API_CPP bool setParam(const char *const param, const float32_t value);

    //! Set a configuration parameter at runtime. \n
    //! For details about available parameters see \ref setparam
    //! \param[in]    param                     Parameter name to be modified.
    //! \param[in]    value                     Value for field (bool).
    //! \return                                 True if success, false if fail.
    DS_API_CPP bool setParam(const char *const param, const bool value);

    //! Add a triangular area of interest. \n
    //! The vertices are in vehicle coordinates and in centimeters. \n
    //! AOIs must be configured before calling the \ref start() method. \n
    //! Several triangles may have the same ID, so to create more complicated AOIs several triangles can be used. \n
    //! For example, a rectangular AOI can be create by two triangles.
    //! \param[in]    vertexA                   First vertex of triangle
    //! \param[in]    vertexB                   Second vertex of triangle
    //! \param[in]    vertexC                   Third vertex of triangle
    //! \param[in]    id                        Area of interest index number. Will be used in \ref AOI and in \ref l2Event
    //! \param[in]    score                     Number of frames for which the attentiveness on the AOI is valid
    //! \param[in]    priority                  Area of interest priority value
    //! \return                                 True on success, false on failure
    DS_API_CPP bool addAOI(const Point3dF vertexA, const Point3dF vertexB, const Point3dF vertexC, const uint16_t id, const uint32_t score,
                           const int16_t priority);

    //! Start - finish initialization and start processing threads.
    //! Should be called before the first call to processFrame.
    //! \return                                 None.
    DS_API_CPP void start();

    //! Passes a video frame for processing
    //! \param[in]    frameBuffer               Frame buffer.
    //! \param[in]    frameNumber               Frame number counter.
    //! \return                                 None.
    DS_API_CPP void processFrame(uint8_t *const frameBuffer, const int32_t frameNumber);

    //! Passes a video frame for processing with vehicle data. \n
    //! For details about library behavior with vehicle data see \ref vehicleinfo
    //! \param[in]    frameBuffer               Frame buffer.
    //! \param[in]    frameNumber               Frame number counter.
    //! \param[in]    vehicleInfo               Telemetry information from the vehicle
    //! \return                                 None.
    DS_API_CPP void processFrame(uint8_t *const frameBuffer, const int32_t frameNumber, const VehicleInfo &vehicleInfo);

    //! Trigger user ID enrollment.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool triggerUserEnrollment();

    //! Abort active user enrollment.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool abortUserEnrollment();

    //! Trigger user recognition.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool triggerUserRecognition();

    //! Abort active user recognition.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool abortUserRecognition();

    //! Trigger user ID database update.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool triggerUserDbUpdate();

    //! Abort user ID database update.
    //! Must be called after the \ref start() method.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool abortUserDbUpdate();

    //! Delete a user by ID.
    //! Must be called after the \ref start() method.
    //! \param[in]    id                        User ID to delete.
    //! \return                                 True on success, false on failure.
    DS_API_CPP bool deleteUser(const int32_t id);

    //! Delete all users.
    //! Must be called after the \ref start() method.
    //! \return                                 None.
    DS_API_CPP void deleteAllUsers();

    //! Write users' data to allocated memory. Call \ref getUsersDatabaseSize to get data size
    //! Must be called after the \ref start() method.
    //! \param[out]    p                        Allocated buffer to write user's data in.
    //! \return                                 None.
    DS_API_CPP void getUsersDatabase(char *const p) const;

    //! Set users' data from allocated memory.
    //! Must be called after the \ref start() method.
    //! \param[in]    p                         Allocated buffer containing users data.
    //! \param[in]    size                      Buffer size
    //! \param[out]   nNumOfUsers               Number of loaded users.
    //! \return                                 Result of type \ref IdDatabaseErrorCodes
    DS_API_CPP IdDatabaseErrorCodes setUsersDatabase(char *const p, const uint32_t size, int32_t &nNumOfUsers);

    //! Get the users data size.
    //! Must be called after the \ref start() method.
    //! \return                                 Size of data. 0 on error.
    DS_API_CPP uint32_t getUsersDatabaseSize() const;

    //! Add user to data.
    //! Must be called after the \ref start() method.
    //! \param[in]    p                         Data to write.
    //! \param[in]    size                      Data size.
    //! \param[out]   nUserId                   ID of the loaded user.
    //! \return                                 Result of type \ref IdDatabaseErrorCodes
    DS_API_CPP IdDatabaseErrorCodes addUser(char *const p, const uint32_t size, int32_t &nUserId);

    //! Get user from data (by its id) and save it to allocated memory.
    //! \param[in] id                           User's ID number.
    //! \param[out]    p                        Allocated buffer to write user's data in.
    //! \return                                 True if user exists, false if not.
    DS_API_CPP bool getUser(const int32_t id, char *const p) const;

    //! Get a single user's size.
    //! Must be called after the \ref start() method.
    //! \return                                 Size of database. 0 on error.
    DS_API_CPP uint32_t getUserSize() const;

    //! Retrieve engine's string version.
    //! \return                                 Engine version string.
    DS_API_CPP static const char *getVersion();

    //! Retrieve engine's source control info.
    //! \return                                 Engine source control string.
    DS_API_CPP static const char *getSourceInfo();

private:
    std::unique_ptr<DriverSense> m_driverSense;
};

//! Return code value.
enum returnCode : int32_t
{
    SUCCESS = 0,          //!< Success
    INVALID_ARGUMENT = 1, //!< Invalid argument
    INVALID_LICENSE = 2,  //!< Invalid license
    UNKNOWN_ERROR = 3     //!< Unknown error
};

//! Create Drive Sense engine object.
//! \param[in]    sInputConfig                  Configuration data.
//! \param[in]    result                        Return code, value of \ref returnCode
//! \return                                     A pointer to Driver Sense class. On failure returns nullptr.
DS_API_C void *createDriverSenseEngine(const InputConfig &sInputConfig, returnCode &result);

//! Destroy Drive Sense engine object.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     None.
DS_API_C void destroyDriverSenseEngine(void *const engine);

//! Finish initialization and start processing threads. Should be called before the first call to processFrame.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     None.
DS_API_C void start(void *const engine);

//! Passes a video frame for processing.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    frameBuffer                   Frame buffer.
//! \param[in]    frameNumber                   Frame number.
//! \return                                     None.
DS_API_C void processFrame(void *const engine, uint8_t *const frameBuffer, const int32_t frameNumber);

//! Passes a video frame for processing with vehicle data. \n
//! For details about library behavior with vehicle data see \ref vehicleinfo
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    frameBuffer                   Frame buffer.
//! \param[in]    frameNumber                   Frame number.
//! \param[in]    vehicleInfo                   Telemetry information from the vehicle
//! \return                                     None.
DS_API_C void processFrameWithVehicleInfo(void *const engine, uint8_t *const frameBuffer, const int32_t frameNumber, const VehicleInfo &vehicleInfo);

//! Trigger user ID enrollment.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     None.
DS_API_C bool triggerUserEnrollment(void *const engine);

//! Abort active user enrollment.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     True on success, false on failure.
DS_API_C bool abortUserEnrollment(void *const engine);

//! Trigger user recognition.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     True on success, false on failure.
DS_API_C bool triggerUserRecognition(void *const engine);

//! Abort active user recognition.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     True on success, false on failure.
DS_API_C bool abortUserRecognition(void *const engine);

//! Trigger user ID database update.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     True on success, false on failure.
DS_API_C bool triggerUserDbUpdate(void *const engine);

//! Abort user ID database update.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     True on success, false on failure.
DS_API_C bool abortUserDbUpdate(void *const engine);

//! Delete a user from data by ID
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    id                            User ID to delete.
//! \return                                     True on success, false on failure.
DS_API_C bool deleteUser(void *const engine, const int32_t id);

//! Delete all users from data.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     None.
DS_API_C void deleteAllUsers(void *const engine);

//! Write users' data to allocated memory. Call \ref getUsersDatabaseSize to get data size
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[out]   p                             Allocated buffer to write user's data in.
//! \return                                     None.
DS_API_C void getUsersDatabase(void *const engine, char *const p);

//! Get users' data from allocated memory.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    p                             Allocated buffer containing users data.
//! \param[in]    size                          Buffer size containing users data.
//! \param[out]   numOfUsers                    Number of loaded users.
//! \return                                     Result of type \ref IdDatabaseErrorCodes
DS_API_C IdDatabaseErrorCodes setUsersDatabase(void *const engine, char *const p, const uint32_t size, int32_t &numOfUsers);

//! Get the user data's serialized size.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     Size of data. 0 on error
DS_API_C uint32_t getUsersDatabaseSize(void *const engine);

//! Add user to data.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    p                             Data to write.
//! \param[in]    size                          Data size.
//! \param[out]   userId                        ID of the loaded user.
//! \return                                     Result of type \ref IdDatabaseErrorCodes
DS_API_C IdDatabaseErrorCodes addUser(void *const engine, char *const p, const uint32_t size, int32_t &userId);

//! Get user from data (by its id) and save it to allocated memory.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    id                            User's ID number.
//! \param[out]   p                             Allocated buffer to write user's data in.
//! \return                                     True if user exists, false if not.
DS_API_C bool getUser(void *const engine, const int32_t id, char *const p);

//! Set a configuration parameter in runtime
//! \param[in]    engine                       A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    param                        Parameter name to be modified.
//! \param[in]    value                        Value for field (int32_t).
//! \return                                    True if success, false if fail.
DS_API_C bool setParamInt(void *const engine, const char *const param, const int32_t value);

//! Set a configuration parameter in runtime
//! \param[in]    engine                       A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    param                        Parameter name to be modified.
//! \param[in]    value                        Value for field (float32_t).
//! \return                                    True if success, false if fail.
DS_API_C bool setParamFloat(void *const engine, const char *const param, const float32_t value);

//! Set a configuration parameter in runtime
//! \param[in]    engine                       A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    param                        Parameter name to be modified.
//! \param[in]    value                        Value for field (bool).
//! \return                                    True if success, false if fail.
DS_API_C bool setParamBool(void *const engine, const char *const param, const bool value);

//! Add a triangular area of interest. \n
//! The vertices are in vehicle coordinates and in centimeters. \n
//! AOIs must be configured before calling the \ref start() method. \n
//! Several triangles may have the same ID, so to create more complicated AOIs several triangles can be used. \n
//! For example, a rectangular AOI can be create by two triangles.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    vertexA                       First vertex of triangle.
//! \param[in]    vertexB                       Second vertex of triangle.
//! \param[in]    vertexC                       Third vertex of triangle.
//! \param[in]    id                            Area of interest index number. Will be used in \ref AOI and in \ref l2Event.
//! \param[in]    score                         Number of frames for which the attentiveness on the AOI is valid.
//! \param[in]    priority                      Area of interest priority value.
//! \return                                     True on success, false on failure.
DS_API_C bool addAOI(void *const engine, const Point3dF &vertexA, const Point3dF &vertexB, const Point3dF &vertexC, const uint16_t id,
                     const uint32_t score, const int16_t priority);

//! Get a single user's size.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     Size of database. 0 on error.
DS_API_C uint32_t getUserSize(void *const engine);

//! Retrieve engine's string version.
//! \return                                     Engine string version.
DS_API_C const char *getVersion();

//! Retrieve engine's source string version.
//! \return                                     Engine string source.
DS_API_C const char *getSourceInfo();

//! Estimate camera pose in vehicle coordinate system based on an object that is aligned with vehicle coordinates.
//! The same object, usually eye or head in camera FOV, is used for all input values of the function.
//! The output values of the function - cameraRotationVcs & cameraLocationVcs - can be used when initializing the DMS library for \ref
//! CameraParameters::cameraRotation & \ref CameraParameters::cameraLocation respectively.
//! The flow to use the function output:
//! 1. Run DMS library and get the values of the driver pose
//! 2. Use the values from step #1 for the function input
//! 3. Rerun the library using the output from the function
//! \param[in]    objectRotationCcs             Object rotation angles in <b>camera</b> coordinate system.
//! \param[in]    objectLocationCcs             Object coordinates in <b>camera</b> coordinate system.
//! \param[in]    objectLocationVcs             Object coordinates in <b>vehicle</b> coordinate system.
//! \param[out]   cameraRotationVcs             Estimated camera rotation angles in <b>vehicle</b> coordinate system.
//! \param[out]   cameraLocationVcs             Estimated camera coordinates in <b>vehicle</b> coordinate system.
//! \return                                     None.
DS_API_C void estimateCameraPose(const ds::EulerAngles &objectRotationCcs, const ds::Point3dF &objectLocationCcs,
                                 const ds::Point3dF &objectLocationVcs, ds::EulerAngles &cameraRotationVcs, ds::Point3dF &cameraLocationVcs);

//! Support function for in-car installation process. The function calculates if a face (provided via the 'face' argument)
//! is in the field-of-view of the camera. The function provides an indication if part of the face is outside of the
//! field-of-view of the camera (return value 0), or if part of the face is between a 'margin' boundary and the frame boundary (return value 1),
//! or if the face is completely inside the margin boundary (return value 2).
//!
//! \param[in]    face                                                  Rectangle in frame of driver's face (as provided by the DriverSenseEngine)
//! \param[in]    frameWidth                                            Video frame width in pixels
//! \param[in]    frameHeight                                           Video frame height in pixels
//! \param[in]    marginTop, marginRight, marginBottom, marginLeft      Margins as portion of the frame. Will be clipped between 0 and 1.
//! \return                                                             One of the following values:<br>
//!                                                                     0 = Face is outside the field-of-view of the camera<br>
//!                                                                     1 = Face is between the margin boundary and frame boundary<br>
//!                                                                     2 = Face is in the margins boundary (centered in the frame)
DS_API_C int32_t isFaceInFov(const ds::Rect &face, const int32_t frameWidth, const int32_t frameHeight, float32_t marginTop, float32_t marginRight,
                             float32_t marginBottom, float32_t marginLeft);
} // namespace ds

#endif // H__DRIVER_SENSE_ENGINE__
