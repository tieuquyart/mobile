package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.AlertsFragment;
import com.mk.autosecure.libs.account.CurrentUser;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 * deprecated
 */
public interface AlertsFragmentViewModel {

    interface Inputs {
    }

    interface Outputs {
    }

    interface Errors {
    }

    final class ViewModel extends FragmentViewModel<AlertsFragment> implements Inputs, Outputs, Errors {

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
