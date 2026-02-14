package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.SettingBody;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.schedulers.Schedulers;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mkgroup.camera.model.Clip.LENS_UPSIDEDOWN;

@SuppressLint("CheckResult")
public class LensSetupFragment extends RxFragment {

    public final static String TAG = LensSetupFragment.class.getSimpleName();

    @BindView(R.id.rg_lens_install)
    RadioGroup rgLensInstall;

    @BindView(R.id.rb_lens_up)
    RadioButton rbLensUp;

    @BindView(R.id.rb_lens_down)
    RadioButton rbLensDown;

    @BindView(R.id.btn_next)
    Button btnNext;

    @OnClick(R.id.btn_next)
    public void next() {
        Logger.t(TAG).d("next lens: " + isLensNormal);
        if (currentCamera != null) {
            boolean lensNormal = currentCamera.getIsLensNormal();
            if (lensNormal != isLensNormal) {
                currentCamera.setLensNormal(isLensNormal);
            }

            SettingBody body = new SettingBody(
                    new SettingBody.SettingsBean(isLensNormal ? LENS_NORMAL : LENS_UPSIDEDOWN));
            ApiClient.createApiService().uploadRotate(currentCamera.getSerialNumber(), body)
                    .subscribeOn(Schedulers.io())
                    .subscribe(response -> Logger.t(TAG).d("uploadRotate: " + response.result),
                            new ServerErrorHandler(TAG));
        }
        if (parentViewModel != null && parentViewModel.inputs != null) {
            parentViewModel.inputs.proceed(4);
        }
    }

    private SetupActivityViewModel.ViewModel parentViewModel;

    private CameraWrapper currentCamera;

    private boolean isLensNormal;

    public static LensSetupFragment newInstance(SetupActivityViewModel.ViewModel viewModel) {
        LensSetupFragment fragment = new LensSetupFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_lens_setup, container, false);
        ButterKnife.bind(this, view);
        initView();

        return view;
    }

    private void initView() {
        currentCamera = VdtCameraManager.getManager().getCurrentCamera();

        rgLensInstall.setOnCheckedChangeListener((group, checkedId) -> {
            boolean enabled = btnNext.isEnabled();
            if (!enabled) {
                btnNext.setEnabled(true);
            }

            if (checkedId == rbLensUp.getId()) {
                isLensNormal = true;
            } else if (checkedId == rbLensDown.getId()) {
                isLensNormal = false;
            }

            rbLensUp.setTextColor(isLensNormal ?
                    getResources().getColor(R.color.colorAccent) : getResources().getColor(R.color.colorPrimary));
            rbLensDown.setTextColor(isLensNormal ?
                    getResources().getColor(R.color.colorPrimary) : getResources().getColor(R.color.colorAccent));
        });
    }

}
