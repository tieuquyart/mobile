package com.mk.autosecure.ui.activity.settings;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.viewpager.widget.ViewPager;

import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.ui.fragment.AllVehicleFragment;
import com.mk.autosecure.ui.fragment.FenceAddedFragment;
import com.mk.autosecure.ui.fragment.FenceTrigFragment;
import com.mk.autosecure.ui.fragment.FenceVehicleFragment;
import com.mk.autosecure.ui.fragment.NoVehicleFragment;
import com.mk.autosecure.ui.fragment.TrigVehicleFragment;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

import static com.mk.autosecure.ui.activity.settings.FenceDetailActivity.FENCE_RULE_BEAN;

/**
 * deprecated - doanVT
 * */
@RequiresActivityViewModel(TrigVehicleActivityViewModel.ViewModel.class)
public class TrigVehicleActivity extends BaseActivity<TrigVehicleActivityViewModel.ViewModel> {

    private final static String TAG = TrigVehicleActivity.class.getSimpleName();

//    public static void launch(Context context, FenceListBean listBean) {
//        Intent intent = new Intent(context, TrigVehicleActivity.class);
//        intent.putExtra(FENCE_LIST_BEAN, listBean);
//        context.startActivity(intent);
//    }

    public static void launch(Context context, FenceRuleBean ruleBean) {
        Intent intent = new Intent(context, TrigVehicleActivity.class);
        intent.putExtra(FENCE_RULE_BEAN, ruleBean);
        context.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.vp_vehicle)
    CustomViewPager vpVehicle;

    private MyFragmentStatePagerAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_trig_vehicle);
        ButterKnife.bind(this);

        setupToolbar();
        initView();
    }

    private void setupToolbar() {
        tvToolbarTitle.setText(R.string.triggering_vehicles);
        toolbar.setNavigationOnClickListener(v -> {
            int currentItem = vpVehicle.getCurrentItem();
            if (currentItem > 0) {
                vpVehicle.setCurrentItem(--currentItem, true);
            } else {
                finish();
            }
        });
        toolbar.inflateMenu(R.menu.menu_personnel_edit);
        toolbar.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if (item.getItemId() == R.id.resetPass) {
                    Logger.t(TAG).d("onMenuItemClick");
                    proceed(1);
                }
                return false;
            }
        });
    }

    public void proceed(int next) {
        int currentItem = vpVehicle.getCurrentItem();
        Logger.t(TAG).d("proceed: " + currentItem);
        if (currentItem >= 0 && (currentItem + next) < mAdapter.getCount()) {
            vpVehicle.setCurrentItem(currentItem + next);
        } else {
            finish();
        }
    }

    private void initView() {
//        FenceListBean listBean = (FenceListBean) getIntent().getSerializableExtra(FENCE_LIST_BEAN);
        FenceRuleBean ruleBean = (FenceRuleBean) getIntent().getSerializableExtra(FENCE_RULE_BEAN);

//        if (listBean != null) viewModel.fenceListBean(listBean);
        if (ruleBean != null) viewModel.fenceRuleBean(ruleBean);
//        Logger.t(TAG).d("FenceListBean: " + listBean + " FenceRuleBean: " + ruleBean);
        Logger.t(TAG).d("FenceRuleBean: " + ruleBean);

        mAdapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());

        String fenceScope = "specific";
        if (ruleBean != null) {
            fenceScope = ruleBean.getScope();
        }

        if ("all".equals(fenceScope)) {
            mAdapter.addFragment(AllVehicleFragment.newInstance(viewModel));
        } else {
            if (ruleBean != null) {
                List<String> vehicleList = ruleBean.getVehicleList();
                if (vehicleList != null && vehicleList.size() != 0) {
                    mAdapter.addFragment(TrigVehicleFragment.newInstance(viewModel));
                } else {
                    toolbar.getMenu().clear();
                    mAdapter.addFragment(new NoVehicleFragment());
                }
            } else {
                mAdapter.addFragment(new NoVehicleFragment());
            }
        }

        mAdapter.addFragment(FenceTrigFragment.newInstance(viewModel));
        mAdapter.addFragment(FenceVehicleFragment.newInstance(viewModel));
        mAdapter.addFragment(FenceAddedFragment.newInstance(viewModel));

        vpVehicle.setAdapter(mAdapter);
        vpVehicle.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                Logger.t(TAG).d("onPageSelected: " + position);
                if (position == 0) {
                    toolbar.getMenu().clear();
                    toolbar.inflateMenu(R.menu.menu_personnel_edit);
                } else {
                    toolbar.getMenu().clear();
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }
}
