package com.mk.autosecure.viewmodels;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.LoginActivity;

public interface LoginViewModel {

    final class ViewModel extends ActivityViewModel<LoginActivity>{

        public ViewModel(AppComponent component) {
            super(component);
        }
    }
}
