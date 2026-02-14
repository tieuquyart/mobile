//
//  CameraClient.m
//  Vidit
//
//  Created by gliu on 15/1/28.
//  Copyright (c)2015年 Transee. All rights reserved.
//

#import "WLCameraClient.h"
#import "ccam_cmd.h"
#include "ccam_cmds.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

//#include <string.h>

@implementation WLCameraClient

- (nonnull instancetype)initWithIPv4:(nullable NSString *)ipv4 IPv6:(nullable NSString *)ipv6 port:(long)port {
    self = [super initWithIPv4:ipv4 IPv6:ipv6 port:port];
    if (self) {
        if(isatty(STDOUT_FILENO)) {
            self.heartBeatInterval = -1;
//            self.heatBeatInterval = 4;
        } else {
            self.heartBeatInterval = 4;
        }
    }
    return self;
}

- (void)getCameraState {
    switch ([_cameraClientDelegate protocolVersion]) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_get_State inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getState]];
            break;
        default:
            break;
    }
}

- (void)startRecord {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_start_rec inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator startRecord]];
            break;
        default:
            break;
    }
}
- (void)stopRecord {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_stop_rec inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator stopRecord]];
            break;
        default:
            break;
    }
}
- (void)getAllInfor {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_get_getAllInfor inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMicState]];
            [self send:[WLEvcamCmdGenerator getTFState]];
            [self send:[WLEvcamCmdGenerator getPowerState]];
            break;
        default:
            break;
    }
}
- (void)getStorageInfos {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_get_getStorageInfor inDomain:CMD_Domain_cam withPara1:nil andPara2:nil];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getTFState]];
            break;
        default:
            break;
    }
}
- (void)getRecordTime {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_get_time inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getCameraName {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_get_Name inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getName]];
            break;
        default:
            break;
    }
}
- (void)setCameraName:(NSString*)name {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* cname = (char*)[name cStringUsingEncoding:NSUTF8StringEncoding];
            [self sendCmd:CMD_Cam_set_Name inDomain:CMD_Domain_cam withPara1:cname andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setName:name]];
            break;
        default:
            break;
    }
}
- (void)setPreviewStreamSize:(BOOL)bBig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[5];
            sprintf(tmp, "%d", bBig);
            [self sendCmd:CMD_Cam_set_StreamSize inDomain:CMD_Domain_cam withPara1:(char*)tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getResolutionList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_List_Resolutions inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getCurrentResolution {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_get_Resolution inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setResolution:(eVideoResolution)resolution {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[5];
            sprintf(tmp, "%d", resolution);
            [self sendCmd:CMD_Rec_Set_Resolution inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getQualityList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_List_Qualities inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getCurrentQuality {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_get_Quality inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setQuality:(WLVideoQuality)quality {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[5];
            sprintf(tmp, "%d", quality);
            [self sendCmd:CMD_Rec_Set_Quality inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setMainQuality:(WLVideoQuality)mainQuality subQuality:(WLVideoQuality)subQuality {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char main[5];
            char sub[5];
            sprintf(main, "%d", mainQuality);
            sprintf(sub, "%d", subQuality);
            [self sendCmd:CMD_Rec_Set_Quality inDomain:CMD_Domain_rec withPara1:main andPara2:sub];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getRecModeList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_List_RecModes inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getCurrentRecMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_get_RecMode inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getRecordMode]];
            break;
        default:
            break;
    }
}
- (void)setRecMode:(WLRecordMode)mode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[5];
            sprintf(tmp, "%d", mode);
            [self sendCmd:CMD_Rec_Set_RecMode inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getColorModeList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_List_ColorModes inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getCurrentColorMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_get_ColorMode inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)setColorMode:(eColorMode)mode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[5];
            sprintf(tmp, "%d", mode);
            [self sendCmd:CMD_Rec_Set_ColorMode inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)powerOff {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_PowerOff inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator powerOff]];
            break;
        default:
            break;
    }
}
- (void)reboot {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_Reboot inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator reboot]];
            break;
        default:
            break;
    }
}
- (void)getWlanMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Network_GetWLanMode inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getHostNumber {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Network_GetHostNum inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getHostInfor:(int)index {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[32];
            sprintf(tmp, "%d", index);
            [self sendCmd:CMD_Network_GetHostInfor inDomain:CMD_Domain_cam withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)addHost:(NSString*)ssid password:(NSString*)pwd {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* hostInfo = (char*)[[NSString stringWithFormat:@"{\"ssid\":\"%@\", \"password\":\"%@\", \"is_hide\":0}", ssid, pwd == nil ? @"" : pwd] cStringUsingEncoding:NSUTF8StringEncoding];
            [self sendCmd:CMD_Network_AddHost inDomain:CMD_Domain_cam withPara1:hostInfo andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setHotspotInfo:ssid password:pwd]];
            break;
        default:
            break;
    }
}
- (void)removeHost:(NSString*)ssid {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* cssid = (char*)[ssid cStringUsingEncoding:NSUTF8StringEncoding];
            [self sendCmd:CMD_Network_RmvHost inDomain:CMD_Domain_cam withPara1:cssid andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)connectHost:(NSString*)ssid mode:(int)mode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* cssid = (char*)[ssid cStringUsingEncoding:NSUTF8StringEncoding];
            char tmp[5];
            sprintf(tmp, "%d", mode);
            [self sendCmd:CMD_Network_ConnectHost inDomain:CMD_Domain_cam withPara1:tmp andPara2:cssid];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.connectionDelegate socketClient:self didDisconnectWithError:nil];
            });
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)syncTime:(long)timeSince1970 zone:(int)zoneInSec {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[16];
            char tmp2[16];
            sprintf(tmp, "%ld", timeSince1970);
            sprintf(tmp2, "%.2f", zoneInSec/3600.0);
            [self sendCmd:CMD_Network_Synctime inDomain:CMD_Domain_cam withPara1:tmp andPara2:tmp2];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setTime:timeSince1970 gmtOffset:zoneInSec]];
            break;
        default:
            break;
    }
}

- (void)getDevicetime {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Network_GetDevicetime inDomain:CMD_Domain_cam withPara1:nil andPara2:nil];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getTime]];
            break;
        default:
            break;
    }
}
- (void)getMicState {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_audio_getMicState inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMicState]];
            break;
        default:
            break;
    }
}
- (void)setMic:(BOOL)bMute gain:(int)gain {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[8];
            sprintf(tmp, "%d", bMute);
            char tmp1[8];
            sprintf(tmp1, "%d", gain);
            [self sendCmd:CMD_audio_setMic inDomain:CMD_Domain_cam withPara1:tmp andPara2:tmp1];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setMicStateWithMuted:bMute volume:gain]];
            break;
        default:
            break;
    }
}

- (void)getOverlayState {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_getOverlayState inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)setOverlayWithName:(BOOL)bname time:(BOOL)btime gps:(BOOL)bgps speed:(BOOL)bspeed {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp[8];
            int  m = 0;
            if(bname)   m|=0x01;
            if(btime)   m|=0x02;
            if(bgps)    m|=0x04;
            if(bspeed)  m|=0x08;
            sprintf(tmp, "%d", m);
            [self sendCmd:CMD_Rec_setOverlay inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}
- (void)getRotateParam {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_Get_Rotate_Mode inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getVinMirror]];
            break;
        default:
            break;
    }
}
- (void)setRotateParam:(BOOL)HFlip andVertical:(BOOL)VFlip {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp1[8];
            sprintf(tmp1, "%d", HFlip);
            char tmp2[8];
            sprintf(tmp2, "%d", VFlip);
            [self sendCmd:CMD_Rec_Set_Rotate_Mode inDomain:CMD_Domain_rec withPara1:tmp1 andPara2:tmp2];
        }

            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setRotateMode:(WLCameraRotateMode)mode{
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            NSString *str;
            switch (mode) {
                case CameraRotateModeNormal:
                    str = @"normal";
                    break;
                case CameraRotateMode180:
                    str = @"180";
                    break;
                case CameraRotateModeAuto:
                default:
                    str = @"auto";
                    break;
            }
            char *tmp = (char *)[str cStringUsingEncoding:NSASCIIStringEncoding];
            [self sendCmd:CMD_Rec_Set_Rotate_Mode inDomain:CMD_Domain_rec withPara1:tmp andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getLiveMarkParam {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_Get_Mark_Time inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMarkSettings]];
            break;
        default:
            break;
    }
}

- (void)setLiveMarkParam:(int)before after:(int)after {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char tmp1[8];
            sprintf(tmp1, "%d", before);
            char tmp2[8];
            sprintf(tmp2, "%d", after);
            [self sendCmd:CMD_Rec_Set_Mark_Time inDomain:CMD_Domain_rec withPara1:tmp1 andPara2:tmp2];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setManualMarkSettingsWithManualBefore:before manualAfter:after]];
            break;
        default:
            break;
    }
}

- (void)doLiveMark {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_Mark_Live_Video inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator manualMarkClip]];
            break;
        default:
            break;
    }
}

- (void)getFWVersion {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_fw_getVersion inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getDeviceInfo]];
            break;
        default:
            break;
    }
}

- (void)newFirmwareVersion:(NSString*)md5 withURL:(NSString*)url {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* cmd5 = (char*)[md5 cStringUsingEncoding:NSUTF8StringEncoding];
            char* curl = (char*)(url == nil?NULL:[url cStringUsingEncoding:NSUTF8StringEncoding]);
            [self sendCmd:CMD_fw_newVersion inDomain:CMD_Domain_cam withPara1:cmd5 andPara2:curl];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)doUpgradeFirmware {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_fw_doUpgrade inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)doScanWiFiHost {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Network_ScanHost inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void) doConnectToSSID:(NSString *)ssid {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char *param1 = (char*)[ssid cStringUsingEncoding:NSUTF8StringEncoding];
            [self sendCmd:CMD_Network_ConnectHotSpot inDomain:CMD_Domain_cam withPara1:param1 andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getAPIVersion {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Cam_getAPIVersion inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getDeviceInfo]];
            break;
        default:
            break;
    }
}

- (void)isAPISupported:(int)api inDomain:(int)domain {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char sdom[16];
            char sidx[16];
            sprintf(sdom, "%d", domain);
            sprintf(sidx, "%d", api);
            [self sendCmd:CMD_Cam_isAPISupported inDomain:CMD_Domain_cam withPara1:sdom andPara2:sidx];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getBTSupported {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_CAM_BT_isSupported inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getBTOpened {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_CAM_BT_isEnabled inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getBlueToothInfo]];
            break;
        default:
            break;
    }
}

- (void)doBTOpen:(BOOL)open {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char enable[8];
            strcpy(enable, open?"1":"0");
            [self sendCmd:CMD_CAM_BT_Enable inDomain:CMD_Domain_cam withPara1:enable andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setBlueToothEnableWithEnable:open]];
            break;
        default:
            break;
    }
}

- (void)updateOBDStatus {
    [self updateBTStatusForType:BTType_OBD];
}

- (void)updateHIDStatus {
    [self updateBTStatusForType:BTType_HID];
}

- (void)updateVin {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char enable[8] = "1";
            char str[32] = "xxxxxxxxxxxxx----";
            [self sendCmd:CMD_SET_CLIP_VIN_STYLE inDomain:CMD_Domain_cam withPara1:enable andPara2:str];
            [self sendCmd:CMD_GET_OBD_VIN inDomain:CMD_Domain_cam withPara1:nil andPara2:nil];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)updateBTStatusForType:(eBTType)type {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%d", type);
            [self sendCmd:CMD_CAM_BT_getDEVStatus inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)doBTScan {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_CAM_BT_doScan inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator scanBlueToothDevices]];
            break;
        default:
            break;
    }
}

- (void)updateBTHostNum {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_CAM_BT_getHostNum inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)updateBTHostInfor:(int)index {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char sidx[16];
            sprintf(sidx, "%d", index);
            [self sendCmd:CMD_CAM_BT_getHostInfor inDomain:CMD_Domain_cam withPara1:sidx andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)doOBDBind:(NSString*)mac {
    [self doBTDev:BTType_OBD Bind:mac];
}

- (void)doHIDBind:(NSString*)mac {
    [self doBTDev:BTType_HID Bind:mac];
}
- (void)doBTDev:(eBTType)type Bind:(NSString*)mac {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char* cmac = (char*)[mac cStringUsingEncoding:NSUTF8StringEncoding];
            char stype[8];
            sprintf(stype, "%d", type);
            [self sendCmd:CMD_CAM_BT_doBind inDomain:CMD_Domain_cam withPara1:stype andPara2:cmac];
        }
            break;
        case CommunicationProtocolVersionEvcam: {
            NSString* stype;
            if (type == BTType_OBD) {
                stype = @"OBD";
            } else if (type == BTType_HID) {
                stype = @"HID";
            } else {
                return;
            }
            [self send:[WLEvcamCmdGenerator bindBlueToothDeviceWithType:stype mac:mac]];
        }
            break;
        default:
            break;
    }
}

- (void)doOBDUnBind {
    [self doBTUnBindDev:BTType_OBD];
}

- (void)doHIDUnBind {
    [self doBTUnBindDev:BTType_HID];
}

- (void)doBTUnBindDev:(eBTType)type {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%d", type);
            [self sendCmd:CMD_CAM_BT_doUnBind inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam: {
            NSString* stype;
            if (type == BTType_OBD) {
                stype = @"OBD";
            } else if (type == BTType_HID) {
                stype = @"HID";
            } else {
                return;
            }
            [self send:[WLEvcamCmdGenerator unbindBlueToothDeviceWithType:stype]];
        }
            break;
        default:
            break;
    }
}

- (void)formatTFCard {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_CAM_Format_TF inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator formatTF]];
            break;
        default:
            break;
    }
}

- (void)setAutoPowerOffDelay:(NSString*)delay {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%s", [delay cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_Auto_Power_Off_Delay inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getAutoPowerOffDelay {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Auto_Power_Off_Delay inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setSpeakerStatus:(BOOL)enabled volume:(int)volume{
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8], stype2[8];
            sprintf(stype, "%d", enabled);
            sprintf(stype2, "%d", volume);
            [self sendCmd:CMD_Set_Speaker_Status inDomain:CMD_Domain_cam withPara1:stype andPara2:stype2];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setSpeakerStateWithMuted:!enabled volum:volume]];
            break;
        default:
            break;
    }
}

- (void)onGetSpeakerStatus {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Speaker_Status inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getSpeakerState]];
            break;
        default:
            break;
    }
}

- (void)setDisplayAutoBrightness:(BOOL)autoBrightness {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%d", autoBrightness);
            [self sendCmd:CMD_Set_Display_Auto_Brightness inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getDisplayAutoBrightness {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Display_Auto_Brightness inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setDisplayBrightness:(int)brightnessLevel {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%d", brightnessLevel);
            [self sendCmd:CMD_Set_Display_Brightness inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getDisplayBrightness {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Display_Brightness inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setDisplayAutoOffTime:(NSString*)autoOffTime {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char stype[8];
            sprintf(stype, "%s", [autoOffTime cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_Display_Auto_Off_Time inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getDisplayAutoOffTime {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Display_Auto_Off_Time inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)factoryReset {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Factory_Reset inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator factoryReset]];
            break;
        default:
            break;
    }
}

- (void)getConnectedClientsCount {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Connected_Clients_Info inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getScreenSaverStyle {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_GET_Screen_Saver_Style inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setScreenSaverStyle:(NSString*)style {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            NSAssert([style isEqualToString:@"All Black"] || [style isEqualToString:@"Dot"], nil);
            char stype[32];
            sprintf(stype, "%s", [style cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_SET_Screen_Saver_Style inDomain:CMD_Domain_cam withPara1:stype andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

-(void)getKey {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_FW_Get_Key inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getWiFiKey]];
            break;
        default:
            break;
    }
}

-(void)get360Server {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_360_Sever inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getServerUrl]];
            break;
        default:
            break;
    }
}

-(void)set360Server:(NSString *)address {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char url[127];
            sprintf(url, "%s", [address cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_360_Sever inDomain:CMD_Domain_cam withPara1:url andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setServerUrl:address]];
            break;
        default:
            break;
    }
}

-(void)copyLog:(NSString *)day {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Copy_Log inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getCameraLogWithValue:day]];
            break;
        default:
            break;
    }
}
-(void)copyDebugLog{
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getCameraDebugLog]];
            break;
            
        default:
            break;
    }
}

-(void)getMountConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Mount_Settings inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMountSettings]];
            break;
        default:
            break;
    }
}

-(void)setMountConfig:(NSDictionary *)dict {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            if (jsonData) {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                char *bytes = (char *)[jsonStr cStringUsingEncoding:NSUTF8StringEncoding];
                //        char bytes[jsonData.length] = {0};
                //        [jsonData getBytes:bytes length:jsonData.length];
                //        char *bytes = (char *)[jsonData bytes];
                [self sendCmd:CMD_Set_Mount_Settings inDomain:CMD_Domain_cam withPara1:bytes andPara2:NULL];
            }
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setMountSettings:dict]];
            break;
        default:
            break;
    }
}

-(void)getMonitorMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Monitor_Mode inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getIgnitionMode]];
            break;
        default:
            break;
    }
}

-(void)getMountVersion {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Mount_Version inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMountVersion]];
            break;
        default:
            break;
    }
}

-(void)getHDRMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_HDR_Mode inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getHDRMode]];
            break;
        default:
            break;
    }
}

-(void)setHDRMode:(WLCameraHDRMode)mode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char s1[4];
            switch (mode) {
                case WLCameraHDRModeOn:
                    strcpy(s1, "on");
                    break;
                case WLCameraHDRModeOff:
                    strcpy(s1, "off");
                    break;
                case WLCameraHDRModeAuto:
                    strcpy(s1, "auto");
                    break;
            }
            [self sendCmd:CMD_Set_HDR_Mode inDomain:CMD_Domain_cam withPara1:s1 andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setHDRMode:mode]];
            break;
        default:
            break;
    }
}

// api 1.9
- (void)getMountAccelLevels {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Mount_Accel_Levels inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAccelDetectLevel]];
            break;
        default:
            break;
    }
}

- (void)setMountAccelLevel:(NSString*)level {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char slevel[32];
            sprintf(slevel, "%s", [level cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_Mount_Accel_Level inDomain:CMD_Domain_cam withPara1:slevel andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAccelDetectLevel:level params:nil]];
            break;
        default:
            break;
    }
}

- (void)getMountAccelParam:(NSString*)level {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char slevel[32];
            sprintf(slevel, "%s", [level cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Get_Mount_Accel_param inDomain:CMD_Domain_cam withPara1:slevel andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAccelDetectLevel]];
            break;
        default:
            break;
    }
}

- (void)setMountAccelForLevel:(NSString*)level Param:(NSString*)param {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char slevel[32];
            sprintf(slevel, "%s", [level cStringUsingEncoding:NSASCIIStringEncoding]);
            char sparam[128];
            sprintf(sparam, "%s", [param cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_Mount_Accel_param inDomain:CMD_Domain_cam withPara1:slevel andPara2:sparam];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAccelDetectLevel:level params:param]];
            break;
        default:
            break;
    }
}

- (void)getIIOEventDetectionParam {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_IIOEventDetectionParam inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getDriveBehaviourDetect]];
            break;
        default:
            break;
    }
}

- (void)setIIOEventDetectionParam:(NSString*)param {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char sparam[128];
            sprintf(sparam, "%s", [param cStringUsingEncoding:NSASCIIStringEncoding]);
            [self sendCmd:CMD_Set_IIOEventDetectionParam inDomain:CMD_Domain_cam withPara1:sparam andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
        {
            [self send:[WLEvcamCmdGenerator setDriveBehaviourDetectParams: param]];
        }
            break;
        default:
            break;
    }
}

- (void)syncTimeEx:(long)timeSince1970 Zone:(int)zoneInSec DaylightSaving:(BOOL)bSaving {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char sparam[256];
            sprintf(sparam, "{\"time\" = %ld, \"timezone\" = %d, \"daylightsaving\" = %s}", timeSince1970, zoneInSec, bSaving ? "true" : "false");
            [self sendCmd:CMD_Synctime_EX inDomain:CMD_Domain_cam withPara1:sparam andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getTimeZone {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_GetTimeZone inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getMarkStorageOptions {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_GetMarkStorage inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMaxMarkSpace]];
            break;
        default:
            break;
    }
}

- (void)setMarkStorage:(int)gb {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char size[8];
            sprintf(size, "%d", gb);
            [self sendCmd:CMD_SetMarkStorage inDomain:CMD_Domain_cam withPara1:size andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setMaxMarkSpaceWithMax:gb]];
            break;
        default:
            break;
    }
}

- (void)getAudioPromptEnabled {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_GetAudioPrompts inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAudioPrompts]];
            break;
        default:
            break;
    }
}

- (void)setAudioPromptEnabled: (BOOL)enabled {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char s1[4];
            if (enabled) {
                strcpy(s1, "on");
            } else {
                strcpy(s1, "off");
            }
            [self sendCmd:CMD_SetAudioPrompts inDomain:CMD_Domain_cam withPara1:s1 andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAudioPromptsWithEnabled: enabled]];
            break;
        default:
            break;
    }
}

- (void)getICCID {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_GetICCID inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getLTEInformation]];
            break;
        default:
            break;
    }
}

- (void)getLTEFirmwareVersion {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_LTE_FWVersion inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getLTEInformation]];
            break;
        default:
            break;
    }
}

// api 1.9 done
// api 1.10
- (void)getLTEStatus {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_LTE_STATUS inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getLTEStatus]];
            break;
        default:
            break;
    }
}
- (void)getRadarSensitivity {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Mount_MW_Sensitivity inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getMWSensitivity]];
            break;
        default:
            break;
    }
}

- (void)setRadarSensitivity:(int)level {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char slevel[8];
            sprintf(slevel, "%d", level);
            [self sendCmd:CMD_Set_Mount_MW_Sensitivity inDomain:CMD_Domain_cam withPara1:slevel andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setMWSensitivityWithLevel:level]];
            break;
        default:
            break;
    }
}

- (void)doDebugProps:(BOOL)setOrGet prop:(NSString*)prop action:(NSString*)action value:(NSString*)value key:(NSString*)key {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:{
            char opration[8];
            if (setOrGet) {
                sprintf(opration, "set");
            } else {
                sprintf(opration, "get");
            }
            NSMutableDictionary* dict = [NSMutableDictionary new];
            if(prop && ![prop isEqualToString:@""]) [dict setObject:prop forKey:@"prop"];
            if(action && ![action isEqualToString:@""]) [dict setObject:action forKey:@"action"];
            [dict setObject:value forKey:@"val"];
            [dict setObject:key forKey:@"magic"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            if (jsonData) {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                char *bytes = (char *)[jsonStr cStringUsingEncoding:NSUTF8StringEncoding];
                [self sendCmd:CMD_DEBUG_PROPS inDomain:CMD_Domain_cam withPara1:opration andPara2:bytes];
            }
        }
            break;
        case CommunicationProtocolVersionEvcam:
            if (setOrGet) {
                [self send:[WLEvcamCmdGenerator setDebugProp:prop val:value]];
            } else {
                [self send:[WLEvcamCmdGenerator getDebugProp:prop]];
            }
            break;
        default:
            break;
    }
}

// api 1.10 done

// api 1.12
- (void)getMountACCTrust {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Mount_ACC_Trust inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getTrustACCStatus]];
            break;
        default:
            break;
    }
}

- (void)setMountACCTrust:(BOOL)trusted {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", trusted);
            [self sendCmd:CMD_Set_Mount_ACC_Trust inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setTrustACCStatus:trusted]];
            break;
        default:
            break;
    }
}

// api 1.12 done
// api 1.13
- (void)getAppKeepAlive {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_KeepAlive_forApp inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getKeepAliveForApp]];
            break;
        default:
            break;
    }
}

- (void)setAppKeepAlive:(BOOL)keep {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", keep);
            [self sendCmd:CMD_Set_KeepAlive_forApp inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setKeepAliveForApp:keep]];
            break;
        default:
            break;
    }
}
- (void)getAttitude {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_Attitude inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAttitude]];
            break;
        default:
            break;
    }
}

- (void)setAttitude:(BOOL)upsidedown {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[32];
            if (upsidedown) {
                sprintf(svalue, "upsidedown");
            } else {
                sprintf(svalue, "normal");
            }
            [self sendCmd:CMD_Set_Attitude inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAttitude: upsidedown ? WLEvcamDeviceAttitudeUpsidedown : WLEvcamDeviceAttitudeNormal]];
            break;
        default:
            break;
    }
}

- (void)getSupportUpsideDown {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Support_UpsideDown inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAttitude]];
            break;
        default:
            break;
    }
}

// api 1.13 done

// api 1.14

- (void)getSupportRiskDriveEvent {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_SupportRiskDriveEvent inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getDriveBehaviourDetect]];
            break;
        default:
            break;
    }
}

- (void)setSupportRiskDriveEvent:(BOOL)supported {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", supported);
            [self sendCmd:CMD_Set_SupportRiskDriveEvent inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setDriveBehaviourDetectEnabled:supported]];
            break;
        default:
            break;
    }
}

- (void)getAPN {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_APN inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getLTEInformation]];
            break;
        default:
            break;
    }
}

- (void)setAPN:(NSString *)apn {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char *param1 = (char*)[apn cStringUsingEncoding:NSUTF8StringEncoding];
            [self sendCmd:CMD_Set_APN inDomain:CMD_Domain_cam withPara1:param1 andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAPN:apn]];
            break;
        default:
            break;
    }
}

- (void)getSupportWlanMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_SupportWlanMode inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getSupportWlanMode]];
            break;
        default:
            break;
    }
}

- (void)getProtectionVoltage {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_ProtectionVoltage inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getProtectionVoltage]];
            break;
        default:
            break;
    }
}

- (void)setProtectionVoltage:(int)voltage {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", voltage);
            [self sendCmd:CMD_Set_ProtectionVoltage inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setProtectionVoltage:voltage]];
            break;
        default:
            break;
    }
}

- (void)getParkSleepDelay {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_ParkSleepDelay inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getParkSleepDelay]];
            break;
        default:
            break;
    }
}

- (void)setParkSleepDelay:(int)delaySeconds {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", delaySeconds);
            [self sendCmd:CMD_Set_ParkSleepDelay inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setParkSleepDelay:delaySeconds]];
            break;
        default:
            break;
    }
}

- (void)getSubStreamOnly {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Rec_Get_SubStreamOnly inDomain:CMD_Domain_rec withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setSubStreamOnly:(BOOL)isOnly {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", isOnly);
            [self sendCmd:CMD_Rec_Set_SubStreamOnly inDomain:CMD_Domain_rec withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getObdWorkMode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_OBDCfg inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)setObdWorkMode:(int)mode {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            char svalue[8];
            sprintf(svalue, "%d", mode);
            [self sendCmd:CMD_Set_OBDCfg inDomain:CMD_Domain_cam withPara1:svalue andPara2:NULL];
        }
            break;
        case CommunicationProtocolVersionEvcam:
            break;
        default:
            break;
    }
}

- (void)getObdWorkModeConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self getObdWorkMode]; // for old model
            [self sendCmd:CMD_Get_OBDTotalCfg inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getObdMode]];
            break;
        default:
            break;
    }
}

- (void)setObdWorkModeConfig:(WLObdWorkModeConfig *)config {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            [self setObdWorkMode:(int)config.mode];

            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[config rawData] options:0 error:&error];
            if (jsonData) {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                char *bytes = (char *)[jsonStr cStringUsingEncoding:NSUTF8StringEncoding];
                [self sendCmd:CMD_Set_OBDTotalCfg inDomain:CMD_Domain_cam withPara1:bytes andPara2:NULL];
            }
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setObdMode:config.mode voltageOn:config.voltageOn.doubleValue voltageOff:config.voltageOff.doubleValue voltageCheck:config.voltageCheck.doubleValue]];
            break;
        default:
            break;
    }
}

- (void)getAdasModeConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAdasConfig]];
            break;
        default:
            break;
    }
}

- (void)setAdasConfig:(WLAdasConfig *)config {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAdasConfig:[config toDict]]];
            break;
        default:
            break;
    }
}

- (void)getAuxConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getAuxConfig]];
            break;
        default:
            break;
    }
}

- (void)setAuxConfig:(int)angle {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setAuxConfigWithAngle:angle]];
            break;
        default:
            break;
    }
}

- (void)getVirtualIgnitionConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_Get_VtIgtCfg inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getVirtualIgnitionConfig]];
            break;
        default:
            break;
    }
}

- (void)setVirtualIgnitionConfigWithEnable:(BOOL)enable {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{ @"enable" : @(enable) } options:0 error:&error];
            
            if (jsonData) {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                char *bytes = (char *)[jsonStr cStringUsingEncoding:NSUTF8StringEncoding];
                [self sendCmd:CMD_Set_VtIgtCfg inDomain:CMD_Domain_cam withPara1:bytes andPara2:NULL];
            }
        }
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setVirtualIgnitionConfigWithEnable:enable]];
            break;
        default:
            break;
    }
}

/////////////////////// ↓ Evcam ↓ ///////////////////////

- (void)transferFirmware:(NSData *)firmwareData size:(int)firmwareSize md5:(NSString *)md5 rebootNeeded:(BOOL)rebootNeeded {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator transferFirmwareWithSize:firmwareSize md5:md5 reboot:rebootNeeded] attachedData:firmwareData];
            break;
        default:
            break;
    }
}

- (void)getUserFileList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
//            [self send:[EvcamCmdGenerator getUserFileList]];
            break;
        default:
            break;
    }
}

- (void)getRecordConfigList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getRecordConfigList]];
            break;
        default:
            break;
    }
}

- (void)getRecordConfig {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getRecordConfig]];
            break;
        default:
            break;
    }
}

- (void)setRecordConfig:(NSString *)recordConfig bitrateFactor:(int)bitrateFactor forceCodec:(int)forceCodec {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setRecordConfig:recordConfig bitrateFactor:bitrateFactor forceCodec:forceCodec]];
            break;
        default:
            break;
    }
}

- (void)setVinMirror:(NSArray *)vinMirrorList {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setVinMirror:vinMirrorList]];
            break;
        default:
            break;
    }
}

- (void)getVinMirror {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionEvcam:
        {
            [self send:[WLEvcamCmdGenerator getVinMirror]];

        }
            break;
        default:
            break;
    }
}

/////////////////////// ↑ Evcam ↑ ///////////////////////

// api 1.14 done

#pragma mark -- private
- (void)sendCmd:(int)cmdCode inDomain:(int)domain
      withPara1:(char*)p1 andPara2:(char*)p2 {
    NSLog(@"CameraClient Send CMD:%d Domain:%d", cmdCode, domain);
    EnumedStringCMD cmd(domain, cmdCode, p1, p2);
    StringCMD* p = &cmd;
    StringEnvelope ev(&p, 1);
    [self sendCMD:ev.getBuffer()Length:ev.getBufferLen()];
}
- (void)sendCMD:(char*)data Length:(int)len {
    SessionDataHead head;
    if(len > sizeof(head.data)) {
        memcpy(head.data, data, sizeof(head.data));
        head.appendLength = (int)(len - sizeof(head.data));
        head.length = sizeof(head)+ head.appendLength;
    } else {
        memset(head.data, 0, sizeof(head.data));
        memcpy(head.data, data, len);
        head.appendLength = 0;
        head.length = sizeof(head);
    }
    NSMutableData* pdata = [NSMutableData dataWithBytes:&head length:sizeof(head)];
    if(len > sizeof(head.data)) {
        [pdata appendBytes:(data + sizeof(head.data)) length:head.appendLength];
    }
    [self sendData:pdata withTimeout:5];
}

- (void)sendHeartBeat {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            [self sendCmd:CMD_fw_getVersion inDomain:CMD_Domain_cam withPara1:NULL andPara2:NULL];
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator keepAliveForApp]];
            [self send:[WLEvcamCmdGenerator getKeepAliveForApp]];
            break;
        default:
            break;
    }
}

// for MK

- (void)setConfigSettingMK:(NSDictionary *)config cmd:(NSString *)cmd {
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator setConfigSettingMK:config cmd:cmd]];
            break;
        default:
            break;
    }
}


- (void)getConfigSettingMK:(NSString *)cmd{
    switch (self.cameraClientDelegate.protocolVersion) {
        case CommunicationProtocolVersionCamClient:
            break;
        case CommunicationProtocolVersionEvcam:
            [self send:[WLEvcamCmdGenerator getConfigSettingMKWithCmd:cmd]];
            break;
        default:
            break;
    }
}


@end
