package com.mkgroup.camera.message.bean;

public class DriverInfoBody {
    String DriverName;
    String Driver_License_No;
    String Plate_Number;

    public DriverInfoBody(String driverName, String driver_license_No, String plate_Number) {
        DriverName = driverName;
        Driver_License_No = driver_license_No;
        Plate_Number = plate_Number;
    }

    public String getDriverName() {
        return DriverName;
    }

    public void setDriverName(String driverName) {
        DriverName = driverName;
    }

    public String getDriver_license_No() {
        return Driver_License_No;
    }

    public void setDriver_license_No(String driver_license_No) {
        Driver_License_No = driver_license_No;
    }

    public String getPlate_Number() {
        return Plate_Number;
    }

    public void setPlate_Number(String plate_Number) {
        Plate_Number = plate_Number;
    }
}
