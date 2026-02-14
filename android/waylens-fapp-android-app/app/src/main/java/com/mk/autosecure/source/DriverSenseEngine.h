//! \copyright Cipia Vision Ltd.
//! \file DriverSenseEngine.h

#ifndef H__DRIVER_SENSE_ENGINE__
#define H__DRIVER_SENSE_ENGINE__

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
    //! \param[in] x - Sets the value to \ref Point3dF::x
    //! \param[in] y - Sets the value to \ref Point3dF::y
    //! \param[in] z - Sets the value to \ref Point3dF::z
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
    //! \param[in] yaw - Sets the value to \ref EulerAngles::yaw
    //! \param[in] pitch - Sets the value to \ref EulerAngles::pitch
    //! \param[in] roll - Sets the value to \ref EulerAngles::roll
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

//! Indicates the engine mode: INIT / DMS / CALIBRATION.
enum class OperationMode : int32_t
{
    INIT,           //!< Initialization mode - before call to start()
    DMS,            //!< DMS operation mode
    LED_VALIDATION, //!< Led validation mode
    CALIBRATION     //!< Calibration mode
};

//! Indicates the camera calibration result
enum class CalibrationResults : int32_t
{
    NA,                   //! No calibration data provided. Calibration results are not applicable.
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
    UNRECOGNIZED,   //!< Status changes from one failure to another, e.g. flip between OVER_EXPOSURE and BLURRED_IMAGE
    DAMAGED_LED     //!< One or more LED bank are damaged. May only be reported if CameraParameters::nControllableLeds is positive
};

//! The state for user enrollment callback when triggering enrollment
enum class EnrollmentState : int32_t
{
    ENROLLED = 0,     //!< User enrollment was completed successfully
    DB_FULL = 1,      //!< Database is full, user was not enrolled
    USER_INVALID = 2, //!< User is not yet valid for enrollment, user was not enrolled
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
    LINEAR,
    LOGARITHMIC
};

//! 3D orientation data structure
//! Angles are relative to a reference coordinate system.\n
//! Orientation is represented in Euler angles in yaw->roll->pitch intrinsic convention. Values are in degrees
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
    Point3dF intersectionPoint; //!< Coordinates of the intersection point between the gaze vector and the active AOI
};

//! Provide head position and pose information.
struct Head
{
    bool valid{false};                      //!< Is data valid
    Orientation orientation;                //!< Head orientation
    Confidence orientationConfidence{100U}; //!< Head pose confidence
    bool positionValid{false};              //!< Is position valid
    Point3dF position;                      //!< Head position in centimeters
    Confidence positionConfidence{100U};    //!< Head position confidence. Only valid if \ref positionValid is true
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
    Confidence originConfidence{100U}; //!< Gaze origin confidence
};

//! Provides data for a single eye
struct Eye
{
    bool valid{false};                          //!< Is data valid
    EyeState state{EyeState::OPEN};             //!< Eye State
    Gaze gaze;                                  //!< Eye gaze data
    Coordinates position;                       //!< Center of the eye 3D position
    NumericFloat opennessPercent;               //!< Eye openness in percent
    Confidence opennessPercentConfidence{100U}; //!< Eye openness (percents) confidence. Only valid if \ref valid is true
    NumericFloat opennessMm;                    //!< Eye openness in millimeters
    Confidence opennessMmConfidence{100U};      //!< Eye openness (milimeters) confidence. Only valid if \ref valid is true
    NumericFloat pupilDilationRatio;            //!< Pupil dilation for in percent
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
    //! Camera's distortion coefficients (only radial distortion is taken into account)
    float32_t distortCoeffs[2] = {0.F, 0.F};
    //!@}

    //!@{@name Camera Pose
    //! [Optional] Rotation and translation of the camera relative to the vehicle coordinate system.
    //! By default the camera is aligned with the vehicle coordinate system

    //! Camera rotation as Euler angles in yaw->roll->pitch intrinsic convention. Values are in degrees
    EulerAngles cameraRotation;
    //! Camera location in centimeters
    Point3dF cameraLocation;
    //!@}

    //!@{@name Camera Control Parameters
    //! [Optional] Configuration of controllable camera parameters.

    //! Minimal exposure time in microseconds
    uint32_t nMinExposureTime{0U};
    //! Maximal exposure time in microseconds
    uint32_t nMaxExposureTime{0U};
    //! Minimal gain
    uint32_t nMinGain{0U};
    //! Maximal gain
    uint32_t nMaxGain{0U};
    //! Gain mode
    CameraGainMode gainMode{CameraGainMode::LINEAR};
    //! Gain step size
    uint32_t nGainStep{0U};
    //! Number of controllabel LEDs (0, 1, or 2)
    uint8_t nControllableLeds{0U};
    //! Time (in frames, i.e. 33ms)
    uint8_t nLedRiseFrames{0U};
    //!< Software auto exposure on/off
    bool bSoftwareAutoExposure{false};
    //!@}
};

//! Camera calibration output
struct CameraCalibration
{
    CalibrationResults calibrationStatus{CalibrationResults::NA}; //!< Camera calibration status
    uint32_t nDetectedPoints{0U};                                 //!< Number of detected key-points
    float32_t fReprojectionErr{0.F};                              //!< Re-projection error of camera pose, in pixels
};

//! Camera control output
struct CameraControl
{
    CameraControl() = default; //!< Default constructor
    //! CameraControl constructor
    //! \param[in] exposureTime - Sets the value to \ref CameraControl::x
    //! \param[in] gain - Sets the value to \ref CameraControl::nGain
    //! \param[in] ledMask - Sets the value to \ref CameraControl::nLedMask
    //! \param[in] autoExposure - Sets the value to \ref CameraControl::bAutoExposure
    constexpr CameraControl(const uint32_t exposureTime, const uint8_t gain, const uint8_t ledMask, const bool autoExposure)
        : nExposureTime(exposureTime)
        , nGain(gain)
        , nLedMask(ledMask)
        , bAutoExposure()
    {
    }
    uint32_t nExposureTime{0U}; //!< Exposure time in microseconds
    uint8_t nGain{0U};          //!< Gain value in multiplies of 1/16
    uint8_t nLedMask{0U};       //!< LED banks status - 0 bit means off, 1 bit means on.
                                //! Only the \ref CameraParameters::nControllableLeds LSB are being used
    bool bAutoExposure{true};   //! Is the hardware supplied autoexposure is enabled
};

//! L1 output structure.
//! This struct is provided by engine for every frame that is processed.
//! It contains the full status of the driver at a given moment.
struct L1Output
{
    int32_t frameNum{-1};                             //!< Frame number which data refers to
    OperationMode engineState{OperationMode::DMS};    //!< DMS/Camera calibration mod
    CameraCalibration calibrationResults;             //!< Camera calibration results
    bool isDriverValid{false};                        //!< Is data valid. If false no information is availabl
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
    faceOutput faceCameraCoordinatesSystem;           //!< User's face in camera coordinates
    faceOutput faceVehicleCoordinatesSystem;          //!< User's face in vehicle coordinates
    DrowsinessState drowsiness{DrowsinessState::UNAVAILABLE}; //!< Driver drowsiness state
    Confidence nDrowsinessConfidence{100U};                   //!< Drowsiness confidence
    DistractionState distraction{DistractionState::INVALID};  //!< Driver distraction state
    Confidence nDistractionConfidence{100U};                  //!< Distraction confidence
    NumericInt blinkDuration;                                 //!< Duration of last blink in frames
    NumericFloat blinkRate;                                   //!< Blink rate in blinks/min
    EyeModeState eyeMode{EyeModeState::INVALID};              //!< Eye mode state
    NumericInt fixationLength;                                //!< Fixation Length in frames
    AOI aoi;                                                  //!< Area of interest
    NumericInt personId;                                      //!< Driver unique ID
    ds::IdState personIdState{ds::IdState::INIT};             //!< Driver ID state
    Expression expression{Expression::INVALID};               //!< Driver expression
    bool isLimitedPerformance{false};                         //!< Limited Performance mode. System is not in optimal performance operation
};

//! Discrete events that the engine can report
enum class l2Event : int32_t
{
    DETECTION,           //!< <b>Detection of user presence:</b> 0: No user, 1: Valid user found
    RECOGNITION,         //!< <b>User has been recognized (either existing or new):</b> User's ID
    FACE_LIVENESS,       //!< <b>Face Liveness:</b> Value is of type \ref TriState
    DROWSINESS,          //!< <b>User's drowsiness:</b> Value is of type \ref DrowsinessState
    AOI_CHANGE,          //!< <b>Change in user's area of interest:</b> ID of the AOI
    DAY_DREAMING,        //!< <b>User is daydreaming:</b> Value is of type \ref TriState
    DISTRACTION,         //!< <b>User's distraction :</b> Value is of type \ref DistractionState
    CAMERA_STATE,        //!< <b>Camera status has changed:</b> Value is of type \ref CameraStatus
    CAMERA_CALIBRATION,  //!< <b>Camera calibration was performed:</b> Value is of type \ref CalibrationResults
    LIMITED_PERFORMANCE, //!< <b>System performance:</b> 0: performance is okay, 1: performance is limited
    SEATBELT,            //!< <b>Seatbelt usage:</b> Value is of type \ref TriState
    PHONE,               //!< <b>Phone usage:</b> Value is of type \ref TriState
    SMOKING,             //!< <b>User is smoking:</b> Value is of type \ref TriState
    YAWN,                //!< <b>User is yawning:</b> Number of yawns in time window
    INVALID              //!< <b>Invalid</b>
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

//! Provides information about the user enrollment process result.
struct EnrollmentOutput
{
    NumericInt personId;                                        //!< Driver ID given after enrollment
    EnrollmentState enrollmentState{EnrollmentState::ENROLLED}; //!< Enrollment state
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
//! This function will be called by the engine if was registered as part of \ref CallbackFunctions. \n
//! L1 Callback is provided for every frame. The L1 callback provide a full status of the driver provided in the l1output parameter.
//! \param[in] l1output                         L1 output
//! \param[in] frameNumber                      Frame number of L1 output
//! \return                                     None
using L1Callback = void (*)(L1Output &l1output, int32_t frameNumber);

//! L2 output callback function type
//!
//! This function will be called by the engine if was registered as part of \ref CallbackFunctions. \n
//! This function is called when a change has been detected. Several calls can be triggered one after
//! the other, each for a different single notification.
//! See the event list at \ref l2Event.
//! \param[in] l2output                         L2 output
//! \param[in] frameNumber                      Frame number of L2 output
//! \return                                     None
using L2Callback = void (*)(L2Output &l2output, int32_t frameNumber);

//! Enrollment callback function type
//!
//! This function will be called by the engine if was registered as part of \ref CallbackFunctions and
//! \ref DriverSenseEngine::startUserEnrollment "startUserEnrollment" was called by the application.
//! \param[in] enrollmentOutput                 Enrollment output
//! \param[in] frameNumber                      Frame number of enrollment output
//! \return                                     None
using EnrollmentCallback = void (*)(EnrollmentOutput &enrollmentOutput, int32_t frameNumber);

//! Enrollment callback function type
//!
//! If it was registered as part of \ref CallbackFunctions, this function will be called by the engine
//! on every change in the required camera parameters.
//! \param[in] cameraControlOutput              Camera control parameters
//! \param[in] frameNumber                      Frame number of enrollment output
//! \return                                     None
using CameraControlCallback = void (*)(const CameraControl &cameraControlOutput, int32_t frameNumber);

//! A struct that encapsulate the different callback functions
struct CallbackFunctions
{
    L1Callback l1Callback{nullptr};                       //!< Function of type \ref L1Callback
    L2Callback l2Callback{nullptr};                       //!< Function of type \ref L2Callback
    ReleaseFrameCallback releaseFrameCallback{nullptr};   //!< Function of type \ref ReleaseFrameCallback
    EnrollmentCallback enrollmentCallback{nullptr};       //!< Function of type \ref EnrollmentCallback
    CameraControlCallback cameraControlCallback{nullptr}; //!< Function of type \ref CameraControlCallback
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
    uint16_t nMaxNumOfIds{20U};                      //!< Maximum number of Ids in database
    bool enableEnrollment{false};                    //!< Enable user enrollment
    bool enableFaceId{true};                         //!< Enable face ID
    bool enableSeatbelt{true};                       //!< Enable seatbelt detection
    bool enableSmoking{false};                       //!< Enable smoking detection
    bool enablePhone{false};                         //!< Enable phone detection
    bool enableExpressions{true};                    //!< Enable expression recognition
    bool enableDistraction{true};                    //!< Enable distraction detection
    bool enableDrowsiness{true};                     //!< Enable drowsiness detection
    bool isLeftHandWheel{true};                      //!< Is driver sitting on left side of the vehicle
    CallbackFunctions callbackFunctions;             //!< Register callback functions
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

    NumericFloat vehicleYawRate;     //!< Vehicle yaw rate in degrees/second
    NumericFloat steeringWheelAngle; //!< Steering wheel angle in degrees. Zero means forward direction.
                                     //!< Positive angle means steering wheel turned clockwise
};

//! IdDatabase error codes
enum IdDatabaseErrorCodes : int32_t
{
    OK = -101,                         //!< Success
    INVALID_HEADER = -102,             //!< Invalid database header
    INCOMPATIBLE_MAJOR_VERSION = -103, //!< Incompatible database major version
    INCOMPATIBLE_MINOR_VERSION = -104  //!< Incompatible database minor version
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

    //! Trigger user enrollment by application.
    //! Triggers enrollment state in the DriverSense. Start only if \ref InputConfig::enableEnrollment is set to true
    //! Must be called after the \ref start() method.
    //! \return                                 None.
    DS_API_CPP void startUserEnrollment();

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
    //! \return                                 Number of users in the database. May return error codes from \ref IdDatabaseErrorCodes
    DS_API_CPP int32_t setUsersDatabase(const char *const p, const uint32_t size);

    //! Get the users data size.
    //! Must be called after the \ref start() method.
    //! \return                                 Size of data. 0 on error.
    DS_API_CPP uint32_t getUsersDatabaseSize() const;

    //! Add user to data.
    //! Must be called after the \ref start() method.
    //! \param[in]    p                         Data to write.
    //! \param[in]    size                      Data size.
    //! \return                                 ID of added user. -1 on fail. May return error codes from \ref IdDatabaseErrorCodes.
    DS_API_CPP int32_t addUser(const char *const p, const uint32_t size);

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
    std::unique_ptr<DriverSense> m_pDriverSense;
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

//! Trigger user enrollment by application.
//! Triggers enrollment state in the DriverSense. Start only if \ref InputConfig::enableEnrollment is set to true
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     None.
DS_API_C void startUserEnrollment(void *const engine);

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
//! \param[in]    size                          Allocated buffer containing users data.
//! \param[in]    p                             Buffer size containing users data.
//! \return                                     Number of users in the database. May return error codes from \ref IdDatabaseErrorCodes
DS_API_C uint32_t setUsersDatabase(void *const engine, const char *const p, const uint32_t size);

//! Get the user data's serialized size.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \return                                     Size of data. 0 on error
DS_API_C int32_t getUsersDatabaseSize(void *const engine);

//! Add user to data.
//! Must be called after the \ref start() method.
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine.
//! \param[in]    p                             Data to write.
//! \param[in]    size                          Data size.
//! \return                                     ID of added user. -1 on fail. May return error codes from \ref IdDatabaseErrorCodes.
DS_API_C int32_t addUser(void *const engine, const char *const p, const uint32_t size);

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
//! \param[in]    engine                        A pointer to Driver Sense class see \ref DriverSenseEngine
//! \param[in]    vertexA                       First vertex of triangle
//! \param[in]    vertexB                       Second vertex of triangle
//! \param[in]    vertexC                       Third vertex of triangle
//! \param[in]    id                            Area of interest index number. Will be used in \ref AOI and in \ref l2Event
//! \param[in]    score                         Area of interest score for attentiveness logic
//! \param[in]    priority                      Area of interest prioritization value
//! \return                                     True on success, false on failure
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
//! \param[in]    face                          Rectangle in frame of driver's face (as provided by the DriverSenseEngine)
//! \param[in]    frameWidth                    Video frame width in pixels
//! \param[in]    frameHeight                   Video frame height in pixels
//! \param[in]    marginPercentage              Margin (in percentage)
//! \return                                     One of the following values:<br>
//!                                             0 = Face is outside the field-of-view of the camera<br>
//!                                             1 = Face is between the margin boundary and frame boundary<br>
//!                                             2 = Face is in the margins boundary (centered in the frame)
DS_API_C uint32_t isFaceInFov(const ds::Rect &face, const uint32_t frameWidth, const uint32_t frameHeight, const uint32_t marginPercentage);
} // namespace ds

#endif // H__DRIVER_SENSE_ENGINE__
