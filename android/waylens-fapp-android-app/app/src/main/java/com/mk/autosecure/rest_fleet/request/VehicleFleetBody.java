package com.mk.autosecure.rest_fleet.request;

public class VehicleFleetBody {
    private String end_time;
    private String start_time;
    private String plate_no;
    private String driver_id;

    public VehicleFleetBody(String end_time, String start_time, String plate_no) {
        this.end_time = end_time;
        this.start_time = start_time;
        this.plate_no = plate_no;
    }

    public VehicleFleetBody(String end_time, String start_time, String plate_no, String driver_id) {
        this.end_time = end_time;
        this.start_time = start_time;
        this.plate_no = plate_no;
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

    public String getPlate_no() {
        return plate_no;
    }

    public void setPlate_no(String plate_no) {
        this.plate_no = plate_no;
    }


    @Override
    public String toString() {
        return "VehicleFleetBody{" +
                "end_time='" + end_time + '\'' +
                ", start_time='" + start_time + '\'' +
                ", plate_no='" + plate_no + '\'' +
                '}';
    }
}
