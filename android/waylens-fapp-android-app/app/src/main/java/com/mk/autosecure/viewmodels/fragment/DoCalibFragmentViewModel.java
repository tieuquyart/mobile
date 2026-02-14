package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.DoCalibFragment;

public interface DoCalibFragmentViewModel {

    interface Inputs {

    }

    interface Outputs {

    }

    interface Errors {

    }

    final class ViewModel extends FragmentViewModel<DoCalibFragment> implements Inputs, Outputs, Errors {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
        }
    }
}
