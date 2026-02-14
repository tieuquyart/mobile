
#ifndef H__DRIVER_SENSE_ENGINE__
#define H__DRIVER_SENSE_ENGINE__

//#include <memory>
//#include <sstream>

//! Typedef of float32_t as float
typedef float float32_t;

//Class DriverSense;

#ifdef WIN32
#define DS_API_C extern "C" __declspec(dllexport)
#define DS_API_CPP __declspec(dllexport)
#else
#if defined __GNUC__ && __GNUC__ >= 4
#define DS_API_C __attribute__ ((visibility("default")))
#define DS_API_CPP __attribute__ ((visibility("default")))
#else
#define DS_API_C
#define DS_API_CPP
#endif
#endif

//!
//! \brief ds (Driver Sense) namespace
//!

//namespace ds
//{
//! \struct Point2dF
//! \brief 2D point data structure.
//!
struct Point2dF
{
    float32_t x;                                              //!< X axis value. \n\n The default value is: 0.F
    float32_t y;                                              //!< Y axis value. \n\n The default value is: 0.F
};

//! \struct Point3dF
//! \brief 3D point data structure.
//!
struct Point3dF
{
    float32_t x;                                              //!< X axis (longitudinal) value in centimeters. \n\n The default value is: 0.F
    float32_t y;                                              //!< Y axis (transverse) value in centimeters. \n\n The default value is: 0.F
    float32_t z;                                              //!< Z axis (vertical) value in centimeters. \n\n The default value is: 0.F
};

//! \struct EulerAngles
//! \brief Euler angles data structure.
//!
struct EulerAngles
{

    float32_t yaw;                                            //!< Euler angle yaw (turning right and left) in degrees. Negative value means turning left. \n\n The default value is: 0.F
    float32_t pitch;                                          //!< Euler angle pitch (turning up and down) in degrees. Negative value means tilt down. \n\n The default value is: 0.F
    float32_t roll;                                           //!< Euler angle roll (tilting to the sides) in degrees. Negative value means rotate counterclockwise. \n\n The default value is: 0.F
};

//! \struct Rect
//! \brief Rectangle data structure.
//!
struct DSRect
{
    float32_t xc;                                             //!< X axis value in pixels of the rectangle center within data frame. \n\n The default value is: 0.F
    float32_t yc;                                             //!< Y axis value in pixels of the rectangle center within data frame. \n\n The default value is: 0.F
    float32_t width;                                          //!< Rectangular width in pixels within data frame. \n\n The default value is: 0.F
    float32_t height;                                         //!< Rectangular height in pixels within data frame. \n\n The default value is: 0.F
    float32_t angle;                                          //!< Rectangle rotation positive values is counterclockwise. \n\n The default value is: 0.F
};


//! \enum OperationMode
//! \brief Indicates the engine mode: DMS / calibration.
//!
typedef NS_ENUM(int32_t, OperationMode)
{
    INIT,                                                            //!< Initialization mode - before call to start()
    DMS,                                                             //!< DMS operation mode
    CALIBRATION                                                      //!< Calibration mode
};

typedef NS_ENUM(int32_t, CalibrationResults)
{
    NA,                                                              //! No calibration data provided. Calibration results are not applicable.
    UNCALIBRATED,                                                    //! No successful calibration since system start-up
    CALIBRATED,                                                      //! Last system calibration successful.
    FAILED_PENDING_RETRY,                                            //! Last calibration failed.  Another calibration attempt is pending
    PERMANENT_ERROR                                                  //! Re-calibration failed too many times, no more retries will be attempted.
};

typedef NS_ENUM(int32_t, FrameState)
{
    PROCESSED,                                                       //!< Frame was processed
    DROPPED,                                                          //!< Frame was dropped
};

//! \enum TriState
//! \brief Tri-state enumerator.
//!
typedef NS_ENUM(int32_t, TriState)
{
    UNKNOWN,                                                         //!< Value is unknown or cannot be determined
    No,                                                              //!< No (false)
    Yes,                                                              //!< Yes (true)
};

//! \enum CameraStatus
//! \brief Camera status.
//!
typedef NS_ENUM(int32_t, CameraStatus)
{
    WORKING,                                                         //!< Camera is working
    CAMERA_FAILURE,                                                  //!< Camera is outputting black or frozen image
    OVER_EXPOSURE,                                                   //!< Overexposed image with flashes caused by LEDs, occlusion, sun lighting, etc.
    DARK_IMAGE,                                                      //!< LEDs are damaged, or camera is fully occluded
    BLURRED_IMAGE,                                                   //!< Image blurring caused by dirty lens or unfocused or partial occlusion of camera
    UNRECOGNIZED                                                     //!< Status changes from one failure to another, e.g. flip between OVER_EXPOSURE and BLURRED_IMAGE
};

//! \enum EnrollmentState
//! \brief The state for user enrollment callback when triggering enrollment
//!
typedef NS_ENUM(int32_t, EnrollmentState)
{
    ENROLLED = 0,                                                    //!< User enrollment was completed successfully
    DB_FULL = 1,                                                     //!< Database is full, user was not enrolled
    USER_INVALID = 2,                                                //!< User is not yet valid for enrollment, user was not enrolled
    ENROLLING = 3,                                                   //!< User is during enrollment, which not done yet
    DB_UPDATED = 4                                                   //!< The internal user database has been updated.
};

typedef NS_ENUM(int32_t, Expression)
    {
        INVALID = -1,                                                    //!< Not a recognized expression
        NEUTRAL = 0,                                                     //!< Neutral expression
        HAPPY = 1,                                                       //!< Happy expression
        ANGRY = 2,                                                       //!< Angry expression
        SAD = 3                                                          //!< Sad expression        
    };
//! \struct NumericInt
//! \brief Numeric integer structure.
//!
struct NumericInt
{
    bool valid;                                             //!< Is value valid \n\n The default value is: false
    int32_t val;                                                //!< Value. \n\n The default value is: 0
};

//! \struct NumericFloat
//! \brief Numeric float32_t structure.
//!
struct NumericFloat
{
    bool valid;                                             //!< Is value valid. \n\n The default value is: false
    float32_t val;                                            //!< Value. \n\n The default value is: 0.F
};

//! \struct Coordinates
//! \brief coordinates structure.
//!
struct Coordinates
{
    bool valid;                                             //!< Is value valid. \n\n The default value is: false
    struct Point3dF val;                                                    //!< A 3D point, distance, or vector in world coordinates in centimeters
};

//! \enum EyeState
//! \brief Eye state.
//!
typedef NS_ENUM(int32_t, EyeState)
{
    OPEN,                                                             //!< Eye is open
    CLOSED                                                            //!< Eye is closed
};

//! \struct Gaze
//! \brief Provides gaze data
//!
struct Gaze
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    struct Point3dF unitVector;                                             //!< Gaze unit vector
    float32_t yaw;                                            //!< Gaze yaw in degrees. \n\n The default value is: 0.F
    float32_t pitch;                                          //!< Gaze pitch in degrees. \n\n The default value is: 0.F
    bool originValid;                                       //!< Is gaze origin valid? if no, information is not valid \n\n The default value is: false
    struct Point3dF origin;                                                 //!< Gaze origin 3D position data
};

//! \struct Eye_old
//! \brief Provides data for a single eye
//!
struct Eye_old
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    EyeState state;                                //!< Eye State. \n\n The default value is: EyeState::OPEN
    struct Gaze gaze;                                                       //!< Eye gaze data
    struct Coordinates position;                                            //!< Eye 3D position
    struct NumericFloat opennessPercent;                                    //!< Eye openness in percent
    struct NumericFloat opennessMm;                                         //!< Eye openness in milimeters
};

//! \struct Eye
//! \brief Provides data for a single eye
//!
struct Eye
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    EyeState state;                                //!< Eye State. \n\n The default value is: EyeState::OPEN
    struct Gaze gaze;                                                       //!< Eye gaze data
    struct Coordinates position;                                            //!< Eye 3D position
    struct NumericFloat opennessPercent;                                    //!< Eye openness in percent
    struct NumericFloat opennessMm;                                         //!< Eye openness in milimeters
    struct NumericFloat pupilDilationRatio;                                 //!< Pupil dilation for in percent
};

//! \enum DrowsinessState
//! \brief Drowsiness State.
//!
typedef NS_ENUM(int32_t, DrowsinessState)
{
    UNAVAILABLE,                                                     //!< User drowsiness state is not available
    NOTDETECTED,                                                     //!< User is not drowsy
    DROWSY,                                                          //!< User is drowsy
    ASLEEP                                                           //!< User is asleep
};

//! \enum EyeModeState
//! \brief Describe the eye state of the user.
//!
typedef NS_ENUM(int32_t, EyeModeState)
{
    INVALIDEyeModeState,                                                         //!< User's eye mode is not available
    FIXATION,                                                        //!< User's eye mode is fixated
    SACCADE,                                                         //!< User's eye mode is saccade
    SMOOTH_PURSUIT,                                                   //!< User's eye mode is smooth pursuit
};

//! \enum AttentivenessState
//! \brief Attentiveness State.
//!
typedef NS_ENUM(int32_t, AttentivenessState)
{
    INVALIDAttentivenessState,                                                         //!< User attentiveness state is not available
    ATTENTIVE,                                                       //!< User is attentive
    DISTRACTED,                                                       //!< User is distracted
};

//! \struct Pose
//! \brief Head position data structure
//!
struct Pose
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    struct EulerAngles value;                                               //!< Head pose value
};

//! \struct AOI
//! \brief Area of interest data structure.
//!
struct AOI
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    int32_t val;                                               //!< Area of interest identification number. \n\n The default value is: -1
    struct Point3dF intersectionPoint;                                      //!< Coordinates of intersection point between gaze vector and AOI
};

//! \struct Head
//! \brief Provide head position and pose information.
//!
struct Head
{
    bool valid;                                             //!< Is data valid. \n\n The default value is: false
    struct Pose pose;                                                       //!< Head orientation
    bool headPositionValid;                                 //!< Is headPosition parameter valid. \n\n The default value is: false
    struct Point3dF headPosition;                                           //!< Head 3D position data
};

//! \struct faceOutput_old
//! \brief Aggregates information about the user's head and eyes.
//!
struct faceOutput_old
{
    struct Eye_old eyeLeft;                                                     //!< Left eye information
    struct Eye_old eyeRight;                                                    //!< Right eye information
    struct Head head;                                                       //!< Head information
    struct Gaze unifiedGaze;                                                //!< Unified gaze information
};

//! \struct faceOutput
//! \brief Aggregates information about the user's head and eyes.
//!
struct faceOutput
{
    struct Eye eyeLeft;                                                     //!< Left eye information
    struct Eye eyeRight;                                                    //!< Right eye information
    struct Head head;                                                       //!< Head information
    struct Gaze unifiedGaze;                                                //!< Unified gaze information
};

//! \struct CameraParameters
//! \brief Camera parameters structure.
//!
struct CameraParameters
{
    struct Point2dF fFocalLength;                                           //!< Focal length in pixels. X - horizontal; Y - vertical
    struct Point2dF fPrincipalPoint;                                        //!< Camera's principal point in pixels. X - horizontal; Y - vertical
    float32_t fDistortCoeffs[2];                      //!< Camera's distortion coefficients (only radial distortion is taken into account)
    struct EulerAngles fCameraRotation;                                     //!< An optional secondary coordinate system: Euler angles of the camera versus secondary coordinate
    //TODO * @image html CameraRotation.png "Camera rotation"
    struct Point3dF fCameraLocation;                                        //!< An optional secondary coordinate system: 3D location of the camera versus secondary coordinate system
    //TODO * @image html CameraLocation.png "Camera location"
};

//! \struct CameraCalibration
//! \brief Camera calibration outputs structure.
//!
struct CameraCalibration
{
    CalibrationResults calibrationStatus;  //!< Camera calibration status \n\n The default value is: CalibrationResults::NA
    uint32_t nDetectedPoints;                                  //!< Number of detected key-points \n\n The default is: 0
    float32_t fReprojectionErr;                               //!< Re-projection error of camera pose, in pixels \n\n The default is: 0
};

//! \struct L1Output_Old
//! \brief L1 output structure.
//!
struct L1Output_1_1
{
    bool isDriverValid;                                     //!< Is data valid. If false no information is available \n\n The default value is: false
    struct DSRect headRect;                                                   //!< Head Location in frame (in pixels)
    TriState isFaceReal;                        //!< Is the driver real (YES) or fake (NO). \n\n The default value is: TriState::UNKNOWN
    TriState eyesOnRoad;                        //!< Are the driver eyes on the road. \n\n The default value is: TriState::UNKNOWN
    TriState hasGlasses;                        //!< Is driver wearing eyeglasses. \n\n The default value is: TriState::UNKNOWN
    TriState isDayDreaming;                     //!< User is daydreaming. \n\n The default value is: TriState::UNKNOWN
    TriState isWearingSeatbelt;                 //!< Is the driver wearing a seatbelt correctly. \n\n The default value is: TriState::UNKNOWN
    TriState isUsingCellphone;                  //!< Is the driver using cellphone. \n\n The default value is: TriState::UNKNOWN
    TriState isSmoking;                         //!< Is the driver smoking. \n\n The default value is: TriState::UNKNOWN
    TriState isYawning;                         //!< Is the driver yawning. \n\n The default value is: TriState::UNKNOWN
    struct NumericInt nYawnCount;                                           //!< Number of yawns in last N minutes.

    int32_t frameNum;                                          //!< Frame number which data refers to. \n\n The default value is: -1

    FrameState frameState;                    //!< State of frame. \n\n The default value is: FrameState::DROPPED
    CameraStatus cameraStatus;                 //!< Status of camera, checked once in a few minutes; assuming initially that camera works. \n\n The default value is: CameraStatus::WORKING
    struct faceOutput_old faceCameraCoordinatesSystem;                          //!< User's face in camera coordinates
    struct faceOutput_old faceWorldCoordinatesSystem;                           //!< User's face in world coordinates

    DrowsinessState drowsiness;          //!< How drowsy is the driver. \n\n The default value is: DrowsinessState::INVALID
    AttentivenessState attentiveness; //!< How attentive is the driver. \n\n The default value is: AttentivenessState::INVALID

    struct NumericInt blinkDuration;                                        //!< Duration in milliseconds of last blink
    struct NumericFloat blinkRate;                                          //!< Blink rate in blinks/min

    EyeModeState eyeMode;                   //!< Eye mode state. \n\n The default value is: EyeModeState::INVALID
    struct NumericInt fixationLength;                                       //!< Fixation Length in number of frames

    struct AOI aoi;                                                         //!< Area of interest

    struct NumericInt personID;                                             //!< Driver ID number
    struct NumericFloat dilationRatio;                                      //!< Pupil dilation for visible eyes in percent (pupil size divided by iris size)
};
//! \struct L1Output v7.1.2
//! \brief L1 output structure.
//!
struct L1Output_1_3
{
    OperationMode engineState;                 //!< DMS/Camera calibration mode \n\n The default value is: OperationMode::DMS
    bool isDriverValid;                                     //!< Is data valid. If false no information is available \n\n The default value is: false
    struct DSRect headRect;                                                   //!< Head Location in frame (in pixels)
    TriState isFaceReal;                        //!< Is the driver real (YES) or fake (NO). \n\n The default value is: TriState::UNKNOWN
    TriState eyesOnRoad;                        //!< Are the driver eyes on the road. \n\n The default value is: TriState::UNKNOWN
    TriState hasGlasses;                        //!< Is driver wearing eyeglasses. \n\n The default value is: TriState::UNKNOWN
    TriState isDayDreaming;                     //!< User is daydreaming. \n\n The default value is: TriState::UNKNOWN
    TriState isWearingSeatbelt;                 //!< Is the driver wearing a seatbelt correctly. \n\n The default value is: TriState::UNKNOWN
    TriState isUsingCellphone;                  //!< Is the driver using cellphone. \n\n The default value is: TriState::UNKNOWN
    TriState isSmoking;                         //!< Is the driver smoking. \n\n The default value is: TriState::UNKNOWN
    TriState isYawning;                         //!< Is the driver yawning. \n\n The default value is: TriState::UNKNOWN
    struct NumericInt nYawnCount;                                           //!< Number of yawns in last N minutes.

    int32_t frameNum;                                          //!< Frame number which data refers to. \n\n The default value is: -1

    FrameState frameState;                    //!< State of frame. \n\n The default value is: FrameState::DROPPED
    CameraStatus cameraStatus;                 //!< Status of camera, checked once in a few minutes; assuming initially that camera works. \n\n The default value is: CameraStatus::WORKING
    struct faceOutput faceCameraCoordinatesSystem;                          //!< User's face in camera coordinates
    struct faceOutput faceWorldCoordinatesSystem;                           //!< User's face in world coordinates

    DrowsinessState drowsiness;          //!< How drowsy is the driver. \n\n The default value is: DrowsinessState::INVALID
    AttentivenessState attentiveness; //!< How attentive is the driver. \n\n The default value is: AttentivenessState::INVALID

    struct NumericInt blinkDuration;                                        //!< Duration in milliseconds of last blink
    struct NumericFloat blinkRate;                                          //!< Blink rate in blinks/min

    EyeModeState eyeMode;                   //!< Eye mode state. \n\n The default value is: EyeModeState::INVALID
    struct NumericInt fixationLength;                                       //!< Fixation Length in number of frames

    struct AOI aoi;                                                         //!< Area of interest

    struct NumericInt personID;                                             //!< Driver ID number
};

//! \struct L1Output v7.2.10
//! \brief L1 output structure.
//!
struct L1Output_1_4
{
    OperationMode engineState;                 //!< DMS/Camera calibration mode \n\n The default value is: OperationMode::DMS
    CalibrationResults calibrationStatus;
    bool isDriverValid;                                     //!< Is data valid. If false no information is available \n\n The default value is: false
    struct DSRect headRect;                                                   //!< Head Location in frame (in pixels)
    TriState isFaceReal;                        //!< Is the driver real (YES) or fake (NO). \n\n The default value is: TriState::UNKNOWN
    TriState eyesOnRoad;                        //!< Are the driver eyes on the road. \n\n The default value is: TriState::UNKNOWN
    TriState hasGlasses;                        //!< Is driver wearing eyeglasses. \n\n The default value is: TriState::UNKNOWN
    TriState hasMask;
    TriState isDayDreaming;                     //!< User is daydreaming. \n\n The default value is: TriState::UNKNOWN
    TriState isWearingSeatbelt;                 //!< Is the driver wearing a seatbelt correctly. \n\n The default value is: TriState::UNKNOWN
    TriState isUsingCellphone;                  //!< Is the driver using cellphone. \n\n The default value is: TriState::UNKNOWN
    TriState isSmoking;                         //!< Is the driver smoking. \n\n The default value is: TriState::UNKNOWN
    TriState isYawning;                         //!< Is the driver yawning. \n\n The default value is: TriState::UNKNOWN
    struct NumericInt nYawnCount;                                           //!< Number of yawns in last N minutes.

    int32_t frameNum;                                          //!< Frame number which data refers to. \n\n The default value is: -1

    FrameState frameState;                    //!< State of frame. \n\n The default value is: FrameState::DROPPED
    CameraStatus cameraStatus;                 //!< Status of camera, checked once in a few minutes; assuming initially that camera works. \n\n The default value is: CameraStatus::WORKING
    struct faceOutput faceCameraCoordinatesSystem;                          //!< User's face in camera coordinates
    struct faceOutput faceWorldCoordinatesSystem;                           //!< User's face in world coordinates

    DrowsinessState drowsiness;          //!< How drowsy is the driver. \n\n The default value is: DrowsinessState::INVALID
    AttentivenessState attentiveness; //!< How attentive is the driver. \n\n The default value is: AttentivenessState::INVALID

    struct NumericInt blinkDuration;                                        //!< Duration in milliseconds of last blink
    struct NumericFloat blinkRate;                                          //!< Blink rate in blinks/min

    EyeModeState eyeMode;                   //!< Eye mode state. \n\n The default value is: EyeModeState::INVALID
    struct NumericInt fixationLength;                                       //!< Fixation Length in number of frames

    struct AOI aoi;                                                         //!< Area of interest

    struct NumericInt personID;                                             //!< Driver ID number

    Expression expression;                    //!< Driver expression. \n\n The default value is: Expression::INVALID

    bool isLimitedPerformance;   
};

struct L1Output_1_5
{
    OperationMode engineState;                 //!< DMS/Camera calibration mode \n\n The default value is: OperationMode::DMS
    struct CameraCalibration calibrationResults;                            //!< Camera calibration results
    bool isDriverValid;                                     //!< Is data valid. If false no information is available \n\n The default value is: false
    struct DSRect headRect;                                                   //!< Head Location in frame (in pixels)
    TriState isFaceReal;                        //!< Is the driver real (YES) or fake (NO). \n\n The default value is: TriState::UNKNOWN
    TriState eyesOnRoad;                        //!< Are the driver eyes on the road. \n\n The default value is: TriState::UNKNOWN
    TriState hasGlasses;                        //!< Is driver wearing eyeglasses. \n\n The default value is: TriState::UNKNOWN
    TriState hasMask;
    TriState isDayDreaming;                     //!< User is daydreaming. \n\n The default value is: TriState::UNKNOWN
    TriState isWearingSeatbelt;                 //!< Is the driver wearing a seatbelt correctly. \n\n The default value is: TriState::UNKNOWN
    TriState isUsingCellphone;                  //!< Is the driver using cellphone. \n\n The default value is: TriState::UNKNOWN
    TriState isSmoking;                         //!< Is the driver smoking. \n\n The default value is: TriState::UNKNOWN
    TriState isYawning;                         //!< Is the driver yawning. \n\n The default value is: TriState::UNKNOWN
    struct NumericInt nYawnCount;                                           //!< Number of yawns in last N minutes.

    int32_t frameNum;                                          //!< Frame number which data refers to. \n\n The default value is: -1

    FrameState frameState;                    //!< State of frame. \n\n The default value is: FrameState::DROPPED
    CameraStatus cameraStatus;                 //!< Status of camera, checked once in a few minutes; assuming initially that camera works. \n\n The default value is: CameraStatus::WORKING
    struct faceOutput faceCameraCoordinatesSystem;                          //!< User's face in camera coordinates
    struct faceOutput faceWorldCoordinatesSystem;                           //!< User's face in world coordinates

    DrowsinessState drowsiness;          //!< How drowsy is the driver. \n\n The default value is: DrowsinessState::INVALID
    AttentivenessState attentiveness; //!< How attentive is the driver. \n\n The default value is: AttentivenessState::INVALID

    struct NumericInt blinkDuration;                                        //!< Duration in milliseconds of last blink
    struct NumericFloat blinkRate;                                          //!< Blink rate in blinks/min

    EyeModeState eyeMode;                   //!< Eye mode state. \n\n The default value is: EyeModeState::INVALID
    struct NumericInt fixationLength;                                       //!< Fixation Length in number of frames

    struct AOI aoi;                                                         //!< Area of interest

    struct NumericInt personID;                                             //!< Driver ID number

    Expression expression;                    //!< Driver expression. \n\n The default value is: Expression::INVALID

    bool isLimitedPerformance;
};

//! \enum l2Event
//! \brief Discrete events that the engine can report
//!
typedef NS_ENUM(int32_t, l2Event)
{
    DETECTION,                                                       //!< <b>Detection of user presence:</b> 0: No user, 1: Valid user found
    RECOGNITION,                                                     //!< <b>User has been recognized (either existing or new):</b> User's ID
    FACE_LIVENESS,                                                   //!< <b>Face Liveness:</b> Value is of type \ref TriState
    DROWSINESS,                                                      //!< <b>User's drowsiness:</b> Value is of type \ref DrowsinessState
    AOI_CHANGE,                                                      //!< <b>Change in user's area of interest:</b> ID of the AOI
    DAY_DREAMING,                                                    //!< <b>User is daydreaming:</b> Value is of type \ref TriState
    ATTENTIVE_Event,                                                       //!< <b>User's attentiveness:</b> Value is of type \ref AttentivenessState
    CAMERA_STATE,                                                    //!< <b>Camera status has changed:</b> Value is of type \ref CameraStatus
    LIMITED_PERFORMANCE,                                             //!< <b>System performance:</b> 0: performance is okay, 1: performance is limited
    SEATBELT,                                                        //!< <b>Seatbelt usage:</b> Value is of type \ref TriState
    PHONE,                                                           //!< <b>Phone usage:</b> Value is of type \ref TriState
    SMOKING,                                                         //!< <b>User is smoking:</b> Value is of type \ref TriState
    YAWN,                                                            //!< <b>User is yawning:</b> Number of yawns in time window
    INVALIDl2Event,                                                          //!< <b>Invalid</b>
};

//! \struct L2Output
//! \brief L2 output structure.
//!
struct L2Output
{
    l2Event event;                               //!< L2 event name. \n\n The default value is: l2Event::INVALID
    int32_t eventVal;                                          //!< L2 event value. \n\n The default value is: -1
    int32_t prevEventVal;                                      //!< Previous L2 event value. \n\n The default value is: -1
    bool last;                                              //!< Indicates this is the last L2 event for the current frame. \n\n The default value is: false
};

//! \struct EnrollmentCBOutput
//! \brief Provides information about the user enrollment process result.
//!
struct EnrollmentCBOutput
{
    struct NumericInt personID;                                             //!< Driver ID given after enrollment
    EnrollmentState enrollmentState;    //!< Enrollment state. \n\n The default value is: EnrollmentState::ENROLLED
};

//! \enum GearDirection
//! \brief Direction of vehicle gear status
//!
typedef NS_ENUM(int32_t, GearDirection)
{
    FORWARD,                                                         //!< Gear is in drive
    NEUTRAL_Gear,                                                         //!< Gear is in neutral
    REVERSE                                                          //!< Gear is in reverse
};

//! \enum TurnSignal
//! \brief Turn signal indication
//!
typedef NS_ENUM(int32_t, TurnSignal)
{
    LEFT,                                                             //!< Left turn signal
    NONE,                                                             //!< No turn signal
    RIGHT                                                             //!< Right turn signal
};

//! \struct VehicleInfo
//! \brief Real-time vehicle telemetry information
//!
struct VehicleInfo
{
    bool valid;                                             //!< Indicated speed & direction information is valid. \n\n The default value is: false
    uint16_t speed;                                            //!< Vehicle speed in KM/H. \n\n The default value is: 0
    GearDirection direction;               //!< Vehicle moving direction. \n\n The default value is: GearDirection::FORWARD
    TurnSignal turnSignal;                       //!< Turn indicator state. \n\n The default value is: TurnSignal::NONE

    struct NumericFloat vehicleYawRate;                                     //!< Vehicle yaw rate in degrees/second
    struct NumericFloat steeringWheelAngle;                                 //!< Steering wheel angle in degrees. Zero means forward direction.
    //!< Positive angle means steering wheel turned clockwise
};

//! \enum IdDatabaseErrorCodes
//! \brief IdDatabase error codes.
//!
enum IdDatabaseErrorCodes : int32_t
{
    OK = -101,                                                       //!< Success
    INVALID_HEADER = -102,                                           //!< Invalid database header
    INCOMPATIBLE_MAJOR_VERSION = -103,                               //!< Incompatible database major version
    INCOMPATIBLE_MINOR_VERSION = -104                                //!< Incompatible database minor version
};

#endif // H__DRIVER_SENSE_ENGINE__
