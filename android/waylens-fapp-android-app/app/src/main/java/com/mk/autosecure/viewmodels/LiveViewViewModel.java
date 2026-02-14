package com.mk.autosecure.viewmodels;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.HornApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BPSResponse;
import com.mk.autosecure.rest.request.LiveControlBody;
import com.mk.autosecure.rest.request.LiveHeartbeatBody;
import com.mk.autosecure.rest.request.LiveStreamBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.FleetApiClient;
import com.mk.autosecure.rest_fleet.response.AudioStreamResponse;
import com.mk.autosecure.rest_fleet.response.StreamBpsResponse;
import com.mk.autosecure.ui.activity.LiveViewActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.bean.FourGSignalResponse;
import com.mk.autosecure.libs.account.CurrentUser;
import com.wowza.gocoder.sdk.api.WowzaGoCoder;
import com.wowza.gocoder.sdk.api.broadcast.WOWZBroadcast;
import com.wowza.gocoder.sdk.api.broadcast.WOWZBroadcastConfig;
import com.wowza.gocoder.sdk.api.configuration.WOWZMediaConfig;
import com.wowza.gocoder.sdk.api.data.WOWZDataMap;
import com.wowza.gocoder.sdk.api.devices.WOWZAudioDevice;
import com.wowza.gocoder.sdk.api.errors.WOWZStreamingError;
import com.wowza.gocoder.sdk.api.logging.WOWZLog;
import com.wowza.gocoder.sdk.api.status.WOWZStatus;
import com.wowza.gocoder.sdk.api.status.WOWZStatusCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/9/21.
 */


public interface LiveViewViewModel {
    interface Inputs {
        void sendHeartbeat(Long aLong);

        void setSerialNumber(String serialNumber);

        void isLiveOrNot(boolean isLive);

        void updateLiveTime(long absTime /* in millis*/);

        void startHeartbeat();

        void stopHeartbeat();

        void stopStreaming();

        void queryLiveSignal(String sn);

        void queryLiveBPS(String sn);

        void filterClipBean(Map<String, Integer> clipListStat, List<String> filterList);

        void filterVisibility(int visible);

        void startAudio();

        void endAudio(boolean appPausing);
    }

    interface Outputs {
        Observable<Long> liveTime();

        Observable<Float> liveSignal();

        Observable<Integer> liveBPS();

        Observable<Integer> loadClipBeans();

        Observable<Integer> filterVisibility();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();
    }

    final class ViewModel extends ActivityViewModel<LiveViewActivity> implements Inputs, Outputs, Errors, WOWZStatusCallback {
        public static final String TAG = LiveViewViewModel.ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            mApiService = ApiService.createApiService();
            mApiClient = ApiClient.createApiService();
            mContext = appComponent.appContext();
            gson = appComponent.gson();
            initAudioConfig();
        }

        static WowzaGoCoder sGoCoderSDK = null;

        private static boolean sBroadcastEnded = true;
        WOWZBroadcast mWZBroadcast = null;
        private static Object sBroadcastLock = new Object();
        WOWZBroadcastConfig mWZBroadcastConfig = null;
        int mWZNetworkLogLevel = WOWZLog.LOG_LEVEL_DEBUG;
        WOWZAudioDevice mWZAudioDevice = null;

        private void initAudioConfig() {
            if (sGoCoderSDK == null) {
                // Enable detailed logging from the GoCoder SDK
                WOWZLog.LOGGING_ENABLED = true;

                // Initialize the GoCoder SDK
                sGoCoderSDK = WowzaGoCoder.init(mContext, BuildConfig.WOWZA_LICENSE_KEY);

                if (sGoCoderSDK == null) {
                    Logger.t(TAG).e("sGoCoderSDK == null: " + WowzaGoCoder.getLastError());
                }
            }

            if (sGoCoderSDK != null) {
                // Create a new instance of the preferences mgr
//            mGoCoderSDKPrefs = new GoCoderSDKPrefs();

                // Create an instance for the broadcast configuration
                mWZBroadcastConfig = new WOWZBroadcastConfig(WOWZMediaConfig.FRAME_SIZE_1280x720);

                // Create a broadcaster instance
                mWZBroadcast = new WOWZBroadcast();
                mWZBroadcast.setLogLevel(WOWZLog.LOG_LEVEL_DEBUG);

                // Initialize the audio input device interface, need have permission RECORD_AUDIO
                mWZAudioDevice = new WOWZAudioDevice();

                // Set the audio broadcaster in the broadcast config
                mWZBroadcastConfig.setAudioBroadcaster(mWZAudioDevice);
            }
        }

        private HornApiService mApiService;
        private FleetApiClient mApiClient;
        private String mSerialNumber;
        private final Gson gson;
        private final Context mContext;

        private CurrentUser currentUser;
        private final PublishSubject<Integer> nextStep = PublishSubject.create();
        private Disposable heartBeatSub = new CompositeDisposable();

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();
        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private final BehaviorSubject<Long> liveTime = BehaviorSubject.create();

        private final BehaviorSubject<Float> liveSignal = BehaviorSubject.create();

        private final BehaviorSubject<Integer> liveBPS = BehaviorSubject.create();

        private final BehaviorSubject<Integer> loadClipBeans = BehaviorSubject.create();

        private final BehaviorSubject<Integer> filterBtnVisible = BehaviorSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        public volatile boolean isLiveOrNot = true;

        public volatile boolean isAudioPush = false;

        public List<String> filterList = new ArrayList<>();

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        public void setSerialNumber(String serialNumber) {
            this.mSerialNumber = serialNumber;
        }

        public String getSerialNumber() {
            return mSerialNumber;
        }

        @Override
        public void isLiveOrNot(boolean isLive) {
            this.isLiveOrNot = isLive;
        }

        @Override
        public void updateLiveTime(long absTime) {
            liveTime.onNext(absTime);
        }

        @Override
        public void startHeartbeat() {
            heartBeatSub = Observable.interval(0, 2, TimeUnit.SECONDS)
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(this::sendHeartbeat, new ServerErrorHandler(TAG));
        }

        @Override
        public void stopHeartbeat() {
            if (heartBeatSub != null && !heartBeatSub.isDisposed()) {
                heartBeatSub.dispose();
            }
        }

        public void sendHeartbeat(Long aLong) {
            LiveHeartbeatBody body = new LiveHeartbeatBody();
            body.sn = mSerialNumber;
            Logger.t(TAG).d("%s", "heart beat");
//            mApiService.liveHeartBeat(body)
//                    .subscribeOn(Schedulers.io())
//                    .compose(bindToLifecycle())
//                    .subscribe(new Consumer<BooleanResponse>() {
//                        @Override
//                        public void accept(BooleanResponse response) throws Exception {
//                            Logger.t(TAG).d("%s", ToStringUtils.getString(response));
//                        }
//                    }, new ServerErrorHandler(TAG));
        }

        public void stopStreaming() {
            LiveControlBody request = new LiveControlBody();
            request.sn = mSerialNumber;
            request.action = "stop";
            request.protocol = "rtmp";
//            try {
//                mApiService.controlLive(request)
//                        .subscribeOn(Schedulers.io())
//                        .compose(bindToLifecycle())
//                        .subscribe(new BaseObserver<LiveControlResponse>(appContext) {
//                            @Override
//                            protected void onHandleSuccess(LiveControlResponse data) {
//                                Logger.t(TAG).d("controlLive onHandleSuccess: %s", data.toString());
//                            }
//
//                            @Override
//                            protected void onHandleError(int code) {
//                                Logger.t(TAG).d("controlLive onHandleError: %s", code);
//                            }
//                        });
//            } catch (Exception e) {
//                Logger.t(TAG).d("stop error");
//            }
        }

        @Override
        public void queryLiveSignal(String sn) {
            if (Constants.isFleet()) {
                FleetCameraBean fleetCamera = currentUser.getFleetCamera(sn);
//                if (fleetCamera != null && fleetCamera.getOnlineStatus() != null) {
//                    double rsrp = fleetCamera.getOnlineStatus().getRSRP();
//                    liveSignal.onNext((float) rsrp);
//                }
            } else {
                mApiService.get4Gsignal(sn)
                        .lift(Operators.apiError(gson))
                        .subscribeOn(Schedulers.io())
//                    .compose(Transformers.pipeApiErrorsTo(apiError))
//                    .compose(Transformers.pipeErrorsTo(networkError))
                        .compose(Transformers.neverError())
                        .compose(bindToLifecycle())
                        .subscribe(this::onLiveSignal);
            }
        }

        private void onLiveSignal(FourGSignalResponse data) {
            Logger.t(TAG).d("get4Gsignal: " + data.toString());
            liveSignal.onNext(data.RSRP);
        }

        @Override
        public void queryLiveBPS(String sn) {
            if (Constants.isFleet()) {
                mApiClient.getCameraBPS(sn, HornApplication.getComponent().currentUser().getAccessToken())
                        .lift(Operators.apiError(gson))
                        .subscribeOn(Schedulers.io())
                        .compose(Transformers.neverError())
                        .compose(bindToLifecycle())
                        .subscribe(this::onStreamBps);
            } else {
                mApiService.getCameraBPS(sn)
                        .lift(Operators.apiError(gson))
                        .subscribeOn(Schedulers.io())
//                    .compose(Transformers.pipeApiErrorsTo(apiError))
//                    .compose(Transformers.pipeErrorsTo(networkError))
                        .compose(Transformers.neverError())
                        .compose(bindToLifecycle())
                        .subscribe(this::onLiveBPS);
            }
        }

        @Override
        public void filterClipBean(Map<String, Integer> clipListStat, List<String> filterList) {
            this.filterList = filterList;
            if (filterList.size() == 0) {
                int count = 0;
                for (Integer integer : clipListStat.values()) {
                    count += integer;
                }
                loadClipBeans.onNext(count);
            } else {
                List<String> list = VideoEventType.getStringTypeFilterList(mContext, filterList);

                int count = 0;

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (Map.Entry<String, Integer> next : clipListStat.entrySet()) {
                        if (list.get(i).equals(next.getKey())) {
                            count += next.getValue();
                        }
                    }
                }
                loadClipBeans.onNext(count);
            }
        }

        @Override
        public void filterVisibility(int visible) {
            filterBtnVisible.onNext(visible);
        }

        @Override
        public void startAudio() {
            LiveStreamBody streamBody = new LiveStreamBody();
            streamBody.action = "start";

            ApiClient.createApiService().startAudio(mSerialNumber, streamBody)
                    .subscribeOn(Schedulers.io())
                    .lift(Operators.apiError(gson))
                    .compose(Transformers.pipeApiErrorsTo(apiError))
                    .compose(Transformers.pipeErrorsTo(networkError))
                    .compose(Transformers.neverError())
                    .compose(bindToLifecycle())
                    .subscribe(this::onToggleBroadcast);
        }

        @Override
        public void endAudio(boolean appPausing) {
            LiveStreamBody streamBody = new LiveStreamBody();
            streamBody.action = "stop";

            ApiClient.createApiService().endAudio(mSerialNumber, streamBody)
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(this::onToggleBroadcast, new ServerErrorHandler(TAG));
        }

        private void onLiveBPS(BPSResponse data) {
            int bps = data.bps;
            Logger.t(TAG).d("onLiveBPS: " + bps);
            liveBPS.onNext(bps);
        }

        private void onStreamBps(StreamBpsResponse response) {
            int bytesInRate = response.getBytesInRate();
            Logger.t(TAG).d("onStreamBps: " + bytesInRate);
            liveBPS.onNext(bytesInRate);
        }

        @Override
        public Observable<Long> liveTime() {
            return liveTime;
        }

        @Override
        public Observable<Float> liveSignal() {
            return liveSignal;
        }

        @Override
        public Observable<Integer> liveBPS() {
            return liveBPS;
        }

        @Override
        public Observable<Integer> loadClipBeans() {
            return loadClipBeans;
        }

        @Override
        public Observable<Integer> filterVisibility() {
            return filterBtnVisible;
        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }

        private void onToggleBroadcast(AudioStreamResponse response) {
            if (mWZBroadcast == null) {
                return;
            }

            if (mWZBroadcast.getStatus().isIdle()) {
                if (!mWZBroadcastConfig.isVideoEnabled() && !mWZBroadcastConfig.isAudioEnabled()) {
                    Logger.t(TAG).d("Unable to publish if both audio and video are disabled");
                } else {
                    if (!mWZBroadcastConfig.isAudioEnabled()) {
                        Logger.t(TAG).d("The audio stream is currently turned off");
                    }

                    if (!mWZBroadcastConfig.isVideoEnabled()) {
                        Logger.t(TAG).d("The video stream is currently turned off");
                    }

                    AudioStreamResponse.PushInfoBean pushInfo = response.getPushInfo();

//                    mWZBroadcastConfig.setUsername(pushInfo.getUserName());
//                    mWZBroadcastConfig.setPassword(pushInfo.getPassword());
                    // TODO: 2019-09-16 server settings bug --ziwen
                    mWZBroadcastConfig.setUsername("fleet_audio");
                    mWZBroadcastConfig.setPassword("waylensfleet2019");

                    String url = pushInfo.getUrl();

                    int i = url.indexOf("//");
                    String substring = url.substring(i + 2);
                    String[] audioInfo = substring.split("/");

                    String s = audioInfo[0];
                    String[] hostAddress = s.split(":");

                    mWZBroadcastConfig.setHostAddress(hostAddress[0]);
                    mWZBroadcastConfig.setPortNumber(Integer.valueOf(hostAddress[1]));
                    mWZBroadcastConfig.setApplicationName(audioInfo[1]);
                    mWZBroadcastConfig.setStreamName(audioInfo[2]);

                    WOWZStreamingError configError = startBroadcast();
                    if (configError != null) {
                        Logger.t(TAG).e("configError: " + configError.getErrorDescription());
                    }
                }
            } else {
                endBroadcast();
            }
        }

        protected synchronized WOWZStreamingError startBroadcast() {
            WOWZStreamingError configValidationError = null;

            if (mWZBroadcast.getStatus().isIdle()) {

                // Set the detail level for network logging output
                mWZBroadcast.setLogLevel(mWZNetworkLogLevel);

                //
                // An example of adding metadata values to the stream for use with the onMetadata()
                // method of the IMediaStreamActionNotify2 interface of the Wowza Streaming Engine Java
                // API for server modules.
                //
                // See http://www.wowza.com/resources/serverapi/com/wowza/wms/stream/IMediaStreamActionNotify2.html
                // for additional usage information on IMediaStreamActionNotify2.
                //

                // Add stream metadata describing the current device and platform
                WOWZDataMap streamMetadata = new WOWZDataMap();
                streamMetadata.put("androidRelease", Build.VERSION.RELEASE);
                streamMetadata.put("androidSDK", Build.VERSION.SDK_INT);
                streamMetadata.put("deviceProductName", Build.PRODUCT);
                streamMetadata.put("deviceManufacturer", Build.MANUFACTURER);
                streamMetadata.put("deviceModel", Build.MODEL);

                mWZBroadcastConfig.setStreamMetadata(streamMetadata);

                //
                // An example of adding query strings for use with the getQueryStr() method of
                // the IClient interface of the Wowza Streaming Engine Java API for server modules.
                //
                // See http://www.wowza.com/resources/serverapi/com/wowza/wms/client/IClient.html#getQueryStr()
                // for additional usage information on getQueryStr().
                //
                try {
                    PackageInfo pInfo = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);

                    // Add query string parameters describing the current app
                    WOWZDataMap connectionParameters = new WOWZDataMap();
                    connectionParameters.put("appPackageName", pInfo.packageName);
                    connectionParameters.put("appVersionName", pInfo.versionName);
                    connectionParameters.put("appVersionCode", pInfo.versionCode);

                    mWZBroadcastConfig.setConnectionParameters(connectionParameters);

                } catch (PackageManager.NameNotFoundException e) {
                    Logger.t(TAG).e("packageInfo: " + e.getMessage());
                }

                mWZBroadcastConfig.setVideoEnabled(false);
                mWZBroadcastConfig.setAudioEnabled(true);

                mWZBroadcastConfig.setAudioChannels(1);
                mWZBroadcastConfig.setAudioSampleRate(16000);
                mWZBroadcastConfig.setAudioBitRate(16000);

                Logger.t(TAG).i("=============== Broadcast Configuration ===============\n"
                        + mWZBroadcastConfig.toString()
                        + "\n=======================================================");

                configValidationError = mWZBroadcastConfig.validateForBroadcast();

                if (configValidationError == null) {
                    WOWZLog.debug("***** [FPS]GoCoderSDKActivity " + mWZBroadcastConfig.getAudioSampleRate());
                    mWZBroadcast.startBroadcast(mWZBroadcastConfig, this);
                }
            } else {
                WOWZLog.error(TAG, "startBroadcast() called while another broadcast is active");
            }
            return configValidationError;
        }

        protected synchronized void endBroadcast() {
            endBroadcast(false);
        }

        protected synchronized void endBroadcast(boolean appPausing) {
            WOWZLog.debug("MP4", "endBroadcast");
            if (!mWZBroadcast.getStatus().isIdle()) {
                WOWZLog.debug("MP4", "endBroadcast-notidle");
                if (appPausing) {
                    // Stop any active live stream
                    sBroadcastEnded = false;
                    mWZBroadcast.endBroadcast(new WOWZStatusCallback() {
                        @Override
                        public void onWZStatus(WOWZStatus wzStatus) {
                            WOWZLog.debug("MP4", "onWZStatus::" + wzStatus.toString());
                            synchronized (sBroadcastLock) {
                                sBroadcastEnded = true;
                                sBroadcastLock.notifyAll();
                            }
                        }

                        @Override
                        public void onWZError(WOWZStatus wzStatus) {
                            WOWZLog.debug("MP4", "onWZStatus::" + wzStatus.getLastError());
                            WOWZLog.error(TAG, wzStatus.getLastError());
                            synchronized (sBroadcastLock) {
                                sBroadcastEnded = true;
                                sBroadcastLock.notifyAll();
                            }
                        }
                    });

                    while (!sBroadcastEnded) {
                        try {
                            sBroadcastLock.wait();
                        } catch (InterruptedException e) {
                        }
                    }
                } else {
                    mWZBroadcast.endBroadcast(this);
                }
            } else {
                WOWZLog.error(TAG, "endBroadcast() called without an active broadcast");
            }
        }

        @Override
        public void onWZStatus(WOWZStatus wowzStatus) {
            Logger.t(TAG).d("onWZStatus: " + wowzStatus.toString());
        }

        @Override
        public void onWZError(WOWZStatus wowzStatus) {
            Logger.t(TAG).e("onWZError: " + wowzStatus.toString());
        }
    }
}
