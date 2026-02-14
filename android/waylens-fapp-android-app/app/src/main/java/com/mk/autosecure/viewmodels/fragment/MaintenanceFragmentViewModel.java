package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.MaintenanceFragment;
import com.mk.autosecure.libs.account.CurrentUser;

public interface MaintenanceFragmentViewModel {

    interface Inputs {
    }

    interface Outputs {
    }

    interface Errors {
    }

    final class ViewModel extends FragmentViewModel<MaintenanceFragment> implements Inputs, Outputs, Errors {

        private final CurrentUser currentUser;

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }
    }
}
