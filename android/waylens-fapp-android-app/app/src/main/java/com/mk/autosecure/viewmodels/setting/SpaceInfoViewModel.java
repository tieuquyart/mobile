package com.mk.autosecure.viewmodels.setting;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.settings.SpaceInfoActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.model.SpaceInfo;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;

import java.util.concurrent.ExecutionException;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/10/27.
 * Email: doanvt-hn@mk.com.vn
 */

public interface SpaceInfoViewModel {
    interface Inputs {
        void loadSpaceInfo();
    }

    interface Outputs {
        Observable<SpaceInfo> spaceInfoData();

        Observable<Integer> recordState();

        Observable<Throwable> spaceInfoError();
    }

    final class ViewModel extends ActivityViewModel<SpaceInfoActivity> implements Inputs, Outputs {
        private static final String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            RxBus.getDefault().toObservable(CameraStateChangeEvent.class)
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(this::onHandleCameraStateChangeEvent, new ServerErrorHandler());

            int recordState = VdtCamera.STATE_RECORD_UNKNOWN;
            CameraWrapper cameraWrapper = VdtCameraManager.getManager().currentCamera().getValue().getIncludeNull();
            if (cameraWrapper != null) {
                recordState = cameraWrapper.getRecordState();
            }
            recordStateSubject.onNext(recordState);
        }

        private final PublishSubject<SpaceInfo> spaceInfoData = PublishSubject.create();
        private final BehaviorSubject<Integer> recordStateSubject = BehaviorSubject.create();
        private final PublishSubject<Throwable> spaceInfoError = PublishSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;

        @Override
        public Observable<SpaceInfo> spaceInfoData() {
            return spaceInfoData;
        }

        @Override
        public Observable<Integer> recordState() {
            return recordStateSubject;
        }

        @Override
        public Observable<Throwable> spaceInfoError() {
            return spaceInfoError;
        }

        /**
         * lấy thông tin bộ nhớ
         * */
        @Override
        public void loadSpaceInfo() {
            Observable.create((ObservableOnSubscribe<SpaceInfo>) emitter -> {
                try {
                    SpaceInfo spaceInfo = SnipeApi.getSpaceInfo();
                    emitter.onNext(spaceInfo);
                } catch (InterruptedException | ExecutionException e) {
                    e.printStackTrace();
                    emitter.onError(e);
                }
            })
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeErrorsTo(spaceInfoError))
                    .compose(Transformers.neverError())
                    .subscribe(spaceInfoData::onNext, new ServerErrorHandler());

        }


        private void onHandleCameraStateChangeEvent(CameraStateChangeEvent event) {
            Logger.t(TAG).d("%s", "cameraStateChangeEvent = " + ToStringUtils.getString(event));
            switch (event.getWhat()) {
                case CameraStateChangeEvent.CAMERA_STATE_REC:
                    int recordState = VdtCamera.STATE_RECORD_UNKNOWN;
                    CameraWrapper cameraWrapper = VdtCameraManager.getManager().currentCamera().getValue().getIncludeNull();
                    if (cameraWrapper != null) {
                        recordState = cameraWrapper.getRecordState();
                    }
                    recordStateSubject.onNext(recordState);
                    break;
                case CameraStateChangeEvent.CAMERA_STATE_REC_DURATION:
                    int recordTime = (Integer) event.getExtra();
                    break;
                case CameraStateChangeEvent.CAMERA_STATE_REC_ERROR:
                    int error = (Integer) event.getExtra();
                    Logger.t(TAG).d("On Rec Error: " + error);
                    switch (error) {
                        case VdtCamera.ERROR_START_RECORD_NO_CARD:

                            break;
                        case VdtCamera.ERROR_START_RECORD_CARD_ERROR:

                            break;
                        case VdtCamera.ERROR_START_RECORD_CARD_FULL:

                            break;
                    }
                    break;
                case CameraStateChangeEvent.CAMERA_STATE_BT_DEVICE_STATUS_CHANGED:
                    break;
                case CameraStateChangeEvent.CAMERA_STATE_MICROPHONE_STATUS_CHANGED:
                    break;
                case CameraStateChangeEvent.CAMERA_STATE_REC_ROTATE:
                    break;
            }
        }
    }
}
