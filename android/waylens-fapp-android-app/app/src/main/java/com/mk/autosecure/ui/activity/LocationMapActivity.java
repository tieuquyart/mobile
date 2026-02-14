package com.mk.autosecure.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.MapTransformUtil;

import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class LocationMapActivity extends AppCompatActivity implements OnMapReadyCallback {

    private final static String TAG = LocationMapActivity.class.getSimpleName();
    private final static String LATITUDE = "latitude";
    private final static String LONGITUDE = "longitude";
    private final static String ADDRESS = "address";

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_direct_location)
    TextView tv_direct_location;

    private double latitude;

    private double longitude;

    public static void launch(Activity activity, double latitude, double longitude, String address) {
        Intent intent = new Intent(activity, LocationMapActivity.class);
        intent.putExtra(LATITUDE, latitude);
        intent.putExtra(LONGITUDE, longitude);
        intent.putExtra(ADDRESS, address);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_location_map);
        ButterKnife.bind(this);

        setupToolbar();

        latitude = getIntent().getDoubleExtra(LATITUDE, 0);
        longitude = getIntent().getDoubleExtra(LONGITUDE, 0);
        String address = getIntent().getStringExtra(ADDRESS);

        Logger.t(TAG).d("latitude: " + latitude + " longitude: " + longitude
                + " address: " + address);

        if (!TextUtils.isEmpty(address)) {
            tv_direct_location.setText(address);
        } else if (latitude != 0 && longitude != 0) {
            String lat = String.format(Locale.ENGLISH, "%.4f", latitude);
            String lng = String.format(Locale.ENGLISH, "%.4f", longitude);
            tv_direct_location.setText(String.format("%s, %s", lat, lng));
        }

        SupportMapFragment mapFragment =
                (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        Logger.t(TAG).d("mapFragment: " + mapFragment);
        if (mapFragment != null) {
            mapFragment.getMapAsync(this);
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.direct_location));
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
//        GoogleMapLogUtil.logMaps();
    }

    @OnClick(R.id.iv_direct)
    public void direct() {
        // Creates an Intent that will load a map of San Francisco
//        String latLng = "geo:" + cameraBean.gps.latitude + "," + cameraBean.gps.longitude + "?z=18";

        //d:驾驶 w:步行 b:骑行  设置步行比较合理
        String latLng = "google.navigation:q=" + latitude + "," + longitude + "&mode=w";
        Uri gmmIntentUri = Uri.parse(latLng);

        Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
        mapIntent.setPackage("com.google.android.apps.maps");

        if (mapIntent.resolveActivity(getPackageManager()) != null) {
            startActivity(mapIntent);
        } else {
            Toast.makeText(this, R.string.map_not_available, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Logger.t(TAG).d("onMapReady: " + latitude + "  " + longitude);

        try {
            LatLng point = MapTransformUtil.gps84_To_Gcj02(new LatLng(latitude, longitude));

            //添加标记到指定经纬度
            googleMap.addMarker(new MarkerOptions().position(point).title("Marker")
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.icon_map)));

            googleMap.setOnMarkerClickListener(marker -> false);

            googleMap.moveCamera(CameraUpdateFactory.newLatLng(point));

            // 设置缩放级别
            googleMap.animateCamera(CameraUpdateFactory.zoomTo(18));

            // 不允许手势缩放
            googleMap.getUiSettings().setZoomGesturesEnabled(false);

        } catch (Exception ex) {
            Logger.t(TAG).e("onMapReady error: " + ex.getMessage());
        }
    }
}
