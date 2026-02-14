package com.mk.autosecure.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.adapter.TrigVehicleAdapter;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.FleetInfo;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.rest_fleet.bean.FenceVehicleBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * A fragment representing a list of Items.
 */
public class TrigVehicleFragment extends Fragment {

    private final static String TAG = TrigVehicleFragment.class.getSimpleName();

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public TrigVehicleFragment() {
    }

    public static TrigVehicleFragment newInstance(TrigVehicleActivityViewModel.ViewModel viewModel) {
        TrigVehicleFragment fragment = new TrigVehicleFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @BindView(R.id.refresh_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_trig_vehicle)
    RecyclerView rvTrigVehicle;

    private Context mContext;
    private TrigVehicleActivityViewModel.ViewModel parentViewModel;
    private List<FenceVehicleBean> fenceVehicleBeans = new ArrayList<>();

    private TrigVehicleAdapter vehicleAdapter;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_trig_vehicle_list, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
    }

    private void initView() {
        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            refreshVehicles();
        });

        rvTrigVehicle.setLayoutManager(new LinearLayoutManager(mContext));
        rvTrigVehicle.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.VERTICAL));
        vehicleAdapter = new TrigVehicleAdapter(R.layout.item_trig_vehicle);
        rvTrigVehicle.setAdapter(vehicleAdapter);

        refreshVehicles();
    }

    private void refreshVehicles() {
        if (parentViewModel != null) {
            FenceRuleBean ruleBean = parentViewModel.ruleBean;
            if (ruleBean != null) {
                List<String> vehicleList = ruleBean.getVehicleList();
                if (vehicleList != null && vehicleList.size() != 0) {
                    Logger.t(TAG).d("fenceVehicleBeans: " + fenceVehicleBeans.size());
                    fenceVehicleBeans.clear();
                    refreshLayout.setRefreshing(true);

                    final FleetInfo fleetInfo = HornApplication.getComponent().fleetInfo();
                    List<VehicleInfoBean> vehicleInfoBeans = fleetInfo.getVehicles();
                    Logger.t(TAG).d("first getVehicles: " + vehicleInfoBeans);
                    if (vehicleInfoBeans == null || vehicleInfoBeans.size() == 0) {
                        new Handler().postDelayed(() -> {
                            List<VehicleInfoBean> vehicles = fleetInfo.getVehicles();
                            Logger.t(TAG).d("second getVehicles: " + vehicles);
                            requestVehicles(vehicles, vehicleList);
                        }, 1500);
                    } else {
                        requestVehicles(vehicleInfoBeans, vehicleList);
                    }
                }
            }
        }
    }

    private void requestVehicles(List<VehicleInfoBean> vehicleInfoBeans, List<String> vehicleList) {
        for (VehicleInfoBean bean : vehicleInfoBeans) {
            for (String vehicleID : vehicleList) {
                if (!TextUtils.isEmpty(vehicleID) && vehicleID.equals(""+bean.getId())) {
                    FenceVehicleBean vehicleBean = new FenceVehicleBean();
                    vehicleBean.vehicleInfoBean = bean;
                    fenceVehicleBeans.add(vehicleBean);
                }
            }
        }
        refreshLayout.setRefreshing(false);
        vehicleAdapter.setDataList(fenceVehicleBeans);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mContext = null;
    }
}
