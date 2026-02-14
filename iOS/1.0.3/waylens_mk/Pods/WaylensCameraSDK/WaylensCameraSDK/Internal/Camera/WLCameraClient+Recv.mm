//
//  WLCameraClient+Recv.m
//  Hachi
//
//  Created by gliu on 16/3/24.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "WLCameraClient+Recv.h"
#import "WLBonjourCameraListManager.h"
#import "ccam_cmd.h"
#import "NSString+apiVersion.h"

#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

@implementation WLCameraClient (Recv)

- (void)onCMD:(EnumedStringCMD*)cmd {
    if (self.cameraClientDelegate == nil) {
        NSLog(@"CameraClient OnCMD: no delegate");
        return;
    }
    NSLog(@"CameraClient Receive CMD:%d Domain:%d", cmd->getCMD(), cmd->getDomain());
    switch (cmd->getDomain()) {
        case CMD_Domain_cam: {
            switch (cmd->getCMD()) {
                case CMD_Cam_getAPIVersion:
                    NSLog(@"--- CMD_Cam_GetApiVersion: %s\n", cmd->getPara1());
                    [self.cameraClientDelegate onGetApiVersion:(char*)cmd->getPara1()];
                    break;
                case CMD_Cam_isAPISupported:
                    NSLog(@"--- CMD_Cam_isAPISupported: %s, %s\n", cmd->getPara1(), cmd->getPara2());
                    break;

                case CMD_Cam_get_Name_result:
                    [self.cameraClientDelegate onCameraName:(char*)cmd->getPara1()];
                    break;

                case CMD_Cam_get_State_result:
                    //NSLog(@"--- get state update: %s\n", cmd->getPara1());
                    [self.cameraClientDelegate onRecordState:(WLRecordState)(atoi(cmd->getPara1()))];
                    break;

//                case CMD_Cam_getMode_result:
//                    [self.pCameraClientDelegate onCameraMode:(eCameraMode)(atoi(cmd->getPara1()))];
//                    break;

                case CMD_Cam_get_time_result:
                    [self.cameraClientDelegate onRecordingTime:(atoi(cmd->getPara1()))];
                    break;

                case CMD_Cam_msg_Storage_infor: {
                    WLStorageState storageState = (WLStorageState)atoll(cmd->getPara1());
                    NSString *format = [NSString stringWithUTF8String:cmd->getPara2()];
                    [self.cameraClientDelegate onStorageState:storageState format:format];
                    NSLog(@"onStorageState:%ld format:%@", storageState, format);
                }
                    break;

                case CMD_Cam_msg_StorageSpace_infor:
                    [self.cameraClientDelegate onStorageSpace:atoll(cmd->getPara1())free:atoll(cmd->getPara2())];
                    break;

                case CMD_Cam_msg_Battery_infor: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onBatteryInfo:json percentage:atoi(cmd->getPara2())];
                }
                    break;

                case CMD_Cam_msg_power_infor:
                    [self.cameraClientDelegate onPowerSupplyState:atoi(cmd->getPara2())];
                    break;

                case CMD_Cam_msg_BT_infor:
                    NSLog(@"-- bt infor : %s, %s\n", cmd->getPara1(), cmd->getPara2());
                    //_delegate->onBTSate(atoi(cmd->getPara1()), cmd->getPara2());
                    break;

                case CMD_Cam_msg_GPS_infor:
                    //NSLog(@"-- gps infor : %s, %s\n", cmd->getPara1(), cmd->getPara2());
                    break;

                case CMD_Cam_msg_Mic_infor:
                    [self.cameraClientDelegate onMicEnabled:(atoi(cmd->getPara1())==0)volume:atoi(cmd->getPara2())];
                    break;

                case CMD_Cam_msg_Internet_infor:
//                    [self.pCameraClientDelegate onInternetServerState:(atoi(cmd->getPara1()))];
                    break;

                case CMD_Network_GetWLanMode:
                    [self.cameraClientDelegate onGetWiFiMode:atoi(cmd->getPara1()) SSID:[NSString stringWithUTF8String:cmd->getPara2()]];
                    break;
                case CMD_Network_GetHostNum:
                    [self.cameraClientDelegate onGetWiFiHostNum:(atoi(cmd->getPara1()))];
                    break;

                case CMD_Network_GetHostInfor:
                    [self.cameraClientDelegate onGetWiFiHostInfor:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;

                case CMD_audio_getMicState:
                    [self.cameraClientDelegate onMicEnabled:(atoi(cmd->getPara1())==0)volume:atoi(cmd->getPara2())];
                    break;
                case CMD_Network_GetDevicetime:
                    [self.cameraClientDelegate onGetDevieTime:atoi(cmd->getPara1()) timeZone:atoi(cmd->getPara2())];
                    break;
                case CMD_fw_getVersion: {
                    char* vHw = (char*)cmd->getPara1();
                    char *at = strstr(vHw, "@");
                    if (at == NULL) {
                        NSLog(@"get a wrong version: %s", vHw);
                        break;
                    } else {
                        if ([[NSString stringWithUTF8String:cmd->getPara2()] isEqualToString:@"beta"]) {
                            [self.cameraClientDelegate onCurrentDevice:@"beta"
                                                                 FW:[NSString stringWithUTF8String:cmd->getPara2()]
                                                           hardware:@"beta"];
                        } else {
                            NSString* hw = [NSString stringWithFormat:@"%s", (char*)(at+1)];
                            at[0] = '\0';
                            NSString* sn = [NSString stringWithFormat:@"%s", vHw];
                            [self.cameraClientDelegate onCurrentDevice:sn
                                                                 FW:[NSString stringWithUTF8String:cmd->getPara2()]
                                                           hardware:hw];
                        }
                    }
                }
                    break;
                case CMD_fw_newVersion: {
                    int result = atoi(cmd->getPara1());
                    NSLog(@"CMD_fw_newVersion: %d", result);
                    if (result == 1) {
                        [self.cameraClientDelegate onReadyToUpgrade];
                    } else if (result == 0) {
                        [self.cameraClientDelegate onUpgradeResult:100];
                    } else {
                        [self.cameraClientDelegate onUpgradeResult:-1];
                    }
                }
                    break;
                case CMD_fw_doUpgrade:
                    break;

                case CMD_Network_ScanHost: {
                    const char *param = cmd->getPara1();
                    NSLog(@"CMD_Network_ScanHost %s", param);
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSNotification *noti = [[NSNotification alloc] initWithName:@"CMD_Network_ScanHost" object:nil userInfo:json];
                    [[NSNotificationCenter defaultCenter] postNotification:noti];
                }
                    break;

                case CMD_Network_AddHost: {
                    const char *param = cmd->getPara1();
                    int result = atoi(param);
                    NSNotification *noti = [[NSNotification alloc] initWithName:@"CMD_Network_AddHost" object:nil userInfo:@{@"data":@(result)}];
                    [[NSNotificationCenter defaultCenter] postNotification:noti];
                }
                    break;
                case CMD_Network_ConnectHost: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSNotification *noti = [[NSNotification alloc] initWithName:@"CMD_Network_ConnectHost" object:nil userInfo:@{@"data":data}];
                    [[NSNotificationCenter defaultCenter] postNotification:noti];
                }
                    break;
                case CMD_Network_ConnectHotSpot: {
                    const char *param = cmd->getPara1();
                    int result = atoi(param);
                    NSNotification *noti = [[NSNotification alloc] initWithName:@"CMD_Network_ConnectHotSpot" object:nil userInfo:@{@"data":@(result)}];
                    [[NSNotificationCenter defaultCenter] postNotification:noti];
                } break;
                case CMD_Rec_error: {
                    Rec_Error_code err = ((Rec_Error_code)atoi(cmd->getPara1()));
                    NSLog(@"OnRecError: %d", err);
                    [self.cameraClientDelegate onRecErr:[NSError errorWithDomain:[NSString stringWithCString:ErrRecodeDescription[err] encoding:NSUTF8StringEncoding] code:err userInfo:nil]];
                }
                    break;

                    //Api 1.2
                case CMD_CAM_BT_isSupported:{
                    int bSupported = (atoi(cmd->getPara1()));
                    NSLog(@"On BT supported: %d", bSupported);
                    [self.cameraClientDelegate onBTisSupported:(bSupported == 1)];
                }
                    break;
                case CMD_CAM_BT_isEnabled:{
                    int bEnabled = (atoi(cmd->getPara1()));
                    NSLog(@"On BT enabled: %d", bEnabled);
                    [self.cameraClientDelegate onBTisEnabled:(bEnabled == 1)];
                }
                    break;
                case CMD_CAM_BT_getDEVStatus:{
                    int pa1 = (atoi(cmd->getPara1()));
                    eBTType type = (eBTType)(pa1 >> 8);
                    WLBluetoothStatus sta = (WLBluetoothStatus)(pa1 & 0xff);
                    NSString* binddev = [NSString stringWithCString:cmd->getPara2()encoding:NSUTF8StringEncoding];
                    NSString* mac = @"";
                    NSString* name = @"";
                    NSRange range = [binddev rangeOfString:@"#"];
                    if (range.length > 0) {
                        mac = [binddev substringToIndex:range.location];
                        name = [binddev substringFromIndex:(range.location+1)];
                    }
                    [self.cameraClientDelegate onGetBTDevType:type Status:sta Mac:mac Name:name];
                }
                    break;
                case CMD_CAM_BT_getHostNum:
                    [self.cameraClientDelegate onGetBTDevHostNum:(atoi(cmd->getPara1()))];
                    break;
                case CMD_CAM_BT_getHostInfor:
                    [self.cameraClientDelegate onGetBTDevHostInfor:[NSString stringWithUTF8String:cmd->getPara1()] Mac:[NSString stringWithUTF8String:cmd->getPara2()]];
                    break;
                case CMD_CAM_BT_doScan: {
                    NSDictionary *json = nil;
                    if (cmd->getPara2()) {
                        NSData *data = [NSData dataWithBytes:cmd->getPara2() length:strlen(cmd->getPara2())];
                        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    }
                    [self.cameraClientDelegate onBTDevScanDone:(atoi(cmd->getPara1())) withList:json];
                }
                    break;
                case CMD_CAM_BT_doBind:
                    [self.cameraClientDelegate onBTDev:((eBTType)atoi(cmd->getPara1()))BindDone:(atoi(cmd->getPara2()))];
                    break;
                case CMD_CAM_BT_doUnBind:
                    [self.cameraClientDelegate onBTDev:((eBTType)atoi(cmd->getPara1()))UnBindDone:(atoi(cmd->getPara2()))];
                    break;
                case CMD_CAM_BT_setOBDTypes:
                    //todo
                    break;
                    // end 1.2

                //CMD 61, 76-87 BEGIN
                case CMD_CAM_Format_TF:
                    [self.cameraClientDelegate onFormatTFCard:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Set_Auto_Power_Off_Delay:
                    [self.cameraClientDelegate onSetAutoPowerOffDelay:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Auto_Power_Off_Delay:
                    [self.cameraClientDelegate onGetAutoPowerOffDelay:[NSString stringWithFormat:@"%s", cmd->getPara1()]];
                    break;
                case CMD_Set_Speaker_Status:
                    [self.cameraClientDelegate onSetSpeakerStatus:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Speaker_Status: {
                    BOOL enabled = (BOOL)atoi(cmd->getPara1());
                    [self.cameraClientDelegate onGetSpeakerStatus:enabled volume:atoi(cmd->getPara2())];
                }   break;
                case CMD_Set_Display_Auto_Brightness:
                    [self.cameraClientDelegate onSetDisplayAutoBrightness:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Display_Auto_Brightness:
                    [self.cameraClientDelegate onGetDisplayAutoBrightness:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Set_Display_Brightness:
                    [self.cameraClientDelegate onSetDisplayBrightness:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Display_Brightness:
                    [self.cameraClientDelegate onGetDisplayBrightness:atoi(cmd->getPara1())];
                    break;
                case CMD_Set_Display_Auto_Off_Time:
                    [self.cameraClientDelegate onSetDisplayAutoOffTime:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Display_Auto_Off_Time:
                    [self.cameraClientDelegate onGetDisplayAutoOffTime:[NSString stringWithFormat:@"%s", cmd->getPara1()]];
                    break;
                case CMD_Factory_Reset:
                    [self.cameraClientDelegate onFactoryReset:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Connected_Clients_Info:
                    [self.cameraClientDelegate onGetConnectedClientsCount:atoi(cmd->getPara1())];
                    break;
                 //CMD 61, 76-87 END
                case CMD_GET_OBD_VIN:
                    [self.cameraClientDelegate onGetVIN:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_GET_Screen_Saver_Style:
                    [self.cameraClientDelegate onGetScreenSaverStyle:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_SET_Screen_Saver_Style:
                    [self.cameraClientDelegate onSetScreenSaverStyle:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Copy_Log:
                    [self.cameraClientDelegate onCopyLog:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_360_Sever: {
                    NSString *server = [NSString stringWithUTF8String:cmd->getPara1()];
                    NSLog(@"Camera Server: %@", server);
                    [self.cameraClientDelegate onGet360Server:server];
                }
                    break;
                case CMD_Set_360_Sever:
                    [self.cameraClientDelegate onSet360Server:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_FW_Get_Key:
                    [self.cameraClientDelegate onGetKey:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_Get_Mount_Settings: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onGetMountConfig:json];
                }
                    break;
                case CMD_Set_Mount_Settings:
                    [self.cameraClientDelegate onSetMountConfig:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Mount_Version: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onGetMountVersion:json];
                }
                    break;
                case CMD_Get_Monitor_Mode:
                    [self.cameraClientDelegate onGetMonitorMode:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_Get_HDR_Mode: {
                    NSString *modeString = [NSString stringWithUTF8String:cmd->getPara1()];
                    WLCameraHDRMode mode = WLCameraHDRModeOff;
                    if ([modeString isEqualToString:@"on"]) {
                        mode = WLCameraHDRModeOn;
                    }
                    else if ([modeString isEqualToString:@"auto"]) {
                        mode = WLCameraHDRModeAuto;
                    }
                    [self.cameraClientDelegate onGetHDRMode:mode];
                }
                    break;
                case CMD_Set_HDR_Mode:
                    [self.cameraClientDelegate onSetHDRMode:(BOOL)atoi(cmd->getPara1())];
                    break;
                // api 1.9
                case CMD_Get_Mount_Accel_Levels: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onGetMountAccelLevels:json current:[NSString stringWithFormat:@"%s", cmd->getPara2()]];
                }
                    break;
                case CMD_Set_Mount_Accel_Level:
                    [self.cameraClientDelegate onSetMountAccelLevel:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_Mount_Accel_param:
                    [self.cameraClientDelegate onGetMountAccelParam:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_Set_Mount_Accel_param:
                    [self.cameraClientDelegate onSetMountAccelParam:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Get_IIOEventDetectionParam:
                    [self.cameraClientDelegate onGetIIOEventDetectionParam:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_Set_IIOEventDetectionParam:
                    [self.cameraClientDelegate onSetIIOEventDetectionParam:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Synctime_EX:
                    break;
                case CMD_GetTimeZone: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onGetTimeZone:[[json objectForKey:@"timezone"] intValue]
                                               DaylightSaving:[[json objectForKey:@"daylightsaving"] boolValue]];
                }
                    break;
                case CMD_GetMarkStorage: {
                    const char *param = cmd->getPara2();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.cameraClientDelegate onGetMarkStorageOptions:json current:atoi(cmd->getPara1())];
                }
                    break;
                case CMD_SetMarkStorage:
                    [self.cameraClientDelegate onSetMarkStorage:atoi(cmd->getPara1())];
                    break;
                case CMD_GetAudioPrompts:
                    [self.cameraClientDelegate onGetAudioPromptEnabled:[[NSString stringWithUTF8String:cmd->getPara1()] isEqual:@"on"]];
                    break;
                case CMD_SetAudioPrompts:
                    [self.cameraClientDelegate onSetAudioPromptEnabled:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_GetICCID:
                    [self.cameraClientDelegate onGetICCID:[NSString stringWithUTF8String:cmd->getPara1()]];
                    break;
                case CMD_Get_LTE_FWVersion:
                    [self.cameraClientDelegate onGetLTEFirmwareVersionPublic:[NSString stringWithUTF8String:cmd->getPara1()] internal:[NSString stringWithUTF8String:cmd->getPara2()]];
                    break;
                case CMD_Get_LTE_STATUS: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"On get LTE Status: %@", json);
                    [self.cameraClientDelegate onGetLTEStatus:json];
                }
                    break;
                // api 1.9 end

                // api 1.10
                case CMD_Get_Mount_MW_Sensitivity: {
                    [self.cameraClientDelegate onGetRadarSensitivity:atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Set_Mount_MW_Sensitivity: {
                    [self.cameraClientDelegate onSetRadarSensitivity:atof(cmd->getPara1())];
                }
                    break;
                case CMD_DEBUG_PROPS: {
                    [self.cameraClientDelegate onDebugProp:[NSString stringWithUTF8String:cmd->getPara1()] value:[NSString stringWithUTF8String:cmd->getPara2()]];
                }
                    break;
                // api 1.10 done
                    
                // api 1.12
                case CMD_Get_Mount_ACC_Trust: {
                    BOOL isTrusted = (BOOL)atoi(cmd->getPara1());

                    NSLog(@"onGetMountACCTrust: %d", isTrusted);

                    [self.cameraClientDelegate onGetMountACCTrust:isTrusted];
                }
                    break;
                // api 1.12 done

                // api 1.13
                case CMD_Get_KeepAlive_forApp: {
                    [self.cameraClientDelegate onGetAppKeepAlive:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Set_KeepAlive_forApp: {
                    [self.cameraClientDelegate onGetAppKeepAlive:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Get_Attitude: {
                    [self.cameraClientDelegate onGetAttitude:[[NSString stringWithUTF8String:cmd->getPara1()] isEqualToString:@"upsidedown"]];
                }
                    break;
                case CMD_Support_UpsideDown: {
                    [self.cameraClientDelegate onGetSupportUpsideDown:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                // api 1.13 done

                // api 1.14
                case CMD_Get_SupportRiskDriveEvent: {
                    [self.cameraClientDelegate onGetSupportRiskDriveEvent:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Get_APN: {
                    [self.cameraClientDelegate onGetAPN:[NSString stringWithUTF8String:cmd->getPara1()]];
                }
                    break;
                case CMD_Get_SupportWlanMode: {
                    [self.cameraClientDelegate onGetSupportWlanMode:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Get_ProtectionVoltage: {
                    [self.cameraClientDelegate onGetProtectionVoltage:atoi(cmd->getPara1())];
                }
                    break;
                case CMD_Get_ParkSleepDelay: {
                    [self.cameraClientDelegate onGetParkSleepDelay:atoi(cmd->getPara1())];
                }
                    break;
                // api 1.14 done
                case CMD_Get_OBDCfg: {
                    int obdWorkMode = atoi(cmd->getPara1());
                    NSLog(@"OBD Work Mode: %d", obdWorkMode);

                    WLObdWorkModeConfig *config = [[WLObdWorkModeConfig alloc] initWithDictionary:@{@"mode" : @(obdWorkMode)}];
                    if (config != nil) {
                        // If has received CMD_Get_OBDTotalCfg, this value will be ignored.
                        [self.cameraClientDelegate onGetObdWorkModeConfig:config];
                    }
                }
                    break;
                case CMD_Get_OBDTotalCfg: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                    NSLog(@"onGetObdWorkModeConfig: %@", json);

                    WLObdWorkModeConfig *config = [[WLObdWorkModeConfig alloc] initWithDictionary:json];
                    if (config != nil) {
                        [self.cameraClientDelegate onGetObdWorkModeConfig:config];
                    }
                }
                    break;
                case CMD_Set_VtIgtCfg:
                case CMD_Get_VtIgtCfg: {
                    const char *param = cmd->getPara1();
                    NSData *data = [NSData dataWithBytes:param length:strlen(param)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    NSLog(@"onGetVirtualIgnitionConfig: %@", json);
                    
                    [self.cameraClientDelegate onGetVirtualIgnitionConfigWithEnable:[json[@"enable"] boolValue]];
                }
                    break;
                default:
                    //printf("--cmd  : %s\n", )
                    break;
            }
        }
            break;
        case CMD_Domain_rec:
        {
            switch (cmd->getCMD()) {
                case CMD_Rec_List_ColorModes:
                    [self.cameraClientDelegate onSupportedColorModeList:(atoll(cmd->getPara1()))];
                    break;
                case CMD_Rec_List_RecModes:
                    [self.cameraClientDelegate onSupportedRecModeList:(atoll(cmd->getPara1()))];
                    break;
                case CMD_Rec_List_Resolutions:
                    [self.cameraClientDelegate onSupportedResolutionList:(atoll(cmd->getPara1()))];
                    break;
                case CMD_Rec_List_Qualities:
                    [self.cameraClientDelegate onSupportedQualityList:(atoll(cmd->getPara1()))];
                    break;

                case CMD_Rec_get_ColorMode:
                    [self.cameraClientDelegate onCurrentColorMode:(atoi(cmd->getPara1()))];
                    break;
                case CMD_Rec_get_RecMode:
                    [self.cameraClientDelegate onCurrentRecMode:(atoi(cmd->getPara1()))];
                    break;
                case CMD_Rec_Set_Quality:
                    [self.cameraClientDelegate onSetQuality:(BOOL)atoi(cmd->getPara1())];
                    break;
                case CMD_Rec_get_Quality:
                    if ((cmd->getPara2() == NULL) || (strcmp(cmd->getPara2(), "") == 0)) {
                        [self.cameraClientDelegate onCurrentQuality:(atoi(cmd->getPara1()))];
                    } else {
                        int para1 = atoi(cmd->getPara1());
                        int para2 = atoi(cmd->getPara2());

                        if (para1 < Video_Quality_num && para2 < Video_Quality_num) {
                            [self.cameraClientDelegate onGetMainQuality:atoi(cmd->getPara1()) subQuality:atoi(cmd->getPara2())];
                        }
                    }
                    break;
                case CMD_Rec_get_Resolution:
                    [self.cameraClientDelegate onCurrentResolution:(atoi(cmd->getPara1()))];
                    break;
                case CMD_Rec_getOverlayState: {
                    int m = atoi(cmd->getPara1());
                    bool bName = m & 0x01;
                    bool bTime = m & 0x02;
                    bool bPosi = m & 0x04;
                    bool bSpeed =  m & 0x08;
                    [self.cameraClientDelegate onOverlayInfoName:bName time:bTime posi:bPosi speed:bSpeed];
                }
                    break;
                case CMD_Rec_Get_Mark_Time: {
                    int m = atoi(cmd->getPara1());
                    int n = atoi(cmd->getPara2());
                    [self.cameraClientDelegate onLiveMarkParam:m After:n];
                }
                    break;
                case CMD_Rec_Get_Rotate_Mode: {
                    if ([WLBonjourCameraListManager.sharedManager.currentCamera.apiVersion compareWithVersion:@"1.5.05"]>=0) {
                        char *mode = (char *)cmd->getPara1();
                        NSString *modeStr = [NSString stringWithCString:mode encoding:NSASCIIStringEncoding];
                        int rotateMode = -1;
                        BOOL rotated = NO;
                        if ([modeStr isEqualToString:@"auto"]) {
                            rotateMode = CameraRotateModeAuto;
                            mode = (char *)cmd->getPara2();
                            modeStr = [NSString stringWithCString:mode encoding:NSASCIIStringEncoding];
                        }
                        if ([modeStr isEqualToString:@"normal"]) {
                            if (rotateMode!=CameraRotateModeAuto) {
                                rotateMode = CameraRotateModeNormal;
                            }
                            rotated = NO;
                        } else if ([modeStr isEqualToString:@"180"]) {
                            if (rotateMode!=CameraRotateModeAuto) {
                                rotateMode = CameraRotateMode180;
                            }
                            rotated = YES;
                        }
                        if (rotateMode>=0) {
                            [self.cameraClientDelegate onRotateMode:(WLCameraRotateMode)rotateMode rotated:rotated];
                        }
                    } else {
                        BOOL m = atoi(cmd->getPara1())!= 0;
                        BOOL n = atoi(cmd->getPara2())!= 0;
                        WLCameraRotateMode rotateMode = CameraRotateModeNormal;
                        BOOL rotated = NO;
                        if (m && n) {
                            rotateMode = CameraRotateMode180;
                            rotated = YES;
                        }
                        [self.cameraClientDelegate onRotateMode:rotateMode rotated:rotated];
                    }
                }
                    break;
                case CMD_Rec_Mark_Live_Video: {
                    BOOL done = atoi(cmd->getPara1())== 0;
                    [self.cameraClientDelegate onLiveMark:done];
                }
                    break;

                // api 1.14
                case CMD_Rec_Get_SubStreamOnly: {
                    [self.cameraClientDelegate onGetSubStreamOnly:(BOOL)atoi(cmd->getPara1())];
                }
                    break;
                // api 1.14 done
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

// call onProcessACK in main queue
- (void)onProcessACK:(NSData*)ack {
    StringEnvelope strEV((char*)[ack bytes], (int)[ack length]);
    for(int i = 0; i < strEV.getNum(); i++) {
        [self onCMD:(EnumedStringCMD*)(strEV.GetCmd(i))];
    }
}
- (void)onReciveBuffer:(nonnull NSData *)data {
    //deal with all cmd in main queue, do not use lock
    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
        switch (self.cameraClientDelegate.protocolVersion) {
            case CommunicationProtocolVersionCamClient:
            {
                [super.receivingBuffer appendData:data];
                while([super.receivingBuffer length] >= (int)sizeof(SessionDataHead)) {
                    SessionDataHead *pHead = (SessionDataHead *)[super.receivingBuffer bytes];
                    if([super.receivingBuffer length] >= pHead->length) {
                        NSRange ackrange = {2*sizeof(int), (sizeof(pHead->data)+ pHead->appendLength)};
                        if (super.receivingBuffer.length < ackrange.location + ackrange.length) {
                            NSLog(@"########## onReciveBuffer: len:%d, append:%d, %@ ####################", pHead->length, pHead->appendLength, super.receivingBuffer);
                            NSAssert(0, @"Wrong Camera msg size!!!");
                        } else {
                            [self onProcessACK:[super.receivingBuffer subdataWithRange:ackrange]];
                            NSRange cmdrange = {0, static_cast<NSUInteger>(pHead->length)};
                            if (cmdrange.length == 0) {
                                cmdrange.length = super.receivingBuffer.length;
                            }
                            [super.receivingBuffer replaceBytesInRange:cmdrange withBytes:nullptr length:0];
                        }
                    } else {
                        //                NSLog(@"Camera Client WaitMore");
                        break;
                    }
                }
            }
                break;
            case CommunicationProtocolVersionEvcam:
            {
                [self.evcamMsgParser appendData:data];
                [[self.evcamMsgParser parse] enumerateObjectsUsingBlock:^(id  _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self handleMsg:msg];
                }];
            }
                break;
            default:
                break;
        }

    }];
}

@end
