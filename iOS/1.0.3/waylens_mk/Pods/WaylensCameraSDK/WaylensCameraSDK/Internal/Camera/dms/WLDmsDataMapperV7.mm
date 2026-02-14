//
//  WLDmsDataMapperV7.m
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import "WLDmsDataMapperV7.h"
#import "WLDmsDataHeaderMapper.h"
#import "WLDmsDataPersonInfoMapper.h"

@implementation WLDmsDataMapperV7

+ (WLDmsData *)mapWithHeader:(eyesight_dms_data_header_t *)header output:(L1OutputV7 *)output personInfo:(nullable eyesight_person_info_t *)personInfo {
    NSMutableDictionary *dmsDict = [[NSMutableDictionary alloc] initWithDictionary:[WLDmsDataHeaderMapper mapWithHeader:header]];

    if (personInfo != NULL) {
        NSDictionary *personDict = [WLDmsDataPersonInfoMapper mapWithHeader:header personInfo:personInfo];
        [dmsDict addEntriesFromDictionary:personDict];
    }

    switch (output->hasGlasses) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysHasGlasses)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysHasGlasses)];
            break;
        default:
            break;
    }

    switch (output->hasMask) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysHasMask)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysHasMask)];
            break;
        default:
            break;
    }

    switch (output->isFaceReal) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsFaceReal)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsFaceReal)];
            break;
        default:
            break;
    }

    switch (output->eyesOnRoad) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysEyesOnRoad)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysEyesOnRoad)];
            break;
        default:
            break;
    }

    switch (output->headOnRoad) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysHeadOnRoad)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysHeadOnRoad)];
            break;
        default:
            break;
    }

    switch (output->isWearingSeatbelt) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsWearingSeatbelt)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsWearingSeatbelt)];
            break;
        default:
            break;
    }

    switch (output->isUsingCellphone) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsUsingCellphone)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsUsingCellphone)];
            break;
        default:
            break;
    }

    switch (output->isDayDreaming) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsDayDreaming)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsDayDreaming)];
            break;
        default:
            break;
    }

    switch (output->isSmoking) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsSmoking)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsSmoking)];
            break;
        default:
            break;
    }

    switch (output->isEating) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsEating)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsEating)];
            break;
        default:
            break;
    }

    switch (output->isYawning) {
        case ds_v7::TriState::YES_STATE:
            [dmsDict setObject:@(YES) forKey:@(WLDmsDataKeysIsYawning)];
            break;
        case ds_v7::TriState::NO_STATE:
            [dmsDict setObject:@(NO) forKey:@(WLDmsDataKeysIsYawning)];
            break;
        default:
            break;
    }

    switch (output->cameraStatus) {
        case ds_v7::CameraStatus::WORKING:
            [dmsDict setObject:@"WORKING" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::CAMERA_FAILURE:
            [dmsDict setObject:@"CAMERA_FAILURE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::OVER_EXPOSURE:
            [dmsDict setObject:@"OVER_EXPOSURE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::DARK_IMAGE:
            [dmsDict setObject:@"DARK_IMAGE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::BLURRED_IMAGE:
            [dmsDict setObject:@"BLURRED_IMAGE" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::UNRECOGNIZED:
            [dmsDict setObject:@"UNRECOGNIZED" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        case ds_v7::CameraStatus::DAMAGED_LED:
            [dmsDict setObject:@"DAMAGED_LED" forKey:@(WLDmsDataKeysCameraStatus)];
            break;
        default:
            break;
    }

    switch (output->drowsiness) {
        case ds_v7::DrowsinessState::UNAVAILABLE:
            [dmsDict setObject:[NSString stringWithFormat:@"UNAVAILABLE, %d%%", output->nDrowsinessConfidence] forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case ds_v7::DrowsinessState::NOT_DETECTED:
            [dmsDict setObject:[NSString stringWithFormat:@"NOT_DETECTED, %d%%", output->nDrowsinessConfidence] forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case ds_v7::DrowsinessState::DROWSY:
            [dmsDict setObject:[NSString stringWithFormat:@"DROWSY, %d%%", output->nDrowsinessConfidence] forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        case ds_v7::DrowsinessState::ASLEEP:
            [dmsDict setObject:[NSString stringWithFormat:@"ASLEEP, %d%%", output->nDrowsinessConfidence] forKey:@(WLDmsDataKeysDrowsiness)];
            break;
        default:
            break;
    }

    switch (output->distraction) {
        case ds_v7::DistractionState::INVALID:
            [dmsDict setObject:[NSString stringWithFormat:@"INVALID, %d%%", output->nDistractionConfidence] forKey:@(WLDmsDataKeysDistraction)];
            break;
        case ds_v7::DistractionState::NOT_DETECTED:
            [dmsDict setObject:[NSString stringWithFormat:@"NOT_DETECTED, %d%%", output->nDistractionConfidence] forKey:@(WLDmsDataKeysDistraction)];
            break;
        case ds_v7::DistractionState::DETECTED:
            [dmsDict setObject:[NSString stringWithFormat:@"DETECTED, %d%%", output->nDistractionConfidence] forKey:@(WLDmsDataKeysDistraction)];
            break;
        case ds_v7::DistractionState::UNRESPONSIVE:
            [dmsDict setObject:[NSString stringWithFormat:@"UNRESPONSIVE, %d%%", output->nDistractionConfidence] forKey:@(WLDmsDataKeysDistraction)];
            break;
        default:
            break;
    }

    switch (output->headGesture) {
        case ds_v7::HeadGesture::NONE:
            [dmsDict setObject:@"NONE" forKey:@(WLDmsDataKeysHeadGesture)];
            break;
        case ds_v7::HeadGesture::NODDING:
            [dmsDict setObject:@"NODDING" forKey:@(WLDmsDataKeysHeadGesture)];
            break;
        case ds_v7::HeadGesture::SHAKING:
            [dmsDict setObject:@"SHAKING" forKey:@(WLDmsDataKeysHeadGesture)];
            break;
        default:
            break;
    }

    switch (output->expression) {
        case ds_v7::Expression::INVALID:
            [dmsDict setObject:@"INVALID" forKey:@(WLDmsDataKeysExpression)];
            break;
        case ds_v7::Expression::NEUTRAL:
            [dmsDict setObject:@"NEUTRAL" forKey:@(WLDmsDataKeysExpression)];
            break;
        case ds_v7::Expression::HAPPY:
            [dmsDict setObject:@"HAPPY" forKey:@(WLDmsDataKeysExpression)];
            break;
        case ds_v7::Expression::ANGRY:
            [dmsDict setObject:@"ANGRY" forKey:@(WLDmsDataKeysExpression)];
            break;
        case ds_v7::Expression::SAD:
            [dmsDict setObject:@"SAD" forKey:@(WLDmsDataKeysExpression)];
            break;
        default:
            break;
    }

    switch (output->eyeMode) {
        case ds_v7::EyeModeState::INVALID:
            [dmsDict setObject:@"INVALID" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case ds_v7::EyeModeState::FIXATION:
            [dmsDict setObject:@"FIXATION" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case ds_v7::EyeModeState::SACCADE:
            [dmsDict setObject:@"SACCADE" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        case ds_v7::EyeModeState::SMOOTH_PURSUIT:
            [dmsDict setObject:@"SMOOTH_PURSUIT" forKey:@(WLDmsDataKeysEyeMode)];
            break;
        default:
            break;
    }

    [dmsDict setObject:@(output->blinkDuration.val) forKey:@(WLDmsDataKeysBlinkDuration)];
    [dmsDict setObject:@(output->blinkRate.val) forKey:@(WLDmsDataKeysBlinkRate)];
    [dmsDict setObject:@(output->fixationLength.val) forKey:@(WLDmsDataKeysFixationLength)];

    struct ds_v7::Gaze gaze = output->faceCameraCoordinatesSystem.unifiedGaze;
    [dmsDict setObject:@(gaze.valid) forKey:@(WLDmsDataKeysIsGazeValid)];

    if (gaze.valid) {
        [dmsDict setObject:[NSString stringWithFormat:@"p:%0.0f° y:%0.0f°", gaze.pitch, gaze.yaw] forKey:@(WLDmsDataKeysGaze)];
    }

    struct ds_v7::Rect headRect = output->headRect;
    [dmsDict setObject:[NSValue valueWithCGRect:CGRectMake(headRect.xc, headRect.yc, headRect.width, headRect.height)] forKey:@(WLDmsDataKeysRawHeadRect)];
    [dmsDict setObject:[NSValue valueWithCGRect:CGRectMake((CGFloat)(headRect.xc - headRect.width / 2), (CGFloat)(headRect.yc - headRect.height / 2), (CGFloat)headRect.width, (CGFloat)headRect.height)] forKey:@(WLDmsDataKeysHeadRect)];
    [dmsDict setObject:@(headRect.angle) forKey:@(WLDmsDataKeysHeadAngle)];

    WLDmsData *dmsData = [[WLDmsData alloc] initWithDict:dmsDict];

    return dmsData;
}

@end
