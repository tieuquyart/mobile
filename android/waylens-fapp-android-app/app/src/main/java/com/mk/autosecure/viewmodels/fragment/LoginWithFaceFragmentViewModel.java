package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.LoginWithFaceFragment;

public interface LoginWithFaceFragmentViewModel {
    interface Inputs {

    }

    interface Outputs {

    }

    interface Errors {

    }

    final class ViewModel extends FragmentViewModel<LoginWithFaceFragment> implements DoCalibFragmentViewModel.Inputs, DoCalibFragmentViewModel.Outputs, DoCalibFragmentViewModel.Errors {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
        }
    }
}
