package com.mk.autosecure.viewmodels;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.fragment.LiveMenuFragment;
import com.mkgroup.camera.CameraWrapper;

import io.reactivex.schedulers.Schedulers;
@SuppressLint("CheckResult")
public interface LiveMenuFragmentViewModel {
    interface Input{
        void currentCamera(CameraWrapper camera);
    }
    interface Output{

    }

    final class ViewModel extends FragmentViewModel<LiveMenuFragment> implements Input, Output{

        private Context mContext;
        private String serialNumber;
        public CameraWrapper mCamera;

        public ViewModel(AppComponent appComponent) {
            super(appComponent);

            mContext = appComponent.appContext();
            arguments()
                    .observeOn(Schedulers.io())
                    .subscribe(bundleOptional -> {
                        Bundle bundle = bundleOptional.getIncludeNull();
                        if (bundle != null) {
                            serialNumber = bundle.getString(IntentKey.SERIAL_NUMBER);
                        }
                    }, new ServerErrorHandler());
        }

        @Override
        public void currentCamera(CameraWrapper camera) {
            mCamera = camera;
        }
    }
}
