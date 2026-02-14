package com.mk.autosecure.ui.fragment;

import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.mk.autosecure.ui.adapter.MyFragmentPagerAdapter;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.fragment.DashboardFragmentViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@RequiresFragmentViewModel(DashboardFragmentViewModel.ViewModel.class)
public class DashBoardFragment extends BaseLazyLoadFragment<DashboardFragmentViewModel.ViewModel> {

    private final static String TAG = DashBoardFragment.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.iv_back)
    ImageView ivBack;

    @BindView(R.id.vp_dashboard)
    CustomViewPager vpDashboard;

    @OnClick(R.id.iv_back)
    public void back() {
        int currentItem = vpDashboard.getCurrentItem();
        if (currentItem == 1) {
            LocalLiveActivity liveActivity = (LocalLiveActivity) getActivity();
            if (liveActivity != null) {
                liveActivity.showOrHideNavigation(View.VISIBLE);
            }

            setTitle();
            ivBack.setVisibility(View.INVISIBLE);
            vpDashboard.setCurrentItem(0, true);
        }
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_dashboard;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        UserLogin fleetUser = viewModel.getCurrentUser().getUserLogin();
        if (fleetUser != null) {
            userName = fleetUser.getUserName();
        }

        initView();
    }

    private DashDriverFragment driverFragment;

    private String userName;

    private void initView() {
        setTitle();

        MyFragmentPagerAdapter adapter = new MyFragmentPagerAdapter(getChildFragmentManager());
        adapter.addFragment(DashFleetFragment.newInstance());

        driverFragment = DashDriverFragment.newInstance();
        adapter.addFragment(driverFragment);

        vpDashboard.setAdapter(adapter);
    }

    private void setTitle() {
//        if (!TextUtils.isEmpty(userName)) {
//            tvToolbarTitle.setText(String.format("%s's Fleet", userName));
//        } else {
            tvToolbarTitle.setText(R.string.dashboard);
//        }
    }

    /**
     * @param fromDateTime UTC
     * @param toDateTime   UTC
     */
    void showDriverDash(int driverID, String cameraSn, long fromDateTime, long toDateTime, String driverName, String plateNumber) {
        LocalLiveActivity liveActivity = (LocalLiveActivity) getActivity();
        if (liveActivity != null) {
            liveActivity.showOrHideNavigation(View.GONE);
        }

        driverFragment.setArgs(driverID, cameraSn, fromDateTime, toDateTime, driverName, plateNumber);
        tvToolbarTitle.setText(driverName);
        ivBack.setVisibility(View.VISIBLE);
        vpDashboard.setCurrentItem(1, true);
    }

    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
        Logger.t(TAG).d("onFragmentResume");
    }

    @Override
    protected void onFragmentFirstVisible() {
    }
}
