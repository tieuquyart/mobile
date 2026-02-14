package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.AdasCfgActivity;
import com.mk.autosecure.ui.activity.settings.CalibActivity;
import com.mk.autosecure.ui.activity.settings.DirectTestActivity;
import com.mk.autosecure.ui.activity.settings.FeedbackActivity;
import com.mk.autosecure.ui.activity.settings.NetworkTestActivity;
import com.mk.autosecure.ui.activity.settings.SpaceInfoActivity;
import com.mk.autosecure.ui.activity.settings.VersionCheckActivity;
import com.mk.autosecure.ui.activity.settings.WebViewActivity;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.AdasCfgChangeEvent;
import com.mkgroup.camera.message.bean.AdasCfgInfo;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.viewmodels.fragment.MaintenanceFragmentViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

@RequiresFragmentViewModel(MaintenanceFragmentViewModel.ViewModel.class)
public class MaintenanceFragment extends BaseLazyLoadFragment<MaintenanceFragmentViewModel.ViewModel> {

    private static final String TAG = MaintenanceFragment.class.getSimpleName();

    @BindView(R.id.ll_sd_card)
    LinearLayout llSdcard;

    @BindView(R.id.ll_calib_camera)
    LinearLayout llCalibCamera;

    @BindView(R.id.ll_adas_settings)
    LinearLayout llAdasSettings;

    @BindView(R.id.btn_logout)
    Button btnLogout;

    @OnClick(R.id.ll_network)
    public void goNetwork() {
        NetworkTestActivity.launch(mActivity, false);
    }

    @OnClick(R.id.ll_power_cord)
    public void goPowerCord() {
        DirectTestActivity.launch(mActivity, false);
    }

    @OnClick(R.id.ll_calib_camera)
    public void goCalibCamera() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);

        if (currentCamera == null) {
            Toast.makeText(mActivity, R.string.setting_request, Toast.LENGTH_LONG).show();
            return;
        }

        Logger.t(TAG).i("isCalibCameraAvailable hardwareName = " + currentCamera.getHardwareName()
                + " apiVersion = " + currentCamera.getApiVersion());

        if (!currentCamera.isCalibCameraAvailable()) {
            Toast.makeText(mActivity, R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
            return;
        }

        CalibActivity.launch(mActivity, false);
    }

    @OnClick(R.id.ll_adas_settings)
    public void goAdasSettings() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);

        if (currentCamera == null) {
            Toast.makeText(mActivity, R.string.setting_request, Toast.LENGTH_LONG).show();
            return;
        }

        Logger.t(TAG).i("goAdasSettings isAdasCfgAvailable = " + currentCamera.isAdasCfgAvailable());

        if (!currentCamera.isAdasCfgAvailable()) {
            Toast.makeText(mActivity, R.string.network_fw_prompt, Toast.LENGTH_LONG).show();
            return;
        }

        AdasCfgActivity.launch(mActivity);
    }

    @OnClick(R.id.ll_sd_card)
    public void goSdcard() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);
        if (currentCamera != null) {
            SpaceInfoActivity.launch(mActivity, false);
        }
    }

    @OnClick(R.id.ll_report_issue)
    public void goReportIssue() {
        FeedbackActivity.launch(mActivity);
    }

    @OnClick(R.id.ll_faq)
    public void goFaq() {
        WebViewActivity.launch(mActivity, WebViewActivity.PAGE_FAQ);
    }

    @OnClick(R.id.ll_about)
    public void goAbout() {
        VersionCheckActivity.launch(mActivity);
    }

    @OnClick(R.id.btn_logout)
    public void logout() {
        if (viewModel.getCurrentUser().exists()) {
            DialogHelper.showLogoutConfirmDialog(mActivity,
                    () -> {
                        viewModel.getCurrentUser().logout();
                        LoginActivity.launchClearTask(mActivity);
                    });
        } else {
            LoginActivity.launchClearTask(mActivity);
        }
    }

    private Activity mActivity;

    public MaintenanceFragment() {
        // Required empty public constructor
    }

    public static MaintenanceFragment newInstance() {
        MaintenanceFragment fragment = new MaintenanceFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
    }

    @Override
    protected void onFragmentPause() {

    }

    @Override
    protected void onFragmentResume() {

    }

    @Override
    protected void onFragmentFirstVisible() {

    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_maintenance;
    }

    @SuppressLint("CheckResult")
    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        boolean exists = viewModel.getCurrentUser().exists();
        btnLogout.setText(exists ? R.string.setting_item_log_out : R.string.log_in);

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(AdasCfgChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAdasCfgChange, new ServerErrorHandler(TAG));
    }

    private void onAdasCfgChange(AdasCfgChangeEvent event) {
        AdasCfgInfo adasCfgInfo = event.getAdasCfgInfo();
        Logger.t(TAG).d("onAdasCfgChange: " + adasCfgInfo);
        llAdasSettings.setVisibility(View.VISIBLE);
    }

    private void onCurrentCamera(Optional<CameraWrapper> vdtCameraOptional) {
        CameraWrapper cameraWrapper = vdtCameraOptional.getIncludeNull();
        Logger.t(TAG).d("onCurrentCamera: " + cameraWrapper);
        llSdcard.setVisibility(cameraWrapper == null ? View.GONE : View.VISIBLE);
        llCalibCamera.setVisibility(cameraWrapper == null ? View.GONE : View.VISIBLE);
        if (cameraWrapper != null && cameraWrapper.isAdasCfgAvailable()) {
            if (cameraWrapper instanceof EvCamera) {
                AdasCfgInfo adasCfgInfo = ((EvCamera) cameraWrapper).getAdasCfgInfo();
                Logger.t(TAG).i("isAdasCfgAvailable adasCfgInfo = " + adasCfgInfo);
                if (adasCfgInfo != null) {
                    llAdasSettings.setVisibility(View.VISIBLE);
                } else {
                    llAdasSettings.setVisibility(View.GONE);
                }
            }
        } else {
            llAdasSettings.setVisibility(View.GONE);
        }
    }
}