package com.mk.autosecure.rest_fleet.request;

import java.util.List;

public class AddFenceBody {
    public String name;
    public String description;
    public List<Double> center;
    public int radius;
    public List<List<Double>> polygon;
}
