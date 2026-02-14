package com.mk.autosecure.ui.fragment;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.PermissionChecker;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CircleOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolygonOptions;
import com.google.android.gms.tasks.Task;
import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.model.PlaceLikelihood;
import com.google.android.libraries.places.api.net.FindCurrentPlaceRequest;
import com.google.android.libraries.places.api.net.FindCurrentPlaceResponse;
import com.google.android.libraries.places.api.net.PlacesClient;
import com.google.android.libraries.places.widget.AutocompleteSupportFragment;
import com.google.android.libraries.places.widget.listener.PlaceSelectionListener;
import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import com.mk.autosecure.ui.activity.settings.FenceMapActivity;
import com.mk.autosecure.ui.activity.settings.FenceRangeActivity;
import com.mk.autosecure.ui.adapter.FenceMapAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceListBean;
import com.mk.autosecure.rest_fleet.request.AddFenceBody;
import com.mk.autosecure.rest_fleet.response.FenceListResponse;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.ObservableSource;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Action;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;

import static android.Manifest.permission.ACCESS_FINE_LOCATION;
import static android.app.Activity.RESULT_OK;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSION_LOCATION_REQUESTCODE;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FenceDrawFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FenceDrawFragment extends RxFragment implements OnMapReadyCallback, GoogleMap.OnMapClickListener {

    private final static String TAG = FenceDrawFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    public final static int COLOR_FILL_FENCE = 0x4d4a90e2;

    private List<LatLng> latLngList = new ArrayList<>();

    private LatLng mCenter;
    private double mRadius = 10;

    private String mParam1;
    private String mParam2;

    private GoogleMap mGoogleMap;

    private AddFenceActivity.FenceType mFenceType = AddFenceActivity.FenceType.Circular;
    private String mFenceName;

    private FenceMapAdapter mMapAdapter;

    public FenceDrawFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment DrawFenceFragment.
     */
    public static FenceDrawFragment newInstance(AddFenceActivityViewModel.ViewModel viewModel) {
        FenceDrawFragment fragment = new FenceDrawFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public void setFenceName(String name) {
        Logger.t(TAG).d("setFenceName: " + name);
        this.mFenceName = name;
    }

    public void setFenceType(AddFenceActivity.FenceType type) {
        Logger.t(TAG).d("setFenceType: " + type);
        this.mFenceType = type;

        showFenceLayout(type);
//        currentLocation();
    }

    private void showFenceLayout(AddFenceActivity.FenceType type) {
        if (parentViewModel != null && parentViewModel.editMode) {
            if (type == AddFenceActivity.FenceType.Circular) {
                llNextPolygonal.setVisibility(View.GONE);
                llNextCircular.setVisibility(View.VISIBLE);
            } else if (type == AddFenceActivity.FenceType.Polygonal) {
                llNextCircular.setVisibility(View.GONE);
                llNextPolygonal.setVisibility(View.VISIBLE);
            }
            return;
        }

        if (tvDrawTips != null) {
            switch (type) {
                case Circular:
                    tvDrawTips.setText(R.string.select_the_central_point_on_the_map);
                    rlDrawFence.setVisibility(View.VISIBLE);
                    flReused.setVisibility(View.GONE);
                    ivCleanMap.setVisibility(View.GONE);
                    llNextPolygonal.setVisibility(View.GONE);
                    break;
                case Polygonal:
                    tvDrawTips.setText(R.string.tap_on_the_map_to_siege_the_geo_fencing_area);
                    rlDrawFence.setVisibility(View.VISIBLE);
                    flReused.setVisibility(View.GONE);
                    ivCleanMap.setVisibility(View.VISIBLE);
                    llNextCircular.setVisibility(View.GONE);
                    break;
                case Reused:
                    tvDrawTips.setText(R.string.select_one_existing_graph_to_create_a_new_zone);
                    rlDrawFence.setVisibility(View.GONE);
                    flReused.setVisibility(View.VISIBLE);
                    requestListMap();
                    break;
            }
        }
    }

    @BindView(R.id.tv_draw_tips)
    TextView tvDrawTips;

    @BindView(R.id.rl_draw_fence)
    RelativeLayout rlDrawFence;

    @BindView(R.id.iv_clean_map)
    ImageView ivCleanMap;

    @BindView(R.id.iv_current_location)
    ImageView ivCurrentLocation;

    @BindView(R.id.fl_autocomplete)
    FrameLayout flAutocomplete;

    @BindView(R.id.fl_reused)
    FrameLayout flReused;

    @BindView(R.id.refresh_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_fence)
    RecyclerView rvFence;

    @BindView(R.id.ll_next_circular)
    LinearLayout llNextCircular;

    @BindView(R.id.btn_next_circular)
    Button btnNextCircular;

    @BindView(R.id.ll_next_polygonal)
    LinearLayout llNextPolygonal;

    @BindView(R.id.btn_next_polygonal)
    Button btnNextPolygonal;

    @BindView(R.id.tv_circular_radius)
    TextView tvCircularRadius;

    @OnClick(R.id.iv_clean_map)
    void cleanMap() {
        latLngList.remove(latLngList.size() - 1);
        drawPolygonalFence(false);
    }

    @OnClick(R.id.iv_current_location)
    void currentLocation() {
        Logger.t(TAG).d("currentLocation: " + isInflate + " " + isVisibleToUser);
        if (!isInflate || !isVisibleToUser) {
            return;
        }
        requestPermission();
    }

    private void requestPermission() {
        if (parentViewModel != null && parentViewModel.editMode) {
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Call findCurrentPlace and handle the response (first check that the user has granted permission).
            if (PermissionChecker.checkSelfPermission(mContext, ACCESS_FINE_LOCATION) == PermissionChecker.PERMISSION_GRANTED) {
                findCurrentPlace();
            } else {
                requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_LOCATION_REQUESTCODE);
            }
        } else {
            findCurrentPlace();
        }
    }

    private void findCurrentPlace() {
        // Use fields to define the data types to return.
        List<Place.Field> placeFields = Collections.singletonList(Place.Field.LAT_LNG);
        // Use the builder to create a FindCurrentPlaceRequest.
        FindCurrentPlaceRequest request = FindCurrentPlaceRequest.newInstance(placeFields);
        // Create a new Places client instance
        PlacesClient placesClient = Places.createClient(mContext);

        if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        Task<FindCurrentPlaceResponse> placeResponse = placesClient.findCurrentPlace(request);
        placeResponse.addOnCompleteListener(task -> {
            Logger.t(TAG).d("find current place: " + task.isSuccessful());
            if (task.isSuccessful()) {
                FindCurrentPlaceResponse response = task.getResult();
                if (response == null || response.getPlaceLikelihoods().size() == 0) {
                    markCurrentLocation(null);
                    return;
                }
                List<PlaceLikelihood> placeLikelihoods = response.getPlaceLikelihoods();
                PlaceLikelihood likelihood = placeLikelihoods.get(0);
                LatLng latLng = likelihood.getPlace().getLatLng();
                Logger.t(TAG).d(String.format(Locale.getDefault(),
                        "Place '%s' has likelihood: %f",
                        latLng,
                        likelihood.getLikelihood()));
                markCurrentLocation(latLng);
            } else {
                Exception exception = task.getException();
                if (exception instanceof ApiException) {
                    ApiException apiException = (ApiException) exception;
                    Logger.t(TAG).e("Place not found: " + apiException.getStatusCode());
                }
                markCurrentLocation(null);
            }
        });
    }

    //定位当前位置
    private void markCurrentLocation(LatLng latLng) {
        Logger.t(TAG).d("markCurrentLocation: " + latLng);
        if (latLng == null) {
            //default location America white house
            latLng = new LatLng(38.8977, -77.0365);
        }

        if (mGoogleMap != null) {
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 10));
        }
//        drawFence(latLng, true, null, null);
    }

    @OnClick(R.id.ll_circular_range)
    void intentRange() {
        if (parentViewModel != null && parentViewModel.editMode) {
            return;
        }
        String radius = tvCircularRadius.getText().toString().trim();
        FenceRangeActivity.launch(this, radius);
    }

    private View loadingView;

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_next_circular)
    void nextCircular() {
        Logger.t(TAG).d("nextCircular");

        if (parentViewModel != null && parentViewModel.editMode) {
            if (mActivity != null && mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).proceed(1);
            }
            return;
        }

        btnNextCircular.setEnabled(false);
        Logger.t(TAG).d("setEnabled(false);");

        loadingView = LayoutInflater.from(mContext).inflate(R.layout.layout_loading_progress, null);
        ((FrameLayout) mActivity.findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

        AddFenceBody body = new AddFenceBody();
        body.name = mFenceName;
        List<Double> doubles = new ArrayList<>();
        LatLng tempLatLng = MapTransformUtil.gcj02_To_Gps84(mCenter);
        doubles.add(tempLatLng.latitude);
        doubles.add(tempLatLng.longitude);
        body.center = doubles;
        body.radius = (int) (mRadius * 1609);

        ApiClient.createApiService().addFence(body)
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .doFinally(() -> {
                    ((FrameLayout) mActivity.findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView);
                    btnNextCircular.setEnabled(true);
                })
                .subscribe(response -> {
                    Logger.t(TAG).d("addFence response: " + response);
                    if (parentViewModel != null && parentViewModel.inputs != null) {
                        parentViewModel.inputs.fenceID(response.getFenceID());
                    }
                    if (mActivity != null && mActivity instanceof AddFenceActivity) {
                        ((AddFenceActivity) mActivity).proceed(1);
                    }
                }, throwable -> {
                    Logger.t(TAG).e("addFence throwable: " + throwable.getMessage());
                    Toast.makeText(mContext, getString(R.string.geo_fence_zone_failed_to_add_please_try_again), Toast.LENGTH_SHORT).show();
                });
    }

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_next_polygonal)
    void nextPolygonal() {
        Logger.t(TAG).d("nextPolygonal: " + latLngList.size());

        if (parentViewModel != null && parentViewModel.editMode) {
            if (mActivity != null && mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).proceed(1);
            }
            return;
        }

//        if (latLngList.size() < 3 || latLngList.size() > 500) {
//            Toast.makeText(mContext, "GeoFencing error", Toast.LENGTH_SHORT).show();
//            return;
//        }

        btnNextPolygonal.setEnabled(false);
        Logger.t(TAG).d("setEnabled(false);");

        loadingView = LayoutInflater.from(mContext).inflate(R.layout.layout_loading_progress, null);
        ((FrameLayout) mActivity.findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

        AddFenceBody body = new AddFenceBody();
        body.name = mFenceName;
        List<List<Double>> tempList = new ArrayList<>();
        for (int i = latLngList.size() - 1; i >= 0; i--) {
            List<Double> doubles = new ArrayList<>();
            LatLng tempLatLng = MapTransformUtil.gcj02_To_Gps84(latLngList.get(i));
            doubles.add(tempLatLng.latitude);
            doubles.add(tempLatLng.longitude);
            tempList.add(doubles);
        }
        tempList.add(tempList.get(0));
        body.polygon = tempList;

        ApiClient.createApiService().addFence(body)
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .doFinally(() -> {
                    ((FrameLayout) mActivity.findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView);
                    btnNextPolygonal.setEnabled(true);
                })
                .subscribe(response -> {
                    Logger.t(TAG).d("addFence response: " + response);
                    if (parentViewModel != null && parentViewModel.inputs != null) {
                        parentViewModel.inputs.fenceID(response.getFenceID());
                    }
                    if (mActivity != null && mActivity instanceof AddFenceActivity) {
                        ((AddFenceActivity) mActivity).proceed(1);
                    }
                }, throwable -> {
                    Logger.t(TAG).e("addFence throwable: " + throwable.getMessage());
                    Toast.makeText(mContext, R.string.geo_fence_zone_failed_to_add_please_try_again, Toast.LENGTH_SHORT).show();
                });
    }

    private boolean isVisibleToUser;
    private boolean isInflate;

    private Context mContext;
    private Activity mActivity;
    private AddFenceActivityViewModel.ViewModel parentViewModel;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

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
        View view = inflater.inflate(R.layout.fragment_fence_draw, container, false);
        ButterKnife.bind(this, view);
        isInflate = true;
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
        Logger.t(TAG).d("isVisibleToUser: " + isVisibleToUser);
        if (isVisibleToUser) {
            requestPermission();
        }
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        this.isVisibleToUser = isVisibleToUser;
        Logger.t(TAG).d("setUserVisibleHint: " + isVisibleToUser + " " + isInflate);
        if (isInflate && isVisibleToUser) {
            requestPermission();
        }
    }

    private void initView() {
        SupportMapFragment fragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.googleMap);
        if (fragment != null) {
            fragment.getMapAsync(this);
        }

        if (parentViewModel != null && parentViewModel.editMode) {
            rlDrawFence.setVisibility(View.VISIBLE);
            tvDrawTips.setText(R.string.the_graph_is_for_preview_only_and_cannot_be_edited);
            flAutocomplete.setVisibility(View.GONE);
            ivCleanMap.setVisibility(View.GONE);
            ivCurrentLocation.setVisibility(View.GONE);
        } else {
            flAutocomplete.setVisibility(View.VISIBLE);

            // Initialize the AutocompleteSupportFragment.
            AutocompleteSupportFragment autocompleteFragment = (AutocompleteSupportFragment)
                    getChildFragmentManager().findFragmentById(R.id.autocomplete_fragment);

            // Specify the types of place data to return.
            if (autocompleteFragment != null) {
                autocompleteFragment.setHint(getString(R.string.search_a_location));
                autocompleteFragment.setPlaceFields(Arrays.asList(Place.Field.ID, Place.Field.NAME, Place.Field.ADDRESS, Place.Field.LAT_LNG));
                // Set up a PlaceSelectionListener to handle the response.
                autocompleteFragment.setOnPlaceSelectedListener(new PlaceSelectionListener() {
                    @Override
                    public void onPlaceSelected(@NonNull Place place) {
                        Logger.t(TAG).d("onPlaceSelected: " + place);
                        LatLng latLng = place.getLatLng();
                        //搜索某个位置
                        if (latLng != null && mGoogleMap != null) {
                            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 10));
//                            drawFence(latLng, true, null, null);
                        }
                    }

                    @Override
                    public void onError(@NonNull Status status) {
                        Logger.t(TAG).e("onError: " + status);
                    }
                });
            }
        }

        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            requestListMap();
        });

        rvFence.setLayoutManager(new LinearLayoutManager(mContext));
        rvFence.setRecyclerListener(recyclerListener);
        mMapAdapter = new FenceMapAdapter(R.layout.item_fence_map);
        mMapAdapter.setOperationListener(bean -> {
            Logger.t(TAG).d("onClickItem: " + bean);
            FenceMapActivity.launch(FenceDrawFragment.this, bean);
        });
        rvFence.setAdapter(mMapAdapter);
    }

    @SuppressLint("CheckResult")
    @Override
    public void onResume() {
        super.onResume();

        Logger.t(TAG).d("onResume: " + mFenceType);
        showFenceLayout(mFenceType);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Logger.t(TAG).d("onMapReady: " + googleMap);
        mGoogleMap = googleMap;
        if (parentViewModel != null && parentViewModel.editMode) {
            setMapLocation();
        } else {
            mGoogleMap.setOnMapClickListener(this);
            currentLocation();
        }
    }

    @SuppressLint("CheckResult")
    private void setMapLocation() {
        if (mGoogleMap == null) return;

        parentViewModel.detailBean()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onDetailBean, new ServerErrorHandler(TAG));
    }

    private void onDetailBean(FenceDetailBean bean) {
        if (bean == null) return;

        List<List<Double>> polygon = bean.getPolygon();
        if (polygon != null) {
            if (polygon.size() == 0) {
                Logger.t(TAG).e("polygon size is 0 !!!");
                return;
            }

            List<LatLng> latLngs = new ArrayList<>();
            for (int i = 0; i < polygon.size(); i++) {
                List<Double> doubleList = polygon.get(i);
                latLngs.add(MapTransformUtil.gps84_To_Gcj02(new LatLng(doubleList.get(0), doubleList.get(1))));
            }
            latLngs.add(latLngs.get(0));

            moveMapCenter(latLngs);

            mGoogleMap.addPolygon(new PolygonOptions()
                    .addAll(latLngs)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        } else {
            List<Double> center = bean.getCenter();
            int radius = bean.getRadius();

            LatLng latLng = MapTransformUtil.gps84_To_Gcj02(new LatLng(center.get(0), center.get(1)));
//            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 7));
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng,
                    MapTransformUtil.getZoomLevel(mGoogleMap, radius)));

            mGoogleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .anchor(0.5f, 0.5f)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_circular_point)));

            mGoogleMap.addCircle(new CircleOptions()
                    .center(latLng)
                    .radius(radius)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        }

        // Set the map type back to normal.
        mGoogleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
    }

    private void moveMapCenter(List<LatLng> latLngs) {
//        Logger.t(TAG).d("moveMapCenter: " + latLngs.size());
        if (latLngs.size() == 0) {
            return;
        }

        LatLngBounds.Builder builder = new LatLngBounds.Builder();
        for (LatLng latLng : latLngs) {
            builder.include(latLng);
        }
        mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), ViewUtils.dp2px(40)));
    }

    private void drawFence(LatLng latLng, boolean moveCamera, Action circularAc, Action polygonalAc) {
        if (mFenceType == AddFenceActivity.FenceType.Circular) {
            mCenter = latLng;
            drawCircleFence(moveCamera);

            try {
                if (circularAc != null) {
                    circularAc.run();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (mFenceType == AddFenceActivity.FenceType.Polygonal) {
            if (latLngList.size() < 500) {
                latLngList.add(latLng);
                drawPolygonalFence(moveCamera);

                try {
                    if (polygonalAc != null) {
                        polygonalAc.run();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                Toast.makeText(mContext, getString(R.string.more_points_are_not_supported), Toast.LENGTH_SHORT).show();
            }
        }
    }

    @Override
    public void onMapClick(LatLng latLng) {
        Logger.t(TAG).d("onMapClick: " + latLng);
        drawFence(latLng, false,
                () -> {
                    if (llNextCircular.getVisibility() == View.GONE) {
                        llNextCircular.setVisibility(View.VISIBLE);
                    }
                }, () -> {
                    if (latLngList.size() >= 3 && llNextPolygonal.getVisibility() == View.GONE) {
                        llNextPolygonal.setVisibility(View.VISIBLE);
                    }
                });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode
                + " " + Arrays.toString(permissions)
                + " " + Arrays.toString(grantResults));
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_LOCATION_REQUESTCODE) {
            if (grantResults.length > 0 &&
                    grantResults[0] == PermissionChecker.PERMISSION_GRANTED) {
                findCurrentPlace();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(ACCESS_FINE_LOCATION);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    markCurrentLocation(null);
                }
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Logger.t(TAG).d("onActivityResult: " + requestCode + " " + resultCode);
        if (requestCode == FenceRangeActivity.FENCE_RANGE_CODE && resultCode == RESULT_OK && data != null) {
            String radius = data.getStringExtra(FenceRangeActivity.FENCE_RANGE);
            Logger.t(TAG).d("onActivityResult radius: " + radius);
            if (radius != null) {
                mRadius = Double.parseDouble(radius);
            }
            tvCircularRadius.setText(radius);
            drawCircleFence(true);
        } else if (requestCode == FenceMapActivity.FENCE_MAP_CODE && resultCode == RESULT_OK && data != null) {
            FenceDetailBean detailBean = (FenceDetailBean) data.getSerializableExtra(FenceMapActivity.FENCE_MAP);
            Logger.t(TAG).d("onActivityResult detailBean: " + detailBean);
            if (detailBean != null) {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.fenceID(detailBean.getFenceID());
                }
                if (mActivity != null && mActivity instanceof AddFenceActivity) {
                    ((AddFenceActivity) mActivity).proceed(1);
                }
            }
        }
    }

    private void drawCircleFence(boolean moveCamera) {
        if (mGoogleMap == null) {
            return;
        }
        mGoogleMap.clear();

        if (moveCamera) {
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(mCenter,
                    MapTransformUtil.getZoomLevel(mGoogleMap, (int) (mRadius * 1609))));
        } else {
//            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLng(mCenter));
        }

        mGoogleMap.addMarker(new MarkerOptions()
                .position(mCenter)
                .anchor(0.5f, 0.5f)
                .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_circular_point)));

        mGoogleMap.addCircle(new CircleOptions()
                .center(mCenter)
                .fillColor(COLOR_FILL_FENCE)
                .radius(mRadius * 1609)
                .strokeColor(COLOR_FILL_FENCE)
                .strokeWidth(4));
    }

    private void drawPolygonalFence(boolean moveCamera) {
        if (btnNextPolygonal != null) btnNextPolygonal.setEnabled(latLngList.size() >= 3);

        if (mGoogleMap == null) {
            return;
        }
        mGoogleMap.clear();

        List<LatLng> tempList = new ArrayList<>();
        LatLngBounds.Builder builder = new LatLngBounds.Builder();
        for (int i = latLngList.size() - 1; i >= 0; i--) {
            LatLng latLng = latLngList.get(i);
            tempList.add(latLng);
            builder.include(latLng);

            mGoogleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .anchor(0.5f, 0.5f)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_circular_point)));
        }
        if (moveCamera) {
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), ViewUtils.dp2px(40)));
        }

        if (tempList.size() > 0) {
            tempList.add(tempList.get(0));
//            List<LatLng> simplify = PolyUtil.simplify(tempList, 0);
            mGoogleMap.addPolygon(new PolygonOptions()
                    .addAll(tempList)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        }
    }

    public interface FenceOperationListener {
        void onClickItem(FenceDetailBean bean);
    }

    private RecyclerView.RecyclerListener recyclerListener = holder -> {
        FenceMapAdapter.FenceViewHolder mapHolder = (FenceMapAdapter.FenceViewHolder) holder;
        if (mapHolder.googleMap != null) {
            // Clear the map and free up resources by changing the map type to none.
            // Also reset the map when it gets reattached to layout, so the previous map would
            // not be displayed.
            mapHolder.googleMap.clear();
            mapHolder.googleMap.setMapType(GoogleMap.MAP_TYPE_NONE);
        }
    };

    @SuppressLint("CheckResult")
    private void requestListMap() {
        refreshLayout.setRefreshing(true);

        ApiClient.createApiService().getFenceList("all")
                .flatMapIterable((Function<FenceListResponse, Iterable<FenceListBean>>) FenceListResponse::getFenceList)
                .flatMap((Function<FenceListBean, ObservableSource<FenceDetailBean>>) fenceListBean -> ApiClient.createApiService().getFenceDetail(fenceListBean.getFenceID()))
                .toList()
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(fenceDetailBeans -> {
                    Logger.t(TAG).d("fenceDetailBeans: " + fenceDetailBeans);
                    mMapAdapter.setNewData(fenceDetailBeans);
                }, throwable -> Logger.t(TAG).e("getFenceList or getFenceDetail throwable: " + throwable.getMessage()));
    }
}
