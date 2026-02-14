package com.mk.autosecure.viewmodels.fragment;

import android.content.Context;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.HornApiService;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.ClipListResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.FleetApiClient;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.ui.fragment.RemoteVideoFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.rest.BaseObserver;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/9/22.
 */

public interface RemoteVideoViewModel {

    interface Inputs {
        void setSerialNumber(String sn);

        void refresh();

        void filterVisibility(int visibility);

        void filterResource(int resource);

        //download

        //delete
        void deleteClip(ClipBean clipBean);

        void loadClipBean(List<String> filterList, boolean useCache);
    }

    interface Outputs {
        Observable<Integer> filterVisibility();

        Observable<Integer> filterShow();

        Observable<Map<String, Integer>> clipListStat();

        Observable<List<ClipBean>> clipBeanList();

        Observable<List<EventBean>> eventsBeanList();

        Observable<Optional<Void>> deleteSuccess();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();
    }

    final class ViewModel extends FragmentViewModel<RemoteVideoFragment> implements Inputs, Outputs, Errors {
        public static final String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            mContext = appComponent.appContext();
            gson = appComponent.gson();
        }

        private final CurrentUser currentUser;
        private final Context mContext;
        private final Gson gson;

        private HornApiService mApiService;
        private FleetApiClient mApiClient;
        private String sn;

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        private final BehaviorSubject<Integer> filterVisibility = BehaviorSubject.create();

        private final BehaviorSubject<Integer> filterShow = BehaviorSubject.create();

        private final BehaviorSubject<Map<String, Integer>> clipListStat = BehaviorSubject.create();

        private final BehaviorSubject<List<ClipBean>> clipBeanList = BehaviorSubject.create();

        private final BehaviorSubject<List<EventBean>> eventsBeanList = BehaviorSubject.create();

        private final BehaviorSubject<Optional<Void>> deleteSuccess = BehaviorSubject.create();

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private List<ClipBean> clipBeanLisCache = new ArrayList<>();

        private List<EventBean> eventBeanListCache = new ArrayList<>();

        @Override
        public Observable<Integer> filterVisibility() {
            return filterVisibility;
        }

        @Override
        public Observable<Integer> filterShow() {
            return filterShow;
        }

        @Override
        public Observable<Map<String, Integer>> clipListStat() {
            return clipListStat;
        }

        @Override
        public Observable<List<ClipBean>> clipBeanList() {
            return clipBeanList;
        }

        @Override
        public Observable<List<EventBean>> eventsBeanList() {
            return eventsBeanList;
        }

        @Override
        public Observable<Optional<Void>> deleteSuccess() {
            return deleteSuccess;
        }

        @Override
        public void setSerialNumber(String sn) {
            this.sn = sn;
        }

        @Override
        public void refresh() {
            fetchClips();
        }

        @Override
        public void filterVisibility(int visibility) {
            filterVisibility.onNext(visibility);
        }

        @Override
        public void filterResource(int resource) {
            filterShow.onNext(resource);
        }

        @Override
        public void deleteClip(ClipBean clipBean) {
            if (clipBean == null) {
                return;
            }
            ApiService.createApiService().deleteClip(clipBean.clipID)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(apiError))
                    .compose(Transformers.pipeErrorsTo(networkError))
                    .compose(Transformers.neverError())
                    .compose(bindToLifecycle())
                    .subscribe(this::deleteSuccess);
        }

        @Override
        public void loadClipBean(List<String> filterList, boolean useCache) {
            if (!currentUser.exists() || TextUtils.isEmpty(sn)) {
                Logger.t(TAG).d("currentUser exists: " + currentUser.exists() + " sn: " + sn);
                return;
            }

            if (useCache) {
                if (Constants.isFleet()) {
                    filterEventsBean(eventBeanListCache, filterList);
                } else {
                    filterClipBean(clipBeanLisCache, filterList);
                }
            } else if (Constants.isFleet()) {
                mApiClient = ApiClient.createApiService();

                long l1 = System.currentTimeMillis();
                long l2 = l1 - 7 * 24 * 60 * 60 * 1000;
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
                String to = format.format(new Date(l1));
                String from = format.format(new Date(l2));

                // TODO: 2020-03-20 目前尚无页面展示

//                mApiClient.getSummaryClip(sn, from, to)
//                        .subscribeOn(Schedulers.io())
//                        .flatMap((Function<SummaryClipResponse, ObservableSource<EventListResponse>>) response -> {
//                            Logger.t(TAG).d("getSummaryClip: " + response.toString());
//                            List<StatisticListBean> statisticList = response.getStatisticList();
//
//                            int count = 0;
//                            for (StatisticListBean bean : statisticList) {
//                                count += bean.getEvent();
//                            }
//
//                            Map<String, Integer> map = new HashMap<>();
//                            map.put("FLEET", count);
//                            clipListStat.onNext(map);
//
//                            return mApiClient.getClipList(sn, null, count);
//                        })
//                        .subscribeOn(Schedulers.io())
//                        .compose(Transformers.pipeErrorsTo(networkError))
//                        .compose(Transformers.neverError())
//                        .compose(bindToLifecycle())
//                        .doOnError(throwable -> eventsBeanList.onNext(new ArrayList<>()))
//                        .subscribe(new BaseObserver<EventListResponse>() {
//                            @Override
//                            protected void onHandleSuccess(EventListResponse data) {
//                                eventBeanListCache = data.getEvents();
//                                filterEventsBean(data.getEvents(), filterList);
//                            }
//                        });
            } else {
                mApiService = ApiService.createApiService();

                mApiService.getClipListStat(sn)
                        .subscribeOn(Schedulers.io())
                        .flatMap(response -> {
//                            Logger.t(TAG).d("getSummaryClip: " + response.toString());
                            Map<String, Integer> clipNums = response.clipNums;
                            clipListStat.onNext(clipNums);

                            int count = 0;
                            for (Integer integer : clipNums.values()) {
                                count += integer;
                            }
                            return mApiService.getClipList(sn, null, count, null);
                        })
                        .subscribeOn(Schedulers.io())
                        .compose(Transformers.pipeErrorsTo(networkError))
                        .compose(Transformers.neverError())
                        .compose(bindToLifecycle())
                        .doOnError(throwable -> clipBeanList.onNext(new ArrayList<>()))
                        .subscribe(new BaseObserver<ClipListResponse>() {
                            @Override
                            protected void onHandleSuccess(ClipListResponse data) {
//                                Logger.t(TAG).d("getClipList: " + data.toString());
                                clipBeanLisCache = data.clips;

                                filterClipBean(data.clips, filterList);
                            }
                        });
            }
        }

        private void filterClipBean(List<ClipBean> beanList, List<String> filterList) {
            if (filterList.size() == 0) {
                clipBeanList.onNext(beanList);
            } else {
                List<String> list = VideoEventType.getStringTypeFilterList(mContext, filterList);

                List<ClipBean> tempList = new ArrayList<>();

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (ClipBean bean : beanList) {
                        if (list.get(i).equals(bean.clipType)) {
                            tempList.add(bean);
                        }
                    }
                }
                clipBeanList.onNext(tempList);
            }
        }

        private void filterEventsBean(List<EventBean> beanList, List<String> filterList) {
            if (filterList.size() == 0) {
                eventsBeanList.onNext(beanList);
            } else {
                List<String> list = VideoEventType.getStringTypeFilterList(mContext, filterList);

                List<EventBean> tempList = new ArrayList<>();

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (EventBean bean : beanList) {
                        if (list.get(i).equals(bean.getEventType())) {
                            tempList.add(bean);
                        }
                    }
                }
                eventsBeanList.onNext(tempList);
            }
        }

        private void deleteSuccess(BooleanResponse response) {
            if (response.result) {
                deleteSuccess.onNext(Optional.empty());
            }
        }

        private void fetchClips() {

        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }
    }
}
