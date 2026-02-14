package com.mk.autosecure.rest.reponse;

import java.io.Serializable;

/**
 * Created by DoanVT on 2017/9/21.
 */

public class LiveStatusResponse implements Serializable {
    public static final String PREPARING_STATE = "preparing";
    public static final String ALLOC_STREAMING_ADDRESS_STATE = "allocStreamingAddress";
    public static final String NOTIFY_STREAMING_ADDRESS_STATE = "notifyStreamingAddress";
    public static final String BEGIN_STREAMING_STATE = "beginToStreaming";
    public static final String FIAL_TO_STREAMING = "failToStreaming";

    public static final String WAIT_PUBLISH_STATE = "waitForPublish";
    public static final String LIVE_STATE = "live";
    public static final String WAIT_AWAKE_STATE = "waitForAwake";
    public static final String OFFLINE_STATE = "offline";

    public String code;
    public String message;
    public boolean success;
    public DataLive data;

    public class DataLive {
        public String status;// waitForPublish, live, waitForAwake, offline
        public String playUrl;
        public String rotate;
        public String transactionId;

        @Override
        public String toString() {
            return "DataLive{" +
                    "status='" + status + '\'' +
                    ", playUrl='" + playUrl + '\'' +
                    ", rotate='" + rotate + '\'' +
                    ", transactionId='" + transactionId + '\'' +
                    '}';
        }
    }
}
