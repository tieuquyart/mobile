package com.mk.autosecure.viewmodels;

import android.annotation.SuppressLint;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mkgroup.camera.model.fms.SendDataFWEvent;
import com.mkgroup.camera.model.fms.SendDataFWResponse;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.fragment.FaceIdFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.data.dms.DataApi;
import com.mkgroup.camera.data.dms.DmsRequestQueue;
import com.mkgroup.camera.model.dms.FaceList;
import com.mkgroup.camera.model.dms.Result;
import com.mkgroup.camera.utils.RxBus;

import java.util.HashMap;
import java.util.Map;
import java.util.Observer;
import java.util.Random;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT.
 */

@SuppressLint("CheckResult")
public interface FaceIdFragmentViewModel {

    String TAG = FaceIdFragmentViewModel.class.getSimpleName();

    interface Inputs {

        void getAllFaces();

        Observable<Result> addFaceWithId(String name);

        Observable<Result> removeFaceWithId(String faceId);

        Observable<Result> removeAllFaces();

        void saveFaceData(EvCamera evCamera, String cameraSn, String numberId);

        void removeFaceData(EvCamera evCamera, String cameraSn, String faceId);

        void showButtonAddFace(int i);
    }

    interface Outputs {

        Observable<FaceList> allFaces();

        String getFaceId();

        Observable<SendDataFWResponse> saveFaceRes();

        Observable<SendDataFWResponse> removeFaceRes();

        Observable<Integer> showBtnAddFace();
    }

    final class ViewModel extends FragmentViewModel<FaceIdFragment> implements Inputs, Outputs {

        public DmsRequestQueue mDmsRequestQueue;
        private Random mRandom;
        Gson gson = new GsonBuilder().create();
        private static final String urlAdd = "http://103.107.183.97:8600/fms/api/update/faceid";
        private static final String urlRemove = "http://103.107.183.97:8600/fms/api/delete/faceid";

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            mRandom = new Random();

        }

        private final BehaviorSubject<FaceList> allFaces = BehaviorSubject.create();
        private final BehaviorSubject<SendDataFWResponse> saveFaceRes = BehaviorSubject.create();
        private final BehaviorSubject<SendDataFWResponse> removeFaceRes = BehaviorSubject.create();
        private final BehaviorSubject<Integer> isVisible = BehaviorSubject.create();
        private String faceId = "";

        /**
         * get List khuôn mặt trên camera
         */
        @Override
        public void getAllFaces() {
            if (mDmsRequestQueue == null) {
                return;
            }

            Observable.create((ObservableOnSubscribe<Void>) emitter -> {
                        try {
                            allFaces.onNext(DataApi.getAllFaces(mDmsRequestQueue));
                        } catch (Exception e) {
                            Logger.t(TAG).e("getAllFaces exception = " + e.getMessage());
                        }
                    })
                    .subscribeOn(Schedulers.io())
                    .subscribe();
        }


        /**
         * thêm khuôn mặt với id
         */
        @Override
        public Observable<Result> addFaceWithId(String name) {
            if (mDmsRequestQueue == null) {
                return Observable.error(new Throwable("DmsRequestQueue is null !!!"));
            }
            Logger.t(TAG).d("faceID:= %s - driverName: %s", faceId, name);
            return DataApi.addFaceWithIdRx(mDmsRequestQueue, faceId, name);
        }

        @Override
        public String getFaceId() {
            return faceId;
        }

        /**
         * handler kết quá lưu dữ liệu face
         */
        @Override
        public Observable<SendDataFWResponse> saveFaceRes() {
            return saveFaceRes;
        }

        /**
         * handler kết quá xóa dữ liệu face
         */
        @Override
        public Observable<SendDataFWResponse> removeFaceRes() {
            return removeFaceRes;
        }

        @Override
        public Observable<Integer> showBtnAddFace() {
            return isVisible;
        }

        /**
         * xóa khuôn mặt theo id
         */
        @Override
        public Observable<Result> removeFaceWithId(String faceId) {
            if (mDmsRequestQueue == null) {
                return Observable.error(new Throwable("DmsRequestQueue is null !!!"));
            }
            return DataApi.removeFaceWithIdRx(mDmsRequestQueue, faceId, 0);
        }

        /**
         * xóa tất cả khuôn mặt
         */
        @Override
        public Observable<Result> removeAllFaces() {
            if (mDmsRequestQueue == null) {
                return Observable.error(new Throwable("DmsRequestQueue is null !!!"));
            }
            return DataApi.removeFaceWithIdRx(mDmsRequestQueue, "", 1);
        }

        /**
         * lưu thông tin khuôn mặt lên FMS qua camera
         */
        @Override
        public void saveFaceData(EvCamera evCamera, String cameraSn, String numberId) {

            long value = (long) (mRandom.nextDouble() * Math.pow(10, 16));
            faceId = String.valueOf(value);
            Map<String, String> params = new HashMap<>();
            params.put("faceId", faceId);
            params.put("cameraSn", cameraSn);
            params.put("numberId", numberId);

            evCamera.sendDataFW(gson.toJson(params), urlAdd);
        }

        /**
         * xóa thông tin khuôn mặt FMS qua camera
         */
        @Override
        public void removeFaceData(EvCamera evCamera, String cameraSn, String faceId) {
            Map<String, String> params = new HashMap<>();
//            params.put("faceId",faceId);
            params.put("cameraSn", cameraSn);

            evCamera.
                    sendDataFW(gson.toJson(params), urlRemove);
        }

        @Override
        public void showButtonAddFace(int i) {
            isVisible.onNext(i);
        }

        @Override
        public Observable<FaceList> allFaces() {
            return allFaces;
        }

    }
}
