package com.mk.autosecure.rest_fleet.response;

import com.mkgroup.camera.bean.FirmwareBean;

public class FirmwareResponse {

    /**
     * firmware : {"id":12,"hardwareVersion":"SC_V1H","firmware":"2.747.45.132.509","firmwareShort":"1.13.10","description":"Update several functions.","md5sum":"aebf837fbba91498ba8fdff3f2d8bdc2","file":"https://tscastle.cam2cloud.com:9002/file/SC_V1H_2.747.45.132.509_1.13.10.tsf","size":22603776,"releaseTime":1565858184973}
     */

    private FirmwareBean firmware;

    public FirmwareBean getFirmware() {
        return firmware;
    }

    public void setFirmware(FirmwareBean firmware) {
        this.firmware = firmware;
    }

}
