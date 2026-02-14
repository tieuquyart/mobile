package com.mk.autosecure.viewmodels.setting;

import android.annotation.SuppressLint;
import android.util.Pair;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.UserBean;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.AuthorizeResponse;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.request.ChangePwdBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.ModifyPwdBody;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.activity.settings.ChangePwdActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;

import java.io.IOException;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;
import retrofit2.HttpException;

/**
 * Created by DoanVT on 2017/11/8.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint("CheckResult")
public interface ChangePwdViewModel {

    interface Inputs {

        /**
         * Call when the save menu is clicked.
         */
        void confirmClick();

        /**
         * Call when the password field is changed.
         */
        void password(String __);

        /**
         * Call when the new password FIRST field is changed.
         */
        void newPasswordFirst(String __);

        /**
         * Call when the new password SECOND field is changed.
         */
        void newPasswordSecond(String __);

        /**
         * Call when the user cancels or dismisses the reset password success confirmation dialog.
         */
        void resetPasswordConfirmationDialogDismissed();
    }


    interface Outputs {
        /**
         * Finish the activity with a successful result.
         */
        Observable<Boolean> changeSuccess();

        /**
         * Emits an email string and boolean to determine whether or not to display the reset password success dialog.
         */
        Observable<Pair<Boolean, String>> showResetPasswordSuccessDialog();

        /**
         * Emits a boolean to determine whether or not the login button should be enabled.
         */
        Observable<Boolean> setConfirmButtonIsEnabled();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> lowLevelError();

        Observable<Response> error();
    }

    final class ViewModel extends ActivityViewModel<ChangePwdActivity> implements Inputs, Outputs, Errors {

        static class ChangePwdData {
            public final @NonNull
            String password;
            public final @NonNull
            String newPwd1th;
            public final @NonNull
            String newPwd2th;

            ChangePwdData(final @NonNull String password,
                          final @NonNull String newPwd1th, final @NonNull String newPwd2th) {
                this.password = password;
                this.newPwd1th = newPwd1th;
                this.newPwd2th = newPwd2th;
            }
        }

        private static final String TAG = ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;
        private final Gson gson;

        public ViewModel(AppComponent component) {
            super(component);
            final Observable<ChangePwdData> changePwdData = Observable.combineLatest(password,
                    newPwdFirst, newPwdSecond, ChangePwdData::new);

            final Observable<Boolean> isValid = changePwdData
                    .map(this::isValid);

            currentUser = component.currentUser();

            gson = component.gson();

            isValid
                    .compose(bindToLifecycle())
                    .subscribe(setConfirmButtonIsEnabled);
            Logger.t(TAG).d("enableButton:= "+setConfirmButtonIsEnabled);

            if (Constants.isFleet()) {
                changePwdData
                        .compose(Transformers.takeWhen(saveClick))
                        .switchMap(pw -> submitFleet(pw.password, pw.newPwd1th, pw.newPwd2th))
                        .compose(bindToLifecycle())
                        .subscribe(this::modifySuccess, new ServerErrorHandler());
            } else {
                changePwdData
                        .compose(Transformers.takeWhen(saveClick))
                        .switchMap((ChangePwdData ep) -> submit(ep.password, ep.newPwd1th, ep.newPwd2th))
                        .compose(bindToLifecycle())
                        .subscribe(this::success, new ServerErrorHandler());
            }
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        private boolean isValid(final @NonNull ChangePwdData data) {
            return data.password.length() > 0 && StringUtils.isPwdValid(data.newPwd1th)
                    && data.newPwd1th.equals(data.newPwd2th);
        }

        private PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();
        private PublishSubject<Response> error = PublishSubject.create();

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

        @Override
        public Observable<Response> error() {
            return error;
        }


        private Observable<AuthorizeResponse> submit(final @NonNull String password, final @NonNull String newPassword1,
                                                     final @NonNull String newPassword2) {
            ChangePwdBody changePwdBody = new ChangePwdBody(password, newPassword1);
            return ApiService.createApiService().changePassword(changePwdBody)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(apiError))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }

        private Observable<BOOLResponse> submitFleet(final @NonNull String password,
                                                     final @NonNull String newPassword,
                                                     final @NonNull String newPasswordAgain) {
            ModifyPwdBody body = new ModifyPwdBody(password, newPassword, newPasswordAgain);
            return ApiClient.createApiService().changePwd(HornApplication.getComponent().currentUser().getAccessToken(),body)
                    .lift(Operators.apiError(gson))
                    .subscribeOn(Schedulers.io())
                    .compose(Transformers.pipeApiErrorsTo(apiError))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }

        private void error(Throwable e) {
            try {
                Logger.t(TAG).d("%s", e.getMessage());
                if (e instanceof HttpException) {
                    HttpException ex = (HttpException) e;
                    Logger.t(TAG).d("error" + ex.response().errorBody().string() + ex.getMessage());
                }
            } catch (IOException ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }

        private void success(final @NonNull AuthorizeResponse response) {
            UserBean userBean = response.user;
            User user = User.builder()
                    .avatar(userBean.avatarUrl)
                    .id(userBean.userID)
                    .name(userBean.userName)
                    .displayName(userBean.displayName)
                    .verified(userBean.isVerified)
                    .build();

            Logger.t(TAG).d("authorizeResponse:" + userBean.userName);
            currentUser.login(user, response.token);
            changeSuccess.onNext(false);
        }

        private void modifySuccess(BOOLResponse response) {
            Logger.t(TAG).d("modifySuccess: " + response.isSuccess());
            if (response.isSuccess()){
                changeSuccess.onNext(true);
            }else{
                changeSuccess.onNext(false);
                error.onNext(response);
            }
        }

        private final PublishSubject<Optional<Void>> saveClick = PublishSubject.create();
        private final PublishSubject<String> password = PublishSubject.create();
        private final PublishSubject<String> newPwdFirst = PublishSubject.create();
        private final PublishSubject<String> newPwdSecond = PublishSubject.create();
        private final PublishSubject<Boolean> resetPasswordConfirmationDialogDismissed = PublishSubject.create();

        private final PublishSubject<Boolean> changeSuccess = PublishSubject.create();
        private final BehaviorSubject<Boolean> setConfirmButtonIsEnabled = BehaviorSubject.create();
        private final BehaviorSubject<Pair<Boolean, String>> showResetPasswordSuccessDialog = BehaviorSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        @Override
        public void confirmClick() {
            saveClick.onNext(Optional.empty());
        }

        @Override
        public void password(final @NonNull String s) {
            password.onNext(s);
        }

        @Override
        public void newPasswordFirst(final @NonNull String s) {
            newPwdFirst.onNext(s);
        }

        @Override
        public void newPasswordSecond(final @NonNull String s) {
            newPwdSecond.onNext(s);
        }

        @Override
        public void resetPasswordConfirmationDialogDismissed() {
            resetPasswordConfirmationDialogDismissed.onNext(true);
        }

        @Override
        public
        @NonNull
        Observable<Boolean> changeSuccess() {
            return changeSuccess;
        }

        @Override
        public Observable<Boolean> setConfirmButtonIsEnabled() {
            return setConfirmButtonIsEnabled;
        }

        @Override
        public Observable<Pair<Boolean, String>> showResetPasswordSuccessDialog() {
            return showResetPasswordSuccessDialog;
        }

    }
}
