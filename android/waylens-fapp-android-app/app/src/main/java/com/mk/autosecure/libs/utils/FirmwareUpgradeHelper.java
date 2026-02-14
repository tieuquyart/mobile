package com.mk.autosecure.libs.utils;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FirmwareBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest_fleet.ApiClient;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2016/10/13.
 */

public class FirmwareUpgradeHelper {

    private static final String TAG = FirmwareUpgradeHelper.class.getSimpleName();

    @SuppressLint("CheckResult")
    public static Observable<Optional<Object>> getNewerFirmwareRx(String sn,
                                                                  String hardwareName,
                                                                  String apiVersion,
                                                                  String bspVersion,
                                                                  boolean useCache) {
        return Observable.create(emitter -> {
            if (Constants.isFleet()) {
                ApiClient.createApiService().getFirmware(sn)
                        .subscribeOn(Schedulers.io())
                        .subscribe(response -> {
                            if (response != null) {
                                FirmwareBean firmware = response.getFirmware();
                                emitter.onNext(Optional.ofNullable(firmware));
                                VdtCameraManager.getManager().getFirmwareManager().updateLatestFleetFirmware(firmware);
                            }
                        }, throwable -> {
                            Logger.t(TAG).d("error = " + throwable.getMessage());

                            FirmwareBean firmwareBean = useCache
                                    ? VdtCameraManager.getManager().getFirmwareManager().getLatestFleetFirmware() : null;
                            emitter.onNext(Optional.ofNullable(firmwareBean));
                        });
            } else {
                ApiService.createApiService().getFirmware()
                        .subscribeOn(Schedulers.io())
                        .subscribe(firmwares -> {
                            if (firmwares != null) {
                                emitter.onNext(firmwares);
                                VdtCameraManager.getManager().getFirmwareManager().updateLatestFirmwareList(firmwares);
                            }
                        }, throwable -> {
                            Logger.t(TAG).d("error = " + throwable.getMessage());

                            List<Firmware> firmwareList = useCache
                                    ? VdtCameraManager.getManager().getFirmwareManager().getLatestFirmwareList() : new ArrayList<>();
                            if (firmwareList != null) {
                                emitter.onNext(firmwareList);
                            }
                        });
            }
        })
                .map(object -> Optional.ofNullable(getNewerFirmware(object, hardwareName, apiVersion, bspVersion)));
    }

    /**
     * @param object Optional<FirmwareBean> or List<Firmware>
     * @return FirmwareBean or Firmware
     */
    public static Object getNewerFirmware(Object object, String hardwareName, String apiVersion, String bspVersion) {
        if (object == null || !isCameraValid(hardwareName, apiVersion, bspVersion)) {
            return null;
        }

        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
        Logger.t(TAG).e("hardwareName: " + hardwareName);

        hardwareName = aBoolean ? hardwareName + "_BETA" : hardwareName;

        if (object instanceof Optional && ((Optional) object).getIncludeNull() instanceof FirmwareBean) {
            FirmwareBean firmwareBean = (FirmwareBean) ((Optional) object).getIncludeNull();

            if (!TextUtils.isEmpty(firmwareBean.getHardwareVersion())
                    && firmwareBean.getHardwareVersion().equals(hardwareName)) {
                FirmwareVersion versionFromServer = new FirmwareVersion(firmwareBean.getFirmwareShort(), firmwareBean.getFirmware());
                FirmwareVersion versionInCamera = new FirmwareVersion(apiVersion, bspVersion);
                Logger.t(TAG).d("latest version: " + versionFromServer);
                Logger.t(TAG).d("version of camera: " + versionInCamera);
                Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
                //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
                if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
                    return firmwareBean;
                }
            }
        } else if (object instanceof List) {
            List<Firmware> firmwares = (List<Firmware>) object;

            for (Firmware firmware : firmwares) {
                if (!TextUtils.isEmpty(firmware.name)
                        && firmware.name.equals(hardwareName)) {
                    FirmwareVersion versionFromServer = new FirmwareVersion(firmware.version, firmware.BSPVersion);
                    FirmwareVersion versionInCamera = new FirmwareVersion(apiVersion, bspVersion);
                    Logger.t(TAG).d("latest version: " + versionFromServer);
                    Logger.t(TAG).d("version of camera: " + versionInCamera);
                    Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
                    //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
                    if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
                        return firmware;
                    }
                }
            }
        }
        return null;
    }

//    public static Observable<Optional<Firmware>> getNewerFirmwareRx(VdtCamera vdtCamera, boolean useCache) {
//        return Observable.create((ObservableOnSubscribe<List<Firmware>>) emitter ->
//                ApiService.createApiService().getFirmware()
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(firmwares -> {
//                            if (firmwares != null) {
//                                emitter.onNext(firmwares);
//                                VdtCameraManager.getManager().getFirmwareManager().updateLatestFirmwareList(firmwares);
//                            }
//                        }, throwable -> {
//                            Logger.t(TAG).d("error = " + throwable.getMessage());
//
//                            List<Firmware> firmwareList = useCache
//                                    ? VdtCameraManager.getManager().getFirmwareManager().getLatestFirmwareList() : new ArrayList<>();
//                            if (firmwareList != null) {
//                                emitter.onNext(firmwareList);
//                            }
//                        }))
//                .map(firmwares -> Optional.ofNullable(getNewerFirmware(firmwares, vdtCamera)));
//    }

    public static Observable<Optional<Firmware>> getNewerFirmwareRx(CameraItem cameraItem, boolean useCache) {
        return Observable.create((ObservableOnSubscribe<List<Firmware>>) emitter ->
                ApiService.createApiService().getFirmware()
                        .subscribeOn(Schedulers.io())
                        .subscribe(firmwares -> {
                            if (firmwares != null) {
                                emitter.onNext(firmwares);
                                VdtCameraManager.getManager().getFirmwareManager().updateLatestFirmwareList(firmwares);
                            }
                        }, throwable -> {
                            Logger.t(TAG).d("error = " + throwable.getMessage());

                            List<Firmware> firmwareList = useCache
                                    ? VdtCameraManager.getManager().getFirmwareManager().getLatestFirmwareList() : new ArrayList<>();
                            if (firmwareList != null) {
                                emitter.onNext(firmwareList);
                            }
                        }))
                .map(firmwares -> Optional.ofNullable(getNewerFirmware(firmwares, cameraItem)));
    }

//    public static Observable<Optional<Firmware>> getNewerFirmwareRx(CameraBean cameraBean, boolean useCache) {
//        return Observable.create((ObservableOnSubscribe<List<Firmware>>) emitter ->
//                ApiService.createApiService().getFirmware()
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(firmwares -> {
//                            if (firmwares != null) {
//                                emitter.onNext(firmwares);
//                                VdtCameraManager.getManager().getFirmwareManager().updateLatestFirmwareList(firmwares);
//                            }
//                        }, throwable -> {
//                            Logger.t(TAG).d("error = " + throwable.getMessage());
//
//                            List<Firmware> firmwareList = useCache
//                                    ? VdtCameraManager.getManager().getFirmwareManager().getLatestFirmwareList() : new ArrayList<>();
//                            if (firmwareList != null) {
//                                emitter.onNext(firmwareList);
//                            }
//                        }))
//                .map(firmwares -> Optional.ofNullable(getNewerFirmware(firmwares, cameraBean)));
//    }

//    public static Observable<Optional<FirmwareBean>> getNewerFirmwareRx(FleetCameraBean fleetCamera, boolean useCache) {
//        return Observable.create((ObservableOnSubscribe<Optional<FirmwareBean>>) emitter ->
//                ApiClient.createApiService().getFirmware(fleetCamera.getSerialNumber())
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(response -> {
//                            if (response != null) {
//                                FirmwareBean firmware = response.getFirmware();
//                                emitter.onNext(Optional.ofNullable(firmware));
//                            }
//                        }, throwable -> {
//                            Logger.t(TAG).d("error = " + throwable.getMessage());
//                            emitter.onNext(Optional.empty());
//                        }))
//                .map(beanOptional -> Optional.ofNullable(getNewerFirmware(beanOptional.getIncludeNull(), fleetCamera)));
//    }

//    public static Firmware getNewerFirmware(List<Firmware> firmwares, VdtCamera vdtCamera) {
//        if (firmwares == null || vdtCamera == null) {
//            return null;
//        }
//
//        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
//        String hardwareName = vdtCamera.getHardwareName();
//        Logger.t(TAG).e("hardwareName: " + hardwareName);
//
//        hardwareName = aBoolean ? hardwareName + "_BETA" : hardwareName;
//
//        for (Firmware firmware : firmwares) {
////            Logger.t(TAG).d("one firmware: " + firmware.toString());
//            if (!TextUtils.isEmpty(firmware.name)
//                    && firmware.name.equals(hardwareName)) {
//                FirmwareVersion versionFromServer = new FirmwareVersion(firmware.version, firmware.BSPVersion);
//                FirmwareVersion versionInCamera = new FirmwareVersion(vdtCamera.getApiVersion(), vdtCamera.getBspFirmware());
//                Logger.t(TAG).d("latest version: " + versionFromServer);
//                Logger.t(TAG).d("version of camera: " + versionInCamera);
//                Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
//                //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
//                if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
//                    return firmware;
//                }
//            }
//        }
//        return null;
//    }

    public static Firmware getNewerFirmware(List<Firmware> firmwares, CameraItem cameraItem) {
        if (firmwares == null || !isCameraItemValid(cameraItem)) {
            return null;
        }

        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
        String hardwareName = cameraItem.getHardwareName();
        Logger.t(TAG).e("hardwareName: " + hardwareName);

        hardwareName = aBoolean ? hardwareName + "_BETA" : hardwareName;

        for (Firmware firmware : firmwares) {
//            Logger.t(TAG).d("one firmware: " + firmware.toString());
            if (!TextUtils.isEmpty(firmware.name)
                    && firmware.name.equals(hardwareName)) {
                FirmwareVersion versionFromServer = new FirmwareVersion(firmware.version, firmware.BSPVersion);
                FirmwareVersion versionInCamera = new FirmwareVersion(cameraItem.getApiVersion(), cameraItem.getBspVersion());
                Logger.t(TAG).d("latest version: " + versionFromServer);
                Logger.t(TAG).d("version of camera: " + versionInCamera);
                Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
                //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
                if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
                    return firmware;
                }
            }
        }
        return null;
    }

//    public static Firmware getNewerFirmware(List<Firmware> firmwares, CameraBean cameraBean) {
//        if (firmwares == null || !isCameraBeanValid(cameraBean)) {
//            return null;
//        }
//
//        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
//        String hardwareName = cameraBean.hardwareVersion;
//        Logger.t(TAG).e("hardwareName: " + hardwareName);
//
//        hardwareName = aBoolean ? hardwareName + "_BETA" : hardwareName;
//
//        for (Firmware firmware : firmwares) {
////            Logger.t(TAG).d("one firmware: " + firmware.toString());
//            if (!TextUtils.isEmpty(firmware.name)
//                    && firmware.name.equals(hardwareName)) {
//                FirmwareVersion versionFromServer = new FirmwareVersion(firmware.version, firmware.BSPVersion);
//                FirmwareVersion versionInCamera = new FirmwareVersion(cameraBean.state.firmwareShort, cameraBean.state.firmware);
//                Logger.t(TAG).d("latest version: " + versionFromServer);
//                Logger.t(TAG).d("version of camera: " + versionInCamera);
//                Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
//                //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
//                if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
//                    return firmware;
//                }
//            }
//        }
//        return null;
//    }

//    public static FirmwareBean getNewerFirmware(FirmwareBean firmwareBean, FleetCameraBean fleetCamera) {
//        if (firmwareBean == null || !isFleetCameraValid(fleetCamera)) {
//            return null;
//        }
//
//        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
//        String hardwareName = fleetCamera.getHardwareVersion();
//        Logger.t(TAG).e("hardwareName: " + hardwareName);
//
//        hardwareName = aBoolean ? hardwareName + "_BETA" : hardwareName;
//
////            Logger.t(TAG).d("one firmware: " + firmware.toString());
//        if (!TextUtils.isEmpty(firmwareBean.getHardwareVersion())
//                && firmwareBean.getHardwareVersion().equals(hardwareName)) {
//            FirmwareVersion versionFromServer = new FirmwareVersion(firmwareBean.getFirmwareShort(), firmwareBean.getFirmware());
//            FirmwareVersion versionInCamera = new FirmwareVersion(fleetCamera.getFirmwareShort(), fleetCamera.getFirmware());
//            Logger.t(TAG).d("latest version: " + versionFromServer);
//            Logger.t(TAG).d("version of camera: " + versionInCamera);
//            Logger.t(TAG).d("check version isDifferentBSPVersion: " + versionFromServer.isDifferentBSPVersion(versionInCamera));
//            //用户当前固件是测试版本，同时退出了测试组，则显示正式版本固件
//            if (versionFromServer.isDifferentBSPVersion(versionInCamera)) {
//                return firmwareBean;
//            }
//        }
//        return null;
//    }

    public static boolean isCameraItemValid(CameraItem cameraItem) {
        if (cameraItem == null) {
            return false;
        }
        return !TextUtils.isEmpty(cameraItem.getApiVersion())
                && !TextUtils.isEmpty(cameraItem.getBspVersion())
                && !TextUtils.isEmpty(cameraItem.getHardwareName());
    }

    public static boolean isCameraValid(String hardwareVersion, String firmwareShort, String firmware) {
        return !TextUtils.isEmpty(hardwareVersion)
                && !TextUtils.isEmpty(firmwareShort)
                && !TextUtils.isEmpty(firmware);
    }

//    public static boolean isCameraBeanValid(CameraBean cameraBean) {
//        if (cameraBean == null) {
//            return false;
//        }
//
//        return !TextUtils.isEmpty(cameraBean.hardwareVersion)
//                && !TextUtils.isEmpty(cameraBean.state.firmwareShort)
//                && !TextUtils.isEmpty(cameraBean.state.firmware);
//    }

//    public static boolean isFleetCameraValid(FleetCameraBean fleetCamera) {
//        if (fleetCamera == null) {
//            return false;
//        }
//
//        return !TextUtils.isEmpty(fleetCamera.getHardwareVersion())
//                && !TextUtils.isEmpty(fleetCamera.getFirmwareShort())
//                && !TextUtils.isEmpty(fleetCamera.getFirmware());
//    }

    public static class FirmwareVersion {
        private String mMain;
        private String mSub;
        private String mBuild;

        public String mBSPVersion;

        public FirmwareVersion(String firmware, String BSPVersion) {
            int i_main = firmware.indexOf('.', 0);
            if (i_main >= 0) {
                mMain = firmware.substring(0, i_main);
                i_main++;
                int i_sub = firmware.indexOf('.', i_main);
                if (i_sub >= 0) {
                    mSub = firmware.substring(i_main, i_sub);
                    i_sub++;
                    mBuild = firmware.substring(i_sub);
                }
            }
            mBSPVersion = BSPVersion;
        }

        public boolean isGreaterThan(FirmwareVersion firmwareVersion) {
            List<Integer> thisBspInts = getBspInts();
            List<Integer> thatBspInts = firmwareVersion.getBspInts();
            for (int i = 0; i < Math.min(thisBspInts.size(), thatBspInts.size()); i++) {
                if (thisBspInts.get(i) > thatBspInts.get(i)) {
                    return true;
                } else if (thatBspInts.get(i) > thisBspInts.get(i)) {
                    return false;
                }
            }
            return false;
        }

        public boolean isGreaterThanOrEqual(FirmwareVersion firmwareVersion) {
            return this.toInteger() >= firmwareVersion.toInteger();
        }

        public boolean isDifferentVersion(FirmwareVersion firmwareVersion) {
            return this.toInteger() != firmwareVersion.toInteger();
        }

        public boolean isDifferentBSPVersion(FirmwareVersion firmwareVersion) {
            if (TextUtils.isEmpty(this.mBSPVersion) || TextUtils.isEmpty(firmwareVersion.mBSPVersion))
                return false;
            return !this.mBSPVersion.equals(firmwareVersion.mBSPVersion);
        }

        @Override
        public String toString() {
            return mMain + mSub + mBuild;
        }

        public int toInteger() {
            return Integer.parseInt(mMain + mSub + mBuild);
        }

        private List<Integer> getBspInts() {
            ArrayList<Integer> bspInts = new ArrayList<>();

            String[] intStrArray = mBSPVersion.split("\\.");
            for (String intStr : intStrArray) {
                int intValue = -1;
                try {
                    intValue = Integer.parseInt(intStr);
                } catch (NumberFormatException ex) {
                    Logger.t(TAG).e("error = " + ex.getMessage());
                }
                bspInts.add(intValue);
            }
            for (int i = 0; i < bspInts.size(); i++) {
//                Logger.t(TAG).d("bsp" + bspInts.get(i));
            }
            return bspInts;
        }
    }
}
