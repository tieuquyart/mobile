package com.mk.autosecure.rest_fleet.bean;

public class TimelineBean {

    /**
     * timelineTime : 1571910222000
     * timelineType : IgnitionStatus
     * fleetID : 268515b6e04e48e5838a3fcfed63d65c
     * cameraSN : 2B17NKK5
     * driverID : 9547858fab143d7d6b96d363ca5cac02
     * vehicleID : fcbcefd82f3af16c101a02711eb01514
     * ignition : {"tripID":"2e6360ac-802d-439c-b46e-6d379d2a1a51","ignitionStatus":"driving"}
     * event : {"eventType":"HARD_ACCEL","clipID":"347322415186968576","country":"China","region":"Shanghai Shi","city":"","route":"Libing Road","streetNumber":"69","address":"69 Libing Rd, Pudong Xinqu, Shanghai Shi, China, 200135"}
     */

    private long timelineTime;
    private String timelineType;
    private String fleetID;
    private String cameraSN;
    private String driverID;
    private String driverName;
    private String vehicleID;
    private String plateNumber;
    private IgnitionBean ignition;
    private EventBean event;
    private GeoFenceEventBean geoFenceEvent;

    public GeoFenceEventBean getGeoFenceEvent() {
        return geoFenceEvent;
    }

    public void setGeoFenceEvent(GeoFenceEventBean geoFenceEvent) {
        this.geoFenceEvent = geoFenceEvent;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public long getTimelineTime() {
        return timelineTime;
    }

    public void setTimelineTime(long timelineTime) {
        this.timelineTime = timelineTime;
    }

    public String getTimelineType() {
        return timelineType;
    }

    public void setTimelineType(String timelineType) {
        this.timelineType = timelineType;
    }

    public String getFleetID() {
        return fleetID;
    }

    public void setFleetID(String fleetID) {
        this.fleetID = fleetID;
    }

    public String getCameraSN() {
        return cameraSN;
    }

    public void setCameraSN(String cameraSN) {
        this.cameraSN = cameraSN;
    }

    public String getDriverID() {
        return driverID;
    }

    public void setDriverID(String driverID) {
        this.driverID = driverID;
    }

    public String getVehicleID() {
        return vehicleID;
    }

    public void setVehicleID(String vehicleID) {
        this.vehicleID = vehicleID;
    }

    public IgnitionBean getIgnition() {
        return ignition;
    }

    public void setIgnition(IgnitionBean ignition) {
        this.ignition = ignition;
    }

    public EventBean getEvent() {
        return event;
    }

    public void setEvent(EventBean event) {
        this.event = event;
    }

    public static class EventBean {
        /**
         * eventType : HARD_ACCEL
         * clipID : 347322415186968576
         * country : China
         * region : Shanghai Shi
         * city :
         * route : Libing Road
         * streetNumber : 69
         * address : 69 Libing Rd, Pudong Xinqu, Shanghai Shi, China, 200135
         */

        private String eventType;
        private String clipID;
        private long duration;
        private String country;
        private String region;
        private String city;
        private String route;
        private String streetNumber;
        private String address;

        public String getEventType() {
            return eventType;
        }

        public void setEventType(String eventType) {
            this.eventType = eventType;
        }

        public String getClipID() {
            return clipID;
        }

        public void setClipID(String clipID) {
            this.clipID = clipID;
        }

        public String getCountry() {
            return country;
        }

        public void setCountry(String country) {
            this.country = country;
        }

        public String getRegion() {
            return region;
        }

        public void setRegion(String region) {
            this.region = region;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getRoute() {
            return route;
        }

        public void setRoute(String route) {
            this.route = route;
        }

        public String getStreetNumber() {
            return streetNumber;
        }

        public void setStreetNumber(String streetNumber) {
            this.streetNumber = streetNumber;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public long getDuration() {
            return duration;
        }

        public void setDuration(long duration) {
            this.duration = duration;
        }

        @Override
        public String toString() {
            return "EventBean{" +
                    "eventType='" + eventType + '\'' +
                    ", clipID='" + clipID + '\'' +
                    ", duration=" + duration +
                    ", country='" + country + '\'' +
                    ", region='" + region + '\'' +
                    ", city='" + city + '\'' +
                    ", route='" + route + '\'' +
                    ", streetNumber='" + streetNumber + '\'' +
                    ", address='" + address + '\'' +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "TimelineBean{" +
                "timelineTime=" + timelineTime +
                ", timelineType='" + timelineType + '\'' +
                ", fleetID='" + fleetID + '\'' +
                ", cameraSN='" + cameraSN + '\'' +
                ", driverID='" + driverID + '\'' +
                ", driverName='" + driverName + '\'' +
                ", vehicleID='" + vehicleID + '\'' +
                ", plateNumber='" + plateNumber + '\'' +
                ", ignition=" + ignition +
                ", event=" + event +
                ", geoFenceEvent=" + geoFenceEvent +
                '}';
    }
}
