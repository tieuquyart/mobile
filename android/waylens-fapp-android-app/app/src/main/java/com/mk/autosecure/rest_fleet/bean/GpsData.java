package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class GpsData implements Serializable {
    public String time;
    public double speed;
    public ArrayList<Double> coordinate;
    public double heading;
    public double hdop;
    public double vdop;
}
