package com.mk.autosecure.rest_fleet.request;

import java.util.List;

public class TotalExportBody {
    private String end_time;
    private String start_time;
    private List<String> list_plate_no;
    private List<Integer> driver_id;

    public TotalExportBody(String end_time, String start_time, List<String> list_plate_no, String abc) {
        this.end_time = end_time;
        this.start_time = start_time;
        this.list_plate_no = list_plate_no;
    }

    public TotalExportBody(String end_time, String start_time, List<Integer> driver_id) {
        this.end_time = end_time;
        this.start_time = start_time;
        this.driver_id = driver_id;
    }

    public String getEnd_time() {
        return end_time;
    }

    public void setEnd_time(String end_time) {
        this.end_time = end_time;
    }

    public String getStart_time() {
        return start_time;
    }

    public void setStart_time(String start_time) {
        this.start_time = start_time;
    }

    public List<String> getList_plate_no() {
        return list_plate_no;
    }

    public void setList_plate_no(List<String> list_plate_no) {
        this.list_plate_no = list_plate_no;
    }

    public List<Integer> getDriver_id() {
        return driver_id;
    }

    public void setDriver_id(List<Integer> driver_id) {
        this.driver_id = driver_id;
    }

    @Override
    public String toString() {
        return "TotalExportBody{" +
                "end_time='" + end_time + '\'' +
                ", start_time='" + start_time + '\'' +
                ", list_plate_no='" + list_plate_no + '\'' +
                ", list_driver_id='" + driver_id + '\'' +
                '}';
    }
}
