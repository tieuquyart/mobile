package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.ui.fragment.AlbumFragment;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
public interface AlbumFragmentViewModel {

    interface Inputs {
    }

    interface Outputs {
    }

    interface Errors {
    }

    final class ViewModel extends FragmentViewModel<AlbumFragment> implements Inputs, Outputs, Errors {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
        }
    }
}
