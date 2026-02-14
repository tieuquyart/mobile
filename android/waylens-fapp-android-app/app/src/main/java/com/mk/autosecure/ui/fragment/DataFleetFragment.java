package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.view.View;
import android.widget.TextView;

import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.ui.activity.settings.DataUsageActivity;
import com.mk.autosecure.ui.adapter.DataFleetAdapter;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.viewmodels.fragment.DataFleetFragmentViewModel;

import java.text.DecimalFormat;
import java.util.Collections;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

@RequiresFragmentViewModel(DataFleetFragmentViewModel.ViewModel.class)
public class DataFleetFragment extends BaseLazyLoadFragment<DataFleetFragmentViewModel.ViewModel> {

    private final static String TAG = DataFleetFragment.class.getSimpleName();

    @BindView(R.id.refresh_fleet_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.tv_month_total)
    TextView tvMonthTotal;

    @BindView(R.id.tv_expected_charge)
    TextView tvExpectedCharge;

    @BindView(R.id.rv_billing_history)
    RecyclerView rvBillingHistory;

    @OnClick(R.id.ll_this_month)
    public void thisMonth() {
        Logger.t(TAG).d("thisMonth: " + mDataBean);
        DataUsageActivity activity = (DataUsageActivity) getActivity();
        if (activity != null) {
            activity.showDataDetail(mDataBean);
        }
    }

    private DataFleetAdapter fleetAdapter;

    private BillingDataBean mDataBean;

    public static DataFleetFragment newInstance() {
        return new DataFleetFragment();
    }

    @Override
    protected void onFragmentPause() {

    }

    @Override
    protected void onFragmentResume() {
        getBillingData();
    }

    private void getBillingData() {
        refreshLayout.setRefreshing(true);

        viewModel.getNowBillingData();
        viewModel.getHistoryBillingData();
    }

    @Override
    protected void onFragmentFirstVisible() {

    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_data_fleet;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        refreshLayout.setOnRefreshListener(() -> getBillingData());

        rvBillingHistory.setLayoutManager(new LinearLayoutManager(getContext()));
        rvBillingHistory.addItemDecoration(new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL));

        fleetAdapter = new DataFleetAdapter(getContext());
        fleetAdapter.setOperationListener(bean -> {
            Logger.t(TAG).d("onClickItem: " + bean);
            DataUsageActivity activity = (DataUsageActivity) getActivity();
            if (activity != null) {
                activity.showDataDetail(bean);
            }
        });

        rvBillingHistory.setAdapter(fleetAdapter);

        initEvent();
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        viewModel.nowBillingData()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNowBillingData, new ServerErrorHandler(TAG));

        viewModel.historyBillingData()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHistoryBillingData, new ServerErrorHandler(TAG));

        //todo error handle
    }

    private void onNowBillingData(BillingDataBean billingDataBean) {
        Logger.t(TAG).d("onNowBillingData: " + billingDataBean);
        refreshLayout.setRefreshing(false);

        mDataBean = billingDataBean;

        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        tvMonthTotal.setText(decimalFormat.format(billingDataBean.getTotalDataVolumeInMB() / 1024));

        tvExpectedCharge.setText(String.format("$%s", decimalFormat.format(billingDataBean.getTotalCharge())));
    }

    private void onHistoryBillingData(List<BillingDataBean> billingList) {
        Logger.t(TAG).d("onHistoryBillingData: " + billingList.size());
        refreshLayout.setRefreshing(false);

        Collections.sort(billingList, (o1, o2) -> o2.getCycleEndDate() - o1.getCycleEndDate() > 0 ? 1 : -1);

        fleetAdapter.setNewData(billingList);
    }

    public interface OperationListener {
        void onClickItem(BillingDataBean bean);
    }
}
