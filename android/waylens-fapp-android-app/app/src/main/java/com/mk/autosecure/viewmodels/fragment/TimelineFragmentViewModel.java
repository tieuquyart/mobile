package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.TimelineFragment;
import com.mk.autosecure.libs.account.CurrentUser;

public interface TimelineFragmentViewModel {

    interface Inputs {

    }

    interface Outputs {

    }

    interface Errors {

    }

    final class ViewModel extends FragmentViewModel<TimelineFragment> implements Inputs, Outputs, Errors {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        private final CurrentUser currentUser;

        public CurrentUser getCurrentUser() {
            return currentUser;
        }
    }
}
