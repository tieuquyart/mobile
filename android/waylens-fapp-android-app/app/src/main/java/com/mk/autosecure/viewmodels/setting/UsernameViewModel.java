package com.mk.autosecure.viewmodels.setting;

import android.content.Context;

import com.google.gson.Gson;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.bean.UserProfile;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.request.AlterProfileBody;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.ui.activity.settings.UsernameActivity;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 * deprecated
 */

public interface UsernameViewModel {
    interface Inputs {
        void changeUsername(String newUsername);
    }

    interface Outputs {
        Observable<Boolean> changeResult();
    }

    interface Errors {
        Observable<ErrorEnvelope> alterError();

        Observable<Throwable> lowlevelError();
    }

    final class ViewModel extends ActivityViewModel<UsernameActivity> implements Inputs, Outputs, Errors {
        private static final String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            appContext = appComponent.appContext();
            gson = appComponent.gson();
        }

        private final BehaviorSubject<Boolean> changeResult = BehaviorSubject.create();
        private final CurrentUser currentUser;
        private final Context appContext;
        private final Gson gson;

        public final Inputs inputs = this;
        public final Outputs outputs = this;
        public final Errors errors = this;

        private final PublishSubject<ErrorEnvelope> error = PublishSubject.create();
        private PublishSubject<Throwable> llError = PublishSubject.create();

        @Override
        public void changeUsername(String newUsername) {
            AlterProfileBody body = new AlterProfileBody();
            body.displayName = newUsername;

            ApiService.createApiService().alterProfile(body)
                    .subscribeOn(Schedulers.io())
                    .lift(Operators.apiError(gson))
                    .compose(Transformers.pipeApiErrorsTo(error))
                    .compose(Transformers.pipeErrorsTo(llError))
                    .compose(Transformers.neverError())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        Logger.t(TAG).d("alterProfile: " + response.result);
                        if (response.result) {
                            refreshUserInfo(newUsername);
                        }
                        changeResult.onNext(response.result);
                    });
        }

        private void refreshUserInfo(String newDisplayName) {
            User user = currentUser.getUser();
            if (user == null) {
                return;
            }
            User newUser = User.builder()
                    .avatar(user.avatar())
                    .displayName(newDisplayName)
                    .id(user.id())
                    .name(user.name())
                    .verified(user.verified())
                    .build();
            currentUser.refreshUser(newUser);

            UserProfile profile = currentUser.getProfile();
            if (profile != null) {
                profile.displayName = newDisplayName;
                currentUser.refreshProfile(profile);
            }
        }

        @Override
        public Observable<Boolean> changeResult() {
            return changeResult;
        }

        @Override
        public Observable<ErrorEnvelope> alterError() {
            return error;
        }

        @Override
        public Observable<Throwable> lowlevelError() {
            return llError;
        }
    }
}
