package com.mk.autosecure.ui.adapter;

import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CircleOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolygonOptions;
import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest_fleet.bean.AddressBean;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.ui.fragment.FenceDrawFragment;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

import static com.mk.autosecure.ui.fragment.FenceDrawFragment.COLOR_FILL_FENCE;

import androidx.annotation.NonNull;

/**
 * Created by cloud on 2020/5/13.
 */
public class FenceMapAdapter extends BaseQuickAdapter<FenceDetailBean, FenceMapAdapter.FenceViewHolder> {

    private final static String TAG = FenceMapAdapter.class.getSimpleName();

    private FenceDrawFragment.FenceOperationListener mListener;

    public FenceMapAdapter(int layoutResId) {
        super(layoutResId);
    }

    public void setOperationListener(FenceDrawFragment.FenceOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(FenceViewHolder helper, FenceDetailBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(FenceViewHolder helper, FenceDetailBean item) {
        List<FenceRuleBean> ruleList = item.getFenceRuleList();
        if (ruleList != null && ruleList.size() != 0) {
            helper.tvNotUsed.setVisibility(View.GONE);
            helper.tvFenceName.setVisibility(View.VISIBLE);

            List<String> stringList = new ArrayList<>();
            for (FenceRuleBean ruleBean : ruleList) {
                String ruleName = ruleBean.getName();
                List<String> type = ruleBean.getType();
                List<String> tempType = new ArrayList<>();
                for (String string : type) {
                    string = string.substring(0, 1).toUpperCase() + string.substring(1);
                    tempType.add(string);
                }
                stringList.add(String.format("%s(%s)", ruleName, tempType));
            }
            helper.tvFenceName.setText(stringList.toString()
                    .replace("[", "")
                    .replace("]", ""));
        } else {
            helper.tvNotUsed.setVisibility(View.VISIBLE);
            helper.tvFenceName.setVisibility(View.GONE);
        }

        AddressBean address = item.getAddress();
        if (address != null) {
            helper.tvFenceLocation.setText(address.getAddress());
        }

        helper.bindView(item);

        helper.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(item);
            }
        });
    }

    @Override
    public void onViewAttachedToWindow(FenceViewHolder holder) {
        super.onViewAttachedToWindow(holder);

    }

    public static class FenceViewHolder extends BaseViewHolder implements OnMapReadyCallback {

        @BindView(R.id.tv_not_used)
        TextView tvNotUsed;

        @BindView(R.id.tv_fence_name)
        TextView tvFenceName;

        @BindView(R.id.tv_fence_location)
        TextView tvFenceLocation;

        @BindView(R.id.mapView)
        MapView mapView;

        public GoogleMap googleMap;
        View layout;

        public FenceViewHolder(View view) {
            super(view);
            layout = view;
            ButterKnife.bind(this, view);
            if (mapView != null) {
                mapView.onCreate(null);
                mapView.setClickable(false);
                mapView.getMapAsync(this);
            }
        }

        @Override
        public void onMapReady(GoogleMap googleMap) {
            Logger.t(TAG).d("onMapReady: " + googleMap);
            MapsInitializer.initialize(HornApplication.getContext(), MapsInitializer.Renderer.LATEST, renderer -> Logger.t(TAG).d(renderer.toString()));
            this.googleMap = googleMap;
            setMapLocation();
        }

        private void setMapLocation() {
            if (googleMap == null) return;

            FenceDetailBean bean = (FenceDetailBean) mapView.getTag();
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
//                googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 7));
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

        private void bindView(FenceDetailBean bean) {
            // Store a reference of the ViewHolder object in the layout.
            layout.setTag(this);
            // Store a reference to the item in the mapView's tag. We use it to get the
            // coordinate of a location, when setting the map location.
            mapView.setTag(bean);
            setMapLocation();
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
            googleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), ViewUtils.dp2px(16)));
        }
    }
}
