package com.mk.autosecure.ui.activity.settings;

import androidx.appcompat.widget.Toolbar;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.mk.autosecure.ui.adapter.MyFragmentPagerAdapter;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.ui.fragment.DataCameraFragment;
import com.mk.autosecure.ui.fragment.DataFleetFragment;

import butterknife.BindView;
import butterknife.ButterKnife;

public class DataUsageActivity extends RxAppCompatActivity {

    private final static String TAG = DataUsageActivity.class.getSimpleName();

    @BindView(R.id.vp_data_usage)
    CustomViewPager vpDataUsage;

    private DataCameraFragment dataCameraFragment;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, DataUsageActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_data_usage);
        ButterKnife.bind(this);

        initView();
    }

    private void initView() {
        setToolbar();

        MyFragmentPagerAdapter adapter = new MyFragmentPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(DataFleetFragment.newInstance());

        dataCameraFragment = DataCameraFragment.newInstance();
        adapter.addFragment(dataCameraFragment);

        vpDataUsage.setAdapter(adapter);
    }

    public void showDataDetail(BillingDataBean dataBean) {
        dataCameraFragment.setArgs(dataBean);
        vpDataUsage.setCurrentItem(1, true);
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> {
            int currentItem = vpDataUsage.getCurrentItem();
            if (currentItem == 1) {
                vpDataUsage.setCurrentItem(0, true);
            } else {
                finish();
            }
        });
    }
}
