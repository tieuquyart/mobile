#ifndef __L1_OUTPUT_H__
#define __L1_OUTPUT_H__

#include "DriverSenseEngine.h"

//namespace ds
//{
    //! Const number of eyelids points. \n
    //! Used in \ref Eyelids::upper and \ref Eyelids::lower
    //!
    static const int32_t NUM_OF_EYELID_POINTS_OUT = 36;
    static const int32_t NUM_OF_FACE_LANDMARKS = 68;

    //! \struct Ellipse
    //! @brief Ellipse data structure.
    //!
    struct Ellipse
    {
        float32_t xc;                                //!< Ellipse center, X axis value in pixels within data frame. \n\n The default value is: 0.F
        float32_t yc;                                //!< Ellipse center, Y axis value in pixel within data frame. \n\n The default value is: 0.F
        float32_t width;                             //!< Ellipse width value in pixels within data frame. \n\n The default value is: 0.F
        float32_t height;                            //!< Ellipse height, value in pixels within data frame. \n\n The default value is: 0.F
        float32_t angle;                             //!< The ellipse rotation angle value in degrees, positive values are counter clockwise. \n\n The default value is: 0.F
    };

    //! \struct Eyelids
    //! @brief Eyelids data structure.
    //!
    struct Eyelids
    {
        bool valid;                                //!< Is data valid. \n\n The default value is: false
        struct Point2dF upper[NUM_OF_EYELID_POINTS_OUT];           //!< Upper eyelid points in pixels
        struct Point2dF lower[NUM_OF_EYELID_POINTS_OUT];           //!< Lower eyelid points in pixels
    };

    //! \struct Iris
    //! @brief Iris data structure.
    //!
    struct Iris
    {
        bool valid;                                //!< Is data valid. \n\n The default value is: false
        struct Ellipse border;                                     //!< Iris border details
    };


    //! \struct Pupil
    //! @brief Pupil data structure.
    //!
    struct Pupil
    {
        bool valid;                                //!< Is data valid. \n\n The default value is: false
        struct Point2dF center;                                    //!< Pupil center location in pixels within data frame
        struct Ellipse border;                                     //!< Details about the pupil's border within data frame        
    };

    //! \enum GazeState
    //! @brief Gaze state.
    //!
    typedef NS_ENUM(int32_t, GazeState)
    {
        VALID,                                              //!< Gaze is valid
        ESTIMATED_EXTRAPOLATED                              //!< Gaze is estimated
    };

    //! \struct EyeLandmarks
    //! @brief Eye Landmarks data structure.
    //!
    struct EyeLandmarks
    {
        struct Pupil pupil;                                        //!< Pupil data
        struct Iris iris;                                          //!< Iris data
        struct Eyelids eyelids;                                    //!< Eyelids data
        GazeState state;                //!< Gaze state. \n\n The default value is: GazeState::VALID
    };

    //! \struct HeadBobbingProb
    //! @brief HeadBobbingProb data structure.
    //!
    struct HeadBobbingProb
    {
        struct NumericFloat jumpProbability;
        struct NumericFloat illPoseProbability;
    };

    //! \struct L1Internal
    //! @brief L1 internal structure.
    //!
    struct L1Internal
    {
        // visual attributes
        struct EyeLandmarks leftEyeLandmarks;                      //! Left eye landmarks
        struct EyeLandmarks rightEyeLandmarks;                     //! Right eye landmarks

        struct Point3dF landmarks[NUM_OF_FACE_LANDMARKS];          //!< Face landmarks

        struct NumericInt Perclos;                                 //!< Percentage of closed eyes in TODO XX seconds sliding window

        struct NumericFloat fixationRate;                          //!< Number of fixations per minute
        struct HeadBobbingProb headBobbingProbability;             //!< Head bobbing probability



        bool maxRollForEyelids;                    //!< Head roll is too big to follow eye lids. \n\n The default value is: false

        struct NumericInt mouthOpenness;                           //!< Is Value of mouth openness in mm

        TriState hasMask;              //!< Is driver wearing Mask. \n\n The default value is: TriState::UNKNOWN
        TriState hasOcclusion;         //!< Occlusion detected on driver. \n\n The default value is: TriState::UNKNOWN

        struct NumericFloat leftEyeOpennessInPixels;               //!< Left eye openness is pixel L2 distance
        struct NumericFloat rightEyeOpennessInPixels;              //!< Right eye openness is pixel L2 distance

        struct NumericInt Age;                                     //!< Estimated driver age in years
        struct NumericInt AgeRange;                                //!< Estimated driver age range in years. Range is plus/minus \ref Age (if valid)
        struct NumericInt Gender;                                  //!< User gender. 0 - Male, else - Female

        struct NumericFloat AttentivenessLevel;                    //!< Attentiveness level. 1 - Attentive, 0 - Distracted

        //Expression expression;       //!< Driver expression. \n\n The default value is: Expression::INVALID
    };

    //! \struct L1OutputAll
    //! @brief L1 all output structure encpsulate both \ref ds::L1Output and \ref ds::L1Internal.
    //!
    struct L1OutputAll_1_1
    {
        struct L1Output_1_1 userOutput;
        struct L1Internal internalOutput;
    };
    struct L1OutputAll_1_3
    {
        struct L1Output_1_3 userOutput;
        struct L1Internal internalOutput;
    };
    struct L1OutputAll_1_4
    {
        struct L1Output_1_4 userOutput;
        struct L1Internal internalOutput;
    };
    struct L1OutputAll_1_5
    {
        struct L1Output_1_5 userOutput;
    };

#endif
