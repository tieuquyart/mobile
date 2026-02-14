package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.google.android.libraries.places.api.Places;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceListBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.ui.fragment.FenceAddedFragment;
import com.mk.autosecure.ui.fragment.FenceDrawFragment;
import com.mk.autosecure.ui.fragment.FenceTrigFragment;
import com.mk.autosecure.ui.fragment.FenceTypeFragment;
import com.mk.autosecure.ui.fragment.FenceVehicleFragment;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

import static com.mk.autosecure.ui.activity.settings.FenceDetailActivity.FENCE_LIST_BEAN;
import static com.mk.autosecure.ui.activity.settings.FenceDetailActivity.FENCE_RULE_BEAN;

@RequiresActivityViewModel(AddFenceActivityViewModel.ViewModel.class)
public class AddFenceActivity extends BaseActivity<AddFenceActivityViewModel.ViewModel> {

    private final static String TAG = AddFenceActivity.class.getSimpleName();

    public static void launch(Context context) {
        Intent intent = new Intent(context, AddFenceActivity.class);
        context.startActivity(intent);
    }

    public static void launch(Context context, FenceListBean listBean) {
        Intent intent = new Intent(context, AddFenceActivity.class);
        intent.putExtra(FENCE_LIST_BEAN, listBean);
        context.startActivity(intent);
    }

    public static void launch(Context context, FenceRuleBean ruleBean) {
        Intent intent = new Intent(context, AddFenceActivity.class);
        intent.putExtra(FENCE_RULE_BEAN, ruleBean);
        context.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.vp_fence)
    CustomViewPager vpFence;

    private MyFragmentStatePagerAdapter mFenceAdapter;

    private FenceDrawFragment fenceDrawFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_fence);
        ButterKnife.bind(this);

        setupToolbar();
        initView();
    }

    private void setupToolbar() {
        tvToolbarTitle.setText(R.string.add_new_zone);
        toolbar.setNavigationOnClickListener(v -> {
            int currentItem = vpFence.getCurrentItem();
            if (currentItem > 0 && currentItem < mFenceAdapter.getCount() - 1) {
                vpFence.setCurrentItem(--currentItem, true);
            } else {
                finish();
            }
        });
    }

    @SuppressLint("CheckResult")
    private void initView() {
        FenceListBean listBean = (FenceListBean) getIntent().getSerializableExtra(FENCE_LIST_BEAN);
        FenceRuleBean ruleBean = (FenceRuleBean) getIntent().getSerializableExtra(FENCE_RULE_BEAN);

        if (listBean != null) viewModel.fenceListBean(listBean);
        if (ruleBean != null) viewModel.fenceRuleBean(ruleBean);
        Logger.t(TAG).d("FenceListBean: " + listBean + " FenceRuleBean: " + ruleBean);

        if (!TextUtils.isEmpty(viewModel.fenceID)) {
            tvToolbarTitle.setText(viewModel.fenceName);

            ApiClient.createApiService().getFenceDetail(viewModel.fenceID)
                    .subscribeOn(Schedulers.newThread())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<FenceDetailBean>() {
                        @Override
                        public void accept(FenceDetailBean bean) throws Exception {
                            if (bean != null) viewModel.fenceDetailBean(bean);
                        }
                    }, new Consumer<Throwable>() {
                        @Override
                        public void accept(Throwable throwable) throws Exception {
                            Logger.t(TAG).e("getFenceDetail throwable: " + throwable.getMessage());
                        }
                    });
        }

        // Initialize the SDK
        Places.initialize(getApplicationContext(), "AIzaSyDCVkUYUl_Hi-lL9300a_Xq8em4DsBhNxU");

        mFenceAdapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());

        mFenceAdapter.addFragment(FenceTypeFragment.newInstance(viewModel));

        fenceDrawFragment = FenceDrawFragment.newInstance(viewModel);
        mFenceAdapter.addFragment(fenceDrawFragment);

        mFenceAdapter.addFragment(FenceTrigFragment.newInstance(viewModel));
        mFenceAdapter.addFragment(FenceVehicleFragment.newInstance(viewModel));
        mFenceAdapter.addFragment(FenceAddedFragment.newInstance(viewModel));

        vpFence.setAdapter(mFenceAdapter);
    }

    public void proceed(int next) {
        int currentItem = vpFence.getCurrentItem();
        Logger.t(TAG).d("proceed: " + currentItem);
        if (currentItem >= 0 && (currentItem + next) < mFenceAdapter.getCount()) {
            vpFence.setCurrentItem(currentItem + next);
        } else {
            finish();
        }
    }

    public void setFenceName(String name) {
        if (fenceDrawFragment != null) {
            fenceDrawFragment.setFenceName(name);
        }
    }

    public void setFenceType(FenceType type) {
        if (fenceDrawFragment != null) {
            fenceDrawFragment.setFenceType(type);
        }
    }

    public enum FenceType {
        Circular, Polygonal, Reused
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
    }
}
