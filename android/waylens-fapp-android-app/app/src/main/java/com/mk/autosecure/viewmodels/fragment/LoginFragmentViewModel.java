package com.mk.autosecure.viewmodels.fragment;

import static com.mk.autosecure.ui.fragment.LoginFragment.KEY_ACCOUNT;
import static com.mk.autosecure.ui.fragment.LoginFragment.KEY_CHECKED;
import static com.mk.autosecure.ui.fragment.LoginFragment.KEY_PW;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.util.Pair;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.account.CameraSubscriber;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.LogInPostBody;
import com.mk.autosecure.rest_fleet.response.CameraResponse;
import com.mk.autosecure.rest_fleet.response.LogInResponse;
import com.mk.autosecure.ui.fragment.LoginFragment;
import android.widget.Toast;

import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import io.reactivex.Observable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/11/14.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint("CheckResult")
public interface LoginFragmentViewModel {


    interface Inputs {
        /**
         * Call when the email address field is changed.
         */
        void account(String __);

        /**
         * Call when the login button is clicked.
         */
        void loginClick();

        /**
         * Call when the password field is changed.
         */
        void password(String __);

        /**
         * Call when the user cancels or dismisses the reset password success confirmation dialog.
         */
        void resetPasswordConfirmationDialogDismissed();

        void rememberAccount(String account, String password, boolean isCheck);

        void getAccount();
    }


    interface Outputs {
        /**
         * Finish the activity with a successful result.
         */
        Observable<Optional<Void>> loginSuccess();
        /**
         * Finish the activity with a failure result.
         */

        Observable<LogInResponse> loginFailure();

        /**
         * Fill the view's email address and show a dialog indicating the user's password has been reset.
         */
        Observable<String> prefillEmailFromPasswordReset();

        /**
         * Emits an email string and boolean to determine whether or not to display the reset password success dialog.
         */
        Observable<Pair<Boolean, String>> showResetPasswordSuccessDialog();

        /**
         * Emits a boolean to determine whether or not the login button should be enabled.
         */
        Observable<Boolean> setLoginButtonIsEnabled();


        BehaviorSubject<String> loginAccount();

        Observable<Pair<String,String>>bindAccountEditText();

        Observable<Boolean>isCheck();
    }

    interface Errors {
        Observable<ErrorEnvelope> loginError();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<LoginFragment> implements Inputs, Outputs, Errors {
        private static final String TAG = ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;
        private final Context mContext;
        private final Gson gson;

        private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

        public ViewModel(AppComponent component) {
            super(component);
            final Observable<Pair<String, String>> accountAndPassword = account
                    .compose(Transformers.combineLatestPair(password));

            final Observable<Boolean> isValid = accountAndPassword
                    .map(ep -> isValid(ep.first, ep.second));
            currentUser = component.currentUser();
            mContext = component.appContext();
            gson = component.gson();

            isValid
                    .compose(bindToLifecycle())
                    .subscribe(setLoginButtonIsEnabled);
            if (Constants.isFleet()) {
                accountAndPassword
                        .compose(Transformers.takeWhen(loginClick))
                        .switchMap(ep -> submitFleet(ep.first, ep.second))
                        .compose(bindToLifecycle())
                        .subscribe(new Consumer<LogInResponse>() {
                            @Override
                            public void accept(LogInResponse response) throws Exception {
                                if (response.isSuccess()) {
                                    currentUser.login(response);
                                    loginSuccess.onNext(Optional.empty());
                                    refreshCamera();
//                                    bindPushToken();
                                } else {
                                    loginFailure.onNext(response);
                                }
                            }
                        });
            }
        }
        /**
         * check validate
         * */
        private boolean isValid(final @NonNull String email, final @NonNull String password) {
            Log.e(TAG, email + "" + StringUtils.isEmpty(email) + "" + password);
            return StringUtils.isPresent(email) && password.length() > 0;
        }

        /**
         * login
         * */
        private Observable<LogInResponse> submitFleet(final @NonNull String name, final @NonNull String password) {
            LogInPostBody body = new LogInPostBody(name, password);
            loginAccount.onNext(name);
            return ApiClient.createApiService().logInFleet(body)
                    .subscribeOn(Schedulers.io())
                    .lift(Operators.apiError(gson))
                    .timeout(1000, TimeUnit.SECONDS)
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError());
        }

//        private void successLogIn(final @NonNull LogInResponse response) {
//            Logger.t(TAG).d("authorizeResponse: " + response);
//            if (response.isSuccess()) {
//                currentUser.login(response);
//                loginSuccess.onNext(Optional.empty());
//                refreshCamera();
//            } else {
//                loginFailure.onNext(response);
//            }
//        }

        private void refreshCamera() {
            if (Constants.isFleet()) {
                getCameras();
            } else {
                ApiService.createApiService().getCameras()
                        .compose(Transformers.switchSchedulers())
                        .subscribe(new CameraSubscriber());
            }
        }
        /**
         * lấy thông tin camera
         * */
        private void getCameras() {
            fleetCameraBeanList.clear();

            ApiClient.createApiService().getCameras(HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<CameraResponse>() {
                        @Override
                        public void accept(CameraResponse cameraResponse) throws Exception {
                            if (cameraResponse.isSuccess()) {
                                List<FleetCameraBean> cameraBeans = cameraResponse.getData();
                                fleetCameraBeanList.addAll(cameraBeans);
                                HornApplication.getComponent().fleetInfo().refreshDevices(cameraBeans);
                            } else {
                                Toast.makeText(mContext, cameraResponse.getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getDriverList throwable: " + throwable.getMessage());
                        List<FleetCameraBean> devices = HornApplication.getComponent().fleetInfo().getDevices();
                        fleetCameraBeanList.add((FleetCameraBean) devices);
                    });
        }

        private final PublishSubject<String> account = PublishSubject.create();
        private final PublishSubject<Optional<Void>> loginClick = PublishSubject.create();
        private final PublishSubject<String> password = PublishSubject.create();
        private final PublishSubject<Boolean> resetPasswordConfirmationDialogDismissed = PublishSubject.create();

        private final PublishSubject<Optional<Void>> loginSuccess = PublishSubject.create();
        private final PublishSubject<LogInResponse> loginFailure = PublishSubject.create();
        private final BehaviorSubject<String> prefillEmailFromPasswordReset = BehaviorSubject.create();
        private final BehaviorSubject<Boolean> setLoginButtonIsEnabled = BehaviorSubject.create();
        private final BehaviorSubject<Boolean> isCheck = BehaviorSubject.create();
        private final BehaviorSubject<Pair<Boolean, String>> showResetPasswordSuccessDialog = BehaviorSubject.create();
        private final BehaviorSubject<Pair<String, String>> bindAccountEditText = BehaviorSubject.create();
        private final BehaviorSubject<String> loginAccount = BehaviorSubject.create();

        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();

        // low level error, network etc.
        private PublishSubject<Throwable> llError = PublishSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        @Override
        public void account(final @NonNull String s) {
            account.onNext(s);
        }

        @Override
        public void loginClick() {
            loginClick.onNext(Optional.empty());
        }

        @Override
        public void password(final @NonNull String s) {
            password.onNext(s);
        }

        @Override
        public void resetPasswordConfirmationDialogDismissed() {
            resetPasswordConfirmationDialogDismissed.onNext(true);
        }

        @Override
        public void rememberAccount(String account, String password, boolean isCheck) {
            if (isCheck){
                PreferenceUtils.putString(KEY_ACCOUNT, account);
                PreferenceUtils.putString(KEY_PW, password);
            }else{
                PreferenceUtils.putString(KEY_ACCOUNT, "");
                PreferenceUtils.putString(KEY_PW, "");
            }
            PreferenceUtils.putBoolean(KEY_CHECKED, isCheck);
        }

        @Override
        public void getAccount() {
            String account = PreferenceUtils.getString(KEY_ACCOUNT,"");
            String password = PreferenceUtils.getString(KEY_PW,"");
            boolean isChecked = PreferenceUtils.getBoolean(KEY_CHECKED,false);
            Logger.t(TAG).d("account: %s - password: %s -isCheck: %s",account,password,isChecked ? "true" : "false");
            bindAccountEditText.onNext(new Pair<>(account,password));
            isCheck.onNext(isChecked);
        }

        @Override
        public
        @NonNull
        Observable<Optional<Void>> loginSuccess() {
            return loginSuccess.hide();
        }

        @Override
        public Observable<LogInResponse> loginFailure() {
            return loginFailure;
        }

        @Override
        public
        @NonNull
        Observable<String> prefillEmailFromPasswordReset() {
            return prefillEmailFromPasswordReset;
        }

        @Override
        public Observable<Boolean> setLoginButtonIsEnabled() {
            return setLoginButtonIsEnabled;
        }

        @Override
        public BehaviorSubject<String> loginAccount() {
            return loginAccount;
        }

        @Override
        public Observable<Pair<String, String>> bindAccountEditText() {
            return bindAccountEditText;
        }

        @Override
        public Observable<Boolean> isCheck() {
            return isCheck;
        }

        @Override
        public Observable<Pair<Boolean, String>> showResetPasswordSuccessDialog() {
            return showResetPasswordSuccessDialog;
        }

        @Override
        public Observable<ErrorEnvelope> loginError() {
            return error;
        }

        @Override
        public Observable<Throwable> lowLevelError() {
            return llError;
        }

    }
}
