package com.mk.autosecure.viewmodels;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.ActivityLifecycleType;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.request.PhoneNoBody;
import com.mk.autosecure.rest_fleet.response.NotificationInfoResponse;
import com.mk.autosecure.rest_fleet.response.NotificationResponse;
import com.mk.autosecure.rest_fleet.response.Response;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;


@SuppressLint({"CheckResult", "NewApi"})
public interface NotificationViewModel {
    interface Inputs {
        void queryNotiList();

        void queryNotiPage(String category);

        void getMoreNotiPage(String category, int index);

        void queryNotiListWithDelay(long delay);

        void queryNotiInfo(String notificationId);

        void markRead(String notiId);

        void queryUnread(String from, String to);

        void loading(boolean loading);

        void updatePhoneNo(String phoneNo, String cameraSn, String notificationId);
    }

    interface Outputs {
        Observable<NotificationBean> notificationInfo();

        Observable<ArrayList<NotificationBean>> listNotification();

        Observable<Boolean> markRead();

        Observable<Optional<Integer>> countUnread();
        Observable<Optional<Integer>> currentIndex();
        Observable<Optional<Integer>> totalPage();

        Observable<Integer> showLoading();

        Observable<Boolean> phoneNoUpdated();

        Observable<Response> error();
    }

    final class ViewModel extends ActivityViewModel<ActivityLifecycleType> implements Inputs, Outputs {

        private static final String TAG = NotificationViewModel.ViewModel.class.getSimpleName();

        private final PublishSubject<NotificationBean> notificationInfo = PublishSubject.create();
        private final PublishSubject<ArrayList<NotificationBean>> listNotification = PublishSubject.create();
        private final PublishSubject<Boolean> markRead = PublishSubject.create();
        private final PublishSubject<Boolean> phoneNoUpdated = PublishSubject.create();
        private final PublishSubject<Optional<Integer>> unreadTotal = PublishSubject.create();
        private final PublishSubject<Optional<Integer>> currentIndex = PublishSubject.create();
        private final PublishSubject<Optional<Integer>> totalPage = PublishSubject.create();
        private final BehaviorSubject<Integer> showLoading = BehaviorSubject.create();
        private final BehaviorSubject<Response> error = BehaviorSubject.create();

        public final NotificationViewModel.Inputs inputs = this;
        public final NotificationViewModel.Outputs outputs = this;

        private Context mContext;

        public ViewModel(AppComponent component) {
            super(component);
            mContext = component.appContext();
        }


        /**
         * lấy danh sách thông báo
         */
        @Override
        public void queryNotiList() {
            loading(true);
            ApiClient.createApiService().getNotificationList(HornApplication.getComponent().currentUser().getAccessToken())
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            listNotification.onNext(response.getData());
                            loading(false);
                        } else {
                            error.onNext(response);
                            loading(false);
                            listNotification.onNext(new ArrayList<>());
                        }
                    }, new ServerErrorHandler(TAG));
        }

        @Override
        public void queryNotiPage(String category) {
            loading(true);

            if (TextUtils.isEmpty(category)) {
                ApiClient.createApiService().getNotificationPage(0, 10, HornApplication.getComponent().currentUser().getAccessToken())
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            if (response.isSuccess()) {
                                ArrayList<NotificationBean> notiList = response.getData().getContent();
                                listNotification.onNext(notiList);
                                totalPage.onNext(Optional.of(response.getData().getTotalPages()));
                                currentIndex.onNext(Optional.of(response.getData().getNumber()));
                                loading(false);
                            } else {
                                error.onNext(response);
                                totalPage.onNext(Optional.of(0));
                                currentIndex.onNext(Optional.of(0));
                                loading(false);
                                listNotification.onNext(new ArrayList<>());
                            }
                        }, new ServerErrorHandler(TAG));
            } else {
                ApiClient.createApiService().getNotificationPageWithCategory(category, 0, 10, HornApplication.getComponent().currentUser().getAccessToken())
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            if (response.isSuccess()) {
                                listNotification.onNext(response.getData().getContent());
                                totalPage.onNext(Optional.of(response.getData().getTotalPages()));
                                currentIndex.onNext(Optional.of(response.getData().getNumber()));
                                loading(false);
                            } else {
                                error.onNext(response);
                                totalPage.onNext(Optional.of(0));
                                currentIndex.onNext(Optional.of(0));
                                loading(false);
                                listNotification.onNext(new ArrayList<>());
                            }
                        }, new ServerErrorHandler(TAG));
            }
        }

        @Override
        public void getMoreNotiPage(String category, int index) {
            loading(true);
            if (TextUtils.isEmpty(category)) {
                ApiClient.createApiService().getNotificationPage(index, 10, HornApplication.getComponent().currentUser().getAccessToken())
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            if (response.isSuccess()) {
                                listNotification.onNext(response.getData().getContent());
                                totalPage.onNext(Optional.of(response.getData().getTotalPages()));
                                currentIndex.onNext(Optional.of(response.getData().getNumber()));
                                loading(false);
                            } else {
                                error.onNext(response);
                                totalPage.onNext(Optional.of(0));
                                currentIndex.onNext(Optional.of(index));
                                loading(false);
                                listNotification.onNext(new ArrayList<>());
                            }
                        }, new ServerErrorHandler(TAG));
            } else {
                ApiClient.createApiService().getNotificationPageWithCategory(category, index, 10, HornApplication.getComponent().currentUser().getAccessToken())
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            if (response.isSuccess()) {
                                listNotification.onNext(response.getData().getContent());
                                totalPage.onNext(Optional.of(response.getData().getTotalPages()));
                                currentIndex.onNext(Optional.of(response.getData().getNumber()));
                                loading(false);
                            } else {
                                error.onNext(response);
                                totalPage.onNext(Optional.of(0));
                                currentIndex.onNext(Optional.of(index));
                                loading(false);
                                listNotification.onNext(new ArrayList<>());
                            }
                        }, new ServerErrorHandler(TAG));
            }
        }

        /**
         * lấy danh sách thông báo delay
         */
        @Override
        public void queryNotiListWithDelay(long delay) {
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    loading(true);
                    ApiClient.createApiService().getNotificationList(HornApplication.getComponent().currentUser().getAccessToken())
                            .subscribeOn(Schedulers.io())
                            .compose(bindToLifecycle())
                            .subscribe(response -> {
                                if (response.isSuccess()) {
                                    listNotification.onNext(response.getData());
                                    loading(false);
                                } else {
                                    error.onNext(response);
                                    loading(false);
                                    listNotification.onNext(new ArrayList<>());
                                }
                            }, new ServerErrorHandler(TAG));
                }
            }, delay);
        }

        /**
         * gọi func lấy thông tin thông báo chưa đọc
         */
        private void queryUnread() {
            long toTime = System.currentTimeMillis();
            long fromTime = DashboardUtil.getZeroFromTime(3, toTime);
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            String toDate = df.format(new Date(toTime));
            String fromDate = df.format(new Date(fromTime));
            queryUnread(fromDate, toDate);
        }

        /**
         * lấy thông tin chi tiết của thông báo
         */
        @Override
        public void queryNotiInfo(String notificationId) {
            loading(true);
            Logger.t(TAG).d("response noti Id: " + notificationId);
            ApiClient.createApiService().getInfoNotification(notificationId, HornApplication.getComponent().currentUser().getAccessToken())
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(this::handleNotiInfo, new ServerErrorHandler(TAG));
        }

        private void handleNotiInfo(NotificationInfoResponse response) {
            loading(false);
            Logger.t(TAG).d("response noti: " + response.getData());
            if (response.isSuccess()) {
                notificationInfo.onNext(response.getData());
            } else {
                error.onNext(response);
                notificationInfo.onNext(null);
            }
        }

        /**
         * đánh dấu thông báo đã đọc
         */
        @Override
        public void markRead(String notiId) {
            ApiClient.createApiService().markReadNotification(notiId, HornApplication.getComponent().currentUser().getAccessToken())
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            markRead.onNext(response.isSuccess());
                        } else {
                            error.onNext(response);
                            markRead.onNext(false);
                        }
                        Logger.t(TAG).d("markReadNotification result: " + response.isSuccess());
                    }, throwable -> {
                        Logger.t(TAG).d("markReadNotification throwable: " + throwable.getMessage());
                        markRead.onNext(false);
                    });
        }

        /**
         * lấy số count thông báo chưa đọc
         */
        @Override
        public void queryUnread(String from, String to) {
//            loading(true);
            ApiClient.createApiService().getUnreadNotification(/*from, to, */HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(unreadResponse -> {
                        Logger.t(TAG).d("getUnreadNotification: " + unreadResponse.toString());
                        if (unreadResponse.isSuccess()) {
                            int unread = unreadResponse.getData();
                            unreadTotal.onNext(Optional.of(unread));
                        } else {
                            error.onNext(unreadResponse);
                            unreadTotal.onNext(Optional.of(0));
                        }

                        loading(false);
                    }, throwable -> {
                        Logger.t(TAG).d("getUnreadNotification throwable: " + throwable.getMessage());
                        loading(false);
                        unreadTotal.onNext(Optional.of(0));
                    });
        }

        @Override
        public void loading(boolean loading) {
            showLoading.onNext(loading ? View.VISIBLE : View.GONE);
        }

        @Override
        public void updatePhoneNo(String phoneNo, String cameraSn, String notificationId) {
            loading(true);
            PhoneNoBody body = new PhoneNoBody(cameraSn, phoneNo, notificationId);
            ApiClient.createApiService().updatePhoneNo(body, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(res -> {
                        loading(false);
                        if (res.isSuccess()) {
                            phoneNoUpdated.onNext(res.isSuccess());
                        } else {
                            phoneNoUpdated.onNext(false);
                            error.onNext(res);
                        }
                    }, throwable -> {
                        loading(false);
                        phoneNoUpdated.onNext(false);
                        new ServerErrorHandler(TAG);
                    });
        }

        @Override
        public Observable<NotificationBean> notificationInfo() {
            return notificationInfo;
        }

        @Override
        public Observable<ArrayList<NotificationBean>> listNotification() {
            return listNotification;
        }

        @Override
        public Observable<Boolean> markRead() {
            return markRead;
        }

        @Override
        public Observable<Optional<Integer>> countUnread() {
            return unreadTotal;
        }

        @Override
        public Observable<Optional<Integer>> currentIndex() {
            return currentIndex;
        }

        @Override
        public Observable<Optional<Integer>> totalPage() {
            return totalPage;
        }

        @Override
        public Observable<Integer> showLoading() {
            return showLoading;
        }

        @Override
        public Observable<Boolean> phoneNoUpdated() {
            return phoneNoUpdated;
        }

        @Override
        public Observable<Response> error() {
            return error;
        }
    }
}
