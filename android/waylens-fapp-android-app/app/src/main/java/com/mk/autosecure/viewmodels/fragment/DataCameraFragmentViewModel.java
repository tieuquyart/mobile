package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.ui.fragment.DataCameraFragment;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
public interface DataCameraFragmentViewModel {

    interface Inputs {
    }

    interface Outputs {
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();
    }

    final class ViewModel extends FragmentViewModel<DataCameraFragment> implements Inputs, Outputs, Errors {

        private static final String TAG = DataCameraFragmentViewModel.ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }
    }
}
