package com.mk.autosecure.libs.account;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.preference.StringPreference;
import com.mkgroup.camera.preference.StringPreferenceType;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by doanvt on 2022/11/02.
 */

public class FleetInfo {

    private final static String TAG = FleetInfo.class.getSimpleName();

    private final StringPreferenceType vehiclePreference;

    private final StringPreferenceType devicePreference;

    private final StringPreferenceType driverPreference;

    private final Gson gson;

    private final BehaviorSubject<Optional<List<VehicleInfoBean>>> vehiclesList = BehaviorSubject.create();

    private final BehaviorSubject<Optional<List<FleetCameraBean>>> devicesList = BehaviorSubject.create();

    private final BehaviorSubject<Optional<List<DriverInfoBean>>> driversList = BehaviorSubject.create();

    public FleetInfo(StringPreference vehiclePreference, StringPreference devicePreference, StringPreference driverPreference, Gson gson) {
        this.vehiclePreference = vehiclePreference;
        this.devicePreference = devicePreference;
        this.driverPreference = driverPreference;
        this.gson = gson;

        this.vehiclesList.onNext(Optional.ofNullable(getVehicles()));
        this.devicesList.onNext(Optional.ofNullable(getDevices()));
        this.driversList.onNext(Optional.ofNullable(getDrivers()));
    }

    public void clearCache() {
        Logger.t(TAG).d("clearCache");
        vehiclePreference.delete();
        devicePreference.delete();
        driverPreference.delete();

        vehiclesList.onNext(Optional.ofNullable(new ArrayList<>()));
        devicesList.onNext(Optional.ofNullable(new ArrayList<>()));
        driversList.onNext(Optional.ofNullable(new ArrayList<>()));
    }

    @SuppressLint("CheckResult")
    public void refreshVehicleInfo() {
        ApiClient.createApiService().getVehiclePage(1,14, HornApplication.getComponent().currentUser().getAccessToken())
                .subscribeOn(Schedulers.io())
                .subscribe(response -> {
                    if(response.isSuccess()){
                        List<VehicleInfoBean> vehicleInfos = response.getData().getRecords();
                        refreshVehicles(vehicleInfos);
                    }else{
                        NetworkErrorHelper.handleExpireToken(HornApplication.getContext(),response);
                    }
                }, new ServerErrorHandler(TAG));
    }

    @SuppressLint("CheckResult")
    public void refreshDeviceInfo() {
        ApiClient.createApiService().getDevicePageInfo(1,14,HornApplication.getComponent().currentUser().getAccessToken())
                .subscribeOn(Schedulers.io())
                .subscribe(response -> {
                    List<FleetCameraBean> cameraInfos = response.getData().getRecords();
                    refreshDevices(cameraInfos);
                }, new ServerErrorHandler(TAG));
    }

    @SuppressLint("CheckResult")
    public void refreshDriverInfo() {
        ApiClient.createApiService().getDriverPageInfo(1,14,HornApplication.getComponent().currentUser().getAccessToken())
                .subscribeOn(Schedulers.io())
                .subscribe(response -> {
                    List<DriverInfoBean> driverInfos = response.getData().getRecords();
                    refreshDrivers(driverInfos);
                }, new ServerErrorHandler(TAG));
    }

    public void updateBindVehicleDriver(int vehicleID, int driverID, boolean unbind) {
        Logger.t(TAG).d("updateBindVehicleDriver vehicleID: " + vehicleID + " driverID: " + driverID);
        if (vehicleID == -1) {
            return;
        }

        List<VehicleInfoBean> vehicles = getVehicles();
        boolean updateVehicle = false;
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (vehicleID ==bean.getId()) {
                    updateVehicle = true;
                    bean.setDriverId(unbind ? null : driverID);
                    break;
                }
            }
        }

        List<DriverInfoBean> drivers = getDrivers();
        boolean updateDriver = false;
        if (drivers != null && drivers.size() > 0) {
            for (DriverInfoBean bean : drivers) {
                if (driverID == bean.getId()) {
                    updateDriver = true;
//                    bean.set(unbind ? "" : vehicleID);
                    break;
                }
            }
        }

        Logger.t(TAG).d("updateVehicle: " + updateVehicle + " updateDriver: " + updateDriver);

        if (updateVehicle && updateDriver) {
            refreshVehicles(vehicles);
            refreshDrivers(drivers);
        }
    }

    public void updateEditVehicle(int vehicleId, String model, String capacity, String type){
        if(vehicleId == -1){
            return;
        }
        List<VehicleInfoBean> vehicles = getVehicles();
        boolean updateVehicle = false;
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (vehicleId == bean.getId()) {
                    updateVehicle = true;
                    bean.setBrand(model);
                    bean.setCapacity(capacity);
                    bean.setType(type);
                    break;
                }
            }
        }

        if(updateVehicle){
            refreshVehicles(vehicles);
        }
    }

    public void updateEditDriver(int driverId, String name, String gender, String phone, String idNo, String driver_license, String license_type, String driving_years, String employeeId){
        if(driverId == -1){
            return;
        }
        List<DriverInfoBean> drivers = getDrivers();
        boolean updateDriver = false;
        if (drivers != null && drivers.size() > 0) {
            for (DriverInfoBean bean : drivers) {
                if (driverId == bean.getId()) {
                    updateDriver = true;
                    bean.setName(name);
                    bean.setGender(Integer.parseInt(""));
                    bean.setPhoneNo(phone);
                    bean.setIdNumber(idNo);
                    bean.setLicense(driver_license);
                    bean.setLicenseType(license_type);
                    bean.setDrivingYears(driving_years);
                    bean.setEmployeeId(employeeId);
                    break;
                }
            }
        }

        if(updateDriver){
            refreshDrivers(drivers);
        }
    }

    public VehicleInfoBean getVehicleWithId(int vehicleId){
        List<VehicleInfoBean> vehicles = getVehicles();
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (vehicleId == bean.getId()) {
                    return bean;
                }
            }
        }
        return null;
    }

    public FleetCameraBean getCameraWithSn(String cameraSn){
        List<FleetCameraBean> beanList = getDevices();
        if (beanList != null && beanList.size() > 0) {
            for (FleetCameraBean bean : beanList) {
                if (cameraSn == bean.getSn()) {
                    return bean;
                }
            }
        }
        return null;
    }

    public DriverInfoBean getDriverWithId(int driverId){
        List<DriverInfoBean> drivers = getDrivers();
        if (drivers != null && drivers.size() > 0) {
            for (DriverInfoBean bean : drivers) {
                if (driverId == bean.getId()) {
                    return bean;
                }
            }
        }
        return null;
    }

    public VehicleInfoBean getVehicleWithPlateNo(String plateNo){
        List<VehicleInfoBean> vehicles = getVehicles();
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (plateNo.equals(bean.getPlateNo())) {
                    return bean;
                }
            }
        }
        return null;
    }

    public void updateBindVehicleDevice(int vehicleID, String cameraSN, boolean unbind) {
        Logger.t(TAG).d("updateBindVehicleDevice vehicleID: " + vehicleID + " cameraSN: " + cameraSN);
        if (vehicleID == -1 || TextUtils.isEmpty(cameraSN)) {
            return;
        }

        List<VehicleInfoBean> vehicles = getVehicles();
        boolean updateVehicle = false;
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (vehicleID == bean.getId()) {
                    updateVehicle = true;
                    bean.setCameraSn(cameraSN);
                    break;
                }
            }
        }

        List<FleetCameraBean> devices = getDevices();
        boolean updateDevice = false;
        if (devices != null && devices.size() > 0) {
            for (FleetCameraBean bean : devices) {
                if (cameraSN.equals(bean.getSn())) {
                    updateDevice = true;
                    break;
                }
            }
        }

        Logger.t(TAG).d("updateVehicle: " + updateVehicle + " updateDevice: " + updateDevice);

        if (updateVehicle && updateDevice) {
            refreshVehicles(vehicles);
            refreshDevices(devices);
        }
    }

    public void updateDeviceActivate(String cameraSN, String state) {
        Logger.t(TAG).d("updateDeviceActivate cameraSN: " + cameraSN + " state: " + state);
        if (TextUtils.isEmpty(cameraSN)) {
            return;
        }

        List<FleetCameraBean> devices = getDevices();
        boolean updateDevice = false;
        if (devices != null && devices.size() > 0) {
            for (FleetCameraBean bean : devices) {
                if (cameraSN.equals(bean.getSn())) {
                    updateDevice = true;
                    bean.setSimState(state);
                    break;
                }
            }
        }

        Logger.t(TAG).d("updateDevice: " + updateDevice);

        if (updateDevice) {
            refreshDevices(devices);
        }
    }

    public void refreshVehicles(List<VehicleInfoBean> vehicles) {
        Logger.t(TAG).d("refreshVehicles: " + vehicles);
        vehiclePreference.set(gson.toJson(vehicles, new TypeToken<List<VehicleInfoBean>>() {
        }.getType()));
        vehiclesList.onNext(Optional.ofNullable(vehicles));
    }

    public void refreshDevices(List<FleetCameraBean> devices) {
        Logger.t(TAG).d("refreshDevices: " + devices);
        devicePreference.set(gson.toJson(devices, new TypeToken<List<FleetCameraBean>>() {
        }.getType()));
        devicesList.onNext(Optional.ofNullable(devices));
    }

    public void refreshDrivers(List<DriverInfoBean> drivers) {
        Logger.t(TAG).d("refreshDrivers: " + drivers);
        driverPreference.set(gson.toJson(drivers, new TypeToken<List<DriverInfoBean>>() {
        }.getType()));
        driversList.onNext(Optional.ofNullable(drivers));
    }

    public VehicleInfoBean queryVehicle(String vehicleID) {
        if (TextUtils.isEmpty(vehicleID)) {
            return null;
        }

        List<VehicleInfoBean> vehicles = getVehicles();
        if (vehicles != null && vehicles.size() > 0) {
            for (VehicleInfoBean bean : vehicles) {
                if (vehicleID.equals(bean.getId())) {
                    return bean;
                }
            }
        }
        return null;
    }

    public FleetCameraBean queryDevice(String sn) {
        if (TextUtils.isEmpty(sn)) {
            return null;
        }

        List<FleetCameraBean> devices = getDevices();
        if (devices != null && devices.size() > 0) {
            for (FleetCameraBean bean : devices) {
                if (sn.equals(bean.getSn())) {
                    return bean;
                }
            }
        }
        return null;
    }

    public DriverInfoBean queryDriver(int driverID) {

        List<DriverInfoBean> drivers = getDrivers();
        if (drivers != null && drivers.size() > 0) {
            for (DriverInfoBean bean : drivers) {
                if (driverID == bean.getId()) {
                    return bean;
                }
            }
        }
        return null;
    }

    public List<DriverInfoBean> getDrivers() {
        List<DriverInfoBean> beanList = gson.fromJson(driverPreference.get(), new TypeToken<List<DriverInfoBean>>() {
        }.getType());
        Logger.t(TAG).d("getDrivers: " + beanList);
        if (beanList == null) {
            refreshDriverInfo();
        }
        return beanList != null ? beanList : new ArrayList<>();
    }

    public List<FleetCameraBean> getDevices() {
        List<FleetCameraBean> beanList = gson.fromJson(devicePreference.get(), new TypeToken<List<FleetCameraBean>>() {
        }.getType());
        Logger.t(TAG).d("getDevices: " + beanList);
        if (beanList == null) {
            refreshDeviceInfo();
        }
        return beanList != null ? beanList : new ArrayList<>();
    }

    public List<VehicleInfoBean> getVehicles() {
        List<VehicleInfoBean> beanList = gson.fromJson(vehiclePreference.get(), new TypeToken<List<VehicleInfoBean>>() {
        }.getType());
        Logger.t(TAG).d("getVehicles: " + beanList);
        if (beanList == null) {
            refreshVehicleInfo();
        }
        return beanList != null ? beanList : new ArrayList<>();
    }

    public Observable<Optional<List<VehicleInfoBean>>> vehicleObservable() {
        return vehiclesList;
    }

    public Observable<Optional<List<FleetCameraBean>>> deviceObservable() {
        return devicesList;
    }

    public Observable<Optional<List<DriverInfoBean>>> driverObservable() {
        return driversList;
    }
}
