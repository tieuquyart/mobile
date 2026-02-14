package com.mk.autosecure.rest_fleet.response;

public class AudioStreamResponse {

    /**
     * status : online
     * pushInfo : {"url":"rtmp://47.100.62.3:1935/audio_test/audio_2B17NKKX","userName":"","password":""}
     */

    private String status;
    private PushInfoBean pushInfo;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public PushInfoBean getPushInfo() {
        return pushInfo;
    }

    public void setPushInfo(PushInfoBean pushInfo) {
        this.pushInfo = pushInfo;
    }

    public static class PushInfoBean {
        /**
         * url : rtmp://47.100.62.3:1935/audio_test/audio_2B17NKKX
         * userName :
         * password :
         */

        private String url;
        private String userName;
        private String password;

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getUserName() {
            return userName;
        }

        public void setUserName(String userName) {
            this.userName = userName;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
