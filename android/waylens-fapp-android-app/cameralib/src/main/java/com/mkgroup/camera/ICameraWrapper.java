package com.mkgroup.camera;

import com.mkgroup.camera.message.bean.AuxCfgModel;
import com.mkgroup.camera.message.bean.HotspotInfoModel;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.message.bean.TransferInfoBean;
import com.mkgroup.camera.direct.PairedDevices;
import com.mkgroup.camera.log.CmdRequestFuture;
import com.mkgroup.camera.model.rawdata.RawDataItem;

import java.util.List;

public interface ICameraWrapper {

    void handleMessage(int domain, int code, String p1, String p2);

    void handleEvCamMessage(String category, String msg, String body);

    void initCameraState();

//    void doBtUnbind(int type, String mac);

//    void doBind(int type, String mac);

    String getName();

    void setName(String name);

    String getApiVersion();

    String getPassword();

    String getCameraServer();

    void setCameraServer(String server);

    CmdRequestFuture<Integer> prepareLog();

    CmdRequestFuture<Integer> prepareLog(String date);

    CmdRequestFuture<Integer> prepareDebugLog();

//    void powerOff();

//    void reboot();

    void queryStorageState();

    int getMonitorMode();

    void factoryReset();

    void setMicEnabled(boolean enabled);

    void setAudioPromptsEnabled(boolean enabled);

    void setLensNormal(boolean isNormal);

    void removePaired(String mac);

    void sendNewFirmware(int size, String md5, OnNewFwVersionListener listener);

    MountSetting getMountSettings(boolean refresh);

    void setMountSettings(String setting);

    String getBspFirmware();

    int getHdrMode();

    void setHdrMode(int hdrMode);

    void sendFormatSDCard();

    void markLiveVideo();

    void stopRecording();

    void startRecording();

    boolean isPromptsEnabled();

//    void setMarkTime(int before, int after);

    int getRadarSensitivity();

    void setRadarSensitivity(int sensitivity);

    int getMountAccTrust();

    void setMountAccTrust(boolean trust);

    boolean getP2pEnable();

    void setP2pEnable(boolean enable);

    PairedDevices getPairedDevices();

    boolean getIsLensNormal();

    String getApnSetting();

    void setApnSetting(String apn);

    boolean getSupportWlan();

    boolean getSupportRiskEvent();

    void setSupportRiskEvent(boolean support);

    String getEventParam();

    void setEventParam(String param);

    int getProtectVoltage();

    void setProtectVoltage(int voltage);

    int getParkSleepDelay();

    void setParkSleepDelay(int delay);

    String getModemVersion();

    int getMarkStorage();

    void setMarkStorage(int index);

    int getMountLevel();

    void setMountLevel(int index);

    int getWifiMode();

    String getIccid();

    void getDeviceTime();

    void setDeviceTime(long syncTime, long syncTimeZone);

    void getMountSensitivity();

    HotspotInfoModel getHotspotInfo();

    void setHotspotInfo(String ssid, String key);

    int getVirtualIgnition();

    void setVirtualIgnition(boolean enable);

    AuxCfgModel getAuxCfg();

    void setAuxCfg(AuxCfgModel model, int angle);

    boolean isNightVisionInDrivingAvailable();

    boolean isPowerCordTestAvailable();

    boolean isMarkSpaceSettingsAvailable();

    boolean isAudioPromptsAvailable();

    boolean isModemVersionAvailable();

    boolean isNetworkTestDiagnosisAvailable();

    boolean isHDRAutoAvailable();

    boolean isNightVisionAutoAvailable();

    boolean isSupportUntrustACCWireAvailable();

    // isGPSInfoInVideoOverlayAvailable

    boolean isWifiDirectAvailable();

    boolean isDrivingModeTimeoutSettingsAvailable();

    boolean isProtectionVoltageAvailable();

    boolean isAPNSettingsAvailable();

    boolean isSubStreamOnlyAvailable();

    boolean isWLanModeAvailable();

    boolean isRiskyDrivingEventAvailable();

    boolean isVinMirrorAvailable();

    boolean isMacWlan0Available();

    boolean isSradarAvailable();

    boolean isExBoardvailable();

    boolean isRecordConfigAvailable();

    boolean isCalibCameraAvailable();

    boolean isVirtualIgnitionAvailable();

    boolean isAdasCfgAvailable();

    boolean isAuxCfgAvailable();

    enum Model {
        Horizon, TW02, TW03, TW06
    }

    interface OnConnectionChangeListener {
        void onConnected(CameraWrapper camera);

        void onConnectionFailed(CameraWrapper camera);

        void onVdbConnected(CameraWrapper camera);

        void onDisconnected(CameraWrapper camera);
    }

    interface OnRawDataUpdateListener {
        void OnRawDataUpdate(CameraWrapper camera, List<RawDataItem> item);
    }

    interface OnNewFwVersionListener {
        void onNewVersion(int response);

        void onTransfer(TransferInfoBean bean);
    }
}
