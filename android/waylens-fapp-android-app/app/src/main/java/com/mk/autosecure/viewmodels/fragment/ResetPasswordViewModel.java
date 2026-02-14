package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.ResetPwdBody;
import com.mk.autosecure.rest.request.ResetPwdEmailBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.ui.fragment.ResetPasswordFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.ToStringUtils;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
public interface ResetPasswordViewModel {

    interface Inputs {
        void email(String __);

        void account(String __);

        void phone(String __);

        void resetPasswordClick();

        void backClick();
    }

    interface Outputs {
        Observable<Optional<Void>> resetSuccess();

        Observable<Boolean> isFormSubmitting();

        Observable<Boolean> isFormValid();

        Observable<Optional<Void>> stepBack();

        String validEmail();
    }

    interface Errors {
        Observable<ErrorEnvelope> resetError();

        Observable<BOOLResponse> resetFailure();

        Observable<ErrorEnvelope> normalError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<ResetPasswordFragment> implements Inputs,
            Outputs, Errors {
        private static final String TAG = ViewModel.class.getSimpleName();

        protected final static class ResetPWData {
            final @NonNull
            String account;

            final @NonNull
            String email;

            final @NonNull
            String phone;

            public ResetPWData(@NonNull String account, @NonNull String email, @NonNull String phone) {
                this.account = account;
                this.email = email;
                this.phone = phone;
            }

            protected boolean isValid() {
                return !StringUtils.isEmpty(account)
                        && !StringUtils.isEmpty(email)
                        && !StringUtils.isEmpty(phone);
            }
        }

        // INPUTS
        private final PublishSubject<String> email = PublishSubject.create();
        private final PublishSubject<String> account = PublishSubject.create();
        private final PublishSubject<String> phone = PublishSubject.create();
        private final PublishSubject<Optional<Void>> resetPasswordClick = PublishSubject.create();

        // OUTPUTS
        private final PublishSubject<Optional<Void>> resetSuccess = PublishSubject.create();

        private final PublishSubject<BOOLResponse> resetFailure = PublishSubject.create();

        public Observable<Optional<Void>> resetSuccess() {
            return resetSuccess.hide();
        }

        private final PublishSubject<Boolean> isFormSubmitting = PublishSubject.create();

        public Observable<Boolean> isFormSubmitting() {
            return isFormSubmitting.hide();
        }

        private final PublishSubject<Boolean> isFormValid = PublishSubject.create();

        public Observable<Boolean> isFormValid() {
            return isFormValid.hide();
        }

        private String validEmail = "";

        @Override
        public String validEmail() {
            return validEmail;
        }

        // ERRORS
        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        public Observable<ErrorEnvelope> resetError() {
            return error
                    .doOnNext(errorEnvelope -> {
                        String error = ToStringUtils.getString(errorEnvelope);
                        Logger.t(TAG).d("error =" + error);
                    })
//                    .takeUntil(resetSuccess)
                    .filter(ErrorEnvelope::isSendResetEmailFatalError);
        }

        @Override
        public Observable<BOOLResponse> resetFailure() {
            return resetFailure;
        }

        public Observable<ErrorEnvelope> normalError() {
            return error
//                    .takeUntil(resetSuccess)
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

        @Override
        public void email(final @NonNull String s) {
            email.onNext(s);
        }

        @Override
        public void account(final @NonNull String s) {
            account.onNext(s);
        }

        @Override
        public void phone(final @NonNull String s) {
            phone.onNext(s);
        }

        @Override
        public void resetPasswordClick() {
            resetPasswordClick.onNext(Optional.empty());
        }

        private final Gson gson;

        public ViewModel(final @NonNull AppComponent component) {
            super(component);
            gson = component.gson();

            final Observable<ResetPWData> resetPWData = Observable.combineLatest(account, email, phone, ResetPWData::new);

            final Observable<Boolean> isValid = resetPWData.compose(Transformers.combineLatestPair(email)).map(pair -> pair.first.isValid() && !StringUtils.isEmpty(pair.second));

            isValid
                    .compose(bindToLifecycle())
                    .subscribe(isFormValid);
//                    email
//                    .doOnNext(s -> {
//                if (StringUtils.isEmail(s)) {
//                    validEmail = s;
//                }
//            })
//                    .map(StringUtils::isEmail)
//                    .compose(bindToLifecycle())
//                    .subscribe(isFormValid);


            resetPWData
                    .compose(Transformers.takeWhen(resetPasswordClick))
                    .switchMap(this::requestSendEmail)
                    .compose(bindToLifecycle())
                    .subscribe(this::success, new ServerErrorHandler());

            normalError()
                    .compose(bindToLifecycle())
                    .subscribe(__ -> resetSuccess.onNext(Optional.empty()), new ServerErrorHandler());
        }

        private Observable<BOOLResponse> requestSendEmail(final @NonNull ResetPWData data) {
            ResetPwdBody body = new ResetPwdBody(data.account, data.email, data.phone);

            return ApiClient.createApiService().resetPassword(body)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .doOnSubscribe(disposable -> isFormSubmitting.onNext(true))
                    .doAfterTerminate(() -> isFormSubmitting.onNext(false));
        }


        private void success(BOOLResponse res) {
            Logger.t(TAG).d("result = " + res.isSuccess());
            if (res.isSuccess()) {
                resetSuccess.onNext(Optional.empty());
            }else{
                resetFailure.onNext(res);
            }
        }
    }
}