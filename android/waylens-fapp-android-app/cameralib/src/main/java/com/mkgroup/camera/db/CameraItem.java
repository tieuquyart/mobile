package com.mkgroup.camera.db;

import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Generated;
import org.greenrobot.greendao.annotation.Id;
import org.greenrobot.greendao.annotation.Property;

/**
 * Created by DoanVT on 2017/11/22.
 * Email: doanvt-hn@mk.com.vn
 */

@Entity
public class CameraItem {

    @Id(autoincrement = true)
    private Long id;

    @Property(nameInDb = "serialNumber")
    private String serialNumber;

    @Property(nameInDb = "apiVersion")
    private String apiVersion;

    @Property(nameInDb = "hardwareName")
    private String hardwareName;

    @Property(nameInDb = "bspVersion")
    private String bspVersion;

    @Property(nameInDb = "cameraName")
    private String cameraName;

    @Property(nameInDb = "mountHardwareVersion")
    private String mountHardwareVersion;

    @Property(nameInDb = "mountSoftwareVersion")
    private String mountSoftVersion;

    @Property(nameInDb = "mountSupport4g")
    private boolean mountSupport4g;

    @Property(nameInDb = "lastConnectingTime")
    private long lastConnectingTime;

    @Generated(hash = 2021611601)
    public CameraItem(Long id, String serialNumber, String apiVersion,
            String hardwareName, String bspVersion, String cameraName,
            String mountHardwareVersion, String mountSoftVersion,
            boolean mountSupport4g, long lastConnectingTime) {
        this.id = id;
        this.serialNumber = serialNumber;
        this.apiVersion = apiVersion;
        this.hardwareName = hardwareName;
        this.bspVersion = bspVersion;
        this.cameraName = cameraName;
        this.mountHardwareVersion = mountHardwareVersion;
        this.mountSoftVersion = mountSoftVersion;
        this.mountSupport4g = mountSupport4g;
        this.lastConnectingTime = lastConnectingTime;
    }

    @Generated(hash = 1447740351)
    public CameraItem() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSerialNumber() {
        return this.serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getApiVersion() {
        return this.apiVersion;
    }

    public void setApiVersion(String apiVersion) {
        this.apiVersion = apiVersion;
    }

    public String getHardwareName() {
        return this.hardwareName;
    }

    public void setHardwareName(String hardwareName) {
        this.hardwareName = hardwareName;
    }

    public String getBspVersion() {
        return this.bspVersion;
    }

    public void setBspVersion(String bspVersion) {
        this.bspVersion = bspVersion;
    }

    public String getCameraName() {
        return this.cameraName;
    }

    public void setCameraName(String cameraName) {
        this.cameraName = cameraName;
    }

    public String getMountHardwareVersion() {
        return this.mountHardwareVersion;
    }

    public void setMountHardwareVersion(String mountHardwareVersion) {
        this.mountHardwareVersion = mountHardwareVersion;
    }

    public String getMountSoftVersion() {
        return this.mountSoftVersion;
    }

    public void setMountSoftVersion(String mountSoftVersion) {
        this.mountSoftVersion = mountSoftVersion;
    }

    public boolean getMountSupport4g() {
        return this.mountSupport4g;
    }

    public void setMountSupport4g(boolean mountSupport4g) {
        this.mountSupport4g = mountSupport4g;
    }

    public long getLastConnectingTime() {
        return this.lastConnectingTime;
    }

    public void setLastConnectingTime(long lastConnectingTime) {
        this.lastConnectingTime = lastConnectingTime;
    }

}
