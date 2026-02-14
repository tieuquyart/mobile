package com.mkgroup.camera.message.bean;

public class MountSettingsBean {

    /**
     * checksum : 230
     * parkingMode : {"detectionSensitivity":"medium","uploadSensitivity":"medium","nightVision":"on"}
     * drivingMode : {"detectionSensitivity":"medium","uploadSensitivity":"off","nightVision":"off","nightVisionTime":{"from":1100,"to":330}}
     * logoLED : on
     * flashLED : off
     * siren : on
     */

    private int checksum;
    private ParkingModeBean parkingMode;
    private DrivingModeBean drivingMode;
    private String logoLED;
    private String flashLED;
    private String siren;

    public MountSettingsBean(int checksum, ParkingModeBean parkingMode, DrivingModeBean drivingMode, String logoLED, String flashLED, String siren) {
        this.checksum = checksum;
        this.parkingMode = parkingMode;
        this.drivingMode = drivingMode;
        this.logoLED = logoLED;
        this.flashLED = flashLED;
        this.siren = siren;
    }

    public int getChecksum() {
        return checksum;
    }

    public void setChecksum(int checksum) {
        this.checksum = checksum;
    }

    public ParkingModeBean getParkingMode() {
        return parkingMode;
    }

    public void setParkingMode(ParkingModeBean parkingMode) {
        this.parkingMode = parkingMode;
    }

    public DrivingModeBean getDrivingMode() {
        return drivingMode;
    }

    public void setDrivingMode(DrivingModeBean drivingMode) {
        this.drivingMode = drivingMode;
    }

    public String getLogoLED() {
        return logoLED;
    }

    public void setLogoLED(String logoLED) {
        this.logoLED = logoLED;
    }

    public String getFlashLED() {
        return flashLED;
    }

    public void setFlashLED(String flashLED) {
        this.flashLED = flashLED;
    }

    public String getSiren() {
        return siren;
    }

    public void setSiren(String siren) {
        this.siren = siren;
    }

    public static class ParkingModeBean {
        /**
         * detectionSensitivity : medium
         * uploadSensitivity : medium
         * nightVision : on
         */

        private String detectionSensitivity;
        private String uploadSensitivity;
        private String nightVision;

        public String getDetectionSensitivity() {
            return detectionSensitivity;
        }

        public void setDetectionSensitivity(String detectionSensitivity) {
            this.detectionSensitivity = detectionSensitivity;
        }

        public String getUploadSensitivity() {
            return uploadSensitivity;
        }

        public void setUploadSensitivity(String uploadSensitivity) {
            this.uploadSensitivity = uploadSensitivity;
        }

        public String getNightVision() {
            return nightVision;
        }

        public void setNightVision(String nightVision) {
            this.nightVision = nightVision;
        }
    }

    public static class DrivingModeBean {
        /**
         * detectionSensitivity : medium
         * uploadSensitivity : off
         * nightVision : off
         * nightVisionTime : {"from":1100,"to":330}
         */

        private String detectionSensitivity;
        private String uploadSensitivity;
        private String nightVision;
        private NightVisionTimeBean nightVisionTime;

        public String getDetectionSensitivity() {
            return detectionSensitivity;
        }

        public void setDetectionSensitivity(String detectionSensitivity) {
            this.detectionSensitivity = detectionSensitivity;
        }

        public String getUploadSensitivity() {
            return uploadSensitivity;
        }

        public void setUploadSensitivity(String uploadSensitivity) {
            this.uploadSensitivity = uploadSensitivity;
        }

        public String getNightVision() {
            return nightVision;
        }

        public void setNightVision(String nightVision) {
            this.nightVision = nightVision;
        }

        public NightVisionTimeBean getNightVisionTime() {
            return nightVisionTime;
        }

        public void setNightVisionTime(NightVisionTimeBean nightVisionTime) {
            this.nightVisionTime = nightVisionTime;
        }

        public static class NightVisionTimeBean {
            /**
             * from : 1100
             * to : 330
             */

            private int from;
            private int to;

            public int getFrom() {
                return from;
            }

            public void setFrom(int from) {
                this.from = from;
            }

            public int getTo() {
                return to;
            }

            public void setTo(int to) {
                this.to = to;
            }
        }
    }
}
