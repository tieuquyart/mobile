package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import com.mk.autosecure.ui.activity.settings.TrigVehicleActivity;
import com.mk.autosecure.ui.adapter.FenceVehicleAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.FleetInfo;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FenceVehicleBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.request.AddFenceRuleBody;
import com.mk.autosecure.rest_fleet.response.AddFenceRuleResponse;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.functions.Action;
import io.reactivex.functions.Consumer;

import static androidx.recyclerview.widget.RecyclerView.SCROLL_STATE_IDLE;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FenceVehicleFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FenceVehicleFragment extends RxFragment {
    private final static String TAG = FenceVehicleFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    public FenceVehicleFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment FenceVehicleFragment.
     */
    public static FenceVehicleFragment newInstance(AddFenceActivityViewModel.ViewModel viewModel) {
        FenceVehicleFragment fragment = new FenceVehicleFragment();
        fragment.fenceViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public static FenceVehicleFragment newInstance(TrigVehicleActivityViewModel.ViewModel viewModel) {
        FenceVehicleFragment fragment = new FenceVehicleFragment();
        fragment.vehicleViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @BindView(R.id.refresh_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_fence_vehicle)
    RecyclerView rvFenceVehicle;

    @BindView(R.id.cb_select_all)
    CheckBox cbSelectAll;

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_save)
    public void save() {
        Logger.t(TAG).d("save");

        AddFenceRuleBody body = new AddFenceRuleBody();

        if (fenceViewModel != null) {
            body.name = fenceViewModel.fenceName;
            body.fenceID = fenceViewModel.fenceID;
            body.type = fenceViewModel.fenceType;
            body.scope = fenceViewModel.fenceScope;
        } else if (vehicleViewModel != null) {
            body.name = vehicleViewModel.fenceName;
            body.fenceID = vehicleViewModel.fenceID;
            body.type = vehicleViewModel.fenceType;
            body.scope = vehicleViewModel.fenceScope;
        }

        List<String> vehicleIDList = new ArrayList<>();
        Logger.t(TAG).d("fenceVehicleBeans size: " + fenceVehicleBeans.size());
        for (FenceVehicleBean bean : fenceVehicleBeans) {
            if (bean.selected) {
                VehicleInfoBean vehicleInfoBean = bean.vehicleInfoBean;
                if (vehicleInfoBean != null) {
                    vehicleIDList.add(""+vehicleInfoBean.getId());
                }
            }
        }
        Logger.t(TAG).d("vehicleIDList size: " + vehicleIDList.size());
        body.vehicleList = vehicleIDList.toArray(new String[0]);

        if (fenceViewModel != null && fenceViewModel.ruleBean == null) {
            ApiClient.createApiService().addFenceRule(body)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<AddFenceRuleResponse>() {
                        @Override
                        public void accept(AddFenceRuleResponse response) throws Exception {
                            Logger.t(TAG).d("addFenceRule response: " + response);
                        }
                    }, new Consumer<Throwable>() {
                        @Override
                        public void accept(Throwable throwable) throws Exception {
                            Logger.t(TAG).e("addFenceRule throwable: " + throwable.getMessage());
                            Toast.makeText(mActivity, R.string.geo_fence_zone_failed_to_add_please_try_again, Toast.LENGTH_SHORT).show();
                        }
                    }, new Action() {
                        @Override
                        public void run() throws Exception {
                            proceed();
                        }
                    });
        } else if (fenceViewModel != null || (vehicleViewModel != null && vehicleViewModel.ruleBean != null)) {
            String fenceRuleID;
            if (fenceViewModel != null) {
                fenceRuleID = fenceViewModel.ruleBean.getFenceRuleID();
            } else {
                fenceRuleID = vehicleViewModel.ruleBean.getFenceRuleID();
            }
            if (!TextUtils.isEmpty(fenceRuleID)) {
                ApiClient.createApiService().editFenceRule(fenceRuleID, body)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(new Consumer<BooleanResponse>() {
                            @Override
                            public void accept(BooleanResponse response) throws Exception {
                                Logger.t(TAG).d("editFenceRule response: " + response);
                            }
                        }, new Consumer<Throwable>() {
                            @Override
                            public void accept(Throwable throwable) throws Exception {
                                Logger.t(TAG).e("editFenceRule throwable: " + throwable.getMessage());
                                Toast.makeText(mActivity, "editFenceRule error: " + throwable.getMessage(), Toast.LENGTH_SHORT).show();
                            }
                        }, new Action() {
                            @Override
                            public void run() throws Exception {
                                proceed();
                            }
                        });
            }
        }
    }

    private void proceed() {
        if (mActivity != null) {
            if (mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).proceed(1);
            } else if (mActivity instanceof TrigVehicleActivity) {
                ((TrigVehicleActivity) mActivity).proceed(1);
            }
        }
    }

    private Activity mActivity;
    private AddFenceActivityViewModel.ViewModel fenceViewModel;
    private TrigVehicleActivityViewModel.ViewModel vehicleViewModel;

    private List<FenceVehicleBean> fenceVehicleBeans = new ArrayList<>();
    private FenceVehicleAdapter vehicleAdapter;
    private List<String> vehicleList = null;

    @Override
    public void onAttach(@NonNull Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_fence_vehicle, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
    }

    private void initView() {
        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            refreshVehicles();
        });

        rvFenceVehicle.setLayoutManager(new LinearLayoutManager(mActivity));
        rvFenceVehicle.addItemDecoration(new DividerItemDecoration(mActivity, DividerItemDecoration.VERTICAL));
        vehicleAdapter = new FenceVehicleAdapter(R.layout.item_fence_vehicle);
        vehicleAdapter.setOperationListener(new VehicleOperationListener() {
            @Override
            public void onClickItem(FenceVehicleBean bean) {
                Logger.t(TAG).d("onClickItem: " + bean);
            }

            @Override
            public void onCheckedChanged() {
                int scrollState = rvFenceVehicle.getScrollState();
                Logger.t(TAG).d("onCheckedChanged scrollState: " + scrollState);

                if (scrollState == SCROLL_STATE_IDLE) {
                    List<FenceVehicleBean> dataList = vehicleAdapter.getDataList();
                    setAllCheck(dataList);
                }
            }
        });
        rvFenceVehicle.setAdapter(vehicleAdapter);

//        rvFenceVehicle.addOnScrollListener(new RecyclerView.OnScrollListener() {
//            @Override
//            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
//                super.onScrollStateChanged(recyclerView, newState);
//                //避免rv滑动时holder复用，导致回调onCheckedChanged，最后使isCheckedForUser置为false
//                Logger.t(TAG).d("onScrollStateChanged: " + newState);
//                if (newState == SCROLL_STATE_IDLE) {
//                    isCheckedForUser = true;
//                }
//            }
//        });

        if (fenceViewModel != null && fenceViewModel.ruleBean != null) {
            vehicleList = fenceViewModel.ruleBean.getVehicleList();
        } else if (vehicleViewModel != null && vehicleViewModel.ruleBean != null) {
            vehicleList = vehicleViewModel.ruleBean.getVehicleList();
        }
        Logger.t(TAG).d("vehicleList: " + vehicleList);

        refreshVehicles();

        cbSelectAll.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).d("onCheckedChanged isCheckedForUser: " + isCheckedForUser);
            if (isCheckedForUser) {
                for (FenceVehicleBean bean : fenceVehicleBeans) {
                    bean.selected = isChecked;
                }
                vehicleAdapter.setDataList(fenceVehicleBeans);
            } else {
                isCheckedForUser = true;
            }
        });
    }

    private void refreshVehicles() {
        refreshLayout.setRefreshing(true);

        FleetInfo fleetInfo = HornApplication.getComponent().fleetInfo();
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

        if (vehicleList != null) {
            Logger.t(TAG).d("select all checked: " + vehicleList.size() + " " + vehicleInfoBeans.size());
            if (vehicleList.size() != 0 && vehicleList.size() == vehicleInfoBeans.size()) {
                cbSelectAll.setChecked(true);
            }
        }
    }

    private void requestVehicles(List<VehicleInfoBean> vehicleInfoBeans, List<String> vehicleList) {
        for (VehicleInfoBean bean : vehicleInfoBeans) {
            FenceVehicleBean vehicleBean = new FenceVehicleBean();
            vehicleBean.vehicleInfoBean = bean;
            vehicleBean.selected = false;
            if (vehicleList != null && vehicleList.size() != 0) {
                for (String vehicleID : vehicleList) {
                    if (!TextUtils.isEmpty(vehicleID) && vehicleID.equals(""+bean.getId())) {
                        vehicleBean.selected = true;
                        break;
                    }
                }
            }
            fenceVehicleBeans.add(vehicleBean);
        }
        refreshLayout.setRefreshing(false);
        vehicleAdapter.setDataList(fenceVehicleBeans);
    }

    private boolean isCheckedForUser = true;

    private void setAllCheck(List<FenceVehicleBean> vehicleBeanList) {
        Logger.t(TAG).d("setAllCheck: " + vehicleBeanList + " " + (vehicleBeanList == fenceVehicleBeans));
        if (vehicleBeanList == null || vehicleBeanList.size() == 0) {
            return;
        }

        boolean allCheck = true;
        for (FenceVehicleBean vehicleBean : vehicleBeanList) {
            if (!vehicleBean.selected) {
                allCheck = false;
                break;
            }
        }
        if (cbSelectAll.isChecked() != allCheck) {
            isCheckedForUser = false;
            cbSelectAll.setChecked(allCheck);
        }
    }

    public interface VehicleOperationListener {
        void onClickItem(FenceVehicleBean bean);

        void onCheckedChanged();
    }
}
