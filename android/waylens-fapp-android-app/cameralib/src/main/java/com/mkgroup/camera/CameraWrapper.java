package com.mkgroup.camera;

import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_FW_DO_UPGRADE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_ATTITUDE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_EVENT_DETECTION_PARAM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.VDT_CAM_PORT;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.mkgroup.camera.message.bean.BoolMsg;
import com.mkgroup.camera.message.bean.CarrierBean;
import com.mkgroup.camera.message.bean.DriverInfoBody;
import com.mkgroup.camera.message.bean.HotspotInfoModel;
import com.mkgroup.camera.message.bean.INOUTBody;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.message.bean.MountVersion;
import com.mkgroup.camera.message.bean.PowerStateBean;
import com.mkgroup.camera.message.bean.SIMDATABean;
import com.mkgroup.camera.message.bean.SettingCfgBean;
import com.mkgroup.camera.message.bean.TCVN01Bean;
import com.mkgroup.camera.message.bean.TCVN02Bean;
import com.mkgroup.camera.message.bean.TCVN03Bean;
import com.mkgroup.camera.message.bean.TCVN04Bean;
import com.mkgroup.camera.message.bean.TCVN05Bean;
import com.mkgroup.camera.model.fms.SendDataFWEvent;
import com.mkgroup.camera.model.fms.SendDataFWResponse;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.connectivity.IPLink;
import com.mkgroup.camera.connectivity.VdtCameraCommunicationBus;
import com.mkgroup.camera.data.vdb.BasicVdbSocket;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbConnection;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;
import com.mkgroup.camera.data.vdb.VdbSocket;
import com.mkgroup.camera.direct.PairedDevices;
import com.mkgroup.camera.event.ApnChangeEvent;
import com.mkgroup.camera.event.AudioPromptsChangeEvent;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.event.ClipInfoMsgEvent;
import com.mkgroup.camera.event.EventParamChangeEvent;
import com.mkgroup.camera.event.HdrModeChangeEvent;
import com.mkgroup.camera.event.HotspotInfoEvent;
import com.mkgroup.camera.event.LensChangeEvent;
import com.mkgroup.camera.event.MarkLiveMsgEvent;
import com.mkgroup.camera.event.MicrophoneChangeEvent;
import com.mkgroup.camera.event.MountAccTrustChangeEvent;
import com.mkgroup.camera.event.MountSettingChangeEvent;
import com.mkgroup.camera.event.MountVersionEvent;
import com.mkgroup.camera.event.P2PEnableChangeEvent;
import com.mkgroup.camera.event.PairedListEvent;
import com.mkgroup.camera.event.RadarSensitivityChangeEvent;
import com.mkgroup.camera.event.SDCardStateEvent;
import com.mkgroup.camera.event.SenseLevelChangeEvent;
import com.mkgroup.camera.event.SleepDelayChangeEvent;
import com.mkgroup.camera.event.SupportWlanChangeEvent;
import com.mkgroup.camera.event.TCVNEvent;
import com.mkgroup.camera.event.VdbReadyInfo;
import com.mkgroup.camera.event.VideoSpaceChangeEvent;
import com.mkgroup.camera.event.VirtualIgnitionEvent;
import com.mkgroup.camera.event.VoltageChangeEvent;
import com.mkgroup.camera.log.CmdRequestFuture;
import com.mkgroup.camera.model.VdbSpaceInfoEvent;
import com.mkgroup.camera.toolbox.ClipInfoMsgHandler;
import com.mkgroup.camera.toolbox.MarkLiveMsgHandler;
import com.mkgroup.camera.toolbox.RawDataMsgHandler;
import com.mkgroup.camera.toolbox.SpaceInfoMsgHandler;
import com.mkgroup.camera.toolbox.VdbReadyMsgHandler;
import com.mkgroup.camera.toolbox.VdbUnmountedMsgHandler;
import com.mkgroup.camera.utils.ClipsManager;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.StringUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.concurrent.CountDownLatch;

import io.reactivex.subjects.BehaviorSubject;

public abstract class CameraWrapper implements ICameraWrapper, CameraConstants {

    final static String LENS_NORMAL = "normal";
    final static String LENS_UPSIDEDOWN = "upsidedown";
    private final static String TAG = CameraWrapper.class.getSimpleName();
    private final static String SDCARD_TYPE = "AGTSV1.2_vfat";
    private final static String SDCARD_TYPE_PREFIX = "AGTSV";
    public int hdr_mode = HDR_MODE_UNKNOWN;
    public boolean mIsShowCamera = true;
    String linkForm; // 区分wifi和p2p
    RxBus mRxBus = RxBus.getDefault();
    InfoMsgQueue infoMsgQueue;
    BehaviorSubject<CameraWrapper> statusSubject = BehaviorSubject.create();
    VdtCameraCommunicationBus mCommunicationBus;
    Gson gson = new GsonBuilder().create();
    CmdRequestFuture<Integer> prepareLogFuture;
    String mSerialNumber = "";
    String mBspVersion = "";
    String mHardwareName;
    Model mHardwareModel;
    String mApiVersionStr = "";
    String mPassword = "";
    String mCameraServer;
    int mMicVol = 7;
    int mPromptsState = AUDIO_PROMPTS_MODE_UNKNOWN;
    String mIccid = "";
    String modemVersion = "";
    int mRadarSensitivity = 0;
    int mMountAccTrust = MOUNT_ACC_UNKNOWN;
    boolean mP2pEnable = false;
    boolean mIsLensNormal = true;
    String[] videoSpaceList;
    int mVideoSpace = 0;
    String[] mountLevelList;
    int mMountLevel = -1;
    String mMountParam = "";
    int mBatteryLevel = BATTERY_CAPACITY_LEVEL_UNKNOWN;
    /**
     * voltage in milli
     */
    int mVoltageNow = -1;
    int mGpsState = -1;
    long mStorageTotalSpace = 0;
    long mStorageFreeSpace = 0;
    boolean shouldFormatStorage = false;
    int mRecordTime = 0;
    int mOverlayFlags = 0;
    int mVideoResolutionList = 0;
    int mVideoResolutionIndex = VIDEO_RESOLUTION_UNKNOWN;
    int mMainStreamQuality = VIDEO_QUALITY_UNKNOWN;
    int mSubStreamQuality = VIDEO_QUALITY_UNKNOWN;
    boolean mSubStreamOnly = false;
    String mApnSetting = null;
    boolean mSupportWlan = false;
    boolean mSupportRiskEvent = false;
    String mEventParam = null;
    int mProtectVoltage = 0;
    int mParkSleepDelay = 0;
    int mRecordModeList = 0;
    int mRecordModeIndex = REC_MODE_UNKNOWN;
    int mColorModeList = 0;
    int mColorModeIndex = COLOR_MODE_UNKNOWN;
    int mMarkBeforeTime = -1;
    int mMarkAfterTime = -1;
    int mDisplayBrightness = 0;
    String mAutoOffTime = null;
    String mAutoPowerOffDelay = null;
    String mScreenSaverStyle = null;
    int mWifiMode = WIFI_MODE_UNKNOWN;
    int mNumWifiAP = 0;
    List<String> mSsidList = new ArrayList<>();
    boolean mIfRotate = false;
    int mScannedBtDeviceNumber = 0;
    MountSetting mountSetting = new MountSetting();
    PairedDevices pairedDevices = new PairedDevices();
    HotspotInfoModel hotspotInfoModel = null;
    int monitorMode = MONITOR_MODE_UNKNOWN;
    OnNewFwVersionListener mOnNewFwVersionListener = null;
    String mCameraName = "";
    int mVirtualIgnitionEnable = VIRTUAL_IGNITION_UNKNOWN;
    private CountDownLatch mInitLatch; // 延迟显示相机连接或断连
    private ClipsManager mClipsManager;
    private int mApiVersion = 0;
    private String mBuild = "";
    private int mMicState = STATE_MIC_UNKNOWN;
    private volatile boolean reportIccid = false;
    private volatile boolean reportSettingTag = false;
    private String lteStatus = "";
    private String modemVersionDebug = "";
    private boolean mUpsidedownEnable = false;
    private boolean mNeedDewarp = false;
    private int mBatteryState = STATE_BATTERY_UNKNOWN;
    private int mPowerState = STATE_POWER_UNKNOWN;
    private int mStorageState = STATE_STORAGE_UNKNOWN;
    private int mRecordState = STATE_RECORD_UNKNOWN;
    //    int mBtState = BT_STATE_UNKNOWN;
    private ServiceInfo mServiceInfo;
    private InetSocketAddress mAddress;
    private VdbRequestQueue mVdbRequestQueue;
    private MountVersion mountVersion = new MountVersion();
    private boolean supportRadarSensitivity = false;
    private WeakReference<OnRawDataUpdateListener> mOnRawDataUpdateListener;
    private OnConnectionChangeListener mOnConnectionChangeListener;
    private VdbConnection mVdbConnection;

    public CameraWrapper(ServiceInfo serviceInfo, final OnConnectionChangeListener listener) {
        mInitLatch = new CountDownLatch(1);
        infoMsgQueue = new InfoMsgQueue();
        mServiceInfo = serviceInfo;

        mOnConnectionChangeListener = listener;
        mAddress = new InetSocketAddress(serviceInfo.inetAddr, serviceInfo.port);
        mCommunicationBus = new VdtCameraCommunicationBus(mAddress, new VdtCameraCommunicationBus.ConnectionChangeListener() {
            @Override
            public void onConnected() {
                initCameraState();
                try {
                    mInitLatch.await();
//                    if (mIsShowCamera) {
                    onCameraConnected();
                    statusSubject.onNext(CameraWrapper.this);
//                    } else {
//                        onCameraDisconnected();
//                    }
                } catch (InterruptedException e) {
                    Logger.t(TAG).d("init status error", e.getMessage());
                }
            }

            @Override
            public void onConnectionFailed() {
                if (mOnConnectionChangeListener != null) {
                    mOnConnectionChangeListener.onConnectionFailed(CameraWrapper.this);
                }
            }

            @Override
            public void onDisconnected() {
                onCameraDisconnected();
            }
        }, new VdtCameraCommunicationBus.CameraMessageHandler() {
            @Override
            public void handleMessage(int domain, int code, String p1, String p2) {
                CameraWrapper.this.handleMessage(domain, code, p1, p2);
            }

            @Override
            public void handleEvCamMessage(String category, String msg, String body) {
                CameraWrapper.this.handleEvCamMessage(category, msg, body);
            }
        });

        mCommunicationBus.start();
        mClipsManager = new ClipsManager();
    }

    static int getBatteryLevelWithString(String str) {
        switch (str) {
            case BATTERY_CAPACITY_CRITICAL_VALUE:
                return BATTERY_CAPACITY_LEVEL_CRITICAL;
            case BATTERY_CAPACITY_LOW_VALUE:
                return BATTERY_CAPACITY_LEVEL_LOW;
            case BATTERY_CAPACITY_NORMAL_VALUE:
                return BATTERY_CAPACITY_LEVEL_NORMAL;

            case BATTERY_CAPACITY_HIGH_VALUE:
                return BATTERY_CAPACITY_LEVEL_HIGH;

            case BATTERY_CAPACITY_FULL_VALUE:
                return BATTERY_CAPACITY_LEVEL_FULL;
            default:
                return BATTERY_CAPACITY_LEVEL_UNKNOWN;
        }
    }

    private void onCameraConnected() {
        InetSocketAddress addr = mAddress;
        if (addr != null) {
//            InetSocketAddress mPreviewAddress = new InetSocketAddress(addr.getAddress(), 8081);
            if (mOnConnectionChangeListener != null) {
                mOnConnectionChangeListener.onConnected(this);
            }
        }
        mVdbConnection = new VdbConnection(getHostString());

        int retryCount = 0;
        retryConnect(retryCount);
    }

    public String getHostString() {
        return mServiceInfo.inetAddr.getHostAddress();
    }

    private void retryConnect(int retryCount) {
        if (retryCount < 3) {
            try {
                //此处如果连接失败会抛出异常
                mVdbConnection.connect();
                Logger.t(TAG).d("vdbConnection: " + mVdbConnection.isConnected());

                VdbSocket vdbSocket = new BasicVdbSocket(getVdbConnection());
                mVdbRequestQueue = new VdbRequestQueue(vdbSocket);
                mVdbRequestQueue.start();
                if (mOnConnectionChangeListener != null) {
                    mOnConnectionChangeListener.onVdbConnected(CameraWrapper.this);
                }
                registerMessageHandler();

            } catch (IOException | InterruptedException e) {
                Logger.t(TAG).e("vdbConnection exception: " + e.getMessage());
                retryConnect(retryCount + 1);
            }
        } else {
            //三次失败以后断连，等待再次连接
            releaseConnection();
        }
    }

    public VdbConnection getVdbConnection() {
        return mVdbConnection;
    }

    private void registerMessageHandler() {
        RawDataMsgHandler rawDataMsgHandler = new RawDataMsgHandler(response -> {
//            Logger.t(TAG).d("receive raw data item");
            if (mOnRawDataUpdateListener != null) {
                OnRawDataUpdateListener listener = mOnRawDataUpdateListener.get();
                if (listener != null) {
                    listener.OnRawDataUpdate(CameraWrapper.this, response);
                }
            }
        }, error -> Logger.t(TAG).e("RawDataMsgHandler ERROR " + error.getMessage()));
        mVdbRequestQueue.registerMessageHandler(rawDataMsgHandler);

        ClipInfoMsgHandler clipInfoMsgHandler = new ClipInfoMsgHandler(
                response -> {
//                        Logger.t(TAG).d("ClipInfoMsgHandler onResponse: " + response.toString());
                    mRxBus.post(new ClipInfoMsgEvent(CameraWrapper.this, response));
                },
                error -> Logger.t(TAG).d("ClipInfoMsgHandler ERROR: " + error));
        mVdbRequestQueue.registerMessageHandler(clipInfoMsgHandler);

        MarkLiveMsgHandler markLiveMsgHandler = new MarkLiveMsgHandler(
                response -> {
//                        Logger.t(TAG).d("MarkLiveMsgHandler onResponse: " + response.toString());
                    mRxBus.post(new MarkLiveMsgEvent(CameraWrapper.this, response, false));
                },
                error -> Logger.t(TAG).d("MarkLiveMsgHandler ERROR: " + error));
        mVdbRequestQueue.registerMessageHandler(markLiveMsgHandler);

        VdbReadyMsgHandler vdbReadyMsgHandler = new VdbReadyMsgHandler(
                response -> {
                    mRxBus.post(new VdbReadyInfo(true));
                    infoMsgQueue.clearMsg(InfoMsgQueue.E_NO_SDCARD_INSERT);
//                        Logger.t(TAG).d("handling vdbReadyMsg");
                },
                error -> Logger.t(TAG).d("VdbReadyMsgHandler ERROR" + error));
        mVdbRequestQueue.registerMessageHandler(vdbReadyMsgHandler);

        VdbUnmountedMsgHandler vdbUnmountedMsgHandler = new VdbUnmountedMsgHandler(
                response -> {
                    infoMsgQueue.putMsg(InfoMsgQueue.E_NO_SDCARD_INSERT);
                    mRxBus.post(new VdbReadyInfo(false));
//                        Logger.t(TAG).d("handling vdbUnmountedMsg");
                },
                error -> Logger.t(TAG).d("VdbUnmountedMsgHandler ERROR"));
        mVdbRequestQueue.registerMessageHandler(vdbUnmountedMsgHandler);

        SpaceInfoMsgHandler spaceInfoMsgHandler = new SpaceInfoMsgHandler(response -> {
            mRxBus.post(new VdbSpaceInfoEvent(CameraWrapper.this, response));
//                Logger.t(TAG).d("handling vdbSpaceInfoMsg");
        }, error -> Logger.t(TAG).d("SpaceInfoMsgHandler ERROR"));

        mVdbRequestQueue.registerMessageHandler(spaceInfoMsgHandler);

    }

    private void onCameraDisconnected() {

//        mVdbRequestQueue.stop();
        if (mVdbRequestQueue != null) {
            mVdbRequestQueue.unregisterMessageHandler(VdbCommand.Factory.MSG_RawData);
            mVdbRequestQueue.unregisterMessageHandler(VdbCommand.Factory.MSG_ClipInfo);
            mVdbRequestQueue.unregisterMessageHandler(VdbCommand.Factory.MSG_MarkLiveClipInfo);
        }

        if (mOnConnectionChangeListener != null) {
            mOnConnectionChangeListener.onDisconnected(this);
        }
    }

    public void releaseConnection() {
        mCommunicationBus.releaseConnection();
    }

    public BehaviorSubject<CameraWrapper> cameraStatus() {
        return statusSubject;
    }

    void ack_Cam_Get_ApiVersion(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_ApiVersion p1=" + p1);
        mApiVersionStr = p1;
        int main = 0, sub = 0;
        String build = "";
        int i_main = p1.indexOf('.');
        if (i_main >= 0) {
            String t = p1.substring(0, i_main);
            main = Integer.parseInt(t);
            i_main++;
            int i_sub = p1.indexOf('.', i_main);
            if (i_sub >= 0) {
                t = p1.substring(i_main, i_sub);
                sub = Integer.parseInt(t);
                i_sub++;
                build = p1.substring(i_sub);
            }
        }
        setApiVersion(main, sub, build);
    }

    private void setApiVersion(int main, int sub, String build) {
        int version = makeVersion(main, sub);
        if (mApiVersion != version || !mBuild.equals(build)) {
            mApiVersion = version;
            mBuild = build;
        }
    }

    public boolean getSupportUpsidedown() {
//        mCommunicationBus.sendCAMCommand(CMD_SUPPORT_UPSIDEDOWN, "", "");
        return mUpsidedownEnable;
    }

    public boolean getNeedDewarp() {
        return mNeedDewarp;
    }

    public String getHardwareName() {
        return mHardwareName;
    }

    public Model getHardwareModel() {
        return mHardwareModel;
    }

    public MountVersion getMountVersion() {
        return mountVersion;
    }


    private int makeVersion(int main, int sub) {
        return (main << 16) | sub;
    }

    void ack_Cam_Get_FW_Version(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_Get_FW_Version p1=" + p1 + ", p2=" + p2);
        setFirmwareVersion(p1, p2);
        if (mInitLatch.getCount() > 0) {
            mInitLatch.countDown();
        }
    }

    public int getBatteryLevel() {
        return mBatteryLevel;
    }

    public int getBatteryState() {
        return mBatteryState;
    }

    public int getVoltageNow() {
        return mVoltageNow;
    }

    public int getPowerState() {
        return mPowerState;
    }

    public String[] getMarkStorageList() {
//        mCommunicationBus.sendCAMCommand(CMD_GETMARKSTORAGE, "", "");
        return videoSpaceList;
    }

    public int getStorageState() {
        return mStorageState;
    }

    private void setFirmwareVersion(String hardwareName, String bspVersion) {
        Logger.t(TAG).i("setFirmwareVersion hardwareName: " + hardwareName + " bspVersion: " + bspVersion);
        int separatorIndex = hardwareName.indexOf("@");
        if (separatorIndex > 0) {
            mHardwareName = hardwareName.substring(separatorIndex + 1);
            String substring = hardwareName.substring(0, separatorIndex);

            //相机间切换连接时，释放掉连接后重连
            if (!TextUtils.isEmpty(mSerialNumber) && !mSerialNumber.equals(substring)) {
                mCommunicationBus.releaseConnection();
                IPLink.linkIP();
            }
            mSerialNumber = substring;
        }

        final String finalHardwareName = this.mHardwareName;

        Logger.t(TAG).d("mHardwareName: " + finalHardwareName);
        Logger.t(TAG).d("mSerialNumber: " + mSerialNumber);

        mNeedDewarp = !finalHardwareName.startsWith(EV_MODEL) && !finalHardwareName.startsWith(EV_TAG)
                && !finalHardwareName.startsWith(TMP_MODEL) && !finalHardwareName.startsWith(TMP_TAG)
                && !finalHardwareName.startsWith(ES_MODEL);

        mHardwareModel = checkHardwareModel(finalHardwareName);

//        if (Constants.isFleet()) {
//            //是否访问2c camera
//            boolean accessToC = PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, false);
//            if (!mHardwareName.contains(accessToC ? HW_MODEL : HW_MODEL_2B_ONYL)
//                    && !mHardwareName.contains(accessToC ? HW_TAG : HW_TAG_2B_ONLY)
////                    && !mHardwareName.contains(accessToC ? EV_MODEL : EV_MODEL_2B_ONYL)) {
//                    && !mHardwareName.contains(EV_MODEL)
//                    && !mHardwareName.contains(EV_TAG)
//                    && !mHardwareName.contains(TMP_MODEL)
//                    && !mHardwareName.contains(TMP_TAG)
//                    && !mHardwareName.contains(ES_MODEL)) {
//                mIsShowCamera = false;
//                mRxBus.post(new AppMismatchEvent(AppMismatchEvent.App.Fleet));
//            } else {
//                mIsShowCamera = true;
//            }
//        } else {
//            //是否访问2b camera
//            boolean accessToB = PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, false);
//            if (!mHardwareName.contains(accessToB ? HW_MODEL : HW_MODEL_2C_ONLY)
//                    && !mHardwareName.contains(accessToB ? HW_TAG : HW_TAG_2C_ONLY)
////                    && !mHardwareName.contains(accessToB ? EV_MODEL : EV_MODEL_2C_ONLY)) {
//                    && !mHardwareName.contains(EV_MODEL)
//                    && !mHardwareName.contains(EV_TAG)
//                    && !mHardwareName.contains(TMP_MODEL)
//                    && !mHardwareName.contains(TMP_TAG)
//                    && !mHardwareName.contains(ES_MODEL)) {
//                mIsShowCamera = false;
//                mRxBus.post(new AppMismatchEvent(AppMismatchEvent.App.Secure360));
//            } else {
//                mIsShowCamera = true;
//            }
//        }

//        mIsShowCamera = true;
//
//        if (mIsShowCamera) {
//            //判断相机版本后再校验时区，时间
//            getDeviceTime();
//        }

        if (mHardwareModel == Model.TW02) {
            getDeviceTime();
        }

        if (!mBspVersion.equals(bspVersion)) {
//          Logger.t(TAG).d("setFirmwareVersion: " + version);
            mBspVersion = bspVersion;
        }
    }

    private Model checkHardwareModel(String hardwareName) {
        if (hardwareName.startsWith(HW_MODEL) || hardwareName.startsWith(HW_TAG)) {
            return Model.TW02;
        } else if (hardwareName.startsWith(EV_MODEL) || hardwareName.startsWith(EV_TAG)
                || hardwareName.startsWith(TMP_MODEL) || hardwareName.startsWith(TMP_TAG)) {
            return Model.TW06;
        } else if (hardwareName.startsWith(ES_MODEL)) {
            return Model.TW03;
        }
        return Model.TW02;
    }

    void ack_Cam_Get_DeviceTime(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_DeviceTime p1=" + p1 + ", p2=" + p2);
        int ret1 = Integer.parseInt(p1);
        int ret2 = Integer.parseInt(p2) / -3600;

        syncTimezone(ret1, ret2);
    }

    private void syncTimezone(int ret1, int ret2) {
        Date date = new Date(System.currentTimeMillis());
        long timeZoneOffset = TimeZone.getDefault().getOffset(date.getTime());

        long syncTime = date.getTime() / 1000;
        long syncTimeZone = timeZoneOffset / (3600 * 1000);
        Logger.t(TAG).d("sync time = " + Math.abs(syncTime - ret1));
        Logger.t(TAG).d("sync timeZone = " + (syncTimeZone == ret2));

        if (syncTimeZone != ret2 || Math.abs(syncTime - ret1) > 60) {
            setDeviceTime(syncTime, syncTimeZone);
        }
    }

    void ack_Cam_Get_NameResult(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_NameResult p1=" + p1 + ", p2=" + p2);
        setCameraName(p1);
    }

    private void setCameraName(String name) {
        if (name == null || name.isEmpty()) {
            // use empty string for unnamed camera
            name = "No name";
        }
        if (!mCameraName.equals(name)) {
            Logger.t(TAG).d("setCameraName: " + name);
            mCameraName = name;
            mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_INFO, this));
        }
    }

    void ack_Cam_StorageInfo(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_StorageInfo p1=" + p1 + ", p2=" + p2);
        try {
            mStorageState = Integer.parseInt(p1);
            mRxBus.post(new SDCardStateEvent(mStorageState, this));

            switch (mStorageState) {
                case STATE_STORAGE_NO_STORAGE:
                    infoMsgQueue.putMsg(InfoMsgQueue.E_NO_SDCARD_INSERT);
                    break;
                case STATE_STORAGE_ERROR:
                    infoMsgQueue.putMsg(InfoMsgQueue.E_SDCARD_ERROR);
                    break;
                default:
                    break;
            }
            if (TextUtils.isEmpty(p2) || !p2.startsWith(SDCARD_TYPE_PREFIX)) {
                shouldFormatStorage = true;
                infoMsgQueue.putMsg(InfoMsgQueue.W_SDCARD_SHOULD_FORMAT);
            } else {
                shouldFormatStorage = false;
                infoMsgQueue.clearMsg(InfoMsgQueue.W_SDCARD_SHOULD_FORMAT);
            }
        } catch (NumberFormatException ex) {
            Logger.t(TAG).d("ack_Cam_StorageInfo exception = " + ex.getMessage());
        }
    }

    public void setVdbRequestQueue(VdbRequestQueue queue) {
        this.mVdbRequestQueue = queue;
    }


    public boolean isShouldFormatStorage() {
        return shouldFormatStorage;
    }

    public String getLteStatus() {
        return lteStatus;
    }

    public int getRecordState() {
        return mRecordState;
    }


    void ack_Cam_MicInfo(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_MicInfo p1=" + p1 + ", p2=" + p2);
        try {
            int state = Integer.parseInt(p1);
            int vol = Integer.parseInt(p2);
            mMicState = state;
            mMicVol = vol;
            mRxBus.post(new MicrophoneChangeEvent(this, mMicState));
        } catch (Exception ex) {
            Logger.t(TAG).d("ack_Cam_MicInfo exception = " + ex.getMessage());
        }
    }

    void ack_Cam_Get_SpeakerStatus(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_SpeakerStatus p1=" + p1 + ", p2=" + p2);
//        try {
//            if (!TextUtils.isEmpty(p1)) {
//                int mSpeakerState = Integer.parseInt(p1);
//            }
//            if (!TextUtils.isEmpty(p2)) {
//                int mSpeakerVol = Integer.parseInt(p2);
//            }
//        } catch (Exception e) {
//            Logger.t(TAG).d("ack_Cam_Get_SpeakerStatus exception = " + e.getMessage());
//        }
    }

    void ack_Cam_Get_MountAccelLevels(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_Get_MountAccelLevels p1=" + p1 + ", p2=" + p2);
        mountLevelList = StringUtils.filterString(p1);
        mMountLevel = -1; //重置
        for (int i = 0; i < mountLevelList.length; i++) {
//            Logger.t(TAG).d("p2: " + p2 + "--" + mountLevelList[i]);
            if (p2.equals(mountLevelList[i])) {
                mMountLevel = i;
                break;
            }
        }
        mRxBus.post(new SenseLevelChangeEvent(this, mMountLevel));
    }

    void ack_Cam_Get_MountSensitivity(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_MountSensitivity p1=" + p1 + ", p2=" + p2);
        mRadarSensitivity = Integer.parseInt(p1);
        mRxBus.post(new RadarSensitivityChangeEvent(this, mRadarSensitivity));
    }

    void ack_Cam_Get_SupportRiskDriveEvent(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_SupportRiskDriveEvent p1=" + p1 + ", p2=" + p2);
        mSupportRiskEvent = Integer.parseInt(p1) == 1;
        if (mSupportRiskEvent) {
            if (mServiceInfo.isVdtCamera) {
                mCommunicationBus.sendCAMCommand(CMD_GET_EVENT_DETECTION_PARAM, "", "");
            }
        }
    }

    void ack_Cam_Get_EventDetectionParam(String p1) {
        //p1=[220, -330, 395, 15, 15, 15]
//        Logger.t(TAG).d("ack_Cam_Get_EventDetectionParam p1=" + p1 + ", p2=" + p2);
        mEventParam = p1;
        mRxBus.post(new EventParamChangeEvent(this, mEventParam));
    }

    void ack_Cam_Get_P2P_Enable(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_P2P_Enable p1=" + p1 + ", p2=" + p2);
        mP2pEnable = Integer.parseInt(p1) == 1;
        mRxBus.post(new P2PEnableChangeEvent(this, mP2pEnable));
    }

    void ack_Cam_Get_P2P_PairedList(String p1) {
        Logger.t(TAG).d("ack_Cam_Get_P2P_PairedList p1=" + p1);
        try {
            PairedDevices devices = gson.fromJson(p1, new TypeToken<PairedDevices>() {
            }.getType());
            pairedDevices = devices;
            mRxBus.post(new PairedListEvent(devices, this));
        } catch (Exception ex) {
            Logger.t(TAG).e("ack_Cam_Get_P2P_PairedList exception = " + ex.getMessage());
        }
    }

    void ack_Cam_SupportWlanMode(String p1) {
//        Logger.t(TAG).d("ack_Cam_SupportWlanMode p1=" + p1 + ", p2=" + p2);
        mSupportWlan = Boolean.valueOf(p1) || (Integer.parseInt(p1) == 1);
        mRxBus.post(new SupportWlanChangeEvent(this, mSupportWlan));
    }

    void ack_Cam_Get_MountAccTrust(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_MountAccTrust p1=" + p1 + ", p2=" + p2);
        mMountAccTrust = Integer.parseInt(p1);
        mRxBus.post(new MountAccTrustChangeEvent(this, mMountAccTrust));
    }

    void ack_Cam_Get_AudioPrompts(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_AudioPrompts p1=" + p1 + ", p2=" + p2);
        switch (p1) {
            case "on":
                mPromptsState = AUDIO_PROMPTS_MODE_ON;
                break;
            case "off":
                mPromptsState = AUDIO_PROMPTS_MODE_OFF;
                break;
            default:
                break;
        }
        mRxBus.post(new AudioPromptsChangeEvent(this, mPromptsState));
    }

    void ack_Cam_Support_Upsidedown(String p1) {
//        Logger.t(TAG).d("ack_Cam_Support_Upsidedown p1=" + p1 + ", p2=" + p2);
        mUpsidedownEnable = Integer.parseInt(p1) == 1;
        if (mUpsidedownEnable) {
            if (mServiceInfo.isVdtCamera) {
                mCommunicationBus.sendCAMCommand(CMD_GET_ATTITUDE, "", "");
            }
        }
    }

    void ack_Cam_Get_Attitude(String p1) {
        Logger.t(TAG).d("ack_Cam_Get_Attitude p1=" + p1);
        mIsLensNormal = LENS_NORMAL.equals(p1);
        mRxBus.post(new LensChangeEvent(this, mIsLensNormal));
    }

    void ack_Cam_Get_ProtectionVoltage(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_ProtectionVoltage p1=" + p1 + ", p2=" + p2);
        mProtectVoltage = Integer.parseInt(p1);
        mRxBus.post(new VoltageChangeEvent(this, mProtectVoltage));
    }

    void ack_Cam_Get_ParkSleepDelay(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_ParkSleepDelay p1=" + p1 + ", p2=" + p2);
        mParkSleepDelay = Integer.parseInt(p1);
        mRxBus.post(new SleepDelayChangeEvent(this, mParkSleepDelay));
    }

    void ack_Cam_Get_VirtualIgnition(boolean enable) {
        Logger.t(TAG).i("ack_Cam_Get_VirtualIgnition enable=" + enable);
        mVirtualIgnitionEnable = enable ? VIRTUAL_IGNITION_ON : VIRTUAL_IGNITION_OFF;
        mRxBus.post(new VirtualIgnitionEvent(this, enable));
    }

    void ack_Cam_Get_Iccid(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_Iccid p1=" + p1 + ", p2=" + p2);
        mIccid = p1;

        reportID(mIccid);
    }

    private void reportID(String mIccid) {
        Logger.t(TAG).d("reportIccid: " + reportIccid);
        if (!reportIccid) {
            if (TextUtils.isEmpty(mIccid)) {
                Logger.t(TAG).d("reportIccid: iccid is null");
            } else {
//                ReportIdBody reportIdBody = new ReportIdBody();
//                reportIdBody.reportIccid = mIccid;
//
//                ApiService.createApiService().reportID(getSerialNumber(), reportIdBody)
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(response -> {
//                            boolean successful = response.isSuccessful();
//                            Logger.t(TAG).d("reportIccid: " + successful);
//                            if (successful) {
//                                reportIccid = response.body().result;
//                            } else {
//                                String string = response.errorBody().string();
//                                Logger.t(TAG).d("reportIccid error: " + string);
//                            }
//                        }, new ServerErrorHandler(TAG));
            }
        }
    }

    public void transferFirmware(File file) {
        mCommunicationBus.sendEvCamFile(file);
    }

    public void upgradeFirmware() {
        mCommunicationBus.sendCAMCommand(CMD_FW_DO_UPGRADE, "", "");
    }

    public String getSerialNumber() {
        return mSerialNumber;
    }

    void ack_Cam_Get_LteVertion(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_Get_LteVertion p1=" + p1 + ", p2=" + p2);
        modemVersion = p1;
        modemVersionDebug = p2;
    }

    void ack_Cam_Get_APN(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_APN p1=" + p1 + ", p2=" + p2);
        mApnSetting = p1;
        mRxBus.post(new ApnChangeEvent(this, mApnSetting));
    }

    void ack_Cam_Get_LteStatus(String p1) {
        Logger.t(TAG).d("ack_Cam_Get_LteStatus p1=" + p1);
        try {
            new JSONObject(p1);
            lteStatus = p1;
        } catch (JSONException e) {
            Logger.t(TAG).e("ack_Cam_Get_LteStatus exception: " + e.getMessage());
        }
    }

    void ack_Cam_CopyLog(String p1) {
//        Logger.t(TAG).d("ack_Cam_CopyLog p1=" + p1 + ", p2=" + p2);
        try {
            int res = Integer.valueOf(p1);
            prepareLogFuture.onResponse(res);
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_CopyLog exception = " + e.getMessage());
        }
    }

    void ack_Cam_FW_Get_Key(String p1) {
//        Logger.t(TAG).d("ack_Cam_FW_Get_Key p1=" + p1);
        if (!TextUtils.isEmpty(p1)) {
            mPassword = p1;
        }
    }

    void ack_Cam_Get_Server(String p1) {
        //horn wss://ws.waylens.com/360/api/4g/
//        Logger.t(TAG).d("ack_Cam_Get_Server p1=" + p1 + ", p2=" + p2);
        if (!TextUtils.isEmpty(p1)) {
            mCameraServer = p1;
        }
    }

    void ack_Cam_Get_MountVersion(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_MountVersion p1=" + p1 + ", p2=" + p2);
        try {
            MountVersion mv = gson.fromJson(p1, new TypeToken<MountVersion>() {
            }.getType());
            mountVersion = mv;
            mRxBus.post(new MountVersionEvent(this, mv));

            if (mountVersion != null) {
                String vercode = mountVersion.vercode;
                int versionCode;
                if (!TextUtils.isEmpty(vercode) && !"unknown".equals(vercode)) {
                    versionCode = Integer.parseInt(vercode);
                } else {
                    versionCode = 0;
                }
                versionCode = versionCode >> 8;
                if (versionCode == 0 ||
                        versionCode == 0x6 ||
                        versionCode == 0x7) {
                    supportRadarSensitivity = false;
                } else {
                    supportRadarSensitivity = true;
                    getMountSensitivity();
                }
            }
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_MountVersion exception = " + e.getMessage());
        }
    }

    void ack_Cam_Get_MountSettings(String p1) {
        Logger.t(TAG).d("ack_Cam_Get_MountSettings p1=" + p1);
        try {
            MountSetting ms = gson.fromJson(p1, new TypeToken<MountSetting>() {
            }.getType());
            mountSetting = ms;

            reportSetting(this);
            mRxBus.post(new MountSettingChangeEvent(this, ms));
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_MountSettings exception = " + e.getMessage());
        }
    }

    public boolean getSupportRadar() {
        return supportRadarSensitivity;
    }


    private void reportSetting(CameraWrapper camera) {
//        Logger.t(TAG).d("reportSettingTag: " + reportSettingTag);
//        if (!reportSettingTag) {
//            reportSettingTag = true;
//
//            CurrentUser currentUser = HornApplication.getComponent().currentUser();
//            if (currentUser.exists()) {
//                List<CameraBean> cameraBeanList = currentUser.getDevices();
//                CameraBean remoteCamera = null;
//                for (CameraBean cameraBean : cameraBeanList) {
////                    Logger.t(TAG).d("cameraBean settings: " + cameraBean.settings);
//                    if (cameraBean.sn.equals(camera.mSerialNumber)) {
//                        remoteCamera = cameraBean;
//                        break;
//                    }
//                }
//                SettingReportBody body = SettingReportBody.makeBody(camera, remoteCamera);
//                Logger.t(TAG).d("SettingReportBody: " + body);
//                if (body == null) {
//                    return;
//                }
//                ApiService.createApiService().reportSetting(camera.getSerialNumber(), body)
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(response -> {
//                            BooleanResponse booleanResponse = response.body();
//                            Logger.t(TAG).d("reportSetting: " + booleanResponse);
//                        }, new ServerErrorHandler(TAG));
//            }
//        }
    }

    void ack_Cam_Get_MonitorMode(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_MonitorMode p1=" + p1 + ", p2=" + p2);
        int mode = MONITOR_MODE_UNKNOWN;
        switch (p1) {
            case DRIVE_MODE_STR:
                mode = MONITOR_MODE_DRIVE;
                break;
            case PARK_MODE_STR:
                mode = MONITOR_MODE_PARK;
                break;
            default:
                break;
        }
        if (mode != MONITOR_MODE_UNKNOWN && mode != monitorMode) {
            monitorMode = mode;
            mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_MONITOR_MODE, this, mode));
        }
    }

    void ack_Dev_HotspotInfo(String p1) {
        Logger.t(TAG).i("ack_Dev_HotspotInfo: p1 = " + p1);
        try {
            HotspotInfoModel model = gson.fromJson(p1, new TypeToken<HotspotInfoModel>() {
            }.getType());
            hotspotInfoModel = model;

            mRxBus.post(new HotspotInfoEvent(this, model));
        } catch (Exception ex) {
            Logger.t(TAG).e("ack_Dev_HotspotInfo exception = " + ex.getMessage());
        }
    }

    void ack_Dev_PowerState(PowerStateBean bean) {
//        Logger.t(TAG).d("ack_Dev_PowerState: " + bean.toString());
        if (bean != null) {
            String level = bean.getLevel();
            mBatteryLevel = getBatteryLevelWithString(level);
            mVoltageNow = bean.getMv();
//            int mBatteryVol = bean.getPercent();
            ack_Cam_PowerInfo(bean.getStatus(), bean.isOnline() ? "1" : "0");
        }
    }

    //mk
    void ack_MK_SIM_DATA(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            SIMDATABean model = gson.fromJson(p1, new TypeToken<SIMDATABean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_Carrier(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            CarrierBean model = gson.fromJson(p1, new TypeToken<CarrierBean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_Send_Data_FW(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            SendDataFWResponse model = gson.fromJson(p1, new TypeToken<SendDataFWResponse>(){}.getType());
            mRxBus.post(new SendDataFWEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_SEND_FACE(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            BoolMsg model = gson.fromJson(p1, new TypeToken<BoolMsg>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_01(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            TCVN01Bean model = gson.fromJson(p1, new TypeToken<TCVN01Bean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_02(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            TCVN02Bean model = gson.fromJson(p1, new TypeToken<TCVN02Bean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_03(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            TCVN03Bean model = gson.fromJson(p1, new TypeToken<TCVN03Bean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_04(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            TCVN04Bean model = gson.fromJson(p1, new TypeToken<TCVN04Bean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_05(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            TCVN05Bean model = gson.fromJson(p1, new TypeToken<TCVN05Bean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_MOC(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            JSONObject jsonObject = new JSONObject(p1);
            String moc_method = jsonObject.getString("MOC");
            mRxBus.post(new TCVNEvent(this,moc_method));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_driverInfo(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            DriverInfoBody model = gson.fromJson(p1, new TypeToken<DriverInfoBody>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_settingCfg(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        if (p1.equals("") || p1 == null){
            mRxBus.post(null);
        }
        try {
            SettingCfgBean model = gson.fromJson(p1, new TypeToken<SettingCfgBean>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    void ack_MK_INOUT(String p1){
        Logger.t(TAG).i("msg p1:" +p1);
        try {
            INOUTBody model = gson.fromJson(p1, new TypeToken<INOUTBody>(){}.getType());
            mRxBus.post(new TCVNEvent(this,model));
        }catch (Exception e){
            e.printStackTrace();
        }
    }
    //end

    void ack_Cam_PowerInfo(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_PowerInfo p1=" + p1 + ", p2=" + p2);
        if (p1.length() == 0 || p2.length() == 0) {
            Logger.t(TAG).d("bad power info, schedule update");

        } else {
            int batteryState = STATE_BATTERY_UNKNOWN;
            switch (p1) {
                case "Full":
                    batteryState = STATE_BATTERY_FULL;
                    break;
                case "Not charging":
                    batteryState = STATE_BATTERY_NOT_CHARGING;
                    break;
                case "Discharging":
                    batteryState = STATE_BATTERY_DISCHARGING;
                    break;
                case "Charging":
                    batteryState = STATE_BATTERY_CHARGING;
                    break;
            }
            int powerState = Integer.parseInt(p2);
            mBatteryState = batteryState;
            mPowerState = powerState;
        }
    }

    void ack_Cam_Get_StateResult(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_StateResult p1=" + p1 + ", p2=" + p2);
        int state = Integer.parseInt(p1);
        if (mRecordState != state) {
            mRecordState = state;
            updateInfoMsg(mRecordState);
            mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_REC, this, null));
        }
    }

    private void updateInfoMsg(int recordState) {
        switch (recordState) {
            case STATE_RECORD_STOPPED:
                infoMsgQueue.putMsg(InfoMsgQueue.I_RECORD_STOPPED);
                break;
            case STATE_RECORD_RECORDING:
                infoMsgQueue.clearAllMsg();
                break;
            default:
                break;
        }
    }

    void ack_Rec_Get_MarkTime(String p1, String p2) {
//        Logger.t(TAG).d("ack_Rec_Get_MarkTime p1=" + p1 + ", p2=" + p2);
        try {
            mMarkBeforeTime = Integer.parseInt(p1);
            mMarkAfterTime = Integer.parseInt(p2);
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Rec_Get_MarkTime exception = " + e.getMessage());
        }
    }

    void ack_Cam_Get_HdrMode(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_HdrMode p1=" + p1 + ", p2=" + p2);
        try {
            switch (p1) {
                case "on":
                    hdr_mode = HDR_MODE_ON;
                    break;
                case "off":
                    hdr_mode = HDR_MODE_OFF;
                    break;
                case "auto":
                    hdr_mode = HDR_MODE_AUTO;
                    break;
                default:
                    hdr_mode = HDR_MODE_UNKNOWN;
                    break;
            }
            mRxBus.post(new HdrModeChangeEvent(this, hdr_mode));
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_HdrMode exception = " + e.getMessage());
        }
    }

    void ack_Cam_Get_MarkStorage(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_Get_MarkStorage p1=" + p1 + ", p2=" + p2);
        videoSpaceList = StringUtils.filterString(p2);
        for (int i = 0; i < videoSpaceList.length; i++) {
            if (p1.equals(videoSpaceList[i])) {
                mVideoSpace = i;
                break;
            }
        }
        mRxBus.post(new VideoSpaceChangeEvent(this, mVideoSpace));
    }

    public ClipsManager getClipsManager() {
        return mClipsManager;
    }

    public int compareToApiVersion(String apiVersion) {
        int main = 0, sub = 0;
        String build = "";
        int i_main = apiVersion.indexOf('.');
        if (i_main >= 0) {
            String t = apiVersion.substring(0, i_main);
            main = Integer.parseInt(t);
            i_main++;
            int i_sub = apiVersion.indexOf('.', i_main);
            if (i_sub >= 0) {
                t = apiVersion.substring(i_main, i_sub);
                sub = Integer.parseInt(t);
                i_sub++;
                build = apiVersion.substring(i_sub);
            }
        }
        int version = makeVersion(main, sub);
        if (version != mApiVersion) {
            return mApiVersion - version;
        } else {
            return mBuild.compareTo(build);
        }
    }

    public InfoMsgQueue getInfoMsgQueue() {
        return infoMsgQueue;
    }

    public void setOnRawDataItemUpdateListener(OnRawDataUpdateListener listener) {
        mOnRawDataUpdateListener = new WeakReference<>(listener);
    }

    InetSocketAddress getInetSocketAddress() {
        return mAddress;
    }

    public boolean isMicEnabled() {
        return mMicState == STATE_MIC_ON;
    }

    public String getModemVersionDebug() {
        return modemVersionDebug;
    }


    public InetAddress getAddress() {
        return mServiceInfo.inetAddr;
    }

    public int getPort() {
        return mServiceInfo.port;
    }

    boolean idMatch(String ssid, String hostString) {
        if (ssid == null || hostString == null) {
            return false;
        }
        String myHostString = getHostString();
        if (mServiceInfo.ssid == null || myHostString == null) {
            return false;
        }
        return mServiceInfo.ssid.equals(ssid) && myHostString.equals(hostString);
    }

    public VdbRequestQueue getRequestQueue() {
        return mVdbRequestQueue;
    }

    public ServiceInfo getServerInfo() {
        return mServiceInfo;
    }

    public void setStopParkingMode(boolean isChecked) {
    }

    public void setOverSpeedMode(boolean isChecked) {

    }

    public void setTrackingPlateMode(boolean isChecked) {

    }

    public static class ServiceInfo {
        public final InetAddress inetAddr;
        public final int port;
        public final String serverName;
        public final boolean isVdtCamera;
        final String serviceName;
        final boolean bPcServer;
        public String ssid;

        public ServiceInfo(InetAddress inetAddr, int port, String serverName, String serviceName, boolean bPcServer) {
            this.ssid = "";
            this.inetAddr = inetAddr;
            this.port = port;
            this.serverName = serverName;
            this.serviceName = serviceName;
            this.bPcServer = bPcServer;
            this.isVdtCamera = port == VDT_CAM_PORT;
        }

        @NonNull
        @Override
        public String toString() {
            return "ServiceInfo{" +
                    "ssid='" + ssid + '\'' +
                    ", inetAddr=" + inetAddr +
                    ", port=" + port +
                    ", serverName='" + serverName + '\'' +
                    ", serviceName='" + serviceName + '\'' +
                    ", bPcServer=" + bPcServer +
                    ", isVdtCamera=" + isVdtCamera +
                    '}';
        }
    }
}
