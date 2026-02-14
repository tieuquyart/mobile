package com.mk.autosecure.viewmodels;

import android.annotation.SuppressLint;
import android.content.Context;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.account.CameraSubscriber;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.SortUtil;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.libs.account.CurrentUser;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/8/23.
 */

public interface SettingViewModel {

    interface Inputs {
        void refreshCamera();

        void refreshFleetCamera();
    }

    interface Outputs {
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends ActivityViewModel<VideosActivity> implements Inputs, Outputs, Errors {

        private final static String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            mContext = appComponent.appContext();
            currentUser = appComponent.currentUser();
            component = appComponent;
            gson = component.gson();
        }

        private final Context mContext;
        private final CurrentUser currentUser;
        private final AppComponent component;
        private final Gson gson;

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        public void refresh(int type) {

        }

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        /***
         *
         * lấy thông tin camera
         */
        @Override
        public void refreshCamera() {
            ApiService.createApiService().getCameras()
                    .compose(Transformers.switchSchedulers())
                    .subscribe(new CameraSubscriber());
        }

        /***
         *
         * lấy thông tin camera
         */
        @SuppressLint("CheckResult")
        @Override
        public void refreshFleetCamera() {
            fleetCameraBeanList.clear();
            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .subscribe(response -> {
                        List<FleetCameraBean> cameras = response.getData();
                        fleetCameraBeanList.addAll(cameras);
                        currentUser.refreshFleetDevices(SortUtil.sortFleet(fleetCameraBeanList), false);
                    });
        }
    }
}