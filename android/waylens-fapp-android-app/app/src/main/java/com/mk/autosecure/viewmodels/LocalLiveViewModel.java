package com.mk.autosecure.viewmodels;

import android.annotation.SuppressLint;
import android.content.Context;

import com.mkgroup.camera.bean.CameraBean;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.SortUtil;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.request.TokenBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.libs.account.CurrentUser;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/8/29.
 * Email: doanvt-hn@mk.com.vn
 */

public interface LocalLiveViewModel {
    interface Inputs {
        void refreshToken();

        void refreshCamera(boolean isForced);

        void getUnreadMsg(READ_MSG_MODE mode);

        void showCamera(String sn);

        void showPreview(int index);
    }

    interface Outputs {
        Observable<Integer> unreadMsgNum();

        Observable<Integer> showCameraIndex();

        Observable<Integer> showPreviewIndex();
    }

    enum READ_MSG_MODE {
        None, Single, All, New
    }

    final class ViewModel extends ActivityViewModel<LocalLiveActivity> implements Inputs, Outputs {

        private final static String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            context = appComponent.appContext();
        }

        private final CurrentUser currentUser;
        private final Context context;

        public final Inputs inputs = this;
        public final Outputs outputs = this;

        private final BehaviorSubject<Integer> unreadMsgNum = BehaviorSubject.create();

        private final BehaviorSubject<Integer> showCameraIndex = BehaviorSubject.create();

        private final BehaviorSubject<Integer> showPreviewIndex = BehaviorSubject.create();

        private int cacheUnread = 0;

        private final int count = 20;

        private long mLastRequestStatusTime = 0;

        private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public void refreshToken() {
            //ConnectionResult
//            int googlePlayServicesAvailable = GoogleApiAvailability.getInstance()
//                    .isGooglePlayServicesAvailable(context);
//            Logger.t(TAG).d("googleService supported: " + (googlePlayServicesAvailable == ConnectionResult.SUCCESS));
//
//            String token = FirebaseInstanceId.getInstance().getToken();
////            Logger.t(TAG).d("FirebaseInstanceId token: " + token);
//            String localToken = PreferenceUtils.getString(PreferenceUtils.SEND_FCM_TOKEN_SERVER, "");
////            Logger.t(TAG).d("Local token: " + localToken);
//
//            if (!TextUtils.isEmpty(localToken)
//                    && !TextUtils.isEmpty(token)
//                    && localToken.equals(token)) {
//
//                uploadToken(token);
//            } else if (!TextUtils.isEmpty(token)) {
//                PreferenceUtils.putString(PreferenceUtils.SEND_FCM_TOKEN_SERVER, token);
//                uploadToken(token);
//            } else {
//
//                Observable.create((ObservableOnSubscribe<Void>) emitter -> {
//                    FirebaseInstanceId.getInstance().deleteInstanceId();
//                    FirebaseInstanceId.getInstance().getInstanceId();
//                })
//                        .subscribeOn(Schedulers.io())
//                        .compose(bindToLifecycle())
//                        .subscribe(Functions.emptyConsumer(), new ServerErrorHandler(TAG));
//            }
        }

        private void uploadToken(String token) {
            if (Constants.isFleet()) {
//                RefreshTokenBody body = new RefreshTokenBody(token);
//
//                ApiClient.createApiService().refreshDeviceToken(body)
//                        .subscribeOn(Schedulers.io())
//                        .subscribe(response -> Logger.t(TAG).d("refreshDeviceToken: " + response.result),
//                                new ServerErrorHandler(TAG));
            } else {
                TokenBody tokenBody = new TokenBody();
                tokenBody.newDeviceToken = token;

                ApiService.createApiService().refreshToken(tokenBody)
                        .subscribeOn(Schedulers.io())
                        .subscribe(booleanResponse -> Logger.t(TAG).d("refreshToken: " + booleanResponse.result),
                                new ServerErrorHandler(TAG));
            }
        }


        @SuppressLint("CheckResult")
        @Override
        public void refreshCamera(boolean isForced) {
            if (Constants.isFleet()) {
                    if (System.currentTimeMillis() - mLastRequestStatusTime > 10000) {
                        mLastRequestStatusTime = System.currentTimeMillis();

                        getCameras(isForced);
                    } else {
                        // do nothing
                    }
            } else {
                ApiService.createApiService().getCameras()
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            Logger.t(TAG).d("getCameras: " + response.cameras);
                            currentUser.refreshDevices(SortUtil.sort(response.cameras), isForced);
                        }, throwable -> {
                            Logger.t(TAG).d("getCameras throwable: " + throwable.getMessage());
                            currentUser.refreshDevices(SortUtil.sort(currentUser.getDevices()), isForced);
                        });
            }
        }

        /**
         * lấy thông tin camera
         * */
        @SuppressLint("CheckResult")
        private void getCameras(boolean isForced) {
            fleetCameraBeanList.clear();

            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        List<FleetCameraBean> cameras = response.getData();
                        this.fleetCameraBeanList.addAll(cameras);

                        Logger.t(TAG).d("getCameras: " + fleetCameraBeanList);
                        if (fleetCameraBeanList != null && fleetCameraBeanList.size() != 0) {
                            currentUser.refreshFleetDevices(fleetCameraBeanList, isForced);
                        }
                    }, throwable -> {
                        Logger.t(TAG).d("getCameras throwable: " + throwable.getMessage());
                        currentUser.refreshFleetDevices(SortUtil.sortFleet(currentUser.getFleetDevices()), isForced);
                    });
        }

        /**
         * deprecated
         * */
        @SuppressLint("CheckResult")
        @Override
        public void getUnreadMsg(READ_MSG_MODE mode) {
            if (Constants.isFleet()) {
            } else {
                ApiService.createApiService().getAlertList(0L, 10)
                        .subscribeOn(Schedulers.io())
                        .doOnError(throwable -> {
                            Logger.t(TAG).e("getAlertList throwable: " + cacheUnread + "--" + throwable.getMessage());
                            switch (mode) {
                                case None:
                                    break;
                                case Single:
                                    cacheUnread = cacheUnread - 1;
                                    break;
                                case All:
                                    cacheUnread = 0;
                                    break;
                                case New:
                                    cacheUnread = cacheUnread + 1;
                                    break;
                            }
                        })
                        .doFinally(() -> unreadMsgNum.onNext(cacheUnread))
                        .subscribe(alertListResponse -> {
                            Logger.t(TAG).d("getAlertList: " + alertListResponse.unreadCount);
                            cacheUnread = alertListResponse.unreadCount;
                        });
            }
        }

        /**
         * hiển thị thông tin camera
         * */
        @Override
        public void showCamera(String serialNumber) {
            ArrayList<CameraBean> devices = currentUser.getDevices();
            int index = -1;
            for (int i = 0; i < devices.size(); i++) {
                CameraBean cameraBean = devices.get(i);
                if (serialNumber.equals(cameraBean.sn)) {
                    index = i;
                    break;
                }
            }
            Logger.t(TAG).e("showCamera index: " + index);
            if (index != -1) {
                showCameraIndex.onNext(index);
            }
        }

        @Override
        public void showPreview(int index) {
            Logger.t(TAG).d("showPreview index: " + index);
            if (index != -1) {
                showPreviewIndex.onNext(index);
            }
        }

        @Override
        public Observable<Integer> unreadMsgNum() {
            return unreadMsgNum;
        }

        @Override
        public Observable<Integer> showCameraIndex() {
            return showCameraIndex;
        }

        @Override
        public Observable<Integer> showPreviewIndex() {
            return showPreviewIndex;
        }
    }
}
