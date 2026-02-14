package com.mk.autosecure.viewmodels;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.SetupActivity;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/8/25.
 */

public interface SetupActivityViewModel {

    interface Inputs {
        void proceed(int index);

        void loading(int visibility);

        void bindSuccess();
    }

    interface Outputs {

        Observable<Integer> nextStep();

        Observable<Integer> showLoading();
    }

    final class ViewModel extends ActivityViewModel<SetupActivity> implements Inputs, Outputs {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        private CurrentUser currentUser;
        private final BehaviorSubject<Integer> nextStep = BehaviorSubject.create();
        private final BehaviorSubject<Integer> showLoading = BehaviorSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public Observable<Integer> nextStep() {
            return nextStep;
        }

        @Override
        public Observable<Integer> showLoading() {
            return showLoading;
        }

        @Override
        public void proceed(int index) {
            nextStep.onNext(index);
        }

        @Override
        public void loading(int visibility) {
            showLoading.onNext(visibility);
        }

        @Override
        public void bindSuccess() {

        }
    }
}