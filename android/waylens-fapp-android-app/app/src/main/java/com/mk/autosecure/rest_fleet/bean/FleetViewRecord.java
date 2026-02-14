package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class FleetViewRecord implements Serializable {
    public int driverId;
    public String driverName;
    public String cameraSn;
    public String simState;
    public boolean isOnline;
    public String mode;
    public SignalInfo signalInfo;
    public GpsData gpsData;
    public String plateNo;
    public double miles;
    public double hours;
    public int events;
    public String lastPicture;
    public Object speedDevice;
    public String type;
    public String brand;
    public String phoneNo;

}


