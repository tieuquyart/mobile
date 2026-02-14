package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;

import java.util.concurrent.TimeUnit;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by DoanVT on 2017/8/25.
 */

public class SecondSetupFragment extends RxFragment {
    public static final String TAG = SecondSetupFragment.class.getSimpleName();

    private static final int WIFI_SETTING = 0;

    public SetupActivityViewModel.ViewModel parentViewModel;

    private Disposable countDownSubscribe;

    private CameraWrapper currentCamera;

    @BindView(R.id.btn_connect)
    Button btnConnect;

    @OnClick(R.id.btn_connect)
    public void onConnectClicked() {
        Logger.t(TAG).d("onConnectClicked: " + inConnected());
        if (inConnected()) {
            proceed();
        } else {
            startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
        }
    }

    @BindString(R.string.setup_meet_problems)
    String stringMeetProblems;

    public static SecondSetupFragment newInstance(SetupActivityViewModel.ViewModel viewModel) {
        SecondSetupFragment fragment = new SecondSetupFragment();
        fragment.parentViewModel = viewModel;
        Bundle bundle = new Bundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_setup_two, container, false);
        ButterKnife.bind(this, v);
        return v;
    }

    @SuppressLint("CheckResult")
    @Override
    public void onResume() {
        super.onResume();

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNewCamera, new ServerErrorHandler());
    }

    private void onNewCamera(Optional<CameraWrapper> cameraOptional) {
        currentCamera = cameraOptional.getIncludeNull();
        Logger.t(TAG).d("onNewCamera: " + currentCamera);
        if (currentCamera != null) {
            btnConnect.setText(R.string.setup_continue);
        } else {
            btnConnect.setText(R.string.setup_second_wifi_setting);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).d("onActivityResult requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == WIFI_SETTING) {
            Logger.t(TAG).d("inHotspotMode: " + NetworkUtils.inHotspotMode() + " inConnected: " + inConnected());
            if (NetworkUtils.inHotspotMode() && inConnected()) {
                proceed();
            } else {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.loading(View.VISIBLE);
                }
                countDown();
            }
        }
    }

    private boolean inConnected() {
        return currentCamera != null;
    }

    private void proceed() {
        if (currentCamera == null) {
            return;
        }

        //判断是否需要dewarp
        boolean needDewarp = currentCamera.getNeedDewarp();
        if (needDewarp) {
            //判断是否支持倒装
            boolean supportUpsidedown = currentCamera.getSupportUpsidedown();
            Logger.t(TAG).d("proceed camera supportUpsidedown: " + supportUpsidedown);
            if (supportUpsidedown) {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.proceed(3);
                }
            } else {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.proceed(4);
                }
            }
        } else {
            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.proceed(4);
            }
        }
    }

    private void countDown() {
        final int time = 10;
        countDownSubscribe = Observable.interval(0, 1, TimeUnit.SECONDS)
                .take(time)
                .map(aLong -> time - aLong)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aLong -> {
                    Logger.t(TAG).d("countDown: " + aLong + " inConnected: " + inConnected());
                    if (inConnected()) {
                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.loading(View.GONE);
                        }
                        unSubscribeCount();
                        proceed();
                    }
                }, throwable -> {
                    Logger.t(TAG).d("onError: " + throwable.getMessage());
                    throwable.printStackTrace();
                }, () -> {
                    Logger.t(TAG).d("onCompleted: ");
                    if (parentViewModel != null && parentViewModel.inputs != null) {
                        parentViewModel.inputs.loading(View.GONE);
                    }
                    unSubscribeCount();
                    Toast.makeText(getContext(), R.string.direct_connect_try_again, Toast.LENGTH_LONG).show();
                });
    }

    private void unSubscribeCount() {
        if (countDownSubscribe != null && !countDownSubscribe.isDisposed()) {
            countDownSubscribe.dispose();
        }
    }

}
