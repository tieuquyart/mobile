package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.viewpager.widget.ViewPager;

import com.google.android.material.tabs.TabLayout;
import com.mk.autosecure.ui.adapter.MyFragmentPagerAdapter;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.ui.fragment.AssetFragment;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class AssetActivity extends AppCompatActivity {

    private final static String TAG = AssetActivity.class.getSimpleName();

    public static void launch(Activity activity, int index) {
        Intent intent = new Intent(activity, AssetActivity.class);
        intent.putExtra("indexView",index);
        activity.startActivity(intent);
    }

    @BindView(R.id.tabLayout)
    TabLayout tabLayout;

    @BindView(R.id.title_toolbar)
    TextView titleToolbar;

    @BindView(R.id.viewpager)
    ViewPager viewPager;

    @BindView(R.id.btn_add_vehicle)
    Button btnAddVehicle;

    @BindView(R.id.btn_add_camera)
    Button btnAddCamera;

    @BindView(R.id.btn_add_driver)
    Button btnAddDriver;

    @OnClick(R.id.btn_add_vehicle)
    public void addVehicle() {
        Logger.t(TAG).d("addVehicle");
        AddVehicleActivity.launch(this);
    }

    @OnClick(R.id.btn_add_camera)
    public void addCamera() {
        Logger.t(TAG).d("addCamera");
        AddCameraActivity.launch(this,null);
    }

    @OnClick(R.id.btn_add_driver)
    public void addDriver() {
        Logger.t(TAG).d("addCamera");
        DriverActivity.launch(this);
    }

    int indexView;
    String[] titles = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_asset);
        ButterKnife.bind(this);
        titles = new String[]{getResources().getString(R.string.vehicle_manage), getResources().getString(R.string.driver_manage),getResources().getString(R.string.devices_manage)};

        if (getIntent() != null) {
            indexView = getIntent().getIntExtra("indexView", 0);
        }
        initView();
    }

    private void initView() {
        setToolbar();

        MyFragmentPagerAdapter pagerAdapter = new MyFragmentPagerAdapter(getSupportFragmentManager());
        pagerAdapter.clearFragments();
        pagerAdapter.addFragment(AssetFragment.newInstance(1, indexView));
        tabLayout.addTab(tabLayout.newTab());

        tabLayout.setupWithViewPager(viewPager, false);
        viewPager.setAdapter(pagerAdapter);
        btnAddVehicle.setVisibility(indexView == 0 ? View.VISIBLE : View.GONE);
        btnAddCamera.setVisibility(indexView == 2 ? View.VISIBLE : View.GONE);
        btnAddDriver.setVisibility(indexView == 1 ? View.VISIBLE : View.GONE);
        tabLayout.getChildAt(0).setVisibility(View.GONE);

    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
        titleToolbar.setText(titles[indexView]);
    }

}
