package com.mk.autosecure.uploadqueue.body;

import java.io.Serializable;

/**
 * Created by doanvt on 16/9/24.
 */

public class GeoInfo implements Serializable {
    public double longitude;
    public double latitude;
    public String country;
    public String region;
    public String city;
}