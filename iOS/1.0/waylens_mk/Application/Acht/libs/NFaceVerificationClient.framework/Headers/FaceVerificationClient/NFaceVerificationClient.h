#ifndef N_FACE_VERIFICATION_CLIENT_H_INCLUDED
#define N_FACE_VERIFICATION_CLIENT_H_INCLUDED

#include "NFaceVerificationClientDefs.h"
#include <stdarg.h>

#ifdef N_IOS
#import <CoreGraphics/CGImage.h>
#endif

#ifdef N_CPP
extern "C"
{
#endif
#ifdef N_MSVC
	typedef signed __int32 NResult;
#else
	typedef signed int NResult;
#endif

#ifdef N_MSVC
	typedef unsigned __int8  NUInt8;
	typedef unsigned __int32 NUInt32;
	typedef signed   __int32 NInt32;
#else
	typedef unsigned char  NUInt8;
	typedef unsigned int   NUInt32;
	typedef signed   int   NInt32;
#endif

	typedef NUInt8 NByte;
	typedef NUInt32 NUInt;
	typedef NInt32 NInt;
	typedef NInt NBool;
	typedef float NFloat;

	#define NTrue 1
	#define NFalse 0

	typedef char NAChar;

#if !defined(N_NO_UNICODE) && defined(_WCHAR_T_DEFINED) || defined(_WCHAR_T)
	typedef wchar_t NWChar;
#endif

#ifdef N_UNICODE
	typedef NWChar NChar;
#else
	typedef NAChar NChar;
#endif
#ifndef N_FACE_VERIFICATION_H_INCLUDED
	struct NRect_
	{
		NInt X;
		NInt Y;
		NInt Width;
		NInt Height;
	};

	typedef struct NRect_ NRect;
#endif

	typedef enum NfvcStatus_
	{
		nfvcsNone = 0,
		nfvcsSuccess = 1,
		nfvcsTimeout = 2,
		nfvcsCanceled = 3,
		nfvcsBadQuality = 4,
		nfvcsMatchNotFound = 5,
		nfvcsCameraNotFound = 6,
		nfvcsFaceNotFound = 7,
		nfvcsLivenessCheckFailed = 8,
		nfvcsBadSharpness = 9,
		nfvcsTooNoisy = 10,
		nfvcsBadLighting = 11,
		nfvcsOcclusion = 12,
		nfvcsBadPose = 13,
		nfvcsTooManyObjects = 14,
		nfvcsMaskDetected = 15,
		nfvcsDuplicateFound = 16,
		nfvcsDuplicateId = 17,
		nfvcsMotionBlur = 18,
		nfvcsCompressionArtifacts = 19,
		nfvcsTooFar = 20,
		nfvcsTooClose = 21,
		nfvcsInternalError = 999
	} NfvcStatus;

	typedef enum NfvcLivenessAction_
	{
		nfvclaNone = 0,
		nfvclaKeepStill = 0x000001,
		nfvclaBlink = 0x000002,
		nfvclaRotateYaw = 0x000004,
		nfvclaKeepRotatingYaw = 0x000008,
		nfvclaTurnToCenter = 0x000010,
		nfvclaTurnLeft = 0x000020,
		nfvclaTurnRight = 0x000040,
		nfvclaTurnUp = 0x000080,
		nfvclaTurnDown = 0x000100,
		nfvclaMoveCloser = 0x000200,
		nfvclaMoveBack = 0x000400
	} NfvcLivenessAction;

	typedef enum NfvcLivenessMode_
	{
		nfvclmNone = 0,
		nfvclmPassive = 1,
		nfvclmActive = 2,
		nfvclmPassiveAndActive = 3,
		nfvclmSimple = 4,
		nfvclmCustom = 5,
		nfvclmPassiveWithBlink = 6
	} NfvcLivenessMode;

	typedef enum NfvcIcaoWarnings_
	{
		nfvciwNone = 0,
		nfvciwFaceNotDetected = 1,
		nfvciwRollLeft = 2,
		nfvciwRollRight = 4,
		nfvciwYawLeft = 8,
		nfvciwYawRight = 16,
		nfvciwPitchUp = 32,
		nfvciwPitchDown = 64,
		nfvciwTooNear = 128,
		nfvciwTooFar = 256,
		nfvciwTooNorth = 512,
		nfvciwTooSouth = 1024,
		nfvciwTooEast = 2048,
		nfvciwTooWest = 4096,
		nfvciwSharpness = 8192,
		nfvciwBackgroundUniformity = 16384,
		nfvciwGrayscaleDensity = 32768,
		nfvciwSaturation = 65536,
		nfvciwExpression = 131072,
		nfvciwDarkGlasses = 262144,
		nfvciwBlink = 524288,
		nfvciwMouthOpen = 1048576,
		nfvciwLookingAway = 2097152,
		nfvciwRedEye = 4194304,
		nfvciwFaceDarkness = 8388608,
		nfvciwUnnaturalSkinTone = 16777216,
		nfvciwWashedOut = 33554432,
		nfvciwPixelation = 67108864,
		nfvciwSkinReflection = 134217728,
		nfvciwGlassesReflection = 268435456,
		nfvciwHeavyFrame = 536870912,
	} NfvcIcaoWarnings;

	typedef void * HNfvcVideoFormat;
	typedef void * HNfvcCapturePreview;
	typedef void * HNfvcResult;
#ifndef N_IOS
	typedef void CGImageRef;
#endif

#define NFailed(result) ((result) < 0)
#define NSucceeded(result) ((result) >= 0)

#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_BLINK N_T("blink")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_TURN_LEFT N_T("turnLeft")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_TURN_RIGHT N_T("turnRight")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_TURN_UP N_T("turnUp")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_TURN_DOWN N_T("turnDown")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_TURN_WITH_TARGETS N_T("turnWithTargets")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_KEEP_STILL N_T("keepStill")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_MOVE_CLOSER N_T("moveCloser")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_MOVE_BACK N_T("moveBack")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_EMPTY N_T(" ")
#define N_FACE_VERIFICATION_CLIENT_CUSTOM_ACTION_STRING_SEPARATOR N_T(",")

	typedef NResult (N_CALLBACK NfvcCapturePreviewCallback)(HNfvcCapturePreview eventInfo, void * pParam);

	// init/uninit
	
	NResult N_API NFaceVerificationClientInitialize(NInt applicationId);
	NResult N_API NFaceVerificationClientUninitialize();

	// setters
	NResult N_API NFaceVerificationClientGetNativeRevision(NInt * pValue);
	NResult N_API NFaceVerificationClientGetNativeRevisionString(NChar * * parValue, NInt * pValueLength);
	NResult N_API NFaceVerificationClientGetCheckIcaoCompliance(NBool * pValue);
	NResult N_API NFaceVerificationClientSetCheckIcaoCompliance(NBool value);
	NResult N_API NFaceVerificationClientGetUseManualCapturing(NBool * pValue);
	NResult N_API NFaceVerificationClientSetUseManualCapturing(NBool value);
	NResult N_API NFaceVerificationClientGetTimeout(NInt * pValue);
	NResult N_API NFaceVerificationClientSetTimeout(NInt value);
	NResult N_API NFaceVerificationClientGetQualityThreshold(NByte * pValue);
	NResult N_API NFaceVerificationClientSetQualityThreshold(NByte value);
	NResult N_API NFaceVerificationClientGetMatchingThreshold(NInt * pValue);
	NResult N_API NFaceVerificationClientSetMatchingThreshold(NInt value);
	NResult N_API NFaceVerificationClientGetLivenessThreshold(NByte * pValue);
	NResult N_API NFaceVerificationClientSetLivenessThreshold(NByte value);
	NResult N_API NFaceVerificationClientGetPassiveLivenessSensitivityThreshold(NByte * pValue);
	NResult N_API NFaceVerificationClientSetPassiveLivenessSensitivityThreshold(NByte value);
	NResult N_API NFaceVerificationClientGetPassiveLivenessQualityThreshold(NByte * pValue);
	NResult N_API NFaceVerificationClientSetPassiveLivenessQualityThreshold(NByte value);
	NResult N_API NFaceVerificationClientGetLivenessMode(NfvcLivenessMode * pValue);
	NResult N_API NFaceVerificationClientSetLivenessMode(NfvcLivenessMode value);
	NResult N_API NFaceVerificationClientSetLivenessBlinkTimeout(NInt value);
	NResult N_API NFaceVerificationClientGetLivenessBlinkTimeout(NInt * pValue);
	NResult N_API NFaceVerificationClientGetLivenessCustomActionSequence(NChar * * parValue, NInt * pValueLength);
	NResult N_API NFaceVerificationClientSetLivenessCustomActionSequence(const NChar * arValue, NInt valueLength);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientGetLivenessUseSeparateBlink(NBool * pValue);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientSetLivenessUseSeparateBlink(NBool value);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientGetLivenessSeparateBlinkThreshold(NFloat * pValue);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientSetLivenessSeparateBlinkThreshold(NFloat value);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientGetLivenessSeparateBlinkHysteresis(NFloat * pValue);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientSetLivenessSeparateBlinkHysteresis(NFloat value);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientGetLivenessSeparateBlinkOcclusion(NFloat * pValue);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientSetLivenessSeparateBlinkOcclusion(NFloat value);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientGetLivenessUsePassiveLiveness(NBool * pValue);
	N_DEPRECATED("function is deprecated")
	NResult N_API NFaceVerificationClientSetLivenessUsePassiveLiveness(NBool value);
	NResult N_API NFaceVerificationClientGetIcaoWarningThreshold(NfvcIcaoWarnings warning, NByte * pValue);
	NResult N_API NFaceVerificationClientSetIcaoWarningThreshold(NfvcIcaoWarnings warning, NByte value);
	NResult N_API NFaceVerificationClientGetIcaoWarningFilter(NfvcIcaoWarnings * pValue);
	NResult N_API NFaceVerificationClientSetIcaoWarningFilter(NfvcIcaoWarnings value);
	NResult N_API NFaceVerificationClientGetDisallowMultipleFaces(NBool * pValue);
	NResult N_API NFaceVerificationClientSetDisallowMultipleFaces(NBool value);
	NResult N_API NFaceVerificationClientGetEnrollToMMAbis(NBool * pValue);
	NResult N_API NFaceVerificationClientSetEnrollToMMAbis(NBool value);
	NResult N_API NFaceVerificationClientGetCurrentMMAbisSubjectId(NChar * * parValue, NInt * pValueLength);
	NResult N_API NFaceVerificationClientSetCurrentMMAbisSubjectId(const NChar * arValue, NInt valueLength);

	// camera
	NResult N_API NFaceVerificationClientGetCurrentCamera(NChar * * parCameraName, NInt * pNameLength);
	NResult N_API NFaceVerificationClientSetCurrentCamera(const NChar * arCameraName, NInt nameLength);
	NResult N_API NFaceVerificationClientGetAvailableCameraCount(NInt * pCount);
	NResult N_API NFaceVerificationClientGetAvailableCamera(NInt index, NChar * * parCameraName, NInt * pNameLength);

	// video formats
	NResult N_API NFaceVerificationClientSetCurrentVideoFormat(HNfvcVideoFormat format);
	NResult N_API NFaceVerificationClientGetCurrentVideoFormat(HNfvcVideoFormat * pFormat);
	NResult N_API NFaceVerificationClientGetAvailableVideoFormats(HNfvcVideoFormat * * parhFormats, NInt * pFormatCount);
	NResult N_API NFaceVerificationClientVideoFormatGetWidth(HNfvcVideoFormat format, NUInt * pValue);
	NResult N_API NFaceVerificationClientVideoFormatGetHeight(HNfvcVideoFormat format, NUInt * pValue);
	NResult N_API NFaceVerificationClientVideoFormatGetFrameRate(HNfvcVideoFormat format, NFloat * pValue);
	NResult N_API NFaceVerificationClientVideoFormatGetMediaSubType(HNfvcVideoFormat format, NUInt * pValue);
	NResult N_API NFaceVerificationClientVideoFormatGetMediaSubTypeAsString(HNfvcVideoFormat format, NChar * * parSubType, NInt * pSubTypeLen);

	// operations
	NResult N_API NFaceVerificationClientStartCreateTemplate(void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartCreateTemplateForLegacyMoc(void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartReextractTemplate(const void * arFVTemplateBuffer, NInt fvTemplateBufferLen, void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartReextractTemplateFromImage(const void * arImageBuffer, NInt imageBufferLen, const void * arFVTemplateBuffer, NInt fvTemplateBufferLen, void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartImportNTemplate(const void * arNTemplateBuffer, NInt nTemplateBufferLen, void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartImportOldFVTemplate(const void * arOldFVTemplateBuffer, NInt oldFVemplateBufferLen, void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientStartImportImage(const void * arImageBuffer, NInt imageBufferLen, void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientFinishOperation(const void * arServerKeyBuffer, NInt keyBufferLen, HNfvcResult * pValue);
	NResult N_API NFaceVerificationClientFVTemplateToMOCTemplate(const void * arFVTemplateBuffer, NInt fvTemplateBufferLen, void * * parMOCTemplateBuffer, NInt * pMOCTemplateBufferLen);
	NResult N_API NFaceVerificationClientVerify(const void * arFVTemplateBuffer, NInt fvTemplateBufferLen, HNfvcResult * pValue);
	NResult N_API NFaceVerificationClientVerifyAgainstNTemplate(const void * arFVTemplateBuffer, NInt fvTemplateBufferLen, const void * arNTemplateBuffer, NInt nTemplateBufferLen, HNfvcResult * pValue);
	NResult N_API NFaceVerificationClientStartCheckLiveness(void * * pRegistrationKeyBuffer, NInt * pKeyBufferLen);
	NResult N_API NFaceVerificationClientCancel(void);
	NResult N_API NFaceVerificationClientForce(void);

	// event info
	NResult N_API NFaceVerificationClientCapturePreviewGetStatus(HNfvcCapturePreview capturePreview, NfvcStatus * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetYaw(HNfvcCapturePreview capturePreview, NFloat * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetRoll(HNfvcCapturePreview capturePreview, NFloat * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetPitch(HNfvcCapturePreview capturePreview, NFloat * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetQuality(HNfvcCapturePreview capturePreview, NByte * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetBoundingRect(HNfvcCapturePreview capturePreview, NInt * pX, NInt * pY, NInt * pWidth, NInt * pHeight);
	NResult N_API NFaceVerificationClientCapturePreviewGetLivenessAction(HNfvcCapturePreview capturePreview, NfvcLivenessAction * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetLivenessTargetYaw(HNfvcCapturePreview capturePreview, NFloat * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetLivenessScore(HNfvcCapturePreview capturePreview, NByte * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewGetIcaoWarnings(HNfvcCapturePreview capturePreview, NfvcIcaoWarnings * pValue);
	NResult N_API NFaceVerificationClientCapturePreviewCopyImageToData(HNfvcCapturePreview capturePreview, NInt * pHeight, NInt * pWidth, NInt * pBuffer);
	NResult N_API NFaceVerificationClientCapturePreviewGetCGImageRef(HNfvcCapturePreview capturePreview, CGImageRef * pValue);
	
	// callbacks
	NResult N_API NFaceVerificationClientSetCapturePreviewCallback(NfvcCapturePreviewCallback pCallback, void * pParam);

	// result
	NResult N_API NFaceVerificationClientResultGetTemplate(HNfvcResult result, void * * pTemplateBuffer, NInt * pBufferLen);
	NResult N_API NFaceVerificationClientResultCopyTokenImageToData(HNfvcResult result, NInt * pHeight, NInt * pWidth, NInt * pBuffer);
	NResult N_API NFaceVerificationClientResultGetTokenCGImageRef(HNfvcResult result, CGImageRef * pValue);
	NResult N_API NFaceVerificationClientResultGetImageJpeg2K(HNfvcResult result, void * * pImageBuffer, NInt * pBufferLen);
	NResult N_API NFaceVerificationClientResultGetTokenImageJpeg2K(HNfvcResult result, void * * pImageBuffer, NInt * pBufferLen);
	NResult N_API NFaceVerificationClientResultGetMatchingScore(HNfvcResult result, NInt * pScore);

	// helpers
	void NFaceVerificationClientSetEnableLogging(NBool value);
	NBool NFaceVerificationClientGetEnableLogging();
	NResult N_API NFaceVerificationClientFreeHandle(void * * handle);
	NResult N_API NFaceVerificationClientGetLastErrorMessage(NChar * * pszMessage, NInt * pMessageLength);
	void N_API NFaceVerificationClientFree(void * ptr);

#ifdef N_CPP
}
#endif

#endif // !N_FACE_VERIFICATION_CLIENT_H_INCLUDED
