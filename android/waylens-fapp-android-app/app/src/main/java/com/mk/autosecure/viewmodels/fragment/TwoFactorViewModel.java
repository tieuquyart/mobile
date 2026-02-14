package com.mk.autosecure.viewmodels.fragment;

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
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.ResetPwdBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.ui.fragment.TwoFactorFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 */

public interface TwoFactorViewModel {
    interface Inputs {
        void code(String __);

        void submitClick();

        void backClick();

        void email(String __);

        void password(String __);

        void passwordRepeat(String __);
    }

    interface Outputs {
        Observable<Optional<Void>> resetSuccess();

        Observable<Boolean> formSubmitting();

        Observable<Boolean> formIsValid();

        Observable<Void> showResendCodeConfirmation();

        Observable<Optional<Void>> stepBack();
    }

    interface Errors {
        // Emits when a submitted code does not match.
        Observable<ErrorEnvelope> resetError();

        // Emits when submitting code error for an unknown reason.
        Observable<ErrorEnvelope> genericError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<TwoFactorFragment> implements Inputs, Outputs, Errors {

        private static final String TAG = ViewModel.class.getSimpleName();

        static class ResetData {
            final @NonNull
            String email;
            final @NonNull
            String password;
            final @NonNull
            String passwordRepeat;

            ResetData(final @NonNull String email, final @NonNull String password, final @NonNull String passwordRepeat) {
                this.email = email;
                this.password = password;
                this.passwordRepeat = passwordRepeat;
            }
        }

        // INPUTS

        @Override
        public void code(@NonNull final String s) {
            code.onNext(s);
        }

        @Override
        public void email(@NonNull String s) {
            email.onNext(s);
        }

        @Override
        public void password(@NonNull String s) {
            password.onNext(s);
        }

        @Override
        public void passwordRepeat(@NonNull String s) {
            passwordRepeat.onNext(s);
        }

        private final PublishSubject<Optional<Void>> submitClick = PublishSubject.create();

        @Override
        public void submitClick() {
            submitClick.onNext(Optional.empty());
        }

        private final PublishSubject<Optional<Void>> backClick = PublishSubject.create();

        @Override
        public void backClick() {
            backClick.onNext(Optional.empty());
        }

        // OUTPUTS
        private final PublishSubject<Boolean> formSubmitting = PublishSubject.create();

        public Observable<Boolean> formSubmitting() {
            return formSubmitting.hide();
        }

        private final PublishSubject<Boolean> formIsValid = PublishSubject.create();

        public Observable<Boolean> formIsValid() {
            return formIsValid.hide();
        }

        private final PublishSubject<Optional<Void>> resetSuccess = PublishSubject.create();

        public Observable<Optional<Void>> resetSuccess() {
            return resetSuccess.hide();
        }

        private final PublishSubject<Void> showResendCodeConfirmation = PublishSubject.create();

        public Observable<Void> showResendCodeConfirmation() {
            return showResendCodeConfirmation.hide();
        }

        @Override
        public Observable<Optional<Void>> stepBack() {
            return backClick;
        }

        // ERRORS
        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        public Observable<ErrorEnvelope> resetError() {
            return error
                    .takeUntil(resetSuccess);
            //.filter(ErrorEnvelope::isChangePWDTokenError);
        }

        public Observable<ErrorEnvelope> genericError() {
            return null;
        }

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        private final CurrentUser currentUser;

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        private PublishSubject<String> email = PublishSubject.create();
        private PublishSubject<String> password = PublishSubject.create();
        private final PublishSubject<String> passwordRepeat = PublishSubject.create();
        private final PublishSubject<String> code = PublishSubject.create();
        private final Gson gson;

        public ViewModel(final @NonNull AppComponent appComponent) {
            super(appComponent);

            currentUser = appComponent.currentUser();

            final Observable<ResetData> resetData = Observable.combineLatest(email, password, password, ResetData::new);

            resetData
                    .compose(Transformers.combineLatestPair(code))
                    .map(cd -> this.isValid(cd.first, cd.second))
                    .compose(bindToLifecycle())
                    .subscribe(formIsValid);

//            code
//                    .compose(Transformers.combineLatestPair(resetData))
//                    .compose(Transformers.takeWhen(submitClick))
//                    .switchMap(cd -> this.resetPwd(cd.first, cd.second.email, cd.second.password))
//                    .compose(bindToLifecycle())
//                    .subscribe(this::success, new ServerErrorHandler(TAG));

            gson = appComponent.gson();

        }

        private void success(final @NonNull BooleanResponse res) {
            if (res.result) {
                resetSuccess.onNext(Optional.empty());
            }
        }

//        private Observable<BooleanResponse> resetPwd(final @NonNull String code, final @NonNull String email,
//                                                     final @NonNull String password) {
//            ResetPwdBody body = new ResetPwdBody();
//            body.email = email;
//            body.newPassword = password;
//            body.token = code;
//            Logger.t(TAG).d("error = " + ToStringUtils.getString("body"));
//            Observable<Response<BooleanResponse>> observable;
//            if (Constants.isFleet()) {
//                observable = ApiClient.createApiService().resetPassword(body);
//            } else {
//                observable = ApiService.createApiService().resetPassword("body");
//            }
//            return observable
//                    .lift(Operators.apiError(gson))
//                    .subscribeOn(Schedulers.io())
//                    .compose(Transformers.pipeApiErrorsTo(error))
//                    .compose(Transformers.pipeErrorsTo(llError))
//                    .compose(Transformers.neverError())
//                    .doOnSubscribe(disposable -> formSubmitting.onNext(true))
//                    .doAfterTerminate(() -> formSubmitting.onNext(false));
//        }

        private boolean isValid(final @NonNull ResetData data, String code) {
            return data.password.length() > 0 && StringUtils.isPwdValid(data.password)
                    && data.password.equals(data.passwordRepeat) && StringUtils.isVerificationCode(code);
        }
    }
}
