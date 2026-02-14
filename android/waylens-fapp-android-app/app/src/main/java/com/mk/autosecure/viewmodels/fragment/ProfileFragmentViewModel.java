package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.account.FleetInfo;
import com.mk.autosecure.ui.fragment.ProfileFragment;
import com.mk.autosecure.libs.account.CurrentUser;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
public interface ProfileFragmentViewModel {

    interface Inputs {
    }

    interface Outputs {
    }

    interface Errors {
    }

    final class ViewModel extends FragmentViewModel<ProfileFragment> implements Inputs, Outputs, Errors {

        private final CurrentUser currentUser;

        private final FleetInfo fleetInfo;

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            fleetInfo = appComponent.fleetInfo();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        public FleetInfo getFleetInfo() {
            return fleetInfo;
        }
    }
}
