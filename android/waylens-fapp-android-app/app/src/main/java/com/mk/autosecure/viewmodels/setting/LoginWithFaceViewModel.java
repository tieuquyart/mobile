package com.mk.autosecure.viewmodels.setting;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.settings.LoginWithFaceActivity;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

public interface LoginWithFaceViewModel {

    interface Inputs {
        void loading(int visibility);
    }

    interface Outputs {
        Observable<Integer> showLoading();
    }

    final class ViewModel extends ActivityViewModel<LoginWithFaceActivity> implements LoginWithFaceViewModel.Inputs, LoginWithFaceViewModel.Outputs {

        public ViewModel(AppComponent component) {
            super(component);
        }

        private final BehaviorSubject<Integer> showLoading = BehaviorSubject.create();

        public final LoginWithFaceViewModel.Inputs inputs = this;
        public final LoginWithFaceViewModel.Outputs outputs = this;

        @Override
        public void loading(int visibility) {
            showLoading.onNext(visibility);
        }

        @Override
        public Observable<Integer> showLoading() {
            return showLoading;
        }
    }
}
