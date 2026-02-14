package com.mk.autosecure.rest.reponse;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class UploadAvatarServerResponse {
    public UploadServer uploadServer;

    public static class UploadServer {
        public String privateKey;
        public String url;

        @Override
        public String toString() {
            return "UploadServer{" +
                    "privateKey='" + privateKey + '\'' +
                    ", url='" + url + '\'' +
                    '}';
        }
    }
}
