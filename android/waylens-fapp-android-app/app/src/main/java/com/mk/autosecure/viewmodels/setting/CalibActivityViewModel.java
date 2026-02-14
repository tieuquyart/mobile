package com.mk.autosecure.viewmodels.setting;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.settings.CalibActivity;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

public interface CalibActivityViewModel {

    interface Inputs {
        void proceed(int index);

        void loading(int visibility);
    }

    interface Outputs {
        Observable<Integer> nextStep();

        Observable<Integer> showLoading();
    }

    final class ViewModel extends ActivityViewModel<CalibActivity> implements Inputs, Outputs {

        public ViewModel(AppComponent component) {
            super(component);
        }

        private final BehaviorSubject<Integer> nextStep = BehaviorSubject.create();
        private final BehaviorSubject<Integer> showLoading = BehaviorSubject.create();

        public final CalibActivityViewModel.Inputs inputs = this;
        public final CalibActivityViewModel.Outputs outputs = this;

        @Override
        public void proceed(int index) {
            nextStep.onNext(index);
        }

        @Override
        public void loading(int visibility) {
            showLoading.onNext(visibility);
        }

        @Override
        public Observable<Integer> nextStep() {
            return nextStep;
        }

        @Override
        public Observable<Integer> showLoading() {
            return showLoading;
        }
    }
}
