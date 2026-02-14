package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;
import android.content.Context;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.bean.CameraEventBean;
import com.mk.autosecure.rest_fleet.bean.EventDetailBean;
import com.mk.autosecure.rest_fleet.bean.FleetViewRecord;
import com.mk.autosecure.rest_fleet.bean.VideoUrlBean;
import com.mk.autosecure.ui.fragment.PreviewFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.SortUtil;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FleetViewBean;
import com.mk.autosecure.rest_fleet.bean.TrackBean;
import com.mk.autosecure.rest_fleet.bean.TripBean;
import com.mk.autosecure.rest_fleet.response.Response;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@SuppressLint("SimpleDateFormat")
public interface PreviewFragmentViewModel {

    interface Inputs {
        void refreshCamera(boolean isForced);

        void refreshOverview(boolean isNeedMoveMap);

        void getMoreFleet(int index);

        void queryTrips(boolean isNeedMoveMap);

        void queryEvents();

        void queryTrack(TripBean bean, boolean moveMap);

        void queryVideoUrl(CameraEventBean bean);

        void queryUnread(String from, String to);
    }

    interface Outputs {
        Observable<Map<List<FleetViewRecord>, Boolean>> summaryList();

        Observable<Map<List<TripBean>, Boolean>> tripList();

        Observable<Map<TripBean, Boolean>> trackList();

        Observable<List<CameraEventBean>> eventList();

        Observable<Optional<EventDetailBean>> eventDetail();

        Observable<Optional<VideoUrlBean>> videoUrlDetail();

        Observable<Optional<Integer>> unreadNotification();

        Observable<FleetViewBean> fleetViewBean();

        Observable<Double> totalPage();

        Observable<Double> currentIndex();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();

        Observable<Response> responseErr();
    }

    @SuppressLint("CheckResult")
    final class ViewModel extends FragmentViewModel<PreviewFragment> implements Inputs, Outputs, Errors {

        private static final String TAG = ViewModel.class.getSimpleName();

        private static final int count = 10;

        private long mEventCursor = 0;

        private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

        //        public String driverID;
        public String cameraSn;

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        private final CurrentUser currentUser;

        private Context mContext;

        private final BehaviorSubject<Map<List<FleetViewRecord>, Boolean>> summaryList = BehaviorSubject.create();

        private final BehaviorSubject<Map<List<TripBean>, Boolean>> tripList = BehaviorSubject.create();

        private final BehaviorSubject<Map<TripBean, Boolean>> trackList = BehaviorSubject.create();

        private final BehaviorSubject<List<CameraEventBean>> eventList = BehaviorSubject.create();

        private final BehaviorSubject<Optional<EventDetailBean>> eventDetail = BehaviorSubject.create();

        private final BehaviorSubject<Optional<VideoUrlBean>> videoUrlDetail = BehaviorSubject.create();

        private final BehaviorSubject<Optional<Integer>> unreadNotification = BehaviorSubject.create();

        private final BehaviorSubject<Double> totalPages = BehaviorSubject.create();

        private final BehaviorSubject<Double> currentIndex = BehaviorSubject.create();

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private final PublishSubject<Response> responseErr = PublishSubject.create();

        private final PublishSubject<FleetViewBean> fleetViewBeanSub = PublishSubject.create();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            mContext = appComponent.appContext();
        }

        @Override
        public void refreshCamera(boolean isForced) {
            if (Constants.isFleet()) {
                getCameras(isForced);
            } else {
                ApiService.createApiService().getCameras()
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                           if(response.isSuccess()){
                               Logger.t(TAG).d("getCameras: " + response.cameras);
                               currentUser.refreshDevices(SortUtil.sort(response.cameras), isForced);
                           }else{
                               responseErr.onNext(response);
                           }
                        }, throwable -> {
                            Logger.t(TAG).d("getCameras throwable: " + throwable.getMessage());
                            currentUser.refreshDevices(SortUtil.sort(currentUser.getDevices()), isForced);
                        });
            }
        }

        /**
         * lấy thông tin camera
         */
        private void getCameras(boolean isForced) {
            fleetCameraBeanList.clear();

            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            List<FleetCameraBean> cameras = response.getData();
                            fleetCameraBeanList.addAll(cameras);
                            currentUser.refreshFleetDevices(SortUtil.sortFleet(fleetCameraBeanList), isForced);
                        } else {
                            responseErr.onNext(response);
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getCameras throwable: " + throwable.getMessage());
                        currentUser.refreshFleetDevices(SortUtil.sortFleet(currentUser.getFleetDevices()), isForced);
                    });
        }

        /**
         * reload lại màn hình overview - getFleetView page
         */
        @Override
        public void refreshOverview(boolean isNeedMoveMap) {
            String pattern = "yyyy-MM-dd";
            String dateInString = new SimpleDateFormat(pattern).format(new Date());
            String accessToken = currentUser.getAccessToken();

            Map<List<FleetViewRecord>, Boolean> map = new HashMap<>();

            ApiClient.createApiService().getFleetView(1, 1, 10, dateInString, accessToken)
                    .subscribeOn(Schedulers.io())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            FleetViewBean fleetView = response.getData();
                            Logger.t(TAG).d("cameraSN:= " + fleetView.getRecords().get(0).cameraSn);
                            map.put(response.getData().getRecords(), isNeedMoveMap);
                            fleetViewBeanSub.onNext(fleetView);
                            totalPages.onNext(fleetView.getPages());
                            currentIndex.onNext(fleetView.getCurrent());
                            summaryList.onNext(map);
                        } else {
                            responseErr.onNext(response);
                            summaryList.onNext(map);
                            totalPages.onNext(0.0);
                            currentIndex.onNext(0.0);
                            Logger.t(TAG).d("error = " + response.getMessage());
                        }
                    }, throwable -> {
                        //test
                        summaryList.onNext(map);
                        Logger.t(TAG).d("error = " + throwable.getMessage());
                    });
        }

        @Override
        public void getMoreFleet(int index) {
            String pattern = "yyyy-MM-dd";
            String dateInString = new SimpleDateFormat(pattern).format(new Date());
            String accessToken = currentUser.getAccessToken();

            Map<List<FleetViewRecord>, Boolean> map = new HashMap<>();

            ApiClient.createApiService().getFleetView(index, 1, 10, dateInString, accessToken)
                    .subscribeOn(Schedulers.io())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            FleetViewBean fleetView = response.getData();
                            Logger.t(TAG).d("cameraSN:= " + fleetView.getRecords().get(0).cameraSn);
                            map.put(response.getData().getRecords(), false);
                            totalPages.onNext(fleetView.getPages());
                            currentIndex.onNext(fleetView.getCurrent());
                            fleetViewBeanSub.onNext(fleetView);
                            summaryList.onNext(map);
                        } else {
                            responseErr.onNext(response);
                            summaryList.onNext(map);
                            totalPages.onNext(0.0);
                            currentIndex.onNext(0.0);
                            Logger.t(TAG).d("error = " + response.getMessage());
                        }
                    }, throwable -> {
                        summaryList.onNext(map);
                        Logger.t(TAG).d("error = " + throwable.getMessage());
                    });
        }

        /**
         * lấy thông tin trips
         */
        @Override
        public void queryTrips(boolean isNeedMoveMap) {
            String pattern = "yyyy-MM-dd";
            String dateInString = new SimpleDateFormat(pattern).format(new Date());

            Map<List<TripBean>, Boolean> map = new HashMap<>();
            ApiClient.createApiService().getTrips(cameraSn, dateInString, currentUser.getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(tripsResponse -> {
                        if (tripsResponse.isSuccess()) {
                            List<TripBean> trips = tripsResponse.getTrips();
                            map.put(trips, isNeedMoveMap);
                            tripList.onNext(map);
                            Logger.t(TAG).d("trips size: " + trips.size());
                            if (trips.size() != 0){
                                queryTrack(trips.get(0), isNeedMoveMap);
//                                queryEventsForTrip(trips.get(0));
                            }
                        } else {
                            responseErr.onNext(tripsResponse);
                            Logger.t(TAG).d("error = " + tripsResponse.getMessage());
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getTrips throwable: " + throwable.getMessage());
                    });
        }

        /**
         * lấy thông tin Track
         */
        public void queryTrack(TripBean tripBean, boolean isNeedMoveMap) {
            // TODO: 2020-01-02 server track time bug, now use work around
            Map<TripBean, Boolean> map = new HashMap<>();
            TripBean currentTripBean = tripBean;

            ApiClient.createApiService().getTrack(cameraSn, tripBean.getTripId(), currentUser.getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            List<TrackBean> tracks = response.getTrack();
                            currentTripBean.setGpsDataList(tracks);
                            map.put(currentTripBean, isNeedMoveMap);
                            trackList.onNext(map);
                            queryEventsForTrip(currentTripBean);
                        } else {
                            Logger.t(TAG).d("error = " + response.getMessage());
                            map.put(currentTripBean, isNeedMoveMap);
                            trackList.onNext(map);
                            responseErr.onNext(response);
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getTrack throwable: " + throwable.getMessage());
                        map.put(currentTripBean, isNeedMoveMap);
                        trackList.onNext(map);
                    });
        }

        /**
         * lấy thông tin Event
         */
        @Override
        public void queryEvents() {
            String pattern = "yyyy-MM-dd";
            String dateNow = new SimpleDateFormat(pattern).format(new Date());
            String dateStart = new SimpleDateFormat(pattern).format(new Date(new Date().getTime() - (14 * 24 * 60 * 60 * 1000)));

            ApiClient.createApiService().getEvents(cameraSn, dateNow, dateStart, currentUser.getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            List<CameraEventBean> events = response.getEvents();
                            eventList.onNext(events);
                        } else {
                            Logger.t(TAG).e("getEventsList throwable: " + response.getMessage());
                            responseErr.onNext(response);
                            eventList.onNext(new ArrayList<>());
                        }

                    }, throwable -> {
                        Logger.t(TAG).e("getEventsList throwable: " + throwable.getMessage());
                        networkError.onNext(throwable);
                        eventList.onNext(new ArrayList<>());
                    });
        }

        private void queryEventsForTrip(TripBean tripBean) {

            ApiClient.createApiService().getAllEventsForOneTrip(tripBean.getTripId(), currentUser.getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            List<CameraEventBean> events = response.getEvents();
                            eventList.onNext(events);
                        } else {
                            Logger.t(TAG).e("getEventsList throwable: " + response.getMessage());
                            responseErr.onNext(response);
                            eventList.onNext(new ArrayList<>());
                        }

                    }, throwable -> {
                        Logger.t(TAG).e("getEventsList throwable: " + throwable.getMessage());
                        networkError.onNext(throwable);
                        eventList.onNext(new ArrayList<>());
                    });
        }


        /**
         * lấy video url theo eventId
         */
        @Override
        public void queryVideoUrl(CameraEventBean bean) {
            ApiClient.createApiService().getVideoUrl(bean.getId(), HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .subscribe(new Consumer<VideoUrlBean>() {
                        @Override
                        public void accept(VideoUrlBean videoUrlBean) throws Exception {
                            if (videoUrlBean.isSuccess()) {
                                videoUrlDetail.onNext(Optional.ofNullable(videoUrlBean));
                            } else {
                                responseErr.onNext(videoUrlBean);
                            }
                        }
                    }, throwable -> {
                        eventDetail.onNext(Optional.empty());
                    });
        }

        /**
         * lấy thông tin số thông báo chưa đọc
         */
        @Override
        public void queryUnread(String from, String to) {
            ApiClient.createApiService().getUnreadNotification(/*from, to,*/ HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(unreadResponse -> {
                        if (unreadResponse.isSuccess()) {
                            Logger.t(TAG).d("getUnreadNotification: " + unreadResponse.toString());
                            int unread = unreadResponse.getData();
                            unreadNotification.onNext(Optional.of(unread));
                        } else {
                            responseErr.onNext(unreadResponse);
                        }

                    }, throwable -> {
                        Logger.t(TAG).d("getUnreadNotification throwable: " + throwable.getMessage());
                        unreadNotification.onNext(Optional.of(0));
                    });
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public Observable<Map<List<FleetViewRecord>, Boolean>> summaryList() {
            return summaryList;
        }

        @Override
        public Observable<Map<List<TripBean>, Boolean>> tripList() {
            return tripList;
        }

        @Override
        public Observable<Map<TripBean, Boolean>> trackList() {
            return trackList;
        }

        @Override
        public Observable<List<CameraEventBean>> eventList() {
            return eventList;
        }

        @Override
        public Observable<Optional<EventDetailBean>> eventDetail() {
            return eventDetail;
        }

        public Observable<Optional<VideoUrlBean>> videoUrlDetail() {
            return videoUrlDetail;
        }

        @Override
        public Observable<Optional<Integer>> unreadNotification() {
            return unreadNotification;
        }

        @Override
        public Observable<FleetViewBean> fleetViewBean() {
            return fleetViewBeanSub;
        }

        @Override
        public Observable<Double> totalPage() {
            return totalPages;
        }

        @Override
        public Observable<Double> currentIndex() {
            return currentIndex;
        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }

        @Override
        public Observable<Response> responseErr() {
            return responseErr;
        }

        private long[] fromToTime() {
            long[] fromToTime = new long[2];
            long currentUtcTimeMillis = System.currentTimeMillis();

            // TODO: 2019-10-08 现在为了方便测试 取两天的时间
            long zeroFromTime = fromToTime[0] = DashboardUtil.getZeroFromTime(2, currentUtcTimeMillis);
            fromToTime[1] = DashboardUtil.getEndTime(2, zeroFromTime);

            return fromToTime;
        }
    }
}
