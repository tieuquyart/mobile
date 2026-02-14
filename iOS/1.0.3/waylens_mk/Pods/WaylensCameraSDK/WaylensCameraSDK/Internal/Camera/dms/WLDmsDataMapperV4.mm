//
//  WLDmsDataMapperV4.m
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import "WLDmsDataMapperV4.h"
#import "WLDmsDataHeaderMapper.h"
#import "WLDmsDataPersonInfoMapper.h"

@implementation WLDmsDataMapperV4

+ (WLDmsData *)mapWithHeader:(eyesight_dms_data_header_t *)header output:(L1OutputAll_1_4 *)output personInfo:(nullable eyesight_person_info_t *)personInfo {
    NSMutableDictionary *dmsDict = [[NSMutableDictionary alloc] initWithDictionary:[WLDmsDataHeaderMapper mapWithHeader:header]];

    if (personInfo != NULL) {
        NSDictionary *personDict = [WLDmsDataPersonInfoMapper mapWithHeader:header personInfo:personInfo];
        [dmsDict addEntriesFromDictionary:personDict];
    }

    switch (output->userOutput.hasGlasses) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysHasGlasses)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysHasGlasses)];
            break;
        default:
            break;
    }

    switch (output->userOutput.hasMask) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysHasMask)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysHasMask)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isFaceReal) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsFaceReal)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsFaceReal)];
            break;
        default:
            break;
    }

    switch (output->userOutput.eyesOnRoad) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysEyesOnRoad)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysEyesOnRoad)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isWearingSeatbelt) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsWearingSeatbelt)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsWearingSeatbelt)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isUsingCellphone) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsUsingCellphone)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsUsingCellphone)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isDayDreaming) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsDayDreaming)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsDayDreaming)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isSmoking) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsSmoking)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsSmoking)];
            break;
        default:
            break;
    }

    switch (output->userOutput.isYawning) {
        case TriState::Yes:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsYawning)];
            break;
        case TriState::No:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsYawning)];
            break;
        default:
            break;
    }

    switch (output->userOutput.cameraStatus) {
        case WORKING:
            [dmsDict setObject:@"WORKING" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case CAMERA_FAILURE:
            [dmsDict setObject:@"CAMERA_FAILURE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case OVER_EXPOSURE:
            [dmsDict setObject:@"OVER_EXPOSURE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case DARK_IMAGE:
            [dmsDict setObject:@"DARK_IMAGE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case BLURRED_IMAGE:
            [dmsDict setObject:@"BLURRED_IMAGE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case UNRECOGNIZED:
            [dmsDict setObject:@"UNRECOGNIZED" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        default:
            break;
    }

    switch (output->userOutput.drowsiness) {
        case DrowsinessState::UNAVAILABLE:
            [dmsDict setObject:@"UNAVAILABLE" forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case DrowsinessState::NOTDETECTED:
            [dmsDict setObject:@"NOTDETECTED" forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case DrowsinessState::DROWSY:
            [dmsDict setObject:@"DROWSY" forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case DrowsinessState::ASLEEP:
            [dmsDict setObject:@"ASLEEP" forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        default:
            break;
    }

    switch (output->userOutput.attentiveness) {
        case AttentivenessState::INVALIDAttentivenessState:
            [dmsDict setObject:@"INVALID" forKey:@(WLDmsDataKeysDistraction)];
            break;
        case AttentivenessState::ATTENTIVE:
            [dmsDict setObject:@"ATTENTIVE" forKey:@(WLDmsDataKeysDistraction)];
            break;
        case AttentivenessState::DISTRACTED:
            [dmsDict setObject:@"DISTRACTED" forKey:@(WLDmsDataKeysDistraction)];
            break;
        default:
            break;
    }

    switch (output->userOutput.expression) {
        case Expression::INVALID:
            [dmsDict setObject:@"INVALID" forKey:@(WLDmsDataKeysExpression)];
            break;
        case Expression::NEUTRAL:
            [dmsDict setObject:@"NEUTRAL" forKey:@(WLDmsDataKeysExpression)];
            break;
        case Expression::HAPPY:
            [dmsDict setObject:@"HAPPY" forKey:@(WLDmsDataKeysExpression)];
            break;
        case Expression::ANGRY:
            [dmsDict setObject:@"ANGRY" forKey:@(WLDmsDataKeysExpression)];
            break;
        case Expression::SAD:
            [dmsDict setObject:@"SAD" forKey:@(WLDmsDataKeysExpression)];
            break;
        default:
            break;
    }

    switch (output->userOutput.eyeMode) {
        case EyeModeState::INVALIDEyeModeState:
            [dmsDict setObject:@"INVALID" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case EyeModeState::FIXATION:
            [dmsDict setObject:@"FIXATION" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case EyeModeState::SACCADE:
            [dmsDict setObject:@"SACCADE" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case EyeModeState::SMOOTH_PURSUIT:
            [dmsDict setObject:@"SMOOTH_PURSUIT" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        default:
            break;
    }

    [dmsDict setObject:@(output->userOutput.blinkDuration.val) forKey:@(WLDmsDataKeysBlinkDuration)];
    [dmsDict setObject:@(output->userOutput.blinkRate.val) forKey:@(WLDmsDataKeysBlinkRate)];
    [dmsDict setObject:@(output->userOutput.fixationLength.val) forKey:@(WLDmsDataKeysFixationLength)];

    struct Gaze gaze = output->userOutput.faceCameraCoordinatesSystem.unifiedGaze;
    [dmsDict setObject:@(gaze.valid) forKey:@(WLDmsDataKeysIsGazeValid)];

    if (gaze.valid) {
        [dmsDict setObject:[NSString stringWithFormat:@"p:%0.0f° y:%0.0f°", gaze.pitch, gaze.yaw] forKey:@(WLDmsDataKeysGaze)];
    }

    struct DSRect headRect = output->userOutput.headRect;
    [dmsDict setObject:[NSValue valueWithCGRect:CGRectMake(headRect.xc, headRect.yc, headRect.width, headRect.height)] forKey:@(WLDmsDataKeysRawHeadRect)];
    [dmsDict setObject:[NSValue valueWithCGRect:CGRectMake((CGFloat)(headRect.xc - headRect.width / 2), (CGFloat)(headRect.yc - headRect.height / 2), (CGFloat)headRect.width, (CGFloat)headRect.height)] forKey:@(WLDmsDataKeysHeadRect)];
    [dmsDict setObject:@(headRect.angle) forKey:@(WLDmsDataKeysHeadAngle)];

    WLDmsData *dmsData = [[WLDmsData alloc] initWithDict:dmsDict];

    return dmsData;
}

@end
