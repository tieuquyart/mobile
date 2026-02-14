package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.DataCleanManager;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.AlbumActivity;
import com.mk.autosecure.ui.activity.SettingActivity;
import com.mk.autosecure.ui.activity.settings.AlertSettingsActivity;
import com.mk.autosecure.ui.activity.settings.FeedbackActivity;
import com.mk.autosecure.ui.activity.settings.VersionCheckActivity;
import com.mk.autosecure.viewmodels.fragment.ProfileFragmentViewModel;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.Logger;

import java.lang.ref.SoftReference;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

@RequiresFragmentViewModel(ProfileFragmentViewModel.ViewModel.class)
public class AccountSettingFragment extends BaseLazyLoadFragment<ProfileFragmentViewModel.ViewModel> {
    private final static String TAG = AccountSettingFragment.class.getSimpleName();


    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @OnClick(R.id.ll_about_fleet)
    public void onAboutClicked() {
        VersionCheckActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_clean_cache_fleet)
    public void onCleanCacheClicked() {
        DialogHelper.showCleanCacheDialog(getActivity(), () -> {
            DataCleanManager.clearAllCache(getActivity());
            Toast.makeText(getActivity(), R.string.cache_cleaned, Toast.LENGTH_SHORT).show();
        });
    }

    @OnClick(R.id.ll_alert_settings)
    public void onAlertSettings() {
        AlertSettingsActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_report_issue_fleet)
    public void onReport() {
        FeedbackActivity.launch(getActivity());
    }

    @OnClick(R.id.ll_settings_fleet)
    public void setting() {
        SettingActivity.launch(getActivity());
    }

    @SuppressLint("CheckResult")
    @OnClick( R.id.ll_shop_fleet)
    public void shop() {
//        String BASE_URL = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServer[webServer.length - 1]);
//        Uri uri = Uri.parse(BASE_URL + "/shop/360?from=android");
//        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
//        startActivity(intent);
        Logger.e("click onShop");
        Toast.makeText(getActivity(),getString( R.string.no_func), Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @OnClick(R.id.ll_album)
    void onAlbum() {
        AlbumActivity.launch(getActivity());
    }


    private SoftReference<Activity> mActivitySoft;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivitySoft = new SoftReference<>(activity);
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_account_setting;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);
        initToolbar();
    }

    private void initToolbar(){
        toolbar.setNavigationOnClickListener(v->getActivity().finish());
        tvToolbarTitle.setText(getString(R.string.settings));
    }


    private CameraWrapper mCamera;


    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
    }

    @Override
    protected void onFragmentFirstVisible() {
    }

}
