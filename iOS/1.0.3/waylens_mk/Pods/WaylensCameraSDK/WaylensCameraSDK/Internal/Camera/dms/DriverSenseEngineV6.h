//! \copyright Cipia Vision Ltd.
//! \file DriverSenseEngine.h

#ifndef H__DRIVER_SENSE_ENGINE_V6__
#define H__DRIVER_SENSE_ENGINE_V6__

//#include <memory>
//#include <sstream>

//! Typedef of float32_t as float
using float32_t = float;

//class DriverSense;

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
namespace ds_v6
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
    ds_v6::IdState personIdState{ds_v6::IdState::INIT};             //!< Driver ID state
    Expression expression{Expression::INVALID};               //!< Driver expression
    bool isLimitedPerformance{false};                         //!< Limited Performance mode. System is not in optimal performance operation
};

} // namespace ds

#endif // H__DRIVER_SENSE_ENGINE__
