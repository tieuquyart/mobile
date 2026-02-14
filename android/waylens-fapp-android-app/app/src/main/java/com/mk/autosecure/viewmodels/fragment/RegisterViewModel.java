package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.bean.UserBean;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.AuthorizeResponse;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest.request.CheckSerialBody;
import com.mk.autosecure.rest.request.FleetNewPostBody;
import com.mk.autosecure.rest.request.SignUpPostBody;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.ui.fragment.RegisterFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;
import kotlin.Pair;

/**
 * Created by DoanVT on 2017/11/15.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint("CheckResult")
public interface RegisterViewModel {

    interface Inputs {
        void fleetName(String __);

        void account(String __);

        void password(String __);

        void fullName(String __);

        void email(String __);

        void mobile(String __);

        void signupClick();

        void agreeCheck(boolean __);

        //checkSN
//        void cameraSn(String __);

        void checkClick(String cameraSn);

        //newFleet
        void fleet_Name(String __);

        void accountFleet(String __);

        void emailFleet(String __);

        void phoneFleet(String __);

        void signupFleetClick();
    }

    interface Outputs {
        Observable<Optional<Void>> signupSuccess();

        Observable<Optional<Void>> checkSnSuccess();

        Observable<Boolean> formSubmitting();

        Observable<Boolean> formIsValid();

        Observable<Boolean> newfleetIsValid();

        BehaviorSubject<String> signupEmail();
    }

    interface Errors {
        Observable<ErrorEnvelope> signupError();

        Observable<BOOLResponse> signupFailure();

        Observable<Throwable> lowLevelError();
    }

    final class ViewModel extends FragmentViewModel<RegisterFragment> implements Inputs, Outputs, Errors {
        private static final String TAG = ViewModel.class.getSimpleName();
        private final CurrentUser currentUser;
        private final AppComponent component;

        protected final static class SignupData {
            final @NonNull
            String email;
            final @NonNull
            String password;
            final @NonNull
            String fleetName;
            final @NonNull
            String account;
            final @NonNull
            String realName;
            final @NonNull
            String phone;

            public SignupData(final @NonNull String email, final @NonNull String password, final @NonNull String fleetName, final @NonNull String account, final @NonNull String realName, final @NonNull String phone) {
                this.email = email;
                this.password = password;
                this.fleetName = fleetName;
                this.account = account;
                this.realName = realName;
                this.phone = phone;
            }

            protected boolean isValid() {
                return !StringUtils.isEmpty(email)
                        && !StringUtils.isEmpty(password)
                        && !StringUtils.isEmpty(fleetName)
                        && !StringUtils.isEmpty(account)
                        && !StringUtils.isEmpty(realName)
                        && !StringUtils.isEmpty(phone);
            }
        }

        protected final static class SignupFleetData {
            final @NonNull
            String fleetName;
            final @NonNull
            String accountFleet;
            final @NonNull
            String emailFleet;
            final @NonNull
            String phoneFleet;

            public SignupFleetData(@NonNull String fleetName, @NonNull String accountFleet, @NonNull String emailFleet, @NonNull String phoneFleet) {
                this.fleetName = fleetName;
                this.accountFleet = accountFleet;
                this.emailFleet = emailFleet;
                this.phoneFleet = phoneFleet;
            }

            protected boolean isValid() {
                return !StringUtils.isEmpty(fleetName)
                        && !StringUtils.isEmpty(accountFleet)
                        && !StringUtils.isEmpty(emailFleet)
                        && !StringUtils.isEmpty(phoneFleet);
            }
        }


        // INPUTS
        private final PublishSubject<String> fullName = PublishSubject.create();

        public void fullName(final @NonNull String s) {
            fullName.onNext(s);
        }

        private final PublishSubject<String> email = PublishSubject.create();

        public void email(final @NonNull String s) {
            email.onNext(s);
        }

        private final PublishSubject<String> password = PublishSubject.create();

        public void password(final @NonNull String s) {
            password.onNext(s);
        }

        private final PublishSubject<String> fleetName = PublishSubject.create();

        public void fleetName(final @NonNull String s) {
            fleetName.onNext(s);
        }

        private final PublishSubject<String> account = PublishSubject.create();

        public void account(final @NonNull String s) {
            account.onNext(s);
        }

        private final PublishSubject<String> mobile = PublishSubject.create();

        public void mobile(final @NonNull String s) {
            mobile.onNext(s);
        }

        private final PublishSubject<Optional<Void>> signupClick = PublishSubject.create();

        public void signupClick() {
            signupClick.onNext(Optional.empty());
        }

        private final BehaviorSubject<Boolean> agreeCheck = BehaviorSubject.createDefault(true);

        public void agreeCheck(boolean state) {
            agreeCheck.onNext(state);
        }

//        private final PublishSubject<String> cameraSn = PublishSubject.create();
//
//        @Override
//        public void cameraSn(final @NonNull String s) {
//            cameraSn.onNext(s);
//        }

        private final PublishSubject<Optional<Void>> checkClick = PublishSubject.create();

        @Override
        public void checkClick(String cameraSn) {
            if (!StringUtils.isEmpty(cameraSn)) {
                CheckSerialBody body = new CheckSerialBody(cameraSn);
                ApiClient.createApiService().checkSerial(body)
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe(this::checkSNRes);
            }
        }

        private final PublishSubject<String> fleet_Name = PublishSubject.create();

        @Override
        public void fleet_Name(final @NonNull String s) {
            Logger.t(TAG).d("fleetName: " + s);
            fleet_Name.onNext(s);
        }

        private final PublishSubject<String> accountFleet = PublishSubject.create();

        @Override
        public void accountFleet(final @NonNull String s) {
            Logger.t(TAG).d("accountF: " + s);
            accountFleet.onNext(s);
        }

        private final PublishSubject<String> emailFleet = PublishSubject.create();

        @Override
        public void emailFleet(final @NonNull String s) {
            Logger.t(TAG).d("emailF: " + s);
            emailFleet.onNext(s);
        }

        private final PublishSubject<String> phoneFleet = PublishSubject.create();

        @Override
        public void phoneFleet(final @NonNull String s) {
            Logger.t(TAG).d("phoneF: " + s);
            phoneFleet.onNext(s);
        }


        private final PublishSubject<Optional<Void>> signupFleetClick = PublishSubject.create();

        @Override
        public void signupFleetClick() {
            signupFleetClick.onNext(Optional.empty());
        }

        // OUTPUTS
        private final PublishSubject<Optional<Void>> signupSuccess = PublishSubject.create();

        public Observable<Optional<Void>> signupSuccess() {
            return signupSuccess.hide();
        }

        private final PublishSubject<Optional<Void>> checkSnSuccess = PublishSubject.create();

        public Observable<Optional<Void>> checkSnSuccess() {
            return checkSnSuccess.hide();
        }

        private final PublishSubject<BOOLResponse> signupFailure = PublishSubject.create();

        private final PublishSubject<Boolean> formSubmitting = PublishSubject.create();

        public Observable<Boolean> formSubmitting() {
            return formSubmitting.hide();
        }

        private final PublishSubject<Boolean> formIsValid = PublishSubject.create();

        public Observable<Boolean> formIsValid() {
            return formIsValid.hide();
        }

//        private final PublishSubject<Boolean> checkSnIsValid = PublishSubject.create();
//
//        public Observable<Boolean> checkSnIsValid() {
//            return checkSnIsValid.hide();
//        }

        private final PublishSubject<Boolean> newfleetIsValid = PublishSubject.create();

        public Observable<Boolean> newfleetIsValid() {
            return newfleetIsValid.hide();
        }

        public BehaviorSubject<String> signupEmail = BehaviorSubject.create();

        @Override
        public BehaviorSubject<String> signupEmail() {
            return signupEmail;
        }

        // ERRORS
        private final PublishSubject<ErrorEnvelope> signupError = PublishSubject.create();

        public Observable<ErrorEnvelope> signupError() {
            return signupError;
        }

        @Override
        public Observable<BOOLResponse> signupFailure() {
            return signupFailure;
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

        public ViewModel(AppComponent component) {
            super(component);
            this.component = component;
            gson = component.gson();
            currentUser = component.currentUser();
            //SignUp
            final Observable<SignupData> signupData = Observable.combineLatest(
                    email, password, fleetName, account, fullName, mobile, SignupData::new);

            final Observable<Boolean> isValidSignUp = signupData.compose(Transformers.combineLatestPair(agreeCheck))
                    .map(pair -> pair.first.isValid() && pair.second);

            isValidSignUp
                    .compose(bindToLifecycle())
                    .subscribe(formIsValid);

            //signupFleet

            final Observable<SignupFleetData> signupFleetData = Observable.combineLatest(fleet_Name, accountFleet, emailFleet, phoneFleet, SignupFleetData::new);

            final Observable<Boolean> isValidNewFleet = signupFleetData.compose(Transformers.combineLatestPair(agreeCheck))
                    .map(pair -> pair.first.isValid() && pair.second);

            isValidNewFleet.compose(bindToLifecycle())
                    .subscribe(newfleetIsValid);

            //submit-signup
            signupData
                    .compose(Transformers.takeWhen(signupClick))
                    .flatMap(this::submit)
                    .compose(bindToLifecycle())
                    .subscribe(this::finish);

            //submit-signupFleet
            signupFleetData.compose(Transformers.takeWhen(signupFleetClick))
                    .flatMap(this::submitFleet)
                    .compose(bindToLifecycle())
                    .subscribe(this::finish);

        }

        private Observable<BOOLResponse> submit(final @NonNull SignupData data) {
            SignUpPostBody postBody = new SignUpPostBody(data.email, data.fleetName, data.password, data.phone, data.realName, data.account);
            signupEmail.onNext(data.email);
            Logger.t(TAG).d("submit: %s", postBody.toString());

            return ApiClient.createApiService().signUp(postBody)
                    .subscribeOn(Schedulers.io())
                    .lift(Operators.apiError(gson))
                    .compose(Transformers.pipeApiErrorsTo(signupError))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .doOnSubscribe(disposable -> formSubmitting.onNext(true))
                    .doAfterTerminate(() -> formSubmitting.onNext(false));
        }

        private Observable<BOOLResponse> submitFleet(final @NonNull SignupFleetData data) {
            FleetNewPostBody postBody = new FleetNewPostBody(data.emailFleet, data.phoneFleet, data.accountFleet, data.fleetName);
            Logger.t(TAG).d("submit: %s", postBody.toString());

            return ApiClient.createApiService().createFleet(postBody)
                    .subscribeOn(Schedulers.io())
                    .lift(Operators.apiError(gson))
                    .compose(Transformers.pipeApiErrorsTo(signupError))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .doOnSubscribe(disposable -> formSubmitting.onNext(true))
                    .doAfterTerminate(() -> formSubmitting.onNext(false));
        }

        private void success(final @NonNull AuthorizeResponse authorizeResponse) {
            UserBean userBean = authorizeResponse.user;
            User user = User.builder()
                    .avatar(userBean.avatarUrl)
                    .id(userBean.userID)
                    .name(userBean.userName)
                    .displayName(userBean.displayName)
                    .verified(userBean.isVerified)
                    .build();

            Logger.t(TAG).d("authorizeResponse:" + userBean.userName);
            currentUser.login(user, authorizeResponse.token);
            signupSuccess.onNext(Optional.empty());
            String em = signupEmail.getValue();
            if (StringUtils.isEmail(em)) {
                component.emailInfo().refresh(new EmailInfo.Data(em, System.currentTimeMillis()));
            }
        }

        private void finish(final @NonNull BOOLResponse response) {
            if (response.isSuccess()) {
                signupSuccess.onNext(Optional.empty());
            } else {
                signupFailure.onNext(response);
            }
        }

        private void checkSNRes(BOOLResponse response) {
            if (response.isSuccess()) {
                checkSnSuccess.onNext(Optional.empty());
            } else {
                signupFailure.onNext(response);
            }
        }

    }
}
