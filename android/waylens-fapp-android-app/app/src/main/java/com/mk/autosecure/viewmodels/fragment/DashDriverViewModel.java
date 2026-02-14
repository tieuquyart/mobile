package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.DriverStatusReportResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.fragment.DashDriverFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;

import java.util.TimeZone;

import io.reactivex.Observable;
import io.reactivex.functions.Consumer;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

public interface DashDriverViewModel {

    interface Inputs {
        void inputQueryTime(int driverID, String fromTime, String toTime);

        void queryStatusReportWithDriverId();
    }

    interface Outputs {
        Observable<Optional<DriverStatusReportResponse>> statusReportWithDriverId();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();

        Observable<Response> responseErr();
    }

    final class ViewModel extends FragmentViewModel<DashDriverFragment> implements DashDriverViewModel.Inputs, DashDriverViewModel.Outputs, DashDriverViewModel.Errors {

        private static final String TAG = DashDriverViewModel.ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;

        private final TimeZone timeZone;

        private int driverID;

        private String fromTime;

        private String toTime;

        private final BehaviorSubject<Optional<DriverStatusReportResponse>> statusReportDriverId = BehaviorSubject.create();

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private final PublishSubject<Response> responseErr = PublishSubject.create();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            timeZone = TimeZone.getDefault();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public void inputQueryTime(int driverID, String fromTime, String toTime) {
            this.driverID = driverID;
            this.fromTime = fromTime;
            this.toTime = toTime;
        }

        /**
         * lấy thông tin báo cáo theo driverId
         * */
        @SuppressLint("CheckResult")
        @Override
        public void queryStatusReportWithDriverId() {
            ApiClient.createApiService().getStatusReportWithDriverId(driverID,fromTime, toTime, 10, 1, currentUser.getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<DriverStatusReportResponse>() {
                        @Override
                        public void accept(DriverStatusReportResponse response) throws Exception {
                            if (response.isSuccess()){
                                statusReportDriverId.onNext(Optional.ofNullable(response));
                            }else{
                                responseErr.onNext(response);
                                statusReportDriverId.onNext(Optional.empty());
                            }
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getStatusReport throwable: " + throwable.getMessage());
                        statusReportDriverId.onNext(Optional.empty());
                    });
        }

        @Override
        public Observable<Optional<DriverStatusReportResponse>> statusReportWithDriverId() {
            return statusReportDriverId;
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
    }
}
