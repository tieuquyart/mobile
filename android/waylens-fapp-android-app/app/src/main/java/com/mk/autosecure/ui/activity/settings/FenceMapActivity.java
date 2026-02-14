package com.mk.autosecure.ui.activity.settings;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

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
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

import static com.mk.autosecure.ui.fragment.FenceDrawFragment.COLOR_FILL_FENCE;

public class FenceMapActivity extends AppCompatActivity implements OnMapReadyCallback {

    private final static String TAG = FenceMapActivity.class.getSimpleName();

    public final static String FENCE_MAP = "fence_map";
    public final static int FENCE_MAP_CODE = 1001;

    public static void launch(Fragment fragment, FenceDetailBean bean) {
        Intent intent = new Intent(fragment.getContext(), FenceMapActivity.class);
        intent.putExtra(FENCE_MAP, bean);
        fragment.startActivityForResult(intent, FENCE_MAP_CODE);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.ll_next_circular)
    LinearLayout llNextCircular;

    @BindView(R.id.ll_next_polygonal)
    LinearLayout llNextPolygonal;

    @OnClick({R.id.btn_next_circular, R.id.btn_next_polygonal})
    public void next() {
        Intent intent = new Intent();
        intent.putExtra(FENCE_MAP, detailBean);
        setResult(RESULT_OK, intent);
        finish();
    }

    private FenceDetailBean detailBean;
    private GoogleMap googleMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fence_map);
        ButterKnife.bind(this);

        detailBean = (FenceDetailBean) getIntent().getSerializableExtra(FENCE_MAP);

        setupToolbar();
        initView();
    }

    private void initView() {
        tvToolbarTitle.setText(R.string.add_new_zone);

        SupportMapFragment fragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map_fence);
        if (fragment != null) {
            fragment.getMapAsync(this);
        }

        List<List<Double>> polygon = detailBean.getPolygon();
        if (polygon != null) {
            llNextPolygonal.setVisibility(View.VISIBLE);
        } else {
            llNextCircular.setVisibility(View.VISIBLE);
        }
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Logger.t(TAG).d("onMapReady: " + googleMap);
        this.googleMap = googleMap;
        new Handler().postDelayed(this::setMapLocation, 300);
    }

    private void setMapLocation() {
        if (googleMap == null) return;

        FenceDetailBean bean = detailBean;
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

            googleMap.addPolygon(new PolygonOptions()
                    .addAll(latLngs)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        } else {
            List<Double> center = bean.getCenter();
            int radius = bean.getRadius();

            LatLng latLng = MapTransformUtil.gps84_To_Gcj02(new LatLng(center.get(0), center.get(1)));
//            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 7));
            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng,
                    MapTransformUtil.getZoomLevel(googleMap, radius)));

            googleMap.addMarker(new MarkerOptions()
                    .position(latLng)
                    .anchor(0.5f, 0.5f)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_circular_point)));

            googleMap.addCircle(new CircleOptions()
                    .center(latLng)
                    .radius(radius)
                    .fillColor(COLOR_FILL_FENCE)
                    .strokeColor(COLOR_FILL_FENCE)
                    .strokeWidth(5));
        }

        // Set the map type back to normal.
        googleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
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
        googleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), ViewUtils.dp2px(40)));
    }
}
