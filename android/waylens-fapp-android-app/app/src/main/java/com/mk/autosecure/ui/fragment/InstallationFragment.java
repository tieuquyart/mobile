package com.mk.autosecure.ui.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.mk.autosecure.ui.activity.settings.SetupFleetActivity;
import com.mk.autosecure.ui.activity.settings.WebViewActivity;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.LocalLiveViewModel;
import com.mk.autosecure.viewmodels.fragment.InstallationFragmentViewModel;

import butterknife.ButterKnife;
import butterknife.OnClick;

import static android.app.Activity.RESULT_OK;

@RequiresFragmentViewModel(InstallationFragmentViewModel.ViewModel.class)
public class InstallationFragment extends BaseLazyLoadFragment<InstallationFragmentViewModel.ViewModel> {

    private final static String TAG = InstallationFragment.class.getSimpleName();

    private final static int SETUP_REQUEST_CODE = 2001;

    @OnClick(R.id.tv_installation_guide)
    public void goGuide() {
        WebViewActivity.launch(mActivity, WebViewActivity.PAGE_INSTALLER);
    }

    @OnClick(R.id.btn_start_installation)
    public void goTest() {
        SetupFleetActivity.launchForInstaller(this, SETUP_REQUEST_CODE);
    }

    private Activity mActivity;

    private LocalLiveViewModel.ViewModel parentViewModel;

    public InstallationFragment() {
        // Required empty public constructor
    }

    public static InstallationFragment newInstance() {
        InstallationFragment fragment = new InstallationFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
        if (activity instanceof LocalLiveActivity) {
            parentViewModel = ((LocalLiveActivity) activity).viewModel();
        }
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
        return R.layout.fragment_installation;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).d("onActivityResult: " + requestCode + " " + resultCode);
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && requestCode == SETUP_REQUEST_CODE) {
            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.showPreview(1);
            }
        }
    }
}