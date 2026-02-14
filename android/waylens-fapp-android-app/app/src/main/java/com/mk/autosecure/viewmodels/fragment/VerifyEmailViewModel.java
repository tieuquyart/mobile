package com.mk.autosecure.viewmodels.fragment;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.ui.fragment.VerifyEmailFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.ObjectUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.UserProfileResponse;

import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/11/14.
 * Email: doanvt-hn@mk.com.vn
 */

public interface VerifyEmailViewModel {

    interface Inputs {
        void resendEmailClick();

        void backClick();

        void setEmail(String email);

        void startPolling();
    }

    interface Outputs {
        Observable<Optional<String>> resendSuccess();

        Observable<Optional<Void>> stepBack();

        Observable<Optional<Boolean>> verifySuccess();

        Observable<String> email();
    }

    interface Errors {
        Observable<ErrorEnvelope> resendError();

        Observable<ErrorEnvelope> otherError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<VerifyEmailFragment> implements Inputs,
            Outputs, Errors {

        private final String TAG = ViewModel.class.getSimpleName();

        // INPUTS
        private final PublishSubject<Optional<Void>> resendEmailClick = PublishSubject.create();
        private boolean isPollingStart = false;

        // OUTPUTS
        private final PublishSubject<Optional<String>> resendSuccess = PublishSubject.create();

        public Observable<Optional<String>> resendSuccess() {
            return resendSuccess.hide();
        }

        private final PublishSubject<Optional<Boolean>> verifySuccess = PublishSubject.create();

        public Observable<Optional<Boolean>> verifySuccess() {
            return verifySuccess;
        }

        private final PublishSubject<String> email = PublishSubject.create();

        // ERRORS
        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        public Observable<ErrorEnvelope> resendError() {
            return error
                    .doOnNext(errorEnvelope ->
                            Logger.t(TAG).d("error = ", ToStringUtils.getString(errorEnvelope)))
                    .filter(ErrorEnvelope::isResendEmailAlreadyVerified);
        }

        public Observable<ErrorEnvelope> otherError() {
            return error
                    .filter(ErrorEnvelope::isNotResendEmailAlreadyVerified);
        }

        private final PublishSubject<Optional<Void>> backClick = PublishSubject.create();

        @Override
        public void backClick() {
            backClick.onNext(Optional.empty());
        }

        @Override
        public void setEmail(String em) {
            email.onNext(em);
        }

        @Override
        public Observable<String> email() {
            return email;
        }

        @Override
        public Observable<Optional<Void>> stepBack() {
            return backClick;
        }

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;
        private final Gson gson;
        public final AppComponent component;

        @Override
        public void resendEmailClick() {
            resendEmailClick.onNext(Optional.empty());
        }

        public ViewModel(final @NonNull AppComponent appComponent) {
            super(appComponent);
            gson = appComponent.gson();
            component = appComponent;

            component.currentUser().observable()
                    .filter(ObjectUtils::isNotNull)
                    .compose(Transformers.takeWhen(resendEmailClick))
                    .switchMap(this::sendVerifyEmail)
                    .compose(bindToLifecycle())
                    .subscribe(this::resendEmailSuccess);

            Observable.interval(0, 5000, TimeUnit.MILLISECONDS)
                    .filter(__ -> isPollingStart)
                    .takeUntil(verifySuccess)
                    .compose(bindToLifecycle())
                    .compose(Transformers.combineLatestPair(component.currentUser().observable()))
                    .filter(pair -> pair.second.getIncludeNull() != null && !pair.second.get().verified())
                    .switchMap(__ -> fetchProfile())
                    .subscribe(this::onUserProfileResponse, new ServerErrorHandler());

        }

        @Override
        public void startPolling() {
            isPollingStart = true;
        }

        private Observable<UserProfileResponse> fetchProfile() {
            return ApiService.createApiService().fetchMyProfile()
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }

        private Observable<BooleanResponse> sendVerifyEmail(final @NonNull Optional<User> userOptional) {
            return ApiService.createApiService().resendVerifyEmail()
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }

        private void onUserProfileResponse(UserProfileResponse res) {
            Logger.t(TAG).d("profile = " + ToStringUtils.toString(res));
            if (res != null && res.isVerified) {
                Logger.t(TAG).d("isVerified = " + res.isVerified);
                isPollingStart = false;
                verifySuccess.onNext(Optional.empty());
                component.currentUser().refreshProfile(res);
            }
        }

        private void resendEmailSuccess(BooleanResponse res) {
            if (res.result) {
                resendSuccess.onNext(Optional.empty());
            }
        }
    }
}


