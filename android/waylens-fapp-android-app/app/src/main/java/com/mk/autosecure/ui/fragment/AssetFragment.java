package com.mk.autosecure.ui.fragment;

import static android.app.Activity.RESULT_OK;
import static com.mk.autosecure.ui.activity.settings.PersonnelEditActivity.REQUEST_CODE_DEVICE;
import static com.mk.autosecure.ui.activity.settings.PersonnelEditActivity.REQUEST_CODE_DRIVER;
import static com.mk.autosecure.ui.data.IntentKey.RELOAD_LIST;
import static com.mkgroup.camera.bean.FleetCameraBean.ACTIVATED;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.response.ActivateResponse;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.AddCameraActivity;
import com.mk.autosecure.ui.activity.settings.AddVehicleActivity;
import com.mk.autosecure.ui.activity.settings.AssetDeviceEditActivity;
import com.mk.autosecure.ui.activity.settings.AssetDriverInfoActivity;
import com.mk.autosecure.ui.activity.settings.AssetVehicleEditActivity;
import com.mk.autosecure.ui.activity.settings.DriverActivity;
import com.mk.autosecure.ui.activity.settings.PersonnelEditActivity;
import com.mk.autosecure.ui.adapter.AssetDevicesAdapter;
import com.mk.autosecure.ui.adapter.AssetDriverAdapter;
import com.mk.autosecure.ui.adapter.AssetVehiclesAdapter;
import com.mk.autosecure.ui.fragment.interfaces.DevicesOperationListener;
import com.mk.autosecure.ui.fragment.interfaces.DriverOperationListener;
import com.mk.autosecure.ui.fragment.interfaces.VehiclesOperationListener;
import com.mk.autosecure.ui.view.WrapContentGridLayoutManager;
import com.mk.autosecure.viewmodels.fragment.AssetFragmentViewModel;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.ObservableSource;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Action;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;

@RequiresFragmentViewModel(AssetFragmentViewModel.ViewModel.class)
@SuppressLint({"ClickableViewAccessibility", "CheckResult", "RestrictedApi", "NotifyDataSetChanged", "NonConstantResourceId"})
public class AssetFragment extends BaseLazyLoadFragment<AssetFragmentViewModel.ViewModel> implements VehiclesOperationListener, DevicesOperationListener, DriverOperationListener {

    private final static String TAG = AssetFragment.class.getSimpleName();

    private static final String ARG_COLUMN_COUNT = "column-count";
    private static final String ARG_ASSET_INDEX = "asset-index";
    private int mColumnCount = 1;
    private int mAssetIndex = 0;
    private int currentPage = 1;
    private int totalPage = 1;
    private boolean isLoading = false;
    List<FleetCameraBean> cameraBeanList = new ArrayList<>();
    List<DriverInfoBean> driverInfoBeanList = new ArrayList<>();
    List<VehicleInfoBean> vehicleInfoBeanList = new ArrayList<>();

    LinearLayoutManager linearLayoutManager;
    GridLayoutManager gridLayoutManager;

    @BindView(R.id.list)
    RecyclerView recyclerView;

    @BindView(R.id.pullToRefresh)
    SwipeRefreshLayout pullToRefresh;

//    @BindView(R.id.nestedSV)
//    NestedScrollView nestedSV;


    @BindView(R.id.inputSearch)
    EditText inputSearch;

    private AssetVehiclesAdapter vehiclesAdapter;

    private AssetDevicesAdapter devicesAdapter;

    private AssetDriverAdapter driverAdapter;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public AssetFragment() {
    }

    @SuppressWarnings("unused")
    public static AssetFragment newInstance(int columnCount, int index) {
        AssetFragment fragment = new AssetFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_COLUMN_COUNT, columnCount);
        args.putInt(ARG_ASSET_INDEX, index);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments() != null) {
            mColumnCount = getArguments().getInt(ARG_COLUMN_COUNT);
            mAssetIndex = getArguments().getInt(ARG_ASSET_INDEX);
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
        return R.layout.fragment_asset;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void initView(View rootView) {
        Context context = rootView.getContext();

        ButterKnife.bind(this, rootView);

        recyclerView.setHasFixedSize(true);
        if (mColumnCount <= 1) {
            recyclerView.setLayoutManager(new LinearLayoutManager(context));
            linearLayoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
        } else {
            recyclerView.setLayoutManager(new WrapContentGridLayoutManager(context, mColumnCount));
            gridLayoutManager = (GridLayoutManager) recyclerView.getLayoutManager();
        }


        currentPage = 1;
        totalPage = 1;

        requestAsset();
        initAdapter();
//        initEvent();
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(receiver, new IntentFilter(RELOAD_LIST));

        inputSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                if (mAssetIndex == 0) {
                    vehiclesAdapter.getFilter().filter(charSequence);
                } else if (mAssetIndex == 1) {
                    devicesAdapter.getFilter().filter(charSequence);
                } else if (mAssetIndex == 2) {
                    driverAdapter.getFilter().filter(charSequence);
                }
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

        pullToRefresh.setOnRefreshListener(this::requestAsset);

        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
            }

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                int totalItemCount = 0;
                int lastVisibleItemPOs = 0;
                if (mColumnCount <= 1) {
                    assert linearLayoutManager != null;
                    totalItemCount = linearLayoutManager.getItemCount();
                    lastVisibleItemPOs = linearLayoutManager.findLastVisibleItemPosition();
                } else {
                    assert gridLayoutManager != null;
                    totalItemCount = gridLayoutManager.getItemCount();
                    lastVisibleItemPOs = gridLayoutManager.findLastVisibleItemPosition();
                }
                Logger.t(TAG).d("doanvt -- totalItemCount: " + totalItemCount + " lastVisibleItemPos: " + lastVisibleItemPOs);
                if (!isLoading && totalItemCount <= lastVisibleItemPOs + 5) {
                    if (currentPage < totalPage) {
                        currentPage += 1;
                        requestAsset(currentPage);
                    }
                }
            }
        });
    }

    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            requestAsset();
        }
    };

    @OnClick(R.id.btnAdd)
    public void addNew() {
        switch (mAssetIndex) {

        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(receiver);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(receiver);
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        viewModel.getFleetInfo().vehicleObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVehicleList, new ServerErrorHandler(TAG));

        viewModel.getFleetInfo().deviceObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDeviceList, new ServerErrorHandler(TAG));

        viewModel.getFleetInfo().driverObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDriverList, new ServerErrorHandler(TAG));
    }

    private void onDeviceList(Optional<List<FleetCameraBean>> listOptional) {
        List<FleetCameraBean> cameraBeans = listOptional.getIncludeNull();
//        currentPage = 1;
//        totalPage = 1;
        exitLoadStatus("");
        cameraBeanList.clear();
        if (cameraBeans != null && cameraBeans.size() != 0) {
            Logger.t(TAG).d("onDeviceList: " + cameraBeans.size());
            cameraBeanList.addAll(cameraBeans);
            if (devicesAdapter != null) devicesAdapter.notifyDataSetChanged();
        }
    }

    private void onDriverList(Optional<List<DriverInfoBean>> listOptional) {
        List<DriverInfoBean> driverInfoBeans = listOptional.getIncludeNull();
//        currentPage = 1;
//        totalPage = 1;
        exitLoadStatus("");
        driverInfoBeanList.clear();
        if (driverInfoBeans != null && driverInfoBeans.size() != 0) {
            Logger.t(TAG).d("onDriverList: " + driverInfoBeans.size());
            driverInfoBeanList.addAll(driverInfoBeans);
            if (driverAdapter != null) driverAdapter.notifyDataSetChanged();
        }
    }

    private void onVehicleList(Optional<List<VehicleInfoBean>> listOptional) {
        List<VehicleInfoBean> vehicleInfoBeans = listOptional.getIncludeNull();
//        currentPage = 1;
//        totalPage = 1;
        exitLoadStatus("");
        vehicleInfoBeanList.clear();
        if (vehicleInfoBeans != null && vehicleInfoBeans.size() != 0) {
            Logger.t(TAG).d("onVehicleList: " + vehicleInfoBeans.size());
            vehicleInfoBeanList.addAll(vehicleInfoBeans);
            if (vehiclesAdapter != null) vehiclesAdapter.notifyDataSetChanged();
        }
    }

    private void enterLoadStatus(boolean isLoadMore) {
        isLoading = true;
        pullToRefresh.setRefreshing(true);
        recyclerView.setVisibility(isLoadMore ? View.VISIBLE : View.GONE);
    }

    private void exitLoadStatus(String msg) {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                isLoading = false;
                pullToRefresh.setRefreshing(false);
                recyclerView.setVisibility(View.VISIBLE);
                if (!StringUtils.isEmpty(msg))
                    Toast.makeText(getActivity(), msg, Toast.LENGTH_SHORT).show();
            }
        }, 500);
    }

    private void initAdapter() {
        if (mAssetIndex == 0) {
            vehiclesAdapter = new AssetVehiclesAdapter(getContext());
            recyclerView.setAdapter(vehiclesAdapter);
            vehiclesAdapter.setOperationListener(this);
        } else if (mAssetIndex == 2) {
            driverAdapter = new AssetDriverAdapter(getContext());
            recyclerView.setAdapter(driverAdapter);
            driverAdapter.setOperationListener(this);
        } else if (mAssetIndex == 1) {
            devicesAdapter = new AssetDevicesAdapter(getContext());
            recyclerView.setAdapter(devicesAdapter);
            devicesAdapter.setOperationListener(this);
        }
    }


    private void requestAsset() {
        Logger.t(TAG).d("doanvt -- requestFirst: " + mAssetIndex);
        enterLoadStatus(false);
        currentPage = 1;
        totalPage = 1;
        if (mAssetIndex == 0) {
            ApiClient.createApiService().getVehiclePage(1, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(vehicleInfoResponse -> {
                        if (vehicleInfoResponse.isSuccess()) {
                            List<VehicleInfoBean> vehicleInfos = vehicleInfoResponse.getData().getRecords();
                            if (vehicleInfos != null && vehicleInfos.size() != 0) {
                                vehicleInfoBeanList = vehicleInfos;
                                totalPage = vehicleInfoResponse.getData().getPages();
                                if (vehiclesAdapter != null)
                                    vehiclesAdapter.setDataMK(vehicleInfoBeanList);
                                if (vehicleInfoBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshVehicles(vehicleInfoBeanList);
                                } else {
                                    List<VehicleInfoBean> refList = new ArrayList<>(vehicleInfoBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshVehicles(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), vehicleInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getVehicleInfoList throwable: " + throwable.getMessage());
                    });
        } else if (mAssetIndex == 2) {
            ApiClient.createApiService().getDriverPageInfo(1, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(driverInfoResponse -> {
                        if (driverInfoResponse.isSuccess()) {
                            List<DriverInfoBean> driverInfoBeans = driverInfoResponse.getData().getRecords();
                            if (driverInfoBeans != null && driverInfoBeans.size() != 0) {
                                driverInfoBeanList = driverInfoBeans;
                                totalPage = driverInfoResponse.getData().getPages();
                                if (driverAdapter != null)
                                    driverAdapter.setDataMK(driverInfoBeanList);
                                viewModel.getFleetInfo().refreshDrivers(driverInfoBeanList);
                                if (driverInfoBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshDrivers(driverInfoBeanList);
                                } else {
                                    List<DriverInfoBean> refList = new ArrayList<>(driverInfoBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshDrivers(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), driverInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getDriverInfoList throwable: " + throwable.getMessage());
                    });
        } else if (mAssetIndex == 1) {
            ApiClient.createApiService().getDevicePageInfo(1, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(deviceInfoResponse -> {
                        if (deviceInfoResponse.isSuccess()) {
                            List<FleetCameraBean> cameraInfos = deviceInfoResponse.getData().getRecords();
                            if (cameraInfos != null && cameraInfos.size() != 0) {
                                cameraBeanList = cameraInfos;
                                totalPage = deviceInfoResponse.getData().getPages();
                                if (devicesAdapter != null)
                                    devicesAdapter.setDataMK(cameraBeanList);
                                viewModel.getFleetInfo().refreshDevices(cameraBeanList);
                                if (cameraBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshDevices(cameraBeanList);
                                } else {
                                    List<FleetCameraBean> refList = new ArrayList<>(cameraBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshDevices(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), deviceInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getDeviceInfoList throwable: " + throwable.getMessage());
                    });
        }
    }

    private void requestAsset(int index) {
        enterLoadStatus(true);
        if (mAssetIndex == 0) {
            vehicleInfoBeanList.add(null);
            recyclerView.post(() -> vehiclesAdapter.notifyItemInserted(vehicleInfoBeanList.size() - 1));
            ApiClient.createApiService().getVehiclePage(index, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(vehicleInfoResponse -> {
                        if (vehicleInfoResponse.isSuccess()) {
                            List<VehicleInfoBean> vehicleInfos = vehicleInfoResponse.getData().getRecords();
                            if (vehicleInfos != null && vehicleInfos.size() != 0) {
                                totalPage = vehicleInfoResponse.getData().getPages();
                                vehicleInfoBeanList.remove(vehicleInfoBeanList.size() - 1);
                                int scrollPosition = vehicleInfoBeanList.size();
                                vehiclesAdapter.notifyItemRemoved(scrollPosition);
                                vehicleInfoBeanList.addAll(vehicleInfos);
                                vehiclesAdapter.notifyDataSetChanged();
                                if (vehicleInfoBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshVehicles(vehicleInfoBeanList);
                                } else {
                                    List<VehicleInfoBean> refList = new ArrayList<>(vehicleInfoBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshVehicles(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), vehicleInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getVehicleInfoList throwable: " + throwable.getMessage());
                    });
        } else if (mAssetIndex == 2) {
            driverInfoBeanList.add(null);
            recyclerView.post(() -> driverAdapter.notifyItemInserted(driverInfoBeanList.size() - 1));
            ApiClient.createApiService().getDriverPageInfo(index, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(driverInfoResponse -> {
                        if (driverInfoResponse.isSuccess()) {
                            List<DriverInfoBean> driverInfoBeans = driverInfoResponse.getData().getRecords();
                            if (driverInfoBeans != null && driverInfoBeans.size() != 0) {
                                driverInfoBeanList.remove(driverInfoBeanList.size() - 1);
                                int scrollPosition = driverInfoBeanList.size();
                                driverAdapter.notifyItemRemoved(scrollPosition);
                                driverInfoBeanList.addAll(driverInfoBeans);
                                totalPage = driverInfoResponse.getData().getPages();
                                driverAdapter.notifyDataSetChanged();
                                if (driverInfoBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshDrivers(driverInfoBeanList);
                                } else {
                                    List<DriverInfoBean> refList = new ArrayList<>(driverInfoBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshDrivers(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), driverInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getDriverInfoList throwable: " + throwable.getMessage());
                    });
        } else if (mAssetIndex == 1) {
            cameraBeanList.add(null);
            recyclerView.post(() -> devicesAdapter.notifyItemInserted(cameraBeanList.size() - 1));
            ApiClient.createApiService().getDevicePageInfo(index, 14, HornApplication.getComponent().currentUser().getAccessToken())
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(deviceInfoResponse -> {
                        if (deviceInfoResponse.isSuccess()) {
                            List<FleetCameraBean> cameraInfos = deviceInfoResponse.getData().getRecords();
                            if (cameraInfos != null && cameraInfos.size() != 0) {
                                cameraBeanList.remove(cameraBeanList.size() - 1);
                                int scrollPosition = cameraBeanList.size();
                                devicesAdapter.notifyItemRemoved(scrollPosition);
                                cameraBeanList.addAll(cameraInfos);
                                totalPage = deviceInfoResponse.getData().getPages();
                                devicesAdapter.notifyDataSetChanged();
                                if (cameraBeanList.get(0) != null) {
                                    viewModel.getFleetInfo().refreshDevices(cameraBeanList);
                                } else {
                                    List<FleetCameraBean> refList = new ArrayList<>(cameraBeanList);
                                    refList.remove(0);
                                    viewModel.getFleetInfo().refreshDevices(refList);
                                }
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(getActivity(), deviceInfoResponse);
                        }
                        exitLoadStatus("");
                    }, throwable -> {
                        exitLoadStatus(throwable.getMessage());
                        Logger.t(TAG).e("getDeviceInfoList throwable: " + throwable.getMessage());
                    });
        }
    }

    @Override
    public void onClickVehicleItem(VehicleInfoBean bean, View view) {
        Logger.t(TAG).d("onClickItem VehicleInfoBean: " + bean);
        DialogHelper.showPopupMenu(getActivity(), view, bean, id -> {
            if (id == R.id.ll_go_detail) {
                AssetVehicleEditActivity.launch(getActivity(), bean);
                Logger.t(TAG).d("doanvt -- onClick detail vehicle");
            } else if (id == R.id.ll_go_edit) {
                AddVehicleActivity.launch(getActivity(), bean);
                Logger.t(TAG).d("doanvt -- onClick edit vehicle");
            } else if (id == R.id.ll_remove) {
                DialogHelper.showRemoveVehicleDialog(getActivity(), () -> {
                    if (bean != null) {
                        View viewLoading = LayoutInflater.from(getActivity()).inflate(R.layout.layout_loading_progress, null);
                        ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).addView(viewLoading);

                        int vehicleID = bean.getId();
                        Observable<BOOLResponse> observable = ApiClient.createApiService().deleteVehicleInfo(vehicleID, HornApplication.getComponent().currentUser().getAccessToken());

                        observable
                                .compose(Transformers.switchSchedulers())
                                .compose(bindToLifecycle())
                                .doFinally(() -> ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).removeView(viewLoading))
                                .subscribe(new BaseObserver<BOOLResponse>() {
                                    @Override
                                    protected void onHandleSuccess(BOOLResponse response) {
                                        boolean result = response.isSuccess();
                                        Logger.t(TAG).d("unbindOrRemove result: " + result);
                                        if (response.isSuccess()) {
                                            Toast.makeText(getActivity(), response.isSuccess() ? "Xóa xe thành công" : "Xóa xe lỗi", Toast.LENGTH_SHORT).show();
                                            requestAsset();
                                        } else {
                                            NetworkErrorHelper.handleExpireToken(getActivity(), response);
                                        }
                                    }
                                });
                    }
                });
                Logger.t(TAG).d("doanvt -- onClick remove vehicle");
            } else if (id == R.id.ll_add_driver) {
                Logger.t(TAG).d("doanvt -- onClick add driver");
                PersonnelEditActivity.launchForResult(getActivity(), PersonnelEditActivity.DRIVER, !StringUtils.isEmpty(bean.getDriverName()) ? bean.getDriverName() : "Rỗng", REQUEST_CODE_DRIVER, bean.getId(), bean.getDriverId(), bean.getCameraId(), bean.getPlateNo());
            } else if (id == R.id.ll_add_camera) {
                PersonnelEditActivity.launchForResult(getActivity(), PersonnelEditActivity.DEVICE, bean.getDriverName(), REQUEST_CODE_DEVICE, bean.getId(), bean.getDriverId(), bean.getCameraId(), bean.getPlateNo());
                Logger.t(TAG).d("doanvt -- onClick add camera");
            }
        });
    }

    @Override
    public void onAddVehicle() {
        AddVehicleActivity.launch(getActivity());
    }

    @Override
    public void onClickDeviceItem(FleetCameraBean bean, View view) {

        Logger.t(TAG).d("onClickItem CameraBean: " + bean);
        DialogHelper.showPopupMenu(getActivity(), view, bean, id -> {
            switch (id) {
                case R.id.ll_go_detail:
                    AssetDeviceEditActivity.launch(getActivity(), bean);
                    break;
                case R.id.ll_go_edit:
                    AddCameraActivity.launch(getActivity(), bean);
                    break;
                case R.id.ll_go_active:
                    DialogHelper.showActivateCameraDialog(getActivity(), () -> {
                        if (bean != null) {
                            View loadingView = LayoutInflater.from(getActivity()).inflate(R.layout.layout_loading_progress, null);
                            ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                            int cameraId = bean.getId();
                            ApiClient.createApiService().activeCamera(cameraId, HornApplication.getComponent().currentUser().getAccessToken())
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(booleanRs -> {
                                                if (booleanRs.isSuccess()) {
                                                    requestAsset();
                                                    Toast.makeText(getActivity(),
                                                            "Kích hoạt thành công!", Toast.LENGTH_SHORT).show();
                                                } else {
                                                    NetworkErrorHelper.handleExpireToken(getActivity(), booleanRs);
                                                }

                                            }, throwable -> Toast.makeText(getActivity(), "Lỗi -- " + throwable.getMessage(), Toast.LENGTH_SHORT).show()
                                    );
                        }
                    });
                    break;
                case R.id.ll_remove:
                    Observable.create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                                View viewRemove = LayoutInflater.from(getActivity()).inflate(R.layout.pop_remove_deactivate, null);
                                PopupWindow popupWindow = new PopupWindow(viewRemove,
                                        CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                        CoordinatorLayout.LayoutParams.MATCH_PARENT,
                                        false);
                                popupWindow.setOutsideTouchable(false);

                                TextView textView = viewRemove.findViewById(R.id.tv_device_sn);
                                final int cameraId = bean.getId();
                                final String token = HornApplication.getComponent().currentUser()
                                        .getAccessToken();
                                if (bean != null) {
                                    textView.setText(getString(R.string.notice));
                                }

                                viewRemove.findViewById(R.id.btn_remove_device).setOnClickListener(v -> {
                                    popupWindow.dismiss();

                                    if (bean != null) {
                                        View loadingView = LayoutInflater.from(getActivity()).inflate(R.layout.layout_loading_progress, null);
                                        ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                                        String simState = bean.getSimState();
                                        Observable<BOOLResponse> observable;

                                        if (ACTIVATED.equals(simState)) {
                                            observable = ApiClient.createApiService().deactivateSim(bean.getSn())
                                                    .subscribeOn(Schedulers.io())
                                                    .compose(bindToLifecycle())
                                                    .flatMap((Function<ActivateResponse, ObservableSource<BOOLResponse>>) activateResponse -> {
                                                        if (activateResponse.isSuccess()) {
                                                            String state = activateResponse.getState();
                                                            Logger.t(TAG).d("deactivateSim state: " + state);
                                                            HornApplication.getComponent().fleetInfo().updateDeviceActivate(bean.getSn(), state);
                                                            requestAsset();
                                                            if (ACTIVATED.equals(state)) {
                                                                return Observable.empty();
                                                            } else {
                                                                return ApiClient.createApiService().deleteCamera(cameraId, token);
                                                            }
                                                        } else {
                                                            NetworkErrorHelper.handleExpireToken(getActivity(), activateResponse);
                                                            return Observable.empty();
                                                        }
                                                    });
                                        } else {
                                            observable = ApiClient.createApiService().deleteCamera(cameraId, token);
                                        }

                                        observable.compose(Transformers.switchSchedulers())
                                                .compose(bindToLifecycle())
                                                .doFinally(() -> ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                                .subscribe(boolResponse -> {
                                                    boolean result = boolResponse.isSuccess();
                                                    Logger.t(TAG).d("deleteCamera result: " + result);
                                                    if (result) {
                                                        requestAsset();
                                                        Toast.makeText(getActivity(), "Xóa camera thành công", Toast.LENGTH_SHORT).show();
                                                    } else {
                                                        NetworkErrorHelper.handleExpireToken(getActivity(), boolResponse);
                                                    }
                                                }, throwable -> Toast.makeText(getActivity(), "Lỗi --" + throwable.getMessage(), Toast.LENGTH_SHORT).show());
                                    }
                                });

                                viewRemove.findViewById(R.id.tv_cancel_remove).setOnClickListener(v -> popupWindow.dismiss());

//                                popupWindow.showAsDropDown(view);
                                emitter.onNext(Optional.ofNullable(popupWindow));
                            })
                            .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(windowOptional -> {
                                windowOptional.get().showAsDropDown(view);
                            });
                    break;
            }
        });
    }

    @Override
    public void onAddDevice() {
        AddCameraActivity.launch(getActivity());
    }

    @Override
    public void onClickDriverItem(DriverInfoBean driverInfoBean, View view) {
        Logger.t(TAG).d("onClickItem DriverBean: " + driverInfoBean);
        DialogHelper.showPopupMenu(getActivity(), view, driverInfoBean, id -> {
            switch (id) {
                case R.id.ll_go_detail:
                    AssetDriverInfoActivity.launch(getActivity(), driverInfoBean);
                    break;
                case R.id.ll_go_edit:
                    DriverActivity.launch(getActivity(), driverInfoBean);
                    break;
                case R.id.ll_remove:
                    DialogHelper.showRemoveDriverDialog(getActivity(), () -> {
                        if (driverInfoBean != null) {
                            View view1 = LayoutInflater.from(getActivity()).inflate(R.layout.layout_loading_progress, null);
                            ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).addView(view1);

                            int driverId = driverInfoBean.getId();
                            Observable<BOOLResponse> observable = ApiClient.createApiService().delDriver(driverId, HornApplication.getComponent().currentUser().getAccessToken());

                            observable
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) getActivity().findViewById(Window.ID_ANDROID_CONTENT)).removeView(view1))
                                    .subscribe(new BaseObserver<BOOLResponse>() {
                                        @Override
                                        protected void onHandleSuccess(BOOLResponse response) {
                                            boolean result = response.isSuccess();
                                            if (result) {
                                                Toast.makeText(getActivity(), "Xóa xe tài xế thành công", Toast.LENGTH_SHORT).show();
                                                requestAsset();
                                            } else {
                                                Toast.makeText(getActivity(), response.getMessage(), Toast.LENGTH_SHORT).show();
                                            }
                                        }
                                    });
                        }
                    });
                    break;
            }
        });
    }

    @Override
    public void onAddDriver() {
        DriverActivity.launch(getActivity());
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && data != null) {
            requestAsset();
        }
    }
}
