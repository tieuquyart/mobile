package com.mk.autosecure.viewmodels.fragment;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.request.ResetPwdEmailBody;
import com.mk.autosecure.ui.fragment.VerificationFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.ToStringUtils;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/11/9.
 * Email: doanvt-hn@mk.com.vn
 */

public interface VerificationViewModel {

    interface Inputs {
        void code(String __);

        void resendCodeClick();

        void setEmail(String email);

        void backClick();
    }

    interface Outputs {
        Observable<Optional<Void>> resendSuccess();

        Observable<Boolean> isFormSubmitting();

        Observable<String> isCodeValid();

        BehaviorSubject<String> emailAddress();

        String validCode();

        Observable<Optional<Void>> stepBack();
    }

    interface Errors {
        Observable<ErrorEnvelope> resetError();

        Observable<ErrorEnvelope> normalError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<VerificationFragment> implements Inputs,
            Outputs, Errors {

        private static final String TAG = ViewModel.class.getSimpleName();

        // INPUTS
        private final PublishSubject<String> code = PublishSubject.create();

        private final BehaviorSubject<String> emailAddress = BehaviorSubject.create();

        private final PublishSubject<Optional<Void>> resendCodeClick = PublishSubject.create();

        // OUTPUTS
        private final PublishSubject<Optional<Void>> resendSuccess = PublishSubject.create();

        public Observable<Optional<Void>> resendSuccess() {
            return resendSuccess.hide();
        }

        private final PublishSubject<Boolean> isFormSubmitting = PublishSubject.create();

        public Observable<Boolean> isFormSubmitting() {
            return isFormSubmitting.hide();
        }

        private final PublishSubject<String> isCodeValid = PublishSubject.create();

        @Override
        public Observable<String> isCodeValid() {
            return isCodeValid.hide();
        }

        private String validCode = "";

        @Override
        public String validCode() {
            return validCode;
        }

        @Override
        public BehaviorSubject<String> emailAddress() {
            return emailAddress;
        }

        // ERRORS
        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        public Observable<ErrorEnvelope> resetError() {
            return error
                    .doOnNext(errorEnvelope -> Logger.t(TAG).d("error = ", ToStringUtils.getString(errorEnvelope)))
                    .takeUntil(resendSuccess)
                    .filter(ErrorEnvelope::isSendResetEmailFatalError);
        }

        public Observable<ErrorEnvelope> normalError() {
            return error
                    .takeUntil(resendSuccess)
                    .filter(ErrorEnvelope::isSendResetEmailErrorAcceptable);
        }

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        private final PublishSubject<Optional<Void>> backClick = PublishSubject.create();

        @Override
        public void backClick() {
            backClick.onNext(Optional.empty());
        }

        @Override
        public Observable<Optional<Void>> stepBack() {
            return backClick;
        }

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;
        public final EmailInfo emailInfo;
        private final Gson gson;

        @Override
        public void code(String s) {
            code.onNext(s);
        }

        @Override
        public void resendCodeClick() {
            resendCodeClick.onNext(Optional.empty());
        }

        @Override
        public void setEmail(String email) {
            if (StringUtils.isEmail(email)) {
                emailAddress.onNext(email);
            }
        }

        public ViewModel(final @NonNull AppComponent component) {
            super(component);
            this.emailInfo = component.emailInfo();
            gson = component.gson();

            code.filter(StringUtils::isVerificationCode)
                    .compose(bindToLifecycle())
                    .doOnNext(__ -> validCode = __)
                    .subscribe(isCodeValid);

            emailAddress.compose(Transformers.takeWhen(resendCodeClick))
                    .switchMap(this::requestSendEmail)
                    .compose(bindToLifecycle())
                    .subscribe(__ -> success());

            normalError()
                    .compose(bindToLifecycle())
                    .subscribe(__ -> success());

        }

        private Observable<BooleanResponse> requestSendEmail(final @NonNull String email) {
            ResetPwdEmailBody body = new ResetPwdEmailBody();
            body.to = email;
            return ApiService.createApiService().sendResetPasswordEmail(body)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .doOnSubscribe(disposable -> isFormSubmitting.onNext(true))
                    .doAfterTerminate(() -> isFormSubmitting.onNext(false));
        }

        private void success() {
            resendSuccess.onNext(Optional.empty());
        }
    }
}