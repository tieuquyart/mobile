package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.message.bean.BoolMsg;
import com.mkgroup.camera.message.bean.BoolRes;
import com.mkgroup.camera.message.bean.CarrierBean;
import com.mkgroup.camera.message.bean.DriverInfoBody;
import com.mkgroup.camera.message.bean.INOUTBody;
import com.mkgroup.camera.message.bean.SIMDATABean;
import com.mkgroup.camera.message.bean.SettingCfgBean;
import com.mkgroup.camera.message.bean.TCVN01Bean;
import com.mkgroup.camera.message.bean.TCVN02Bean;
import com.mkgroup.camera.message.bean.TCVN03Bean;
import com.mkgroup.camera.message.bean.TCVN04Bean;
import com.mkgroup.camera.message.bean.TCVN05Bean;

public class TCVNEvent {
    private final CameraWrapper mCameraWrapper;
    private TCVN01Bean model01;
    private TCVN02Bean model02;
    private TCVN03Bean model03;
    private TCVN04Bean model04;
    private TCVN05Bean model05;
    private DriverInfoBody driverInfoBody;
    private SettingCfgBean settingCfgBean;
    private INOUTBody inoutBody;
    private BoolMsg msgSuccess;
    private SIMDATABean dataSIM;
    private CarrierBean carrierBean;
    private BoolRes value;
    private String MOC;

    public String getMOC() {
        return MOC;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, String MOC) {
        this.mCameraWrapper = mCameraWrapper;
        this.MOC = MOC;
    }

    public TCVNEvent(CameraWrapper cameraWrapper, BoolRes boolRes){
        this.mCameraWrapper = cameraWrapper;
        value = boolRes;
    }

    public DriverInfoBody getDriverInfoBody() {
        return driverInfoBody;
    }

    public void setDriverInfoBody(DriverInfoBody driverInfoBody) {
        this.driverInfoBody = driverInfoBody;
    }

    public SettingCfgBean getSettingCfgBean() {
        return settingCfgBean;
    }

    public void setSettingCfgBean(SettingCfgBean settingCfgBean) {
        this.settingCfgBean = settingCfgBean;
    }

    public INOUTBody getInoutBody() {
        return inoutBody;
    }

    public void setInoutBody(INOUTBody inoutBody) {
        this.inoutBody = inoutBody;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, DriverInfoBody driverInfoBody) {
        this.mCameraWrapper = mCameraWrapper;
        this.driverInfoBody = driverInfoBody;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, SettingCfgBean settingCfgBean) {
        this.mCameraWrapper = mCameraWrapper;
        this.settingCfgBean = settingCfgBean;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, INOUTBody inoutBody) {
        this.mCameraWrapper = mCameraWrapper;
        this.inoutBody = inoutBody;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, TCVN01Bean model) {
        this.mCameraWrapper = mCameraWrapper;
        this.model01 = model;
    }
    public TCVNEvent(CameraWrapper mCameraWrapper, TCVN02Bean model) {
        this.mCameraWrapper = mCameraWrapper;
        this.model02 = model;
    }
    public TCVNEvent(CameraWrapper mCameraWrapper, TCVN03Bean model) {
        this.mCameraWrapper = mCameraWrapper;
        this.model03 = model;
    }
    public TCVNEvent(CameraWrapper mCameraWrapper, TCVN04Bean model) {
        this.mCameraWrapper = mCameraWrapper;
        this.model04 = model;
    }
    public TCVNEvent(CameraWrapper mCameraWrapper, TCVN05Bean model) {
        this.mCameraWrapper = mCameraWrapper;
        this.model05 = model;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper,BoolMsg boolMsg){
        this.mCameraWrapper = mCameraWrapper;
        this.msgSuccess = boolMsg;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, SIMDATABean dataSIM) {
        this.mCameraWrapper = mCameraWrapper;
        this.dataSIM = dataSIM;
    }

    public TCVNEvent(CameraWrapper mCameraWrapper, CarrierBean carrierBean) {
        this.mCameraWrapper = mCameraWrapper;
        this.carrierBean = carrierBean;
    }

    public BoolMsg getMsgSuccess() {
        return msgSuccess;
    }

    public TCVN01Bean getModel01() {
        return model01;
    }

    public TCVN02Bean getModel02() {
        return model02;
    }

    public TCVN03Bean getModel03() {
        return model03;
    }

    public TCVN04Bean getModel04() {
        return model04;
    }

    public TCVN05Bean getModel05() {
        return model05;
    }

    public SIMDATABean getDataSIM() {
        return dataSIM;
    }

    public CameraWrapper getCameraWrapper() {
        return mCameraWrapper;
    }

    public CarrierBean getCarrierBean() {
        return carrierBean;
    }

    public BoolRes getValue() {
        return value;
    }

    public void setValue(BoolRes value) {
        this.value = value;
    }
}
