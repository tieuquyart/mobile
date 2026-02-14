package com.mk.autosecure.rest_fleet.bean;

public class LastLocationBean {

    /**
     * cameraSN : 2B17NKWL
     * plateNumber :
     * driver :
     * isOnline : true
     * mode : driving
     * gps : {"time":1569393570523,"coordinate":{"longitude":121.601483,"latitude":31.1908118,"altitude":17.2},"speed":0.3759559988975525,"track":0,"gpsTime":1569393572000,"hDop":182,"vDop":355}
     */

    private String cameraSN;
    private String plateNumber;
    private String driverName;
    private String driverID;
    private String cameraStatus;
    private GpsBean gps;

    public String getDriverID() {
        return driverID;
    }

    public void setDriverID(String driverID) {
        this.driverID = driverID;
    }

    public String getCameraSN() {
        return cameraSN;
    }

    public void setCameraSN(String cameraSN) {
        this.cameraSN = cameraSN;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getCameraStatus() {
        return cameraStatus;
    }

    public void setCameraStatus(String cameraStatus) {
        this.cameraStatus = cameraStatus;
    }

    public GpsBean getGps() {
        return gps;
    }

    public void setGps(GpsBean gps) {
        this.gps = gps;
    }

    public static class GpsBean {
        /**
         * time : 1569393570523
         * coordinate : {"longitude":121.601483,"latitude":31.1908118,"altitude":17.2}
         * speed : 0.3759559988975525
         * track : 0
         * gpsTime : 1569393572000
         * hDop : 182
         * vDop : 355
         */

        private long time;
        private CoordinateBean coordinate;
        private double speed;
        private double track;
        private long gpsTime;
        private int hDop;
        private int vDop;

        public long getTime() {
            return time;
        }

        public void setTime(long time) {
            this.time = time;
        }

        public CoordinateBean getCoordinate() {
            return coordinate;
        }

        public void setCoordinate(CoordinateBean coordinate) {
            this.coordinate = coordinate;
        }

        public double getSpeed() {
            return speed;
        }

        public void setSpeed(double speed) {
            this.speed = speed;
        }

        public double getTrack() {
            return track;
        }

        public void setTrack(double track) {
            this.track = track;
        }

        public long getGpsTime() {
            return gpsTime;
        }

        public void setGpsTime(long gpsTime) {
            this.gpsTime = gpsTime;
        }

        public int getHDop() {
            return hDop;
        }

        public void setHDop(int hDop) {
            this.hDop = hDop;
        }

        public int getVDop() {
            return vDop;
        }

        public void setVDop(int vDop) {
            this.vDop = vDop;
        }

        public static class CoordinateBean {
            /**
             * longitude : 121.601483
             * latitude : 31.1908118
             * altitude : 17.2
             */

            private double longitude;
            private double latitude;
            private double altitude;

            public double getLongitude() {
                return longitude;
            }

            public void setLongitude(double longitude) {
                this.longitude = longitude;
            }

            public double getLatitude() {
                return latitude;
            }

            public void setLatitude(double latitude) {
                this.latitude = latitude;
            }

            public double getAltitude() {
                return altitude;
            }

            public void setAltitude(double altitude) {
                this.altitude = altitude;
            }

            @Override
            public String toString() {
                return "CoordinateBean{" +
                        "longitude=" + longitude +
                        ", latitude=" + latitude +
                        ", altitude=" + altitude +
                        '}';
            }
        }

        @Override
        public String toString() {
            return "GpsBean{" +
                    "time=" + time +
                    ", coordinate=" + coordinate +
                    ", speed=" + speed +
                    ", track=" + track +
                    ", gpsTime=" + gpsTime +
                    ", hDop=" + hDop +
                    ", vDop=" + vDop +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "LastLocationBean{" +
                "cameraSN='" + cameraSN + '\'' +
                ", plateNumber='" + plateNumber + '\'' +
                ", driverName='" + driverName + '\'' +
                ", driverID='" + driverID + '\'' +
                ", cameraStatus='" + cameraStatus + '\'' +
                ", gps=" + gps +
                '}';
    }
}
