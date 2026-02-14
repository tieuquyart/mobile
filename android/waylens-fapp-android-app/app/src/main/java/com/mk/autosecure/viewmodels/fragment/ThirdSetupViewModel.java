package com.mk.autosecure.viewmodels.fragment;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BindDeviceResponse;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest.request.BindDeviceBody;
import com.mk.autosecure.rest.request.ReportIdBody;
import com.mk.autosecure.ui.fragment.ThirdSetupFragment;
import com.orhanobut.logger.Logger;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/11/21.
 * Email: doanvt-hn@mk.com.vn
 */

public interface ThirdSetupViewModel {

    interface Inputs {

        void bindCamera(String sn, String nickname, String password);

        void reportIccid(String sn, String iccid);
    }

    interface Outputs {
        /**
         * Finish the activity with a successful result.
         */
        Observable<Integer> bindSuccess();

        Observable<SubscribeResponse> reportSuccess();
    }

    interface Errors {

        Observable<ErrorEnvelope> bindError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<ThirdSetupFragment> implements Inputs, Outputs, Errors {
        public static final String TAG = ViewModel.class.getSimpleName();

        private final Gson gson;
        private PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        private PublishSubject<Integer> bindSuccess = PublishSubject.create();

        private PublishSubject<SubscribeResponse> reportSuccess = PublishSubject.create();

        public final AppComponent component;

        public ViewModel(final @NonNull AppComponent component) {
            super(component);
            this.component = component;
            gson = component.gson();

            repearBind()
                    .takeUntil(bindSuccess)
                    .subscribe(errorEnvelope -> bindSuccess.onNext(-1), new ServerErrorHandler());
        }

        @Override
        public void bindCamera(String sn, String nickname, String password) {
            requestBindCamera(sn, nickname, password)
                    .compose(bindToLifecycle())
                    .subscribe(this::success, new ServerErrorHandler());
        }

        @Override
        public void reportIccid(String sn, String iccid) {
            ReportIdBody reportIdBody = new ReportIdBody();
            reportIdBody.reportIccid = iccid;

            ApiService.createApiService().reportID(sn, reportIdBody)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .flatMap(response -> {
                        if (response.result) {
                            return ApiService.createApiService().getCurrentSub(sn);
                        } else {
                            return Observable.empty();
                        }
                    })
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .compose(bindToLifecycle())
                    .subscribe(response -> reportSuccess.onNext(response));
        }

        @Override
        public Observable<ErrorEnvelope> bindError() {
            return error
                    .doOnNext(errorEnvelope -> Logger.t(TAG).d("error = " + errorEnvelope.getErrorMessage()))
                    .takeUntil(bindSuccess)
                    .filter(errorEnvelope -> !errorEnvelope.isAlreadyBoundYour());
        }

        public Observable<ErrorEnvelope> repearBind() {
            return error
                    .takeUntil(bindSuccess)
                    .filter(ErrorEnvelope::isAlreadyBoundYour);
        }

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        @Override
        public Observable<Integer> bindSuccess() {
            return bindSuccess;
        }

        @Override
        public Observable<SubscribeResponse> reportSuccess() {
            return reportSuccess;
        }

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        /**
         *
         * */
        private Observable<BindDeviceResponse> requestBindCamera(final @NonNull String sn, String nickname, String password) {
            BindDeviceBody bindDeviceBody = new BindDeviceBody();
            bindDeviceBody.sn = sn;
            bindDeviceBody.name = nickname;
            bindDeviceBody.password = password;

            return ApiService.createApiService().bindDeviceRes(bindDeviceBody)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }


        private void success(BindDeviceResponse res) {
            if (res.result) {
                Logger.t(TAG).d("result = " + res.result);
                bindSuccess.onNext(0);
            }
        }
    }
}
